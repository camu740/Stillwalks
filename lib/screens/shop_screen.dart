import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stillwalks/services/esencia_service.dart';
import 'package:stillwalks/services/orbe_service.dart';
import 'package:stillwalks/models/upgrade.dart';
import 'package:stillwalks/models/orbe.dart';
import 'package:stillwalks/l10n/app_localizations.dart';
import 'package:stillwalks/l10n/data_localizations.dart';
import 'package:stillwalks/models/sanctuary.dart';
import 'package:stillwalks/models/inventory_item.dart';
import 'package:stillwalks/services/progression_service.dart';
import 'package:stillwalks/services/tutorial_service.dart';

/// Pantalla de la tienda para comprar Orbes y mejoras
class ShopScreen extends StatefulWidget {
  final int initialTab;
  
  const ShopScreen({super.key, this.initialTab = 0});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: widget.initialTab);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Escuchar servicios
    final esenciaService = Provider.of<EsenciaService>(context);
    final orbeService = Provider.of<OrbeService>(context);
    final progressionService = Provider.of<ProgressionService>(context); // Injected
    final tutorialService = Provider.of<TutorialService>(context);       // Injected
    
    final currentEsencia = esenciaService.playerState.totalEsencia;
    final currentLevel = esenciaService.playerState.explorerLevel;

    // TUTORIAL LOCK: If in shop step, force tab 0 (Orbs) and disable others.
    // We can just ignore tap on other tabs or hide them? 
    // Better to Disable interaction if strict.
    final bool isTutorialShopStep = tutorialService.currentStep == TutorialStep.shop;

    return PopScope(
      canPop: !isTutorialShopStep,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.tutorialBlockShop)),
        );
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.shop),
          backgroundColor: Colors.deepPurple.withOpacity(0.8),
          bottom: TabBar(
            controller: _tabController,
            onTap: (index) {
               if (isTutorialShopStep && index != 0) {
                 _tabController.index = 0; // Force back to Orbs
                 ScaffoldMessenger.of(context).showSnackBar(
                   const SnackBar(content: Text('Sigue el tutorial: Compra un orbe básico.')),
                 );
               }
            },
            tabs: [
              Tab(icon: const Icon(Icons.circle), text: AppLocalizations.of(context)!.orbs),
              Tab(icon: const Icon(Icons.auto_awesome), text: AppLocalizations.of(context)!.sanctuaries),
              Tab(icon: const Icon(Icons.trending_up), text: AppLocalizations.of(context)!.upgrades),
            ],
          ),
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.deepPurple.withOpacity(0.8),
                Colors.black,
              ],
            ),
          ),
          child: Column(
            children: [
              // Balance de Esencia
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.amberAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.amberAccent.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.auto_awesome, color: Colors.amberAccent),
                      const SizedBox(width: 8),
                      Text(
                        '${AppLocalizations.of(context)!.essence}: ${currentEsencia.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.amberAccent,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
  
              // Contenido con tabs
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  physics: isTutorialShopStep ? const NeverScrollableScrollPhysics() : null, // Disable swipe
                  children: [
                     _buildOrbesTab(currentLevel, isTutorialShopStep),
                     _buildSanctuariesTab(currentLevel),
                     _buildUpgradesTab(currentLevel),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrbesTab(int currentLevel, bool isTutorialMode) {
    final orbeService = Provider.of<OrbeService>(context);
    final esenciaService = Provider.of<EsenciaService>(context);
    final currentEsencia = esenciaService.playerState.totalEsencia;
    final progressionService = Provider.of<ProgressionService>(context);
    final tutorialService = Provider.of<TutorialService>(context); // Added retrieval

    // Get all orb types and sort by required steps
    final allOrbes = orbeService.orbeTypes;
    allOrbes.sort((a, b) => a.requiredSteps.compareTo(b.requiredSteps));

    return ListView(
      padding: const EdgeInsets.all(16),
      children: allOrbes.map((type) {
         // LOCK LOGIC
         bool isLockedByLevel = !progressionService.isItemUnlocked(currentLevel, type.id);
         bool isLockedByTutorial = isTutorialMode && type.id != 'orbe_basic';
         
         String? lockReason;
         if (isLockedByTutorial) {
           lockReason = "Bloqueado por Tutorial";
         } else if (isLockedByLevel) {
           final reqLevel = progressionService.getRequiredLevelForItem(type.id);
           lockReason = "Requiere Nivel $reqLevel";
         }

         return _buildOrbItem(type, currentEsencia, orbeService, esenciaService, lockReason, tutorialService);
      }).toList(),
    );
  }

  Widget _buildOrbItem(OrbeType type, double currentEsencia, OrbeService orbeService, EsenciaService esenciaService, String? lockReason, TutorialService tutorialService) {
      final cost = orbeService.getOrbeCost(type.id);
      
      // Determine color based on rarity/difficulty
      Color iconColor = Colors.grey; // Default for basic
      if (type.id == 'orbe_advanced') iconColor = Colors.green;
      else if (type.id == 'orbe_expert') iconColor = Colors.blue;

      final isLocked = lockReason != null;

      return Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: Opacity( // Dim if locked
          opacity: isLocked ? 0.6 : 1.0,
          child: _ShopItem(
            icon: Icons.circle_outlined,
            iconColor: iconColor,
            title: AppLocalizations.of(context)!.getOrbName(type.id, type.name),
            description: isLocked ? lockReason : AppLocalizations.of(context)!.getOrbDescription(type.id, type.description),
            cost: cost,
            currentEsencia: currentEsencia,
            isLocked: isLocked, // Pass lock state
            onPurchase: isLocked ? () {
               // Show reason if clicked while locked
               ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(lockReason ?? "Bloqueado")),
               );
            } : () async {
              final result = await orbeService.purchaseOrbe(type.id, currentEsencia);
              if (result != null) {
                await esenciaService.spendEsencia(cost);
                
                // ADVANCE TUTORIAL if applicable
                if (type.id == 'orbe_basic' && tutorialService.currentStep == TutorialStep.shop) {
                  await tutorialService.nextStep();
                  debugPrint('🎓 ShopScreen: Advanced tutorial to Sanctuary step');
                  
                  if (mounted) {
                    Navigator.of(context).pop(); // Return to Home
                  }
                  return; // Exit function to avoid showing purchase snackbar which might be confusing during transition
                }

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(AppLocalizations.of(context)!.orbPurchased))
                  );
                }
              } else {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(AppLocalizations.of(context)!.notEnoughEssence))
                  );
                }
              }
            },
          ),
        ),
      );
  }

  Widget _buildSanctuariesTab(int currentLevel) {
    final orbeService = Provider.of<OrbeService>(context);
    final esenciaService = Provider.of<EsenciaService>(context);
    final progressionService = Provider.of<ProgressionService>(context);
    final currentEsencia = esenciaService.playerState.totalEsencia;
    
    // Obtener santuarios permanentes
    final permanentSanctuaries = orbeService.sanctuaries.where((s) => !s.isTemporary).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Sección: Santuarios Permanentes (Mejoras)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              const Icon(Icons.fort, color: Colors.purpleAccent, size: 20),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context)!.permanentSanctuaryUpgrades,
                style: const TextStyle(
                  color: Colors.purpleAccent,
                  fontStyle: FontStyle.italic,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        
        ...permanentSanctuaries.map((sanctuary) {
          final cost = Sanctuary.getUpgradeCost(sanctuary.speedUpgradeLevel);
          final currentLevelVal = sanctuary.speedUpgradeLevel;
          final reductionPercent = (currentLevelVal * 2);
          
          // Check Upgrade Cap
          final upgradeCap = progressionService.getUpgradeCap(currentLevel, type: 'sanctuary');
          final isCappedByLevel = currentLevelVal >= upgradeCap;
          final nextReqLevel = isCappedByLevel ? progressionService.getLevelRequiredForHigherCap(upgradeCap, type: 'sanctuary') : null;
          
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _SanctuaryUpgradeItem(
              title: AppLocalizations.of(context)!.getSanctuaryName(sanctuary.id, sanctuary.typeId, sanctuary.name),
              description: AppLocalizations.of(context)!.getSanctuaryDescription(sanctuary.id, sanctuary.typeId, sanctuary.description),
              currentLevel: currentLevelVal,
              maxLevel: 15,
              cost: cost,
              currentEsencia: currentEsencia,
              reductionPercent: reductionPercent,
              isCappedByLevel: isCappedByLevel,
              nextRequiredLevel: nextReqLevel,
              onPurchase: () async {
                if (isCappedByLevel) return; // Should be disabled

                final success = await orbeService.upgradeSanctuarySpeed(sanctuary.id, currentEsencia);
                if (success) {
                  await esenciaService.spendEsencia(cost);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(AppLocalizations.of(context)!.sanctuaryUpgraded(
                        AppLocalizations.of(context)!.getSanctuaryName(sanctuary.id, sanctuary.typeId, sanctuary.name),
                        currentLevelVal + 1
                      ))),
                    );
                  }
                } else {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(AppLocalizations.of(context)!.notEnoughEssence)),
                    );
                  }
                }
              },
            ),
          );
        }).toList(),
        
        const SizedBox(height: 24),
        const Divider(color: Colors.white24),
        const SizedBox(height: 16),

        // Sección: Santuarios Temporales (Compra)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            AppLocalizations.of(context)!.temporarySanctuaries,
            style: const TextStyle(
              color: Colors.cyanAccent,
              fontStyle: FontStyle.italic,
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(height: 8),
        _buildLockedSanctuaryItem(InventoryItemTypes.tempSanctuaryFastFlow, 1200.0, currentEsencia, orbeService, esenciaService, progressionService, currentLevel),
        const SizedBox(height: 12),
        _buildLockedSanctuaryItem(InventoryItemTypes.tempSanctuarySymbiosis, 2000.0, currentEsencia, orbeService, esenciaService, progressionService, currentLevel),
        const SizedBox(height: 12),
        _buildLockedSanctuaryItem(InventoryItemTypes.tempSanctuaryQuietude, 4000.0, currentEsencia, orbeService, esenciaService, progressionService, currentLevel),
      ],
    );
  }
  
  // Helper for Sanctuary with Locks
  Widget _buildLockedSanctuaryItem(String typeId, double cost, double currentEsencia, OrbeService orbeService, EsenciaService esenciaService, ProgressionService progressionService, int currentLevel) {
      final isLocked = !progressionService.isItemUnlocked(currentLevel, typeId);
      final reqLevel = progressionService.getRequiredLevelForItem(typeId);
      
      String description = AppLocalizations.of(context)!.getSanctuaryDescription('', typeId, '');
      if (isLocked) description = "Requiere Nivel $reqLevel";
      
      IconData icon = InventoryItemTypes.getIcon(typeId);
      if (typeId == InventoryItemTypes.tempSanctuaryQuietude) icon = Icons.spa;

      return Opacity(
        opacity: isLocked ? 0.6 : 1.0,
        child: _ShopItem(
          icon: icon,
          iconColor: Colors.tealAccent,
          title: AppLocalizations.of(context)!.getSanctuaryName('', typeId, InventoryItemTypes.getShortName(typeId)),
          description: description,
          cost: cost,
          currentEsencia: currentEsencia,
          isLocked: isLocked,
          hasBackground: false, // No orb background for sanctuaries
          onPurchase: isLocked ? () {
             ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Requiere Nivel $reqLevel")),
             );
          } : () async {
            final success = await orbeService.purchaseInventoryItem(
              typeId,
              cost,
              currentEsencia,
            );
            if (success) {
              await esenciaService.spendEsencia(cost);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(AppLocalizations.of(context)!.sanctuaryPurchased)),
                );
              }
            }
          },
        ),
      );
  }

  Widget _buildUpgradesTab(int currentLevel) {
    final esenciaService = Provider.of<EsenciaService>(context);
    final currentEsencia = esenciaService.playerState.totalEsencia;
    
    // Obtener mejoras globales
    final globalUpgrades = esenciaService.upgrades;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Sección: Mejoras Globales
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              const Icon(Icons.trending_up, color: Colors.greenAccent, size: 20),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context)!.globalUpgrades,
                style: const TextStyle(
                  color: Colors.greenAccent,
                  fontStyle: FontStyle.italic,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        
        // Mostrar mejoras globales
        if (false) // Disabled loading check since we build from types
          const Center(child: Text('...'))
        else
          ...[UpgradeType.idleMultiplier, UpgradeType.energyStorage].map((type) {
             final isOwned = esenciaService.hasUpgrade(type);
             
             Upgrade upgrade;
             int cost;
             String bonusText = '';
             
             if (isOwned) {
               upgrade = esenciaService.getUpgrade(type)!;
               // Cost for NEXT level (from currentLevel + 1)
               if (upgrade.currentLevel >= type.maxLevel) {
                 cost = 0; 
               } else {
                 final nextLevelIndex = upgrade.currentLevel + 1;
                 if (nextLevelIndex < type.costs.length) {
                    cost = type.costs[nextLevelIndex].toInt();
                 } else {
                    cost = 0; // Should not happen if maxLevel matches costs length
                 }
               }
               
               if (type == UpgradeType.energyStorage) {
                 final nextCapacity = 100 + ((upgrade.currentLevel + 1) * 200);
                 bonusText = 'Capacidad: ${100 + (upgrade.currentLevel * 200)} \u2192 $nextCapacity';
               } else {
                 bonusText =  AppLocalizations.of(context)!.getUpgradeBonusText(type);
               }
             } else {
                // Unowned ... (rest same) -> NO, need to copy rest or use strict replacement range.
                // Since I am replacing the `if (isOwned)` block essentially.
                // I'll rewrite the whole block from `if (isOwned)` down to `else` closing brace.
                
               upgrade = Upgrade(
                 id: 'temp_${type.name}',
                 type: type,
                 currentLevel: 0,
                 name: AppLocalizations.of(context)!.getUpgradeName(type),
                 description: AppLocalizations.of(context)!.getUpgradeDescription(type),
               );
               cost = type.costs[0].toInt(); // Unlock cost
               
               if (type == UpgradeType.energyStorage) {
                 bonusText = 'Desbloquea capacidad: 100';
               } else {
                 bonusText = 'Desbloquear mejora';
               }
             }

            // Check Upgrade Cap with Type
            final progressionService = Provider.of<ProgressionService>(context);
            String upgradeTypeId = type == UpgradeType.idleMultiplier ? 'idle_multiplier' : 'energy_storage';
            
            final upgradeCap = progressionService.getUpgradeCap(currentLevel, type: upgradeTypeId);
            // If unowned (level 0), and cap is 0, then 0 >= 0 is true -> Capped.
            // If cap is 2 (level 4 reached), then 0 >= 2 is false -> Not capped.
            final isCappedByLevel = upgrade.currentLevel >= upgradeCap;
            final isMaxLevel = isOwned && upgrade.currentLevel >= type.maxLevel;
            
            // Next required level logic
            int? nextReqLevel; 
            if (isCappedByLevel) {
                 nextReqLevel = progressionService.getLevelRequiredForHigherCap(upgradeCap, type: upgradeTypeId);
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _UpgradeItem(
                icon: _getUpgradeIcon(type),
                title: AppLocalizations.of(context)!.getUpgradeName(type),
                description: AppLocalizations.of(context)!.getUpgradeDescription(type),
                currentLevel: isOwned ? upgrade.currentLevel : 0,
                maxLevel: type.maxLevel,
                cost: isMaxLevel ? 0 : cost.toDouble(),
                currentEsencia: currentEsencia,
                multiplier: '', // Not used anymore as separate text
                bonusText: bonusText,
                isCappedByLevel: isCappedByLevel,
                nextRequiredLevel: nextReqLevel,
                isMaxLevel: isMaxLevel,
                onPurchase: () async {
                  if (isCappedByLevel || isMaxLevel) return;

                  final success = await esenciaService.purchaseUpgradeByType(type);
                  if (success) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(AppLocalizations.of(context)!.upgradeCompleted(
                           AppLocalizations.of(context)!.getUpgradeName(type)
                        ))),
                      );
                    }
                  } else {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(AppLocalizations.of(context)!.notEnoughEssence)),
                      );
                    }
                  }
                },
              ),
            );
          }).toList(),
      ],
    );
  }

  IconData _getUpgradeIcon(UpgradeType type) {
    if (type == UpgradeType.idleMultiplier) return Icons.schedule;
    if (type == UpgradeType.energyStorage) return Icons.battery_charging_full;
    return Icons.star;
  }


}

