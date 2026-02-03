import 'package:flutter/foundation.dart';
import 'package:stillwalks/models/player_state.dart';
import 'package:stillwalks/models/upgrade.dart';
import 'package:stillwalks/data/database/database_helper.dart';

/// Servicio que gestiona la generación de Esencia y el estado del jugador
class EsenciaService extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper();

  PlayerState _playerState = PlayerState.initial();
  List<Upgrade> _upgrades = [];

  PlayerState get playerState => _playerState;
  List<Upgrade> get upgrades => _upgrades;

  // Constantes de anti-cheat
  static const int maxAccumulableHours = 12;
  static const double baseEsenciaPerHour = 100.0;

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
        name: 'Generación Pasiva',
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

    final source = fromNative ? 'native Android' : 'app calculation';
    debugPrint('💰 EsenciaService: Added $amount Esencia from $source. Total: ${_playerState.totalEsencia}');
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

  /// Obtiene la mejora de reducción de costo de Orbes
  double getOrbeCostReduction() {
    final upgrade = _upgrades.firstWhere(
      (u) => u.type == UpgradeType.orbeCostReduction,
      orElse: () => Upgrade(
        id: 'upgrade_orbe_cost',
        type: UpgradeType.orbeCostReduction,
        currentLevel: 0,
        name: '',
        description: '',
      ),
    );

    // El multiplicador indica quanto reduce (ej: nivel 5 = 1.10, reduce 10%)
    return (upgrade.calculateMultiplier() - 1.0).clamp(0.0, 0.5); // Máximo 50% reducción
  }

  /// Obtiene el multiplicador de velocidad de santuario
  double getSanctuarySpeedMultiplier() {
    final upgrade = _upgrades.firstWhere(
      (u) => u.type == UpgradeType.sanctuarySpeed,
      orElse: () => Upgrade(
        id: 'upgrade_sanctuary_speed',
        type: UpgradeType.sanctuarySpeed,
        currentLevel: 0,
        name: '',
        description: '',
      ),
    );

    return upgrade.calculateMultiplier();
  }
}
