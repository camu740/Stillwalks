package com.stillwalks.app

import android.content.Context
import android.content.SharedPreferences
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.util.Log
import android.content.Intent // Added import
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.BinaryMessenger // Explicit import for clarity

/**
 * Servicio que cuenta pasos usando el sensor de hardware del dispositivo
 * y actualiza el progreso de Orbes en santuarios.
 */
class StepCounterService private constructor(
    private val context: Context
) : SensorEventListener {

    companion object {
        private const val TAG = "StepCounterService"
        private const val PREFS_NAME = "stillwalks_prefs"
        private const val KEY_LAST_STEP_COUNT = "last_step_count"
        private const val KEY_SESSION_STEPS = "session_steps"
        private const val KEY_LAST_UPDATE_TIME = "last_step_update_time"
        
        // Anti-cheat: máximo ~250 pasos por minuto (4.16 pasos/segundo)
        // Relaxing for batch updates: average speed check over longer periods
        private const val MAX_STEPS_PER_SECOND = 10
        // Increased significantly to allow for long walks with phone in pocket (Doze mode)
        private const val MAX_STEPS_PER_UPDATE = 50000 
        
        @Volatile
        private var instance: StepCounterService? = null

        fun getInstance(context: Context): StepCounterService {
            return instance ?: synchronized(this) {
                instance ?: StepCounterService(context.applicationContext).also { instance = it }
            }
        }
    }
// ...
    private val sensorManager: SensorManager = 
        context.getSystemService(Context.SENSOR_SERVICE) as SensorManager
    
    private val stepSensor: Sensor? = 
        sensorManager.getDefaultSensor(Sensor.TYPE_STEP_COUNTER)
    
    private val prefs: SharedPreferences = 
        context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
    
    private var methodChannel: MethodChannel? = null
    
    private var lastStepCount: Int = 0
    private var sessionSteps: Int = 0
    private var lastUpdateTime: Long = 0
    private var isTracking = false

    fun attachChannel(messenger: BinaryMessenger) {
        methodChannel = MethodChannel(messenger, "com.stillwalks.app/steps")
        Log.d(TAG, "MethodChannel attached")
    }

    fun detachChannel() {
        methodChannel = null
        Log.d(TAG, "MethodChannel detached")
    }
    
    // Helper since we can't easily nullify a non-nullable type if we initialized it differently earlier.
    // In this refactor, methodChannel is nullable.

    fun start() {
        if (isTracking) return
        
        if (stepSensor != null) {
            // Cargar estado guardado
            loadState()
            
            sensorManager.registerListener(
                this, 
                stepSensor, 
                SensorManager.SENSOR_DELAY_NORMAL
            )
            isTracking = true
            Log.d(TAG, "Step counter started successfully")
        } else {
            Log.e(TAG, "Step counter sensor not available on this device")
        }
    }

    fun stop() {
        if (!isTracking) return
        
        sensorManager.unregisterListener(this)
        saveState()
        isTracking = false
        Log.d(TAG, "Step counter stopped")
    }
    
    private fun loadState() {
        lastStepCount = prefs.getInt(KEY_LAST_STEP_COUNT, 0)
        sessionSteps = prefs.getInt(KEY_SESSION_STEPS, 0)
        lastUpdateTime = prefs.getLong(KEY_LAST_UPDATE_TIME, System.currentTimeMillis())
        
        Log.d(TAG, "State loaded: lastCount=$lastStepCount, session=$sessionSteps")
    }
    
    private fun saveState() {
        prefs.edit().apply {
            putInt(KEY_LAST_STEP_COUNT, lastStepCount)
            putInt(KEY_SESSION_STEPS, sessionSteps)
            putLong(KEY_LAST_UPDATE_TIME, System.currentTimeMillis())
            apply()
        }
    }

    override fun onSensorChanged(event: SensorEvent) {
        if (event.sensor.type == Sensor.TYPE_STEP_COUNTER) {
            val totalSteps = event.values[0].toInt()
            
            // Primera lectura o después de reinicio del dispositivo
            // Handle device reboot (sensor resets to 0)
            if (lastStepCount == 0 || totalSteps < lastStepCount) {
                lastStepCount = totalSteps
                lastUpdateTime = System.currentTimeMillis()
                Log.d(TAG, "Sensor reset detected or first run. Validating base: $lastStepCount")
                return
            }
            
            val newSteps = totalSteps - lastStepCount
            
            // Anti-cheat: validar que el incremento sea razonable
            if (!isStepIncrementValid(newSteps)) {
                Log.w(TAG, "Suspicious step increment detected: $newSteps steps. Ignoring.")
                return
            }
            
            if (newSteps > 0) {
                lastStepCount = totalSteps
                sessionSteps += newSteps
                val now = System.currentTimeMillis()
                lastUpdateTime = now
                
                Log.d(TAG, "New steps: $newSteps (Total session: $sessionSteps)")
                
                // Guardar periódicamente (cada 50 pasos)
                if (sessionSteps % 50 == 0) {
                    saveState()
                }
                
                // Notificar a Flutter
                onStepsDetected(newSteps, sessionSteps)
                
                // Update notification in foreground service
                // Update notification in foreground service
                val intent = Intent(context, TrackingForegroundService::class.java)
                intent.action = TrackingForegroundService.ACTION_UPDATE_NOTIFICATION
                context.startService(intent)
            }
        }
    }

    override fun onAccuracyChanged(sensor: Sensor, accuracy: Int) {
        when (accuracy) {
            SensorManager.SENSOR_STATUS_UNRELIABLE -> {
                Log.w(TAG, "Step sensor accuracy is unreliable")
            }
            SensorManager.SENSOR_STATUS_ACCURACY_LOW -> {
                Log.w(TAG, "Step sensor accuracy is low")
            }
        }
    }
    
    /**
     * Valida que el incremento de pasos sea realista
     */
    private fun isStepIncrementValid(steps: Int): Boolean {
        // Rechazar incrementos negativos
        if (steps < 0) {
            Log.w(TAG, "Negative step increment detected")
            return false
        }
        
        // Rechazar saltos absurdamente grandes (más allá de lo posible en un día)
        if (steps > MAX_STEPS_PER_UPDATE) {
            Log.w(TAG, "Step increment too large: $steps > $MAX_STEPS_PER_UPDATE")
            return false
        }
        
        // Validar velocidad (pasos por segundo) solo si el intervalo es significativo
        val currentTime = System.currentTimeMillis()
        val timeDelta = (currentTime - lastUpdateTime) / 1000.0 // en segundos
        
        if (timeDelta > 1.0) { // Solo chequear rate si ha pasado al menos 1 segundo
            val stepsPerSecond = steps / timeDelta
            if (stepsPerSecond > MAX_STEPS_PER_SECOND) {
                Log.w(TAG, "Steps per second too high: $stepsPerSecond (steps=$steps, time=${timeDelta}s)")
                return false
            }
        }
        
        return true
    }

    private fun onStepsDetected(newSteps: Int, totalSessionSteps: Int) {
        // Notificar a Flutter para actualizar UI y progreso de Orbes
        val data = mapOf(
            "newSteps" to newSteps,
            "totalSteps" to totalSessionSteps,
            "timestamp" to System.currentTimeMillis()
        )
        
        methodChannel?.invokeMethod("onStepsUpdated", data)
    }

    /**
     * Obtiene los pasos de la sesión actual
     */
    fun getSessionSteps(): Int {
        return sessionSteps
    }
    
    /**
     * Reinicia el contador de sesión (por ejemplo, para testing)
     */
    fun resetSessionSteps() {
        sessionSteps = 0
        saveState()
        Log.d(TAG, "Session steps reset")
    }
    
    /**
     * Verifica si el sensor está disponible
     */
    fun isSensorAvailable(): Boolean {
        return stepSensor != null
    }
}
