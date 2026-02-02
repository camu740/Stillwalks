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
    final updatedOrbe = orbe.copyWith(
      currentProgress: orbe.currentProgress + steps,
    );

    await _db.updateOrbe(orbeId, {'currentProgress': updatedOrbe.currentProgress});
    _orbes[orbeIndex] = updatedOrbe;
    notifyListeners();
  }

  /// Actualiza todos los Orbes en santuarios con nuevos pasos
  Future<void> addStepsToActiveOrbes(int newSteps) async {
    // Obtener santuarios con Orbes activos
    // Nota: Asumiendo que DatabaseHelper tiene un método para obtener santuarios
    // y que estos santuarios pueden contener un orbeId.
    // Si no existe, necesitará ser implementado en DatabaseHelper.
    final sanctuaries = await _db.getAllSanctuaries(); // This method needs to exist in DatabaseHelper

    for (var sanctuaryMap in sanctuaries) {
      final orbeId = sanctuaryMap['orbeId'] as String?;
      if (orbeId != null) {
        await updateOrbeProgress(orbeId, newSteps);
      }
    }

    debugPrint('OrbeService: Added $newSteps steps to all active orbes');
  }

  /// Canaliza un Orbe completado (determina qué Stillwalk sale)
  Future<CreatureInstance?> channelOrbe(String orbeId) async {
    final orbeIndex = _orbes.indexWhere((o) => o.id == orbeId);
    if (orbeIndex == -1) return null;

    final orbe = _orbes[orbeIndex];
    final orbeType = getOrbeType(orbe.orbeTypeId);
    if (orbeType == null) return null;

    // Verificar que está listo para canalizar
    if (!orbe.isReadyToChannel(orbeType.requiredSteps)) {
      return null;
    }

    // Determinar qué criatura sale usando la loot table
    final speciesId = _rollLootTable(orbeType.lootTable);
    if (speciesId == null) return null;

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

  /// Elimina un Orbe ya canalizado
  Future<void> deleteChanneledOrbe(String orbeId) async {
    await _db.deleteOrbe(orbeId);
    _orbes.removeWhere((o) => o.id == orbeId);
    notifyListeners();
  }
}
