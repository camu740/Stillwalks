import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:stillwalks/models/orbe.dart';
import 'package:stillwalks/models/creature_species.dart';
import 'package:stillwalks/models/creature_instance.dart';
import 'package:stillwalks/data/database/database_helper.dart';

/// Servicio que gestiona la lógica de Orbes y canalización
class OrbeService extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper();
  final Random _random = Random();

  List<Orbe> _orbes = [];
  List<OrbeType> _orbeTypes = [];

  List<Orbe> get orbes => _orbes;
  List<OrbeType> get orbeTypes => _orbeTypes;

  /// Inicializa el servicio
  Future<void> initialize() async {
    await loadOrbes();
  }

  /// Carga todos los Orbes y tipos desde la base de datos
  Future<void> loadOrbes() async {
    final orbesData = await _db.getAllOrbes();
    _orbes = orbesData.map((data) => Orbe.fromJson(data)).toList();

    final typesData = await _db.getAllOrbeTypes();
    _orbeTypes = typesData.map((data) => OrbeType.fromJson(data)).toList();

    notifyListeners();
  }

  /// Compra un nuevo Orbe
  Future<Orbe?> purchaseOrbe(String orbeTypeId, double esenciaAvailable, double reductionMultiplier) async {
    // Calcular costo
    final baseCost = 500.0;
    final cost = baseCost * (1.0 - reductionMultiplier);

    if (esenciaAvailable < cost) {
      return null; // No hay suficiente Esencia
    }

    // Crear nuevo Orbe
    final newOrbe = Orbe(
      id: 'orbe_${DateTime.now().millisecondsSinceEpoch}',
      orbeTypeId: orbeTypeId,
      currentProgress: 0,
      createdAt: DateTime.now(),
    );

    await _db.insertOrbe(newOrbe.toJson());
    _orbes.add(newOrbe);
    notifyListeners();

    return newOrbe;
  }

  /// Obtiene el tipo de un Orbe
  OrbeType? getOrbeType(String orbeTypeId) {
    try {
      return _orbeTypes.firstWhere((type) => type.id == orbeTypeId);
    } catch (e) {
      return null;
    }
  }

  /// Actualiza el progreso de un Orbe con pasos
  Future<void> updateOrbeProgress(String orbeId, int steps) async {
    final orbeIndex = _orbes.indexWhere((o) => o.id == orbeId);
    if (orbeIndex == -1) return;

    final orbe = _orbes[orbeIndex];
    final type = getOrbeType(orbe.orbeTypeId);
    final maxSteps = type?.requiredSteps ?? 2000; // Fallback

    // Clamp al máximo
    final newProgress = (orbe.currentProgress + steps).clamp(0, maxSteps);

    if (newProgress == orbe.currentProgress) return; // No hay cambios

    final updatedOrbe = orbe.copyWith(
      currentProgress: newProgress,
    );

    await _db.updateOrbe(orbeId, {'currentProgress': updatedOrbe.currentProgress});
    _orbes[orbeIndex] = updatedOrbe;
    notifyListeners();
  }

  /// Actualiza todos los Orbes activos (en progreso) con nuevos pasos
  Future<void> addStepsToActiveOrbes(int newSteps) async {
    // MVP: Actualizar todos los orbes que no han sido canalizados aún
    // En el futuro, solo los que estén en un santuario
    final activeOrbes = _orbes.where((o) => !o.isChanneled).toList();

    for (var orbe in activeOrbes) {
      await updateOrbeProgress(orbe.id, newSteps);
    }

    debugPrint('OrbeService: Added $newSteps steps to ${activeOrbes.length} active orbes');
    notifyListeners();
  }

  /// Canaliza un Orbe completado (determina qué Stillwalk sale)
  Future<CreatureInstance?> channelOrbe(String orbeId) async {
    final orbeIndex = _orbes.indexWhere((o) => o.id == orbeId);
    if (orbeIndex == -1) return null;

    final orbe = _orbes[orbeIndex];
    var orbeType = getOrbeType(orbe.orbeTypeId);
    
    // Fallback para legacy bug
    if (orbeType == null) {
      // Intentar buscar el básico por defecto
      orbeType = getOrbeType('orbe_basic');
      // Si aún así falla (no debería), hardcodeamos uno temporal
      orbeType ??= OrbeType(
          id: 'temp', 
          requiredSteps: 2000, 
          name: 'Unknown', 
          description: '', 
          lootTable: {
            'spiristone': 0.50,
            'radispirit': 0.35,
            'slugrry': 0.15,
          }
      );
    }

    // Obtener inventario actual para ajustar probabilidades (Bad Luck Protection)
    final allInstances = await _db.getAllCreatureInstances();
    
    // Crear tabla de loot ajustada
    final Map<String, double> adjustedLootTable = {};
    double totalWeight = 0.0;

    for (var entry in orbeType.lootTable.entries) {
      final speciesId = entry.key;
      final baseProbability = entry.value;
      
      // Contar cuántos tenemos de esta especie
      final count = allInstances.where((i) => i['speciesId'] == speciesId).length;
      
      // Fórmula: Peso = Base / (1 + count * 0.5)
      // Ejemplo: Spiristone (base 0.5). Con 0 => 0.5. Con 1 => 0.33. Con 10 => 0.08.
      final adjustedWeight = baseProbability / (1.0 + (count * 0.5));
      
      adjustedLootTable[speciesId] = adjustedWeight;
      totalWeight += adjustedWeight;
    }

    // Normalizar a 1.0 (opcional, pero buena práctica para _rollLootTable si este espera 0-1)
    // Mi _rollLootTable suma acumulativamente, así que si el total != 1.0, el random (0-1) podría salirse de rango si total < 1.
    // O si total > 1.
    // Mejor normalizar la tabla ajustada.
    
    final Map<String, double> finalLootTable = {};
    if (totalWeight > 0) {
      adjustedLootTable.forEach((key, weight) {
        finalLootTable[key] = weight / totalWeight;
      });
    } else {
      // Fallback si algo falló
      finalLootTable.addAll(orbeType.lootTable);
    }

    // Verificar que está listo para canalizar
    if (!orbe.isReadyToChannel(orbeType.requiredSteps)) {
      return null;
    }

    // Determinar qué criatura sale usando la loot table ajustada
    final speciesId = _rollLootTable(finalLootTable);
    if (speciesId == null) return null;

    // DEBUG: Mostrar probabilidades reales en consola
    debugPrint('🎲 Loot Roll: $finalLootTable -> Result: $speciesId');

    // Crear instancia de criatura
    final instance = CreatureInstance(
      id: 'creature_${DateTime.now().millisecondsSinceEpoch}',
      speciesId: speciesId,
      caughtAt: DateTime.now(),
    );

    await _db.insertCreatureInstance(instance.toJson());

    // Actualizar Orbe con la criatura asignada
    final channeldOrbe = orbe.copyWith(stillwalkId: instance.id);
    await _db.updateOrbe(orbeId, {'stillwalkId': instance.id});
    _orbes[orbeIndex] = channeldOrbe;

    notifyListeners();
    return instance;
  }

  /// Lógica de loot table (roll probabilístico)
  String? _rollLootTable(Map<String, double> lootTable) {
    if (lootTable.isEmpty) return null;

    final roll = _random.nextDouble(); // 0.0 - 1.0
    double cumulative = 0.0;

    for (final entry in lootTable.entries) {
      cumulative += entry.value;
      if (roll <= cumulative) {
        return entry.key;
      }
    }

    // Fallback: devolver la última entrada
    return lootTable.keys.last;
  }

  /// Obtiene Orbes que no están en santuarios
  List<Orbe> getAvailableOrbes() {
    // TODO: Filtrar los que ya están asignados a santuarios
    return _orbes.where((o) => !o.isChanneled).toList();
  }

  /// Obtiene una instancia por ID (helper para UI)
  Future<CreatureInstance?> getCreatureInstanceById(String instanceId) async {
    final allInstances = await _db.getAllCreatureInstances();
    try {
      final data = allInstances.firstWhere((i) => i['id'] == instanceId);
      return CreatureInstance.fromJson(data);
    } catch (e) {
      return null;
    }
  }

  /// Elimina un Orbe ya canalizado
  Future<void> deleteChanneledOrbe(String orbeId) async {
    await _db.deleteOrbe(orbeId);
    _orbes.removeWhere((o) => o.id == orbeId);
    notifyListeners();
  }

  /// Obtiene una especie por ID (helper para UI)
  Future<CreatureSpecies?> getSpeciesById(String speciesId) async {
    final allSpeciesData = await _db.getAllCreatureSpecies();
    try {
      final speciesData = allSpeciesData.firstWhere((s) => s['id'] == speciesId);
      return CreatureSpecies.fromJson(speciesData);
    } catch (e) {
      return null;
    }
  }
  /// Comprueba si es la primera vez que se captura esta especie (para mostrar badge "Nuevo")
  Future<bool> isNewDiscovery(String speciesId) async {
    final allInstances = await _db.getAllCreatureInstances();
    final count = allInstances.where((i) => i['speciesId'] == speciesId).length;
    return count == 1;
  }

  /// Obtiene lista de IDs de especies descubiertas
  Future<List<String>> getUnlockedSpeciesIds() async {
    final allInstances = await _db.getAllCreatureInstances();
    return allInstances.map((i) => i['speciesId'] as String).toSet().toList();
  }

  /// Helper para exponer todas las especies al diario
  Future<List<CreatureSpecies>> getAllSpecies() async {
    final data = await _db.getAllCreatureSpecies();
    return data.map((d) => CreatureSpecies.fromJson(d)).toList();
  }
}
