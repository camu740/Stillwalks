import 'package:stillwalks/models/inventory_item.dart';

enum ProgressionFeature {
  temporarySanctuarySlot,
  // Add more features here
}

enum UnlockType {
  feature,
  item,
  upgradeCap,
}

class Unlock {
  final UnlockType type;
  final dynamic value; // Feature enum, String (itemId), or int (cap)
  final String? description; // Optional description for UI
  final String? upgradeType; // Optional: specific upgrade type ID or 'sanctuary'

  const Unlock.feature(ProgressionFeature feature, {this.description})
      : type = UnlockType.feature,
        value = feature,
        upgradeType = null;

  const Unlock.item(String itemId, {this.description})
      : type = UnlockType.item,
        value = itemId,
        upgradeType = null;

  const Unlock.upgradeCap(int cap, {this.description, this.upgradeType})
      : type = UnlockType.upgradeCap,
        value = cap;
}

class LevelDefinition {
  final int level;
  final int requiredXp; // Cumulative XP to REACH this level
  final List<Unlock> unlocks;

  const LevelDefinition({
    required this.level,
    required this.requiredXp,
    this.unlocks = const [],
  });
}

class ProgressionService {
  // Static configuration of levels
  static const List<LevelDefinition> _levels = [
    LevelDefinition(level: 1, requiredXp: 0, unlocks: [
      Unlock.item('building_recolector', description: "Recolector unlocked"),
      Unlock.item('upgrade_tap_strength', description: "Fuerza de Tap desbloqueada"),
    ]),
    LevelDefinition(level: 2, requiredXp: 250, unlocks: [
      Unlock.item('upgrade_tap_multiplier', description: "Ritmo Interior desbloqueado"),
    ]),
    LevelDefinition(level: 3, requiredXp: 550, unlocks: [ 
      Unlock.item('building_mina', description: "Mina desbloqueada"),
    ]),
    LevelDefinition(level: 4, requiredXp: 1000, unlocks: [ 
        Unlock.item('building_cantera', description: "Cantera desbloqueada"),
    ]),
    LevelDefinition(level: 5, requiredXp: 1650, unlocks: [ 
      Unlock.item('upgrade_global_multiplier', description: "Flujo Esencial desbloqueado"),
      Unlock.feature(ProgressionFeature.temporarySanctuarySlot, description: "Slot de Santuario Temporal"),
       Unlock.item(InventoryItemTypes.tempSanctuaryFastFlow, description: "Santuario Temporal: Fast Flow"),
    ]),
    LevelDefinition(level: 6, requiredXp: 2600, unlocks: [ 
      Unlock.item('upgrade_offline_efficiency', description: "Eco Persistente desbloqueado"),
      Unlock.item('orbe_advanced', description: "Orbe Avanzado"),
    ]),
    LevelDefinition(level: 7, requiredXp: 3550, unlocks: [ 
      Unlock.item('upgrade_offline_time', description: "Memoria Persistente desbloqueada"),
      Unlock.item(InventoryItemTypes.tempSanctuarySymbiosis, description: "Santuario Temporal: Simbiosis"),
    ]),
    LevelDefinition(level: 8, requiredXp: 5000, unlocks: [ 
      Unlock.item('building_yacimiento', description: "Yacimiento desbloqueado"),
    ]),
    LevelDefinition(level: 9, requiredXp: 6500, unlocks: [ 
      Unlock.item('orbe_expert', description: "Orbe Experto"),
      Unlock.item(InventoryItemTypes.tempSanctuaryQuietude, description: "Santuario Temporal: Quietud"),
    ]),
    LevelDefinition(level: 10, requiredXp: 9000, unlocks: [
       // No news
    ]),
    LevelDefinition(level: 11, requiredXp: 11500, unlocks: [ 
      Unlock.item('building_fabrica', description: "Fábrica desbloqueada"),
    ]),
    LevelDefinition(level: 12, requiredXp: 15000, unlocks: [ 
        // 12+ General rule
    ]),
  ];

  /// Returns the LevelDefinition for a specific level.
  /// If level exceeds max defined, returns the last defined level (or a fallback).
  LevelDefinition getLevelDefinition(int level) {
    if (level < 1) return _levels.first;
    if (level > _levels.last.level) return _levels.last;
    return _levels.firstWhere((l) => l.level == level, orElse: () => _levels.last);
  }

