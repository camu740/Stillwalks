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
        private const val CHANNEL_ID = "stillwalks_tracking"
        private const val NOTIFICATION_ID = 1
        
        const val ACTION_START = "com.stillwalks.app.START"
        const val ACTION_STOP = "com.stillwalks.app.STOP"
    }

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
        Log.d(TAG, "Tracking service created")
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACTION_START -> {
                if (Build.VERSION.SDK_INT >= 34) {
                    startForeground(
                        NOTIFICATION_ID, 
                        createNotification(),
                        android.content.pm.ServiceInfo.FOREGROUND_SERVICE_TYPE_HEALTH
                    )
                } else {
                    startForeground(NOTIFICATION_ID, createNotification())
                }
                Log.d(TAG, "Foreground service started")
            }
            ACTION_STOP -> {
                stopForeground(true)
                stopSelf()
                Log.d(TAG, "Foreground service stopped")
            }
        }
        
        // Si el sistema mata el servicio, reiniciarlo
        return START_STICKY
    }

    override fun onBind(intent: Intent?): IBinder? {
        return null
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "Tracking de Esencia y Pasos",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Mantiene el tracking activo mientras la app está en background"
                setShowBadge(false)
            }

            val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.createNotificationChannel(channel)
        }
    }

    private fun createNotification(): Notification {
        val notificationIntent = Intent(this, MainActivity::class.java)
        val pendingIntent = PendingIntent.getActivity(
            this,
            0,
            notificationIntent,
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
            } else {
                PendingIntent.FLAG_UPDATE_CURRENT
            }
        )

        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("Stillwalks activo")
            .setContentText("Generando Esencia...")
            .setSmallIcon(android.R.drawable.ic_menu_compass) // TODO: Usar icono personalizado
            .setContentIntent(pendingIntent)
            .setOngoing(true)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setCategory(NotificationCompat.CATEGORY_SERVICE)
            .build()
    }

    /**
     * Actualiza el contenido de la notificación (llamado desde ScreenLockTracker)
     */
    fun updateNotification(esencia: Double, rate: Double, steps: Int) {
        val notification = NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("Stillwalks")
            .setContentText("Esencia: ${esencia.toInt()} (+${rate.toInt()}/h) | Pasos: $steps")
            .setSmallIcon(android.R.drawable.ic_menu_compass)
            .setOngoing(true)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .build()

        val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        notificationManager.notify(NOTIFICATION_ID, notification)
    }
}
