import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stillwalks/models/notification_settings.dart';
import 'package:stillwalks/services/native_bridge.dart';
import 'package:stillwalks/data/database/database_helper.dart';

/// Servicio centralizado para gestionar preferencias de notificaciones
class NotificationPreferencesService extends ChangeNotifier {
  static const String _storageKey = 'notification_settings';
  
  StillwalksSettings _settings = const StillwalksSettings();
  NativeBridge? _nativeBridge;
  
  StillwalksSettings get settings => _settings;
  
  /// Inyecta el bridge nativo para sincronizar configuraciones
  void setNativeBridge(NativeBridge bridge) {
    _nativeBridge = bridge;
    // Sincronizar recordatorios al iniciar
    if (_settings.walkReminderEnabled) {
      _nativeBridge?.updateWalkReminder(true, _settings.walkReminderPreset);
    }
  }
  
  /// Inicializa el servicio cargando las configuraciones guardadas
  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);
      
      if (jsonString != null) {
        final json = jsonDecode(jsonString) as Map<String, dynamic>;
        _settings = StillwalksSettings.fromJson(json);
        debugPrint('NotificationPreferences: Loaded settings from storage');
      } else {
        debugPrint('NotificationPreferences: Using default settings (and saving them)');
        await _saveSettings(); // Ensure defaults are persisted for Native side to read
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('NotificationPreferences: Error loading settings: $e');
    }
  }
  
  /// Guarda las configuraciones actuales
  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(_settings.toJson());
      await prefs.setString(_storageKey, jsonString);
      debugPrint('NotificationPreferences: Settings saved');
    } catch (e) {
      debugPrint('NotificationPreferences: Error saving settings: $e');
    }
  }

  // --- GENERAL ---

  Future<void> setLanguage(String language) async {
    _settings = _settings.copyWith(
      language: language,
      hasLanguageBeenSelected: true,
    );
    await _saveSettings();
    notifyListeners();
  }

  Future<void> setSoundVibrationEnabled(bool enabled) async {
    _settings = _settings.copyWith(soundVibrationEnabled: enabled);
    await _saveSettings();
    notifyListeners();
  }

  Future<void> setBatterySaverMode(bool enabled) async {
    _settings = _settings.copyWith(batterySaverMode: enabled);
    
    // When battery saver is enabled, disable walk reminders
    if (enabled && _settings.walkReminderEnabled) {
      _settings = _settings.copyWith(
        walkReminderEnabled: false,
        walkReminderPreset: 'none',
      );
      _nativeBridge?.updateWalkReminder(false, 'none');
    }
    
    await _saveSettings();
    notifyListeners();
    
    debugPrint('Battery Saver Mode: ${enabled ? "ON" : "OFF"}');
  }

  // --- NOTIFICACIONES ---
  
  /// Actualiza la configuración general de notificaciones permanentes
  Future<void> setPermanentNotificationEnabled(bool enabled) async {
    _settings = _settings.copyWith(permanentNotificationEnabled: enabled);
    await _saveSettings();
    
    if (enabled) {
      await _nativeBridge?.startTracking();
    } else {
      await _nativeBridge?.stopTracking();
    }
    
    notifyListeners();
  }
  
  
  /// Actualiza la configuración de eventos (orbes + hitos)
  Future<void> setEventsNotificationEnabled(bool enabled) async {
    _settings = _settings.copyWith(eventsNotificationEnabled: enabled);
    await _saveSettings();
    notifyListeners();
  }
  
  /// Actualiza la configuración de recordatorios de paseo
  Future<void> setWalkReminderEnabled(bool enabled) async {
    _settings = _settings.copyWith(walkReminderEnabled: enabled);
    await _saveSettings();
    
    _nativeBridge?.updateWalkReminder(
      enabled, 
      enabled ? _settings.walkReminderPreset : 'none'
    );
    
    notifyListeners();
  }
  
  /// Actualiza el preset del recordatorio de paseo
  Future<void> setWalkReminderPreset(String preset) async {
    if (!['none', 'soft', 'normal'].contains(preset)) {
      debugPrint('NotificationPreferences: Invalid preset: $preset');
      return;
    }
    
    // Don't allow enabling reminders in battery saver mode
    if (preset != 'none' && _settings.batterySaverMode) {
      debugPrint('NotificationPreferences: Cannot enable reminders in battery saver mode');
      return;
    }
    
    final enabled = preset != 'none';
    _settings = _settings.copyWith(
      walkReminderPreset: preset,
      walkReminderEnabled: enabled,
    );
    await _saveSettings();
    
    _nativeBridge?.updateWalkReminder(enabled, preset);
    
    notifyListeners();
  }
  
  
  // --- BIENESTAR ---

  Future<void> setPauseProgress(bool paused) async {
    _settings = _settings.copyWith(pauseProgress: paused);
    await _saveSettings();
    
    if (paused) {
      // When pausing: stop tracking and hide permanent notification
      try {
        await _nativeBridge?.pauseTracking();
        debugPrint('NotificationPreferences: Progress paused - tracking stopped');
      } catch (e) {
        debugPrint('NotificationPreferences: Error pausing tracking: $e');
      }
    } else {
      // When resuming: restart tracking if permanent notification was enabled
      try {
        await _nativeBridge?.resumeTracking();
        if (_settings.permanentNotificationEnabled) {
          await _nativeBridge?.startTracking();
        }
        debugPrint('NotificationPreferences: Progress resumed - tracking restarted');
      } catch (e) {
        debugPrint('NotificationPreferences: Error resuming tracking: $e');
      }
    }
    
    notifyListeners();
  }

  Future<void> setDoNotDisturbEnabled(bool enabled) async {
    _settings = _settings.copyWith(doNotDisturbEnabled: enabled);
    await _saveSettings();
    notifyListeners();
  }

  Future<void> setDndStartTime(String time) async {
    _settings = _settings.copyWith(dndStartTime: time);
    await _saveSettings();
    notifyListeners();
  }

  Future<void> setDndEndTime(String time) async {
    _settings = _settings.copyWith(dndEndTime: time);
    await _saveSettings();
    notifyListeners();
  }

  Future<void> setDailyStepGoal(int goal) async {
    // Si se quita el objetivo (0), desactivar notificación
    bool shouldDisableNotification = goal == 0 && _settings.dailyGoalNotificationEnabled;
    
    _settings = _settings.copyWith(
      dailyStepGoal: goal,
      dailyGoalNotificationEnabled: shouldDisableNotification ? false : null,
    );
    await _saveSettings();
    notifyListeners();
  }

  Future<void> setDailyGoalNotificationEnabled(bool enabled) async {
    // No permitir activar si no hay objetivo
    if (enabled && _settings.dailyStepGoal == 0) return;

    _settings = _settings.copyWith(dailyGoalNotificationEnabled: enabled);
    await _saveSettings();
    notifyListeners();
  }

  // --- AUDIO ---

  Future<void> setMusicVolume(double volume) async {
    _settings = _settings.copyWith(musicVolume: volume.clamp(0.0, 1.0));
    await _saveSettings();
    notifyListeners();
  }

  // --- GOOGLE FIT ---

  Future<void> setHasSeenGoogleFitPrompt(bool seen) async {
    _settings = _settings.copyWith(hasSeenGoogleFitPrompt: seen);
    await _saveSettings();
    notifyListeners();
  }

  /// Restablece completamente la aplicación (Borra BBDD y Preferencias)
  Future<void> fullFactoryReset() async {
    try {
      debugPrint('🚨 NotificationPreferences: Performing FULL FACTORY RESET');
      
      // 1. Limpiar base de datos SQLite
      final dbHelper = DatabaseHelper();
      await dbHelper.resetDatabase();
      
      // 2. Limpiar SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      
      // 3. Reiniciar estado del bridge nativo
      if (_nativeBridge != null) {
        await _nativeBridge?.resetAccumulatedTime();
        await _nativeBridge?.setLastSyncedFlutterSteps(0);
        await _nativeBridge?.stopTracking();
      }
      
      // 4. Reiniciar estado en memoria
      _settings = const StillwalksSettings();
      
      notifyListeners();
      debugPrint('✅ NotificationPreferences: Reset completed successfully');
    } catch (e) {
      debugPrint('❌ NotificationPreferences: Error during factory reset: $e');
      rethrow;
    }
  }
}
