import 'dart:async';
import 'package:stillwalks/services/collection_service.dart';
import 'package:flutter/foundation.dart';
import 'package:stillwalks/models/player_state.dart';
import 'package:stillwalks/models/upgrade.dart';
import 'package:stillwalks/data/database/database_helper.dart';
import 'package:stillwalks/services/native_bridge.dart';
import 'package:stillwalks/services/notification_preferences_service.dart';
import 'package:stillwalks/services/progression_service.dart';
import 'package:stillwalks/services/notification_guard_service.dart';
import 'package:stillwalks/models/building.dart';
import 'dart:math';

/// Servicio que gestiona la generación de Esencia y el estado del jugador
class EsenciaService extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper();

  PlayerState _playerState = PlayerState.initial();
  List<Upgrade> _upgrades = [];

  PlayerState get playerState => _playerState;
  List<Upgrade> get upgrades => _upgrades;
  DateTime get lastUpdate => _playerState.lastActiveTimestamp;

  // Notification services
  NativeBridge? _nativeBridge;
  NotificationPreferencesService? _notificationPrefs;
  NotificationGuardService? _notificationGuard;
  int _lastNotifiedMilestone = 0;

  /// Sets the notification services (called from main.dart after initialization)
  void setNotificationServices(NativeBridge nativeBridge, NotificationPreferencesService notificationPrefs, NotificationGuardService notificationGuard) {
    _nativeBridge = nativeBridge;
    _notificationPrefs = notificationPrefs;
    _notificationGuard = notificationGuard;
    // Initialize milestone tracking with current essence
    _lastNotifiedMilestone = (_playerState.totalEsencia ~/ 1000).toInt() * 1000;
  }

  // Constantes de anti-cheat
  static const int maxAccumulableHours = 12;

  /// Carga el estado del jugador y mejoras desde la base de datos
  Future<void> loadPlayerState() async {
    final stateData = await _db.getPlayerState();
    if (stateData != null) {
      _playerState = PlayerState.fromJson(stateData);
    } else {
      // Inicializar nuevo jugador
      _playerState = PlayerState.initial();
      await _db.updatePlayerState(_playerState.toJson());
    }

    // Cargar mejoras
    final upgradesData = await _db.getAllUpgrades();
    _upgrades = upgradesData.map((data) => Upgrade.fromJson(data)).toList();

    // Verificación de integridad: Asegurar que existe Energy Storage
    // REMOVED: We want Energy Storage to be initially UNOWNED (not in list)
    /*
    if (!_upgrades.any((u) => u.type == UpgradeType.energyStorage)) {
       // ... removed logic ...
    }
    */

    // Recalcular multiplicador basado en mejoras
    _updateMultipliers();

    notifyListeners();
  }

  /// Actualiza los multiplicadores basados en las mejoras actuales
  void _updateMultipliers() {
    final idleUpgrade = _upgrades.firstWhere(
      (u) => u.type == UpgradeType.idleMultiplier,
      orElse: () => Upgrade(
        id: 'upgrade_idle_multiplier',
        type: UpgradeType.idleMultiplier,
        currentLevel: 0,
        name: 'Recolector de Esencia',
        description: '',
      ),
    );

    _playerState = _playerState.copyWith(
      idleMultiplier: idleUpgrade.calculateMultiplier(),
    );
  }

  /// Inicializa el servicio
  Future<void> initialize() async {
    await loadPlayerState();
  }

  /// Calcula y añade la Esencia pendiente basada en:
  /// 1. Tiempo con móvil bloqueado (desde Android)
  /// 2. Tiempo activo en Stillwalks (desde ActiveTimeTracker)
  Future<void> calculatePendingEsencia(NativeBridge nativeBridge, activeTimeTracker) async {
    try {
      // 1. Obtener tiempo bloqueado desde Android nativo
      final lockedMinutes = await nativeBridge.getAccumulatedLockedMinutes();
      
      // 2. Obtener tiempo activo en Stillwalks
      final activeMinutes = activeTimeTracker.getCurrentAccumulatedMinutes();
      
      // 3. Sumar ambos tiempos
      final totalMinutes = lockedMinutes + activeMinutes;
      
      // 4. Aplicar límite de 24 horas
      final cappedMinutes = totalMinutes > (24 * 60) ? 24 * 60 : totalMinutes;
      final hoursElapsed = cappedMinutes / 60.0;
      
      // 5. Calcular esencia generada
      final esenciaGenerated = _playerState.esenciaPerHour * hoursElapsed;
      
      debugPrint('💎 EsenciaService: Locked: ${lockedMinutes}min, Active: ${activeMinutes}min, Total: ${cappedMinutes}min (${hoursElapsed.toStringAsFixed(2)}h)');
      
      if (esenciaGenerated <= 0) {
        debugPrint('💎 EsenciaService: No essence to generate');
        return;
      }
      
      // 6. Actualizar timestamp ANTES de añadir esencia (evitar feedback loop)
      final now = DateTime.now();
      _playerState = _playerState.copyWith(
        lastActiveTimestamp: now,
      );
      await _db.updatePlayerState(_playerState.toJson());
      
      // 7. Añadir esencia
      await addEsencia(esenciaGenerated);
      
      // 8. Reset contadores en ambos trackers
      await nativeBridge.resetAccumulatedTime();
      activeTimeTracker.reset();
      
      debugPrint('💰 EsenciaService: Generated $esenciaGenerated essence from ${hoursElapsed.toStringAsFixed(2)} hours (locked + active)');
      
    } catch (e) {
      debugPrint('❌ EsenciaService: Error calculating pending essence: $e');
    }
  }

  // Stream for notifying when essence is earned
  final _essenceEarnedController = StreamController<double>.broadcast();
  Stream<double> get onEssenceEarned => _essenceEarnedController.stream;

  @override
  void dispose() {
    _essenceEarnedController.close();
    super.dispose();
  }

  /// Añade Esencia (desde nativo o cálculo local)
  Future<void> addEsencia(double amount, {bool fromNative = false}) async {
    if (amount <= 0) return;

    // CRÍTICO: NO actualizar lastActiveTimestamp aquí
    // Esto causaba el feedback loop que generaba esencia infinita
    _playerState = _playerState.copyWith(
      totalEsencia: _playerState.totalEsencia + amount,
      // lastActiveTimestamp se actualiza SOLO en calculatePendingEsencia
    );

    await _db.updatePlayerState(_playerState.toJson());
    
    // Notify general listeners (UI updates)
    notifyListeners();
    
    // Notify specific event listeners (Game mechanics)
    debugPrint('💰 EsenciaService: Broadcasting $amount essence to stream listeners...');
    _essenceEarnedController.add(amount);

    _checkMilestoneNotification();

    final source = fromNative ? 'native Android' : 'app calculation';
    debugPrint('💰 EsenciaService: Added $amount Esencia from $source. Total: ${_playerState.totalEsencia}');
    
    // Sync with native for persistent notification
    _syncToNative();
  }

  /// Syncs current total essence to native side
  void _syncToNative() {
    if (_nativeBridge != null) {
      _nativeBridge!.syncEsencia(_playerState.totalEsencia);
      
      // Also update notification content immediately for responsiveness
      // We pass a generic body, but the native side will query the exact steps/essence
      // or we could pass it here. For now, we rely on Native side to pull data or we send it.
      // Actually, NativeBridge.updateNotificationContent expects title/body.
      // But we want the NATIVE service to format it. 
      // So we'll trigger an update via channel or rely on the syncEsencia to trigger it in native.
      // Let's rely on syncEsencia triggering the update in Native.
    }
  }

  // Progression Service
  final ProgressionService _progressionService = ProgressionService();

  // Stream for notifying level up events
  final _levelUpController = StreamController<int>.broadcast();
  Stream<int> get onLevelUp => _levelUpController.stream;

  /// Añade XP al jugador y verifica subida de nivel
  Future<void> addXp(int amount) async {
    if (amount <= 0) return;

    final oldLevel = _playerState.explorerLevel;
    final newXp = _playerState.currentXp + amount;
    
    // Calcular nuevo nivel basado en XP acumulada
    final newLevel = _progressionService.calculateLevel(newXp);

    _playerState = _playerState.copyWith(
      currentXp: newXp,
      explorerLevel: newLevel,
    );

    await _db.updatePlayerState(_playerState.toJson());
    notifyListeners();

    debugPrint('⭐ XP Added: $amount. Total XP: $newXp. Level: $oldLevel -> $newLevel');

    // Notificar si hubo subida de nivel
    if (newLevel > oldLevel) {
      debugPrint('🎉 LEVEL UP! $oldLevel -> $newLevel');
      _levelUpController.add(newLevel);
    }
  }

  /// Verifica si se ha alcanzado un nuevo hito de esencia
  void _checkMilestoneNotification() {
    if (_nativeBridge == null || _notificationPrefs == null) return;
    
    final settings = _notificationPrefs!.settings;
    if (!settings.eventsNotificationEnabled) return;

    final currentEssence = _playerState.totalEsencia.toInt();
    final currentMilestone = (currentEssence ~/ 1000) * 1000;

    if (currentMilestone > _lastNotifiedMilestone && currentMilestone >= 1000) {
      if (_notificationGuard == null || _notificationGuard!.shouldAllowNotification('milestone')) {
        _nativeBridge!.showMilestoneNotification(currentMilestone);
        _lastNotifiedMilestone = currentMilestone;
        _notificationGuard?.markNotified('milestone');
        debugPrint('💰 EsenciaService: Milestone notification sent for $currentMilestone essence');
      }
    }
  }

  /// Gasta Esencia (para compras)
  Future<bool> spendEsencia(double amount) async {
    if (_playerState.totalEsencia < amount) {
      return false; // No hay suficiente Esencia
    }

    _playerState = _playerState.copyWith(
      totalEsencia: _playerState.totalEsencia - amount,
    );

    await _db.updatePlayerState(_playerState.toJson());
    notifyListeners();

    // Sync with native
    _syncToNative();

    return true;
  }
  /// Verifica si el usuario posee una mejora
  bool hasUpgrade(UpgradeType type) {
    return _upgrades.any((u) => u.type == type);
  }

  /// Obtiene una mejora por tipo (si existe)
  Upgrade? getUpgrade(UpgradeType type) {
    try {
      return _upgrades.firstWhere((u) => u.type == type);
    } catch (_) {
      return null;
    }
  }

  /// Compra o desbloquea una mejora por tipo
  Future<bool> purchaseUpgradeByType(UpgradeType type) async {
    if (hasUpgrade(type)) {
      final upgrade = getUpgrade(type)!;
      return purchaseUpgrade(upgrade.id);
    }

    // Desbloquear (Nivel 0)
    // Costo base (index 0)
    final cost = type.baseCost; // Costo de desbloqueo (500 para Storage)

    // Verificar si hay suficiente Esencia
    if (_playerState.totalEsencia < cost) {
      return false;
    }

    // Definir ID y nombre según tipo
    String id = '';
    String name = '';
    String description = '';

    if (type == UpgradeType.energyStorage) {
      id = 'upgrade_energy_storage';
      name = 'Almacén de Energía';
      description = 'Permite acumular pasos para orbes futuros.';
    } else if (type == UpgradeType.idleMultiplier) {
      id = 'upgrade_idle_multiplier';
      name = 'Recolector de Esencia';
      description = 'Aumenta la generación pasiva.';
    } else if (type == UpgradeType.tapStrength) {
      id = 'upgrade_tap_strength';
      name = 'Fuerza de Toque';
      description = 'Aumenta la esencia ganada por cada toque.';
    } else if (type == UpgradeType.tapMultiplier) {
      id = 'upgrade_tap_multiplier';
      name = 'Ritmo Interior';
      description = 'Multiplica la esencia de los toques.';
    } else if (type == UpgradeType.globalMultiplier) {
      id = 'upgrade_global_multiplier';
      name = 'Sincronía Global';
      description = 'Aumenta toda la ganancia de esencia.';
    } else if (type == UpgradeType.offlineEfficiency) {
      id = 'upgrade_offline_efficiency';
      name = 'Meditación Profunda';
      description = 'Mejora la recolección offline.';
    } else {
      // Fallback for safety
      id = 'upgrade_${type.name}';
      name = type.name;
      description = 'Mejora desconocida';
    }

    final newUpgrade = Upgrade(
      id: id,
      type: type,
      currentLevel: 1, // Inicia en Nivel 1 (Al comprarlo obtienes el primer nivel)
      name: name,
      description: description,
    );

    // Gastar Esencia
    await spendEsencia(cost);

    // Guardar en DB y lista
    await _db.insertUpgrade(newUpgrade.toJson());
    _upgrades.add(newUpgrade);

    // Recalcular multiplicadores
    _updateMultipliers();
    
    // Add XP for unlocking
    addXp(10);

    notifyListeners();
    return true;
  }

  /// Compra una mejora (incrementa nivel)
  Future<bool> purchaseUpgrade(String upgradeId) async {
    final upgradeIndex = _upgrades.indexWhere((u) => u.id == upgradeId);
    if (upgradeIndex == -1) return false;

    final upgrade = _upgrades[upgradeIndex];
    
    // Verificar si puede ser mejorado
    if (!upgrade.canUpgrade()) return false;

    // Map UpgradeType to string ID used in ProgressionService
    String upgradeTypeId = '';
    if (upgrade.type == UpgradeType.idleMultiplier) upgradeTypeId = 'idle_multiplier';
    else if (upgrade.type == UpgradeType.energyStorage) upgradeTypeId = 'energy_storage';
    else if (upgrade.type == UpgradeType.tapStrength) upgradeTypeId = 'tap_strength';
    else if (upgrade.type == UpgradeType.tapMultiplier) upgradeTypeId = 'tap_multiplier';
    else if (upgrade.type == UpgradeType.globalMultiplier) upgradeTypeId = 'global_multiplier';
    else if (upgrade.type == UpgradeType.offlineEfficiency) upgradeTypeId = 'offline_efficiency';
    // Add sanctuary if it was an upgrade type, but it handles separately in OrbeService for Sanctuaries

    // Verificar límite por Nivel de Explorador
    final levelCap = _progressionService.getUpgradeCap(_playerState.explorerLevel, type: upgradeTypeId);
    
    // Si la mejora ya está en el cap del nivel actual (y el cap es restrictivo > 0)
    if (upgrade.currentLevel >= levelCap) {
      debugPrint('🚫 Upgrade cap reached for Level ${_playerState.explorerLevel}. Cap: $levelCap (Type: $upgradeTypeId)');
      return false;
    }
    
    final cost = upgrade.calculateNextLevelCost();

    // Verificar si hay suficiente Esencia
    if (_playerState.totalEsencia < cost) {
      return false;
    }

    // Gastar Esencia
    await spendEsencia(cost);

    // Subir nivel de mejora
    final upgradedUpgrade = upgrade.copyWith(
      currentLevel: upgrade.currentLevel + 1,
    );

    // Update in DB (using index logic or ID)
    // Note: DatabaseHelper might need 'type' if ID isn't unique, but usually ID is unique key.
    // However, if we inserted them manually...
    await _db.updateUpgrade(upgrade.id, {'currentLevel': upgradedUpgrade.currentLevel});
    _upgrades[upgradeIndex] = upgradedUpgrade;

    // Recalcular multiplicadores
    _updateMultipliers();
    
    // Force player state update to save Essence spending and potentially synced data
    await _db.updatePlayerState(_playerState.toJson());
    
    // Add XP for purchasing upgrade (20 XP)
    addXp(20);

    notifyListeners();
    return true;
  }

  /// Actualiza el contador de pasos
  Future<void> updateSteps(int steps) async {
    _playerState = _playerState.copyWith(
      totalSteps: _playerState.totalSteps + steps,
    );

    await _db.updatePlayerState(_playerState.toJson());
    notifyListeners();
  }

  /// Capacidad máxima del Almacén de Energía
  int get storageCapacity {
    if (!hasUpgrade(UpgradeType.energyStorage)) return 0;

    final storageUpgrade = getUpgrade(UpgradeType.energyStorage)!;
    
    // Level 0 (Just unlocked): 100
    // Level 1+: 100 + (level * 200) --> Wait, at L1 we want 300.
    // Formula: 100 + (level * 200).
    // L0: 100 + 0 = 100.
    // L1: 100 + 200 = 300.
    return 100 + (storageUpgrade.currentLevel * 200);
  }

  /// Añade pasos al almacén (respetando el límite)
  Future<void> addStoredSteps(int steps) async {
    final capacity = storageCapacity;
    if (capacity <= 0 || steps <= 0) return;

    final currentStored = _playerState.storedSteps;
    if (currentStored >= capacity) return;

    final spaceAvailable = capacity - currentStored;
    final stepsToAdd = steps > spaceAvailable ? spaceAvailable : steps;

    _playerState = _playerState.copyWith(
      storedSteps: currentStored + stepsToAdd,
    );

    await _db.updatePlayerState(_playerState.toJson());
    notifyListeners();
    debugPrint('🔋 EsenciaService: Stored $stepsToAdd steps. Total: ${_playerState.storedSteps}/$capacity');
  }

  /// Consume pasos del almacén
  Future<int> consumeStoredSteps(int amount) async {
    if (amount <= 0 || _playerState.storedSteps <= 0) return 0;

    final available = _playerState.storedSteps;
    final consumed = amount > available ? available : amount;

    _playerState = _playerState.copyWith(
      storedSteps: available - consumed,
    );

    await _db.updatePlayerState(_playerState.toJson());
    notifyListeners();
    debugPrint('🔋 EsenciaService: Consumed $consumed stored steps. Remaining: ${_playerState.storedSteps}');
    
    return consumed;
  }

  /// Reinicia el progreso del jugador (Debug)
  Future<void> resetProgress() async {
    _playerState = PlayerState.initial();
    
    // Reset upgrades
    for (var i = 0; i < _upgrades.length; i++) {
        _upgrades[i] = _upgrades[i].copyWith(currentLevel: 0);
        await _db.updateUpgrade(_upgrades[i].id, {'currentLevel': 0});
    }
    _updateMultipliers(); // Reset multipliers

    await _db.updatePlayerState(_playerState.toJson());
    notifyListeners();
    debugPrint('🔄 EsenciaService: Progress reset to initial state.');
  }



  // Collection Service reference for passive generation bonuses
  CollectionService? _collectionService;
  
  void setCollectionService(CollectionService collectionService) {
    _collectionService = collectionService;
    debugPrint('EsenciaService: CollectionService set. Total species: ${_collectionService?.totalSpeciesCount}');
    notifyListeners();
  }

  // Timer for passive generation
  Timer? _generationTimer;

  /// Starts the passive essence generation timer (when app is in foreground)
  void startGenerationTimer() {
    _generationTimer?.cancel();
    _generationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final passivePerSecond = passiveEssencePerSecond;
      if (passivePerSecond > 0) {
        addEsencia(passivePerSecond, fromNative: false);
      }
    });
    debugPrint('⏱️ Essence generation timer started');
  }

  /// Stops the passive essence generation timer
  void stopGenerationTimer() {
    _generationTimer?.cancel();
    _generationTimer = null;
    debugPrint('⏱️ Essence generation timer stopped');
  }

  /// Calculates passive essence per second from buildings and bonuses
  double get passiveEssencePerSecond {
    return _calculatePassiveRate();
  }

  double _calculatePassiveRate() {
    double total = 0.0;

    // Sum from all buildings
    for (final entry in _playerState.buildings.entries) {
      final buildingId = entry.key;
      final count = entry.value;

      // Find building type
      final type = BuildingType.values.firstWhere(
        (t) => t.id == buildingId,
        orElse: () => BuildingType.values.first,
      );

      total += type.baseProduction * count;
    }

    // Apply global multiplier if exists
    final globalUpgrade = _upgrades.firstWhere(
      (u) => u.type == UpgradeType.globalMultiplier,
      orElse: () => Upgrade(
        id: 'temp',
        type: UpgradeType.globalMultiplier,
        currentLevel: 0,
        name: '',
        description: '',
      ),
    );

    if (globalUpgrade.currentLevel > 0) {
      final multiplier = 1.0 + (globalUpgrade.currentLevel * globalUpgrade.type.incrementPerLevel);
      total *= multiplier;
    }



    // Apply Idle Multiplier (Recolector de Esencia)
    if (_playerState.idleMultiplier > 1.0) {
      total *= _playerState.idleMultiplier;
    }

    // Collection bonuses - TODO: implement getTotalPassiveBonus in CollectionService
    // if (_collectionService != null) {
    //   final collectionBonus = _collectionService!.getTotalPassiveBonus();
    //   total *= (1.0 + collectionBonus);
    // }

    return total;
  }

  /// Calculates offline essence (called when app resumes)
  Future<void> calculateOfflineEssence() async {
    try {
      final now = DateTime.now();
      final lastCheck = _playerState.lastOfflineCheck;
      
      final difference = now.difference(lastCheck);
      final secondsOffline = difference.inSeconds;
      
      if (secondsOffline <= 60) {
        // Less than a minute, ignore
        _playerState = _playerState.copyWith(lastOfflineCheck: now);
        await _db.updatePlayerState(_playerState.toJson());
        return;
      }

      // Cap at 12 hours
      final cappedSeconds = secondsOffline > (12 * 3600) ? (12 * 3600) : secondsOffline;

      // Get offline efficiency
      double offlineEfficiency = 0.05; // Base 5%
      final offlineUpgrade = _upgrades.firstWhere(
        (u) => u.type == UpgradeType.offlineEfficiency,
        orElse: () => Upgrade(
          id: 'temp',
          type: UpgradeType.offlineEfficiency,
          currentLevel: 0,
          name: '',
          description: '',
        ),
      );

      if (offlineUpgrade.currentLevel > 0) {
        offlineEfficiency += offlineUpgrade.currentLevel * 0.15; // +15% per level
      }

      final passiveRate = passiveEssencePerSecond;
      final offlineEssence = passiveRate * cappedSeconds * offlineEfficiency;

      if (offlineEssence > 0) {
        // Store for display
        _playerState = _playerState.copyWith(
          lastOfflineEarnedEssence: offlineEssence,
          lastOfflineCheck: now,
        );
        await _db.updatePlayerState(_playerState.toJson());

        // Add the essence
        await addEsencia(offlineEssence, fromNative: false);
        debugPrint('💤 Offline essence calculated: $offlineEssence (${secondsOffline}s offline, ${offlineEfficiency * 100}% efficiency)');
      } else {
        _playerState = _playerState.copyWith(lastOfflineCheck: now);
        await _db.updatePlayerState(_playerState.toJson());
      }
    } catch (e) {
      debugPrint('❌ Error calculating offline essence: $e');
    }
  }

  /// Obtiene la esencia generada offline (para mostrar en UI)
  double get lastOfflineEarnedEssence => _playerState.lastOfflineEarnedEssence;

  /// Limpia la esencia offline earned (después de mostrar el diálogo)
  Future<void> clearOfflineEarnedEssence() async {
    _playerState = _playerState.copyWith(lastOfflineEarnedEssence: 0.0);
    await _db.updatePlayerState(_playerState.toJson());
    notifyListeners();
  }

  ///Get building count
  int getBuildingCount(BuildingType type) {
    return _playerState.buildings[type.id] ?? 0;
  }

  /// Get building cost
  double getBuildingCost(BuildingType type) {
    final currentCount = getBuildingCount(type);
    return type.baseCost * pow(type.costScale, currentCount);
  }

  /// Buy a building
  Future<bool> buyBuilding(BuildingType type) async {
    final currentCount = getBuildingCount(type);

    // 1. Check Level Gate
    final playerLevel = _playerState.explorerLevel;
    // Use ProgressionService for dynamic caps based on level
    final maxAllowed = _progressionService.getUpgradeCap(playerLevel, type: type.id);
    
    // Fallback if maxAllowed is 0 (meaning not explicitly set, or locked)
    // But if it's 0 and we are trying to buy, it implies it might be locked.
    // However, if ProgressionService returns 0, we should probably assume strictly 0?
    // Let's assume if > 0 use it, otherwise fallback to type.getMaxAllowedCount ONLY if we are sure?
    // Actually, ProgressionService defines strict caps. If it returns 0, you can't buy.
    // EXCEPT: "Unlock.upgradeCap(0)" exists for general.
    
    // If maxAllowed is 0, we can check if it's genuinely 0 or just not defined. 
    // But given the config, it defines caps for building_recolector explicitly.
    // If it returns 0, we block.
    
    if (currentCount >= maxAllowed && maxAllowed > 0) {
      debugPrint('❌ Cannot buy building: already at max ($currentCount/$maxAllowed) for player level $playerLevel');
      return false;
    } else if (maxAllowed == 0 && currentCount > 0) {
       // If cap is 0, but we have some? weird.
       return false;
    } else if (maxAllowed == 0 && currentCount == 0) {
        // If cap is 0, maybe we can't buy any.
        // But wait, isItemUnlocked might handle "unlocking".
        // Use logic: if ProgressionService returns > 0, use it.
        // If it returns 0, check if we should fallback to loose logic? 
        // No, stay strict to ProgressionService.
        // Note: For Recolector at Level 1, it returns 5. So it works.
        debugPrint('❌ Cannot buy building: cap is 0 for player level $playerLevel');
        return false;
    }

    // 2. Check cost
    final cost = getBuildingCost(type);
    if (_playerState.totalEsencia < cost) {
      return false;
    }

    // 3. Spend essence
    await spendEsencia(cost);

    // 4. Update building count
    final newBuildings = Map<String, int>.from(_playerState.buildings);
    newBuildings[type.id] = currentCount + 1;

    _playerState = _playerState.copyWith(buildings: newBuildings);
    await _db.updatePlayerState(_playerState.toJson());

    // 5. Add XP
    addXp(5);

    notifyListeners();
    debugPrint('🏗️ Bought ${type.name} for $cost. New count: ${currentCount + 1}');
    return true;
  }

  /// Calculates the base tap strength (without multipliers)
  double get baseTapStrength {
    // 1. Base tap value always 1.0
    double tapValue = 1.0;
    
    // 2. Add Tap Strength upgrade
    final strengthUpgrade = _upgrades.firstWhere(
      (u) => u.type == UpgradeType.tapStrength,
      orElse: () => Upgrade(
        id: 'temp_tap_strength',
        type: UpgradeType.tapStrength,
        currentLevel: 0,
        name: 'Fuerza de Tap',
        description: '',
      ),
    );
    
    // Each level adds +1 to base tap
    tapValue += strengthUpgrade.currentLevel * (strengthUpgrade.type.incrementPerLevel);
    return tapValue;
  }

  /// Calculates the current essence generated per tap (including multipliers)
  double get essencePerTap {
    double tapValue = baseTapStrength;
    
    // 3. Apply Tap Multiplier
    final multiplierUpgrade = _upgrades.firstWhere(
      (u) => u.type == UpgradeType.tapMultiplier,
      orElse: () => Upgrade(
        id: 'temp_tap_multiplier',
        type: UpgradeType.tapMultiplier,
        currentLevel: 0,
        name: 'Ritmo Interior',
        description: '',
      ),
    );
    
    // Base multiplier 1.0 + (level * 0.05)
    double multiplier = 1.0 + (multiplierUpgrade.currentLevel * multiplierUpgrade.type.incrementPerLevel);
    
    return tapValue * multiplier;
  }

  /// Maneja un tap del usuario para generar esencia
  /// Retorna la cantidad de esencia generada para mostrar en UI
  double handleTap() {
    final finalEsencia = essencePerTap;
    
    // 5. Add to total essence (we don't await database here for performance, just update state)
    // We update local state immediately
    _playerState = _playerState.copyWith(
      totalEsencia: _playerState.totalEsencia + finalEsencia,
    );
    
    // Notify listeners so UI updates
    notifyListeners();
    
    // Trigger background save (fire and forget)
    _db.updatePlayerState(_playerState.toJson()).ignore();
    
    return finalEsencia;
  }
}
