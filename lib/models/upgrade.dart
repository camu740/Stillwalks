import 'dart:math' as math;

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

  /// Calcula el coste para el siguiente nivel usando tablas fijas o fórmula dinámica
  double calculateNextLevelCost() {
    final costs = type.getCosts();
    
    // Si la lista de costos está vacía, usar cálculo dinámico
    if (costs.isEmpty) {
      if (currentLevel >= type.maxLevel) return double.infinity;
      
      return type.baseCost * math.pow(type.costScale, currentLevel);
    }
    
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
    incrementPerLevel: 0.05, 
    maxLevel: 12,
    costScale: 2.5,
    costs: [], 
  ),
  energyStorage(
    baseCost: 500,
    incrementPerLevel: 200.0, // Capacity +200 per level
    maxLevel: 12,
    costScale: 1.6,
    costs: [], 
  ),
  tapStrength(
    baseCost: 25,
    incrementPerLevel: 1.0, 
    maxLevel: 30, // Expanded from 20 to 30 as per doc recommendation
    costScale: 1.5,
    costs: [], 
  ),
  tapMultiplier( // Represents "Inner Rhythm"
    baseCost: 150,
    incrementPerLevel: 0.0, // Handled via specific logic (Cooldown)
    maxLevel: 15, 
    costScale: 1.5,
    costs: [],
  ),
  globalMultiplier( // Represents "Essence Flow"
    baseCost: 2500,
    incrementPerLevel: 0.01, // +1% per level
    maxLevel: 20, 
    costScale: 1.6,
    costs: [],
  ),
  offlineEfficiency( // Represents "Echo Persistent" (%)
    baseCost: 3000,
    incrementPerLevel: 0.01, // +1% per level
    maxLevel: 15,
    costScale: 1.7, 
    costs: [], 
  ),
  offlineTime( // Represents "Memory Persistent" (Time)
    baseCost: 2500,
    incrementPerLevel: 0.0, // Handled via specific logic (Time table)
    maxLevel: 15,
    costScale: 1.6,
    costs: [],
  );

  const UpgradeType({
    required this.baseCost,
    required this.incrementPerLevel,
    required this.maxLevel,
    required this.costs,
    required this.costScale,
  });

  final double baseCost;
  final double incrementPerLevel;
  final int maxLevel;
  final List<double> costs;
  final double costScale;

  /// Obtiene la lista de costes por nivel
  List<double> getCosts() => costs;
  
  /// Returns the maximum upgrade level allowed for a given player level
  /// This enforces progressive unlocking tied to player progression
  int getMaxAllowedLevel(int playerLevel) {
    // Tiered approach: every 3-5 levels unlocks more upgrade levels
    if (playerLevel <= 3) return 1;
    if (playerLevel <= 6) return 2;
    if (playerLevel <= 10) return 3;
    if (playerLevel <= 15) return 4;
    if (playerLevel <= 20) return 5;
    if (playerLevel <= 25) return 6;
    if (playerLevel <= 30) return 7;
    if (playerLevel <= 35) return 8;
    if (playerLevel <= 40) return 9;
    if (playerLevel <= 45) return 10;
    if (playerLevel <= 50) return 11;
    
    // Cap at the absolute max for this upgrade type
    return maxLevel < 12 ? maxLevel : 12;
  }
}
