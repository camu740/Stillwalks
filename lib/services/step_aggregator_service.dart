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
  
  /// Inicializa el servicio y sincroniza pasos pendientes
  Future<void> initialize() async {
    // Restaurar último valor conocido para cálculo de delta
    // Simular persistencia básica por ahora o usar SharedPreferences si es accesible
    // Para simplificar, asumimos que main.dart inyectará la lógica o lo haremos aquí si añadimos shared_preferences al pubspec
    // Pero como no puedo editar pubspec, usaré NativeBridge para guardar/cargar valores simples si es posible
    // O mejor, delegar al caller.
    
    // Actually, let's use the NativeBridge to store this "last synced" value 
    // since we already have shared prefs in native side for other things?
    // No, standard flutter shared_preferences is better but I can't check pubspec.
    // Assuming shared_preferences is used in other services? 
    // EsenciaService uses DatabaseHelper.
    
    // Let's rely on NativeBridge to give us the delta?
    // Native StepCounterService keeps 'sessionSteps'.
    // If we simply ask native for "steps since timestamp X", it's hard.
    
    // Alternative: Add 'lastSyncedSteps' to PlayerState?
    // Or use a local file?
    
    // Let's check if DatabaseHelper can store generic key-values?
    // It has `updatePlayerState`. 
    
    // For now, I will modify `main.dart` to handle the sync logic using a simple logic, 
    // but first let's expose a method here to process the "catch up".
  }

  /// Sincroniza los pasos acumulados mientras la app estaba cerrada
  Future<int> syncMissedSteps() async {
    try {
      final nativeSteps = await _nativeBridge.getSteps();
      
      // Necesitamos saber cuántos pasos teníamos la última vez que corrió la app.
      // Si no tenemos persistencia local de este valor, no podemos calcular el delta.
      // Pero, el servicio nativo envía "newSteps" como delta en tiempo real.
      
      // Solución: El servicio nativo debería trackear "pasos enviados a flutter".
      // O Flutter debería guardar "pasos recibidos del nativo".
      
      return 0; // Placeholder until persistence strategy is decided
    } catch (e) {
      debugPrint('⚠️ Error syncing missed steps: $e');
      return 0;
    }
  }

  // ... rest of class override
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
