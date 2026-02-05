import 'package:flutter/foundation.dart';
import 'package:stillwalks/models/player_state.dart';
import 'package:stillwalks/models/upgrade.dart';
import 'package:stillwalks/data/database/database_helper.dart';
import 'package:stillwalks/services/native_bridge.dart';
import 'package:stillwalks/services/notification_preferences_service.dart';
import 'package:stillwalks/services/notification_guard_service.dart';

/// Servicio que gestiona la generación de Esencia y el estado del jugador
class EsenciaService extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper();

  PlayerState _playerState = PlayerState.initial();
  List<Upgrade> _upgrades = [];

  PlayerState get playerState => _playerState;
  List<Upgrade> get upgrades => _upgrades;

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
    if (!_upgrades.any((u) => u.type == UpgradeType.energyStorage)) {
      final storageUpgrade = Upgrade(
        id: 'upgrade_energy_storage',
        type: UpgradeType.energyStorage,
        currentLevel: 0,
        name: 'Almacén de Energía',
        description: 'Permite acumular pasos para orbes futuros.',
      );
      await _db.insertUpgrade(storageUpgrade.toJson());
      _upgrades.add(storageUpgrade);
      debugPrint('🔋 EsenciaService: Upgrade "Energy Storage" inserted because it was missing.');
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

    // Actualizar estado
    _playerState = _playerState.copyWith(
      totalEsencia: _playerState.totalEsencia + esenciaGenerated,
      lastActiveTimestamp: now,
    );

    await _db.updatePlayerState(_playerState.toJson());
    notifyListeners();
  }

  /// Añade Esencia (desde nativo o cálculo local)
  Future<void> addEsencia(double amount, {bool fromNative = false}) async {
    if (amount <= 0) return;

    _playerState = _playerState.copyWith(
      totalEsencia: _playerState.totalEsencia + amount,
      lastActiveTimestamp: DateTime.now(),
    );

    await _db.updatePlayerState(_playerState.toJson());
    notifyListeners();

    _checkMilestoneNotification();

    final source = fromNative ? 'native Android' : 'app calculation';
    debugPrint('💰 EsenciaService: Added $amount Esencia from $source. Total: ${_playerState.totalEsencia}');
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

  /// Compra una mejora
  Future<bool> purchaseUpgrade(String upgradeId) async {
    final upgradeIndex = _upgrades.indexWhere((u) => u.id == upgradeId);
    if (upgradeIndex == -1) return false;

    final upgrade = _upgrades[upgradeIndex];
    
    // Verificar si puede ser mejorado
    if (!upgrade.canUpgrade()) return false;
    
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

    await _db.updateUpgrade(upgradeId, {'currentLevel': upgradedUpgrade.currentLevel});
    _upgrades[upgradeIndex] = upgradedUpgrade;

    // Recalcular multiplicadores
    _updateMultipliers();
    await _db.updatePlayerState(_playerState.toJson());

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
    final storageUpgrade = _upgrades.firstWhere(
      (u) => u.type == UpgradeType.energyStorage,
      orElse: () => Upgrade(
        id: 'upgrade_energy_storage',
        type: UpgradeType.energyStorage,
        currentLevel: 0,
        name: 'Almacén de Energía',
        description: '',
      ),
    );
    return storageUpgrade.currentLevel * 300;
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
}
