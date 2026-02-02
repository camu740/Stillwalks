package com.stillwalks.app

import android.content.Context
import android.content.SharedPreferences
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.util.Log
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * Servicio que cuenta pasos usando el sensor de hardware del dispositivo
 * y actualiza el progreso de Orbes en santuarios.
 */
class StepCounterService(
    private val context: Context,
    private val flutterEngine: FlutterEngine
) : SensorEventListener {

    companion object {
        private const val TAG = "StepCounterService"
        private const val PREFS_NAME = "stillwalks_prefs"
        private const val KEY_LAST_STEP_COUNT = "last_step_count"
        private const val KEY_SESSION_STEPS = "session_steps"
        private const val KEY_LAST_UPDATE_TIME = "last_step_update_time"
        
        // Anti-cheat: máximo ~250 pasos por minuto (4.16 pasos/segundo)
        private const val MAX_STEPS_PER_SECOND = 5
        private const val MAX_STEPS_PER_UPDATE = 100 // Para evitar saltos grandes
    }

    private val sensorManager: SensorManager = 
        context.getSystemService(Context.SENSOR_SERVICE) as SensorManager
    
    private val stepSensor: Sensor? = 
        sensorManager.getDefaultSensor(Sensor.TYPE_STEP_COUNTER)
    
    private val prefs: SharedPreferences = 
        context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
    
    private val methodChannel = MethodChannel(
        flutterEngine.dartExecutor.binaryMessenger, 
        "com.stillwalks.app/steps"
    )
    
    private var lastStepCount: Int = 0
    private var sessionSteps: Int = 0
    private var lastUpdateTime: Long = 0
    private var isTracking = false

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
            if (lastStepCount == 0 || totalSteps < lastStepCount) {
                lastStepCount = totalSteps
                lastUpdateTime = System.currentTimeMillis()
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
                lastUpdateTime = System.currentTimeMillis()
                
                Log.d(TAG, "New steps: $newSteps (Total session: $sessionSteps)")
                
                // Guardar periódicamente (cada 50 pasos)
                if (sessionSteps % 50 == 0) {
                    saveState()
                }
                
                // Notificar a Flutter
                onStepsDetected(newSteps, sessionSteps)
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
        
        // Rechazar saltos muy grandes (más de 100 pasos de golpe)
        if (steps > MAX_STEPS_PER_UPDATE) {
            Log.w(TAG, "Step increment too large: $steps")
            return false
        }
        
        // Validar velocidad (pasos por segundo)
        val currentTime = System.currentTimeMillis()
        val timeDelta = (currentTime - lastUpdateTime) / 1000.0 // en segundos
        
        if (timeDelta > 0) {
            val stepsPerSecond = steps / timeDelta
            if (stepsPerSecond > MAX_STEPS_PER_SECOND) {
                Log.w(TAG, "Steps per second too high: $stepsPerSecond")
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
        
        methodChannel.invokeMethod("onStepsUpdated", data)
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
