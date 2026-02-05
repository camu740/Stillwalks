package com.stillwalks.app

import android.app.Notification
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import androidx.core.app.NotificationCompat
import com.stillwalks.app.R

class StillwalksNotificationManager(private val context: Context) {
    
    private val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
    
    init {
        // Create channels on initialization
        NotificationChannels.createNotificationChannels(context)
    }

    internal fun getLocalized(key: String, default: String): String {
        val prefs = context.getSharedPreferences("StillwalksNativePrefs", Context.MODE_PRIVATE)
        return prefs.getString(key, default) ?: default
    }
    
    /**
     * Build the foreground notification for the tracking service
     */
    fun buildForegroundNotification(
        title: String,
        body: String
    ): Notification {
        val intent = Intent(context, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
        }
        val pendingIntent = PendingIntent.getActivity(
            context,
            0,
            intent,
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        )
        
        return NotificationCompat.Builder(context, NotificationChannels.FOREGROUND)
            .setContentTitle(title)
            .setContentText(body)
            .setStyle(NotificationCompat.BigTextStyle().bigText(body))
            .setSmallIcon(R.mipmap.ic_launcher)
            .setOngoing(true)
            .setOnlyAlertOnce(true)
            .setContentIntent(pendingIntent)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .build()
    }
    
    /**
     * Build and show orb ready notification
     */
    fun showOrbReadyNotification(orbType: String) {
        val intent = Intent(context, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
        }
        val pendingIntent = PendingIntent.getActivity(
            context,
            0,
            intent,
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        )
        
        val title = getLocalized("orbReadyTitle", "✨ Orbe Listo")
        val bodyTemplate = getLocalized("orbReadyBody", "Tu {type} ha terminado de canalizar")
        val body = bodyTemplate.replace("{type}", orbType)
        
        val notification = NotificationCompat.Builder(context, NotificationChannels.ORB_READY)
            .setContentTitle(title)
            .setContentText(body)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setAutoCancel(true)
            .setContentIntent(pendingIntent)
            .setPriority(NotificationCompat.PRIORITY_DEFAULT)
            .build()
        
        notificationManager.notify(NotificationChannels.NOTIFICATION_ORB_READY, notification)
    }
    
    /**
     * Build and show walk reminder notification
     */
    fun showWalkReminderNotification() {
        val intent = Intent(context, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
        }
        val pendingIntent = PendingIntent.getActivity(
            context,
            0,
            intent,
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        )
        
        // Random gentle reminder messages
        val messages = listOf(
            getLocalized("walkMsg1", "¿Un paseo tranquilo?"),
            getLocalized("walkMsg2", "Tal vez es buen momento para caminar"),
            getLocalized("walkMsg3", "El aire fresco siempre viene bien"),
            getLocalized("walkMsg4", "¿Qué tal estirar las piernas?")
        )
        val message = messages.random()
        
        val title = getLocalized("walkReminderTitle", "🌿 Momento de Paseo")
        
        val notification = NotificationCompat.Builder(context, NotificationChannels.REMINDERS)
            .setContentTitle(title)
            .setContentText(message)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setAutoCancel(true)
            .setContentIntent(pendingIntent)
            .setPriority(NotificationCompat.PRIORITY_DEFAULT)
            .build()
        
        notificationManager.notify(NotificationChannels.NOTIFICATION_WALK_REMINDER, notification)
    }
    
    /**
     * Build and show essence milestone notification
     */
    fun showMilestoneNotification(essence: Int) {
        val intent = Intent(context, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
        }
        val pendingIntent = PendingIntent.getActivity(
            context,
            0,
            intent,
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        )
        
        val notification = NotificationCompat.Builder(context, NotificationChannels.MILESTONES)
            .setContentTitle("🎊 Hito Alcanzado")
            .setContentText("Has alcanzado $essence de Esencia")
            .setSmallIcon(R.mipmap.ic_launcher)
            .setAutoCancel(true)
            .setContentIntent(pendingIntent)
            .setPriority(NotificationCompat.PRIORITY_DEFAULT)
            .build()
        
        notificationManager.notify(NotificationChannels.NOTIFICATION_MILESTONE, notification)
    }
    
    /**
     * Build and show goal reached notification
     */
    fun showGoalReachedNotification(goal: Int) {
        val intent = Intent(context, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
        }
        val pendingIntent = PendingIntent.getActivity(
            context,
            0,
            intent,
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        )
        
        val title = getLocalized("goalReachedTitle", "Objetivo Cumplido")
        val bodyTemplate = getLocalized("goalReachedBody", "Has alcanzado tu objetivo diario de {goal} pasos")
        val body = bodyTemplate.replace("{goal}", goal.toString())
        
        val notification = NotificationCompat.Builder(context, NotificationChannels.MILESTONES)
            .setContentTitle(title)
            .setContentText(body)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setAutoCancel(true)
            .setContentIntent(pendingIntent)
            .setPriority(NotificationCompat.PRIORITY_DEFAULT)
            .build()
        
        notificationManager.notify(NotificationChannels.NOTIFICATION_GOAL_REACHED, notification)
    }
    fun cancelNotification(notificationId: Int) {
        notificationManager.cancel(notificationId)
    }
    
    /**
     * Cancel all notifications
     */
    fun cancelAllNotifications() {
        notificationManager.cancelAll()
    }
}