class _ShopItem extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final String title;
  final String description;
  final double cost;
  final double currentEsencia;
  final Function() onPurchase;
  final bool isLocked;
  final bool hasBackground; // Added parameter

  const _ShopItem({
    required this.icon,
    this.iconColor,
    required this.title,
    required this.description,
    required this.cost,
    required this.currentEsencia,
    required this.onPurchase,
    this.isLocked = false,
    this.hasBackground = true, // Default to true (orb style)
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white24),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: hasBackground 
        ? Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isLocked ? Colors.grey.withOpacity(0.2) : iconColor!.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isLocked ? Icons.lock : icon, 
              color: isLocked ? Colors.grey : iconColor, 
              size: 32
            ),
          )
        : Padding(
            padding: const EdgeInsets.all(12.0), // Keep spacing consistent
            child: Icon(
              isLocked ? Icons.lock : icon, 
              color: isLocked ? Colors.grey : iconColor, 
              size: 32
            ),
          ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(color: isLocked ? Colors.redAccent : Colors.white70),
            ),
            const SizedBox(height: 8),
            if (!isLocked) // Only show cost if unlocked (or show regardless? Design choice: user code had cost. Let's show cost but greyed out?)
            // Actually, if locked, we might want to hide cost or show it in red?
            // User requested "bloqueado", usually implies not purchasable.
            // Let's keep cost visible but button handles logic.
            Row(
              children: [
                const Icon(Icons.auto_awesome, color: Colors.amberAccent, size: 16),
                const SizedBox(width: 4),
                Text(
                  cost.toStringAsFixed(0),
                  style: const TextStyle(
                    color: Colors.amberAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: ElevatedButton(
          onPressed: isLocked ? onPurchase : (currentEsencia >= cost ? onPurchase : null),
          style: ElevatedButton.styleFrom(
            backgroundColor: isLocked ? Colors.grey : (currentEsencia >= cost ? Colors.deepPurple : Colors.grey[800]),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(isLocked ? 'Bloqueado' : AppLocalizations.of(context)!.buy),
        ),
      ),
    );
  }
}

class _UpgradeItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final int currentLevel;
  final int maxLevel;
  final double cost;
  final double currentEsencia;
  final String multiplier;
  final String bonusText;
  final VoidCallback onPurchase;
  final bool isCappedByLevel;
  final int? nextRequiredLevel;
  final bool isMaxLevel; // Added field

  const _UpgradeItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.currentLevel,
    required this.maxLevel,
    required this.cost,
    required this.currentEsencia,
    required this.multiplier,
    required this.bonusText,
    required this.onPurchase,
    this.isCappedByLevel = false,
    this.nextRequiredLevel,
    this.isMaxLevel = false, // Added parameter
  });

  @override
  Widget build(BuildContext context) {
    
    final canAfford = currentEsencia >= cost && !isMaxLevel;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, size: 40, color: Colors.greenAccent),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: isMaxLevel ? Colors.amber.withOpacity(0.2) : Colors.blueAccent.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            isMaxLevel ? 'MAX' : 'Nv. $currentLevel',
                            style: TextStyle(
                              fontSize: 12, 
                              color: isMaxLevel ? Colors.amber : Colors.blueAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(fontSize: 14, color: Colors.white70),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      bonusText,
                      style: const TextStyle(fontSize: 13, color: Colors.greenAccent, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      multiplier,
                      style: const TextStyle(fontSize: 11, color: Colors.white54),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (!isMaxLevel)
                Row(
                  children: [
                    const Icon(Icons.auto_awesome, size: 20, color: Colors.amberAccent),
                    const SizedBox(width: 4),
                    Text(
                      cost.toStringAsFixed(0),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.amberAccent,
                      ),
                    ),
                  ],
                )
              else
                const Text(
                  'Nivel máximo alcanzado',
                  style: TextStyle(color: Colors.amber, fontSize: 13, fontWeight: FontWeight.bold),
                ),
              if (!isMaxLevel)
                ElevatedButton(
                  onPressed: isCappedByLevel ? null : (canAfford ? onPurchase : null), // Disable if capped
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isCappedByLevel ? Colors.grey.withOpacity(0.5) : Colors.greenAccent.withOpacity(0.8),
                    foregroundColor: isCappedByLevel ? Colors.white70 : Colors.black,
                    disabledBackgroundColor: Colors.grey.withOpacity(0.3),
                  ),
                  child: Text(
                    isCappedByLevel 
                      ? 'Nivel ${nextRequiredLevel ?? "?"}' 
                      : AppLocalizations.of(context)!.upgrade
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SanctuaryUpgradeItem extends StatelessWidget {
  final String title;
  final String description;
  final int currentLevel;
  final int maxLevel;
  final double cost;
  final double currentEsencia;
  final int reductionPercent;
  final VoidCallback onPurchase;
  final bool isCappedByLevel;
  final int? nextRequiredLevel; // Added

  const _SanctuaryUpgradeItem({
    required this.title,
    required this.description,
    required this.currentLevel,
    required this.maxLevel,
    required this.cost,
    required this.currentEsencia,
    required this.reductionPercent,
    required this.onPurchase,
    this.isCappedByLevel = false,
    this.nextRequiredLevel, // Added
  });

  @override
  Widget build(BuildContext context) {
    final isMaxLevel = currentLevel >= maxLevel;
    final canAfford = currentEsencia >= cost && !isMaxLevel;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.fort, size: 40, color: Colors.purpleAccent),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: isMaxLevel 
                                ? Colors.amber.withOpacity(0.2)
                                : Colors.purpleAccent.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            isMaxLevel ? 'MAX' : 'Nv. $currentLevel',
                            style: TextStyle(
                              fontSize: 12,
                              color: isMaxLevel ? Colors.amber : Colors.purpleAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(fontSize: 14, color: Colors.white70),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Bono actual: -$reductionPercent%',
                      style: const TextStyle(fontSize: 13, color: Colors.purpleAccent, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      '-2% pasos a realizar / nivel',
                      style: TextStyle(fontSize: 11, color: Colors.white54),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (!isMaxLevel)
                Row(
                  children: [
                    const Icon(Icons.auto_awesome, size: 20, color: Colors.amberAccent),
                    const SizedBox(width: 4),
                    Text(
                      cost.toStringAsFixed(0),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.amberAccent,
                      ),
                    ),
                  ],
                )
              else
                const Text(
                  'Nivel máximo alcanzado',
                  style: TextStyle(color: Colors.amber, fontSize: 13, fontWeight: FontWeight.bold),
                ),
              if (!isMaxLevel)
                ElevatedButton(
                  onPressed: isCappedByLevel ? null : (canAfford ? onPurchase : null), // Disable if capped
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isCappedByLevel ? Colors.grey.withOpacity(0.5) : Colors.purpleAccent.withOpacity(0.8),
                    foregroundColor: isCappedByLevel ? Colors.white70 : Colors.white,
                    disabledBackgroundColor: Colors.grey.withOpacity(0.3),
                  ),
                  child: Text(
                    isCappedByLevel 
                      ? 'Nivel ${nextRequiredLevel ?? "?"}' 
                      : AppLocalizations.of(context)!.upgrade
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
