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
import 'dart:math';

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
  StreamSubscription<void>? _essenceRainSubscription;
  
  // Tap animation state
  final List<Widget> _tapAnimations = [];
  int _tapIdCounter = 0;

  // Random Orb State
  Timer? _randomOrbTimer;
  Offset? _randomOrbPosition;
  bool _isRandomOrbVisible = false;
  final Random _random = Random();
  
  // Cooldown State
  Duration? _cooldownDuration;
  DateTime? _lastTapTime;

  @override
  void initState() {
    super.initState();
    // Listen for level up events
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final esenciaService = Provider.of<EsenciaService>(context, listen: false);
      _levelUpSubscription = esenciaService.onLevelUp.listen((newLevel) {
        _showLevelUpDialog(newLevel);
      });
      
      _essenceRainSubscription = esenciaService.onEssenceRainRequested.listen((_) {
        _startEssenceRain();
      });
      
      // Check for offline essence collected
      _checkOfflineEssence();
    });

    _startRandomOrbTimer();
  }

  @override
  void dispose() {
    _levelUpSubscription?.cancel();
    _essenceRainSubscription?.cancel();
    _randomOrbTimer?.cancel();
    _essenceRainTimer?.cancel();
    super.dispose();
  }

  void _showLevelUpDialog(int newLevel) {
    final progressionService = ProgressionService();
    final levelDef = progressionService.getLevelDefinition(newLevel);
    
    List<Unlock> unlocks = List.from(levelDef.unlocks);
    
    if (newLevel == 2) {
       unlocks.add(const Unlock.item(
         'offer_free_orb', 
         description: '¡OFERTA: 1 Orbe Básico GRATIS en la Tienda!',
       ));
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => LevelUpDialog(
        newLevel: newLevel,
        unlocks: unlocks,
        onDismiss: () {
          Navigator.of(context).popUntil((route) => route.isFirst);
          Provider.of<EsenciaService>(context, listen: false).requestEssenceRain();
        },
      ),
    );
  }

  void _startRandomOrbTimer() {
    _randomOrbTimer?.cancel();
    
    // Frecuencia dinámica basada en el nivel
    final level = Provider.of<EsenciaService>(context, listen: false).playerState.explorerLevel;
    final int nextInterval;
    
    if (level <= 2) {
      // Mucho más frecuente en niveles iniciales (3 a 12 segundos)
      nextInterval = _random.nextInt(10) + 3;
    } else {
      // Intervalo normal (5 a 45 segundos)
      nextInterval = _random.nextInt(41) + 5;
    }
    
    _randomOrbTimer = Timer(Duration(seconds: nextInterval), () {
      if (mounted) {
        _showRandomOrb();
      }
    });
  }

  // --- Essence Rain Logic ---
  Timer? _essenceRainTimer;
  bool _isEssenceRainActive = false;

  void _startEssenceRain() {
    if (_isEssenceRainActive) return;
    
    debugPrint('✨ HomeScreen: Starting Essence Rain event!');
    setState(() {
      _isEssenceRainActive = true;
    });

    int orbsSpawned = 0;
    const int totalOrbs = 25;
    
    _essenceRainTimer = Timer.periodic(const Duration(milliseconds: 250), (timer) {
      if (orbsSpawned >= totalOrbs) {
        timer.cancel();
        Future.delayed(const Duration(seconds: 4), () {
          if (mounted) {
            setState(() {
              _isEssenceRainActive = false;
            });
          }
        });
        return;
      }

      if (mounted) {
        _showRainOrb();
        orbsSpawned++;
      }
    });
  }

  void _showRainOrb() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    final minX = 40.0;
    final maxX = screenWidth - 100.0;
    final minY = 100.0;
    final maxY = screenHeight - 200.0;

    final pos = Offset(
      minX + _random.nextDouble() * (maxX - minX),
      minY + _random.nextDouble() * (maxY - minY),
    );

    final id = 'rain_${DateTime.now().millisecondsSinceEpoch}_${_random.nextInt(1000)}';
    
    setState(() {
      _tapAnimations.add(
        Positioned(
          key: ValueKey(id),
          left: pos.dx,
          top: pos.dy,
          child: RandomEssenceOrb(
            onTap: () {
              final esenciaService = Provider.of<EsenciaService>(context, listen: false);
              final bonus = esenciaService.baseTapStrength * 3;
              esenciaService.addEsencia(bonus);
              
              if (mounted) {
                setState(() {
                  _tapAnimations.removeWhere((w) => w.key == ValueKey(id));
                  _showFloatingXpText(bonus, pos, Colors.amberAccent);
                });
              }
            },
            onDismiss: () {
              if (mounted) {
                setState(() {
                  _tapAnimations.removeWhere((w) => w.key == ValueKey(id));
                });
              }
            },
          ),
        ),
      );
    });
  }

  void _showFloatingXpText(double bonus, Offset pos, Color color) {
    final id = 'floating_${DateTime.now().millisecondsSinceEpoch}_${_random.nextInt(1000)}';
    _tapAnimations.add(
      Positioned(
        key: ValueKey(id),
        left: pos.dx,
        top: pos.dy,
        child: FloatingEssenceText(
          text: '+${bonus.toStringAsFixed(0)}',
          startPosition: pos,
          color: color,
          fontWeight: FontWeight.w900,
          fontSize: 22,
          onComplete: () {
            if (mounted) {
              setState(() {
                _tapAnimations.removeWhere((w) => w.key == ValueKey(id));
              });
            }
          },
        ),
      ),
    );
  }

  void _showRandomOrb() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    final minX = 40.0;
    final maxX = screenWidth - 100.0;
    final minY = 100.0;
    final maxY = screenHeight - 200.0;

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
    final bonus = esenciaService.baseTapStrength * 5;
    esenciaService.addEsencia(bonus); 

    final pos = _randomOrbPosition ?? Offset.zero;
    final id = 'bonus_${DateTime.now().millisecondsSinceEpoch}';
    
    setState(() {
      _isRandomOrbVisible = false;
      _tapAnimations.add(
        Positioned(
          key: ValueKey(id),
          left: pos.dx,
          top: pos.dy,
          child: FloatingEssenceText(
            text: '+${bonus.toStringAsFixed(0)}',
            startPosition: pos,
            color: Colors.lightBlueAccent,
            fontWeight: FontWeight.w900,
            fontSize: 24,
            onComplete: () {
                 if (mounted) {
                   setState(() {
                     _tapAnimations.removeWhere((w) => w.key == ValueKey(id));
                   });
                 }
             },
          ),
        ),
      );
    });

    _startRandomOrbTimer();
  }

  void _handleTap(TapDownDetails details) {
    final esenciaService = Provider.of<EsenciaService>(context, listen: false);
    final earned = esenciaService.handleTap();
    
    if (earned <= 0) return;

    final tapTime = DateTime.now();
    final duration = esenciaService.tapCooldown;
    
    setState(() {
      _lastTapTime = tapTime;
      _cooldownDuration = duration.inMilliseconds > 300 ? duration : null;
    });

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
                xp: '15-90',
                color: Colors.purple,
              ),
              const SizedBox(height: 10),
              _buildXpSource(
                icon: Icons.bolt,
                text: l10n.xpSourceChannelOrbs,
                xp: '60-350',
                color: Colors.orange,
              ),
              const SizedBox(height: 10),
              _buildXpSource(
                icon: Icons.location_city,
                text: l10n.xpSourceBuyBuildings,
                xp: '50',
                color: Colors.blueAccent,
              ),
              const SizedBox(height: 10),
              _buildXpSource(
                icon: Icons.trending_up,
                text: l10n.xpSourceBuyUpgrades,
                xp: '40',
                color: Colors.green,
              ),
              const SizedBox(height: 10),
              _buildXpSource(
                icon: Icons.auto_awesome,
                text: l10n.xpSourceBuySanctuaries,
                xp: '20',
                color: Colors.cyan,
              ),
              const SizedBox(height: 10),
              _buildXpSource(
                icon: Icons.fort,
                text: l10n.xpSourceUpgradeSanctuaries,
                xp: '40',
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
        const SizedBox(width: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
    final tutorialService = Provider.of<TutorialService>(context);
    final progressionService = ProgressionService();
    
    // Tutorial Target Updates
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final tutorialService = Provider.of<TutorialService>(context, listen: false);
      if (tutorialService.currentStep == TutorialStep.shop) {
        _updateTutorialTarget(_shopButtonKey, tutorialService);
      } else if (tutorialService.currentStep == TutorialStep.sanctuary || tutorialService.currentStep == TutorialStep.hatch) {
        _updateTutorialTarget(_sanctuarySlotKey, tutorialService);
      }
    });

    return TutorialManager(
      child: TutorialOverlay(
        child: PopScope(
          canPop: tutorialService.isCompleted,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(AppLocalizations.of(context)!.tutorialBlockHome)),
            );
          },
          child: Scaffold(
            body: GestureDetector(
              onTapDown: _handleTap,
              behavior: HitTestBehavior.opaque,
              child: Container(
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
                  child: Stack(
                    children: [
                      // 1. Base UI Layer
                      Column(
                        children: [
                          // Upper Panel: Essence + Level
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
                                    // Essence Info
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
                                                '+${esenciaService.passiveEssencePerSecond.toStringAsFixed(1)}/s',
                                                style: const TextStyle(fontSize: 14, color: Colors.white70),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),

                                    const SizedBox(width: 8),
                                   
                                    // Shortcuts
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        ShopShortcutButton(
                                          icon: Icons.trending_up,
                                          iconColor: Colors.greenAccent,
                                          isCompact: true,
                                          onTap: () {
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (context) => const ShopScreen(initialTab: 0),
                                              ),
                                            );
                                          },
                                        ),
                                        const SizedBox(height: 6),
                                        ShopShortcutButton(
                                          icon: Icons.location_city,
                                          iconColor: Colors.cyanAccent,
                                          isCompact: true,
                                          onTap: () {
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (context) => const ShopScreen(initialTab: 1),
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                    
                                    const SizedBox(width: 20),
                                    
                                    // Divider
                                    Container(
                                      width: 1,
                                      color: Colors.white.withOpacity(0.2),
                                      margin: const EdgeInsets.only(right: 20),
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
                                                  value: progressionService.getLevelProgress(
                                                    esenciaService.playerState.currentXp,
                                                    esenciaService.playerState.explorerLevel,
                                                  ),
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
                                            '${progressionService.getLevelRelativeXp(esenciaService.playerState.currentXp, esenciaService.playerState.explorerLevel)}/${progressionService.getLevelXpRange(esenciaService.playerState.explorerLevel) > 0 ? progressionService.getLevelXpRange(esenciaService.playerState.explorerLevel) : "-"}',
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

                          // Cooldown Indicator
                          Builder(
                            builder: (context) {
                              final tapTime = _lastTapTime;
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 32.0).copyWith(top: 4),
                                child: SizedBox(
                                  height: 4,
                                  child: _cooldownDuration != null 
                                    ? CooldownIndicator(
                                        key: ValueKey('cooldown_${tapTime?.millisecondsSinceEpoch}'), 
                                        duration: _cooldownDuration!,
                                        onComplete: () {
                                          if (mounted && _lastTapTime == tapTime) {
                                            setState(() {
                                              _cooldownDuration = null;
                                            });
                                          }
                                        },
                                      )
                                    : const SizedBox(),
                                ),
                              );
                            }
                          ),

                          const Spacer(),

                          // Central Section: Sanctuaries
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                LayoutBuilder(
                                  builder: (context, constraints) {
                                    final isTempUnlocked = progressionService.isFeatureUnlocked(
                                      esenciaService.playerState.explorerLevel, 
                                      ProgressionFeature.temporarySanctuarySlot
                                    );
                                    
                                    if (!isTempUnlocked) {
                                      return Center(
                                        child: SizedBox(
                                          width: constraints.maxWidth * 0.6,
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
                                    
                                    return Row(
                                      children: [
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
                                        Expanded(
                                          child: TemporarySanctuarySlot(
                                            orbeService: orbeService,
                                          ),
                                        ),
                                      ],
                                    );
                                  }
                                ),

                                // Energy Storage
                                Builder(
                                  builder: (context) {
                                    final isVisible = esenciaService.playerState.explorerLevel >= 4 && 
                                                      esenciaService.hasUpgrade(UpgradeType.energyStorage);
                                    if (!isVisible) return const SizedBox.shrink();

                                    final storageUpgrade = esenciaService.upgrades.firstWhere(
                                      (u) => u.type == UpgradeType.energyStorage,
                                      orElse: () => Upgrade(id: 'temp', type: UpgradeType.energyStorage, currentLevel: 0, name: '', description: ''),
                                    );
                                    
                                    final currentLevel = storageUpgrade.currentLevel;
                                    double visualProgress = (currentLevel - 1) / 11.0;
                                    visualProgress = visualProgress.clamp(0.0, 1.0);

                                    return LayoutBuilder(
                                      builder: (context, constraints) {
                                        final targetWidth = constraints.maxWidth * (0.5 + (0.5 * visualProgress));
                                        return Padding(
                                          padding: const EdgeInsets.only(top: 24.0),
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
                                                  style: const TextStyle(fontSize: 14, color: Colors.blueAccent, fontWeight: FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      }
                                    );
                                  }
                                ),
                              ],
                            ),
                          ),

                          const Spacer(),

                          // Navigation Buttons
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
                                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const InventoryScreen())),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _NavButton(
                                        key: _shopButtonKey,
                                        icon: Icons.shopping_bag,
                                        label: AppLocalizations.of(context)!.shop,
                                        onPressed: () {
                                          final tutorialService = Provider.of<TutorialService>(context, listen: false);
                                          if (tutorialService.isActive && !tutorialService.allowShopAccess) return;
                                          if (tutorialService.currentStep == TutorialStep.shop) tutorialService.setTarget(null);
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
                                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ExplorerJournalScreen())),
                                ),
                                const SizedBox(height: 12),
                                _NavButton(
                                  icon: Icons.settings,
                                  label: AppLocalizations.of(context)!.settings,
                                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      
                      // 2. Animations Layer
                      Stack(children: _tapAnimations),

                      // 3. Random Orb
                      if (_isRandomOrbVisible && _randomOrbPosition != null)
                        Positioned(
                          left: _randomOrbPosition!.dx,
                          top: _randomOrbPosition!.dy,
                          child: RandomEssenceOrb(
                            onTap: _handleRandomOrbTap,
                            onDismiss: () {
                              if (mounted) {
                                setState(() { _isRandomOrbVisible = false; });
                                _startRandomOrbTimer();
                              }
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            floatingActionButton: kDebugMode ? _buildDebugButtons() : null,
          ),
        ),
      ),
    );
  }

  Widget _buildDebugButtons() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        FloatingActionButton.extended(
          heroTag: 'essence_btn',
          onPressed: () async {
            final esenciaService = Provider.of<EsenciaService>(context, listen: false);
            await esenciaService.addEsencia(1000.0);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('DEBUG: +1000 Esencia added')));
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
            final res = await orbeService.addStepsToActiveOrbes(500);
            if (res['count'] == 0) await esenciaService.addStoredSteps(500);
            esenciaService.updateSteps(500);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('DEBUG: +500 steps added')));
            }
          },
          icon: const Icon(Icons.directions_run),
          label: const Text('+500 Pasos'),
          backgroundColor: Colors.redAccent,
        ),
        const SizedBox(height: 16),
        FloatingActionButton.extended(
          heroTag: 'reset_btn',
          onPressed: () async {
             await DatabaseHelper().resetDatabase();
             await Provider.of<OrbeService>(context, listen: false).initialize();
             final es = Provider.of<EsenciaService>(context, listen: false);
             await es.resetProgress();
             await es.initialize();
             await Provider.of<TutorialService>(context, listen: false).resetTutorial();
             if (mounted) {
               ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('DEBUG: Database Reset')));
             }
          },
          icon: const Icon(Icons.delete_forever),
          label: const Text('Reset DB'),
          backgroundColor: Colors.black,
        ),
      ],
    );
  }

  void _updateTutorialTarget(GlobalKey key, TutorialService service) {
    if (key.currentContext == null || !key.currentContext!.mounted) return;
    final RenderBox? renderBox = key.currentContext!.findRenderObject() as RenderBox?;
    final RenderBox? screenBox = context.findRenderObject() as RenderBox?;

    if (renderBox != null && renderBox.attached && screenBox != null && screenBox.attached) {
      final position = renderBox.localToGlobal(Offset.zero, ancestor: screenBox);
      final size = renderBox.size;
      final rect = Rect.fromLTWH(position.dx, position.dy, size.width, size.height);
      if (service.targetRect != rect) {
        service.setTarget(rect);
      }
    }
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

class CooldownIndicator extends StatefulWidget {
  final Duration duration;
  final VoidCallback onComplete;

  const CooldownIndicator({
    super.key,
    required this.duration,
    required this.onComplete,
  });

  @override
  State<CooldownIndicator> createState() => _CooldownIndicatorState();
}

class _CooldownIndicatorState extends State<CooldownIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
         vsync: this,
         duration: widget.duration,
    );
    _controller.reverse(from: 1.0).whenComplete(() {
        if (mounted) widget.onComplete();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        if (_controller.value <= 0) return const SizedBox.shrink();
        return CustomPaint(
          size: const Size(double.infinity, 4),
          painter: _CooldownPainter(
            progress: _controller.value,
          ),
        );
      },
    );
  }
}

class _CooldownPainter extends CustomPainter {
  final double progress;

  _CooldownPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    final paint = Paint()
      ..color = Colors.cyanAccent.withOpacity(0.8)
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round
      ..strokeWidth = size.height;

    final centerX = size.width / 2;
    final currentTotalWidth = size.width * progress;
    final halfWidth = currentTotalWidth / 2;
    
    final p1 = Offset(centerX - halfWidth, size.height / 2);
    final p2 = Offset(centerX + halfWidth, size.height / 2);

    canvas.drawLine(p1, p2, paint);
    
    final glowPaint = Paint()
      ..color = Colors.cyanAccent.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.height + 4
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      
    canvas.drawLine(p1, p2, glowPaint);
  }

  @override
  bool shouldRepaint(_CooldownPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
