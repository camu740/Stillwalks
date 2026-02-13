import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stillwalks/services/tutorial_service.dart';
import 'package:stillwalks/services/esencia_service.dart';
import 'package:stillwalks/services/orbe_service.dart';
import 'package:stillwalks/l10n/app_localizations.dart';
import 'package:stillwalks/widgets/tutorial_dialog.dart';

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
  TutorialStep? _lastShownStep;

  @override
  Widget build(BuildContext context) {
    final tutorialService = Provider.of<TutorialService>(context);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      
      final currentStep = tutorialService.currentStep;
      
      if (currentStep == TutorialStep.welcome) {
        if (_lastShownStep != TutorialStep.welcome) {
           _lastShownStep = TutorialStep.welcome;
           _showWelcomeDialog(context, tutorialService);
        }
      } else if (currentStep == TutorialStep.energyIntro) {
        if (_lastShownStep != TutorialStep.energyIntro) {
           _lastShownStep = TutorialStep.energyIntro;
           _showEnergyDialog(context, tutorialService);
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

  void _showWelcomeDialog(BuildContext context, TutorialService tutorialService) {
    final esenciaService = Provider.of<EsenciaService>(context, listen: false);
    final orbeService = Provider.of<OrbeService>(context, listen: false);
    final l10n = AppLocalizations.of(context)!;
    final basicOrbCost = orbeService.getOrbeCost('orbe_basic');
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Material(
          color: Colors.transparent,
          child: TutorialDialog(
            title: l10n.tutorialWelcomeTitle,
            description: l10n.tutorialWelcomeDesc,
            onNext: () async {
              // Close dialog first
              Navigator.of(context).pop();
              await esenciaService.addEsencia(basicOrbCost);
              await tutorialService.nextStep();
            },
          ),
        ),
      ),
    );
  }

  void _showEnergyDialog(BuildContext context, TutorialService tutorialService) {
    final orbeService = Provider.of<OrbeService>(context, listen: false);
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Material(
          color: Colors.transparent,
          child: TutorialDialog(
            title: l10n.tutorialEnergyTitle,
            description: l10n.tutorialEnergyDesc,
            onNext: () async {
              Navigator.of(context).pop();
              await orbeService.loadData(); 
              
              String? targetOrbId;
              for (var s in orbeService.sanctuaries) {
                if (!s.isTemporary && s.orbeId != null) {
                   targetOrbId = s.orbeId;
                   break;
                }
              }

              if (targetOrbId != null) {
                 await orbeService.updateOrbeProgress(targetOrbId, 2500);
              } else {
                 await orbeService.addStepsToActiveOrbes(2500); 
              }
              
              orbeService.setNextHatchOverride('gamusarra');
              await tutorialService.nextStep();
            },
          ),
        ),
      ),
    );
  }

  void _showAdventureContinuesDialog(BuildContext context, TutorialService tutorialService) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Material(
          color: Colors.transparent,
          child: TutorialDialog(
            title: l10n.tutorialAdventureTitle,
            description: l10n.tutorialAdventureDesc,
            isLast: true,
            onNext: () async {
              Navigator.of(context).pop();
              await tutorialService.completeTutorial();
            },
          ),
        ),
      ),
    );
  }
}
