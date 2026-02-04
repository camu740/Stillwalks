package com.stillwalks.app

import android.content.Intent
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.stillwalks.app/native"
    private lateinit var screenLockTracker: ScreenLockTracker
    private lateinit var stepCounter: StepCounterService
    
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
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
                "getEsencia" -> {
                    // TODO: Obtener Esencia pendiente desde BD
                    result.success(0.0)
                }
                "getSteps" -> {
                    val steps = stepCounter.getSessionSteps()
                    result.success(steps)
                }
                "updateNotificationContent" -> {
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
                else -> {
                    result.notImplemented()
                }
            }
        }
        
        // Inicializar servicios
        screenLockTracker = ScreenLockTracker(this, flutterEngine)
        stepCounter = StepCounterService(this, flutterEngine)
    }
    
    override fun onResume() {
        super.onResume()
        // Notificar que el usuario está activo
        screenLockTracker.onAppOpened()
    }
    
    private fun startBackgroundServices() {
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
    }
    
    private fun stopBackgroundServices() {
        screenLockTracker.stop()
        stepCounter.stop()
        
        val serviceIntent = Intent(this, TrackingForegroundService::class.java)
        stopService(serviceIntent)
    }
}
