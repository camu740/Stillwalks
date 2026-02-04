import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:stillwalks/models/orbe.dart';
import 'package:stillwalks/models/creature_species.dart';
import 'package:stillwalks/models/creature_instance.dart';
import 'package:stillwalks/models/sanctuary.dart';
import 'package:stillwalks/models/inventory_item.dart';
import 'package:stillwalks/data/database/database_helper.dart';

/// Servicio que gestiona la lógica de Orbes, Santuarios e Inventario
class OrbeService extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper();
  final Random _random = Random();

  List<Orbe> _orbes = [];
  List<OrbeType> _orbeTypes = [];
  List<Sanctuary> _sanctuaries = [];
  List<InventoryItem> _inventory = [];

  List<Orbe> get orbes => _orbes;
  List<OrbeType> get orbeTypes => _orbeTypes;
  List<Sanctuary> get sanctuaries => _sanctuaries;
  List<InventoryItem> get inventory => _inventory;

  /// Inicializa el servicio
  Future<void> initialize() async {
    await loadData();
  }

  /// Carga todos los datos desde la base de datos
  Future<void> loadData() async {
    final orbesData = await _db.getAllOrbes();
    _orbes = orbesData.map((data) => Orbe.fromJson(data)).toList();

    final typesData = await _db.getAllOrbeTypes();
    _orbeTypes = typesData.map((data) => OrbeType.fromJson(data)).toList();

    final sanctuariesData = await _db.getAllSanctuaries();
    _sanctuaries = sanctuariesData.map((data) => Sanctuary.fromJson(data)).toList();
    
    // Limpiar santuarios temporales inválidos (sin typeId o con 0 usos)
    final invalidTempSanctuaries = _sanctuaries.where((s) => 
      s.isTemporary && (s.typeId == null || s.remainingUses <= 0)
    ).toList();
    
    for (final invalid in invalidTempSanctuaries) {
      await _db.deleteSanctuary(invalid.id);
      _sanctuaries.removeWhere((s) => s.id == invalid.id);
      debugPrint('OrbeService: Removed invalid temporary sanctuary: ${invalid.id}');
    }
    
    // Si no hay santuarios, crear el inicial
    if (_sanctuaries.isEmpty) {
      final initialSanctuary = Sanctuary(
        id: 'sanc_primordial',
        name: 'Santuario Primordial',
        description: 'Tu santuario permanente de canalización.',
        speedMultiplier: 1.0,
        isTemporary: false,
      );
      await _db.insertSanctuary(initialSanctuary.toJson());
      _sanctuaries.add(initialSanctuary);
    }

    final inventoryData = await _db.getAllInventoryItems();
    _inventory = inventoryData.map((data) => InventoryItem.fromJson(data)).toList();

    notifyListeners();
  }

  /// Compra un nuevo Orbe (va a la bolsa, no al santuario)
  Future<Orbe?> purchaseOrbe(String orbeTypeId, double esenciaAvailable) async {
    final type = getOrbeType(orbeTypeId);
    if (type == null) return null;

    final cost = type.requiredSteps * 0.05; // Ejemplo de costo basado en pasos o fijo

    if (esenciaAvailable < cost) {
      return null;
    }

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

  /// Compra un objeto de inventario
  Future<bool> purchaseInventoryItem(String typeId, double cost, double esenciaAvailable) async {
    if (esenciaAvailable < cost) return false;
    
    await _db.updateInventoryItem(typeId, 1);
    await loadData(); // Recargar inventario
    return true;
  }

  /// Asigna un orbe a un santuario
  Future<void> assignOrbeToSanctuary(String orbeId, String sanctuaryId) async {
    final sIdx = _sanctuaries.indexWhere((s) => s.id == sanctuaryId);
    if (sIdx == -1) return;

    // Desasignar de otros santuarios si estuviera (limpieza)
    for (var i = 0; i < _sanctuaries.length; i++) {
      if (_sanctuaries[i].orbeId == orbeId) {
        _sanctuaries[i] = _sanctuaries[i].copyWith(clearOrbe: true);
        await _db.updateSanctuary(_sanctuaries[i].id, _sanctuaries[i].toJson());
      }
    }

    _sanctuaries[sIdx] = _sanctuaries[sIdx].copyWith(orbeId: orbeId);
    await _db.updateSanctuary(sanctuaryId, _sanctuaries[sIdx].toJson());
    notifyListeners();
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
    final maxSteps = type?.requiredSteps ?? 2000; 

    final newProgress = (orbe.currentProgress + steps).clamp(0, maxSteps);
    if (newProgress == orbe.currentProgress) return;

    final updatedOrbe = orbe.copyWith(currentProgress: newProgress);
    await _db.updateOrbe(orbeId, {'currentProgress': updatedOrbe.currentProgress});
    _orbes[orbeIndex] = updatedOrbe;
    notifyListeners();
  }

  /// Actualiza SOLO los Orbes asignados a santuarios
  /// Retorna el número de orbes actualizados
  Future<int> addStepsToActiveOrbes(int newSteps) async {
    int updatedCount = 0;
    for (var sanctuary in _sanctuaries) {
      if (sanctuary.orbeId != null) {
        final orbeIndex = _orbes.indexWhere((o) => o.id == sanctuary.orbeId);
        if (orbeIndex != -1) {
          final orbe = _orbes[orbeIndex];
          final type = getOrbeType(orbe.orbeTypeId);
          
          if (type != null) {
             final effectiveRequiredSteps = (type.requiredSteps / sanctuary.speedMultiplier).round();
             if (orbe.currentProgress < effectiveRequiredSteps) {
               // Aún necesita pasos
               await updateOrbeProgress(sanctuary.orbeId!, newSteps);
               updatedCount++;
             }
          }
        }
      }
    }

    if (updatedCount > 0) {
      debugPrint('OrbeService: Added steps to $updatedCount orbes in sanctuaries');
      notifyListeners();
    }
    
    return updatedCount;
  }

  /// Canaliza un Orbe completado
  Future<CreatureInstance?> channelOrbe(String orbeId) async {
    final orbeIdx = _orbes.indexWhere((o) => o.id == orbeId);
    if (orbeIdx == -1) return null;

    final orbe = _orbes[orbeIdx];
    final type = getOrbeType(orbe.orbeTypeId);
    
    if (type == null) return null;

    // Buscar santuario para ver si tiene multiplicador de reducción de requisito
    final sanctuary = _sanctuaries.firstWhere((s) => s.orbeId == orbeId, orElse: () => _sanctuaries.first);
    final effectiveRequiredSteps = (type.requiredSteps / sanctuary.speedMultiplier).round();

    if (!orbe.isReadyToChannel(effectiveRequiredSteps)) {
      debugPrint('OrbeService: Orbe not ready. Needs $effectiveRequiredSteps, has ${orbe.currentProgress}');
      return null;
    }

    // Lógica de Loot Inteligente (Bad Luck Protection)
    final allInstances = await _db.getAllCreatureInstances();
    final Map<String, double> adjustedLootTable = {};
    double totalWeight = 0.0;

    for (var entry in type.lootTable.entries) {
      final speciesId = entry.key;
      final count = allInstances.where((i) => i['speciesId'] == speciesId).length;
      final adjustedWeight = entry.value / (1.0 + (count * 0.5));
      adjustedLootTable[speciesId] = adjustedWeight;
      totalWeight += adjustedWeight;
    }

    final Map<String, double> finalLootTable = {};
    if (totalWeight > 0) {
      adjustedLootTable.forEach((key, weight) => finalLootTable[key] = weight / totalWeight);
    } else {
      finalLootTable.addAll(type.lootTable);
    }

    final speciesId = _rollLootTable(finalLootTable);
    if (speciesId == null) return null;

    final instance = CreatureInstance(
      id: 'creature_${DateTime.now().millisecondsSinceEpoch}',
      speciesId: speciesId,
      caughtAt: DateTime.now(),
    );

    await _db.insertCreatureInstance(instance.toJson());

    final channeledOrbe = orbe.copyWith(stillwalkId: instance.id);
    await _db.updateOrbe(orbeId, {'stillwalkId': instance.id});
    _orbes[orbeIdx] = channeledOrbe;

    // Calcular recompensa de esencia si está en Santuario de Simbiosis
    double symbiosisEssence = 0.0;
    if (sanctuary.typeId == InventoryItemTypes.tempSanctuarySymbiosis) {
      symbiosisEssence = (orbe.currentProgress / 10).floorToDouble();
      debugPrint('OrbeService: Symbiosis sanctuary rewarded $symbiosisEssence essence');
    }

    // Limpiar el orbe del santuario para permitir asignar uno nuevo
    final sIdx = _sanctuaries.indexWhere((s) => s.orbeId == orbeId);
    if (sIdx != -1) {
      _sanctuaries[sIdx] = _sanctuaries[sIdx].copyWith(clearOrbe: true);
      await _db.updateSanctuary(_sanctuaries[sIdx].id, _sanctuaries[sIdx].toJson());
    }

    // Manejar consumibles de santuarios temporales (después de canalizar con éxito)
    await _consumeSanctuaryCharge(orbeId);

    notifyListeners();
    
    // Retornar instancia con metadatos de recompensa
    // NOTA: Para comunicar la esencia al UI, necesitamos un mecanismo.
    // Por ahora, guardaremos en una propiedad del servicio que el UI puede leer
    _lastSymbiosisReward = symbiosisEssence;
    
    return instance;
  }

  // Variable para comunicar la recompensa de simbiosis al UI
  double _lastSymbiosisReward = 0.0;
  double get lastSymbiosisReward => _lastSymbiosisReward;
  
  void clearSymbiosisReward() {
    _lastSymbiosisReward = 0.0;
  }

  Future<void> _consumeSanctuaryCharge(String orbeId) async {
    final sIdx = _sanctuaries.indexWhere((s) => s.orbeId == orbeId);
    if (sIdx == -1) return;

    final sanctuary = _sanctuaries[sIdx];
    if (sanctuary.isTemporary) {
      final newUses = sanctuary.remainingUses - 1;
      if (newUses <= 0) {
        await _db.deleteSanctuary(sanctuary.id);
        _sanctuaries.removeAt(sIdx);
      } else {
        _sanctuaries[sIdx] = sanctuary.copyWith(remainingUses: newUses);
        await _db.updateSanctuary(sanctuary.id, _sanctuaries[sIdx].toJson());
      }
    }
  }

  /// Activa un santuario temporal desde el inventario
  Future<bool> activateTemporarySanctuary(String typeId) async {
    // Verificar si ya hay uno temporal activo (Rule 8: Máx 1)
    if (_sanctuaries.any((s) => s.isTemporary)) return false;

    // Quitar del inventario
    await _db.updateInventoryItem(typeId, -1);

    // Crear santuario temporal
    double speed = 1.0;
    int uses = 1;

    switch (typeId) {
      case InventoryItemTypes.tempSanctuaryFastFlow:
        speed = 2.0; // -50% pasos = 2x velocidad
        uses = 1;
        break;
      case InventoryItemTypes.tempSanctuarySymbiosis:
        speed = 1.0;
        uses = 2;
        break;
      // ... otros tipos
    }

    final tempSanctuary = Sanctuary(
      id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      name: InventoryItemTypes.getName(typeId),
      description: InventoryItemTypes.getDescription(typeId),
      speedMultiplier: speed,
      isTemporary: true,
      remainingUses: uses,
      typeId: typeId,
    );

    await _db.insertSanctuary(tempSanctuary.toJson());
    await loadData(); // Recargar todo
    return true;
  }

  String? _rollLootTable(Map<String, double> lootTable) {
    if (lootTable.isEmpty) return null;
    final roll = _random.nextDouble();
    double cumulative = 0.0;
    for (final entry in lootTable.entries) {
      cumulative += entry.value;
      if (roll <= cumulative) return entry.key;
    }
    return lootTable.keys.last;
  }

  List<Orbe> getAvailableOrbes() {
    final assignedIds = _sanctuaries.map((s) => s.orbeId).whereType<String>().toSet();
    return _orbes.where((o) => !o.isChanneled && !assignedIds.contains(o.id)).toList();
  }

  Future<CreatureInstance?> getCreatureInstanceById(String instanceId) async {
    final data = await _db.getCreatureInstance(instanceId);
    return data != null ? CreatureInstance.fromJson(data) : null;
  }

  Future<void> deleteChanneledOrbe(String orbeId) async {
    // Limpiar santuario primero
    for (var i = 0; i < _sanctuaries.length; i++) {
      if (_sanctuaries[i].orbeId == orbeId) {
        _sanctuaries[i] = _sanctuaries[i].copyWith(clearOrbe: true);
        await _db.updateSanctuary(_sanctuaries[i].id, _sanctuaries[i].toJson());
      }
    }
    await _db.deleteOrbe(orbeId);
    _orbes.removeWhere((o) => o.id == orbeId);
    notifyListeners();
  }

  Future<CreatureSpecies?> getSpeciesById(String speciesId) async {
    final data = await _db.getCreatureSpecies(speciesId);
    return data != null ? CreatureSpecies.fromJson(data) : null;
  }

  Future<bool> isNewDiscovery(String speciesId) async {
    final allInstances = await _db.getAllCreatureInstances();
    return allInstances.where((i) => i['speciesId'] == speciesId).length == 1;
  }

  Future<List<String>> getUnlockedSpeciesIds() async {
    final allInstances = await _db.getAllCreatureInstances();
    return allInstances.map((i) => i['speciesId'] as String).toSet().toList();
  }

  Future<List<CreatureSpecies>> getAllSpecies() async {
    final data = await _db.getAllCreatureSpecies();
    return data.map((d) => CreatureSpecies.fromJson(d)).toList();
  }

  /// Mejora el nivel de velocidad de un santuario específico
  Future<bool> upgradeSanctuarySpeed(String sanctuaryId, double esenciaAvailable) async {
    final sIdx = _sanctuaries.indexWhere((s) => s.id == sanctuaryId);
    if (sIdx == -1) return false;

    final sanctuary = _sanctuaries[sIdx];
    
    // Verificar que puede ser mejorado
    if (!sanctuary.canUpgrade()) return false;
    
    // Verificar coste
    final cost = Sanctuary.getUpgradeCost(sanctuary.speedUpgradeLevel);
    if (esenciaAvailable < cost) return false;
    
    // Incrementar nivel y recalcular multiplicador
    final newLevel = sanctuary.speedUpgradeLevel + 1;
    final newMultiplier = Sanctuary.calculateSpeedMultiplier(newLevel);
    
    _sanctuaries[sIdx] = sanctuary.copyWith(
      speedUpgradeLevel: newLevel,
      speedMultiplier: newMultiplier,
    );
    
    await _db.updateSanctuary(sanctuaryId, _sanctuaries[sIdx].toJson());
    notifyListeners();
    
    return true;
  }
}
