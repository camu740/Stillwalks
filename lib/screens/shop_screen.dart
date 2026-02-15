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
import 'package:stillwalks/models/building.dart'; // Added

import 'dart:math'; // Added

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
    final tutorialService = Provider.of<TutorialService>(context, listen: false);
    int startTab = widget.initialTab;
    if (tutorialService.currentStep == TutorialStep.shop) {
      startTab = 2; // Force Orbs
    }
    _tabController = TabController(length: 4, vsync: this, initialIndex: startTab);
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
            isScrollable: false, // Make tabs fill the width
            onTap: (index) {
               if (isTutorialShopStep && index != 2) {
                 _tabController.index = 2; // Force back to Orbs
                 ScaffoldMessenger.of(context).showSnackBar(
                   const SnackBar(content: Text('Sigue el tutorial: Compra un orbe básico.')),
                 );
               }
            },
            tabs: [
              Tab(icon: const Icon(Icons.trending_up), text: AppLocalizations.of(context)!.upgrades),
              Tab(icon: const Icon(Icons.location_city), text: AppLocalizations.of(context)!.buildings),
              Tab(icon: const Icon(Icons.circle), text: AppLocalizations.of(context)!.orbs),
              Tab(icon: const Icon(Icons.fort), text: AppLocalizations.of(context)!.sanctuaries),
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
                      const SizedBox(width: 16),
                       // Show Passive Rate too
                      Text(
                        '(+${esenciaService.passiveEssencePerSecond.toStringAsFixed(1)}/s)',
                         style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
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
                    _buildUpgradesTab(currentLevel),
                    _buildBuildingsTab(currentLevel),
                    _buildOrbesTab(currentLevel, isTutorialShopStep),
                    _buildSanctuariesTab(currentLevel),
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
      children: [
        // Inventory Counter for Orbs
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Bolsa de Orbes',
                style: TextStyle(color: Colors.white70, fontStyle: FontStyle.italic),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: orbeService.currentOrbsCount >= OrbeService.maxOrbs ? Colors.redAccent.withOpacity(0.2) : Colors.white10,
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
        ...allOrbes.map((type) {

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
    ],
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
                  // If not enough essence, show that. Otherwise, it must be the limit.
                  if (currentEsencia < cost) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(AppLocalizations.of(context)!.notEnoughEssence))
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(AppLocalizations.of(context)!.errOrbLimitReached(OrbeService.maxOrbs)))
                    );
                  }
                }
              }
            },

          ),
        ),
      );
  }

  Widget _buildBuildingsTab(int currentLevel) {
    final esenciaService = Provider.of<EsenciaService>(context);
    final currentEsencia = esenciaService.playerState.totalEsencia;
    final progressionService = Provider.of<ProgressionService>(context);
    
    // Lista de edificios
    final buildings = BuildingType.values;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: buildings.map((type) {
         final count = esenciaService.getBuildingCount(type);
         final cost = esenciaService.getBuildingCost(type);
         
         // Level Locks and Limits
         final isUnlocked = progressionService.isItemUnlocked(currentLevel, type.id);
         final limit = progressionService.getUpgradeCap(currentLevel, type: type.id);
         final isLimitReached = count >= limit && isUnlocked;
         
         final canAfford = currentEsencia >= cost && isUnlocked && !isLimitReached;

         // Calculate next required level if limit is reached
         int? nextReqLevel;
         if (isLimitReached) {
           nextReqLevel = progressionService.getLevelRequiredForHigherCap(limit, type: type.id);
         }

         String buttonText = AppLocalizations.of(context)!.buy;
         if (!isUnlocked) {
           buttonText = AppLocalizations.of(context)!.locked;
         } else if (isLimitReached) {
           buttonText = 'Nivel ${nextReqLevel ?? "?"}'; 
         }

         return Padding(
           padding: const EdgeInsets.only(bottom: 12.0),
           child: Container(
             padding: const EdgeInsets.all(16),
             decoration: BoxDecoration(
               color: Colors.white.withOpacity(0.05),
               borderRadius: BorderRadius.circular(16),
               border: Border.all(color: !isUnlocked ? Colors.redAccent.withOpacity(0.3) : Colors.white24),
             ),
             child: Row(
               children: [
                 Container(
                   padding: const EdgeInsets.all(12),
                   decoration: BoxDecoration(
                     color: !isUnlocked ? Colors.grey.withOpacity(0.2) : Colors.blueGrey.withOpacity(0.3),
                     shape: BoxShape.circle,
                   ),
                   child: Icon(
                     !isUnlocked ? Icons.lock : _getBuildingIcon(type), 
                     color: !isUnlocked ? Colors.grey : Colors.cyanAccent, 
                     size: 32
                   ),
                 ),
                 const SizedBox(width: 16),
                 Expanded(
                   child: Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       Row(
                         children: [
                           Text(
                             AppLocalizations.of(context)!.getBuildingName(type),
                             style: TextStyle(
                               color: !isUnlocked ? Colors.grey : Colors.white,
                               fontWeight: FontWeight.bold,
                               fontSize: 16,
                             ),
                           ),
                           const SizedBox(width: 8),
                           if (isUnlocked)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.blueAccent.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Nv. $count',
                                  style: const TextStyle(
                                    fontSize: 12, 
                                    color: Colors.blueAccent,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                         ],
                       ),
                       const SizedBox(height: 4),
                       Text(
                         !isUnlocked 
                          ? AppLocalizations.of(context)!.requiresLevel(progressionService.getRequiredLevelForItem(type.id) ?? 0)
                          : type.description,
                         style: TextStyle(
                           color: !isUnlocked ? Colors.redAccent.withOpacity(0.7) : Colors.white70, 
                           fontSize: 13,
                           fontStyle: !isUnlocked ? FontStyle.italic : null,
                         ),
                       ),
                       const SizedBox(height: 4),
                       if (isUnlocked)
                         Text(
                           '+${type.baseProduction}/s',
                           style: const TextStyle(color: Colors.greenAccent, fontSize: 12),
                         ),
                       const SizedBox(height: 8),
                       if (!isLimitReached && isUnlocked)
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
                 ),
                 ElevatedButton(
                   onPressed: canAfford ? () async {
                      final success = await esenciaService.buyBuilding(type);
                      if (success) {
                         if (context.mounted) {
                           ScaffoldMessenger.of(context).showSnackBar(
                             SnackBar(content: Text(AppLocalizations.of(context)!.purchaseCompleted(
                               AppLocalizations.of(context)!.getBuildingName(type)
                             ))),
                           );
                         }
                      }
                   } : null,
                   style: ElevatedButton.styleFrom(
                     backgroundColor: canAfford ? Colors.cyan : Colors.grey[800],
                     foregroundColor: Colors.white,
                     disabledBackgroundColor: isLimitReached ? Colors.redAccent.withOpacity(0.1) : null,
                     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                   ),
                   child: Text(
                     buttonText,
                     style: TextStyle(
                       fontSize: !isUnlocked || isLimitReached ? 11 : 13,
                       fontWeight: FontWeight.bold,
                     ),
                   ),
                 ),
               ],
             ),
           ),
         );
      }).toList(),
    );
  }

  Widget _buildEnergyStorageUpgrade(EsenciaService esenciaService, double currentEsencia, int currentLevel) {
      final type = UpgradeType.energyStorage;
      final isOwned = esenciaService.hasUpgrade(type);
      
      final progressionService = Provider.of<ProgressionService>(context);
      // Check unlock status using string ID 'energy_storage'
      final isUnlocked = progressionService.isItemUnlocked(currentLevel, 'energy_storage');
      final requiredLevel = progressionService.getRequiredLevelForItem('energy_storage');

      Upgrade upgrade;
      double cost;
      String bonusText = '';
      
      if (isOwned) {
          upgrade = esenciaService.getUpgrade(type)!;
          if (type.costs.isNotEmpty) {
              cost = upgrade.calculateNextLevelCost(); 
          } else {
              // Dynamic calculation
              cost = type.baseCost * pow(1.5, upgrade.currentLevel);
          }
          final nextCapacity = 100 + ((upgrade.currentLevel + 1) * 200);
          bonusText = '${AppLocalizations.of(context)!.capacityLabel}: ${100 + (upgrade.currentLevel * 200)} \u2192 $nextCapacity';
      } else {
          upgrade = Upgrade(
            id: 'temp_${type.name}',
            type: type,
            currentLevel: 0,
            name: getTypeDisplayName(type, context),
            description: getTypeDescription(type, context),
          );
          if (type.costs.isNotEmpty) {
            cost = type.costs[0]; 
          } else {
            cost = type.baseCost;
          }
          bonusText = '${AppLocalizations.of(context)!.unlockCapacityLabel}: 100';
      }

      final upgradeCap = progressionService.getUpgradeCap(currentLevel, type: 'energy_storage');
      final isCappedByLevel = upgrade.currentLevel >= upgradeCap;
      final isMaxLevel = isOwned && upgrade.currentLevel >= type.maxLevel;
      
      int? nextReqLevel; 
      if (isCappedByLevel) {
           nextReqLevel = progressionService.getLevelRequiredForHigherCap(upgradeCap, type: 'energy_storage');
      }

      // Override logic if locked completely
      if (!isUnlocked) {
         // Show compact locked version using _ShopItem
         return Opacity(
           opacity: 0.6,
           child: _ShopItem(
              icon: Icons.battery_charging_full,
              iconColor: Colors.blueAccent,
              title: AppLocalizations.of(context)!.upgradeStorageName, 
              description: "Requiere Nivel $requiredLevel",
              cost: 0,
              currentEsencia: currentEsencia,
              isLocked: true,
              hasBackground: false, // Match other upgrades or keep true? Upgrades usually have background. 
              // Wait, _UpgradeItem doesn't use background for icon. But _ShopItem does if true. 
              // Let's use hasBackground: false to match Upgrades tab style (no circle bg for icon).
              // Or true? Buildings have circle bg. Upgrades don't.
              // Let's use false to be safe or true if needed.
              // _UpgradeItem just has Icon(size: 40). 
              // _ShopItem has leading: hasBackground ? Container(...) : Padding(Icon...).
              // So false is closer to _UpgradeItem style (just padding).
              onPurchase: () {
                 ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Requiere Nivel $requiredLevel")),
                 );
              }
           ),
         );
      }

      return Opacity(
        opacity: isUnlocked ? 1.0 : 0.6,
        child: _UpgradeItem(
          icon: Icons.battery_charging_full,
          iconColor: Colors.blueAccent, 
          bonusTextColor: isUnlocked ? Colors.blueAccent : Colors.redAccent,
          title: AppLocalizations.of(context)!.upgradeStorageName, 
          description: AppLocalizations.of(context)!.upgradeStorageDesc,
          currentLevel: isOwned ? upgrade.currentLevel : 0,
          maxLevel: type.maxLevel,
          cost: (isMaxLevel || !isUnlocked) ? 0 : cost.toDouble(),
          currentEsencia: currentEsencia,
          onPurchase: () async {
              if (isCappedByLevel || isMaxLevel) return;
  
              final success = await esenciaService.purchaseUpgradeByType(type);
              if (success) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(AppLocalizations.of(context)!.upgradeCompleted(
                        AppLocalizations.of(context)!.upgradeStorageName
                    ))),
                  );
                }
              } else {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(AppLocalizations.of(context)!.notEnoughEssence)),
                  );
                }
              }
          },
          // Add required parameters
          bonusText: bonusText,
          isCappedByLevel: isCappedByLevel && isUnlocked, // Only show cap warning if unlocked
          nextRequiredLevel: isUnlocked ? nextReqLevel : null, 
          isMaxLevel: isMaxLevel,
          multiplier: '',
          isLocked: !isUnlocked, // Pass isLocked state (though likely irrelevant now)
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

        const SizedBox(height: 12),

        // Energy Storage Upgrade (Moved here, below Primordial)
        _buildEnergyStorageUpgrade(esenciaService, currentEsencia, currentLevel),
        
        const SizedBox(height: 24),
        const Divider(color: Colors.white24),
        const SizedBox(height: 16),

        // Sección: Santuarios Temporales (Compra)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context)!.temporarySanctuaries,
                style: const TextStyle(
                  color: Colors.cyanAccent,
                  fontStyle: FontStyle.italic,
                  fontSize: 16,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: orbeService.currentTempSanctuariesCount >= OrbeService.maxTempSanctuaries ? Colors.redAccent.withOpacity(0.2) : Colors.white10,
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

        const SizedBox(height: 8),
        _buildLockedSanctuaryItem(InventoryItemTypes.tempSanctuaryFastFlow, 1200.0, currentEsencia, orbeService, esenciaService, progressionService, currentLevel),
        const SizedBox(height: 12),
        _buildLockedSanctuaryItem(InventoryItemTypes.tempSanctuarySymbiosis, 2500.0, currentEsencia, orbeService, esenciaService, progressionService, currentLevel),
        const SizedBox(height: 12),
        _buildLockedSanctuaryItem(InventoryItemTypes.tempSanctuaryQuietude, 5000.0, currentEsencia, orbeService, esenciaService, progressionService, currentLevel),
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
              
              // XP Award: Purchase Sanctuary (+20 XP)
              esenciaService.addXp(20);

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(AppLocalizations.of(context)!.sanctuaryPurchased)),
                );
              }
            } else {
              if (mounted) {
                if (currentEsencia < cost) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(AppLocalizations.of(context)!.notEnoughEssence)),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(AppLocalizations.of(context)!.errInventoryLimitReached(OrbeService.maxTempSanctuaries))),
                  );
                }
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
        
          ...[
            UpgradeType.tapStrength,
            UpgradeType.tapMultiplier,
            UpgradeType.globalMultiplier,
            UpgradeType.offlineEfficiency,
          ].map((type) {
             final isOwned = esenciaService.hasUpgrade(type);
             
             Upgrade upgrade;
             double cost; // Changed to double
             String bonusText = '';
             
             if (isOwned) {
               upgrade = esenciaService.getUpgrade(type)!;
               
               cost = upgrade.calculateNextLevelCost();
               
               if (type == UpgradeType.tapStrength) {
                    bonusText = '${AppLocalizations.of(context)!.strengthLabel}: + ${upgrade.currentLevel} \u2192 ${upgrade.currentLevel + 1}'; 
               } else {
                    bonusText =  AppLocalizations.of(context)!.getUpgradeBonusText(type);
               }
             } else {
               upgrade = Upgrade(
                 id: 'temp_${type.name}',
                 type: type,
                 currentLevel: 0,
                 name: getTypeDisplayName(type, context), // Helper
                 description: getTypeDescription(type, context), // Helper
               );
               // Level 0 -> 1 cost is Base Cost (or costs[0])
               if (type.costs.isNotEmpty) {
                 cost = type.costs[0]; 
               } else {
                 cost = type.baseCost;
               }
               
               bonusText = AppLocalizations.of(context)!.unlockLevel1;
             }

            // Check Upgrade Cap with Type
            final progressionService = Provider.of<ProgressionService>(context);
            String upgradeTypeId = '';
            if (type == UpgradeType.idleMultiplier) upgradeTypeId = 'idle_multiplier';
            else if (type == UpgradeType.energyStorage) upgradeTypeId = 'energy_storage';
            else if (type == UpgradeType.tapStrength) upgradeTypeId = 'tap_strength';
            else if (type == UpgradeType.tapMultiplier) upgradeTypeId = 'tap_multiplier';
            else if (type == UpgradeType.globalMultiplier) upgradeTypeId = 'global_multiplier';
            else if (type == UpgradeType.offlineEfficiency) upgradeTypeId = 'offline_efficiency';

            
            int upgradeCap = 999;
            if (upgradeTypeId.isNotEmpty) {
               upgradeCap = progressionService.getUpgradeCap(currentLevel, type: upgradeTypeId);
            }
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

  // Helpers for text (since L10n might not be updated yet)
  String getTypeDisplayName(UpgradeType type, BuildContext context) {
      // Try L10n first or fallback
      try {
        return AppLocalizations.of(context)!.getUpgradeName(type);
      } catch (_) {
        switch(type) {
            case UpgradeType.tapStrength: return 'Fuerza de Tap';
            case UpgradeType.tapMultiplier: return 'Ritmo Interior';
            case UpgradeType.globalMultiplier: return 'Flujo Esencial';
            case UpgradeType.offlineEfficiency: return 'Eco Persistente';
            default: return type.name;
        }
      }
  }

  String getTypeDescription(UpgradeType type, BuildContext context) {
      try {
        return AppLocalizations.of(context)!.getUpgradeDescription(type);
      } catch (_) {
         switch(type) {
            case UpgradeType.tapStrength: return '+1 Esencia por tap';
            case UpgradeType.tapMultiplier: return '+10% fuerza de tap';
            case UpgradeType.globalMultiplier: return '+20% producción global';
            case UpgradeType.offlineEfficiency: return 'Mejora producción offline';
            default: return '';
        }
      }
  }

  IconData _getUpgradeIcon(UpgradeType type) {
    if (type == UpgradeType.idleMultiplier) return Icons.schedule;
    if (type == UpgradeType.energyStorage) return Icons.battery_charging_full;
    if (type == UpgradeType.tapStrength) return Icons.touch_app;
    if (type == UpgradeType.tapMultiplier) return Icons.speed;
    if (type == UpgradeType.globalMultiplier) return Icons.public;
    if (type == UpgradeType.offlineEfficiency) return Icons.bedtime;
    return Icons.star;
  }

  IconData _getBuildingIcon(BuildingType type) {
    switch (type) {
      case BuildingType.recolector:
        return Icons.eco;
      case BuildingType.mina:
        return Icons.landscape;
      case BuildingType.cantera:
        return Icons.construction;
      case BuildingType.yacimiento:
        return Icons.layers;
      case BuildingType.fabrica:
        return Icons.factory;
    }
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
  final bool isMaxLevel;
  final Color? iconColor; 
  final Color? bonusTextColor;
  final bool isLocked; // Added

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
    this.isMaxLevel = false,
    this.iconColor,
    this.bonusTextColor,
    this.isLocked = false, // Added
  });

  @override
  Widget build(BuildContext context) {
    
    final canAfford = currentEsencia >= cost && !isMaxLevel;
    // Determine effective icon and color
    final effectiveIcon = isLocked ? Icons.lock : icon;
    final effectiveIconColor = isLocked ? Colors.grey : (iconColor ?? Colors.greenAccent);

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
              Icon(effectiveIcon, size: 40, color: effectiveIconColor),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isLocked ? Colors.grey : Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (!isLocked)
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
                      style: TextStyle(fontSize: 14, color: isLocked ? Colors.redAccent.withOpacity(0.8) : Colors.white70),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      bonusText,
                      style: TextStyle(
                        fontSize: 13, 
                        color: isLocked ? Colors.redAccent : (bonusTextColor ?? Colors.greenAccent), 
                        fontWeight: FontWeight.bold
                      ),
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
              if (!isMaxLevel && !isLocked)
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
              else if (isLocked)
                 // Keep empty or show 'Locked'? Design choice: Empty left side is fine.
                 const SizedBox.shrink()
              else
                const Text(
                  'Nivel máximo alcanzado',
                  style: TextStyle(color: Colors.amber, fontSize: 13, fontWeight: FontWeight.bold),
                ),
              if (!isMaxLevel || isLocked)
                ElevatedButton(
                  onPressed: isLocked ? onPurchase : (isCappedByLevel ? null : (canAfford ? onPurchase : null)), 
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isLocked ? Colors.grey : (isCappedByLevel ? Colors.grey.withOpacity(0.5) : Colors.greenAccent.withOpacity(0.8)),
                    foregroundColor: isLocked ? Colors.white : (isCappedByLevel ? Colors.white70 : Colors.black),
                    disabledBackgroundColor: Colors.grey.withOpacity(0.3),
                  ),
                  child: Text(
                    isLocked ? (AppLocalizations.of(context)?.locked ?? 'Bloqueado') :
                    (isCappedByLevel 
                      ? 'Nivel ${nextRequiredLevel ?? "?"}' 
                      : AppLocalizations.of(context)!.upgrade)
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
