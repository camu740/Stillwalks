import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:stillwalks/data/seeds/initial_data.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'stillwalks.db');
    
    return await openDatabase(
      path,
      version: 9,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Tabla de estado del jugador
    await db.execute('''
      CREATE TABLE player_state (
        id INTEGER PRIMARY KEY CHECK (id = 1),
        totalEsencia REAL NOT NULL DEFAULT 0,
        idleMultiplier REAL NOT NULL DEFAULT 1.0,
        lastActiveTimestamp TEXT NOT NULL,
        totalSteps INTEGER NOT NULL DEFAULT 0,
        storedSteps INTEGER NOT NULL DEFAULT 0,
        explorerLevel INTEGER NOT NULL DEFAULT 1,
        currentXp INTEGER NOT NULL DEFAULT 0,
        lastBootTime TEXT
      )
    ''');

    // Tabla de santuarios (mejorada para temporales)
    await db.execute('''
      CREATE TABLE sanctuaries (
        id TEXT PRIMARY KEY,
        speedMultiplier REAL NOT NULL DEFAULT 1.0,
        orbeId TEXT,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        isTemporary INTEGER NOT NULL DEFAULT 0,
        remainingUses INTEGER NOT NULL DEFAULT 0,
        typeId TEXT,
        speedUpgradeLevel INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (orbeId) REFERENCES orbes(id) ON DELETE SET NULL
      )
    ''');

    // Tabla de tipos de Orbe
    await db.execute('''
      CREATE TABLE orbe_types (
        id TEXT PRIMARY KEY,
        requiredSteps INTEGER NOT NULL,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        lootTable TEXT NOT NULL,
        mechanics TEXT
      )
    ''');

    // Tabla de Orbes (instancias)
    await db.execute('''
      CREATE TABLE orbes (
        id TEXT PRIMARY KEY,
        orbeTypeId TEXT NOT NULL,
        currentProgress INTEGER NOT NULL DEFAULT 0,
        stillwalkId TEXT,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (orbeTypeId) REFERENCES orbe_types(id),
        FOREIGN KEY (stillwalkId) REFERENCES creature_instances(id)
      )
    ''');

    // Tabla de especies de criaturas (datos estáticos)
    await db.execute('''
      CREATE TABLE creature_species (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        rarity TEXT NOT NULL,
        assetPath TEXT NOT NULL,
        dexNumber INTEGER NOT NULL UNIQUE
      )
    ''');

    // Tabla de instancias de criaturas capturadas
    await db.execute('''
      CREATE TABLE creature_instances (
        id TEXT PRIMARY KEY,
        speciesId TEXT NOT NULL,
        caughtAt TEXT NOT NULL,
        nickname TEXT,
        currentForm INTEGER NOT NULL DEFAULT 0,
        isFavorite INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (speciesId) REFERENCES creature_species(id)
      )
    ''');

    // Tabla de inventario (Bolsa) para consumibles/objetos
    await db.execute('''
      CREATE TABLE inventory_items (
        id TEXT PRIMARY KEY,
        typeId TEXT NOT NULL,
        quantity INTEGER NOT NULL DEFAULT 1,
        metadata TEXT
      )
    ''');

    // Tabla de mejoras
    await db.execute('''
      CREATE TABLE upgrades (
        id TEXT PRIMARY KEY,
        type TEXT NOT NULL,
        currentLevel INTEGER NOT NULL DEFAULT 0,
        name TEXT NOT NULL,
        description TEXT NOT NULL
      )
    ''');

    // Índices para mejorar rendimiento
    await db.execute('CREATE INDEX idx_orbes_type ON orbes(orbeTypeId)');
    await db.execute('CREATE INDEX idx_creatures_species ON creature_instances(speciesId)');
    await db.execute('CREATE INDEX idx_sanctuaries_orbe ON sanctuaries(orbeId)');

    // Insertar estado inicial del jugador
    await db.insert('player_state', {
      'id': 1,
      'totalEsencia': 0.0,
      'idleMultiplier': 1.0,
      'lastActiveTimestamp': DateTime.now().toIso8601String(),
      'totalSteps': 0,
      'storedSteps': 0,
      'explorerLevel': 1,
      'currentXp': 0,
      'lastBootTime': DateTime.now().toIso8601String(),
    });
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Crear tabla de inventario si no existe (migración)
      await db.execute('''
        CREATE TABLE IF NOT EXISTS inventory_items (
          id TEXT PRIMARY KEY,
          typeId TEXT NOT NULL,
          quantity INTEGER NOT NULL DEFAULT 1,
          metadata TEXT
        )
      ''');
      
      // Asegurar que las columnas nuevas de santuarios existan
      // Nota: En SQLite ALTER TABLE solo permite añadir una columna a la vez
      try {
        await db.execute('ALTER TABLE sanctuaries ADD COLUMN isTemporary INTEGER NOT NULL DEFAULT 0');
        await db.execute('ALTER TABLE sanctuaries ADD COLUMN remainingUses INTEGER NOT NULL DEFAULT 0');
        await db.execute('ALTER TABLE sanctuaries ADD COLUMN typeId TEXT');
      } catch (e) {
        // Ignorar si las columnas ya existen
      }
    }
    
    // Añadir campo speedUpgradeLevel para mejoras por santuario (v4)
    if (oldVersion < 4) {
      try {
        await db.execute('ALTER TABLE sanctuaries ADD COLUMN speedUpgradeLevel INTEGER NOT NULL DEFAULT 0');
      } catch (e) {
        // Ignorar si la columna ya existe
        debugPrint('Migration v4 warning: $e');
      }
    }

    // Insertar mejoras globales iniciales si no existen (v5)
    if (oldVersion < 5) {
      await _seedGlobalUpgrades(db);
    }

    // Eliminación de 'Eficiencia de Orbes', 'Velocidad de Santuario' global y ajuste de textos (v6)
    if (oldVersion < 6) {
      await db.delete('upgrades', where: 'id = ?', whereArgs: ['upgrade_orbe_cost']);
      await db.delete('upgrades', where: 'id = ?', whereArgs: ['upgrade_sanctuary_speed']);
      
      await db.update('upgrades', {
        'name': 'Recolector de Esencia',
        'description': 'Aumenta la velocidad de generación pasiva de Esencia',
      }, where: 'id = ?', whereArgs: ['upgrade_idle_multiplier']);
    }

    // Añadir columna storedSteps y mejora de Almacén de Energía (v7)
    if (oldVersion < 7) {
      try {
        await db.execute('ALTER TABLE player_state ADD COLUMN storedSteps INTEGER NOT NULL DEFAULT 0');
      } catch (e) {
        // Columna ya existe
      }

      await db.insert('upgrades', {
        'id': 'upgrade_energy_storage',
        'type': 'UpgradeType.energyStorage',
        'currentLevel': 0,
        'name': 'Almacén de Energía',
        'description': 'Permite almacenar pasos no usados cuando no hay orbes activos.',
      }, conflictAlgorithm: ConflictAlgorithm.ignore);
    }
    // V8: Añadir columna mechanics a orbe_types
    if (oldVersion < 8) {
      try {
        await db.execute('ALTER TABLE orbe_types ADD COLUMN mechanics TEXT');
      } catch (e) {
        // Ignorar si ya existe
      }
    }
    // V9: Añadir columnas explorerLevel y currentXp
    if (oldVersion < 9) {
      try {
        await db.execute('ALTER TABLE player_state ADD COLUMN explorerLevel INTEGER NOT NULL DEFAULT 1');
        await db.execute('ALTER TABLE player_state ADD COLUMN currentXp INTEGER NOT NULL DEFAULT 0');
      } catch (e) {
        // Columna ya existe
      }
    }
  }

  Future<void> _seedGlobalUpgrades(Database db) async {
    final batch = db.batch();
    
    // Recolector de Esencia
    batch.insert('upgrades', {
      'id': 'upgrade_idle_multiplier',
      'type': 'UpgradeType.idleMultiplier',
      'currentLevel': 0,
      'name': 'Recolector de Esencia',
      'description': 'Aumenta la velocidad de generación pasiva de Esencia',
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    // Almacén de Energía
    batch.insert('upgrades', {
      'id': 'upgrade_energy_storage',
      'type': 'UpgradeType.energyStorage',
      'currentLevel': 0,
      'name': 'Almacén de Energía',
      'description': 'Permite almacenar pasos no usados cuando no hay orbes activos.',
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    // NOTA: 'Eficiencia de Orbes' eliminada en v6

    await batch.commit();
  }

  // ========== PLAYER STATE ==========
  
  Future<Map<String, dynamic>?> getPlayerState() async {
    final db = await database;
    final results = await db.query('player_state', where: 'id = ?', whereArgs: [1]);
    return results.isNotEmpty ? results.first : null;
  }

  Future<void> updatePlayerState(Map<String, dynamic> state) async {
    final db = await database;
    await db.update('player_state', state, where: 'id = ?', whereArgs: [1]);
  }

  // ========== SANCTUARIES ==========

  Future<List<Map<String, dynamic>>> getAllSanctuaries() async {
    final db = await database;
    return await db.query('sanctuaries');
  }

  Future<Map<String, dynamic>?> getSanctuary(String id) async {
    final db = await database;
    final results = await db.query('sanctuaries', where: 'id = ?', whereArgs: [id]);
    return results.isNotEmpty ? results.first : null;
  }

  Future<void> updateSanctuary(String id, Map<String, dynamic> data) async {
    final db = await database;
    await db.update('sanctuaries', data, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteSanctuary(String id) async {
    final db = await database;
    await db.delete('sanctuaries', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> insertSanctuary(Map<String, dynamic> sanctuary) async {
    final db = await database;
    await db.insert('sanctuaries', sanctuary, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // ========== ORBE TYPES ==========

  Future<List<Map<String, dynamic>>> getAllOrbeTypes() async {
    final db = await database;
    return await db.query('orbe_types');
  }

  Future<Map<String, dynamic>?> getOrbeType(String id) async {
    final db = await database;
    final results = await db.query('orbe_types', where: 'id = ?', whereArgs: [id]);
    return results.isNotEmpty ? results.first : null;
  }

  Future<void> insertOrbeType(Map<String, dynamic> orbeType) async {
    final db = await database;
    await db.insert('orbe_types', orbeType, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // ========== ORBES ==========

  Future<String> insertOrbe(Map<String, dynamic> orbe) async {
    final db = await database;
    await db.insert('orbes', orbe);
    return orbe['id'];
  }

  Future<List<Map<String, dynamic>>> getAllOrbes() async {
    final db = await database;
    return await db.query('orbes');
  }

  Future<Map<String, dynamic>?> getOrbe(String id) async {
    final db = await database;
    final results = await db.query('orbes', where: 'id = ?', whereArgs: [id]);
    return results.isNotEmpty ? results.first : null;
  }

  Future<void> updateOrbe(String id, Map<String, dynamic> data) async {
    final db = await database;
    await db.update('orbes', data, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteOrbe(String id) async {
    final db = await database;
    await db.delete('orbes', where: 'id = ?', whereArgs: [id]);
  }

  // ========== CREATURE SPECIES ==========

  Future<void> insertCreatureSpecies(Map<String, dynamic> species) async {
    final db = await database;
    await db.insert('creature_species', species, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getAllCreatureSpecies() async {
    final db = await database;
    return await db.query('creature_species', orderBy: 'dexNumber ASC');
  }

  Future<Map<String, dynamic>?> getCreatureSpecies(String id) async {
    final db = await database;
    final results = await db.query('creature_species', where: 'id = ?', whereArgs: [id]);
    return results.isNotEmpty ? results.first : null;
  }

  // ========== CREATURE INSTANCES ==========

  Future<String> insertCreatureInstance(Map<String, dynamic> instance) async {
    final db = await database;
    await db.insert('creature_instances', instance);
    return instance['id'];
  }

  Future<List<Map<String, dynamic>>> getAllCreatureInstances() async {
    final db = await database;
    return await db.query('creature_instances', orderBy: 'caughtAt DESC');
  }

  Future<Map<String, dynamic>?> getCreatureInstance(String id) async {
    final db = await database;
    final results = await db.query('creature_instances', where: 'id = ?', whereArgs: [id]);
    return results.isNotEmpty ? results.first : null;
  }

  Future<void> updateCreatureInstance(String id, Map<String, dynamic> data) async {
    final db = await database;
    await db.update('creature_instances', data, where: 'id = ?', whereArgs: [id]);
  }

  // ========== INVENTORY ITEMS ==========

  Future<List<Map<String, dynamic>>> getAllInventoryItems() async {
    final db = await database;
    return await db.query('inventory_items');
  }

  Future<void> updateInventoryItem(String typeId, int delta) async {
    final db = await database;
    final items = await db.query('inventory_items', where: 'typeId = ?', whereArgs: [typeId]);
    
    if (items.isEmpty) {
      if (delta > 0) {
        await db.insert('inventory_items', {
          'id': 'item_$typeId',
          'typeId': typeId,
          'quantity': delta,
        });
      }
    } else {
      final currentQuantity = items.first['quantity'] as int;
      final newQuantity = currentQuantity + delta;
      
      if (newQuantity <= 0) {
        await db.delete('inventory_items', where: 'typeId = ?', whereArgs: [typeId]);
      } else {
        await db.update('inventory_items', {'quantity': newQuantity}, where: 'typeId = ?', whereArgs: [typeId]);
      }
    }
  }

  // ========== UPGRADES ==========

  Future<void> insertUpgrade(Map<String, dynamic> upgrade) async {
    final db = await database;
    await db.insert('upgrades', upgrade, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getAllUpgrades() async {
    final db = await database;
    return await db.query('upgrades');
  }

  Future<Map<String, dynamic>?> getUpgrade(String id) async {
    final db = await database;
    final results = await db.query('upgrades', where: 'id = ?', whereArgs: [id]);
    return results.isNotEmpty ? results.first : null;
  }

  Future<void> updateUpgrade(String id, Map<String, dynamic> data) async {
    final db = await database;
    await db.update('upgrades', data, where: 'id = ?', whereArgs: [id]);
  }

  // ========== UTILIDADES ==========

  Future<void> resetDatabase() async {
    final db = await database;
    
    // Delete all orbe types first (will cascade delete orbes)
    await db.delete('orbe_types');
    
    await db.delete('creature_instances');
    await db.delete('orbes');
    await db.delete('upgrades');
    await db.delete('inventory_items');
    
    // Eliminar santuarios temporales
    await db.delete('sanctuaries', where: 'isTemporary = ?', whereArgs: [1]);
    
    // Limpiar orbeId y mejoras del santuario permanente
    await db.update('sanctuaries', {
      'orbeId': null,
      'speedUpgradeLevel': 0,
      'speedMultiplier': 1.0,
    }, where: 'isTemporary = ?', whereArgs: [0]);
    
    // Restore seeds directly to avoid isSeeded() check
    await InitialData.seedOrbeTypes();
    await InitialData.seedUpgrades();
    
    await db.update('player_state', {
      'totalEsencia': 0,
      'idleMultiplier': 1.0,
      'totalSteps': 0,
      'storedSteps': 0,
      'explorerLevel': 1,
      'currentXp': 0,
      'lastActiveTimestamp': DateTime.now().toIso8601String(),
    }, where: 'id = ?', whereArgs: [1]);
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
