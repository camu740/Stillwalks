/// Representa un Santuario (incubadora) donde se colocan Orbes
class Sanctuary {
  final String id;
  final double speedMultiplier; // Multiplicador de velocidad de canalización
  final String? orbeId; // ID del Orbe asignado (null si está vacío)
  final String name;
  final String description;
  final bool isTemporary;
  final int remainingUses;
  final String? typeId;

  Sanctuary({
    required this.id,
    required this.speedMultiplier,
    this.orbeId,
    required this.name,
    required this.description,
    this.isTemporary = false,
    this.remainingUses = 0,
    this.typeId,
  });

  bool get isEmpty => orbeId == null;
  bool get hasOrbe => orbeId != null;

  Sanctuary copyWith({
    String? id,
    double? speedMultiplier,
    String? orbeId,
    bool clearOrbe = false,
    String? name,
    String? description,
    bool? isTemporary,
    int? remainingUses,
    String? typeId,
  }) {
    return Sanctuary(
      id: id ?? this.id,
      speedMultiplier: speedMultiplier ?? this.speedMultiplier,
      orbeId: clearOrbe ? null : (orbeId ?? this.orbeId),
      name: name ?? this.name,
      description: description ?? this.description,
      isTemporary: isTemporary ?? this.isTemporary,
      remainingUses: remainingUses ?? this.remainingUses,
      typeId: typeId ?? this.typeId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'speedMultiplier': speedMultiplier,
      'orbeId': orbeId,
      'name': name,
      'description': description,
      'isTemporary': isTemporary ? 1 : 0,
      'remainingUses': remainingUses,
      'typeId': typeId,
    };
  }

  factory Sanctuary.fromJson(Map<String, dynamic> json) {
    return Sanctuary(
      id: json['id'] as String,
      speedMultiplier: (json['speedMultiplier'] as num).toDouble(),
      orbeId: json['orbeId'] as String?,
      name: json['name'] as String,
      description: json['description'] as String,
      isTemporary: (json['isTemporary'] as int? ?? 0) == 1,
      remainingUses: json['remainingUses'] as int? ?? 0,
      typeId: json['typeId'] as String?,
    );
  }
}
