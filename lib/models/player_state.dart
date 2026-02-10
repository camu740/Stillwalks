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

  PlayerState({
    required this.totalEsencia,
    required this.idleMultiplier,
    required this.lastActiveTimestamp,
    required this.totalSteps,
    this.storedSteps = 0,
    this.explorerLevel = 1,
    this.currentXp = 0,
  }) : esenciaPerHour = _calculateEsenciaPerHour(idleMultiplier);

  // Esencia base por hora = 100, multiplicado por mejoras
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
  }) {
    return PlayerState(
      totalEsencia: totalEsencia ?? this.totalEsencia,
      idleMultiplier: idleMultiplier ?? this.idleMultiplier,
      lastActiveTimestamp: lastActiveTimestamp ?? this.lastActiveTimestamp,
      totalSteps: totalSteps ?? this.totalSteps,
      storedSteps: storedSteps ?? this.storedSteps,
      explorerLevel: explorerLevel ?? this.explorerLevel,
      currentXp: currentXp ?? this.currentXp,
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
    };
  }

  factory PlayerState.fromJson(Map<String, dynamic> json) {
    return PlayerState(
      totalEsencia: json['totalEsencia'] as double,
      idleMultiplier: json['idleMultiplier'] as double,
      lastActiveTimestamp: DateTime.parse(json['lastActiveTimestamp'] as String),
      totalSteps: json['totalSteps'] as int,
      storedSteps: (json['storedSteps'] as int?) ?? 0,
      explorerLevel: (json['explorerLevel'] as int?) ?? 1,
      currentXp: (json['currentXp'] as int?) ?? 0,
    );
  }

  // Estado inicial para nuevos jugadores
  factory PlayerState.initial() {
    return PlayerState(
      totalEsencia: 495.0, // Grants almost enough for first orb (500)
      idleMultiplier: 1.0,
      lastActiveTimestamp: DateTime.now(),
      totalSteps: 0,
      storedSteps: 0,
      explorerLevel: 1,
      currentXp: 0,
    );
  }
}
