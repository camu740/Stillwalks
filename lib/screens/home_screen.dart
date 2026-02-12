import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:stillwalks/services/esencia_service.dart';
import 'package:stillwalks/services/orbe_service.dart';
import 'package:stillwalks/screens/shop_screen.dart';
import 'package:stillwalks/screens/explorer_journal_screen.dart';

import 'package:stillwalks/screens/settings_screen.dart';
import 'package:stillwalks/screens/inventory_screen.dart';
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
import 'package:stillwalks/screens/widgets/floating_essence_text.dart';
import 'package:stillwalks/screens/widgets/random_essence_orb.dart';
import 'package:stillwalks/screens/widgets/shop_shortcut_button.dart';
import 'package:stillwalks/screens/shop_screen.dart'; // Ensure ShopScreen is imported
import 'dart:math'; // Added for random position

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
  
  // Tap animation state
  final List<Widget> _tapAnimations = [];
  int _tapIdCounter = 0;

  // Random Orb State
  Timer? _randomOrbTimer;
  Offset? _randomOrbPosition;
  bool _isRandomOrbVisible = false;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    // Listen for level up events
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final esenciaService = Provider.of<EsenciaService>(context, listen: false);
      _levelUpSubscription = esenciaService.onLevelUp.listen((newLevel) {
        _showLevelUpDialog(newLevel);
      });
      
      // Check for offline essence collected
      _checkOfflineEssence();
    });

    _startRandomOrbTimer();
  }

  @override
  void dispose() {
    _levelUpSubscription?.cancel();
    _randomOrbTimer?.cancel();
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



  void _startRandomOrbTimer() {
    _randomOrbTimer?.cancel();
    // Random interval between 5 and 45 seconds
    final nextInterval = _random.nextInt(41) + 5;
    _randomOrbTimer = Timer(Duration(seconds: nextInterval), () {
      if (mounted) {
        _showRandomOrb();
      }
    });
  }

  void _showRandomOrb() {
    // Calculate random position (safe area roughly)
    // Avoid top bar and bottom nav
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    // Margins
    final minX = 40.0;
    final maxX = screenWidth - 100.0;
    final minY = 100.0; // Below top stats
    final maxY = screenHeight - 200.0; // Above nav

    setState(() {
      _randomOrbPosition = Offset(
        minX + _random.nextDouble() * (maxX - minX),
        minY + _random.nextDouble() * (maxY - minY),
      );
      _isRandomOrbVisible = true;
    });
  }

  void _handleRandomOrbTap() {
    if (!_isRandomOrbVisible) return;

    final esenciaService = Provider.of<EsenciaService>(context, listen: false);
    
    // Reward calculation: 5x Base Tap Strength (without multipliers)
    final bonus = esenciaService.baseTapStrength * 5;
    
    esenciaService.addEsencia(bonus); 

    // Show floating text
    final pos = _randomOrbPosition ?? Offset.zero;
    
    setState(() {
      _isRandomOrbVisible = false;
      _tapAnimations.add(
        FloatingEssenceText(
          key: ValueKey('bonus_${DateTime.now().millisecondsSinceEpoch}'),
          text: '+${bonus.toStringAsFixed(0)}',
          startPosition: pos,
          color: Colors.lightBlueAccent,
          fontWeight: FontWeight.w900,
          fontSize: 24,
          onComplete: () {
               // Cleanup handled by widget key removal usually or similar logic
                if (mounted) {
                  setState(() {
                    _tapAnimations.removeWhere((w) => w.key == ValueKey('bonus_${DateTime.now().millisecondsSinceEpoch}'));
                  });
                }
            },
          ),
      );
    });

    _startRandomOrbTimer(); // Restart cycle
  }

  void _handleTap(TapDownDetails details) {
    final esenciaService = Provider.of<EsenciaService>(context, listen: false);
    final earned = esenciaService.handleTap();
    
    // Add floating text animation
    final id = _tapIdCounter++;
    
    setState(() {
      _tapAnimations.add(
        Positioned(
          key: ValueKey('tap_$id'),
          left: details.globalPosition.dx,
          top: details.globalPosition.dy,
          child: FloatingEssenceText(
            text: '+${earned.toStringAsFixed(0)}',
            startPosition: details.globalPosition,
            onComplete: () {
              if (mounted) {
                setState(() {
                  _tapAnimations.removeWhere((widget) => widget.key == ValueKey('tap_$id'));
                });
              }
            },
          ),
        ),
      );
    });
  }

  void _checkOfflineEssence() {
    final esenciaService = Provider.of<EsenciaService>(context, listen: false);
    
    if (esenciaService.lastOfflineEarnedEssence > 0) {
      // Small delay to ensure dialog appears after screen is ready
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _showOfflineEssenceDialog(esenciaService.lastOfflineEarnedEssence);
          esenciaService.clearOfflineEarnedEssence();
        }
      });
    }
  }

  void _showOfflineEssenceDialog(double essence) {
    final l10n = AppLocalizations.of(context)!;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.auto_awesome, color: Colors.amber, size: 28),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                l10n.offlineEssenceCollectedTitle,
                style: const TextStyle(
                  color: Colors.amber,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.amber.withValues(alpha: 0.3),
                    Colors.deepPurple.withValues(alpha: 0.3),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.withValues(alpha: 0.5)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.auto_awesome, color: Colors.amberAccent, size: 32),
                  const SizedBox(width: 12),
                  Text(
                    essence.toStringAsFixed(0),
                    style: const TextStyle(
                      color: Colors.amber,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(color: Colors.black45, offset: Offset(0, 2), blurRadius: 4),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.offlineEssenceCollectedBody,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              foregroundColor: Colors.amber,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text(
              l10n.adventureContinues,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _showLevelInfoDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.info_outline, color: Colors.amber, size: 28),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                l10n.explorerLevel,
                style: const TextStyle(
                  color: Colors.amber,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.howToGainXp,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildXpSource(
                icon: Icons.circle_outlined,
                text: l10n.xpSourceBuyOrbs,
                xp: '10-50',
                color: Colors.purple,
              ),
              const SizedBox(height: 10),
              _buildXpSource(
                icon: Icons.bolt,
                text: l10n.xpSourceChannelOrbs,
                xp: '25-100',
                color: Colors.orange,
              ),
              const SizedBox(height: 10),
              _buildXpSource(
                icon: Icons.trending_up,
                text: l10n.xpSourceBuyUpgrades,
                xp: '20',
                color: Colors.green,
              ),
              const SizedBox(height: 10),
              _buildXpSource(
                icon: Icons.auto_awesome,
                text: l10n.xpSourceBuySanctuaries,
                xp: '35',
                color: Colors.cyan,
              ),
              const SizedBox(height: 10),
              _buildXpSource(
                icon: Icons.fort,
                text: l10n.xpSourceUpgradeSanctuaries,
                xp: '20',
                color: Colors.deepPurple,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lightbulb_outline, color: Colors.blue, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.levelUpToUnlock,
                        style: TextStyle(
                          color: Colors.blue.shade200,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              foregroundColor: Colors.amber,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text(
              l10n.understood,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildXpSource({required IconData icon, required String text, required String xp, required Color color}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ),
        const SizedBox(width: 16), // Increased from 8 to 16 for more breathing room
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), // Slightly larger badge
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.green.withValues(alpha: 0.4)),
          ),
          child: Text(
            '+$xp XP',
            style: const TextStyle(
              color: Colors.green,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
  
  @override
  Widget build(BuildContext context) {
    // Escuchar cambios en los servicios
    final esenciaService = Provider.of<EsenciaService>(context);
    final orbeService = Provider.of<OrbeService>(context);
    final tutorialService = Provider.of<TutorialService>(context); // Listen to tutorial steps
    final progressionService = ProgressionService();
    
    // final currentEsencia = esenciaService.playerState.totalEsencia;
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
        child: GestureDetector(
          onTapDown: _handleTap,
          behavior: HitTestBehavior.opaque, // Capture taps even on empty space
          child: Stack(
            children: [
              // Background (if any)
              Container(color: Colors.black), // Ensure background is hit-testable if it was transparent
              
              // Floating animations (moved to top of stack)
              // ..._tapAnimations,  <-- REMOVED from here
              
              // Main UI Content
              Stack(
                children: [
          PopScope(
            canPop: tutorialService.isCompleted,
            onPopInvokedWithResult: (didPop, result) {
               if (didPop) return;
               // Optional: Show message or just do nothing as requested "que no ocurra nada"
               ScaffoldMessenger.of(context).showSnackBar(
                 SnackBar(content: Text(AppLocalizations.of(context)!.tutorialBlockHome)),
               );
            },
            child: Scaffold(
              // Removed AppBar
              body: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.deepPurple.withValues(alpha: 0.8),
                    Colors.black,
                  ],
                ),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    // Sección superior: Panel Unificado (Esencia + Nivel)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Left Side: Essence Collector Info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      AppLocalizations.of(context)!.essenceCollectorLabel.toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white.withValues(alpha: 0.6),
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(Icons.auto_awesome, color: Colors.amberAccent, size: 24),
                                        const SizedBox(width: 8),
                                        Text(
                                          esenciaService.playerState.totalEsencia.toStringAsFixed(0),
                                          style: const TextStyle(
                                            fontSize: 28,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            shadows: [
                                              Shadow(color: Colors.black45, offset: Offset(0, 2), blurRadius: 4),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(Icons.access_time, size: 14, color: Colors.white70),
                                        const SizedBox(width: 4),
                                        Text(
                                          '+${esenciaPerHour.toStringAsFixed(0)}/h',
                                          style: const TextStyle(fontSize: 14, color: Colors.white70),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.amber.withValues(alpha: 0.2),
                                            borderRadius: BorderRadius.circular(4),
                                            border: Border.all(color: Colors.amber.withValues(alpha: 0.5)),
                                          ),
                                          child: Text(
                                            '${AppLocalizations.of(context)!.levelAbbr} $collectorLevel',
                                            style: const TextStyle(
                                              fontSize: 10,
                                              color: Colors.amber,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              
                              // Divider
                              Container(
                                width: 1,
                                color: Colors.white.withOpacity(0.2),
                                margin: const EdgeInsets.symmetric(horizontal: 24),
                              ),
                              
                              // Right Side: Player Level Info
                              GestureDetector(
                                onTap: () => _showLevelInfoDialog(context),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
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
                                        Text(
                                          '${esenciaService.playerState.explorerLevel}',
                                          style: const TextStyle(
                                            color: Colors.amber,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                      ],
                                    ),
                                   const SizedBox(height: 8),
                                    Text(
                                      '${esenciaService.playerState.currentXp}/${nextLevelXp ?? "-"}',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
  
                    // Espacio flexible superior
                    const Spacer(),
  
                    // Sección central: Santuarios y Almacén
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                       child: Column(
                         mainAxisSize: MainAxisSize.min,
                         children: [
                           LayoutBuilder(
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
  
                          // Almacén de Energía (Debajo de santuarios)
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
                              
                              const totalLevels = 12; // UpgradeType.energyStorage.maxLevel
                              
                              final isVisible = esenciaService.playerState.explorerLevel >= 4 && 
                                                esenciaService.hasUpgrade(UpgradeType.energyStorage);
  
                              if (isVisible) {
                                final currentLevel = storageUpgrade.currentLevel;
                                final double visualProgress = (currentLevel - 1) / (totalLevels - 1);
                                final double clampedProgress = visualProgress.clamp(0.0, 1.0);
  
                                return LayoutBuilder(
                                  builder: (context, constraints) {
                                    final maxAvailableWidth = constraints.maxWidth; // Full width of parent
                                    
                                    final widthFactor = 0.5 + (0.5 * clampedProgress);
                                    final targetWidth = maxAvailableWidth * widthFactor;
  
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 24.0), // Space between sanctuaries and storage
                                      child: Container(
                                        width: targetWidth,
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: Colors.blueAccent.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(color: Colors.blueAccent.withValues(alpha: 0.3)),
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
                        ],
                      ),
                    ),
      
                    // Espacio flexible inferior
                    const Spacer(),
      
                    // Sección inferior: Botones de navegación
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _NavButton(
                                  icon: Icons.inventory_2,
                                  label: AppLocalizations.of(context)!.yourBag,
                                  onPressed: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (_) => const InventoryScreen()));
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _NavButton(
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
                              ),
                            ],
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
          ),
                ],
              ),
              
              // Floating animations (ON TOP of UI controls)
              IgnorePointer(
                ignoring: true, // Let taps pass through to UI
                child: Stack(
                  children: _tapAnimations,
                ),
              ),
              // Shop Shortcuts (Top Right Side)
              Positioned(
                top: 170, // Moved down to avoid overlap with top status bar
                right: 0, // Flush to edge
                child: SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Upgrades Shortcut
                      ShopShortcutButton(
                        icon: Icons.trending_up, 
                        iconColor: Colors.greenAccent,
                        onTap: () {
                           Navigator.of(context).push(
                             MaterialPageRoute(
                               builder: (context) => const ShopScreen(initialTab: 0), // 0 = Upgrades
                             ),
                           );
                        },
                      ),
                      const SizedBox(height: 16),
                      // Buildings Shortcut
                      ShopShortcutButton(
                        icon: Icons.location_city, 
                        iconColor: Colors.cyanAccent,
                        onTap: () {
                           Navigator.of(context).push(
                             MaterialPageRoute(
                               builder: (context) => const ShopScreen(initialTab: 1), // 1 = Buildings
                             ),
                           );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // Random Essence Orb (Moved to top)
              if (_isRandomOrbVisible && _randomOrbPosition != null)
                Positioned(
                  left: _randomOrbPosition!.dx,
                  top: _randomOrbPosition!.dy,
                  child: RandomEssenceOrb(
                    onTap: _handleRandomOrbTap,
                    onDismiss: () {
                      if (mounted) {
                        setState(() {
                          _isRandomOrbVisible = false;
                        });
                        _startRandomOrbTimer();
                      }
                    },
                  ),
                ),
            ],
          ),
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
          backgroundColor: Colors.white.withValues(alpha: 0.1),
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
