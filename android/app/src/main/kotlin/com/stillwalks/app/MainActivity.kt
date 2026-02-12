package com.stillwalks.app

import android.content.Intent
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import androidx.work.PeriodicWorkRequestBuilder
import androidx.work.WorkManager
import androidx.work.ExistingPeriodicWorkPolicy
import java.util.concurrent.TimeUnit

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.stillwalks.app/native"
    private lateinit var screenLockTracker: ScreenLockTracker
    private lateinit var stepCounter: StepCounterService
    private lateinit var notificationManager: StillwalksNotificationManager
    
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Inicializar servicios (Singleton for StepCounter and ScreenLockTracker)
        screenLockTracker = ScreenLockTracker.getInstance(this)
        screenLockTracker.attachChannel(flutterEngine.dartExecutor.binaryMessenger)
        
        stepCounter = StepCounterService.getInstance(this)
        stepCounter.attachChannel(flutterEngine.dartExecutor.binaryMessenger)
        
        notificationManager = StillwalksNotificationManager(this)
        
        // Crear MethodChannel para comunicación con Flutter
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "startTracking" -> {
                    startBackgroundServices()
                    result.success("Tracking started")
                }
                "stopTracking" -> {
                    stopBackgroundServices()
                    result.success("Tracking stopped")
                }
                "getAccumulatedLockedMinutes" -> {
                    val minutes = screenLockTracker.getAccumulatedLockedMinutes()
                    result.success(minutes)
                }
                "resetAccumulatedTime" -> {
                    screenLockTracker.resetAccumulatedTime()
                    result.success(true)
                }
                "updateIdleMultiplier" -> {
                    val multiplier = call.argument<Double>("multiplier") ?: 1.0
                    screenLockTracker.updateIdleMultiplier(multiplier)
                    result.success(true)
                }
                "getEsencia" -> {
                    // TODO: Obtener Esencia pendiente desde BD (or SharedPrefs if synced)
                    result.success(0.0)
                }
                "syncEsencia" -> {
                    val amount = call.argument<Double>("amount") ?: 0.0
                    val prefs = getSharedPreferences("StillwalksNativePrefs", android.content.Context.MODE_PRIVATE)
                    prefs.edit().putFloat("total_essence", amount.toFloat()).apply()
                    
                    // Trigger notification update
                    val serviceIntent = Intent(context, TrackingForegroundService::class.java).apply {
                        action = TrackingForegroundService.ACTION_UPDATE_NOTIFICATION
                    }
                    startService(serviceIntent)
                    
                    result.success(true)
                }
                "getSteps" -> {
                    val steps = stepCounter.getSessionSteps()
                    result.success(steps)
                }
                "updateNotificationContent" -> {
                    // This serves as a manual override from Flutter if needed, 
                    // but syncEsencia is preferred for state.
                    val title = call.argument<String>("title")
                    val body = call.argument<String>("body")
                    
                    val serviceIntent = Intent(context, TrackingForegroundService::class.java).apply {
                        action = "com.stillwalks.app.UPDATE_CONTENT"
                        putExtra("title", title)
                        putExtra("body", body)
                    }
                    startService(serviceIntent)
                    result.success(true)
                }
                "showOrbReadyNotification" -> {
                    val orbType = call.argument<String>("orbType") ?: "Orbe"
                    notificationManager.showOrbReadyNotification(orbType)
                    result.success(true)
                }
                "showWalkReminderNotification" -> {
                    notificationManager.showWalkReminderNotification()
                    result.success(true)
                }
                "showMilestoneNotification" -> {
                    val essence = call.argument<Int>("essence") ?: 0
                    notificationManager.showMilestoneNotification(essence)
                    result.success(true)
                }
                "showGoalReachedNotification" -> {
                    val goal = call.argument<Int>("goal") ?: 5000
                    notificationManager.showGoalReachedNotification(goal)
                    result.success(true)
                }
                "updateWalkReminder" -> {
                    val enabled = call.argument<Boolean>("enabled") ?: false
                    val preset = call.argument<String>("preset") ?: "none"
                    updateWalkReminderSchedule(enabled, preset)
                    result.success(true)
                }
                "pauseTracking" -> {
                    // Stop tracking service but don't reset state
                    val serviceIntent = Intent(this, TrackingForegroundService::class.java)
                    serviceIntent.action = "PAUSE"
                    stopService(serviceIntent)
                    result.success("Tracking paused")
                }
                "resumeTracking" -> {
                    // Resume tracking service
                    val serviceIntent = Intent(this, TrackingForegroundService::class.java)
                    serviceIntent.action = "RESUME"
                    startService(serviceIntent)
                    result.success("Tracking resumed")
                }
                "syncLocalization" -> {
                    val prefs = context.getSharedPreferences("StillwalksNativePrefs", android.content.Context.MODE_PRIVATE)
                    val editor = prefs.edit()
                    val args = call.arguments as Map<String, String>
                    args.forEach { (key, value) ->
                        editor.putString(key, value)
                    }
                    editor.apply()
                    result.success(true)
                }
                "getLastSyncedFlutterSteps" -> {
                    val prefs = context.getSharedPreferences("StillwalksNativePrefs", android.content.Context.MODE_PRIVATE)
                    val steps = prefs.getLong("last_synced_flutter_steps", 0L)
                    result.success(steps)
                }
                "setLastSyncedFlutterSteps" -> {
                    val steps = (call.arguments as? Number)?.toLong() ?: 0L
                    val prefs = context.getSharedPreferences("StillwalksNativePrefs", android.content.Context.MODE_PRIVATE)
                    prefs.edit().putLong("last_synced_flutter_steps", steps).apply()
                    result.success(true)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
    
    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        super.cleanUpFlutterEngine(flutterEngine)
        stepCounter.detachChannel()
        screenLockTracker.detachChannel()
    }
    
    override fun onResume() {
        super.onResume()
        // Notificar que el usuario está activo
        screenLockTracker.onAppOpened()
    }
    
    private fun startBackgroundServices() {
        // Verificar permisos antes de iniciar servicios
        val hasPermission = androidx.core.content.ContextCompat.checkSelfPermission(
            this,
            android.Manifest.permission.ACTIVITY_RECOGNITION
        ) == android.content.pm.PackageManager.PERMISSION_GRANTED
        
        if (!hasPermission) {
            android.util.Log.e("MainActivity", "❌ Cannot start services: ACTIVITY_RECOGNITION permission not granted")
            return
        }
        
        android.util.Log.d("MainActivity", "✅ Starting background services with ACTIVITY_RECOGNITION permission")
        
        // Iniciar servicio foreground para tracking
        val serviceIntent = Intent(this, TrackingForegroundService::class.java).apply {
            action = TrackingForegroundService.ACTION_START
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            startForegroundService(serviceIntent)
        } else {
            startService(serviceIntent)
        }
        
        // Iniciar tracking
        screenLockTracker.start()
        stepCounter.start()
        
        android.util.Log.d("MainActivity", "📱 Background services started")
    }
    
    private fun stopBackgroundServices() {
        screenLockTracker.stop()
        stepCounter.stop()
        
        val serviceIntent = Intent(this, TrackingForegroundService::class.java)
        stopService(serviceIntent)
    }

    private fun updateWalkReminderSchedule(enabled: Boolean, preset: String) {
        val workManager = WorkManager.getInstance(this)
        val workName = "stillwalks_walk_reminder"
        
        if (!enabled || preset == "none") {
            workManager.cancelUniqueWork(workName)
            return
        }
        
        val intervalHours = when (preset) {
            "soft" -> 3L
            "normal" -> 2L
            else -> 3L
        }
        
        val walkReminderRequest = PeriodicWorkRequestBuilder<WalkReminderWorker>(
            intervalHours, TimeUnit.HOURS
        ).build()
        
        workManager.enqueueUniquePeriodicWork(
            workName,
            ExistingPeriodicWorkPolicy.UPDATE,
            walkReminderRequest
        )
    }
}
