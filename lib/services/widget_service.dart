import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';
import 'package:stillwalks/models/sanctuary.dart';
import 'package:stillwalks/services/esencia_service.dart';
import 'package:stillwalks/services/orbe_service.dart';
import 'package:stillwalks/services/collection_service.dart';
import 'package:stillwalks/services/native_bridge.dart';
import 'package:stillwalks/models/upgrade.dart';

class WidgetService {
  static const String _groupId = 'group.stillwalks.widget'; // Para iOS si se implementa
  static const String _androidWidgetName = 'StillwalksWidget';

  /// Actualiza los datos del widget basándose en el estado actual
  Future<void> updateWidgetData({
    required EsenciaService essenceService,
    required OrbeService orbeService,
    required CollectionService collectionService,
    required NativeBridge nativeBridge,
  }) async {
    try {
      // 0. Enviar actualización a la notificación nativa
      _updateNativeNotification(nativeBridge, orbeService, essenceService);
      
      final futures = <Future>[];

      // 1. Esencia y Diario
      futures.add(HomeWidget.saveWidgetData<String>('total_essence', 
          essenceService.playerState.totalEsencia.toInt().toString()));
      
      // Calcular progreso del diario (discovered / total)
      final discovered = collectionService.discoveredSpeciesCount;
      final total = collectionService.totalSpeciesCount;
      futures.add(HomeWidget.saveWidgetData<String>('journal_progress', '$discovered / $total'));

      // 2. Santuarios
      final sanctuaries = orbeService.sanctuaries;
      
      // Santuario Primordial
      final primordial = sanctuaries.firstWhere(
        (s) => !s.isTemporary,
        orElse: () => Sanctuary(id: 'dummy', name: 'N/A', description: '', speedMultiplier: 1.0),
      );

      if (primordial.id != 'dummy') {
        // Incluir nivel en el nombre
        futures.add(HomeWidget.saveWidgetData<String>('s1_name', '${primordial.name} (Nv. ${primordial.speedUpgradeLevel})'));
        futures.addAll(_getSanctuaryUpdateFutures('s1', primordial, orbeService));
      }

      // Santuario Temporal
      try {
        final temporary = sanctuaries.firstWhere((s) => s.isTemporary);
        futures.add(HomeWidget.saveWidgetData<bool>('s2_visible', true));
        
        // Incluir usos restantes en el nombre
        final usosText = temporary.remainingUses == 1 ? 'uso' : 'usos';
        futures.add(HomeWidget.saveWidgetData<String>('s2_name', '${temporary.name} (${temporary.remainingUses} $usosText)'));
        
        // Determinar icono
        String iconType = 'default';
        if (temporary.typeId != null) {
          if (temporary.typeId == 'temp_sanctuary_fast_flow') iconType = 'fast';
          if (temporary.typeId == 'temp_sanctuary_symbiosis') iconType = 'symbiosis';
        }
        futures.add(HomeWidget.saveWidgetData<String>('s2_icon_type', iconType));
        
        futures.addAll(_getSanctuaryUpdateFutures('s2', temporary, orbeService));
      } catch (e) {
        // No hay santuario temporal
        futures.add(HomeWidget.saveWidgetData<bool>('s2_visible', false));
      }

      // 3. Almacén de Energía
      final storageCap = essenceService.storageCapacity;
      if (storageCap > 0) {
        futures.add(HomeWidget.saveWidgetData<bool>('storage_visible', true));
        
        // Obtener nivel del almacén
        final storageUpgrade = essenceService.upgrades.firstWhere(
          (u) => u.type == UpgradeType.energyStorage,
          orElse: () => Upgrade(id: '', type: UpgradeType.energyStorage, currentLevel: 0, name: 'Almacén', description: ''),
        );
        
        futures.add(HomeWidget.saveWidgetData<String>('storage_name', 'Almacén de Energía (Nv. ${storageUpgrade.currentLevel})'));
        
        final stored = essenceService.playerState.storedSteps;
        final progress = (stored / storageCap * 10000).clamp(0, 10000).toInt(); // 0-10000 for setImageLevel
        
        futures.add(HomeWidget.saveWidgetData<String>('storage_status', '$stored / $storageCap'));
        futures.add(HomeWidget.saveWidgetData<int>('storage_progress', progress));
        futures.add(HomeWidget.saveWidgetData<int>('storage_color', 0xFF448AFF)); // BlueAccent
        futures.add(HomeWidget.saveWidgetData<int>('storage_title_color', 0xFF448AFF)); // Title matches progress color
      } else {
        futures.add(HomeWidget.saveWidgetData<bool>('storage_visible', false));
      }

      // Ejecutar todas las guardas en paralelo
      await Future.wait(futures);

      // 4. Forzar actualización del widget
      await HomeWidget.updateWidget(
        name: _androidWidgetName,
      );
      
      debugPrint('Widget actualizado correctamente (Batch: ${futures.length} items)');
    } catch (e) {
      debugPrint('Error actualizando widget: $e');
    }
  }

