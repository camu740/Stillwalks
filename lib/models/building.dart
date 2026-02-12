enum BuildingType {
  recolector(
    id: 'building_recolector',
    name: 'Recolector',
    baseProduction: 1.0, 
    baseCost: 100.0,
    costScale: 1.7,
    description: 'Genera esencia básica automáticamente.',
  ),
  mina(
    id: 'building_mina',
    name: 'Mina',
    baseProduction: 5.0,
    baseCost: 750.0,
    costScale: 1.8,
    description: 'Extrae esencia de la tierra.',
  ),
  cantera(
    id: 'building_cantera',
    name: 'Cantera',
    baseProduction: 20.0,
    baseCost: 4000.0,
    costScale: 1.9,
    description: 'Producción industrial de esencia.',
  ),
  yacimiento(
    id: 'building_yacimiento',
    name: 'Yacimiento',
    baseProduction: 75.0,
    baseCost: 15000.0,
    costScale: 2.0,
    description: 'Fuente masiva de esencia pura.',
  ),
  fabrica(
    id: 'building_fabrica',
    name: 'Fábrica',
    baseProduction: 250.0,
    baseCost: 75000.0,
    costScale: 2.1,
    description: 'La cúspide de la tecnología de esencia.',
  );

  final String id;
  final String name;
  final double baseProduction; // Per second
  final double baseCost;
  final double costScale;
  final String description;

  const BuildingType({
    required this.id,
    required this.name,
    required this.baseProduction,
    required this.baseCost,
    required this.costScale,
    required this.description,
  });
  
  /// Returns the maximum count of this building type allowed for a given player level
  /// Formula: Every 2 player levels unlocks 1 more building
  /// L1-2: 1, L3-4: 2, L5-6: 3, etc.
  int getMaxAllowedCount(int playerLevel) {
    return (playerLevel ~/ 2) + 1; // Integer division
  }
}

class Building {
  final BuildingType type;
  final int count;
  final int level; // For now, maybe just count is enough? Design says "Mejora de edificios" exists too.

  // Design says: 
  // "Cada edificio tiene su propio nivel" AND "Se puede comprar varias veces" implies distinct instances?
  // Usually in clickers you buy "count" of buildings (10 Farms).
  // AND you can upgrade the "type" (Farms produce x2).
  // Section 8.5 says: "Cada edificio tiene niveles que aumentan su producción base".
  // It also says "Número máximo de cada tipo limitado por nivel de explorador".
  // This implies we have a Count (amount of buildings) and potentially a meta-Level for the building type.
  // "Mejora de edificios: Nivel 1 (base), Nivel 5 (+50%), Nivel 10 (x2)".
  // This sounds like "Milestone upgrades" based on count, OR a separate upgrade.
  // "Cada edificio tiene niveles que aumentan su producción base" -> This creates a complexity.
  // Usually:
  // - You buy 10 Recolectores. 
  // - You verify "Upgrade Recolector Efficiency" in a separate upgrades tab.
  // OR
  // - You upgrade the Recolector itself?
  // "Nivel 1: producción base. Nivel 5: +50%."
  // Let's assume for now we track `count`. 
  // And `level` could be a multiplier applied to all buildings of this type.
  
  Building({
    required this.type,
    this.count = 0,
    this.level = 1, // Multiplier level
  });

  // Logic moved to EsenciaService
  
  Map<String, dynamic> toJson() {
    return {
      'id': type.id,
      'count': count,
      'level': level,
    };
  }

  factory Building.fromJson(Map<String, dynamic> json) {
    // Handle legacy or flexibility
    final typeId = json['id'] as String;
    final type = BuildingType.values.firstWhere(
      (e) => e.id == typeId,
      orElse: () => BuildingType.recolector, // Fallback
    );
    
    return Building(
      type: type,
      count: (json['count'] as int?) ?? 0,
      level: (json['level'] as int?) ?? 1,
    );
  }
  
  Building copyWith({
    int? count,
    int? level,
  }) {
    return Building(
      type: type,
      count: count ?? this.count,
      level: level ?? this.level,
    );
  }
}
