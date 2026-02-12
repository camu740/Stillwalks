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
class ScreenLockTracker private constructor(
    private val context: Context
) {
    companion object {
        private const val TAG = "ScreenLockTracker"
        private const val PREFS_NAME = "stillwalks_prefs"
        private const val KEY_LAST_UNLOCK_TIME = "last_unlock_time"
        private const val KEY_LAST_BOOT_TIME = "last_boot_time"
        private const val KEY_IDLE_MULTIPLIER = "idle_multiplier"
        
        // Constantes de juego
        private const val BASE_ESENCIA_PER_HOUR = 100.0
        private const val MAX_ACCUMULATION_HOURS = 24.0  // Cambiado de 12 a 24
        private const val MILLIS_PER_HOUR = 3600000.0
        
        @Volatile
        private var instance: ScreenLockTracker? = null

        fun getInstance(context: Context): ScreenLockTracker {
            return instance ?: synchronized(this) {
                instance ?: ScreenLockTracker(context.applicationContext).also { instance = it }
            }
        }
    }
    
    private val prefs: SharedPreferences = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
    private var methodChannel: MethodChannel? = null
    
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

    fun attachChannel(messenger: io.flutter.plugin.common.BinaryMessenger) {
        methodChannel = MethodChannel(messenger, "com.stillwalks.app/esencia")
        Log.d(TAG, "MethodChannel attached")
    }

    fun detachChannel() {
        methodChannel = null
        Log.d(TAG, "MethodChannel detached")
    }
    
    private var accumulatedLockedMillis: Long = 0
    private var screenOffTimestamp: Long = 0

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
        accumulatedLockedMillis = prefs.getLong("accumulated_locked_millis", 0)
    }
    
    private fun saveState() {
        prefs.edit().apply {
            putLong(KEY_LAST_UNLOCK_TIME, lastUnlockTime)
            putLong(KEY_LAST_BOOT_TIME, lastBootTime)
            putLong("accumulated_locked_millis", accumulatedLockedMillis)
            apply()
        }
    }
    
    private fun onScreenOff() {
        // Pantalla apagada - comienza sesión de bloqueo
        screenOffTimestamp = System.currentTimeMillis()
        Log.d(TAG, "Screen OFF - Starting lock session at $screenOffTimestamp")
        updateNotification()
    }
    
    private fun onScreenOn() {
        // Pantalla encendida (puede estar en lockscreen)
        // NO detiene la generación (según especificaciones)
        Log.d(TAG, "Screen ON (lockscreen visible)")
    }
    
    private fun onDeviceUnlocked() {
        // Usuario desbloqueó - calculamos duración de la sesión
        val currentTime = System.currentTimeMillis()
        val currentBootTime = SystemClock.elapsedRealtime()
        
        // Si teníamos una sesión activa (screenOffTimestamp > 0)
        if (screenOffTimestamp > 0) {
            val sessionDuration = currentTime - screenOffTimestamp
            if (sessionDuration > 0) {
                accumulatedLockedMillis += sessionDuration
                Log.d(TAG, "Lock session ended. Duration: ${sessionDuration}ms. Total accumulated: ${accumulatedLockedMillis}ms")
            }
            screenOffTimestamp = 0 // Reset sesión actual
        }

        // Anti-cheat: verificar manipulación de hora del sistema
        if (!isTimeValid(currentTime, currentBootTime)) {
            Log.w(TAG, "Time manipulation detected! Resetting timestamps without accumulation")
            // Actualizar referencias sin acumular tiempo
            lastUnlockTime = currentTime
            lastBootTime = currentBootTime
            saveState()
            return
        }
        
        Log.d(TAG, "Device UNLOCKED - Tracking time only (essence generation handled by Flutter)")
        
        // Actualizar timestamps (Flutter consultará el tiempo acumulado)
        lastUnlockTime = currentTime
        lastBootTime = currentBootTime
        saveState()
        
        updateNotification()
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
     * DEPRECATED: Flutter ahora maneja el cálculo
     */
    fun onAppOpened() {
        Log.d(TAG, "App opened - Flutter will handle essence calculation")
    }
    
    /**
     * Obtiene el tiempo acumulado con el móvil bloqueado (en minutos)
     * Para que Flutter lo combine con tiempo activo en app
     */
    fun getAccumulatedLockedMinutes(): Int {
        // Devolvemos lo acumulado en sesiones cerradas + la sesión actual si está bloqueado
        var totalMillis = accumulatedLockedMillis
        
        if (screenOffTimestamp > 0) {
            // Actualmente bloqueado, sumar tiempo transcurrido
            totalMillis += (System.currentTimeMillis() - screenOffTimestamp)
        }
        
        val elapsedMinutes = (totalMillis / 60000).toInt()
        
        Log.d(TAG, "Accumulated locked time requested: $elapsedMinutes minutes ($totalMillis ms)")
        return elapsedMinutes
    }
    
    /**
     * Resetea el contador de tiempo bloqueado
     * Llamar después de que Flutter haya procesado la esencia
     */
    fun resetAccumulatedTime() {
        accumulatedLockedMillis = 0
        // Si estamos bloqueados, reiniciamos el timestamp de inicio de sesión actual para no contar doble
        if (screenOffTimestamp > 0) {
            screenOffTimestamp = System.currentTimeMillis()
        }
        lastUnlockTime = System.currentTimeMillis()
        lastBootTime = SystemClock.elapsedRealtime()
        saveState()
        Log.d(TAG, "Accumulated locked time reset")
    }
    
    /**
     * Actualiza el multiplicador de idle (cuando se compra una mejora)
     */
    fun updateIdleMultiplier(multiplier: Double) {
        prefs.edit().putFloat(KEY_IDLE_MULTIPLIER, multiplier.toFloat()).apply()
        Log.d(TAG, "Idle multiplier updated to $multiplier")
    }
    
    /**
     * Calcula la Esencia pendiente (generada pero no reclamada)
     * NOTA: Este método se mantiene para compatibilidad pero Flutter
     * manejará la generación real de esencia
     */
    fun getPendingEsencia(): Double {
        val currentTime = System.currentTimeMillis()
        val elapsedMillis = currentTime - lastUnlockTime
        val elapsedHours = elapsedMillis / MILLIS_PER_HOUR
        
        if (elapsedHours <= 0) return 0.0
        
        val cappedHours = min(elapsedHours, MAX_ACCUMULATION_HOURS)  // 24h
        val idleMultiplier = prefs.getFloat(KEY_IDLE_MULTIPLIER, 1.0f).toDouble()
        val esenciaPerHour = BASE_ESENCIA_PER_HOUR * idleMultiplier
        
        return esenciaPerHour * cappedHours
    }

    private fun updateNotification() {
        // Trigger notification update in TrackingForegroundService
        val intent = Intent(context, TrackingForegroundService::class.java).apply {
            action = TrackingForegroundService.ACTION_UPDATE_NOTIFICATION
        }
        context.startService(intent)
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
        
        methodChannel?.invokeMethod("onEsenciaGenerated", data)
    }
}
