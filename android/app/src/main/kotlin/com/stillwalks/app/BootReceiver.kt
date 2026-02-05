package com.stillwalks.app

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import android.util.Log

class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == Intent.ACTION_BOOT_COMPLETED) {
            Log.d("BootReceiver", "Boot completed. Checking if we should restart tracking.")
            
            // Flutter SharedPreferences writes to 'FlutterSharedPreferences' file
            // and prefixes keys with 'flutter.'
            val prefs = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
            val settingsJson = prefs.getString("flutter.notification_settings", null)
            
            if (settingsJson != null) {
                // Check if permanent notification is enabled in the JSON string
                if (settingsJson.contains("\"permanentNotificationEnabled\":true")) {
                    Log.d("BootReceiver", "Restarting tracking service...")
                    val serviceIntent = Intent(context, TrackingForegroundService::class.java).apply {
                        action = TrackingForegroundService.ACTION_START
                    }
                    
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                        context.startForegroundService(serviceIntent)
                    } else {
                        context.startService(serviceIntent)
                    }
                }
            }
        }
    }
}
