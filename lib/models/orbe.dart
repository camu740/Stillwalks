import 'dart:convert';

/// Define un tipo de Orbe con sus características
class OrbeType {
  final String id;
  final int requiredSteps; // Pasos necesarios para canalizar
  final String name;
  final String description;
  final Map<String, double> lootTable; // speciesId -> probability
  final Map<String, dynamic> mechanics; // Configuración flexible de comportamientos

  OrbeType({
    required this.id,
    required this.requiredSteps,
    required this.name,
    required this.description,
    required this.lootTable,
    this.mechanics = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'requiredSteps': requiredSteps,
      'name': name,
      'description': description,
      'lootTable': jsonEncode(lootTable),
      'mechanics': jsonEncode(mechanics),
    };
  }

  factory OrbeType.fromJson(Map<String, dynamic> json) {
    return OrbeType(
      id: json['id'] as String,
      requiredSteps: json['requiredSteps'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
      lootTable: Map<String, double>.from(
        jsonDecode(json['lootTable'] as String),
      ),
      mechanics: json['mechanics'] != null 
          ? jsonDecode(json['mechanics'] as String) 
          : {},
    );
  }
}

/// Representa una instancia de Orbe (en inventario o en santuario)
class Orbe {
  final String id;
  final String orbeTypeId;
  final int currentProgress; // Pasos actuales
  final String? stillwalkId; // ID del Stillwalk asignado tras canalización
  final DateTime createdAt;

  Orbe({
    required this.id,
    required this.orbeTypeId,
    required this.currentProgress,
    this.stillwalkId,
    required this.createdAt,
  });

  bool get isChanneled => stillwalkId != null;
  bool get isInProgress => stillwalkId == null && currentProgress > 0;
  bool get isNew => currentProgress == 0 && stillwalkId == null;

  /// Calcula el porcentaje de progreso (0.0 a 1.0)
  double progressPercentage(int requiredSteps) {
    if (requiredSteps == 0) return 0.0;
    final progress = currentProgress / requiredSteps;
    return progress > 1.0 ? 1.0 : progress;
  }

  bool isReadyToChannel(int requiredSteps) {
    return currentProgress >= requiredSteps && stillwalkId == null;
  }

  Orbe copyWith({
    String? id,
    String? orbeTypeId,
    int? currentProgress,
    String? stillwalkId,
    DateTime? createdAt,
  }) {
    return Orbe(
      id: id ?? this.id,
      orbeTypeId: orbeTypeId ?? this.orbeTypeId,
      currentProgress: currentProgress ?? this.currentProgress,
      stillwalkId: stillwalkId ?? this.stillwalkId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orbeTypeId': orbeTypeId,
      'currentProgress': currentProgress,
      'stillwalkId': stillwalkId,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Orbe.fromJson(Map<String, dynamic> json) {
    return Orbe(
      id: json['id'] as String,
      orbeTypeId: json['orbeTypeId'] as String,
      currentProgress: json['currentProgress'] as int,
      stillwalkId: json['stillwalkId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
