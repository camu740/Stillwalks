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

  /// Calcula el coste para el siguiente nivel usando tablas fijas
  double calculateNextLevelCost() {
    final costs = type.getCosts();
    if (currentLevel >= costs.length) return double.infinity; // Máximo nivel alcanzado
    return costs[currentLevel];
  }

  /// Calcula el valor del multiplicador en el nivel actual
  double calculateMultiplier() {
    return 1.0 + (currentLevel * type.incrementPerLevel);
  }

  /// Verifica si la mejora puede seguir subiendo de nivel
  bool canUpgrade() {
    return currentLevel < type.maxLevel;
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
  idleMultiplier(
    baseCost: 1000,
    incrementPerLevel: 0.02,
    maxLevel: 6,
    costs: [1000, 2500, 5000, 9000, 15000, 25000], // Extendido
  ),
  energyStorage(
    baseCost: 500,
    incrementPerLevel: 300.0,
    maxLevel: 5,
    costs: [500, 1500, 3000, 5000, 8000],
  );

  const UpgradeType({
    required this.baseCost,
    required this.incrementPerLevel,
    required this.maxLevel,
    required this.costs,
  });

  final double baseCost;
  final double incrementPerLevel;
  final int maxLevel;
  final List<double> costs;

  /// Obtiene la lista de costes por nivel
  List<double> getCosts() => costs;
}
