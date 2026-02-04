import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

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
}
