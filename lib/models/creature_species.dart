/// Define una especie de Stillwalk (datos estáticos)
/// Esto es lo que aparece en el "Diario de explorador"
class CreatureSpecies {
  final String id;
  final String name;
  final String description;
  final String rarity; // 'common', 'uncommon', 'rare', 'epic', 'legendary'
  final String assetPath; // Ruta al sprite
  final int dexNumber; // Número en el Diario de explorador

  CreatureSpecies({
    required this.id,
    required this.name,
    required this.description,
    required this.rarity,
    required this.assetPath,
    required this.dexNumber,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'rarity': rarity,
      'assetPath': assetPath,
      'dexNumber': dexNumber,
    };
  }

  factory CreatureSpecies.fromJson(Map<String, dynamic> json) {
    return CreatureSpecies(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      rarity: json['rarity'] as String,
      assetPath: json['assetPath'] as String,
      dexNumber: json['dexNumber'] as int,
    );
  }
}