  /// Calculates the current level based on total XP.
  int calculateLevel(int currentXp) {
    int level = 1;
    for (var def in _levels) {
      if (currentXp >= def.requiredXp) {
        level = def.level;
      } else {
        break;
      }
    }
    return level;
  }


  /// Checks if an item (ID) is unlocked at the given level.
  bool isItemUnlocked(int currentLevel, String itemId) {
    // Basic items are always unlocked (level 1 check usually suffices if properly defined)
    if (itemId == 'orbe_basic') return true;
    
    // Check if explicitly unlocked in definitions
    for (var def in _levels) {
      if (def.level > currentLevel) break;
      for (var unlock in def.unlocks) {
        if (unlock.type == UnlockType.item && unlock.value == itemId) {
          return true;
        }
      }
    }
    return false;
  }

  /// Returns XP required to reach the NEXT level.
  int? getNextLevelXpRequirement(int currentLevel) {
    final nextLevel = currentLevel + 1;
    if (nextLevel > _levels.last.level) return null;
    return getLevelDefinition(nextLevel).requiredXp;
  }

  /// Checks if a feature is unlocked at the given level.
  bool isFeatureUnlocked(int currentLevel, ProgressionFeature feature) {
    for (var def in _levels) {
      if (def.level > currentLevel) break;
      for (var unlock in def.unlocks) {
        if (unlock.type == UnlockType.feature && unlock.value == feature) {
          return true;
        }
      }
    }
    return false;
  }

