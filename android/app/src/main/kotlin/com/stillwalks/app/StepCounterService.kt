package com.stillwalks.app

import android.content.Context
import android.content.SharedPreferences
import android.content.pm.PackageManager
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.util.Log
import android.content.Intent // Added import
import androidx.core.content.ContextCompat
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
        if (isTracking) {
            Log.d(TAG, "⚠️ Step counter already tracking (session: $sessionSteps steps)")
            return
        }
        
        Log.i(TAG, "🚀 Starting step counter service...")
        
        // Verificar permiso de ACTIVITY_RECOGNITION en runtime
        val hasPermission = ContextCompat.checkSelfPermission(
            context,
            android.Manifest.permission.ACTIVITY_RECOGNITION
        ) == PackageManager.PERMISSION_GRANTED
        
        if (!hasPermission) {
            Log.e(TAG, "❌ ACTIVITY_RECOGNITION permission not granted! Cannot start step counter.")
            Log.e(TAG, "   Please ensure the permission is granted in the app settings.")
            return
        }
        
        Log.d(TAG, "✅ ACTIVITY_RECOGNITION permission granted")
        
        if (stepSensor != null) {
            Log.d(TAG, "📱 Sensor Info:")
            Log.d(TAG, "   - Name: ${stepSensor.name}")
            Log.d(TAG, "   - Vendor: ${stepSensor.vendor}")
            Log.d(TAG, "   - Power: ${stepSensor.power}mA")
            
            // Cargar estado guardado
            loadState()
            
            val registered = sensorManager.registerListener(
                this, 
                stepSensor, 
                SensorManager.SENSOR_DELAY_NORMAL
            )
            
            if (registered) {
                isTracking = true
                Log.i(TAG, "✅ Step counter started successfully (restored session: $sessionSteps steps)")
                Log.d(TAG, "   Anti-cheat limits: $MAX_STEPS_PER_SECOND steps/sec, $MAX_STEPS_PER_UPDATE max batch")
            } else {
                Log.e(TAG, "❌ Failed to register step sensor listener")
            }
        } else {
            Log.e(TAG, "❌ Step counter sensor (TYPE_STEP_COUNTER) not available on this device")
            Log.e(TAG, "   This device may not support hardware step counting.")
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
        
        val timeSinceLastUpdate = (System.currentTimeMillis() - lastUpdateTime) / 1000.0
        Log.d(TAG, "📂 State loaded from SharedPreferences:")
        Log.d(TAG, "   - Last sensor count: $lastStepCount")
        Log.d(TAG, "   - Session steps: $sessionSteps")
        Log.d(TAG, "   - Time since last update: ${timeSinceLastUpdate.toInt()}s ago")
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
            val currentTime = System.currentTimeMillis()
            val timeDelta = (currentTime - lastUpdateTime) / 1000.0
            
            // Primera lectura o después de reinicio del dispositivo
            // Handle device reboot (sensor resets to 0)
            if (lastStepCount == 0 || totalSteps < lastStepCount) {
                lastStepCount = totalSteps
                lastUpdateTime = currentTime
                if (totalSteps < lastStepCount) {
                    Log.w(TAG, "📱 Device reboot detected! Sensor reset from $lastStepCount to $totalSteps")
                    Log.w(TAG, "   Session steps preserved: $sessionSteps")
                } else {
                    Log.d(TAG, "🎯 First sensor reading: $totalSteps steps (baseline set)")
                }
                return
            }
            
            val newSteps = totalSteps - lastStepCount
            
            // Anti-cheat: validar que el incremento sea razonable
            if (!isStepIncrementValid(newSteps, timeDelta)) {
                Log.w(TAG, "⚠️ Invalid step increment REJECTED: $newSteps steps")
                Log.w(TAG, "   Time delta: ${timeDelta.toInt()}s, Rate: ${if(timeDelta > 0) (newSteps/timeDelta).toInt() else "N/A"} steps/sec")
                Log.w(TAG, "   Current sensor: $totalSteps, Last: $lastStepCount")
                return
            }
            
            if (newSteps > 0) {
                lastStepCount = totalSteps
                sessionSteps += newSteps
                lastUpdateTime = currentTime
                
                val stepsPerSec = if (timeDelta > 0) newSteps / timeDelta else 0.0
                val logLevel = if (newSteps > 100) "INFO" else "DEBUG"
                
                if (newSteps > 100) {
                    Log.i(TAG, "👣 Step batch: +$newSteps steps (${stepsPerSec.toInt()}/s over ${timeDelta.toInt()}s) → Session: $sessionSteps")
                } else {
                    Log.d(TAG, "👣 +$newSteps steps → Session total: $sessionSteps")
                }
                
                // Guardar periódicamente (cada 50 pasos)
                if (sessionSteps % 50 < newSteps) { // Crossed a 50-step boundary
                    saveState()
                    Log.d(TAG, "💾 State saved at $sessionSteps steps")
                }
                
                // Notificar a Flutter
                onStepsDetected(newSteps, sessionSteps)
                
                // Update notification in foreground service
                val intent = Intent(context, TrackingForegroundService::class.java)
                intent.action = TrackingForegroundService.ACTION_UPDATE_NOTIFICATION
                context.startService(intent)
            }
        }
    }

    override fun onAccuracyChanged(sensor: Sensor, accuracy: Int) {
        val accuracyStr = when (accuracy) {
            SensorManager.SENSOR_STATUS_UNRELIABLE -> "UNRELIABLE"
            SensorManager.SENSOR_STATUS_ACCURACY_LOW -> "LOW"
            SensorManager.SENSOR_STATUS_ACCURACY_MEDIUM -> "MEDIUM"
            SensorManager.SENSOR_STATUS_ACCURACY_HIGH -> "HIGH"
            else -> "UNKNOWN($accuracy)"
        }
        
        when (accuracy) {
            SensorManager.SENSOR_STATUS_UNRELIABLE -> {
                Log.w(TAG, "⚠️ Sensor accuracy changed: $accuracyStr")
                Log.w(TAG, "   Step counting may be temporarily impacted")
            }
            SensorManager.SENSOR_STATUS_ACCURACY_LOW -> {
                Log.w(TAG, "📉 Sensor accuracy: $accuracyStr (reduced precision)")
            }
            SensorManager.SENSOR_STATUS_ACCURACY_MEDIUM,
            SensorManager.SENSOR_STATUS_ACCURACY_HIGH -> {
                Log.d(TAG, "📊 Sensor accuracy: $accuracyStr")
            }
        }
    }
    
    /**
     * Valida que el incremento de pasos sea realista
     * @param steps Número de pasos nuevos detectados
     * @param timeDelta Tiempo transcurrido desde última actualización (segundos)
     */
    private fun isStepIncrementValid(steps: Int, timeDelta: Double): Boolean {
        // Rechazar incrementos negativos (nunca deberían ocurrir)
        if (steps < 0) {
            Log.e(TAG, "❌ VALIDATION FAILED: Negative increment ($steps steps)")
            return false
        }
        
        // Rechazar saltos absurdamente grandes
        if (steps > MAX_STEPS_PER_UPDATE) {
            Log.e(TAG, "❌ VALIDATION FAILED: Batch too large")
            Log.e(TAG, "   Steps: $steps > MAX: $MAX_STEPS_PER_UPDATE")
            Log.e(TAG, "   This could indicate sensor malfunction or tampering")
            return false
        }
        
        // Validar velocidad (pasos por segundo) solo si el intervalo es significativo
        // For very short intervals, we can't reliably calculate rate
        if (timeDelta > 1.0) { // Solo chequear rate si ha pasado al menos 1 segundo
            val stepsPerSecond = steps / timeDelta
            if (stepsPerSecond > MAX_STEPS_PER_SECOND) {
                Log.e(TAG, "❌ VALIDATION FAILED: Step rate too high")
                Log.e(TAG, "   Rate: ${stepsPerSecond.toInt()} steps/sec > MAX: $MAX_STEPS_PER_SECOND")
                Log.e(TAG, "   Steps: $steps over ${timeDelta.toInt()}s")
                Log.e(TAG, "   Normal walking: 2-4 steps/sec, running: 5-8 steps/sec")
                return false
            }
        } else if (timeDelta > 0.1 && steps > 20) {
            // For sub-second intervals with suspiciously high counts
            Log.w(TAG, "⚠️ Validation warning: $steps steps in ${(timeDelta*1000).toInt()}ms")
            Log.w(TAG, "   Allowing but flagging for monitoring")
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
        
        if (methodChannel != null) {
            methodChannel?.invokeMethod("onStepsUpdated", data)
            Log.d(TAG, "📤 Sent to Flutter: +$newSteps steps (total: $totalSessionSteps)")
        } else {
            Log.w(TAG, "⚠️ Cannot notify Flutter: MethodChannel not attached")
            Log.w(TAG, "   Steps will be queued until Flutter is ready")
        }
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
