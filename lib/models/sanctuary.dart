/// Representa un Santuario (incubadora) donde se colocan Orbes
class Sanctuary {
  final String id;
  final double speedMultiplier; // Multiplicador de velocidad de canalización
  final String? orbeId; // ID del Orbe asignado (null si está vacío)
  final String name;
  final String description;

  Sanctuary({
    required this.id,
    required this.speedMultiplier,
    this.orbeId,
    required this.name,
    required this.description,
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
  }) {
    return Sanctuary(
      id: id ?? this.id,
      speedMultiplier: speedMultiplier ?? this.speedMultiplier,
      orbeId: clearOrbe ? null : (orbeId ?? this.orbeId),
      name: name ?? this.name,
      description: description ?? this.description,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'speedMultiplier': speedMultiplier,
      'orbeId': orbeId,
      'name': name,
      'description': description,
    };
  }

  factory Sanctuary.fromJson(Map<String, dynamic> json) {
    return Sanctuary(
      id: json['id'] as String,
      speedMultiplier: json['speedMultiplier'] as double,
      orbeId: json['orbeId'] as String?,
      name: json['name'] as String,
      description: json['description'] as String,
    );
  }
}
