
// Mock classes to test ProgressionService logic
class ProgressionService {
  int getUpgradeCap(int currentLevel, {String? type}) {
    if (type == null) return 0;

    // Unified Formula for Tap Strength (Smoother progression)
    if (type == 'tap_strength') {
        int cap;
        if (currentLevel >= 12) {
            final levelDiff = currentLevel - 11;
            cap = (11 + levelDiff);
        } else {
            cap = (currentLevel + 1);
        }
        return cap.clamp(0, 30);
    }

    if (currentLevel >= 12) {
        final levelDiff = currentLevel - 11;
        if (type == 'building_recolector') return (11 + levelDiff);
        return 0;
    }

    switch (currentLevel) {
        case 1:
            if (type == 'building_recolector') return 3;
            break;
        case 2:
            if (type == 'building_recolector') return 5;
            break;
        case 3:
            if (type == 'building_recolector') return 7;
            break;
        case 4:
            if (type == 'building_recolector') return 7;
            break;
        case 5:
            if (type == 'building_recolector') return 7;
            break;
        case 6:
            if (type == 'building_recolector') return 7;
            break;
        case 7:
            if (type == 'building_recolector') return 7;
            break;
        case 8:
            if (type == 'building_recolector') return 8;
            break;
        case 9:
            if (type == 'building_recolector') return 9;
            break;
        case 10:
            if (type == 'building_recolector') return 10;
            break;
        case 11:
            if (type == 'building_recolector') return 11;
            break;
    }
    return 0;
  }
}

void main() {
  final service = ProgressionService();
  
  print('--- Tap Strength Caps ---');
  for (int i = 1; i <= 15; i++) {
    print('Explorer Level $i: Cap ${service.getUpgradeCap(i, type: 'tap_strength')}');
  }

  print('\n--- Building Recolector Caps ---');
  for (int i = 1; i <= 15; i++) {
    print('Explorer Level $i: Cap ${service.getUpgradeCap(i, type: 'building_recolector')}');
  }
}
