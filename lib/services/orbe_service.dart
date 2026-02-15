import 'dart:math';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:stillwalks/models/orbe.dart';
import 'package:stillwalks/models/creature_species.dart';
import 'package:stillwalks/models/creature_instance.dart';
import 'package:stillwalks/models/sanctuary.dart';
import 'package:stillwalks/models/inventory_item.dart';
import 'package:stillwalks/data/database/database_helper.dart';
import 'package:stillwalks/services/native_bridge.dart';
import 'package:stillwalks/services/notification_preferences_service.dart';
import 'package:stillwalks/services/esencia_service.dart';
import 'package:stillwalks/services/notification_guard_service.dart';

/// Servicio que gestiona la lógica de Orbes, Santuarios e Inventario
class OrbeService extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper();
  final Random _random = Random();

  List<Orbe> _orbes = [];
  List<OrbeType> _orbeTypes = [];
  List<Sanctuary> _sanctuaries = [];
  List<InventoryItem> _inventory = [];

  // Constants for inventory limits
  static const int maxOrbs = 10;
  static const int maxTempSanctuaries = 5;

  
  // Tutorial specific: Override next hatch result
  String? _nextHatchOverrideSpeciesId;
  void setNextHatchOverride(String? speciesId) {
    _nextHatchOverrideSpeciesId = speciesId;
  }
  
  // Optional service references for notifications
  NativeBridge? _nativeBridge;
  NotificationPreferencesService? _notificationPrefs;
  NotificationGuardService? _notificationGuard;
  EsenciaService? _esenciaService;
  
  // Stream subscription for essence events
  StreamSubscription<double>? _essenceSubscription;

  List<Orbe> get orbes => _orbes;
  List<OrbeType> get orbeTypes => _orbeTypes;
  List<Sanctuary> get sanctuaries => _sanctuaries;
  List<InventoryItem> get inventory => _inventory;

  // Helpers to check limits
  int get currentOrbsCount {
    final assignedIds = _sanctuaries.map((s) => s.orbeId).whereType<String>().toSet();
    return _orbes.where((o) => !o.isChanneled && !assignedIds.contains(o.id)).length;
  }
  int get currentTempSanctuariesCount {
    int count = 0;
    for (var item in _inventory) {
      if (item.typeId.startsWith('temp_sanctuary_')) {
        count += item.quantity;
      }
    }
    return count;
  }

  bool get canPurchaseOrbe => currentOrbsCount < maxOrbs;
  bool get canPurchaseTempSanctuary => currentTempSanctuariesCount < maxTempSanctuaries;

  
  /// Sets the notification services (called from main.dart after initialization)
  void setNotificationServices(NativeBridge nativeBridge, NotificationPreferencesService notificationPrefs, NotificationGuardService notificationGuard) {
    _nativeBridge = nativeBridge;
    _notificationPrefs = notificationPrefs;
    _notificationGuard = notificationGuard;
  }

  /// Inyecta el servicio de esencia para la progresión (XP)
  void setEsenciaService(EsenciaService service) {
    _esenciaService = service;
  }

  /// Inicializa el servicio
  Future<void> initialize() async {
    await loadData();
  }

  /// Listens to another service (EsenciaService) to trigger game mechanics
  void listenToEssenceService(Stream<double> essenceStream) {
    debugPrint('🕊️ OrbeService: Setting up essence stream listener...');
    _essenceSubscription?.cancel(); // Cancel any existing subscription
    _essenceSubscription = essenceStream.listen((amount) {
      debugPrint('🕊️ OrbeService: Received essence event: $amount');
      _applyEssenceToStepsConversion(amount);
    });
    debugPrint('🕊️ OrbeService: Essence stream listener active');
  }

  /// Converts earned essence into steps for valid sanctuaries
  Future<void> _applyEssenceToStepsConversion(double essenceAmount) async {
    if (essenceAmount <= 0) return;
    
    int convertedSteps = essenceAmount.floor(); // 1 Essence = 1 Step
    debugPrint('🕊️ OrbeService: Checking for Quietude sanctuaries to apply $convertedSteps essence...');
    
    for (var sanctuary in _sanctuaries) {
      debugPrint('🕊️   Sanctuary: ${sanctuary.name}, isTemp=${sanctuary.isTemporary}, typeId=${sanctuary.typeId}, hasOrb=${sanctuary.orbeId != null}, uses=${sanctuary.remainingUses}');
      if (sanctuary.isTemporary && 
          sanctuary.typeId == InventoryItemTypes.tempSanctuaryQuietude && 
          sanctuary.orbeId != null &&
          sanctuary.remainingUses > 0) {
            
        debugPrint('🕊️ Quietude Sanctuary: Converting $convertedSteps essence to steps for orb ${sanctuary.orbeId}');
        await updateOrbeProgress(sanctuary.orbeId!, convertedSteps);
      }
    }
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

    final cost = getOrbeCost(orbeTypeId);

    if (esenciaAvailable < cost) {
      return null;
    }

    if (!canPurchaseOrbe) {
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
    
    // XP Award: Comprar Orbe (Variable por tipo)
    int xpReward = 15; // Basic
    if (orbeTypeId == 'orbe_advanced') xpReward = 45;
    if (orbeTypeId == 'orbe_expert') xpReward = 90;
    
    _esenciaService?.addXp(xpReward);
    
    notifyListeners();

    return newOrbe;
  }

  /// getOrbeCost returns the essence cost for a given orb type
  double getOrbeCost(String orbeTypeId) {
    // Definición de precios fijos por tipo
    switch (orbeTypeId) {
      case 'orbe_basic':
        return 500.0;
      case 'orbe_advanced':
        return 1200.0;
      case 'orbe_expert':
        return 2500.0;
      default:
        // Fallback genérico para futuros orbes (5% de los pasos)
        final type = getOrbeType(orbeTypeId);
        if (type != null) {
          return type.requiredSteps * 0.05;
        }
        return 999999.0; // Precio prohibitivo si no existe
    }
  }

  /// Compra un objeto de inventario
  Future<bool> purchaseInventoryItem(String typeId, double cost, double esenciaAvailable) async {
    if (esenciaAvailable < cost) return false;

    // Check limit if it's a temporary sanctuary
    if (typeId.startsWith('temp_sanctuary_') && !canPurchaseTempSanctuary) {
      return false;
    }

    
    await _db.updateInventoryItem(typeId, 1);
    await loadData(); // Recargar inventario
    
    // XP Award: Comprar Santuario Temporal (20 XP)
    // Verificamos si es un item de tipo santuario temporal
    if (typeId.startsWith('temp_sanctuary_')) {
       _esenciaService?.addXp(20);
    }
    
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

  /// Obtiene un Orbe por su ID
  Orbe? getOrbeById(String id) {
    try {
      return _orbes.firstWhere((o) => o.id == id);
    } catch (e) {
      return null;
    }
  }



  /// Actualiza el progreso de un Orbe con pasos
  /// Retorna la cantidad de Esencia generada (si el orbe tiene esa mecánica)
  Future<double> updateOrbeProgress(String orbeId, int steps) async {
    final orbeIndex = _orbes.indexWhere((o) => o.id == orbeId);
    if (orbeIndex == -1) return 0.0;

    final orbe = _orbes[orbeIndex];
    final type = getOrbeType(orbe.orbeTypeId);
    final maxSteps = type?.requiredSteps ?? 2000; 

    final newProgress = (orbe.currentProgress + steps).clamp(0, maxSteps);
    if (newProgress == orbe.currentProgress) return 0.0;
    
    // Check if orb just completed (wasn't complete before, now is)
    final wasComplete = orbe.currentProgress >= maxSteps;
    final isNowComplete = newProgress >= maxSteps;

    final updatedOrbe = orbe.copyWith(currentProgress: newProgress);
    await _db.updateOrbe(orbeId, {'currentProgress': updatedOrbe.currentProgress});
    _orbes[orbeIndex] = updatedOrbe;
    
    // Trigger notification if orb just completed and notifications are enabled
    if (!wasComplete && isNowComplete && type != null) {
      if (_notificationPrefs != null && _nativeBridge != null) {
        final settings = _notificationPrefs!.settings;
        if (settings.eventsNotificationEnabled) {
          // Check cooldown/guard
          if (_notificationGuard == null || _notificationGuard!.shouldAllowNotification('orb_ready')) {
            await _nativeBridge!.showOrbReadyNotification(type.name);
            _notificationGuard?.markNotified('orb_ready');
            debugPrint('OrbeService: Orb ready notification sent for ${type.name}');
          }
        }
      }
    }
    
    notifyListeners();

    // Calcular esencia bonus si aplica (Orbe Esencial)
    if (type?.mechanics != null && type!.mechanics.containsKey('bonusEssencePerStep')) {
      final double bonus = (type.mechanics['bonusEssencePerStep'] as num).toDouble();
      return steps * bonus;
    }

    return 0.0;
  }

  /// Actualiza SOLO los Orbes asignados a santuarios
  /// Retorna un objeto con { count: int, essenceEarned: double, unusedSteps: int }
  Future<Map<String, dynamic>> addStepsToActiveOrbes(int newSteps) async {
    int updatedCount = 0;
    double totalEssenceEarned = 0.0;
    int maxStepsConsumed = 0;

    for (var sanctuary in _sanctuaries) {
      if (sanctuary.orbeId != null) {
        // Skip Quietude sanctuaries - they only progress with essence
        if (sanctuary.typeId == InventoryItemTypes.tempSanctuaryQuietude) {
          continue;
        }
        
        final orbeIndex = _orbes.indexWhere((o) => o.id == sanctuary.orbeId);
        if (orbeIndex != -1) {
          final orbe = _orbes[orbeIndex];
          final type = getOrbeType(orbe.orbeTypeId);
          
          if (type != null) {
             final effectiveRequiredSteps = (type.requiredSteps / sanctuary.speedMultiplier).round();
             if (orbe.currentProgress < effectiveRequiredSteps) {
               // Pasos necesarios para completar ESTE orbe
               final stepsNeeded = effectiveRequiredSteps - orbe.currentProgress;
               
               // Pasos que realmente consumirá de este batch
               final stepsConsumed = newSteps > stepsNeeded ? stepsNeeded : newSteps;
               
               // Actualizar máximo pasos consumidos por cualquiera de los orbes
               if (stepsConsumed > maxStepsConsumed) {
                 maxStepsConsumed = stepsConsumed;
               }

               // Aún necesita pasos
               final essence = await updateOrbeProgress(sanctuary.orbeId!, newSteps);
               totalEssenceEarned += essence;
               updatedCount++;
             }
          }
        }
      }
    }

    // Calcular pasos no utilizados (overflow)
    // Si no había orbes activos, todos son unused.
    // Si había orbes, unused = total - max(consumidos por cualquier orbe)
    final unusedSteps = newSteps - maxStepsConsumed;

    if (updatedCount > 0 || unusedSteps > 0) {
      debugPrint('OrbeService: Processed $newSteps steps. Used max $maxStepsConsumed. Unused: $unusedSteps. Earned $totalEssenceEarned essence.');
      notifyListeners();
    }
    
    return {
      'count': updatedCount,
      'essenceEarned': totalEssenceEarned,
      'unusedSteps': unusedSteps
    };
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

    String? speciesId;
    if (_nextHatchOverrideSpeciesId != null) {
      speciesId = _nextHatchOverrideSpeciesId;
      _nextHatchOverrideSpeciesId = null; // Consume override
      debugPrint('OrbeService: Forcing hatch result to $speciesId');
    } else {
      speciesId = _rollLootTable(finalLootTable);
    }
    
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

    // XP Award: Canalizar Orbe (25/50/100 XP según rareza)
    // XP Award: Canalizar Orbe (100/250/400 XP según rareza - New Balance)
    int channelingXp = 100; // Basic
    if (type.id == 'orbe_advanced') channelingXp = 250;
    if (type.id == 'orbe_expert') channelingXp = 400;
    _esenciaService?.addXp(channelingXp);

    // XP Award: Descubrimiento (50 XP)
    // Check if this species was already discovered BEFORE this hatch
    // (Wait, I just inserted it. So I should check if count == 1 now)
    final isNew = await isNewDiscovery(speciesId);
    if (isNew) {
       _esenciaService?.addXp(150);
       debugPrint('⭐ XP Bonus: New Discovery! (+50 XP)');
    }

    // Calcular recompensa de esencia si está en Santuario de Simbiosis
    double symbiosisEssence = 0.0;
    if (sanctuary.typeId == InventoryItemTypes.tempSanctuarySymbiosis) {
      symbiosisEssence = (orbe.currentProgress / 10).floorToDouble();
      debugPrint('OrbeService: Symbiosis sanctuary rewarded $symbiosisEssence essence');
    }

    // Manejar consumibles de santuarios temporales (ANTEs de limpiar el orbe, para poder encontrar el santuario)
    await _consumeSanctuaryCharge(orbeId);

    // Limpiar el orbe del santuario para permitir asignar uno nuevo
    // (Solo si el santuario aún existe tras consumir la carga)
    final sIdx = _sanctuaries.indexWhere((s) => s.orbeId == orbeId);
    if (sIdx != -1) {
      _sanctuaries[sIdx] = _sanctuaries[sIdx].copyWith(clearOrbe: true);
      await _db.updateSanctuary(_sanctuaries[sIdx].id, _sanctuaries[sIdx].toJson());
    }

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
        speed = 1.111111; // -10% pasos = 1/0.9 velocidad
        uses = 1;
        break;
      case InventoryItemTypes.tempSanctuarySymbiosis:
        speed = 1.0;
        uses = 2;
        break;
      case InventoryItemTypes.tempSanctuaryQuietude:
        speed = 1.0;
        uses = 1; // 1 Channeling duration
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
    
    // XP Award: Upgrade Sanctuary Speed (+40 XP)
    _esenciaService?.addXp(40);
    
    notifyListeners();
    
    return true;
  }

  /// Reinicia el estado de Orbes y Santuarios (Para reinicio de tutorial)
  Future<void> resetState() async {
    // 1. Borrar todos los orbes
    await _db.deleteAllOrbes();
    _orbes.clear();

    // 2. Borrar todos los santuarios excepto el primordial
    final List<Sanctuary> toKeep = [];
    for (var s in _sanctuaries) {
      if (!s.isTemporary) {
         // Resetear santuario primordial
         final resetSanctuary = s.copyWith(
           orbeId: null, // Clear assigned orb
           clearOrbe: true,
           speedUpgradeLevel: 0,
           speedMultiplier: 1.0, 
         );
         await _db.updateSanctuary(resetSanctuary.id, resetSanctuary.toJson());
         toKeep.add(resetSanctuary);
      } else {
         await _db.deleteSanctuary(s.id);
      }
    }
    _sanctuaries = toKeep;

    // 3. Borrar inventario
    // (Asumimos que hay un método deleteAllInventoryItems o lo hacemos uno a uno)
    // Inv items no tienen ID único, son tipos. Update a 0.
    for (var item in _inventory) {
      await _db.updateInventoryItem(item.typeId, -item.quantity); // Remove all
    }
    _inventory.clear(); // Reload will fix or just clear local
    await loadData(); // Reload to be safe and ensure consistent state

    debugPrint('🕊️ OrbeService: State reset complete.');
    notifyListeners();
  }
}
