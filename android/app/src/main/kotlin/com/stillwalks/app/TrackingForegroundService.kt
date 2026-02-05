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
    }

    private lateinit var notificationManager: StillwalksNotificationManager

    override fun onCreate() {
        super.onCreate()
        notificationManager = StillwalksNotificationManager(this)
        Log.d(TAG, "Tracking service created")
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACTION_START -> {
                val title = notificationManager.getLocalized("trackingServiceTitle", "Stillwalks activo")
                val body = notificationManager.getLocalized("trackingServiceBody", "Generando Esencia...")
                
                val notification = notificationManager.buildForegroundNotification(title, body)
                
                if (Build.VERSION.SDK_INT >= 34) {
                    startForeground(
                        NOTIFICATION_ID, 
                        notification,
                        android.content.pm.ServiceInfo.FOREGROUND_SERVICE_TYPE_HEALTH
                    )
                } else {
                    startForeground(NOTIFICATION_ID, notification)
                }
                Log.d(TAG, "Foreground service started")
            }
            ACTION_STOP -> {
                stopForeground(true)
                stopSelf()
                Log.d(TAG, "Foreground service stopped")
            }
            "com.stillwalks.app.UPDATE_CONTENT" -> {
                val title = intent.getStringExtra("title") ?: "Stillwalks"
                val body = intent.getStringExtra("body") ?: "Generando Esencia..."
                
                val notification = notificationManager.buildForegroundNotification(title, body)
                val nm = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
                nm.notify(NOTIFICATION_ID, notification)
            }
        }
        
        return START_STICKY
    }

    override fun onBind(intent: Intent?): IBinder? {
        return null
    }
}
