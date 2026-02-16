import 'dart:convert';

/// Representa el estado global del jugador
class PlayerState {
  final double totalEsencia;
  final double idleMultiplier; // Multiplicador de generación pasiva
  final DateTime lastActiveTimestamp; // Última vez que el dispositivo fue desbloqueado
  final int totalSteps; // Pasos totales acumulados
  final int storedSteps; // Pasos almacenados (batería)
  final double esenciaPerHour; // Esencia generada por hora (calculado)
  final int explorerLevel; // Nivel de explorador (nuevo sistema de progresión)
  final int currentXp; // XP actual acumulada
  
  // New Essence System
  final Map<String, int> buildings; // Map of BuildingID -> Count
  final double tapMultiplier;
  final DateTime lastOfflineCheck;
  final double lastOfflineEarnedEssence; // Track offline earnings for display
  final bool freeOrbLevel2Claimed;

  PlayerState({
    required this.totalEsencia,
    required this.idleMultiplier,
    required this.lastActiveTimestamp,
    required this.totalSteps,
    this.storedSteps = 0,
    this.explorerLevel = 1,
    this.currentXp = 0,
    this.buildings = const {},
    this.tapMultiplier = 1.0,
    required this.lastOfflineCheck,
    this.lastOfflineEarnedEssence = 0.0,
    this.freeOrbLevel2Claimed = false,
  }) : esenciaPerHour = _calculateEsenciaPerHour(idleMultiplier);

  // Esencia base por hora NO LONGER USED in new system, keeping for compatibility until full refactor
  static double _calculateEsenciaPerHour(double multiplier) {
    return 300.0 * multiplier;
  }

  /// Calcula la Esencia generada desde lastActiveTimestamp hasta ahora
  /// Aplica el límite de 12 horas máximo
  double calculatePendingEsencia() {
    final now = DateTime.now();
    final elapsedTime = now.difference(lastActiveTimestamp);
    
    // Límite de 12 horas acumulables
    final cappedHours = elapsedTime.inMinutes / 60.0;
    final hoursToApply = cappedHours > 12.0 ? 12.0 : cappedHours;
    
    return esenciaPerHour * hoursToApply;
  }

  PlayerState copyWith({
    double? totalEsencia,
    double? idleMultiplier,
    DateTime? lastActiveTimestamp,
    int? totalSteps,
    int? storedSteps,
    int? explorerLevel,
    int? currentXp,
    Map<String, int>? buildings,
    double? tapMultiplier,
    DateTime? lastOfflineCheck,
    double? lastOfflineEarnedEssence,
    bool? freeOrbLevel2Claimed,
  }) {
    return PlayerState(
      totalEsencia: totalEsencia ?? this.totalEsencia,
      idleMultiplier: idleMultiplier ?? this.idleMultiplier,
      lastActiveTimestamp: lastActiveTimestamp ?? this.lastActiveTimestamp,
      totalSteps: totalSteps ?? this.totalSteps,
      storedSteps: storedSteps ?? this.storedSteps,
      explorerLevel: explorerLevel ?? this.explorerLevel,
      currentXp: currentXp ?? this.currentXp,
      buildings: buildings ?? this.buildings,
      tapMultiplier: tapMultiplier ?? this.tapMultiplier,
      lastOfflineCheck: lastOfflineCheck ?? this.lastOfflineCheck,
      lastOfflineEarnedEssence: lastOfflineEarnedEssence ?? this.lastOfflineEarnedEssence,
      freeOrbLevel2Claimed: freeOrbLevel2Claimed ?? this.freeOrbLevel2Claimed,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalEsencia': totalEsencia,
      'idleMultiplier': idleMultiplier,
      'lastActiveTimestamp': lastActiveTimestamp.toIso8601String(),
      'totalSteps': totalSteps,
      'storedSteps': storedSteps,
      'explorerLevel': explorerLevel,
      'currentXp': currentXp,
      'buildings': jsonEncode(buildings), // Encode map to JSON string for SQLite TEXT
      'tapMultiplier': tapMultiplier,
      'lastOfflineCheck': lastOfflineCheck.toIso8601String(),
      'lastOfflineEarnedEssence': lastOfflineEarnedEssence,
      'freeOrbLevel2Claimed': freeOrbLevel2Claimed,
    };
  }

  factory PlayerState.fromJson(Map<String, dynamic> json) {
    // Helper to parse buildings from String or Map (for backward compatibility)
    Map<String, int> parsedBuildings = {};
    if (json['buildings'] != null) {
      if (json['buildings'] is String) {
        try {
          final decoded = jsonDecode(json['buildings'] as String) as Map<String, dynamic>;
          parsedBuildings = decoded.map((k, v) => MapEntry(k, v as int));
        } catch (e) {
          // Error parsing, empty default
        }
      } else if (json['buildings'] is Map) {
        parsedBuildings = (json['buildings'] as Map).map((k, v) => MapEntry(k.toString(), v as int));
      }
    }

    return PlayerState(
      totalEsencia: (json['totalEsencia'] as num?)?.toDouble() ?? 0.0,
      idleMultiplier: (json['idleMultiplier'] as num?)?.toDouble() ?? 1.0,
      lastActiveTimestamp: json['lastActiveTimestamp'] != null 
          ? DateTime.parse(json['lastActiveTimestamp'] as String) 
          : DateTime.now(),
      totalSteps: (json['totalSteps'] as int?) ?? 0,
      storedSteps: (json['storedSteps'] as int?) ?? 0,
      explorerLevel: (json['explorerLevel'] as int?) ?? 1,
      currentXp: (json['currentXp'] as int?) ?? 0,
      buildings: parsedBuildings,
      tapMultiplier: (json['tapMultiplier'] as num?)?.toDouble() ?? 1.0,
      lastOfflineCheck: json['lastOfflineCheck'] != null 
          ? DateTime.parse(json['lastOfflineCheck'] as String) 
          : DateTime.now(),
      lastOfflineEarnedEssence: (json['lastOfflineEarnedEssence'] as num?)?.toDouble() ?? 0.0,
      freeOrbLevel2Claimed: json['freeOrbLevel2Claimed'] as bool? ?? false,
    );
  }

  // Estado inicial para nuevos jugadores
  factory PlayerState.initial() {
    return PlayerState(
      totalEsencia: 0.0,
      idleMultiplier: 1.0,
      lastActiveTimestamp: DateTime.now(),
      totalSteps: 0,
      storedSteps: 0,
      explorerLevel: 1,
      currentXp: 0,
      buildings: {},
      tapMultiplier: 1.0,
      lastOfflineCheck: DateTime.now(),
      lastOfflineEarnedEssence: 0.0,
      freeOrbLevel2Claimed: false,
    );
  }
}