  List<Future> _getSanctuaryUpdateFutures(String prefix, Sanctuary sanctuary, OrbeService orbeService) {
    final futures = <Future>[];
    int color = 0xFFE040FB; // Default Purple (Primordial)

    if (sanctuary.isTemporary) {
      // Default Cyan for temporary
      color = 0xFF18FFFF; 
      if (sanctuary.typeId == 'temp_sanctuary_fast_flow') color = 0xFFFFD740; // Yellow for Fast Flow
      if (sanctuary.typeId == 'temp_sanctuary_symbiosis') color = 0xFF69F0AE; // GreenAccent/Teal for Symbiosis
    }

    if (sanctuary.orbeId != null) {
      final orbe = orbeService.getOrbeById(sanctuary.orbeId!);
      if (orbe != null) {
        final type = orbeService.getOrbeType(orbe.orbeTypeId);
        if (type != null) {
          final requiredSteps = (type.requiredSteps / sanctuary.speedMultiplier).round();
          // Scale to 0-10000 for ClipDrawable
          final progress = (orbe.currentProgress / requiredSteps * 10000).clamp(0, 10000).toInt();
          
          if (orbe.currentProgress >= requiredSteps) {
            futures.add(HomeWidget.saveWidgetData<String>('${prefix}_status', '¡Canalizar ahora!'));
            color = 0xFF66BB6A; // Green for READY
          } else {
            futures.add(HomeWidget.saveWidgetData<String>('${prefix}_status', '${orbe.currentProgress} / $requiredSteps'));
          }
          
          futures.add(HomeWidget.saveWidgetData<int>('${prefix}_progress', progress));
          futures.add(HomeWidget.saveWidgetData<int>('${prefix}_color', color));
          futures.add(HomeWidget.saveWidgetData<int>('${prefix}_title_color', color)); // Title color matches progress
          return futures;
        }
      }
    }
    
    // Si no hay orbe o hay error
    futures.add(HomeWidget.saveWidgetData<String>('${prefix}_status', 'Sin orbe activo'));
    futures.add(HomeWidget.saveWidgetData<int>('${prefix}_progress', 0));
    futures.add(HomeWidget.saveWidgetData<int>('${prefix}_color', color)); // Empty bar color
    futures.add(HomeWidget.saveWidgetData<int>('${prefix}_title_color', color)); // Title color matches even when empty
    return futures;
  }

  Future<void> _updateNativeNotification(NativeBridge nativeBridge, OrbeService orbeService, EsenciaService essenceService) async {
    try {
      // (Misma lógica de notificación)
      // 0. Construir Línea 1 (Recursos)
      final currentEsencia = essenceService.playerState.totalEsencia.toInt();
      String resourceLine = 'Esencia: $currentEsencia';
      
      if (essenceService.storageCapacity > 0) {
        final stored = essenceService.playerState.storedSteps;
        final cap = essenceService.storageCapacity;
        resourceLine = 'Esencia: $currentEsencia | Almacén: $stored/$cap';
      }

      // 0. Construir Línea 2 (Santuarios)
      String sanctuaryLine = '';
      final sanctuaries = orbeService.sanctuaries;
      
      // 1. Primordial
      final primordial = sanctuaries.firstWhere(
        (s) => !s.isTemporary, 
        orElse: () => Sanctuary(id: 'dummy', name: '', description: '', speedMultiplier: 1.0),
      );

      if (primordial.id != 'dummy' && primordial.orbeId != null) {
        final orbe = orbeService.getOrbeById(primordial.orbeId!);
        if (orbe != null) {
          final type = orbeService.getOrbeType(orbe.orbeTypeId);
          if (type != null) {
            final requiredSteps = (type.requiredSteps / primordial.speedMultiplier).round();
            final pct = (orbe.currentProgress / requiredSteps * 100).toInt();
            final pText = (orbe.currentProgress >= requiredSteps) ? '¡Listo!' : '$pct%';
            sanctuaryLine = 'Primordial: $pText';
          }
        }
      }

      // 2. Temporal
      final temporary = sanctuaries.firstWhere(
        (s) => s.isTemporary,
        orElse: () => Sanctuary(id: 'dummy', name: '', description: '', speedMultiplier: 1.0),
      );

      if (temporary.id != 'dummy' && temporary.orbeId != null) {
        final orbe = orbeService.getOrbeById(temporary.orbeId!);
        if (orbe != null) {
          final type = orbeService.getOrbeType(orbe.orbeTypeId);
          if (type != null) {
            final requiredSteps = (type.requiredSteps / temporary.speedMultiplier).round();
            final pct = (orbe.currentProgress / requiredSteps * 100).toInt();
            final tText = (orbe.currentProgress >= requiredSteps) ? '¡Listo!' : '$pct%';
            
            if (sanctuaryLine.isNotEmpty) {
              sanctuaryLine = '$sanctuaryLine | Temporal: $tText';
            } else {
              sanctuaryLine = 'Temporal: $tText';
            }
          }
        }
      }
      
      if (sanctuaryLine.isEmpty) {
        sanctuaryLine = 'Sin orbes activos';
      }

      // Enviar actualización
      await nativeBridge.updateNotificationContent(
        title: resourceLine,
        body: sanctuaryLine,
      );

    } catch (e) {
      debugPrint('Error updating native notification: $e');
    }
  }
}
