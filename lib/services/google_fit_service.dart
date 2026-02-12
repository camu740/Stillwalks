import 'package:flutter/foundation.dart';
import 'package:health/health.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Servicio opcional para obtener pasos desde Google Fit / Health Connect
/// Solo se usa si el usuario lo habilita en configuración
class GoogleFitService extends ChangeNotifier {
  static const String _prefKeyEnabled = 'google_fit_enabled';
  static const String _prefKeyLastSync = 'google_fit_last_sync';
  
  final Health _health = Health();
  bool _isEnabled = false;
  bool _isAvailable = false;
  DateTime? _lastSyncTime;
  
  bool get isEnabled => _isEnabled;
  bool get isAvailable => _isAvailable;
  DateTime? get lastSyncTime => _lastSyncTime;
  
  /// Inicializa el servicio y carga preferencias
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _isEnabled = prefs.getBool(_prefKeyEnabled) ?? false;
    
    final lastSyncMs = prefs.getInt(_prefKeyLastSync);
    if (lastSyncMs != null) {
      _lastSyncTime = DateTime.fromMillisecondsSinceEpoch(lastSyncMs);
    }
    
    // Verificar si Health/Google Fit está disponible en el dispositivo
    await _checkAvailability();
    
    debugPrint('📊 GoogleFitService initialized: enabled=$_isEnabled, available=$_isAvailable');
    notifyListeners();
  }
  
  /// Verifica si Google Fit / Health Connect está disponible
  Future<void> _checkAvailability() async {
    try {
      // Intentar obtener tipos de datos soportados
      final types = [HealthDataType.STEPS];
      final permissions = [HealthDataAccess.READ];
      
      // Esto NO pide permisos, solo verifica disponibilidad
      _isAvailable = await _health.hasPermissions(types, permissions: permissions) != null;
      debugPrint('📊 Google Fit availability: $_isAvailable');
    } catch (e) {
      debugPrint('⚠️ Error checking Google Fit availability: $e');
      _isAvailable = false;
    }
  }
  
  /// Habilita Google Fit (requiere permisos del usuario)
  Future<bool> enable() async {
    // We attempt to enable even if _isAvailable is false, because 
    // _isAvailable depends on having permissions, which we are about to request.
    
    try {
      debugPrint('🔑 Requesting Google Fit permissions...');
      
      final types = [HealthDataType.STEPS];
      final permissions = [HealthDataAccess.READ];
      
      // Solicitar permisos
      final granted = await _health.requestAuthorization(types, permissions: permissions);
      
      if (granted) {
        _isEnabled = true;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_prefKeyEnabled, true);
        
        debugPrint('✅ Google Fit enabled successfully');
        notifyListeners();
        return true;
      } else {
        debugPrint('❌ Google Fit permissions denied by user');
        return false;
      }
    } catch (e) {
      debugPrint('❌ Error enabling Google Fit: $e');
      return false;
    }
  }
  
  /// Deshabilita Google Fit
  Future<void> disable() async {
    _isEnabled = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKeyEnabled, false);
    
    debugPrint('📊 Google Fit disabled');
    notifyListeners();
  }
  
  /// Obtiene los pasos desde la última sincronización
  /// Retorna null si no está habilitado o hay error
  Future<int?> getStepsSinceLastSync() async {
    if (!_isEnabled) {
      return null; // No habilitado, usar sensor hardware
    }
    
    try {
      final now = DateTime.now();
      final startTime = _lastSyncTime ?? now.subtract(const Duration(hours: 24));
      
      debugPrint('📊 Querying Google Fit steps: ${startTime.toString()} to ${now.toString()}');
      
      // Obtener datos de pasos
      final types = [HealthDataType.STEPS];
      final permissions = [HealthDataAccess.READ];
      
      // Verificar permisos nuevamente
      final hasPermission = await _health.hasPermissions(types, permissions: permissions);
      if (hasPermission != true) {
        debugPrint('⚠️ Google Fit permissions revoked or not granted');
        
        // Try to re-request permissions once before disabling
        debugPrint('🔑 Attempting to re-request Google Fit permissions...');
        final granted = await _health.requestAuthorization(types, permissions: permissions);
        
        if (!granted) {
          debugPrint('❌ Google Fit permissions still denied, disabling service');
          await disable();
          return null;
        }
        
        debugPrint('✅ Google Fit permissions re-granted');
      }
      
      // Obtener datos with retry mechanism
      List<HealthDataPoint> healthData = [];
      int retryCount = 0;
      const maxRetries = 3;
      
      while (retryCount < maxRetries) {
        try {
          healthData = await _health.getHealthDataFromTypes(
            types: types,
            startTime: startTime,
            endTime: now,
          );
          break; // Success, exit retry loop
        } catch (e) {
          retryCount++;
          if (retryCount >= maxRetries) {
            debugPrint('❌ Failed to get Google Fit data after $maxRetries attempts: $e');
            rethrow;
          }
          debugPrint('⚠️ Retry $retryCount/$maxRetries: Error getting Google Fit data: $e');
          await Future.delayed(Duration(seconds: retryCount * 2)); // Exponential backoff
        }
      }
      
      // Sumar todos los pasos
      int totalSteps = 0;
      for (var data in healthData) {
        if (data.type == HealthDataType.STEPS) {
          // In health 13.x, value is a HealthValue (could be NumericHealthValue, etc.)
          final value = data.value;
          if (value is NumericHealthValue) {
            totalSteps += value.numericValue.toInt();
          }
        }
      }
      
      // Actualizar tiempo de sincronización
      _lastSyncTime = now;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_prefKeyLastSync, now.millisecondsSinceEpoch);
      
      debugPrint('📊 Google Fit returned: $totalSteps steps (${healthData.length} data points)');
      
      return totalSteps;
    } catch (e, stackTrace) {
      debugPrint('❌ Error getting steps from Google Fit: $e');
      debugPrint('Stack trace: $stackTrace');
      // Don't disable on error, just return null to fall back to hardware sensor
      return null;
    }
  }
  
  /// Resetea el tiempo de última sincronización
  /// Útil para testing o reset del juego
  Future<void> resetSyncTime() async {
    _lastSyncTime = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefKeyLastSync);
    debugPrint('📊 Google Fit sync time reset');
  }
}
