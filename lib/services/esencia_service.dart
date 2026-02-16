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
import 'package:stillwalks/services/tutorial_service.dart';
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
    
    // Repair: Force Tap Strength to be at least Level 1
    bool needsUpdate = false;
    for (var u in _upgrades) {
      if (u.type == UpgradeType.tapStrength && u.currentLevel < 1) {
        // Upgrade to Level 1
        final index = _upgrades.indexOf(u);
        _upgrades[index] = u.copyWith(currentLevel: 1);
        _db.updateUpgrade(u.id, {'currentLevel': 1}).ignore();
        needsUpdate = true;
      }
    }
    
    // If tapStrength is missing entirely (e.g. old save), add it?
    // It should be handled by seedUpgrades or orElse logic, but better to be safe.
    if (!_upgrades.any((u) => u.type == UpgradeType.tapStrength)) {
        final newUpgrade = Upgrade(
          id: 'upgrade_tap_strength',
          type: UpgradeType.tapStrength,
          currentLevel: 1,
          name: 'Fuerza de Tap',
          description: 'Aumenta la cantidad de Esencia generada por click.',
        );
        _upgrades.add(newUpgrade);
        _db.insertUpgrade(newUpgrade.toJson()).ignore();
        needsUpdate = true;
    }

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
      // Ensure tapMultiplier is updated if it exists in state? 
      // Actually PlayerState.tapMultiplier is a legacy field, 
      // the real logic uses get baseTapStrength.
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
      
      // 4. Time Limit Calculation
      // Logic:
      // - Eco Persistent (Offline Efficiency) Level >= 1 grants BASE 15 minutes (Level 1 equivalent).
      // - Persistent Memory (Offline Time) adds levels on top of that base.
      
       // Check Eco Upgrade existence first
      final echoUpgrade = _upgrades.firstWhere(
        (u) => u.type == UpgradeType.offlineEfficiency,
        orElse: () => Upgrade(
            id: 'temp_offline_efficiency',
            type: UpgradeType.offlineEfficiency,
            currentLevel: 0,
            name: 'Eco Persistente',
            description: '',
        )
      );

      final memoryUpgrade = _upgrades.firstWhere(
        (u) => u.type == UpgradeType.offlineTime,
        orElse: () => Upgrade(
          id: 'temp_offline_time',
          type: UpgradeType.offlineTime,
          currentLevel: 0,
          name: 'Memoria Persistente',
          description: '',
        ),
      );

      double maxOfflineMinutes = 0.0;
      
      if (echoUpgrade.currentLevel > 0) {
          int effectiveTimeLevel = 1; // Base 15 min
          if (memoryUpgrade.currentLevel > 0) {
              effectiveTimeLevel += memoryUpgrade.currentLevel;
          }
          maxOfflineMinutes = _getOfflineTimeLimit(effectiveTimeLevel);
      } else {
          maxOfflineMinutes = 0.0;
      }


      if (echoUpgrade.currentLevel == 0) {
         maxOfflineMinutes = 0.0; // Hard lock if Eco not unlocked
      }

      final cappedMinutes = totalMinutes > maxOfflineMinutes ? maxOfflineMinutes : totalMinutes;
      final hoursElapsed = cappedMinutes / 60.0;
      
      // 5. Calcular esencia generada (Base pasiva * Eco Efficiency)
      final passiveRate = passiveEssencePerSecond; 
      final passivePerHour = passiveRate * 3600;
      
      // Eco Efficiency: 1% per level (Max 15%)
      double efficiency = echoUpgrade.currentLevel * 0.01;
      
      final esenciaGenerated = passivePerHour * hoursElapsed * efficiency;
      
      debugPrint('💎 EsenciaService: Total: ${totalMinutes}min. Capped: ${maxOfflineMinutes}min. Eff: ${(efficiency*100).toStringAsFixed(1)}%');
      
      if (esenciaGenerated <= 0) return;
      
      final now = DateTime.now();
      _playerState = _playerState.copyWith(
        lastActiveTimestamp: now,
        lastOfflineEarnedEssence: esenciaGenerated,
        lastOfflineCheck: now,
      );
      await _db.updatePlayerState(_playerState.toJson());
      
      await addEsencia(esenciaGenerated);
      
      await nativeBridge.resetAccumulatedTime();
      activeTimeTracker.reset();
      
    } catch (e) {
      debugPrint('❌ EsenciaService: Error calculating pending essence: $e');
    }
  }

  double _getOfflineTimeLimit(int level) {
      // Nivel 1 desbloquea 15 min. Max(15) es 8h.
      // 1: 15m
      // 5: 90m
      // 10: 300m
      // 15: 480m
      if (level <= 0) return 0.0;
      if (level == 1) return 15.0;
      
      // Linear interpolation between breakpoints?
      if (level <= 5) return 15.0 + ((level - 1) * (75.0 / 4)); // 1->15, 5->90. Diff 75 in 4 steps. 18.75/lvl
      if (level <= 10) return 90.0 + ((level - 5) * (210.0 / 5)); // 5->90, 10->300. Diff 210 in 5 steps. 42/lvl
      return 300.0 + ((level - 10) * (180.0 / 5)); // 10->300, 15->480. Diff 180 in 5 steps. 36/lvl
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
    // debugPrint('💰 EsenciaService: Broadcasting $amount essence to stream listeners...');
    _essenceEarnedController.add(amount);

    _checkMilestoneNotification();

    final source = fromNative ? 'native Android' : 'app calculation';
    // debugPrint('💰 EsenciaService: Added $amount Esencia from $source. Total: ${_playerState.totalEsencia}');
    
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

  // Tutorial Service reference
  TutorialService? _tutorialService;

  void setTutorialService(TutorialService tutorialService) {
    _tutorialService = tutorialService;
  }

  // Progression Service
  final ProgressionService _progressionService = ProgressionService();


  // Stream for notifying level up events
  final _levelUpController = StreamController<int>.broadcast();
  Stream<int> get onLevelUp => _levelUpController.stream;

  /// Añade XP al jugador y verifica subida de nivel
  Future<void> addXp(int amount) async {
    if (amount <= 0) return;

    // Bloquear ganancia de XP durante el tutorial para evitar popups superpuestos
    if (_tutorialService != null && _tutorialService!.isActive) {
      debugPrint('🎓 EsenciaService: XP gain blocked during tutorial.');
      return;
    }

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
      name = 'Fuerza de Tap'; // Updated name
      description = 'Aumenta la esencia ganada por cada toque.';
    } else if (type == UpgradeType.tapMultiplier) {
      id = 'upgrade_tap_multiplier'; // Keep ID
      name = 'Ritmo Interior'; // Updated name
      description = 'Reduce el tiempo entre toques.'; // Updated desc
    } else if (type == UpgradeType.globalMultiplier) {
      id = 'upgrade_global_multiplier';
      name = 'Flujo Esencial'; // Updated name
      description = 'Multiplicador global de producción.';
    } else if (type == UpgradeType.offlineEfficiency) {
      id = 'upgrade_offline_efficiency';
      name = 'Eco Persistente'; // Updated name
      description = 'Genera un % de producción estando offline.';
    } else if (type == UpgradeType.offlineTime) {
      id = 'upgrade_offline_time';
      name = 'Memoria Persistente';
      description = 'Aumenta el tiempo máximo de producción offline.';
    } else {
      // Fallback for safety
      id = 'upgrade_${type.name}';
      name = type.name;
      description = 'Mejora desconocida';
    }

    final newUpgrade = Upgrade(
      id: id,
      type: type,
      currentLevel: type == UpgradeType.tapStrength ? 2 : 1, // Si es Fuerza de Tap, salta a Nivel 2 (ya que Nv 1 es el base)
      name: name,
      description: description,
    );

    // Gastar Esencia
    await spendEsencia(cost);

    // Guardar en lista (Memoria primero)
    _upgrades.add(newUpgrade);
    _updateMultipliers();
    notifyListeners();

    // Guardar en DB
    try {
      await _db.insertUpgrade(newUpgrade.toJson());
      debugPrint('✅ Upgrade unlocked and persisted: ${newUpgrade.id}');
    } catch (e) {
      debugPrint('❌ CRITICAL ERROR inserting upgrade in DB: $e');
      // DB desincronizada, pero el usuario tiene la mejora en esta sesión.
    }
    
    // Add XP for unlocking
    addXp(40);

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
    else if (upgrade.type == UpgradeType.offlineTime) upgradeTypeId = 'offline_time';
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
    // Esto actualiza el estado del jugador y la base de datos
    await spendEsencia(cost);

    // Subir nivel de mejora
    final upgradedUpgrade = upgrade.copyWith(
      currentLevel: upgrade.currentLevel + 1,
    );

    // Actualizar en lista (Memoria primero para UI responsiva)
    _upgrades[upgradeIndex] = upgradedUpgrade;
    _updateMultipliers(); // Recalcular multiplicadores
    notifyListeners(); // Notificar UI inmediatamente

    // Actualizar en DB
    try {
      await _db.updateUpgrade(upgrade.id, {'currentLevel': upgradedUpgrade.currentLevel});
      debugPrint('✅ Upgrade persisted: ${upgrade.id} -> ${upgradedUpgrade.currentLevel}');
    } catch (e) {
      debugPrint('❌ CRITICAL ERROR updating upgrade in DB: $e');
      // No revertimos memoria para no confundir al usuario, pero la DB estará desincronizada hasta el próximo reinicio o save exitoso.
      // Podríamos reintentar o marcar flag de "dirty".
    }
    
    // Add XP for purchasing upgrade (20 XP)
    // Era 40 antes? El comentario decía 20 pero el código 40.
    // Estandarizamos a 40 como estaba.
    addXp(40);

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
    
    // Reset upgrades to their startLevel (e.g. Tap Strength starts at 1)
    for (var i = 0; i < _upgrades.length; i++) {
        final startLvl = _upgrades[i].type.startLevel;
        _upgrades[i] = _upgrades[i].copyWith(currentLevel: startLvl);
        await _db.updateUpgrade(_upgrades[i].id, {'currentLevel': startLvl});
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

    // Apply global multiplier (Flow Essence)
    // +1% per level. Max 20%.
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
      final multiplier = 1.0 + (globalUpgrade.currentLevel * 0.01);
      total *= multiplier;
    }

    // Apply Idle Multiplier (Legacy/Recolector Efficiency)
    if (_playerState.idleMultiplier > 1.0) {
      total *= _playerState.idleMultiplier;
    }

    // Collection bonuses
    // if (_collectionService != null) {
    //   final collectionBonus = _collectionService!.getTotalPassiveBonus();
    //   total *= (1.0 + collectionBonus);
    // }

    return total;
  }

  /// Calculates offline essence (Obsolete, see calculatePendingEsencia)
  Future<void> calculateOfflineEssence() async {}

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
    
    if (currentCount >= maxAllowed && maxAllowed > 0) {
      debugPrint('❌ Cannot buy building: already at max ($currentCount/$maxAllowed) for player level $playerLevel');
      return false;
    } else if (maxAllowed == 0 && currentCount > 0) {
       return false;
    } else if (maxAllowed == 0 && currentCount == 0) {
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
    addXp(50);

    notifyListeners();
    debugPrint('🏗️ Bought ${type.name} for $cost. New count: ${currentCount + 1}');
    return true;
  }

  /// Calculates the base tap strength (without multipliers)
  double get baseTapStrength {
    final strengthUpgrade = _upgrades.firstWhere(
      (u) => u.type == UpgradeType.tapStrength,
      orElse: () => Upgrade(
        id: 'temp_tap_strength',
        type: UpgradeType.tapStrength,
        currentLevel: 1, 
        name: 'Fuerza de Tap',
        description: '',
      ),
    );
    
    // Nivel = Esencia (min 1)
    int level = strengthUpgrade.currentLevel;
    if (level < 1) level = 1; 

    return level.toDouble();
  }

  /// Calculates the current essence generated per tap
  double get essencePerTap {
    // Only depends on Tap Force. Inner Rhythm affects cooldown.
    return baseTapStrength;
  }

  DateTime _lastTapTime = DateTime.fromMillisecondsSinceEpoch(0);
  
  Duration get tapCooldown {
     final innerRhythm = _upgrades.firstWhere(
      (u) => u.type == UpgradeType.tapMultiplier, 
      orElse: () => Upgrade(
        id: 'temp_inner_rhythm',
        type: UpgradeType.tapMultiplier,
        currentLevel: 0,
        name: 'Ritmo Interior',
        description: '',
      ),
    );

    int level = innerRhythm.currentLevel;
    if (level <= 0) return const Duration(milliseconds: 3000); 

    double cooldownSeconds = 3.0; 
    
    if (level >= 1 && level <= 13) {
        cooldownSeconds = 3.0 - ((level - 1) * 0.2);
    } else if (level == 14) {
        cooldownSeconds = 0.45;
    } else if (level >= 15) {
        cooldownSeconds = 0.3;
    }
    
    return Duration(milliseconds: (cooldownSeconds * 1000).toInt());
  }

  /// Maneja un tap del usuario para generar esencia
  double handleTap() {
    final now = DateTime.now();
    final difference = now.difference(_lastTapTime);
    final cooldown = tapCooldown;
    
    // Permitir un pequeño margen de error (100ms) para evitar desincronización con UI
    if (difference.inMilliseconds < (cooldown.inMilliseconds - 100)) {
       return 0.0; // Cooldown active
    }

    final finalEsencia = essencePerTap;
    _lastTapTime = now;
    
    _playerState = _playerState.copyWith(
      totalEsencia: _playerState.totalEsencia + finalEsencia,
    );
    
    notifyListeners();
    _db.updatePlayerState(_playerState.toJson()).ignore();
    
    return finalEsencia;
  }

  /// Verifica si la oferta de orbe gratuito de nivel 2 está disponible
  bool get isLevel2FreeOrbAvailable {
    return _playerState.explorerLevel >= 2 && !_playerState.freeOrbLevel2Claimed;
  }

  /// Marca la oferta de orbe gratuito como reclamada
  Future<void> claimLevel2FreeOrb() async {
    if (!isLevel2FreeOrbAvailable) return;

    _playerState = _playerState.copyWith(freeOrbLevel2Claimed: true);
    await _db.updatePlayerState(_playerState.toJson());
    notifyListeners();
    debugPrint('🎁 EsenciaService: Level 2 Free Orb claimed.');
  }

  /// Sets the free orb claimed flag (Debug/Manual)
  Future<void> setFreeOrbClaimed(bool claimed) async {
      _playerState = _playerState.copyWith(freeOrbLevel2Claimed: claimed);
      await _db.updatePlayerState(_playerState.toJson());
      notifyListeners();
  }
}
