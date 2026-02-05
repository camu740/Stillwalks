import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:stillwalks/l10n/app_localizations.dart';

/// Clase para comunicación bidireccional con código nativo Android
class NativeBridge {
  static const platform = MethodChannel('com.stillwalks.app/native');
  static const esenciaChannel = MethodChannel('com.stillwalks.app/esencia');
  static const stepsChannel = MethodChannel('com.stillwalks.app/steps');
  
  // Callbacks para notificar a los services de Flutter
  Function(double esencia, double hours)? onEsenciaGenerated;
  Function(int newSteps, int totalSteps)? onStepsUpdated;
  
  NativeBridge() {
    _setupListeners();
  }
  
  void _setupListeners() {
    // Listener para Esencia generada
    esenciaChannel.setMethodCallHandler((call) async {
      if (call.method == 'onEsenciaGenerated') {
        final data = call.arguments as Map<dynamic, dynamic>;
        final esencia = (data['esencia'] as num).toDouble();
        final hours = (data['hours'] as num).toDouble();
        
        debugPrint('NativeBridge: Esencia generated: $esencia ($hours hours)');
        onEsenciaGenerated?.call(esencia, hours);
      }
    });
    
    // Listener para pasos actualizados
    stepsChannel.setMethodCallHandler((call) async {
      if (call.method == 'onStepsUpdated') {
        final data = call.arguments as Map<dynamic, dynamic>;
        final newSteps = data['newSteps'] as int;
        final totalSteps = data['totalSteps'] as int;
        
        debugPrint('NativeBridge: Steps updated: +$newSteps (Total: $totalSteps)');
        onStepsUpdated?.call(newSteps, totalSteps);
      }
    });
  }
  
  /// Inicia el tracking nativo (screen lock + steps)
  Future<void> startTracking() async {
    try {
      final result = await platform.invokeMethod('startTracking');
      debugPrint('NativeBridge: $result');
    } on PlatformException catch (e) {
      debugPrint('NativeBridge: Error starting tracking: ${e.message}');
      rethrow;
    }
  }
  
  /// Detiene el tracking nativo
  Future<void> stopTracking() async {
    try {
      final result = await platform.invokeMethod('stopTracking');
      debugPrint('NativeBridge: $result');
    } on PlatformException catch (e) {
      debugPrint('NativeBridge: Error stopping tracking: ${e.message}');
      rethrow;
    }
  }
  
  /// Pausa temporalmente el tracking (para Bienestar > Pausar progreso)
  Future<void> pauseTracking() async {
    try {
      final result = await platform.invokeMethod('pauseTracking');
      debugPrint('NativeBridge: $result');
    } on PlatformException catch (e) {
      debugPrint('NativeBridge: Error pausing tracking: ${e.message}');
      rethrow;
    }
  }
  
  /// Reanuda el tracking pausado
  Future<void> resumeTracking() async {
    try {
      final result = await platform.invokeMethod('resumeTracking');
      debugPrint('NativeBridge: $result');
    } on PlatformException catch (e) {
      debugPrint('NativeBridge: Error resuming tracking: ${e.message}');
      rethrow;
    }
  }
  
  /// Obtiene la Esencia pendiente (testing)
  Future<double> getEsencia() async {
    try {
      final result = await platform.invokeMethod('getEsencia');
      return (result as num).toDouble();
    } on PlatformException catch (e) {
      debugPrint('NativeBridge: Error getting Esencia: ${e.message}');
      return 0.0;
    }
  }
  
  /// Obtiene los pasos actuales
  Future<int> getSteps() async {
    try {
      final result = await platform.invokeMethod('getSteps');
      return result as int;
    } on PlatformException catch (e) {
      debugPrint('NativeBridge: Error getting steps: ${e.message}');
      return 0;
    }
  }
  /// Actualiza el contenido de la notificación
  Future<void> updateNotificationContent({
    required String title,
    required String body,
  }) async {
    try {
      await platform.invokeMethod('updateNotificationContent', {
        'title': title,
        'body': body,
      });
    } on PlatformException catch (e) {
      debugPrint('NativeBridge: Error updating notification: ${e.message}');
    }
  }
  
  /// Muestra la notificación de orbe listo
  Future<void> showOrbReadyNotification(String orbType) async {
    try {
      await platform.invokeMethod('showOrbReadyNotification', {
        'orbType': orbType,
      });
      debugPrint('NativeBridge: Orb ready notification shown for $orbType');
    } on PlatformException catch (e) {
      debugPrint('NativeBridge: Error showing orb ready notification: ${e.message}');
    }
  }
  
  /// Muestra la notificación de recordatorio de paseo
  Future<void> showWalkReminderNotification() async {
    try {
      await platform.invokeMethod('showWalkReminderNotification');
      debugPrint('NativeBridge: Walk reminder notification shown');
    } on PlatformException catch (e) {
      debugPrint('NativeBridge: Error showing walk reminder notification: ${e.message}');
    }
  }
  
  /// Muestra la notificación de hito de esencia
  Future<void> showMilestoneNotification(int essence) async {
    try {
      await platform.invokeMethod('showMilestoneNotification', {
        'essence': essence,
      });
      debugPrint('NativeBridge: Milestone notification shown for $essence essence');
    } on PlatformException catch (e) {
      debugPrint('NativeBridge: Error showing milestone notification: ${e.message}');
    }
  }

  /// Muestra la notificación de objetivo diario
  Future<void> showGoalReachedNotification(int goal) async {
    try {
      if (goal <= 0) return;
      await platform.invokeMethod('showGoalReachedNotification', {'goal': goal});
      debugPrint('NativeBridge: Goal notification shown for $goal steps');
    } on PlatformException catch (e) {
      debugPrint('NativeBridge: Error showing goal notification: ${e.message}');
    }
  }

  /// Actualiza la programación de recordatorios de paseo
  Future<void> updateWalkReminder(bool enabled, String preset) async {
    try {
      await platform.invokeMethod('updateWalkReminder', {
        'enabled': enabled,
        'preset': preset,
      });
      debugPrint('NativeBridge: Walk reminder updated: enabled=$enabled, preset=$preset');
    } on PlatformException catch (e) {
      debugPrint('NativeBridge: Error updating walk reminder: ${e.message}');
    }
  }

  /// Sincroniza las traducciones con el código nativo
  Future<void> syncLocalization(AppLocalizations l10n) async {
    try {
      await platform.invokeMethod('syncLocalization', {
        'orbReadyTitle': l10n.orbReadyTitle,
        'orbReadyBody': l10n.orbReadyBody,
        'walkReminderTitle': l10n.walkReminderTitle,
        'walkMsg1': l10n.walkMsg1,
        'walkMsg2': l10n.walkMsg2,
        'walkMsg3': l10n.walkMsg3,
        'walkMsg4': l10n.walkMsg4,
        'trackingServiceTitle': l10n.trackingServiceTitle,
        'trackingServiceBody': l10n.trackingServiceBody,
        'goalReachedTitle': l10n.goalReachedTitle,
        'goalReachedBody': l10n.goalReachedBody,
      });
      debugPrint('NativeBridge: Localization synced');
    } on PlatformException catch (e) {
      debugPrint('NativeBridge: Error syncing localization: ${e.message}');
    }
  }
}
