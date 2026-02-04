import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stillwalks/models/sanctuary.dart';
import 'package:stillwalks/models/inventory_item.dart';
import 'package:stillwalks/services/orbe_service.dart';
import 'package:stillwalks/services/esencia_service.dart';
import 'package:stillwalks/screens/sanctuary_screen.dart';
import 'package:stillwalks/screens/inventory_screen.dart';
import 'package:stillwalks/screens/channeling_screen.dart';
import 'package:stillwalks/screens/shop_screen.dart';
import 'package:stillwalks/models/upgrade.dart';

class SanctuarySlot extends StatelessWidget {
  final Sanctuary sanctuary;
  final OrbeService orbeService;

  const SanctuarySlot({
    super.key,
    required this.sanctuary,
    required this.orbeService,
  });

  @override
  Widget build(BuildContext context) {
    final hasOrbe = sanctuary.orbeId != null;
    
    // Obtener información del orbe si existe
    final orbe = hasOrbe 
        ? orbeService.orbes.where((o) => o.id == sanctuary.orbeId).firstOrNull 
        : null;
    final type = orbe != null ? orbeService.getOrbeType(orbe.orbeTypeId) : null;
    
    // Calcular progreso
    double progress = 0.0;
    int currentSteps = 0;
    int requiredSteps = 1;
    bool isReadyToChannel = false;
    
    if (orbe != null && type != null) {
      currentSteps = orbe.currentProgress;
      final effectiveRequiredSteps = (type.requiredSteps / sanctuary.speedMultiplier).round();
      requiredSteps = effectiveRequiredSteps;
      progress = (currentSteps / requiredSteps).clamp(0.0, 1.0);
      isReadyToChannel = currentSteps >= requiredSteps;
    }
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isReadyToChannel 
              ? Colors.greenAccent.withOpacity(0.5)
              : Colors.purpleAccent.withOpacity(0.3),
        ),
      ),
      child: Stack(
        children: [
          // Área clickeable principal
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: hasOrbe && !isReadyToChannel
                ? null // Deshabilitar si está canalizando
                : () async {
                    if (isReadyToChannel && orbe != null) {
                      // Canalizar el orbe
                      final esenciaService = Provider.of<EsenciaService>(context, listen: false);
                      final instance = await orbeService.channelOrbe(orbe.id);
                      
                      // Verificar si hay recompensa de Simbiosis
                      final symbiosisReward = orbeService.lastSymbiosisReward;
                      if (symbiosisReward > 0 && context.mounted) {
                        await esenciaService.addEsencia(symbiosisReward);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('¡Santuario de Simbiosis te otorgó ${symbiosisReward.toStringAsFixed(0)} de Esencia!'),
                            backgroundColor: Colors.cyanAccent.withOpacity(0.8),
                            duration: const Duration(seconds: 3),
                          ),
                        );
                        orbeService.clearSymbiosisReward();
                      }
                      
                      if (instance != null && context.mounted) {
                        final species = await orbeService.getSpeciesById(instance.speciesId);
                        final isNew = await orbeService.isNewDiscovery(instance.speciesId);
                        if (species != null && context.mounted) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChannelingScreen(
                                species: species,
                                instance: instance,
                                isNew: isNew,
                              ),
                            ),
                          );
                        }
                      }
                    } else {
                      // Abrir inventario para seleccionar orbe
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => InventoryScreen(
                            isSelectionMode: true,
                            sanctuaryId: sanctuary.id,
                          ),
                        ),
                      );
                    }
                  },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      if (hasOrbe && !isReadyToChannel)
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            value: progress,
                            strokeWidth: 3,
                            backgroundColor: Colors.white10,
                            color: Colors.purpleAccent,
                          ),
                        )
                      else
                        Icon(
                          isReadyToChannel ? Icons.check_circle : Icons.fort_outlined,
                          size: 20,
                          color: isReadyToChannel ? Colors.greenAccent : Colors.purpleAccent,
                        ),
                      const SizedBox(width: 8),
                      const Text(
                        'Primordial',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (hasOrbe)
                    Text(
                      isReadyToChannel 
                          ? '¡Canalizar ahora!' 
                          : '$currentSteps / $requiredSteps pasos',
                      style: TextStyle(
                        fontSize: 12,
                        color: isReadyToChannel ? Colors.greenAccent : Colors.white54,
                        fontWeight: isReadyToChannel ? FontWeight.bold : FontWeight.normal,
                      ),
                    )
                  else
                    const Text(
                      'Vacío',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white54,
                      ),
                    ),
                ],
              ),
            ),
          ),
          
          // Botón de información independiente (fuera del InkWell para evitar conflictos)
          Positioned(
            top: 4,
            right: 4,
            child: IconButton(
              icon: const Icon(Icons.info_outline, size: 20),
              color: Colors.purpleAccent.withOpacity(0.7),
              padding: const EdgeInsets.all(8),
              constraints: const BoxConstraints(),
              onPressed: () => _showPrimordialInfo(context, sanctuary),
            ),
          ),
        ],
      ),
    );
  }

  void _showPrimordialInfo(BuildContext context, Sanctuary sanctuary) {
    final esenciaService = Provider.of<EsenciaService>(context, listen: false);
    
    // Buscar la mejora de velocidad de forma segura
    final speedUpgrade = esenciaService.upgrades.firstWhere(
      (u) => u.type == UpgradeType.sanctuarySpeed,
      orElse: () => Upgrade(
        id: 'upgrade_sanctuary_speed',
        type: UpgradeType.sanctuarySpeed,
        currentLevel: 0,
        name: 'Velocidad de Canalización',
        description: '',
      ),
    );
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.deepPurple.shade900,
        title: const Row(
          children: [
            Icon(Icons.fort_outlined, color: Colors.purpleAccent),
            const SizedBox(width: 8),
            Text('Santuario Primordial'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📊 Características:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Text('• Tipo: Santuario Permanente'),
            Text('• Nivel de mejora: ${speedUpgrade.currentLevel}'),
            const Text('• Usos: Ilimitados ♾️'),
            const SizedBox(height: 16),
            const Text(
              '⚡ Habilidad Especial:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.purpleAccent),
            ),
            const SizedBox(height: 8),
            const Text('Canalización Infinita. Nunca se agota y permite canalizar cualquier tipo de orbe.'),
            const SizedBox(height: 16),
            const Text(
              '💡 Mejora la velocidad de canalización en la tienda para reducir los pasos necesarios.',
              style: TextStyle(color: Colors.amberAccent, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}

class TemporarySanctuarySlot extends StatelessWidget {
  final OrbeService orbeService;

  const TemporarySanctuarySlot({
    super.key,
    required this.orbeService,
  });

  @override
  Widget build(BuildContext context) {
    final tempSanctuary = orbeService.sanctuaries.where((s) => s.isTemporary).firstOrNull;
    final hasTemp = tempSanctuary != null;
    
    // Verificar si hay santuarios temporales en el inventario
    final hasTemporaryItems = orbeService.inventory.isNotEmpty;
    
    // Obtener información del orbe si existe
    final orbe = hasTemp && tempSanctuary.orbeId != null
        ? orbeService.orbes.where((o) => o.id == tempSanctuary.orbeId).firstOrNull
        : null;
    final type = orbe != null ? orbeService.getOrbeType(orbe.orbeTypeId) : null;
    
    // Calcular progreso
    double progress = 0.0;
    int currentSteps = 0;
    int requiredSteps = 1;
    bool isReadyToChannel = false;
    
    if (orbe != null && type != null && hasTemp) {
      currentSteps = orbe.currentProgress;
      final effectiveRequiredSteps = (type.requiredSteps / tempSanctuary.speedMultiplier).round();
      requiredSteps = effectiveRequiredSteps;
      progress = (currentSteps / requiredSteps).clamp(0.0, 1.0);
      isReadyToChannel = currentSteps >= requiredSteps;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isReadyToChannel
              ? Colors.greenAccent.withOpacity(0.5)
              : hasTemp 
                  ? Colors.cyanAccent.withOpacity(0.3) 
                  : Colors.white.withOpacity(0.1),
        ),
      ),
      child: Stack(
        children: [
          // Área clickeable principal
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: (hasTemp && orbe != null && !isReadyToChannel)
                ? null // Deshabilitar si está canalizando
                : () async {
                    if (hasTemp && isReadyToChannel && orbe != null) {
                      // Canalizar el orbe
                      final esenciaService = Provider.of<EsenciaService>(context, listen: false);
                      final instance = await orbeService.channelOrbe(orbe.id);
                      
                      // Verificar si hay recompensa de Simbiosis
                      final symbiosisReward = orbeService.lastSymbiosisReward;
                      if (symbiosisReward > 0 && context.mounted) {
                        await esenciaService.addEsencia(symbiosisReward);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('¡Santuario de Simbiosis te otorgó ${symbiosisReward.toStringAsFixed(0)} de Esencia!'),
                            backgroundColor: Colors.cyanAccent.withOpacity(0.8),
                            duration: const Duration(seconds: 3),
                          ),
                        );
                        orbeService.clearSymbiosisReward();
                      }
                      
                      if (instance != null && context.mounted) {
                        final species = await orbeService.getSpeciesById(instance.speciesId);
                        final isNew = await orbeService.isNewDiscovery(instance.speciesId);
                        if (species != null && context.mounted) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChannelingScreen(
                                species: species,
                                instance: instance,
                                isNew: isNew,
                              ),
                            ),
                          );
                        }
                      }
                    } else if (hasTemp && tempSanctuary.orbeId == null) {
                      // Si hay temporal asignado pero sin orbe, abrir inventario para asignar orbe
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => InventoryScreen(
                            isSelectionMode: true,
                            sanctuaryId: tempSanctuary.id,
                          ),
                        ),
                      );
                    } else if (hasTemporaryItems) {
                      // Si no hay temporal asignado pero sí hay items en inventario, abrir inventario en modo selección de santuarios
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const InventoryScreen(
                            isSanctuarySelectionMode: true,
                          ),
                        ),
                      );
                    } else {
                      // Si no hay temporales ni en slot ni en inventario, ir a la tienda (pestaña santuarios)
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ShopScreen(initialTab: 1),
                        ),
                      );
                    }
                  },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      if (hasTemp && orbe != null && !isReadyToChannel)
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            value: progress,
                            strokeWidth: 3,
                            backgroundColor: Colors.white10,
                            color: Colors.cyanAccent,
                          ),
                        )
                      else
                        Icon(
                          isReadyToChannel 
                              ? Icons.check_circle
                              : hasTemp 
                                  ? (tempSanctuary.typeId != null 
                                      ? InventoryItemTypes.getIcon(tempSanctuary.typeId!) 
                                      : Icons.timer)
                                  : (hasTemporaryItems ? Icons.add_circle_outline : Icons.shopping_bag_outlined),
                          size: hasTemp ? 20 : 24,
                          color: isReadyToChannel
                              ? Colors.greenAccent
                              : hasTemp 
                                  ? Colors.cyanAccent 
                                  : (hasTemporaryItems ? Colors.greenAccent : Colors.amber),
                        ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          hasTemp 
                              ? (tempSanctuary.typeId != null 
                                  ? InventoryItemTypes.getShortName(tempSanctuary.typeId!) 
                                  : tempSanctuary.name)
                              : (hasTemporaryItems ? 'Activar Santuario' : 'Comprar'),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: hasTemp ? Colors.white : (hasTemporaryItems ? Colors.white70 : Colors.amber),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (hasTemp && orbe != null)
                    Text(
                      isReadyToChannel 
                          ? '¡Canalizar ahora!' 
                          : '$currentSteps / $requiredSteps pasos',
                      style: TextStyle(
                        fontSize: 12,
                        color: isReadyToChannel ? Colors.greenAccent : Colors.white54,
                        fontWeight: isReadyToChannel ? FontWeight.bold : FontWeight.normal,
                      ),
                    )
                  else if (hasTemp)
                    Text(
                      'Vacío (${tempSanctuary.remainingUses} usos)',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white54,
                      ),
                    )
                  else
                    Text(
                      hasTemporaryItems ? 'Toca para activar' : 'Ir a tienda',
                      style: TextStyle(
                        fontSize: 12,
                        color: hasTemporaryItems ? Colors.white54 : Colors.amber.withOpacity(0.7),
                      ),
                    ),
                ],
              ),
            ),
          ),
          
          // Botón de información independiente
          if (hasTemp && tempSanctuary.typeId != null)
            Positioned(
              top: 4,
              right: 4,
              child: IconButton(
                icon: const Icon(Icons.info_outline, size: 20),
                color: Colors.cyanAccent.withOpacity(0.7),
                padding: const EdgeInsets.all(8),
                constraints: const BoxConstraints(),
                onPressed: () => _showTemporaryInfo(context, tempSanctuary),
              ),
            ),
        ],
      ),
    );
  }

  void _showTemporaryInfo(BuildContext context, Sanctuary sanctuary) {
    if (sanctuary.typeId == null) return;
    
    String abilityDescription = '';
    String abilityIcon = '⚡';
    
    switch (sanctuary.typeId) {
      case InventoryItemTypes.tempSanctuaryFastFlow:
        abilityDescription = 'Reduce los pasos requeridos en un 50% (multiplicador 2x de velocidad).';
        abilityIcon = '⚡';
        break;
      case InventoryItemTypes.tempSanctuarySymbiosis:
        abilityDescription = 'Otorga 1 punto de Esencia por cada 10 pasos realizados durante la canalización.';
        abilityIcon = '♾️';
        break;
      case InventoryItemTypes.tempSanctuaryQuietude:
        abilityDescription = 'Permite eclosionar orbes usando Esencia en lugar de pasos.';
        abilityIcon = '🧘';
        break;
      case InventoryItemTypes.tempSanctuaryEcho:
        abilityDescription = 'Reduce pasos en 70% pero solo genera criaturas comunes/inusuales.';
        abilityIcon = '📊';
        break;
      case InventoryItemTypes.tempSanctuaryResonance:
        abilityDescription = 'Aumenta la probabilidad de obtener criaturas raras en +10%.';
        abilityIcon = '⭕';
        break;
      default:
        abilityDescription = 'Habilidad especial activa.';
    }
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.deepPurple.shade900,
        title: Row(
          children: [
            Icon(InventoryItemTypes.getIcon(sanctuary.typeId!), color: Colors.cyanAccent),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                InventoryItemTypes.getName(sanctuary.typeId!),
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📊 Características:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Text('• Tipo: Santuario Temporal'),
            Text('• Usos restantes: ${sanctuary.remainingUses}'),
            const SizedBox(height: 16),
            Text(
              '$abilityIcon Habilidad Especial:',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.cyanAccent),
            ),
            const SizedBox(height: 8),
            Text(abilityDescription),
            const SizedBox(height: 16),
            const Text(
              '⚠️ Se destruye automáticamente después de agotar todos los usos.',
              style: TextStyle(color: Colors.orangeAccent, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}
