import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stillwalks/services/tutorial_service.dart';
import 'package:stillwalks/services/esencia_service.dart';
import 'package:stillwalks/services/orbe_service.dart';
import 'package:stillwalks/l10n/app_localizations.dart';

class TutorialManager extends StatefulWidget {
  final Widget child;

  const TutorialManager({
    super.key,
    required this.child,
  });

  @override
  State<TutorialManager> createState() => _TutorialManagerState();
}

class _TutorialManagerState extends State<TutorialManager> {
  // Track which tutorial step we've already shown a dialog for
  TutorialStep? _lastShownStep;

  @override
  void initState() {
    super.initState();
    // No initial check needed here, dependencies change will trigger updates or build
  }

  @override
  Widget build(BuildContext context) {
    // Listen to TutorialService changes
    final tutorialService = Provider.of<TutorialService>(context);
    
    // We need services for dialog actions, but listen: false to avoid unnecessary rebuilds just for accessing them
    // However, if we need their state, we should listen. For actions, usually no.
    // But wait, build context access inside addPostFrameCallback is safe.
    
    // Check if we need to show a dialog based on current step
    // Using addPostFrameCallback to ensure context is valid and we're not building
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      
      final currentStep = tutorialService.currentStep;
      
      if (currentStep == TutorialStep.welcome) {
        if (_lastShownStep != TutorialStep.welcome) {
           _lastShownStep = TutorialStep.welcome;
           _showTutorialWelcomeDialog(context, tutorialService);
        }
      } else if (currentStep == TutorialStep.energyIntro) {
        if (_lastShownStep != TutorialStep.energyIntro) {
           _lastShownStep = TutorialStep.energyIntro;
           _showEnergyTutorialDialog(context, tutorialService);
        }
      } else if (currentStep == TutorialStep.adventureContinues) {
          if (_lastShownStep != TutorialStep.adventureContinues) {
             _lastShownStep = TutorialStep.adventureContinues;
             _showAdventureContinuesDialog(context, tutorialService);
          }
      }
    });

    return widget.child;
  }

  void _showTutorialWelcomeDialog(BuildContext context, TutorialService tutorialService) {
    // Obtain services here to ensure we have the latest context
    final esenciaService = Provider.of<EsenciaService>(context, listen: false);
    final orbeService = Provider.of<OrbeService>(context, listen: false);
    
    // Get dynamic cost for basic orb
    final basicOrbCost = orbeService.getOrbeCost('orbe_basic');
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.deepPurple.shade900,
        title: Text(
          AppLocalizations.of(context)!.tutorialWelcome,
          style: const TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.auto_awesome, size: 48, color: Colors.amberAccent),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.tutorialWelcomeDesc,
              style: const TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
              ),
              onPressed: () async {
                // Grant exact amount needed for basic orb
                await esenciaService.addEsencia(basicOrbCost);
                
                // Show feedback
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(AppLocalizations.of(context)!.essenceGrant(basicOrbCost.toStringAsFixed(0))),
                      backgroundColor: Colors.amber,
                    ),
                  );
                }
                
                // Advance tutorial
                await tutorialService.nextStep();
                
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              },
              child: Text(AppLocalizations.of(context)!.startAdventure),
            ),
          ),
        ],
      ),
    );
  }

  void _showEnergyTutorialDialog(BuildContext context, TutorialService tutorialService) {
    final orbeService = Provider.of<OrbeService>(context, listen: false);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.deepPurple.shade900,
        title: Text(
          AppLocalizations.of(context)!.energyTutorialTitle,
          style: const TextStyle(color: Colors.white)
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.directions_walk, size: 48, color: Colors.cyanAccent),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.energyTutorialDesc,
              style: const TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.cyanAccent,
                foregroundColor: Colors.black,
              ),
              onPressed: () async {
                Navigator.of(context).pop();
                
                // Force reload to ensure latest state from DB
                await orbeService.loadData(); 
                
                // 1. Force grant energy to the main sanctuary orb
                // Loop to find the correct main sanctuary orb ID (robustness)
                String? targetOrbId;
                for (var s in orbeService.sanctuaries) {
                  if (!s.isTemporary && s.orbeId != null) {
                     targetOrbId = s.orbeId;
                     break;
                  }
                }

                if (targetOrbId != null) {
                   // Grant > 2000 steps (2500)
                   await orbeService.updateOrbeProgress(targetOrbId, 2500);
                } else {
                   // Fallback: Generic add if specific finding fails
                   await orbeService.addStepsToActiveOrbes(2500); 
                }
                
                // 2. Setup guaranteed hatch
                orbeService.setNextHatchOverride('stillwalk');
                
                // 3. Advance to Hatch step (Sanctuary Highlight)
                await tutorialService.nextStep();
              },
              child: Text(AppLocalizations.of(context)!.letsGo),
            ),
          ),
        ],
      ),
    );
  }

  void _showAdventureContinuesDialog(BuildContext context, TutorialService tutorialService) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.deepPurple.shade900,
        title: Text(
          AppLocalizations.of(context)!.tutorialConclusionTitle,
          style: const TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.star, size: 48, color: Colors.amberAccent),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.tutorialConclusionDesc,
              style: const TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
              ),
              onPressed: () async {
                // Finalize tutorial
                await tutorialService.completeTutorial();
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              },
              child: Text(AppLocalizations.of(context)!.continueButton),
            ),
          ),
        ],
      ),
    );
  }
}
