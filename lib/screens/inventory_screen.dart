import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stillwalks/services/orbe_service.dart';
import 'package:stillwalks/models/orbe.dart';
import 'package:stillwalks/models/inventory_item.dart';
import 'package:stillwalks/services/tutorial_service.dart';
import 'package:stillwalks/screens/shop_screen.dart';
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
    Widget body;
    if (isSelectionMode) {
      // Modo selección de orbe: Solo mostrar lista de orbes
      body = _buildOrbesTab(context, orbeService, availableOrbes);
    } else if (isSanctuarySelectionMode) {
      // Modo selección de santuario (activar): Solo mostrar lista de santuarios
      body = _buildSantuariosTab(context, orbeService, inventoryItems);
    } else {
      // Modo normal: Tabs
      return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: Text(AppLocalizations.of(context)!.yourBag),
            backgroundColor: Colors.deepPurple.withOpacity(0.8),
            bottom: TabBar(
              tabs: [
                Tab(icon: const Icon(Icons.circle), text: AppLocalizations.of(context)!.orbs),
                Tab(icon: const Icon(Icons.auto_awesome), text: AppLocalizations.of(context)!.sanctuaries),
              ],
            ),
          ),
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.deepPurple.withOpacity(0.8), Colors.black],
              ),
            ),
            child: TabBarView(
              children: [
                _buildOrbesTab(context, orbeService, availableOrbes),
                _buildSantuariosTab(context, orbeService, inventoryItems),
              ],
            ),
          ),
        ),
      );
    }

    // Scaffold sin tabs para modos de selección
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isSanctuarySelectionMode 
              ? AppLocalizations.of(context)!.selectSanctuary
              : (isSelectionMode ? AppLocalizations.of(context)!.selectOrbTitle : AppLocalizations.of(context)!.yourBag)
        ),
        backgroundColor: Colors.deepPurple.withOpacity(0.8),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.deepPurple.withOpacity(0.8), Colors.black],
          ),
        ),
        child: body,
      ),
    );
  }

  Widget _buildOrbesTab(BuildContext context, OrbeService orbeService, List<Orbe> availableOrbes) {
    if (availableOrbes.isEmpty) {
      return _buildEmptyState(
        context,
        AppLocalizations.of(context)!.noOrbsAvailable,
        AppLocalizations.of(context)!.noOrbsInstructions,
        Icons.shopping_bag_outlined,
        2, // Orbs Tab
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Bolsa Capacity Counter
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context)!.bagCapacity,
                style: const TextStyle(color: Colors.white70, fontStyle: FontStyle.italic),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: orbeService.currentOrbsCount >= OrbeService.maxOrbs ? Colors.redAccent.withValues(alpha: 0.2) : Colors.white10,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: orbeService.currentOrbsCount >= OrbeService.maxOrbs ? Colors.redAccent : Colors.white24),
                ),
                child: Text(
                  '${orbeService.currentOrbsCount} / ${OrbeService.maxOrbs}',
                  style: TextStyle(
                    color: orbeService.currentOrbsCount >= OrbeService.maxOrbs ? Colors.redAccent : Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),

        ...availableOrbes.map((orbe) {
          final type = orbeService.getOrbeType(orbe.orbeTypeId);
          
          Color iconColor = Colors.grey;
          if (type?.id == 'orbe_advanced') {
            iconColor = Colors.green;
          } else if (type?.id == 'orbe_expert') {
            iconColor = Colors.blue;
          }

          return Card(
            color: Colors.white.withValues(alpha: 0.05),
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: Icon(Icons.circle_outlined, color: iconColor, size: 40),
              title: Text(
                type != null 
                    ? AppLocalizations.of(context)!.getOrbName(type.id, type.name) 
                    : AppLocalizations.of(context)!.unknownOrb, 
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)
              ),
              subtitle: Text(
                AppLocalizations.of(context)!.stepsRequired(type?.requiredSteps ?? 0),
                style: const TextStyle(color: Colors.white70),
              ),
              trailing: isSelectionMode 
                ? ElevatedButton(
                    onPressed: () async {
                      if (sanctuaryId != null) {
                        final tutorialService = Provider.of<TutorialService>(context, listen: false);
                        await orbeService.assignOrbeToSanctuary(orbe.id, sanctuaryId!);
                        
                        if (context.mounted) {
                          Navigator.pop(context);
                        }
                        
                        if (tutorialService.currentStep == TutorialStep.sanctuary) {
                          await Future.delayed(const Duration(milliseconds: 300));
                          await tutorialService.nextStep();
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
                    child: Text(AppLocalizations.of(context)!.assign),
                  )
                : null,
            ),
          );
        }).toList(),
      ],
    );

  }

  Widget _buildSantuariosTab(BuildContext context, OrbeService orbeService, List<InventoryItem> inventoryItems) {
    if (inventoryItems.isEmpty) {
      return _buildEmptyState(
        context,
        AppLocalizations.of(context)!.noItemsAvailable,
        AppLocalizations.of(context)!.noItemsInstructions,
        Icons.grid_view_outlined,
        3, // Sanctuaries Tab
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Bolsa Capacity Counter
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context)!.bagCapacity,
                style: const TextStyle(color: Colors.white70, fontStyle: FontStyle.italic),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: orbeService.currentTempSanctuariesCount >= OrbeService.maxTempSanctuaries ? Colors.redAccent.withValues(alpha: 0.2) : Colors.white10,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: orbeService.currentTempSanctuariesCount >= OrbeService.maxTempSanctuaries ? Colors.redAccent : Colors.white24),
                ),
                child: Text(
                  '${orbeService.currentTempSanctuariesCount} / ${OrbeService.maxTempSanctuaries}',
                  style: TextStyle(
                    color: orbeService.currentTempSanctuariesCount >= OrbeService.maxTempSanctuaries ? Colors.redAccent : Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),

        ...inventoryItems.map((item) {
          final name = AppLocalizations.of(context)!.getSanctuaryName('', item.typeId, 'Item');
          final desc = AppLocalizations.of(context)!.getSanctuaryDescription('', item.typeId, '');
          
          return Card(
            color: Colors.white.withValues(alpha: 0.05),
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: Icon(
                InventoryItemTypes.getIcon(item.typeId),
                color: Colors.cyanAccent,
                size: 40,
              ),
              title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              subtitle: Text(
                '$desc\n${AppLocalizations.of(context)!.quantityDisplay(item.quantity)}',
                style: const TextStyle(color: Colors.white70),
              ),
              isThreeLine: true,
              trailing: ElevatedButton(
                onPressed: () async {
                  final success = await orbeService.activateTemporarySanctuary(item.typeId);
                  if (success && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(AppLocalizations.of(context)!.itemActivated(name))),
                    );
                    
                    try {
                      final tempSanctuary = orbeService.sanctuaries.firstWhere((s) => s.isTemporary);
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
                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                    }
                  } else if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(AppLocalizations.of(context)!.tempSanctuaryAlreadyActive)),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.cyan[700]),
                child: Text(AppLocalizations.of(context)!.use),
              ),
            ),
          );
        }).toList(),
      ],
    );

  }

  Widget _buildEmptyState(BuildContext context, String title, String subtitle, IconData icon, int shopTab) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: Colors.white24),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              subtitle,
              style: const TextStyle(color: Colors.white54),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ShopScreen(initialTab: shopTab)),
                );
              },
              icon: const Icon(Icons.shopping_bag),
              label: Text(AppLocalizations.of(context)!.goToShop),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                backgroundColor: Colors.deepPurple,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
