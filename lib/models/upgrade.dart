/// Representa una mejora comprable con Esencia
class Upgrade {
  final String id;
  final UpgradeType type;
  final int currentLevel;
  final String name;
  final String description;
  
  Upgrade({
    required this.id,
    required this.type,
    required this.currentLevel,
    required this.name,
    required this.description,
  });

  /// Calcula el costo para el siguiente nivel
  /// Fórmula: baseCost * (1.15 ^ currentLevel)
  double calculateNextLevelCost() {
    final baseCost = type.baseCost;
    return baseCost * _pow(1.15, currentLevel.toDouble());
  }

  double _pow(double base, double exponent) {
    if (exponent == 0) return 1;
    double result = 1;
    for (int i = 0; i < exponent.toInt(); i++) {
      result *= base;
    }
    return result;
  }

  /// Calcula el valor del multiplicador en el nivel actual
  double calculateMultiplier() {
    return 1.0 + (currentLevel * type.incrementPerLevel);
  }

  Upgrade copyWith({
    String? id,
    UpgradeType? type,
    int? currentLevel,
    String? name,
    String? description,
  }) {
    return Upgrade(
      id: id ?? this.id,
      type: type ?? this.type,
      currentLevel: currentLevel ?? this.currentLevel,
      name: name ?? this.name,
      description: description ?? this.description,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString(),
      'currentLevel': currentLevel,
      'name': name,
      'description': description,
    };
  }

  factory Upgrade.fromJson(Map<String, dynamic> json) {
    return Upgrade(
      id: json['id'] as String,
      type: UpgradeType.values.firstWhere(
        (e) => e.toString() == json['type'],
      ),
      currentLevel: json['currentLevel'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
    );
  }
}

/// Tipos de mejoras disponibles
enum UpgradeType {
  idleMultiplier(baseCost: 100, incrementPerLevel: 0.1),
  sanctuarySpeed(baseCost: 200, incrementPerLevel: 0.05),
  orbeCostReduction(baseCost: 150, incrementPerLevel: 0.02);

  const UpgradeType({
    required this.baseCost,
    required this.incrementPerLevel,
  });

  final double baseCost;
  final double incrementPerLevel;
}
