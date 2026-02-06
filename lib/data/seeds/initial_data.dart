import 'package:stillwalks/models/creature_species.dart';
import 'package:stillwalks/models/orbe.dart';
import 'package:stillwalks/models/sanctuary.dart';
import 'package:stillwalks/models/upgrade.dart';
import 'package:stillwalks/data/database/database_helper.dart';

/// Datos iniciales para el MVP
class InitialData {
  static final DatabaseHelper _db = DatabaseHelper();

  /// Inicializa todos los datos semilla del juego
  static Future<void> seedDatabase() async {
    if (await isSeeded()) {
      // Ensure new orbs types are updated/added
      await seedOrbeTypes();
      return;
    }
    await _seedCreatureSpecies();
    await seedOrbeTypes();
    await _seedSanctuaries();
    await seedUpgrades();
  }

  /// Verifica si la base de datos ya fue inicializada
  static Future<bool> isSeeded() async {
    final species = await _db.getAllCreatureSpecies();
    return species.isNotEmpty;
  }

  // ==================== CREATURE SPECIES ====================

  static Future<void> _seedCreatureSpecies() async {
    final species = [
      CreatureSpecies(
        id: 'spiristone',
        name: 'Spiristone',
        description: 'Una pequeña piedra encantada con manitas y piernitas. Curiosa y amigable.',
        rarity: 'common',
        assetPath: 'assets/creatures/spiristone.png',
        dexNumber: 1,
      ),
      CreatureSpecies(
        id: 'radispirit',
        name: 'Radispirit',
        description: 'Un rábano mágico que camina sobre cuatro patas. Sus hojas brillan al atardecer.',
        rarity: 'uncommon',
        assetPath: 'assets/creatures/radispirit.png',
        dexNumber: 2,
      ),
      CreatureSpecies(
        id: 'slugrry',
        name: 'Slugrry',
        description: 'Una babosa peluda blanca de movimientos lentos pero pensamiento rápido.',
        rarity: 'rare',
        assetPath: 'assets/creatures/slugrry.png',
        dexNumber: 3,
      ),
    ];

    for (final s in species) {
      await _db.insertCreatureSpecies(s.toJson());
    }
  }

  // ==================== ORBE TYPES ====================

  static Future<void> seedOrbeTypes() async {
    final orbeType = OrbeType(
      id: 'orbe_basic',
      requiredSteps: 2000,
      name: 'Orbe Básico',
      description: 'Un Orbe común que requiere 2000 pasos para canalizar.',
      lootTable: {
        'spiristone': 0.50,  // 50%
        'radispirit': 0.35,  // 35%
        'slugrry': 0.15,     // 15%
      },
    );

    final orbeAdvanced = OrbeType(
      id: 'orbe_advanced',
      requiredSteps: 5000,
      name: 'Orbe Avanzado',
      description: 'Mejora probabilidad de Poco Comunes. Requiere 5000 pasos.',
      lootTable: {
        'spiristone': 0.30,  // 30%
        'radispirit': 0.50,  // 50%
        'slugrry': 0.20,     // 20%
      },
    );

    final orbeExpert = OrbeType(
      id: 'orbe_expert',
      requiredSteps: 10000,
      name: 'Orbe Experto',
      description: 'Mejora probabilidad de Raros. Requiere 10000 pasos.',
      lootTable: {
        'spiristone': 0.10,  // 10%
        'radispirit': 0.40,  // 40%
        'slugrry': 0.50,     // 50%
      },
    );

    // Special orbs removed - keeping only standard progression orbs

    await _db.insertOrbeType(orbeType.toJson());
    await _db.insertOrbeType(orbeAdvanced.toJson());
    await _db.insertOrbeType(orbeExpert.toJson());
  }

  // ==================== SANCTUARIES ====================

  static Future<void> _seedSanctuaries() async {
    final sanctuary = Sanctuary(
      id: 'sanctuary_1',
      speedMultiplier: 1.0,
      name: 'Santuario Primordial',
      description: 'El primer santuario descubierto. Un lugar tranquilo donde los Orbes pueden canalizar su energía.',
    );

    await _db.insertSanctuary(sanctuary.toJson());
  }

  // ==================== UPGRADES ====================

  static Future<void> seedUpgrades() async {
    final upgrades = [
      Upgrade(
        id: 'upgrade_idle_multiplier',
        type: UpgradeType.idleMultiplier,
        currentLevel: 0,
        name: 'Recolector de Esencia',
        description: 'Aumenta la velocidad de generación pasiva de Esencia.',
      ),
    ];

    for (final upgrade in upgrades) {
      await _db.insertUpgrade(upgrade.toJson());
    }
  }

  // ==================== UTILIDADES ====================

  /// Obtiene el costo base de un Orbe básico
  static double getBasicOrbeCost() {
    return 500.0; // 500 Esencia
  }
}
