import 'package:flutter/foundation.dart';
import 'package:stillwalks/services/native_bridge.dart';
import 'package:stillwalks/services/google_fit_service.dart';

/// Servicio que agrega y valida pasos de múltiples fuentes
/// Combina datos del sensor nativo y Google Fit para mayor precisión
class StepAggregatorService {
  final NativeBridge _nativeBridge;
  final GoogleFitService _googleFitService;
  
  DateTime? _lastNativeStepUpdate;
  DateTime? _lastGoogleFitUpdate;
  int _lastNativeSteps = 0;
  int _lastGoogleFitSteps = 0;
  
  StepAggregatorService(this._nativeBridge, this._googleFitService);
  
  /// Obtiene pasos de múltiples fuentes y selecciona la más confiable
  Future<StepData> getAggregatedSteps() async {
    final now = DateTime.now();
    
    // 1. Obtener pasos del sensor nativo
    int? nativeSteps;
    try {
      nativeSteps = await _nativeBridge.getSteps();
      _lastNativeSteps = nativeSteps;
      _lastNativeStepUpdate = now;
      debugPrint('📊 Native sensor steps: $nativeSteps');
    } catch (e) {
      debugPrint('⚠️ Error getting native steps: $e');
      nativeSteps = null;
    }
    
    // 2. Obtener pasos de Google Fit (si está habilitado)
    int? googleFitSteps;
    if (_googleFitService.isEnabled) {
      try {
        googleFitSteps = await _googleFitService.getStepsSinceLastSync();
        if (googleFitSteps != null && googleFitSteps > 0) {
          _lastGoogleFitSteps = googleFitSteps;
          _lastGoogleFitUpdate = now;
          debugPrint('📊 Google Fit steps: $googleFitSteps');
        }
      } catch (e) {
        debugPrint('⚠️ Error getting Google Fit steps: $e');
        googleFitSteps = null;
      }
    }
    
    // 3. Determinar la fuente más confiable
    return _selectBestSource(nativeSteps, googleFitSteps);
  }
  
  /// Selecciona la mejor fuente de datos basada en disponibilidad y confiabilidad
  StepData _selectBestSource(int? nativeSteps, int? googleFitSteps) {
    // Si ambas fuentes están disponibles, usar validación cruzada
    if (nativeSteps != null && googleFitSteps != null) {
      // Si los valores son similares (dentro del 20%), promediamos
      final difference = (nativeSteps - googleFitSteps).abs();
      final average = (nativeSteps + googleFitSteps) / 2;
      final percentDiff = (difference / average) * 100;
      
      if (percentDiff <= 20) {
        // Valores similares, usar promedio
        final avgSteps = ((nativeSteps + googleFitSteps) / 2).round();
        debugPrint('✅ Step sources agree (~${percentDiff.toStringAsFixed(1)}% diff). Using average: $avgSteps');
        return StepData(
          steps: avgSteps,
          source: StepSource.combined,
          reliability: StepReliability.high,
        );
      } else {
        // Valores muy diferentes, preferir Google Fit si está habilitado (más preciso)
        debugPrint('⚠️ Step sources disagree (${percentDiff.toStringAsFixed(1)}% diff). Native: $nativeSteps, GoogleFit: $googleFitSteps');
        debugPrint('→ Preferring Google Fit as primary source');
        return StepData(
          steps: googleFitSteps,
          source: StepSource.googleFit,
          reliability: StepReliability.medium,
        );
      }
    }
    
    // Solo Google Fit disponible
    if (googleFitSteps != null) {
      debugPrint('📊 Using Google Fit only');
      return StepData(
        steps: googleFitSteps,
        source: StepSource.googleFit,
        reliability: StepReliability.medium,
      );
    }
    
    // Solo sensor nativo disponible
    if (nativeSteps != null) {
      debugPrint('📊 Using native sensor only');
      return StepData(
        steps: nativeSteps,
        source: StepSource.nativeSensor,
        reliability: StepReliability.medium,
      );
    }
    
    // Ninguna fuente disponible
    debugPrint('❌ No step sources available');
    return StepData(
      steps: 0,
      source: StepSource.none,
      reliability: StepReliability.none,
    );
  }
  
  /// Obtiene diagnósticos del sistema de conteo de pasos
  Future<Map<String, dynamic>> getDiagnostics() async {
    final nativeWorking = await _nativeBridge.isStepCountingWorking();
    final nativeDiag = await _nativeBridge.getStepCountingDiagnostics();
    
    return {
      'nativeSensor': {
        'working': nativeWorking,
        'lastUpdate': _lastNativeStepUpdate?.toIso8601String(),
        'lastSteps': _lastNativeSteps,
        'details': nativeDiag,
      },
      'googleFit': {
        'enabled': _googleFitService.isEnabled,
        'available': _googleFitService.isAvailable,
        'lastUpdate': _lastGoogleFitUpdate?.toIso8601String(),
        'lastSteps': _lastGoogleFitSteps,
        'lastSync': _googleFitService.lastSyncTime?.toIso8601String(),
      },
      'overall': {
        'hasAnySource': nativeWorking || _googleFitService.isEnabled,
        'hasMultipleSources': nativeWorking && _googleFitService.isEnabled,
      },
    };
  }
}

/// Datos de pasos con metadatos
class StepData {
  final int steps;
  final StepSource source;
  final StepReliability reliability;
  
  StepData({
    required this.steps,
    required this.source,
    required this.reliability,
  });
}

/// Fuente de datos de pasos
enum StepSource {
  nativeSensor,
  googleFit,
  combined,
  none,
}

/// Nivel de confiabilidad de los datos
enum StepReliability {
  high,    // Validación cruzada exitosa
  medium,  // Una sola fuente confiable
  low,     // Fuente poco confiable
  none,    // Sin datos
}
