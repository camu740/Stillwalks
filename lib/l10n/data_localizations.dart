import 'package:stillwalks/l10n/app_localizations.dart';
import 'package:stillwalks/models/upgrade.dart';
import 'package:stillwalks/models/inventory_item.dart';

/// Extension para traducir datos dinámicos (ids de BBDD) a Strings localizados
extension DataLocalizations on AppLocalizations {
  
  // ==================== UPGRADES ====================

  String getUpgradeName(UpgradeType type) {
    switch (type) {
      case UpgradeType.idleMultiplier:
        return upgradeIdleName;
      case UpgradeType.energyStorage:
        return upgradeStorageName;
      default:
        // Fallback genérico o nombre por defecto si existe
        return upgradeSpeedName; 
    }
  }

  String getUpgradeDescription(UpgradeType type) {
    switch (type) {
      case UpgradeType.idleMultiplier:
        return upgradeIdleDesc;
      case UpgradeType.energyStorage:
        return upgradeStorageDesc;
      default:
        return '';
    }
  }

  String getUpgradeBonusText(UpgradeType type) {
    switch (type) {
      case UpgradeType.idleMultiplier:
        return upgradeIdleBonus;
      case UpgradeType.energyStorage:
        return upgradeStorageBonus;
      default:
        return '';
    }
  }

  // ==================== SANCTUARIES ====================

  String getSanctuaryName(String id, String? typeId, String defaultName) {
    // 1. Santuarios fijos por ID
    if (id == 'sanc_primordial' || id == 'sanctuary_1') {
      return sancPrimordialName;
    }

    // 2. Santuarios temporales por TypeID
    if (typeId != null) {
      switch (typeId) {
        case InventoryItemTypes.tempSanctuaryFastFlow:
          return sancFastFlowName;
        case InventoryItemTypes.tempSanctuarySymbiosis:
          return sancSymbiosisName;
        case InventoryItemTypes.tempSanctuaryQuietude:
          return sancQuietudeName;
        case InventoryItemTypes.tempSanctuaryEcho:
          return sancEchoName;
        case InventoryItemTypes.tempSanctuaryResonance:
          return sancResonanceName;
      }
    }

    // 3. Fallback al nombre original (posiblemente personalizado por usuario en futuro)
    return defaultName;
  }

  String getSanctuaryDescription(String id, String? typeId, String defaultDesc) {
    if (id == 'sanc_primordial' || id == 'sanctuary_1') {
      return sancPrimordialDesc;
    }

    if (typeId != null) {
      switch (typeId) {
        case InventoryItemTypes.tempSanctuaryFastFlow:
          return sancFastFlowDesc;
        case InventoryItemTypes.tempSanctuarySymbiosis:
          return sancSymbiosisDesc;
        case InventoryItemTypes.tempSanctuaryQuietude:
          return sancQuietudeDesc;
        case InventoryItemTypes.tempSanctuaryEcho:
          return sancEchoDesc;
        case InventoryItemTypes.tempSanctuaryResonance:
          return sancResonanceDesc;
      }
    }

    return defaultDesc;
  }

  // ==================== ORBS ====================

  String getOrbName(String orbeTypeId, String defaultName) {
    switch (orbeTypeId) {
      case 'orbe_basic':
        return orbBasicName;
      case 'orbe_advanced':
        return orbAdvancedName;
      case 'orbe_expert':
        return orbExpertName;
      case 'orbe_quietude':
        return orbQuietudeName;
      case 'orbe_essence':
        return orbEssenceName;
      default:
        return defaultName;
    }
  }

  String getOrbDescription(String orbeTypeId, String defaultDesc) {
    switch (orbeTypeId) {
      case 'orbe_basic':
        return orbBasicDesc;
      case 'orbe_advanced':
        return orbAdvancedDesc;
      case 'orbe_expert':
        return orbExpertDesc;
      case 'orbe_quietude':
        return orbQuietudeDesc;
      case 'orbe_essence':
        return orbEssenceDesc;
      default:
        return defaultDesc;
    }
  }

  // ==================== CREATURES ====================

  String getCreatureDescription(String speciesId, String defaultDesc) {
    switch (speciesId) {
      case 'spiristone':
        return descSpiristone;
      case 'radispirit':
        return descRadispirit;
      case 'slugrry':
        return descSlugrry;
      default:
        return defaultDesc;
    }
  }

  String getTemporarySanctuaryAbilityDescription(String typeId) {
    switch (typeId) {
      case InventoryItemTypes.tempSanctuaryFastFlow:
        return abilityFastFlow;
      case InventoryItemTypes.tempSanctuarySymbiosis:
        return abilitySymbiosis;
      case InventoryItemTypes.tempSanctuaryQuietude:
        return abilityQuietude;
      case InventoryItemTypes.tempSanctuaryEcho:
        return abilityEcho;
      case InventoryItemTypes.tempSanctuaryResonance:
        return abilityResonance;
      default:
        return abilityActive;
    }
  }
}
