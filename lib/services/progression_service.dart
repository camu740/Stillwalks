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
      Unlock.item('upgrade_tap_multiplier', description: "Ritmo Interior desbloqueado"),
    ]),
    LevelDefinition(level: 2, requiredXp: 250, unlocks: [
    ]),
    LevelDefinition(level: 3, requiredXp: 550, unlocks: [ 
      Unlock.item('energy_storage', description: "Almacén de Energía desbloqueado"),
      Unlock.item('building_mina', description: "Mina desbloqueada"),
    ]),
    LevelDefinition(level: 4, requiredXp: 1000, unlocks: [ 
      Unlock.item('upgrade_offline_efficiency', description: "Eco Persistente desbloqueado"),
      Unlock.item('building_cantera', description: "Cantera desbloqueada"),

    ]),
    LevelDefinition(level: 5, requiredXp: 1650, unlocks: [ 
      Unlock.item('upgrade_offline_time', description: "Eco Duradero desbloqueado"),
      Unlock.feature(ProgressionFeature.temporarySanctuarySlot, description: "Slot de Santuario Temporal"),
      Unlock.item(InventoryItemTypes.tempSanctuaryFastFlow, description: "Santuario Temporal: Fast Flow"),
    ]),
    LevelDefinition(level: 6, requiredXp: 2600, unlocks: [ 
      Unlock.item('orbe_advanced', description: "Orbe Avanzado"),
    ]),
    LevelDefinition(level: 7, requiredXp: 3550, unlocks: [ 
      Unlock.item('upgrade_global_multiplier', description: "Flujo Esencial desbloqueado"),
      Unlock.item(InventoryItemTypes.tempSanctuarySymbiosis, description: "Santuario Temporal: Simbiosis"),
    ]),
    LevelDefinition(level: 8, requiredXp: 5000, unlocks: [ 
      Unlock.item('building_yacimiento', description: "Yacimiento desbloqueado"),
    ]),
    LevelDefinition(level: 9, requiredXp: 6500, unlocks: [ 
      Unlock.item('orbe_expert', description: "Orbe Experto"),
    ]),
    LevelDefinition(level: 10, requiredXp: 9000, unlocks: [
      Unlock.item(InventoryItemTypes.tempSanctuaryQuietude, description: "Santuario Temporal: Quietud"),
    ]),
    LevelDefinition(level: 11, requiredXp: 11500, unlocks: [ 
      Unlock.item('building_fabrica', description: "Fábrica desbloqueada"),
    ]),
    LevelDefinition(level: 12, requiredXp: 15000, unlocks: [ 
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

  /// Returns the relative progress towards the next level as a value between 0.0 and 1.0.
  double getLevelProgress(int currentXp, int currentLevel) {
    final currentDef = getLevelDefinition(currentLevel);
    int startXp = currentDef.requiredXp;
    
    final nextLevelXp = getNextLevelXpRequirement(currentLevel);
    
    if (nextLevelXp == null) return 1.0; 
    
    int levelTotalXp = nextLevelXp - startXp;
    int currentLevelXp = currentXp - startXp;
    
    if (levelTotalXp <= 0) return 1.0; 
    
    return (currentLevelXp / levelTotalXp).clamp(0.0, 1.0);
  }
  
  /// Returns current XP accumulated within the current level (Relative XP).
  int getLevelRelativeXp(int currentXp, int currentLevel) {
      final currentDef = getLevelDefinition(currentLevel);
      // Ensure we don't return negative if for some reason xp < required (bug?)
      return (currentXp - currentDef.requiredXp).clamp(0, 999999);
  }

  /// Returns total XP required for the current level (End - Start).
  int getLevelXpRange(int currentLevel) {
     final currentDef = getLevelDefinition(currentLevel);
     final nextLevelXp = getNextLevelXpRequirement(currentLevel);
     if (nextLevelXp == null) return 0; 
     return nextLevelXp - currentDef.requiredXp;
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

    // Energy Storage specific logic
    if (type == 'energy_storage') {
      if (currentLevel < 3) return 0;
      // Formula: Cap 2 at L3, +2 every 2 levels. Max 15.
      int cap = 2 + ((currentLevel - 3) ~/ 2) * 2;
      return cap.clamp(0, 15);
    }

    // Unified Formula for Tap Strength (Smoother progression)
    if (type == 'tap_strength') {
        // Starts at cap 5 at L1, then +4 per level.
        int cap = 5 + (currentLevel - 1) * 4;
        return cap.clamp(1, 30);
    }

    // Ritmo Interior (Inner Rhythm) always cap 5
    if (type == 'tap_multiplier') {
        return 5;
    }

    // Checking Level 12+ for other types
    if (currentLevel >= 12) {
        // Regla general 12+: +1 al nivel máximo de todas por cada nivel
        final levelDiff = currentLevel - 11; // L12 -> 1.
        
        if (type == 'building_recolector') return (11 + levelDiff); 
        if (type == 'building_mina') return (9 + levelDiff);
        if (type == 'building_cantera') return (8 + levelDiff);
        if (type == 'building_yacimiento') return (4 + levelDiff);
        if (type == 'building_fabrica') return (1 + levelDiff);
        
        if (type == 'global_multiplier') return (7 + levelDiff).clamp(0, 20); // Flow
        if (type == 'offline_efficiency') return (6 + levelDiff).clamp(0, 15); // Echo
        if (type == 'offline_time') return (5 + levelDiff).clamp(0, 15); // Memory
        
        return 0;
    }

    // Explicit Levels 1-11
    switch (currentLevel) {
        case 1:
            if (type == 'building_recolector') return 3;
            break;
        case 2:
            if (type == 'building_recolector') return 5;
            break;
        case 3:
            if (type == 'building_recolector') return 7;
            if (type == 'building_mina') return 1;
            break;

        case 4:
            if (type == 'offline_efficiency') return 1;
            if (type == 'building_recolector') return 7; 
            if (type == 'building_mina') return 2;
            if (type == 'building_cantera') return 1;
            break;
        case 5:
            if (type == 'offline_efficiency') return 2;
            if (type == 'offline_time') return 1;
            if (type == 'building_recolector') return 7; 
            if (type == 'building_mina') return 3;
            if (type == 'building_cantera') return 2;
            break;
        case 6:
            if (type == 'offline_efficiency') return 3;
            if (type == 'offline_time') return 2;
            if (type == 'building_recolector') return 7; 
            if (type == 'building_mina') return 4;
            if (type == 'building_cantera') return 3;
            break;
        case 7:
            if (type == 'global_multiplier') return 1;
            if (type == 'offline_efficiency') return 4;
            if (type == 'offline_time') return 3;
            if (type == 'building_recolector') return 7;
            if (type == 'building_mina') return 5;
            if (type == 'building_cantera') return 4;
            break;
        case 8:
            if (type == 'global_multiplier') return 2;
            if (type == 'offline_efficiency') return 5;
            if (type == 'offline_time') return 4;
            if (type == 'building_recolector') return 8;
            if (type == 'building_mina') return 6;
            if (type == 'building_cantera') return 5;
            if (type == 'building_yacimiento') return 1;
            break;
        case 9:
            if (type == 'global_multiplier') return 3;
            if (type == 'offline_efficiency') return 6;
            if (type == 'offline_time') return 5;
            if (type == 'building_recolector') return 9;
            if (type == 'building_mina') return 7;
            if (type == 'building_cantera') return 6;
            if (type == 'building_yacimiento') return 2;
            break;
        case 10:
            if (type == 'global_multiplier') return 4;
            if (type == 'offline_efficiency') return 7;
            if (type == 'offline_time') return 6;
            if (type == 'building_recolector') return 10;
            if (type == 'building_mina') return 8;
            if (type == 'building_cantera') return 7;
            if (type == 'building_yacimiento') return 3;
            break;
        case 11:
            if (type == 'global_multiplier') return 5;
            if (type == 'offline_efficiency') return 8;
            if (type == 'offline_time') return 7;
            if (type == 'building_recolector') return 11;
            if (type == 'building_mina') return 9;
            if (type == 'building_cantera') return 8;
            if (type == 'building_yacimiento') return 4;
            if (type == 'building_fabrica') return 1;
            break;

    }
    
    // Sanctuary Logic
    if (type == 'sanctuary') {
        // Allow sanctuary speed upgrades to scale with level, slightly ahead
        // Start at 5, +1 per level? 
        // Or uncap it? If uncapped, return high value.
        // But Shop checks cap to show "Level X". 
        // Let's say: Level 1 -> Cap 5. Level 10 -> Cap 15.
        // Formula: currentLevel + 4?
        return currentLevel + 4;
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
