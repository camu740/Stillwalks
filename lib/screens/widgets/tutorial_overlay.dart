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
              Positioned.fill(
                child: _buildStepOverlay(context, tutorialService),
              ),
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

class SpotlightBarrier extends StatelessWidget {
  final Rect targetRect;
  final VoidCallback? onTapOutside;

  const SpotlightBarrier({super.key, required this.targetRect, this.onTapOutside});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    
    // Create 4 blocks around the target rect
    return Stack(
      children: [
        // Top
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: targetRect.top,
          child: GestureDetector(
            onTap: onTapOutside,
            behavior: HitTestBehavior.opaque,
            child: Container(color: Colors.black54),
          ),
        ),
        // Bottom
        Positioned(
          top: targetRect.bottom,
          left: 0,
          right: 0,
          bottom: 0,
          child: GestureDetector(
            onTap: onTapOutside,
            behavior: HitTestBehavior.opaque,
            child: Container(color: Colors.black54),
          ),
        ),
        // Left
        Positioned(
          top: targetRect.top,
          left: 0,
          width: targetRect.left,
          height: targetRect.height,
          child: GestureDetector(
            onTap: onTapOutside,
            behavior: HitTestBehavior.opaque,
             child: Container(color: Colors.black54),
          ),
        ),
        // Right
        Positioned(
          top: targetRect.top,
          left: targetRect.right,
          right: 0,
          height: targetRect.height,
           child: GestureDetector(
            onTap: onTapOutside,
            behavior: HitTestBehavior.opaque,
             child: Container(color: Colors.black54),
          ),
        ),
        // Border around target (optional visual flair)
         Positioned.fromRect(
           rect: targetRect.inflate(4), // Little padding
           child: IgnorePointer(
             child: Container(
               decoration: BoxDecoration(
                 borderRadius: BorderRadius.circular(12),
                 border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
                 boxShadow: [
                   BoxShadow(
                     color: Colors.white.withOpacity(0.2),
                     blurRadius: 8,
                     spreadRadius: 2,
                   )
                 ]
               ),
             ),
           ),
         ),
      ],
    );
  }
}
