package com.stillwalks.app

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.os.Build

object NotificationChannels {
    // Channel IDs
    const val FOREGROUND = "stillwalks_foreground"
    const val ORB_READY = "stillwalks_orb_ready"
    const val REMINDERS = "stillwalks_reminders"
    const val MILESTONES = "stillwalks_milestones"
    
    // Notification IDs
    const val NOTIFICATION_FOREGROUND = 1
    const val NOTIFICATION_ORB_READY = 2
    const val NOTIFICATION_WALK_REMINDER = 3
    const val NOTIFICATION_MILESTONE = 4
    const val NOTIFICATION_GOAL_REACHED = 5
    
    fun createNotificationChannels(context: Context) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            
            // Foreground Service Channel (Low priority - always visible but not intrusive)
            val foregroundChannel = NotificationChannel(
                FOREGROUND,
                "Progreso Activo",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Muestra tu progreso mientras caminas"
                setShowBadge(false)
            }
            
            // Orb Ready Channel (Default priority - important but not urgent)
            val orbReadyChannel = NotificationChannel(
                ORB_READY,
                "Orbe Listo",
                NotificationManager.IMPORTANCE_DEFAULT
            ).apply {
                description = "Te avisamos cuando un orbe termina de canalizar"
                setShowBadge(true)
            }
            
            // Reminders Channel (Default priority - gentle nudges)
            val remindersChannel = NotificationChannel(
                REMINDERS,
                "Recordatorios",
                NotificationManager.IMPORTANCE_DEFAULT
            ).apply {
                description = "Recordatorios suaves para caminar"
                setShowBadge(false)
            }
            
            // Milestones Channel (Default priority - celebratory)
            val milestonesChannel = NotificationChannel(
                MILESTONES,
                "Hitos y Logros",
                NotificationManager.IMPORTANCE_DEFAULT
            ).apply {
                description = "Notificaciones cuando alcanzas hitos importantes"
                setShowBadge(true)
            }
            
            // Register all channels
            notificationManager.createNotificationChannels(
                listOf(
                    foregroundChannel,
                    orbReadyChannel,
                    remindersChannel,
                    milestonesChannel
                )
            )
        }
    }
}
