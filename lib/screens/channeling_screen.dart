import 'package:flutter/material.dart';
import 'dart:math' show pi;

/// Pantalla de animación de canalización (cuando el Orbe está completo)
import 'package:stillwalks/models/creature_instance.dart';
import 'package:stillwalks/models/creature_species.dart';
import 'package:stillwalks/l10n/app_localizations.dart';

import 'package:provider/provider.dart';
import 'package:stillwalks/services/tutorial_service.dart';

/// Pantalla de animación de canalización (cuando el Orbe está completo)
class ChannelingScreen extends StatefulWidget {
  final CreatureInstance instance;
  final CreatureSpecies species;
  final bool isNew;

  const ChannelingScreen({
    super.key,
    required this.instance,
    required this.species,
    required this.isNew,
  });

  @override
  State<ChannelingScreen> createState() => _ChannelingScreenState();
}

class _ChannelingScreenState extends State<ChannelingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _opacityAnimation;

  bool _showCreature = false;
  // bool _isFirstTime -> Usamos widget.isNew

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: pi * 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
      ),
    );

    // Iniciar animación
    _controller.forward().then((_) {
      setState(() {
        _showCreature = true;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: [
              Colors.purple.withAlpha(204),
              Colors.black,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animación del Orbe
                if (!_showCreature)
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _scaleAnimation.value,
                        child: Transform.rotate(
                          angle: _rotationAnimation.value,
                          child: Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  Colors.purpleAccent,
                                  Colors.deepPurple.withAlpha(128),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.purpleAccent.withAlpha(204),
                                  blurRadius: 60,
                                  spreadRadius: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                // Criatura revelada
                if (_showCreature) ...[
                  FadeTransition(
                    opacity: _opacityAnimation,
                    child: Column(
                      children: [
                        // TODO: Mostrar sprite real de la criatura
                        Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withAlpha(77),
                                blurRadius: 30,
                                spreadRadius: 10,
                              ),
                            ],
                          ),
                          child: Image.asset(
                            widget.species.assetPath,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.pets, size: 150, color: Colors.white),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Nombre de la criatura
                        Text(
                          widget.species.name,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Badge de "Nuevo" si es primera captura
                        if (widget.isNew)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.amberAccent.withAlpha(51),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.amberAccent),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.star, color: Colors.amberAccent, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  AppLocalizations.of(context)!.newCreatureBadge,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.amberAccent,
                                  ),
                                ),
                              ],
                            ),
                          ),

                        const SizedBox(height: 48),

                        // Botón para continuar
                        ElevatedButton(
                          onPressed: () async {
                            // Tutorial completion check
                            final tutorialService = Provider.of<TutorialService>(context, listen: false);
                            
                            if (context.mounted) {
                              // Volver a home primero
                              Navigator.of(context).popUntil((route) => route.isFirst);
                            }

                            if (tutorialService.currentStep == TutorialStep.hatch) {
                                // Short delay to ensure transition is seemingly done or at least stack is cleared
                                // This ensures the dialog from nextStep() is pushed onto the Home screen, not wiped by popUntil
                                await Future.delayed(const Duration(milliseconds: 100));
                                tutorialService.setTarget(null); // Ensure highlight is removed
                                await tutorialService.nextStep();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurpleAccent,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 48,
                              vertical: 16,
                            ),
                          ),
                            child: Text(
                            AppLocalizations.of(context)!.continueButton,
                            style: const TextStyle(fontSize: 18),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
