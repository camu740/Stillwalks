import 'package:flutter/foundation.dart';
import 'package:stillwalks/models/inventory_item.dart';
import 'package:stillwalks/models/upgrade.dart';

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
      Unlock.upgradeCap(0), 
    ]),
    LevelDefinition(level: 2, requiredXp: 250, unlocks: [
      Unlock.upgradeCap(2, description: "Mejoras de Santuario hasta Nivel 2", upgradeType: "sanctuary"),
    ]),
    LevelDefinition(level: 3, requiredXp: 550, unlocks: [ 
      Unlock.upgradeCap(2, description: "Mejoras de Recolector hasta Nivel 2", upgradeType: "idle_multiplier"),
    ]),
    LevelDefinition(level: 4, requiredXp: 1000, unlocks: [ 
      Unlock.upgradeCap(2, description: "Mejoras de Almacén hasta Nivel 2", upgradeType: "energy_storage"),
    ]),
    LevelDefinition(level: 5, requiredXp: 1650, unlocks: [ 
      Unlock.feature(ProgressionFeature.temporarySanctuarySlot, description: "Slot de Santuario Temporal"),
      Unlock.item(InventoryItemTypes.tempSanctuaryFastFlow, description: "Santuario Temporal: Fast Flow"),
    ]),
    LevelDefinition(level: 6, requiredXp: 2600, unlocks: [ 
      Unlock.item('orbe_advanced', description: "Orbe Avanzado"),
      Unlock.upgradeCap(4, description: "Todas las mejoras hasta Nivel 4"),
    ]),
    LevelDefinition(level: 7, requiredXp: 3550, unlocks: [ 
      Unlock.item(InventoryItemTypes.tempSanctuarySymbiosis, description: "Santuario Temporal: Simbiosis"),
    ]),
    LevelDefinition(level: 8, requiredXp: 5000, unlocks: [ 
      Unlock.upgradeCap(6, description: "Todas las mejoras hasta Nivel 6"),
    ]),
    LevelDefinition(level: 9, requiredXp: 6500, unlocks: [ 
      Unlock.item('orbe_expert', description: "Orbe Experto"),
      Unlock.item(InventoryItemTypes.tempSanctuaryQuietude, description: "Santuario Temporal: Quietud"),
    ]),
    LevelDefinition(level: 10, requiredXp: 9000, unlocks: [
      Unlock.upgradeCap(8, description: "Todas las mejoras hasta Nivel 8"),
    ]),
    LevelDefinition(level: 11, requiredXp: 11500, unlocks: [ 
      Unlock.upgradeCap(10, description: "Todas las mejoras hasta Nivel 10"),
    ]),
    LevelDefinition(level: 12, requiredXp: 15000, unlocks: [ 
      Unlock.upgradeCap(12, description: "Todas las mejoras hasta Nivel 12"),
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
  /// If type is 'sanctuary', it checks for sanctuary specific unlocks.
  /// If type is an UpgradeType enum string (e.g., 'UpgradeType.energyStorage'), it checks for that.
  int getUpgradeCap(int currentLevel, {String? type}) {
    int cap = 0;
    
    // Check all levels up to current
    for (var def in _levels) {
      if (def.level > currentLevel) break;
      for (var unlock in def.unlocks) {
        if (unlock.type == UnlockType.upgradeCap) {
          final unlockCap = unlock.value as int;
          
          // If this is a global cap (no type specified), it applies to everyone
          if (unlock.upgradeType == null) {
            if (unlockCap > cap) cap = unlockCap;
          } 
          // If this is a specific cap, it applies only if types match
          else if (type != null && unlock.upgradeType == type) {
             if (unlockCap > cap) cap = unlockCap;
          }
          // Special case: 'sanctuary' type might need to match if we pass 'sanctuary'
        }
      }
    }
    return cap;
  }
  
  /// Helper to find the level required to increase the upgrade cap BEYOND the current cap.
  int? getLevelRequiredForHigherCap(int currentCap, {String? type}) {
    for (var def in _levels) {
      for (var unlock in def.unlocks) {
        if (unlock.type == UnlockType.upgradeCap) {
           final unlockCap = unlock.value as int;
           final unlockType = unlock.upgradeType;
           
           bool isRelevant = (unlockType == null) || (type != null && unlockType == type);
           
           if (isRelevant && unlockCap > currentCap) return def.level;
        }
      }
    }
    return null; // Max cap reached
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
    return null; // Should not happen if item is restricted
  }
}
