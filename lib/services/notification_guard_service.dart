import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stillwalks/services/notification_preferences_service.dart';
import 'package:stillwalks/services/native_bridge.dart';

/// Servicio encargado de evitar spam de notificaciones y aplicar reglas de bienestar.
class NotificationGuardService extends ChangeNotifier {
  static const String _lastAppActiveKey = 'flutter.last_app_active_timestamp';
  static const String _lastNotificationPrefix = 'last_notified_';
  // Daily Steps persistence
  static const String _dailyStepsKey = 'stillwalks_daily_steps';
  static const String _lastStepsDateKey = 'stillwalks_last_steps_date';

  DateTime _lastAppActive = DateTime.now();
  final Map<String, DateTime> _lastNotified = {};
  NotificationPreferencesService? _prefs;
  NativeBridge? _nativeBridge;
  
  // Daily tracking
  int _dailySteps = 0;
  DateTime _lastStepsDate = DateTime.now();

  void setPreferences(NotificationPreferencesService prefs) {
    _prefs = prefs;
  }

  void setNativeBridge(NativeBridge bridge) {
    _nativeBridge = bridge;
  }

  /// Inicializa el servicio
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final lastActiveMs = prefs.getInt(_lastAppActiveKey);
    if (lastActiveMs != null) {
      _lastAppActive = DateTime.fromMillisecondsSinceEpoch(lastActiveMs);
    }
    
    // Load daily steps
    _dailySteps = prefs.getInt(_dailyStepsKey) ?? 0;
    final dateStr = prefs.getString(_lastStepsDateKey);
    if (dateStr != null) {
      _lastStepsDate = DateTime.parse(dateStr);
    }
    
    // Check reset on init
    final now = DateTime.now();
    if (!_isSameDay(now, _lastStepsDate)) {
      _dailySteps = 0;
      _lastStepsDate = now;
      _saveDailySteps();
    }
    
    updateAppActive(); // Marcar como activo al iniciar
  }
  
  bool _isSameDay(DateTime d1, DateTime d2) {
    return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
  }

  /// Registra que la app está activa (el usuario interactúa)
  void updateAppActive() {
    _lastAppActive = DateTime.now();
    _saveLastActive();
  }

  Future<void> _saveLastActive() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastAppActiveKey, _lastAppActive.millisecondsSinceEpoch);
  }
  
  Future<void> _saveDailySteps() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_dailyStepsKey, _dailySteps);
    await prefs.setString(_lastStepsDateKey, _lastStepsDate.toIso8601String());
  }

  /// Determina si una notificación debería permitirse según reglas de bienestar
  bool shouldAllowNotification(String type, {Duration cooldown = const Duration(minutes: 5)}) {
    final now = DateTime.now();

    // Regla 0: Modo No Molestar
    if (_prefs != null && _prefs!.settings.doNotDisturbEnabled) {
      if (_isInDndRange(now, _prefs!.settings.dndStartTime, _prefs!.settings.dndEndTime)) {
        debugPrint('🛡️ NotificationGuard: Suppressed $type because of DND mode');
        return false;
      }
    }
    
    // Regra 1: No molestar si la app se cerró hace poco (ej. 15 min para recordatorios)
    if (type == 'walk_reminder') {
      if (now.difference(_lastAppActive) < const Duration(minutes: 15)) {
        debugPrint('🛡️ NotificationGuard: Suppressed walk_reminder because app was recently active');
        return false;
      }
    }

    // Regra 2: Cooldown por tipo para evitar spam
    final last = _lastNotified[type];
    if (last != null && now.difference(last) < cooldown) {
      debugPrint('🛡️ NotificationGuard: Suppressed $type because of cooldown');
      return false;
    }

    return true;
  }

  /// Marca que se ha enviado una notificación satisfactoriamente
  void markNotified(String type) {
    _lastNotified[type] = DateTime.now();
  }
  
  /// Actualiza pasos diarios y verifica objetivos
  Future<void> updateDailySteps(int delta) async {
    final now = DateTime.now();
    
    if (!_isSameDay(now, _lastStepsDate)) {
      _dailySteps = 0;
      _lastStepsDate = now;
    }
    
    _dailySteps += delta;
    _saveDailySteps();
    
    // Check Goal
    if (_prefs != null && _nativeBridge != null) {
      final settings = _prefs!.settings;
      if (settings.dailyGoalNotificationEnabled && settings.dailyStepGoal > 0) {
        if (_dailySteps >= settings.dailyStepGoal) {
          
          bool alreadyNotifiedToday = false;
          if (_lastNotified.containsKey('goal_reached')) {
             if (_isSameDay(_lastNotified['goal_reached']!, now)) {
               alreadyNotifiedToday = true;
             }
          }
          
          if (!alreadyNotifiedToday && shouldAllowNotification('goal_reached', cooldown: const Duration(hours: 20))) {
             _nativeBridge!.showGoalReachedNotification(settings.dailyStepGoal);
             markNotified('goal_reached');
          }
        }
      }
    }
  }

  bool _isInDndRange(DateTime now, String start, String end) {
    final startParts = start.split(':');
    final endParts = end.split(':');
    
    final startTime = now.copyWith(
      hour: int.parse(startParts[0]),
      minute: int.parse(startParts[1]),
      second: 0,
      millisecond: 0,
    );
    
    final endTime = now.copyWith(
      hour: int.parse(endParts[0]),
      minute: int.parse(endParts[1]),
      second: 0,
      millisecond: 0,
    );

    if (startTime.isBefore(endTime)) {
      // Rango normal (ej. 08:00 a 22:00)
      return now.isAfter(startTime) && now.isBefore(endTime);
    } else {
      // Rango nocturno (ej. 22:00 a 08:00)
      return now.isAfter(startTime) || now.isBefore(endTime);
    }
  }
}
