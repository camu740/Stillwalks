package com.stillwalks.app

import android.app.*
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.IBinder
import androidx.core.app.NotificationCompat
import android.util.Log

/**
 * Servicio foreground para tracking continuo de esencia y pasos
 * Requerido para que Android permita background tracking en Android 8+
 */
class TrackingForegroundService : Service() {

    companion object {
        private const val TAG = "TrackingService"
        private const val NOTIFICATION_ID = NotificationChannels.NOTIFICATION_FOREGROUND
        
        const val ACTION_START = "com.stillwalks.app.START"
        const val ACTION_STOP = "com.stillwalks.app.STOP"
        const val ACTION_UPDATE_NOTIFICATION = "com.stillwalks.app.UPDATE_NOTIFICATION"
    }

    private lateinit var notificationManager: StillwalksNotificationManager

    override fun onCreate() {
        super.onCreate()
        notificationManager = StillwalksNotificationManager(this)
        
        // Ensure step counter is running as long as the service is alive
        StepCounterService.getInstance(this).start()
        
        // Ensure screen tracker is running (for passive essence)
        ScreenLockTracker.getInstance(this).start()
        
        Log.d(TAG, "Tracking service created")
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACTION_START -> {
                updateNotification()
                Log.d(TAG, "Foreground service started")
            }
            ACTION_STOP -> {
                stopForeground(true)
                stopSelf()
                Log.d(TAG, "Foreground service stopped")
            }
            "com.stillwalks.app.UPDATE_CONTENT" -> {
                // Manual override
                val title = intent.getStringExtra("title") ?: "Stillwalks"
                val body = intent.getStringExtra("body") ?: "Generando Esencia..."
                
                val notification = notificationManager.buildForegroundNotification(title, body)
                val nm = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
                nm.notify(NOTIFICATION_ID, notification)
            }
            ACTION_UPDATE_NOTIFICATION -> {
                updateNotification()
            }
        }
        
        return START_STICKY
    }

    private fun updateNotification() {
        // Read synced essence (base)
        val prefs = getSharedPreferences("StillwalksNativePrefs", Context.MODE_PRIVATE)
        val totalEsencia = prefs.getFloat("total_essence", 0.0f).toDouble()
        
        // Add pending essence from ScreenLockTracker
        val pendingEsencia = ScreenLockTracker.getInstance(this).getPendingEsencia()
        val finalEsencia = totalEsencia + pendingEsencia
        
        // Get step count
        val steps = StepCounterService.getInstance(this).getSessionSteps()
        
        val title = notificationManager.getLocalized("trackingServiceTitle", "Stillwalks activo")
        
        // Format body
        // Default fallback if localization missing
        val bodyFormat = "Esencia: %.0f | Pasos: %d" 
        // In a real scenario, we should have synced this format string too
        
        val body = String.format(java.util.Locale.getDefault(), "Esencia: %.0f | Pasos: %d", finalEsencia, steps)
        
        val notification = notificationManager.buildForegroundNotification(title, body)
        
        if (Build.VERSION.SDK_INT >= 34) {
            // Service type required for Android 14+
            try {
               startForeground(
                   NOTIFICATION_ID, 
                   notification,
                   android.content.pm.ServiceInfo.FOREGROUND_SERVICE_TYPE_HEALTH
               )
            } catch (e: Exception) {
                // Should not happen if permission granted
                Log.e(TAG, "Error starting foreground service", e)
                val nm = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
                nm.notify(NOTIFICATION_ID, notification)
            }
        } else {
            startForeground(NOTIFICATION_ID, notification)
        }
    }

    override fun onBind(intent: Intent?): IBinder? {
        return null
    }
}
