package com.stillwalks.app

import android.content.Context
import androidx.work.CoroutineWorker
import androidx.work.WorkerParameters
import android.util.Log

class WalkReminderWorker(
    appContext: Context,
    workerParams: WorkerParameters
) : CoroutineWorker(appContext, workerParams) {

    override suspend fun doWork(): Result {
        Log.d("WalkReminderWorker", "Checking if we should show walk reminder")
        
        // Flutter SharedPreferences writes to 'FlutterSharedPreferences' file
        val prefs = applicationContext.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        val lastActiveMs = prefs.getLong("flutter.last_app_active_timestamp", 0)
        val now = System.currentTimeMillis()
        
        // Suppress if app was active in the last 15 minutes
        if (now - lastActiveMs < 15 * 60 * 1000) {
            Log.d("WalkReminderWorker", "App was active recently. Skipping reminder.")
            return Result.success()
        }
        
        val notificationManager = StillwalksNotificationManager(applicationContext)
        notificationManager.showWalkReminderNotification()
        
        return Result.success()
    }
}
