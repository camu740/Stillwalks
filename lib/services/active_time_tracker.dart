import 'package:flutter/foundation.dart';

/// Servicio que rastrea cuánto tiempo el usuario ha estado activamente
/// usando Stillwalks (app en foreground, no minimizada)
class ActiveTimeTracker extends ChangeNotifier {
  DateTime? _activeStartTime;
  int _accumulatedMinutes = 0;
  bool _isActive = false;

  bool get isActive => _isActive;
  int get accumulatedMinutes => _accumulatedMinutes;

  /// Llamar cuando la app entra en foreground (AppLifecycleState.resumed)
  void startTracking() {
    if (_isActive) return;
    
    _activeStartTime = DateTime.now();
    _isActive = true;
    debugPrint('🟢 ActiveTimeTracker: Started tracking active time');
  }

  /// Llamar cuando la app sale del foreground (paused/inactive/detached)
  void stopTracking() {
    if (!_isActive || _activeStartTime == null) return;
    
    final now = DateTime.now();
    final elapsedMinutes = now.difference(_activeStartTime!).inMinutes;
    
    if (elapsedMinutes > 0) {
      _accumulatedMinutes += elapsedMinutes;
      debugPrint('⏸️ ActiveTimeTracker: Stopped. Session: ${elapsedMinutes}min, Total: ${_accumulatedMinutes}min');
    }
    
    _activeStartTime = null;
    _isActive = false;
  }

 /// Obtiene el tiempo acumulado (incluyendo la sesión actual si está activa)
  int getCurrentAccumulatedMinutes() {
    int total = _accumulatedMinutes;
    
    if (_isActive && _activeStartTime != null) {
      final now = DateTime.now();
      final currentSessionMinutes = now.difference(_activeStartTime!).inMinutes;
      total += currentSessionMinutes;
    }
    
    return total;
  }

  /// Reinicia el contador (después de que se haya procesado la esencia)
  void reset() {
    _accumulatedMinutes = 0;
    // Si está activo, reiniciar el tiempo de inicio a ahora
    if (_isActive) {
      _activeStartTime = DateTime.now();
      debugPrint('🔄 ActiveTimeTracker: Reset (restarting active session)');
    } else {
      debugPrint('🔄 ActiveTimeTracker: Reset');
    }
  }
}
