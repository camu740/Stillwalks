import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:stillwalks/models/player_state.dart';
import 'package:stillwalks/models/upgrade.dart';
import 'package:stillwalks/data/database/database_helper.dart';
import 'package:stillwalks/services/native_bridge.dart';
import 'package:stillwalks/services/notification_preferences_service.dart';
import 'package:stillwalks/services/progression_service.dart';
import 'package:stillwalks/services/notification_guard_service.dart';

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
  static const double baseEsenciaPerHour = 300.0;

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

  /// Calcula y añade la Esencia pendiente basada en tiempo offline
  Future<void> calculatePendingEsencia() async {
    final now = DateTime.now();
    final elapsedMinutes = now.difference(_playerState.lastActiveTimestamp).inMinutes;

    // Aplicar límite de 12 horas
    final cappedMinutes = elapsedMinutes > (maxAccumulableHours * 60)
        ? maxAccumulableHours * 60
        : elapsedMinutes;

    final hoursElapsed = cappedMinutes / 60.0;
    final esenciaGenerated = _playerState.esenciaPerHour * hoursElapsed;

    // Use addEsencia to trigger stream events for game mechanics
    if (esenciaGenerated > 0) {
      await addEsencia(esenciaGenerated);
      debugPrint('💰 EsenciaService: Calculated $esenciaGenerated pending essence from $hoursElapsed hours offline');
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

    _playerState = _playerState.copyWith(
      totalEsencia: _playerState.totalEsencia + amount,
      lastActiveTimestamp: DateTime.now(),
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
    final cost = type.costs[0]; // Costo de desbloqueo (500 para Storage)

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
    }

    final newUpgrade = Upgrade(
      id: id,
      type: type,
      currentLevel: 0, // Inicia en Nivel 0 (Desbloqueado)
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
    if (upgrade.type == UpgradeType.energyStorage) upgradeTypeId = 'energy_storage';
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
    
    // Add XP for purchasing upgrade (10 XP)
    addXp(10);

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
}
