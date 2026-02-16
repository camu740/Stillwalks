import 'package:flutter/material.dart';
import 'dart:math';

class RandomEssenceOrb extends StatefulWidget {
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  const RandomEssenceOrb({
    super.key,
    required this.onTap,
    required this.onDismiss,
  });

  @override
  State<RandomEssenceOrb> createState() => _RandomEssenceOrbState();
}

class _RandomEssenceOrbState extends State<RandomEssenceOrb> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4), // Total lifecycle
    );

    // Fade in: 0.0 -> 0.5s
    // Stay: 0.5s -> 3.0s
    // Fade out: 3.0s -> 4.0s
    
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0).chain(CurveTween(curve: Curves.elasticOut)), weight: 15),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 60),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0).chain(CurveTween(curve: Curves.easeInOut)), weight: 25),
    ]).animate(_controller);

    _opacityAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 10),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 65),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 25),
    ]).animate(_controller);

    _controller.forward().then((_) {
      if (mounted) {
        widget.onDismiss();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    _controller.stop();
    // Maybe play a quick "pop" animation or just disappear
    widget.onTap(); 
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: GestureDetector(
              onTap: _handleTap,
              onTapDown: (_) {}, // Consumir evento para evitar que propague al fondo (tap normal)
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.amberAccent.withOpacity(0.8),
                      Colors.orangeAccent.withOpacity(0.4),
                      Colors.transparent,
                    ],
                    stops: const [0.3, 0.7, 1.0],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amber.withOpacity(0.5),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.auto_awesome, 
                  color: Colors.white, 
                  size: 30,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
