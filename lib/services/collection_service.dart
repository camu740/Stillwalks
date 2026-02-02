import 'package:flutter/foundation.dart';
import 'package:stillwalks/models/creature_species.dart';
import 'package:stillwalks/models/creature_instance.dart';
import 'package:stillwalks/data/database/database_helper.dart';

/// Servicio que gestiona la colección de Stillwalks (Diario de explorador)
class CollectionService extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper();

  List<CreatureSpecies> _allSpecies = [];
  List<CreatureInstance> _capturedInstances = [];

  List<CreatureSpecies> get allSpecies => _allSpecies;
  List<CreatureInstance> get capturedInstances => _capturedInstances;

  /// Número total de especies en el MVP
  int get totalSpeciesCount => _allSpecies.length;

  /// Número de especies descubiertas (capturadas al menos una vez)
  int get discoveredSpeciesCount {
    final discoveredIds = _capturedInstances.map((i) => i.speciesId).toSet();
    return discoveredIds.length;
  }

  /// Carga todas las especies y criaturas capturadas
  Future<void> loadCollection() async {
    final speciesData = await _db.getAllCreatureSpecies();
    _allSpecies = speciesData.map((data) => CreatureSpecies.fromJson(data)).toList();

    final instancesData = await _db.getAllCreatureInstances();
    _capturedInstances = instancesData.map((data) => CreatureInstance.fromJson(data)).toList();

    notifyListeners();
  }

  /// Verifica si una especie ha sido descubierta
  bool isSpeciesDiscovered(String speciesId) {
    return _capturedInstances.any((i) => i.speciesId == speciesId);
  }

  /// Obtiene todas las instancias de una especie específica
  List<CreatureInstance> getInstancesOfSpecies(String speciesId) {
    return _capturedInstances.where((i) => i.speciesId == speciesId).toList();
  }

  /// Obtiene los datos de una especie
  CreatureSpecies? getSpecies(String speciesId) {
    try {
      return _allSpecies.firstWhere((s) => s.id == speciesId);
    } catch (e) {
      return null;
    }
  }

  /// Registra una nueva captura (llamado después de canalizar un Orbe)
  Future<void> registerCapture(CreatureInstance instance) async {
    _capturedInstances.insert(0, instance); // Añadir al inicio (más reciente)
    notifyListeners();
  }

  /// Marca/desmarca como favorito
  Future<void> toggleFavorite(String instanceId) async {
    final index = _capturedInstances.indexWhere((i) => i.id == instanceId);
    if (index == -1) return;

    final instance = _capturedInstances[index];
    final updated = instance.copyWith(isFavorite: !instance.isFavorite);

    await _db.updateCreatureInstance(instanceId, {'isFavorite': updated.isFavorite ? 1 : 0});
    _capturedInstances[index] = updated;

    notifyListeners();
  }

  /// Obtiene estadísticas de la colección
  Map<String, dynamic> getCollectionStats() {
    return {
      'total': totalSpeciesCount,
      'discovered': discoveredSpeciesCount,
      'completion_rate': totalSpeciesCount > 0
          ? (discoveredSpeciesCount / totalSpeciesCount * 100).toStringAsFixed(1)
          : '0.0',
      'total_caught': _capturedInstances.length,
    };
  }
}
