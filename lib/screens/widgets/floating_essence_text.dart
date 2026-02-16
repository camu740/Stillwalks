import 'package:flutter/material.dart';

class FloatingEssenceText extends StatefulWidget {
  final String text;
  final VoidCallback onComplete;
  final Offset startPosition;
  final Color? color;
  final double? fontSize;
  final FontWeight? fontWeight;

  const FloatingEssenceText({
    super.key,
    required this.text,
    required this.onComplete,
    required this.startPosition,
    this.color,
    this.fontSize,
    this.fontWeight,
  });

  @override
  State<FloatingEssenceText> createState() => _FloatingEssenceTextState();
}

class _FloatingEssenceTextState extends State<FloatingEssenceText> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<double> _translateY;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _opacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.5, 1.0, curve: Curves.easeOut)),
    );

    _translateY = Tween<double>(begin: 0.0, end: -50.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    
    _scale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.3, curve: Curves.elasticOut)),
    );

    _controller.forward().then((_) {
      if (mounted) {
        widget.onComplete();
      }
    }); // Add check for mounted
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Use SizedBox to ensure the text has layout constraints even in a Stack
    // Use SizedBox to ensure the text has layout constraints even in a Stack
    return SizedBox(
      width: 100, // Fixed width to prevent layout issues
      height: 100, // Fixed height for animation space
      child: IgnorePointer( // Ensure it doesn't block other taps
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(-50, -30) + Offset(0, _translateY.value), // Apply centering offset here + animation
              child: Opacity(
                opacity: _opacity.value,
                child: Transform.scale(
                  scale: _scale.value,
                  child: Center(
                    child: Material(
                      type: MaterialType.transparency, // Needed if no ancestor Material
                      child: Text(
                        widget.text,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: widget.color ?? Colors.amberAccent,
                          fontSize: widget.fontSize ?? 28, 
                          fontWeight: widget.fontWeight ?? FontWeight.w900,
                          shadows: [
                            const Shadow(
                              color: Colors.black,
                              offset: Offset(2, 2),
                              blurRadius: 4,
                            ),
                            Shadow(
                              color: (widget.color ?? Colors.amber).withOpacity(0.6),
                              offset: const Offset(0, 0),
                              blurRadius: 10, // Glow effect
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
