package com.stillwalks.app

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.SharedPreferences
import android.os.SystemClock
import android.util.Log
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import kotlin.math.min

/**
 * Rastrea cuándo el dispositivo está bloqueado vs. desbloqueado
 * y calcula la Esencia generada pasivamente.
 */
class ScreenLockTracker(
    private val context: Context,
    private val flutterEngine: FlutterEngine
) {
    companion object {
        private const val TAG = "ScreenLockTracker"
        private const val PREFS_NAME = "stillwalks_prefs"
        private const val KEY_LAST_UNLOCK_TIME = "last_unlock_time"
        private const val KEY_LAST_BOOT_TIME = "last_boot_time"
        private const val KEY_IDLE_MULTIPLIER = "idle_multiplier"
        
        // Constantes de juego
        private const val BASE_ESENCIA_PER_HOUR = 100.0
        private const val MAX_ACCUMULATION_HOURS = 12.0
        private const val MILLIS_PER_HOUR = 3600000.0
    }
    
    private val prefs: SharedPreferences = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
    private val methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.stillwalks.app/esencia")
    
    private var isTracking = false
    private var lastUnlockTime: Long = 0
    private var lastBootTime: Long = 0
    
    private val screenReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            when (intent.action) {
                Intent.ACTION_SCREEN_OFF -> onScreenOff()
                Intent.ACTION_SCREEN_ON -> onScreenOn()
                Intent.ACTION_USER_PRESENT -> onDeviceUnlocked()
            }
        }
    }
    
    fun start() {
        if (isTracking) return
        
        val filter = IntentFilter().apply {
            addAction(Intent.ACTION_SCREEN_OFF)
            addAction(Intent.ACTION_SCREEN_ON)
            addAction(Intent.ACTION_USER_PRESENT)
        }
        context.registerReceiver(screenReceiver, filter)
        isTracking = true
        
        // Cargar estado guardado
        loadState()
        
        Log.d(TAG, "ScreenLockTracker started")
    }
    
    fun stop() {
        if (!isTracking) return
        
        try {
            context.unregisterReceiver(screenReceiver)
        } catch (e: Exception) {
            Log.e(TAG, "Error unregistering receiver", e)
        }
        isTracking = false
        
        Log.d(TAG, "ScreenLockTracker stopped")
    }
    
    private fun loadState() {
        lastUnlockTime = prefs.getLong(KEY_LAST_UNLOCK_TIME, System.currentTimeMillis())
        lastBootTime = prefs.getLong(KEY_LAST_BOOT_TIME, SystemClock.elapsedRealtime())
    }
    
    private fun saveState() {
        prefs.edit().apply {
            putLong(KEY_LAST_UNLOCK_TIME, lastUnlockTime)
            putLong(KEY_LAST_BOOT_TIME, lastBootTime)
            apply()
        }
    }
    
    private fun onScreenOff() {
        // Pantalla apagada - comienza generación de Esencia
        Log.d(TAG, "Screen OFF - Starting Esencia generation")
    }
    
    private fun onScreenOn() {
        // Pantalla encendida (puede estar en lockscreen)
        // NO detiene la generación (según especificaciones)
        Log.d(TAG, "Screen ON (lockscreen visible)")
    }
    
    private fun onDeviceUnlocked() {
        // Usuario desbloqueó - calculamos Esencia generada
        val currentTime = System.currentTimeMillis()
        val currentBootTime = SystemClock.elapsedRealtime()
        
        // Anti-cheat: verificar manipulación de hora del sistema
        if (!isTimeValid(currentTime, currentBootTime)) {
            Log.w(TAG, "Time manipulation detected! Skipping Esencia generation")
            // Actualizar referencias sin dar Esencia
            lastUnlockTime = currentTime
            lastBootTime = currentBootTime
            saveState()
            return
        }
        
        // Calcular tiempo transcurrido
        val elapsedMillis = currentTime - lastUnlockTime
        val elapsedHours = elapsedMillis / MILLIS_PER_HOUR
        
        // Aplicar límite de 12 horas
        val cappedHours = min(elapsedHours, MAX_ACCUMULATION_HOURS)
        
        if (cappedHours > 0) {
            // Calcular Esencia generada
            val idleMultiplier = prefs.getFloat(KEY_IDLE_MULTIPLIER, 1.0f).toDouble()
            val esenciaPerHour = BASE_ESENCIA_PER_HOUR * idleMultiplier
            val esenciaGenerated = esenciaPerHour * cappedHours
            
            Log.d(TAG, "Device UNLOCKED - Generated $esenciaGenerated Esencia (${cappedHours}h)")
            
            // Notificar a Flutter
            notifyFlutter(esenciaGenerated, cappedHours)
        } else {
            Log.d(TAG, "Device UNLOCKED - No time elapsed")
        }
        
        // Actualizar timestamps
        lastUnlockTime = currentTime
        lastBootTime = currentBootTime
        saveState()
    }
    
    /**
     * Valida que el tiempo del sistema no haya sido manipulado
     * Compara el boot time actual con el guardado
     */
    private fun isTimeValid(currentTime: Long, currentBootTime: Long): Boolean {
        // Si el boot time es menor que el guardado, el dispositivo se reinició
        // Esto es válido
        if (currentBootTime < lastBootTime) {
            Log.d(TAG, "Device rebooted detected (valid)")
            return true
        }
        
        // Calcular cuánto tiempo ha pasado según el bootTime (no manipulable)
        val bootTimeDelta = currentBootTime - lastBootTime
        
        // Calcular cuánto tiempo ha pasado según el system time (manipulable)
        val systemTimeDelta = currentTime - lastUnlockTime
        
        // Si la diferencia es mayor a 5 minutos, probablemente hubo manipulación
        val discrepancy = kotlin.math.abs(systemTimeDelta - bootTimeDelta)
        val maxAllowedDiscrepancy = 5 * 60 * 1000 // 5 minutos
        
        if (discrepancy > maxAllowedDiscrepancy) {
            Log.w(TAG, "Time discrepancy detected: ${discrepancy}ms")
            return false
        }
        
        return true
    }
    
    /**
     * Llamado cuando la app se abre (para recalcular inmediatamente)
     */
    fun onAppOpened() {
        // Simular desbloqueo para recalcular
        onDeviceUnlocked()
    }
    
    /**
     * Actualiza el multiplicador de idle (cuando se compra una mejora)
     */
    fun updateIdleMultiplier(multiplier: Double) {
        prefs.edit().putFloat(KEY_IDLE_MULTIPLIER, multiplier.toFloat()).apply()
        Log.d(TAG, "Idle multiplier updated to $multiplier")
    }
    
    /**
     * Notifica a Flutter sobre la Esencia generada
     */
    private fun notifyFlutter(esenciaGenerated: Double, hoursElapsed: Double) {
        val data = mapOf(
            "esencia" to esenciaGenerated,
            "hours" to hoursElapsed,
            "timestamp" to System.currentTimeMillis()
        )
        
        methodChannel.invokeMethod("onEsenciaGenerated", data)
    }
}
