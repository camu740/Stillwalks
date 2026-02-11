package com.stillwalks.app

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import androidx.core.content.ContextCompat
import android.util.Log

class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == Intent.ACTION_BOOT_COMPLETED) {
            Log.d("BootReceiver", "📱 Boot completed. Checking if we should restart tracking.")
            
            // Verificar permiso de ACTIVITY_RECOGNITION
            val hasPermission = ContextCompat.checkSelfPermission(
                context,
                android.Manifest.permission.ACTIVITY_RECOGNITION
            ) == PackageManager.PERMISSION_GRANTED
            
            if (!hasPermission) {
                Log.e("BootReceiver", "❌ ACTIVITY_RECOGNITION permission not granted. Cannot restart tracking.")
                return
            }
            
            Log.d("BootReceiver", "✅ ACTIVITY_RECOGNITION permission granted")
            
            // Flutter SharedPreferences writes to 'FlutterSharedPreferences' file
            // and prefixes keys with 'flutter.'
            val prefs = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
            val settingsJson = prefs.getString("flutter.notification_settings", null)
            
            if (settingsJson != null) {
                // Check if permanent notification is enabled in the JSON string
                if (settingsJson.contains("\"permanentNotificationEnabled\":true")) {
                    Log.d("BootReceiver", "🚀 Restarting tracking service...")
                    val serviceIntent = Intent(context, TrackingForegroundService::class.java).apply {
                        action = TrackingForegroundService.ACTION_START
                    }
                    
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                        context.startForegroundService(serviceIntent)
                    } else {
                        context.startService(serviceIntent)
                    }
                    
                    Log.d("BootReceiver", "✅ Tracking service restarted successfully")
                } else {
                    Log.d("BootReceiver", "ℹ️ Permanent notification disabled. Not restarting service.")
                }
            } else {
                Log.d("BootReceiver", "ℹ️ No notification settings found. Not restarting service.")
            }
        }
    }
}
