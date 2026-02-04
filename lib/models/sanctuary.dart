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
  final int speedUpgradeLevel; // Nivel de mejora de velocidad (0-6)

  Sanctuary({
    required this.id,
    required this.speedMultiplier,
    this.orbeId,
    required this.name,
    required this.description,
    this.isTemporary = false,
    this.remainingUses = 0,
    this.typeId,
    this.speedUpgradeLevel = 0,
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
    int? speedUpgradeLevel,
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
      speedUpgradeLevel: speedUpgradeLevel ?? this.speedUpgradeLevel,
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
      'speedUpgradeLevel': speedUpgradeLevel,
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
      speedUpgradeLevel: json['speedUpgradeLevel'] as int? ?? 0,
    );
  }

  /// Calcula el multiplicador de velocidad basado en el nivel de mejora
  /// Cada nivel reduce los pasos en 2% (nivel 15 = -30% máximo)
  static double calculateSpeedMultiplier(int upgradeLevel) {
    final reductionPercent = (upgradeLevel * 0.02).clamp(0.0, 0.30);
    return 1.0 + reductionPercent;
  }

  /// Obtiene el coste de la siguiente mejora de velocidad
  static double getUpgradeCost(int currentLevel) {
    // 15 niveles de mejora para un progreso más granular
    const costs = [
      300.0, 500.0, 700.0, 900.0, 1200.0, // Nv 1-5 (Early)
      1500.0, 1800.0, 2200.0, 2600.0, 3000.0, // Nv 6-10 (Mid)
      3500.0, 4000.0, 4500.0, 5000.0, 6000.0 // Nv 11-15 (Late)
    ];
    if (currentLevel >= costs.length) return double.infinity;
    return costs[currentLevel];
  }

  /// Comprueba si el santuario puede ser mejorado
  bool canUpgrade() {
    return !isTemporary && speedUpgradeLevel < 15;
  }
}
