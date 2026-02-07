import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum TutorialStep {
  none,            // Tutorial not active / completed (or not started but checked)
  welcome,         // 1. Welcome dialog & Essence grant
  shop,            // 2. Guide to Shop tab & Buy Orb
  sanctuary,       // 3. Guide to Sanctuary & Assign Orb
  energyIntro,     // 4. Energy explanation dialog
  hatch,           // 5. Ready to hatch -> Force Stillwalk
  adventureContinues, // 6. Final message after leveling up first creature
  completed        // 7. Tutorial finished
}

class TutorialService extends ChangeNotifier {
  static const String _prefTutorialKey = 'tutorial_step_index';
  
  TutorialStep _currentStep = TutorialStep.none;
  bool _isLoading = true;
  Rect? _targetRect;

  TutorialStep get currentStep => _currentStep;
  bool get isLoading => _isLoading;
  Rect? get targetRect => _targetRect;
  
  void setTarget(Rect? rect) {
    _targetRect = rect;
    notifyListeners();
  }
  
  // Getters helpers
  bool get isActive => _currentStep != TutorialStep.completed && _currentStep != TutorialStep.none;
  bool get isCompleted => _currentStep == TutorialStep.completed;

  // Specific state checks for UI blocking/highlighting
  bool get allowShopAccess => _currentStep == TutorialStep.shop || isCompleted;
  bool get allowInventoryAccess => _currentStep == TutorialStep.sanctuary || isCompleted;
  bool get allowChanneling => _currentStep == TutorialStep.hatch || isCompleted;

  TutorialService() {
    _loadState();
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    final stepIndex = prefs.getInt(_prefTutorialKey) ?? 0;
    
    // Default to 'welcome' if new user (index 0), else map index to enum
    if (stepIndex == 0) {
      _currentStep = TutorialStep.welcome; 
    } else {
      // If saved index exceeds enum options, assume completed
      if (stepIndex >= TutorialStep.values.length) {
        _currentStep = TutorialStep.completed;
      } else {
        _currentStep = TutorialStep.values[stepIndex];
      }
    }
    
    // Fix: If it was 'none' (index 0) but we want to start it, logic is handled above.
    // If we want to allow existing users to skip, we need a separate check.
    // For now, assuming new feature rollout -> everyone gets it if not marked completed?
    // User request: "tutorial para NUEVOS jugadores".
    // Existing players might have data. We should check if they have creatures/orbs?
    // But for simplicity, we focus on the _prefTutorialKey.
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> nextStep() async {
    if (_currentStep == TutorialStep.completed) return;

    final nextIndex = _currentStep.index + 1;
    if (nextIndex < TutorialStep.values.length) {
      _currentStep = TutorialStep.values[nextIndex];
    } else {
      _currentStep = TutorialStep.completed;
    }
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefTutorialKey, _currentStep.index);
    
    notifyListeners();
    debugPrint('🎓 TutorialService: Advanced to $_currentStep');
  }

  Future<void> completeTutorial() async {
    _currentStep = TutorialStep.completed;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefTutorialKey, TutorialStep.completed.index);
    notifyListeners();
  }
  
  // Debug / Reset
  Future<void> resetTutorial() async {
    _currentStep = TutorialStep.welcome;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefTutorialKey, TutorialStep.welcome.index);
    notifyListeners();
  }
}
