import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stillwalks/models/sanctuary.dart';
import 'package:stillwalks/models/inventory_item.dart';
import 'package:stillwalks/models/orbe.dart';
import 'package:stillwalks/services/orbe_service.dart';
import 'package:stillwalks/services/esencia_service.dart';
import 'package:stillwalks/screens/sanctuary_screen.dart';
import 'package:stillwalks/screens/inventory_screen.dart';
import 'package:stillwalks/screens/channeling_screen.dart';
import 'package:stillwalks/screens/shop_screen.dart';
import 'package:stillwalks/models/upgrade.dart';

import 'package:stillwalks/l10n/app_localizations.dart';
import 'package:stillwalks/l10n/data_localizations.dart';

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
    final esenciaService = Provider.of<EsenciaService>(context);
    final storedSteps = esenciaService.playerState.storedSteps;
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
    bool canInfuse = false;
    final currentEsencia = esenciaService.playerState.totalEsencia;
    
    if (orbe != null && type != null) {
      canInfuse = type.mechanics['canInfuseEssence'] == true;
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
                            content: Text(AppLocalizations.of(context)!.symbiosisReward(symbiosisReward.toStringAsFixed(0))),
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
                      Expanded(
                        child: Text(
                          AppLocalizations.of(context)!.getSanctuaryName(sanctuary.id, sanctuary.typeId, sanctuary.name),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (hasOrbe)
                    Text(
                      isReadyToChannel 
                          ? AppLocalizations.of(context)!.channelNow 
                          : sanctuary.typeId == InventoryItemTypes.tempSanctuaryQuietude
                              ? AppLocalizations.of(context)!.progressEssence(currentSteps, requiredSteps)
                              : AppLocalizations.of(context)!.progressSteps(currentSteps, requiredSteps),
                      style: TextStyle(
                        fontSize: 12,
                        color: isReadyToChannel ? Colors.greenAccent : Colors.white54,
                        fontWeight: isReadyToChannel ? FontWeight.bold : FontWeight.normal,
                      ),
                    )
                  else
                    Text(
                      AppLocalizations.of(context)!.emptySlot,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white54,
                      ),
                    ),
                  if (hasOrbe && !isReadyToChannel && storedSteps > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: SizedBox(
                        height: 28,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent.withOpacity(0.3),
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                          ),
                          icon: const Icon(Icons.battery_charging_full, size: 14, color: Colors.blueAccent),
                          label: Text(
                            '${AppLocalizations.of(context)!.useStorage} ($storedSteps)',
                            style: const TextStyle(fontSize: 11, color: Colors.white),
                          ),
                          onPressed: () => _showStorageChannelDialog(context, sanctuary.orbeId!, requiredSteps - currentSteps, storedSteps, esenciaService),
                        ),
                      ),
                    ),
                  if (hasOrbe && !isReadyToChannel && canInfuse && currentEsencia >= 50) // Mínimo 50 esencia para mostrar
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: SizedBox(
                        height: 28,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purpleAccent.withOpacity(0.3),
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                          ),
                          icon: const Icon(Icons.bolt, size: 14, color: Colors.purpleAccent),
                          label: Text(
                            AppLocalizations.of(context)!.infuseEssence,
                            style: const TextStyle(fontSize: 11, color: Colors.white),
                          ),
                          onPressed: () => _showEssenceInfusionDialog(context, sanctuary.orbeId!, type!, requiredSteps - currentSteps, currentEsencia, esenciaService),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          
          // Botón de información en la esquina superior derecha
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
          
          // Badge de nivel en la esquina inferior derecha
          Positioned(
            bottom: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.purpleAccent.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.purpleAccent.withOpacity(0.3)),
              ),
              child: Text(
                '${AppLocalizations.of(context)!.levelAbbr} ${sanctuary.speedUpgradeLevel}',
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.purpleAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showStorageChannelDialog(BuildContext context, String orbeId, int needed, int stored, EsenciaService esenciaService) {
    int toTransfer = min(needed, stored);
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: Colors.blueGrey.shade900,
            title: const Text('Canalizar Energía'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Elige cuánta energía transferir:'),
                const SizedBox(height: 16),
                Text(
                  '$toTransfer',
                  style: const TextStyle(
                    fontSize: 32, 
                    fontWeight: FontWeight.bold, 
                    color: Colors.blueAccent
                  ),
                ),
                const Text('pasos', style: TextStyle(color: Colors.blueAccent)),
                const SizedBox(height: 16),
                Slider(
                  value: toTransfer.toDouble(),
                  min: 1,
                  max: min(needed, stored).toDouble(),
                  activeColor: Colors.blueAccent,
                  inactiveColor: Colors.blueAccent.withOpacity(0.2),
                  onChanged: (value) {
                    setState(() {
                      toTransfer = value.round();
                    });
                  },
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('1', style: TextStyle(fontSize: 10, color: Colors.white54)),
                    Text('${min(needed, stored)}', style: TextStyle(fontSize: 10, color: Colors.white54)),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Almacén: $stored | Necesarios: $needed',
                  style: const TextStyle(fontSize: 12, color: Colors.white54),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context), 
                child: const Text('Cancelar', style: TextStyle(color: Colors.white70))
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
                onPressed: () async {
                  Navigator.pop(context);
                  final consumed = await esenciaService.consumeStoredSteps(toTransfer);
                  if (consumed > 0) {
                    await orbeService.updateOrbeProgress(orbeId, consumed);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('¡Se canalizaron $consumed pasos del almacén!'))
                      );
                    }
                  }
                },
                child: const Text('Transferir', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showPrimordialInfo(BuildContext context, Sanctuary sanctuary) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.deepPurple.shade900,
        title: Row(
          children: [
            Icon(Icons.fort_outlined, color: Colors.purpleAccent),
            const SizedBox(width: 8),
            Text(AppLocalizations.of(context)!.getSanctuaryName(sanctuary.id, sanctuary.typeId, sanctuary.name)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.stats,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text('• ${AppLocalizations.of(context)!.typePermanent}'),
            Text('• ${AppLocalizations.of(context)!.upgradeLevel(sanctuary.speedUpgradeLevel, (sanctuary.speedUpgradeLevel * 2).toStringAsFixed(0))}'),
            Text('• ${AppLocalizations.of(context)!.unlimitedUses}'),
            const SizedBox(height: 16),
            Text(
              '⚡ ${AppLocalizations.of(context)!.specialAbility}',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.purpleAccent),
            ),
            const SizedBox(height: 8),
            Text(AppLocalizations.of(context)!.infiniteChannelingDesc),
            const SizedBox(height: 16),
            Text(
              '💡 ${AppLocalizations.of(context)!.improveSpeedHint}',
              style: TextStyle(color: Colors.amberAccent, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.close),
          ),
        ],
      ),
    );
  }


  void _showEssenceInfusionDialog(BuildContext context, String orbeId, OrbeType type, int neededSteps, double currentEssence, EsenciaService esenciaService) {
    // Configuración desde mechanics
    final essenceCostPerStep = (type.mechanics['essenceToStepsCost'] as num?)?.toDouble() ?? 2.0;

    double essenceToSpend = 100.0;
    if (essenceToSpend > currentEssence) essenceToSpend = currentEssence;
    
    // Calcular máximo posible
    double maxEssence = min(currentEssence, neededSteps * essenceCostPerStep);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          int stepsToGain = (essenceToSpend / essenceCostPerStep).floor();

          return AlertDialog(
            backgroundColor: Colors.deepPurple.shade900,
            title: Text(AppLocalizations.of(context)!.infuseEssence),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(AppLocalizations.of(context)!.infuseEssenceDesc(essenceToSpend.toStringAsFixed(0), stepsToGain)),
                const SizedBox(height: 16),
                Text(
                  '-${essenceToSpend.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 32, 
                    fontWeight: FontWeight.bold, 
                    color: Colors.amberAccent
                  ),
                ),
                Text(AppLocalizations.of(context)!.essence, style: TextStyle(color: Colors.amberAccent)),
                const SizedBox(height: 8),
                Icon(Icons.arrow_downward, color: Colors.white54, size: 16),
                const SizedBox(height: 8),
                 Text(
                  '+$stepsToGain',
                  style: const TextStyle(
                    fontSize: 32, 
                    fontWeight: FontWeight.bold, 
                    color: Colors.greenAccent
                  ),
                ),
                Text(AppLocalizations.of(context)!.steps, style: TextStyle(color: Colors.greenAccent)),
                const SizedBox(height: 16),
                Slider(
                  value: essenceToSpend,
                  min: 10, // Mínimo
                  max: max(10, maxEssence),
                  activeColor: Colors.amberAccent,
                  inactiveColor: Colors.amberAccent.withOpacity(0.2),
                  onChanged: (value) {
                    setState(() {
                      essenceToSpend = value;
                    });
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context), 
                child: Text(AppLocalizations.of(context)!.cancel, style: TextStyle(color: Colors.white70))
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.purpleAccent),
                onPressed: () async {
                  Navigator.pop(context);
                  // Validar de nuevo
                  if (esenciaService.playerState.totalEsencia < essenceToSpend) return;

                  await esenciaService.spendEsencia(essenceToSpend);
                  await orbeService.updateOrbeProgress(orbeId, stepsToGain);
                  
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(AppLocalizations.of(context)!.essenceInfused(stepsToGain)))
                    );
                  }
                },
                child: Text(AppLocalizations.of(context)!.confirm, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          );
        },
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
    final esenciaService = Provider.of<EsenciaService>(context);
    final storedSteps = esenciaService.playerState.storedSteps;
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
                            content: Text(AppLocalizations.of(context)!.symbiosisReward(symbiosisReward.toStringAsFixed(0))),
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
                                    ? AppLocalizations.of(context)!.getSanctuaryName(tempSanctuary.id, tempSanctuary.typeId!, tempSanctuary.name)
                                    : tempSanctuary.name)
                                : (hasTemporaryItems ? AppLocalizations.of(context)!.activateSanctuary : AppLocalizations.of(context)!.buy),
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
                          ? AppLocalizations.of(context)!.channelNow 
                          : tempSanctuary.typeId == InventoryItemTypes.tempSanctuaryQuietude
                              ? AppLocalizations.of(context)!.progressEssence(currentSteps, requiredSteps)
                              : AppLocalizations.of(context)!.progressSteps(currentSteps, requiredSteps),
                      style: TextStyle(
                        fontSize: 12,
                        color: isReadyToChannel ? Colors.greenAccent : Colors.white54,
                        fontWeight: isReadyToChannel ? FontWeight.bold : FontWeight.normal,
                      ),
                    )
                  else if (hasTemp)
                    Text(
                      AppLocalizations.of(context)!.emptySlot,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white54,
                      ),
                    )
                  else
                    Text(
                      hasTemporaryItems 
                          ? AppLocalizations.of(context)!.tapToActivate 
                          : AppLocalizations.of(context)!.goToShop,
                      style: TextStyle(
                        fontSize: 12,
                        color: hasTemporaryItems ? Colors.white54 : Colors.amber.withOpacity(0.7),
                      ),
                    ),
                  if (hasTemp && orbe != null && !isReadyToChannel && storedSteps > 0)
                   Padding(
                     padding: const EdgeInsets.only(top: 8.0),
                     child: SizedBox(
                       height: 28,
                       child: ElevatedButton.icon(
                         style: ElevatedButton.styleFrom(
                           backgroundColor: Colors.blueAccent.withOpacity(0.3),
                           padding: const EdgeInsets.symmetric(horizontal: 8),
                         ),
                         icon: const Icon(Icons.battery_charging_full, size: 14, color: Colors.blueAccent),
                           label: Text(
                             '${AppLocalizations.of(context)!.useStorage} ($storedSteps)',
                             style: const TextStyle(fontSize: 11, color: Colors.white),
                           ),
                         onPressed: () => _showStorageChannelDialog(context, tempSanctuary!.orbeId!, requiredSteps - currentSteps, storedSteps, esenciaService),
                       ),
                     ),
                   ),
                ],
              ),
            ),
          ),
          
          // Badge de usos en la esquina inferior derecha
          if (hasTemp)
            Positioned(
              bottom: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.cyanAccent.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.cyanAccent.withOpacity(0.3)),
                ),
                child: Text(
                  '${tempSanctuary.remainingUses} ${AppLocalizations.of(context)!.usesPlural}',
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.cyanAccent,
                    fontWeight: FontWeight.bold,
                  ),
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

  void _showStorageChannelDialog(BuildContext context, String orbeId, int needed, int stored, EsenciaService esenciaService) {
    int toTransfer = min(needed, stored);
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: Colors.blueGrey.shade900,
            title: Text(AppLocalizations.of(context)!.channelEnergy),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(AppLocalizations.of(context)!.chooseEnergyTransfer),
                const SizedBox(height: 16),
                Text(
                  '$toTransfer',
                  style: const TextStyle(
                    fontSize: 32, 
                    fontWeight: FontWeight.bold, 
                    color: Colors.blueAccent
                  ),
                ),
                Text(AppLocalizations.of(context)!.stepsLower, style: TextStyle(color: Colors.blueAccent)),
                const SizedBox(height: 16),
                Slider(
                  value: toTransfer.toDouble(),
                  min: 1,
                  max: min(needed, stored).toDouble(),
                  activeColor: Colors.blueAccent,
                  inactiveColor: Colors.blueAccent.withOpacity(0.2),
                  onChanged: (value) {
                    setState(() {
                      toTransfer = value.round();
                    });
                  },
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('1', style: TextStyle(fontSize: 10, color: Colors.white54)),
                    Text('${min(needed, stored)}', style: TextStyle(fontSize: 10, color: Colors.white54)),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  AppLocalizations.of(context)!.storageVsNeeded(stored, needed),
                  style: const TextStyle(fontSize: 12, color: Colors.white54),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context), 
                child: Text(AppLocalizations.of(context)!.cancel, style: TextStyle(color: Colors.white70))
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
                onPressed: () async {
                  Navigator.pop(context);
                  final consumed = await esenciaService.consumeStoredSteps(toTransfer);
                  if (consumed > 0) {
                    await orbeService.updateOrbeProgress(orbeId, consumed);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(AppLocalizations.of(context)!.stepsChanneledFromStorage(consumed)))
                      );
                    }
                  }
                },
                child: Text(AppLocalizations.of(context)!.transfer, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showTemporaryInfo(BuildContext context, Sanctuary sanctuary) {
    if (sanctuary.typeId == null) return;
    
    final abilityDescription = AppLocalizations.of(context)!.getTemporarySanctuaryAbilityDescription(sanctuary.typeId!);
    String abilityIcon = '⚡';
    
    switch (sanctuary.typeId) {
      case InventoryItemTypes.tempSanctuaryFastFlow:
        abilityIcon = '⚡';
        break;
      case InventoryItemTypes.tempSanctuarySymbiosis:
        abilityIcon = '♾️';
        break;
      case InventoryItemTypes.tempSanctuaryQuietude:
        abilityIcon = '🧘';
        break;
      case InventoryItemTypes.tempSanctuaryEcho:
        abilityIcon = '📊';
        break;
      case InventoryItemTypes.tempSanctuaryResonance:
        abilityIcon = '⭕';
        break;
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
                AppLocalizations.of(context)!.getSanctuaryName(sanctuary.id, sanctuary.typeId!, sanctuary.name),
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.stats,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text('• ${AppLocalizations.of(context)!.typeTemporary}'),
            Text('• ${AppLocalizations.of(context)!.remainingUses(sanctuary.remainingUses)}'),
            const SizedBox(height: 16),
            Text(
              '$abilityIcon ${AppLocalizations.of(context)!.specialAbility}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.cyanAccent),
            ),
            const SizedBox(height: 8),
            Text(abilityDescription),
            const SizedBox(height: 16),
            Text(
              '⚠️ ${AppLocalizations.of(context)!.destroyWarning}',
              style: TextStyle(color: Colors.orangeAccent, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.close),
          ),
        ],
      ),
    );
  }
}
