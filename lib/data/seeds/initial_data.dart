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
    // Siempre sembramos especies y tipos de orbe para asegurar que las actualizaciones
    // de assets o balanceo se reflejen (usan ConflictAlgorithm.replace)
    await _seedCreatureSpecies();
    await seedOrbeTypes();

    if (await isSeededRest()) {
      return;
    }
    await _seedSanctuaries();
    await seedUpgrades();
  }

  /// Verifica si los datos persistentes principales ya existen
  static Future<bool> isSeededRest() async {
    final sanctuaries = await _db.getAllSanctuaries();
    return sanctuaries.isNotEmpty;
  }

  /// Verifica si la base de datos ya fue inicializada (deprecated but kept for compatibility if used elsewhere)
  static Future<bool> isSeeded() async {
    return isSeededRest();
  }

  // ==================== CREATURE SPECIES ====================

  static Future<void> _seedCreatureSpecies() async {
    final species = [
      CreatureSpecies(
        id: 'yedrantia',
        name: 'Yedrantía',
        description: 'Yedrantía habita entre ruinas cubiertas de yedra y bosques antiguos. Se dice que protege los lugares donde fue invocada.',
        rarity: 'common',
        assetPath: 'assets/creatures/yedrantia.png',
        dexNumber: 1,
      ),
      CreatureSpecies(
        id: 'trasgueco',
        name: 'Trasgüeco',
        description: 'Trasgüeco habita en casas antiguas y hórreos apartados. Aunque parece una simple marioneta, se mueve cuando nadie lo observa.',
        rarity: 'common',
        assetPath: 'assets/creatures/trasgueco.png',
        dexNumber: 2,
      ),
      CreatureSpecies(
        id: 'harijaun',
        name: 'Harijaun',
        description: 'Harijaun protege los bosques más antiguos, donde sus pasos hacen temblar la tierra.',
        rarity: 'uncommon',
        assetPath: 'assets/creatures/harijaun.png',
        dexNumber: 3,
      ),
      CreatureSpecies(
        id: 'gamusarra',
        name: 'Gamusarra',
        description: 'Gamusarra habita en bosques y caminos rurales donde apenas se le puede ver. Atrae a los viajeros con ruidos extraños y saltos juguetones, pero cuando alguien se acerca demasiado, ataca con sus afiladas garras y desaparece entre la maleza. Se dice que solo aparece cuando nadie puede demostrar que realmente lo ha visto.',
        rarity: 'special',
        assetPath: 'assets/creatures/gamusarra.png',
        dexNumber: 0,
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
        'yedrantia': 0.45,
        'trasgueco': 0.45, 
        'harijaun': 0.10,
      },
    );

    final orbeAdvanced = OrbeType(
      id: 'orbe_advanced',
      requiredSteps: 5000,
      name: 'Orbe Avanzado',
      description: 'Mejora probabilidad de Poco Comunes. Requiere 5000 pasos.',
      lootTable: {
        'yedrantia': 0.25,
        'trasgueco': 0.25,
        'harijaun': 0.50,
      },
    );

    final orbeExpert = OrbeType(
      id: 'orbe_expert',
      requiredSteps: 10000,
      name: 'Orbe Experto',
      description: 'Mejora probabilidad de Raros. Requiere 10000 pasos.',
      lootTable: {
        'yedrantia': 0.10,
        'trasgueco': 0.10,
        'harijaun': 0.80,
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
      Upgrade(
        id: 'upgrade_tap_strength',
        type: UpgradeType.tapStrength,
        currentLevel: 1,
        name: 'Fuerza de Tap',
        description: 'Aumenta la cantidad de Esencia generada por click.',
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
