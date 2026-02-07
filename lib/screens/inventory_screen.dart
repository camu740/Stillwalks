import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stillwalks/services/orbe_service.dart';
import 'package:stillwalks/models/orbe.dart';
import 'package:stillwalks/models/inventory_item.dart';
import 'package:stillwalks/services/tutorial_service.dart';
import 'package:stillwalks/l10n/app_localizations.dart';
import 'package:stillwalks/l10n/data_localizations.dart';

class InventoryScreen extends StatelessWidget {
  final bool isSelectionMode;
  final String? sanctuaryId;
  final bool isSanctuarySelectionMode;

  const InventoryScreen({
    super.key, 
    this.isSelectionMode = false,
    this.sanctuaryId,
    this.isSanctuarySelectionMode = false,
  });

  @override
  Widget build(BuildContext context) {
    final orbeService = Provider.of<OrbeService>(context);
    final tutorialService = Provider.of<TutorialService>(context);
    
    var availableOrbes = orbeService.getAvailableOrbes();
    // Tutorial: Filter to only show basic orb if in sanctuary step
    if (tutorialService.currentStep == TutorialStep.sanctuary) {
      availableOrbes = availableOrbes.where((o) => o.orbeTypeId == 'orbe_basic').toList();
    }
    
    final inventoryItems = orbeService.inventory;

    // Determinar qué mostrar según el modo
    final showOrbes = !isSanctuarySelectionMode;
    final showItems = !isSelectionMode || isSanctuarySelectionMode;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isSanctuarySelectionMode 
              ? AppLocalizations.of(context)!.selectSanctuary
              : (isSelectionMode ? AppLocalizations.of(context)!.selectOrbTitle : AppLocalizations.of(context)!.yourBag)
        ),
        backgroundColor: Colors.deepPurple,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.deepPurple.withOpacity(0.8), Colors.black],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            // Sección de Orbes (solo si no estamos en modo selección de santuarios)
            if (showOrbes) ...[
              SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  '${AppLocalizations.of(context)!.waitingOrbs} (${availableOrbes.length})',
                  style: const TextStyle(fontSize: 20, fontStyle: FontStyle.italic, color: Colors.purpleAccent),
                ),
              ),
            ),
            if (availableOrbes.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: isSelectionMode
                      ? Card(
                          color: Colors.white.withOpacity(0.05),
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              children: [
                                const Icon(
                                  Icons.shopping_bag_outlined,
                                  size: 64,
                                  color: Colors.white30,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  AppLocalizations.of(context)!.noOrbsAvailable,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  AppLocalizations.of(context)!.noOrbsInstructions,
                                  style: const TextStyle(color: Colors.white54),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 24),
                                ElevatedButton.icon(
                                    onPressed: () async {
                                      await Navigator.pushNamed(context, '/shop');
                                      
                                      if (context.mounted) {
                                        final orbeService = Provider.of<OrbeService>(context, listen: false);
                                        // If still no orbs available after returning from shop, go back to previous screen (Home)
                                        // logic: if user bought something, we stay here to let them select it.
                                        // if user didn't buy anything, we go back to home as if we never entered inventory.
                                        if (orbeService.getAvailableOrbes().isEmpty) {
                                          Navigator.pop(context);
                                        }
                                      }
                                    },
                                  icon: const Icon(Icons.shopping_bag),
                                  label: Text(AppLocalizations.of(context)!.goToShop),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 32,
                                      vertical: 16,
                                    ),
                                    backgroundColor: Colors.deepPurple,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : Center(
                          child: Text(
                            AppLocalizations.of(context)!.noUnassignedOrbs,
                            style: const TextStyle(color: Colors.white54),
                          ),
                        ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final orbe = availableOrbes[index];
                    final type = orbeService.getOrbeType(orbe.orbeTypeId);
                    
                    // Determine color based on rarity/difficulty (same as Shop)
                    Color iconColor = Colors.grey; // Default for basic
                    if (type?.id == 'orbe_advanced') iconColor = Colors.green;
                    else if (type?.id == 'orbe_expert') iconColor = Colors.blue;

                    return Card(
                      color: Colors.white.withOpacity(0.05),
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: Icon(Icons.circle_outlined, color: iconColor, size: 40),
                        title: Text(
                          type != null 
                              ? AppLocalizations.of(context)!.getOrbName(type.id, type.name) 
                              : AppLocalizations.of(context)!.unknownOrb, 
                          style: const TextStyle(fontWeight: FontWeight.bold)
                        ),
                        subtitle: Text(AppLocalizations.of(context)!.stepsRequired(type?.requiredSteps ?? 0)),
                        trailing: isSelectionMode 
                          ? ElevatedButton(
                              onPressed: () async {
                                if (sanctuaryId != null) {
                                  await orbeService.assignOrbeToSanctuary(orbe.id, sanctuaryId!);
                                  
                                  if (context.mounted) {
                                    Navigator.pop(context);
                                  }
                                  
                                  if (tutorialService.currentStep == TutorialStep.sanctuary) {
                                    // Small delay to ensure Home Screen is visible
                                    debugPrint('TUTORIAL_DEBUG: Inventory popping, waiting 300ms...');
                                    await Future.delayed(const Duration(milliseconds: 300));
                                    debugPrint('TUTORIAL_DEBUG: Calling nextStep() from Inventory (Sanctuary -> EnergyIntro)');
                                    await tutorialService.nextStep();
                                  }
                                }
                              },
                              child: Text(AppLocalizations.of(context)!.assign),
                            )
                          : null,
                      ),
                    );
                  },
                  childCount: availableOrbes.length,
                ),
              ),
            ],

            // Sección de Objetos (Temporales, etc.)
            if (showItems) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    '${AppLocalizations.of(context)!.inventoryItemsAndSanctuaries} (${inventoryItems.fold<int>(0, (sum, item) => sum + item.quantity)})',
                    style: const TextStyle(fontSize: 20, fontStyle: FontStyle.italic, color: Colors.cyanAccent),
                  ),
                ),
              ),
              if (inventoryItems.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 32.0),
                    child: Center(child: Text(AppLocalizations.of(context)!.emptyInventoryBag, style: const TextStyle(color: Colors.white54))),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final item = inventoryItems[index];
                      // Reutilizamos la lógica de nombres de santuarios porque estos items SON santuarios en potencia
                      final name = AppLocalizations.of(context)!.getSanctuaryName('', item.typeId, 'Item');
                      final desc = AppLocalizations.of(context)!.getSanctuaryDescription('', item.typeId, '');
                      
                      return Card(
                        color: Colors.white.withOpacity(0.05),
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: ListTile(
                          leading: Icon(
                            InventoryItemTypes.getIcon(item.typeId),
                            color: Colors.cyanAccent,
                            size: 40,
                          ),
                          title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('$desc\n${AppLocalizations.of(context)!.quantityDisplay(item.quantity)}'),
                          isThreeLine: true,
                          trailing: ElevatedButton(
                            onPressed: () async {
                              final success = await orbeService.activateTemporarySanctuary(item.typeId);
                              if (success && context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(AppLocalizations.of(context)!.itemActivated(name))),
                                );
                                
                                // Encontrar el santuario temporal recién creado
                                try {
                                  final tempSanctuary = orbeService.sanctuaries.firstWhere((s) => s.isTemporary);
                                  
                                  // Navegar directamente al selector (reemplazando esta pantalla)
                                  if (context.mounted) {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => InventoryScreen(
                                          isSelectionMode: true,
                                          sanctuaryId: tempSanctuary.id,
                                        )
                                      )
                                    );
                                  }
                                } catch (e) {
                                  // No se encontró santuario temporal, volver normalmente
                                  debugPrint('Error finding temporary sanctuary: $e');
                                  if (context.mounted) {
                                    Navigator.pop(context);
                                  }
                                }
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(AppLocalizations.of(context)!.tempSanctuaryAlreadyActive)),
                                );
                              }
                            },
                            child: Text(AppLocalizations.of(context)!.use),
                          ),
                        ),
                      );
                    },
                    childCount: inventoryItems.length,
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
