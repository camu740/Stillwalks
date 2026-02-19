
import 'package:flutter_test/flutter_test.dart';
import 'package:stillwalks/services/progression_service.dart';

void main() {
  group('ProgressionService Level Caps', () {
    final service = ProgressionService();

    test('Ritmo Interior should always have cap 5 from Level 1', () {
      expect(service.getUpgradeCap(1, type: 'tap_multiplier'), 5);
      expect(service.getUpgradeCap(5, type: 'tap_multiplier'), 5);
      expect(service.getUpgradeCap(10, type: 'tap_multiplier'), 5);
      expect(service.getUpgradeCap(20, type: 'tap_multiplier'), 5);
    });

    test('Fuerza de tap should scale: 5 at L1, then +4 per level, max 30', () {
      expect(service.getUpgradeCap(1, type: 'tap_strength'), 5);
      expect(service.getUpgradeCap(2, type: 'tap_strength'), 9);
      expect(service.getUpgradeCap(7, type: 'tap_strength'), 29);
      expect(service.getUpgradeCap(8, type: 'tap_strength'), 30);
    });

    test('Flujo Esencial should unlock at Level 7', () {
      expect(service.getUpgradeCap(6, type: 'global_multiplier'), 0);
      expect(service.getUpgradeCap(7, type: 'global_multiplier'), 1);
    });

    test('Eco Persistente should unlock at Level 4', () {
      expect(service.getUpgradeCap(3, type: 'offline_efficiency'), 0);
      expect(service.getUpgradeCap(4, type: 'offline_efficiency'), 1);
    });

    test('Eco Duradero should unlock at Level 5', () {
      expect(service.getUpgradeCap(4, type: 'offline_time'), 0);
      expect(service.getUpgradeCap(5, type: 'offline_time'), 1);
    });

    test('Energy Storage should unlock at Level 3', () {
      expect(service.getUpgradeCap(2, type: 'energy_storage'), 0);
      expect(service.getUpgradeCap(3, type: 'energy_storage'), 2);
    });
  });
}
