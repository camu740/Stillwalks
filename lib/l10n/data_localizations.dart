import 'package:stillwalks/l10n/app_localizations.dart';
import 'package:stillwalks/models/upgrade.dart';
import 'package:stillwalks/models/building.dart';
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
      case UpgradeType.tapStrength:
        return upgradeTapStrengthName;
      case UpgradeType.tapMultiplier:
        return upgradeTapMultiplierName;
      case UpgradeType.globalMultiplier:
        return upgradeGlobalMultiplierName;
      case UpgradeType.offlineEfficiency:
        return upgradeOfflineEfficiencyName;
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
      case UpgradeType.tapStrength:
        return upgradeTapStrengthDesc;
      case UpgradeType.tapMultiplier:
        return upgradeTapMultiplierDesc;
      case UpgradeType.globalMultiplier:
        return upgradeGlobalMultiplierDesc;
      case UpgradeType.offlineEfficiency:
        return upgradeOfflineEfficiencyDesc;
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
      case UpgradeType.tapStrength:
        return '+1 ${perLevel}';
      case UpgradeType.tapMultiplier:
        return 'x1.5 ${perLevel}';
      case UpgradeType.globalMultiplier:
        return '+20% ${perLevel}';
      case UpgradeType.offlineEfficiency:
        return '+5% ${perLevel}';
      default:
        return '';
    }
  }

  // ==================== BUILDINGS ====================

  String getBuildingName(BuildingType type) {
    switch (type) {
      case BuildingType.recolector:
        return building_recolector_name;
      case BuildingType.mina:
        return building_mina_name;
      case BuildingType.cantera:
        return building_cantera_name;
      case BuildingType.yacimiento:
        return building_yacimiento_name;
      case BuildingType.fabrica:
        return building_fabrica_name;
    }
  }

  String getBuildingDescription(BuildingType type) {
    switch (type) {
      case BuildingType.recolector:
        return building_recolector_desc;
      case BuildingType.mina:
        return building_mina_desc;
      case BuildingType.cantera:
        return building_cantera_desc;
      case BuildingType.yacimiento:
        return building_yacimiento_desc;
      case BuildingType.fabrica:
        return building_fabrica_desc;
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
  
  String getCreatureName(String speciesId, String defaultName) {
    switch (speciesId) {
      case 'spiristone':
        return nameSpiristone;
      case 'radispirit':
        return nameRadispirit;
      case 'slugrry':
        return nameSlugrry;
      case 'gamusarra':
        return nameGamusarra;
      default:
        return defaultName;
    }
  }

  String getCreatureDescription(String speciesId, String defaultDesc) {
    switch (speciesId) {
      case 'spiristone':
        return descSpiristone;
      case 'radispirit':
        return descRadispirit;
      case 'slugrry':
        return descSlugrry;
      case 'gamusarra':
        return descGamusarra;
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