  /// Gets the upgrade level cap for the current explorer level and specific upgrade type.
  /// Standardizes limits based on Balance Document formulas (Section 8).
  int getUpgradeCap(int currentLevel, {String? type}) {
    if (type == null) return 0;

    // Hardcode limits based on Level 1-11+ tables
    
    // Limits map key: type, value: maxLevel
    // We can use a switch on currentLevel
    
    // Helper to get building limits
    // Force specific limits as per doc
    
    if (currentLevel >= 12) {
        // Regla general 12+: +1 al nivel máximo de todas por cada nivel
        // Topes globales: Tap: 20, Rhythm: 15, Flow: 20, Echo: 15, Memory: 15.
        // Buildings: ??? Doc says "Aumenta en +1 el nivel máximo de todas las mejoras y edificios".
        // Base values at L11:
        // Tap: 11. Recolector: 11. Mina: 9. Cantera: 8. Yacimiento: 4. Fabrica: 1.
        // Rhythm: 10. Flow: 7. Echo: 6. Memory: 5.
        
        final levelDiff = currentLevel - 11; // L12 -> 1.
        
        if (type == 'tap_strength') return (11 + levelDiff).clamp(0, 20);
        if (type == 'building_recolector') return (11 + levelDiff); // Unlimited? Or soft cap?
        if (type == 'building_mina') return (9 + levelDiff);
        if (type == 'building_cantera') return (8 + levelDiff);
        if (type == 'building_yacimiento') return (4 + levelDiff);
        if (type == 'building_fabrica') return (1 + levelDiff);
        
        if (type == 'tap_multiplier') return (10 + levelDiff).clamp(0, 15); // Rhythm
        if (type == 'global_multiplier') return (7 + levelDiff).clamp(0, 20); // Flow
        if (type == 'offline_efficiency') return (6 + levelDiff).clamp(0, 15); // Echo
        if (type == 'offline_time') return (5 + levelDiff).clamp(0, 15); // Memory
        
        return 0;
    }

    // Explicit Levels 1-11
    switch (currentLevel) {
        case 1:
            if (type == 'tap_strength') return 1;
            if (type == 'building_recolector') return 1;
            break;
        case 2:
            if (type == 'tap_strength') return 2;
            if (type == 'tap_multiplier') return 1;
            if (type == 'building_recolector') return 2;
            break;
        case 3:
            if (type == 'tap_strength') return 3;
            if (type == 'tap_multiplier') return 2;
            if (type == 'building_recolector') return 3;
            if (type == 'building_mina') return 1;
            break;
        case 4:
            if (type == 'tap_strength') return 4;
            if (type == 'tap_multiplier') return 3;
            if (type == 'building_recolector') return 4;
            if (type == 'building_mina') return 2;
            if (type == 'building_cantera') return 1;
            break;
        case 5:
            if (type == 'tap_strength') return 5;
            if (type == 'tap_multiplier') return 4;
            if (type == 'global_multiplier') return 1;
            if (type == 'building_recolector') return 5;
            if (type == 'building_mina') return 3;
            if (type == 'building_cantera') return 2;
            break;
        case 6:
            if (type == 'tap_strength') return 6;
            if (type == 'tap_multiplier') return 5;
            if (type == 'global_multiplier') return 2;
            if (type == 'offline_efficiency') return 1;
            if (type == 'building_recolector') return 6;
            if (type == 'building_mina') return 4;
            if (type == 'building_cantera') return 3;
            break;
        case 7:
            if (type == 'tap_strength') return 7;
            if (type == 'tap_multiplier') return 6;
            if (type == 'global_multiplier') return 3;
            if (type == 'offline_efficiency') return 2;
            if (type == 'offline_time') return 1;
            if (type == 'building_recolector') return 7;
            if (type == 'building_mina') return 5;
            if (type == 'building_cantera') return 4;
            break;
        case 8:
            if (type == 'tap_strength') return 8;
            if (type == 'tap_multiplier') return 7;
            if (type == 'global_multiplier') return 4;
            if (type == 'offline_efficiency') return 3;
            if (type == 'offline_time') return 2;
            if (type == 'building_recolector') return 8;
            if (type == 'building_mina') return 6;
            if (type == 'building_cantera') return 5;
            if (type == 'building_yacimiento') return 1;
            break;
        case 9:
            if (type == 'tap_strength') return 9;
            if (type == 'tap_multiplier') return 8;
            if (type == 'global_multiplier') return 5;
            if (type == 'offline_efficiency') return 4;
            if (type == 'offline_time') return 3;
            if (type == 'building_recolector') return 9;
            if (type == 'building_mina') return 7;
            if (type == 'building_cantera') return 6;
            if (type == 'building_yacimiento') return 2;
            break;
        case 10:
            if (type == 'tap_strength') return 10;
            if (type == 'tap_multiplier') return 9;
            if (type == 'global_multiplier') return 6;
            if (type == 'offline_efficiency') return 5;
            if (type == 'offline_time') return 4;
            if (type == 'building_recolector') return 10;
            if (type == 'building_mina') return 8;
            if (type == 'building_cantera') return 7;
            if (type == 'building_yacimiento') return 3;
            break;
        case 11:
            if (type == 'tap_strength') return 11;
            if (type == 'tap_multiplier') return 10;
            if (type == 'global_multiplier') return 7;
            if (type == 'offline_efficiency') return 6;
            if (type == 'offline_time') return 5;
            if (type == 'building_recolector') return 11;
            if (type == 'building_mina') return 9;
            if (type == 'building_cantera') return 8;
            if (type == 'building_yacimiento') return 4;
            if (type == 'building_fabrica') return 1;
            break;
    }
    
    // Also check Energy Storage? Not in document, assume open or existing logic?
    // Maintain existing logic if it was dynamic, OR if it's not restricted, allow it?
    // Use fallback for energy_storage if not restricted by doc.
    if (type == 'energy_storage') {
         // Existing formula was: ((Level - 1) / 3) + 1 approx?
         // Let's use generic formula: Level based cap?
         // Doc doesn't restrict Energy Storage explicitly in Section 8.
         // But "Almacén de Energía" is unlocked at L4 in old code.
         // Let's unlock at L1 (always useful) or keep at L4?
         // Let's keep existing logic if any, or default to reasonable cap.
         return currentLevel + 2; // Loose cap
    }

    return 0; // Default locked if not matched
  }
  
  /// Helper to find the level required to increase the upgrade cap BEYOND the current cap.
  int? getLevelRequiredForHigherCap(int currentCap, {String? type}) {
    if (type == null) return null;
    
    // Iterate from level 1 up to a reasonable max (e.g. 60) to find when cap > currentCap
    // Optimization: Start checking from a likely level? But levels are small enough.
    // Let's iterate 1 to 100.
    for (int lvl = 1; lvl <= 100; lvl++) {
       int capAtLvl = getUpgradeCap(lvl, type: type);
       if (capAtLvl > currentCap) {
         return lvl;
       }
    }
    return null; // Max cap reached or not found
  }
  
  /// Helper to get the level required to unlock an item (for UI display)
  int? getRequiredLevelForItem(String itemId) {
    if (itemId == 'orbe_basic') return 1;
    for (var def in _levels) {
      for (var unlock in def.unlocks) {
        if (unlock.type == UnlockType.item && unlock.value == itemId) {
          return def.level;
        }
      }
    }
    return null; 
  }
}
