import 'package:flutter/material.dart';
import 'dart:math' show pi;

/// Pantalla de animación de canalización (cuando el Orbe está completo)
import 'package:stillwalks/models/creature_instance.dart';
import 'package:stillwalks/models/creature_species.dart';

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
              Colors.purple.withOpacity(0.8),
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
                                  Colors.deepPurple.withOpacity(0.5),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.purpleAccent.withOpacity(0.8),
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
                                color: Colors.white.withOpacity(0.3),
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
                              color: Colors.amberAccent.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.amberAccent),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.star, color: Colors.amberAccent, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  '¡NUEVO!',
                                  style: TextStyle(
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
                          onPressed: () {
                            // Volver a home
                            Navigator.of(context).popUntil((route) => route.isFirst);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurpleAccent,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 48,
                              vertical: 16,
                            ),
                          ),
                          child: const Text(
                            'Continuar',
                            style: TextStyle(fontSize: 18),
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
