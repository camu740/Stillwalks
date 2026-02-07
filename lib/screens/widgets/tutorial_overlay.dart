import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stillwalks/services/tutorial_service.dart';

class TutorialOverlay extends StatelessWidget {
  final Widget child;

  const TutorialOverlay({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Consumer<TutorialService>(
      builder: (context, tutorialService, _) {
        if (!tutorialService.isActive || tutorialService.isLoading) {
          return child;
        }

        return Stack(
          children: [
            // The main app content
            child,
            
            // Overlay layer
            // We use a simplified approach: specific overlay widgets based on step
            // For a full "spotlight" library we'd need more complex implementation
            // Here we'll rely on passing a layout delegate or just simple blocking 
            // with holes if we know screen coordinates (hard).
            
            // Alternative: The overlay is transparent, but we render "Mask" 
            // around the target. 
            // For MVP, we will render a dark barrier that ignores clicks 
            // on the *specific target area* if possible, or just blocks *everything else*.
            
            if (tutorialService.currentStep != TutorialStep.none && 
                tutorialService.currentStep != TutorialStep.completed)
              _buildStepOverlay(context, tutorialService),
          ],
        );
      },
    );
  }

  Widget _buildStepOverlay(BuildContext context, TutorialService service) {
    if (service.targetRect != null) {
      return SpotlightBarrier(
        targetRect: service.targetRect!,
        onTapOutside: () {
          // Block interaction outside?
        },
      );
    }
  
    switch (service.currentStep) {
      case TutorialStep.welcome:
        // Handled by a Dialog in HomeScreen, just pass-through here or block interaction
        return Container(color: Colors.black54); 
        
      default:
        // By default, if no target is set but we are active, maybe just block everything?
        // Or let it pass through if we haven't set up the step yet.
        return const SizedBox.shrink();
    }
  }
}

/// A specialized widget to "punch a hole" in a barrier
class SpotlightBarrier extends StatelessWidget {
  final Rect targetRect;
  final VoidCallback? onTapOutside;

  const SpotlightBarrier({super.key, required this.targetRect, this.onTapOutside});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        IgnorePointer(
          child: ColorFiltered(
            colorFilter: const ColorFilter.mode(
              Colors.black54,
              BlendMode.srcOut,
            ),
            child: Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.transparent,
                    backgroundBlendMode: BlendMode.dstOut,
                  ),
                ),
                Positioned.fromRect(
                  rect: targetRect,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Tap handler for outside
        Positioned.fill(
          child: GestureDetector(
            onTap: onTapOutside,
            behavior: HitTestBehavior.deferToChild,
            child: CustomPaint(
              painter: _HolePainter(targetRect),
            ),
          ),
        ),
      ],
    );
  }
}

class _HolePainter extends CustomPainter {
  final Rect holeRect;

  _HolePainter(this.holeRect);

  @override
  void paint(Canvas canvas, Size size) {
    // Just for hit testing logic visualization if needed
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
  
  @override
  bool? hitTest(Offset position) {
    // Return true (handle tap) if OUTSIDE the hole
    return !holeRect.contains(position);
  }
}
