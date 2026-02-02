/// Representa una instancia específica de un Stillwalk capturado por el jugador
/// Separado de CreatureSpecies para permitir futuras mejoras:
/// - Múltiples capturas de la misma especie
/// - Estadísticas individuales
/// - Formas/evoluciones diferentes
/// - Intercambio entre jugadores (sin perder la especie del diario)
class CreatureInstance {
  final String id;
  final String speciesId; // Referencia a CreatureSpecies
  final DateTime caughtAt; // Fecha de captura
  final String? nickname; // Apodo personalizado (futuro)
  
  // Campos para futuras expansiones
  final int currentForm; // 0 = forma base, 1+ = evoluciones
  final bool isFavorite; // Marcado como favorito

  CreatureInstance({
    required this.id,
    required this.speciesId,
    required this.caughtAt,
    this.nickname,
    this.currentForm = 0,
    this.isFavorite = false,
  });

  CreatureInstance copyWith({
    String? id,
    String? speciesId,
    DateTime? caughtAt,
    String? nickname,
    int? currentForm,
    bool? isFavorite,
  }) {
    return CreatureInstance(
      id: id ?? this.id,
      speciesId: speciesId ?? this.speciesId,
      caughtAt: caughtAt ?? this.caughtAt,
      nickname: nickname ?? this.nickname,
      currentForm: currentForm ?? this.currentForm,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'speciesId': speciesId,
      'caughtAt': caughtAt.toIso8601String(),
      'nickname': nickname,
      'currentForm': currentForm,
      'isFavorite': isFavorite ? 1 : 0,
    };
  }

  factory CreatureInstance.fromJson(Map<String, dynamic> json) {
    return CreatureInstance(
      id: json['id'] as String,
      speciesId: json['speciesId'] as String,
      caughtAt: DateTime.parse(json['caughtAt'] as String),
      nickname: json['nickname'] as String?,
      currentForm: json['currentForm'] as int? ?? 0,
      isFavorite: (json['isFavorite'] as int? ?? 0) == 1,
    );
  }
}
