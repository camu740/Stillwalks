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
      Unlock.item('building_recolector', description: "Recolector desbloqueado"),
      // Caps handled dynamically
    ]),
    LevelDefinition(level: 2, requiredXp: 250, unlocks: [
      // Caps handled dynamically
    ]),
    LevelDefinition(level: 3, requiredXp: 550, unlocks: [ 
      Unlock.item('building_mina', description: "Mina desbloqueada"),
    ]),
    LevelDefinition(level: 4, requiredXp: 1000, unlocks: [ 
       Unlock.item('energy_storage', description: "Almacén de Energía desbloqueado"),
    ]),
    LevelDefinition(level: 5, requiredXp: 1650, unlocks: [ 
      Unlock.feature(ProgressionFeature.temporarySanctuarySlot, description: "Slot de Santuario Temporal"),
      Unlock.item(InventoryItemTypes.tempSanctuaryFastFlow, description: "Santuario Temporal: Fast Flow"),
      Unlock.item('building_cantera', description: "Cantera desbloqueada"),
    ]),
    LevelDefinition(level: 6, requiredXp: 2600, unlocks: [ 
      Unlock.item('orbe_advanced', description: "Orbe Avanzado"),
    ]),
    LevelDefinition(level: 7, requiredXp: 3550, unlocks: [ 
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
       // Caps handled dynamically
    ]),
    LevelDefinition(level: 11, requiredXp: 11500, unlocks: [ 
      Unlock.item('building_fabrica', description: "Fábrica desbloqueada"),
    ]),
    LevelDefinition(level: 12, requiredXp: 15000, unlocks: [ 
       // Caps handled dynamically
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
    // Basic items are always unlocked (level 1)
    if (itemId == 'orbe_basic') return true;
    
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
  /// Returns null if max level.
  int? getNextLevelXpRequirement(int currentLevel) {
    final nextLevel = currentLevel + 1;
    if (nextLevel > _levels.last.level) return null;
    return getLevelDefinition(nextLevel).requiredXp;
  }

  /// Checks if a feature is unlocked at the given level.
  bool isFeatureUnlocked(int currentLevel, ProgressionFeature feature) {
    // Check all levels up to currentLevel to see if feature was unlocked
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
  /// Standardizes limits based on Balance Document formulas.
  int getUpgradeCap(int currentLevel, {String? type}) {
    // 1. Building Limits (building_*)
    if (type != null && type.startsWith('building_')) {
      // Formula: ((Level - 1) / 2) + 1
      // L1: 0/2 + 1 = 1
      // L2: 1/2 + 1 = 1
      // L3: 2/2 + 1 = 2
      // Check if the building item itself is unlocked first?
      // isItemUnlocked checks if it's in the list.
      if (!isItemUnlocked(currentLevel, type)) return 0;
      
      return ((currentLevel - 1) ~/ 2) + 1;
    }

    // 2. Standard Upgrade Limits (including sanctuary and others not building_*)
    if (type != null) {
       // Formula from UpgradeType (L1-3: 1, L4-6: 2...)
       // Formula: ((Level - 1) / 3) + 1
       // L1: 0/3 + 1 = 1
       // L4: 3/3 + 1 = 2
       return ((currentLevel - 1) ~/ 3) + 1;
    }
    
    // Fallback (should typically not reach here if type is provided)
    return 0;
  }
  
  /// Helper to find the level required to increase the upgrade cap BEYOND the current cap.
  int? getLevelRequiredForHigherCap(int currentCap, {String? type}) {
    // 1. Buildings
    if (type != null && type.startsWith('building_')) {
       // Formula: ((Level - 1) / 2) + 1 = Cap
       // We want next Cap = currentCap + 1
       // ((L - 1) / 2) + 1 = currentCap + 1
       // (L - 1) / 2 = currentCap
       // L - 1 = 2 * currentCap
       // L = 2 * currentCap + 1
       return (2 * currentCap) + 1;
    }
    
    // 2. Upgrades (Standard & Sanctuary)
    // Formula: ((Level - 1) / 3) + 1 = Cap
    // Target Cap = currentCap + 1
    // ((L - 1) / 3) + 1 = currentCap + 1
    // (L - 1) / 3 = currentCap
    // L - 1 = 3 * currentCap
    // L = 3 * currentCap + 1
    return (3 * currentCap) + 1;
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
