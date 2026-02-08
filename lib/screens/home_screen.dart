import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:stillwalks/services/esencia_service.dart';
import 'package:stillwalks/services/orbe_service.dart';
import 'package:stillwalks/screens/shop_screen.dart';
import 'package:stillwalks/screens/explorer_journal_screen.dart';

import 'package:stillwalks/screens/settings_screen.dart';
import 'package:stillwalks/data/database/database_helper.dart';
import 'package:stillwalks/models/upgrade.dart';
import 'package:stillwalks/screens/widgets/sanctuary_slot_widgets.dart';
import 'package:stillwalks/screens/widgets/tutorial_overlay.dart';
import 'package:stillwalks/screens/widgets/tutorial_manager.dart';
import 'package:stillwalks/services/tutorial_service.dart';
import 'dart:async';
import 'package:stillwalks/services/progression_service.dart';
import 'package:stillwalks/screens/widgets/level_up_dialog.dart';
import 'package:stillwalks/l10n/app_localizations.dart';

/// Pantalla principal con el estado del jugador
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey _shopButtonKey = GlobalKey();
  final GlobalKey _sanctuarySlotKey = GlobalKey();
  StreamSubscription<int>? _levelUpSubscription;

  @override
  void initState() {
    super.initState();
    // Listen for level up events
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final esenciaService = Provider.of<EsenciaService>(context, listen: false);
      _levelUpSubscription = esenciaService.onLevelUp.listen((newLevel) {
        _showLevelUpDialog(newLevel);
      });
    });
  }

  @override
  void dispose() {
    _levelUpSubscription?.cancel();
    super.dispose();
  }

  void _showLevelUpDialog(int newLevel) {
    // Get unlocks for this level
    final progressionService = ProgressionService();
    final levelDef = progressionService.getLevelDefinition(newLevel);
    
    showDialog(
      context: context,
      barrierDismissible: false, // User must tap button
      builder: (context) => LevelUpDialog(
        newLevel: newLevel,
        unlocks: levelDef.unlocks,
        onDismiss: () => Navigator.of(context).pop(),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    // Escuchar cambios en los servicios
    final esenciaService = Provider.of<EsenciaService>(context);
    final orbeService = Provider.of<OrbeService>(context);
    final progressionService = ProgressionService();
    
    final currentEsencia = esenciaService.playerState.totalEsencia;
    final nextLevelXp = progressionService.getNextLevelXpRequirement(esenciaService.playerState.explorerLevel);
    // Asumimos que esenciaPerHour está en el estado del jugador, si no, calculamos o usamos base
    // Revisando EsenciaService: _playerState.esenciaPerHour se usa en calculatePendingEsencia.
    // Si la propiedad no existe en el modelo público, usaremos un valor derivado o fijo por ahora.
    // Para asegurar compilación, accediendo a playerState.
    // Si playerState no tiene esenciaPerHour, esto fallará. 
    // Mirando EsenciaService.dart linea 75: _playerState.esenciaPerHour * hoursElapsed. SI EXISTE.
    final esenciaPerHour = esenciaService.playerState.esenciaPerHour; 
    
    // Get Collector Level (Safe lookup)
    int collectorLevel = 0;
    try {
      final collectorUpgrade = esenciaService.upgrades.firstWhere(
        (u) => u.type == UpgradeType.idleMultiplier,
        orElse: () => Upgrade(
          id: 'temp', 
          type: UpgradeType.idleMultiplier, 
          currentLevel: 0, 
          name: '', 
          description: ''
        ),
      );
      collectorLevel = collectorUpgrade.currentLevel;
    } catch (e) {
      // Fallback
      collectorLevel = 0;
    } 
    

    
    // Tutorial Target Updates
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final tutorialService = Provider.of<TutorialService>(context, listen: false);
      
      if (tutorialService.currentStep == TutorialStep.shop) {
        _updateTutorialTarget(_shopButtonKey, tutorialService);
      } else if (tutorialService.currentStep == TutorialStep.sanctuary) {
        _updateTutorialTarget(_sanctuarySlotKey, tutorialService);
      } else if (tutorialService.currentStep == TutorialStep.hatch) {
         _updateTutorialTarget(_sanctuarySlotKey, tutorialService);
      }
    });

    return TutorialManager(
      child: TutorialOverlay(
      child: Stack(
        children: [
          Scaffold(
            // Removed AppBar
            body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.deepPurple.withAlpha(204),
                  Colors.black,
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // Sección superior: Esencia
                  Expanded(
                    flex: 2,
                    child: Stack(
                      children: [
                        // Background / Centered Content
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                AppLocalizations.of(context)!.essence,
                                style: const TextStyle(
                                  fontSize: 20,
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                              const SizedBox(height: 4),
                              
                              // Essence Icon + Number (Centered) - Removed the large duplicate number
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.auto_awesome, color: Colors.amberAccent, size: 32),
                                  const SizedBox(width: 8),
                                  Text(
                                    esenciaService.playerState.totalEsencia.toStringAsFixed(0),
                                    style: const TextStyle(
                                      fontSize: 48,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      shadows: [
                                        Shadow(color: Colors.black45, offset: Offset(0, 2), blurRadius: 4),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              
                              const SizedBox(height: 12),
                              
                              // Hourly Rate and Collector Level Tag
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // Hourly Rate
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.access_time, size: 16, color: Colors.white70),
                                      const SizedBox(width: 4),
                                      Text(
                                        '+${esenciaPerHour.toStringAsFixed(0)}/h',
                                        style: const TextStyle(fontSize: 16, color: Colors.white70),
                                      ),
                                    ],
                                  ),
                                  
                                  const SizedBox(width: 8),

                                  // Collector Level Tag (Styled like Sanctuary Level)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.amber.withOpacity(0.2), // Matching Essence Theme
                                      borderRadius: BorderRadius.circular(4), // Slightly rounded like a tag
                                      border: Border.all(color: Colors.amber.withOpacity(0.5)),
                                    ),
                                    child: Text(
                                      'LVL $collectorLevel', // Using LVL directly for now or AppLocalizations if I was sure, keeping it simple
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: Colors.amber,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Player Level Indicator (Top Right)
                        Positioned(
                          top: 16,
                          right: 16,
                          child: Column(
                            children: [
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  SizedBox(
                                    width: 48,
                                    height: 48,
                                    child: CircularProgressIndicator(
                                      value: nextLevelXp != null 
                                        ? esenciaService.playerState.currentXp / nextLevelXp 
                                        : 1.0,
                                      backgroundColor: Colors.white10,
                                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
                                      strokeWidth: 4,
                                    ),
                                  ),
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Colors.black26,
                                      shape: BoxShape.circle,
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      '${esenciaService.playerState.explorerLevel}',
                                      style: const TextStyle(
                                        color: Colors.amber,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${esenciaService.playerState.currentXp}/${nextLevelXp ?? "-"}',
                                style: const TextStyle(
                                  color: Colors.white60,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // App Title (Top Left) - Replaces AppBar
                        Positioned(
                          top: 16,
                          left: 16,
                          child: Text(
                            AppLocalizations.of(context)!.appTitle,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Sección media: Santuarios (Condicional)
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                       child: LayoutBuilder(
                        builder: (context, constraints) {
                           // Use ProgressionService to check unlock status instead of hardcoding
                           final isTempUnlocked = progressionService.isFeatureUnlocked(
                             esenciaService.playerState.explorerLevel, 
                             ProgressionFeature.temporarySanctuarySlot
                           );
                           
                           if (!isTempUnlocked) {
                             // Locked: Centered Primordial Sanctuary
                             return Center(
                               child: SizedBox(
                                 width: constraints.maxWidth * 0.6, // Slightly wider when single
                                 child: SanctuarySlot(
                                  containerKey: _sanctuarySlotKey,
                                  sanctuary: orbeService.sanctuaries.firstWhere(
                                    (s) => !s.isTemporary,
                                    orElse: () => orbeService.sanctuaries.first,
                                  ),
                                  orbeService: orbeService,
                                 ),
                               ),
                             );
                           }
                           
                           // Unlocked: Side by Side
                           return Row(
                            children: [
                              // Santuario Primordial (izquierda)
                              Expanded(
                                child: SanctuarySlot(
                                  containerKey: _sanctuarySlotKey,
                                  sanctuary: orbeService.sanctuaries.firstWhere(
                                    (s) => !s.isTemporary,
                                    orElse: () => orbeService.sanctuaries.first,
                                  ),
                                  orbeService: orbeService,
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Santuario Temporal (derecha)
                              Expanded(
                                child: TemporarySanctuarySlot(
                                  orbeService: orbeService,
                                ),
                              ),
                            ],
                          );
                        }
                      ),
                    ),
                  ),

                  // Almacén de Energía (Debajo de santuarios)
                  // Visible only if Level >= 4 AND Storage Upgrade purchased (Level >= 1)
                  Builder(
                    builder: (context) {
                       final storageUpgrade = esenciaService.upgrades.firstWhere(
                          (u) => u.type == UpgradeType.energyStorage,
                          orElse: () => Upgrade(
                            id: 'temp_storage', 
                            type: UpgradeType.energyStorage, 
                            currentLevel: 0, 
                            name: '', 
                            description: ''
                          ),
                        );
                        
                        // Use maxLevel from definition.
                        const maxLevel = 12; // UpgradeType.energyStorage.maxLevel is not const, but we know it's 12. 
                        // Actually, access it dynamically if possible, or use the type's property.
                        // Since we are in a build method, we can access the enum.
                        final totalLevels = UpgradeType.energyStorage.maxLevel;
                        
                        final isVisible = esenciaService.playerState.explorerLevel >= 4 && 
                                          esenciaService.hasUpgrade(UpgradeType.energyStorage);

                        if (isVisible) {
                          // Calculate width interaction
                          final currentLevel = storageUpgrade.currentLevel;
                          // Ratio: Level 1 should be small, Max Level should be full width.
                          // But we start counting 'visual progress' from level 1.
                          // So: (current - 1) / (total - 1)?
                          // Level 1: 0/11 = 0%.
                          // Level 12: 11/11 = 100%.
                          // Base width: 40% of max.
                          // visualProgress: 0.0 to 1.0.
                          final double visualProgress = (currentLevel - 1) / (totalLevels - 1);
                          final double clampedProgress = visualProgress.clamp(0.0, 1.0);

                          return LayoutBuilder(
                            builder: (context, constraints) {
                              // Match bottom padding: 24 horizontal * 2 = 48.
                              final maxAvailableWidth = constraints.maxWidth - 48;
                              
                              // Start at 50% width diff for Level 1, grow to 100%.
                              final widthFactor = 0.5 + (0.5 * clampedProgress);
                              final targetWidth = maxAvailableWidth * widthFactor;

                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 12.0),
                                child: Container(
                                  width: targetWidth,
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.blueAccent.withAlpha(25),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: Colors.blueAccent.withAlpha(77)),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.battery_charging_full, size: 18, color: Colors.blueAccent),
                                      const SizedBox(width: 8),
                                      Text(
                                        '${AppLocalizations.of(context)!.storage}: ${esenciaService.playerState.storedSteps} / ${esenciaService.storageCapacity}',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.blueAccent,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        overflow: TextOverflow.visible,
                                        softWrap: false,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }
                          );
                        } else {
                          return const SizedBox.shrink();
                        }
                    }
                  ),

                  // Sección inferior: Botones de navegación
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          _NavButton(
                            key: _shopButtonKey,
                            icon: Icons.shopping_bag,
                            label: AppLocalizations.of(context)!.shop,
                            onPressed: () {
                              // Allow navigation only if permitted
                               final tutorialService = Provider.of<TutorialService>(context, listen: false);
                               if (tutorialService.isActive && !tutorialService.allowShopAccess) {
                                 return;
                               }
                               
                               if (tutorialService.currentStep == TutorialStep.shop) {
                                 tutorialService.setTarget(null); // Clear highlight
                               }
                               
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const ShopScreen()));
                            },
                          ),
                          const SizedBox(height: 12),
                          _NavButton(
                            icon: Icons.book,
                            label: AppLocalizations.of(context)!.explorerJournal,
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const ExplorerJournalScreen()));
                            },
                          ),
                          const SizedBox(height: 12),
                          _NavButton(
                            icon: Icons.settings,
                            label: AppLocalizations.of(context)!.settings,
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          floatingActionButton: kDebugMode
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    FloatingActionButton.extended(
                      heroTag: 'essence_btn',
                      onPressed: () async {
                        final esenciaService = Provider.of<EsenciaService>(context, listen: false);
                        await esenciaService.addEsencia(1000.0);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('DEBUG: +1000 Esencia añadida')),
                          );
                        }
                      },
                      icon: const Icon(Icons.flash_on),
                      label: const Text('+1000 Esencia'),
                      backgroundColor: Colors.amber,
                    ),
                    const SizedBox(height: 16),
                    FloatingActionButton.extended(
                      heroTag: 'steps_btn',
                      onPressed: () async {
                        final orbeService = Provider.of<OrbeService>(context, listen: false);
                        final esenciaService = Provider.of<EsenciaService>(context, listen: false);
                        
                        const steps = 500;
                        final activeOrbs = await orbeService.addStepsToActiveOrbes(steps);
                        if (activeOrbs['count'] == 0) {
                          await esenciaService.addStoredSteps(steps);
                        }
                        esenciaService.updateSteps(steps);
                        
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('DEBUG: +500 pasos simulados')),
                          );
                        }
                      },
                      icon: const Icon(Icons.directions_run),
                      label: const Text('+500 Pasos'),
                      backgroundColor: Colors.redAccent,
                    ),
                    const SizedBox(height: 16),
                    FloatingActionButton.extended(
                      heroTag: 'storage_btn',
                      onPressed: () {
                        final esenciaService = Provider.of<EsenciaService>(context, listen: false);
                        esenciaService.addStoredSteps(100);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('DEBUG: +100 pasos al Almacén')),
                        );
                      },
                      icon: const Icon(Icons.battery_charging_full),
                      label: const Text('+100 Almacén'),
                      backgroundColor: Colors.blueAccent,
                    ),
                    const SizedBox(height: 16),
                    FloatingActionButton.extended(
                      heroTag: 'reset_btn',
                      onPressed: () async {
                         final orbeService = Provider.of<OrbeService>(context, listen: false);
                         final esenciaService = Provider.of<EsenciaService>(context, listen: false);
                         final tutorialService = Provider.of<TutorialService>(context, listen: false);

                         final db = DatabaseHelper();
                         await db.resetDatabase();
                         
                         // Services must reset their internal state too
                         await orbeService.initialize();
                         await esenciaService.resetProgress(); // Explicitly reset player state in memory
                         // Re-initialize to load fresh state from DB (though resetProgress sets memory)
                         await esenciaService.initialize(); 
                         
                         await tutorialService.resetTutorial();
                         
                         if (context.mounted) {

                           ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('DEBUG: Base de datos REINICIADA y Servicios Recargados 💥')),
                          );
                         }
                      },
                      icon: const Icon(Icons.delete_forever),
                      label: const Text('Reset DB'),
                      backgroundColor: Colors.black,
                    ),
                  ],
                )
              : null,
          ),
          

        ],
      ),
      ),
    );
  }


  void _updateTutorialTarget(GlobalKey key, TutorialService service) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (key.currentContext == null || !key.currentContext!.mounted) return;
      
      final RenderBox? renderBox = key.currentContext!.findRenderObject() as RenderBox?;
      if (renderBox != null && renderBox.attached) {
        final position = renderBox.localToGlobal(Offset.zero);
        final size = renderBox.size;
        final rect = Rect.fromLTWH(position.dx, position.dy, size.width, size.height);
        
        // Update service only if changed significantly
        if (service.targetRect != rect) {
          service.setTarget(rect);
        }
      }
    });
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _NavButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: Colors.white.withAlpha(25),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
