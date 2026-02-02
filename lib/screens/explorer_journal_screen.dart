import 'package:flutter/material.dart';

/// Pantalla del Diario de explorador (colección de Stillwalks)
class ExplorerJournalScreen extends StatefulWidget {
  const ExplorerJournalScreen({super.key});

  @override
  State<ExplorerJournalScreen> createState() => _ExplorerJournalScreenState();
}

class _ExplorerJournalScreenState extends State<ExplorerJournalScreen> {
  // TODO: Conectar con CollectionService
  final List<Map<String, dynamic>> _species = [
    {
      'id': 'spiristone',
      'name': 'Spiristone',
      'dexNumber': 1,
      'discovered': true,
      'assetPath': 'assets/creatures/spiristone.png',
      'rarity': 'common',
    },
    {
      'id': 'radispirit',
      'name': 'Radispirit',
      'dexNumber': 2,
      'discovered': false,
      'assetPath': 'assets/creatures/radispirit.png',
      'rarity': 'uncommon',
    },
    {
      'id': 'slugrry',
      'name': 'Slugrry',
      'dexNumber': 3,
      'discovered': false,
      'assetPath': 'assets/creatures/slugrry.png',
      'rarity': 'rare',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final discoveredCount = _species.where((s) => s['discovered']).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Diario de Explorador'),
        backgroundColor: Colors.deepPurple.withOpacity(0.8),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.deepPurple.withOpacity(0.8),
              Colors.black,
            ],
          ),
        ),
        child: Column(
          children: [
            // Header con estadísticas
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.catching_pokemon, size: 32, color: Colors.amberAccent),
                  const SizedBox(width: 12),
                  Text(
                    '$discoveredCount / ${_species.length} Descubiertos',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            // Grid de criaturas
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.8,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: _species.length,
                itemBuilder: (context, index) {
                  final species = _species[index];
                  return _CreatureCard(
                    dexNumber: species['dexNumber'],
                    name: species['name'],
                    discovered: species['discovered'],
                    assetPath: species['assetPath'],
                    rarity: species['rarity'],
                    onTap: () {
                      if (species['discovered']) {
                        _showCreatureDetails(context, species);
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreatureDetails(BuildContext context, Map<String, dynamic> species) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(species['name']),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              species['assetPath'],
              width: 128,
              height: 128,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.image_not_supported,
                size: 128,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '#${species['dexNumber'].toString().padLeft(3, '0')}',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 8),
            _RarityBadge(rarity: species['rarity']),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}

class _CreatureCard extends StatelessWidget {
  final int dexNumber;
  final String name;
  final bool discovered;
  final String assetPath;
  final String rarity;
  final VoidCallback onTap;

  const _CreatureCard({
    required this.dexNumber,
    required this.name,
    required this.discovered,
    required this.assetPath,
    required this.rarity,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: discovered ? onTap : null,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(discovered ? 0.1 : 0.03),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: discovered ? Colors.white.withOpacity(0.2) : Colors.white.withOpacity(0.05),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Imagen o silueta
            if (discovered)
              Image.asset(
                assetPath,
                width: 100,
                height: 100,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.pets,
                  size: 100,
                  color: Colors.white54,
                ),
              )
            else
              const Icon(
                Icons.help_outline,
                size: 100,
                color: Colors.white24,
              ),

            const SizedBox(height: 12),

            // Número Dex
            Text(
              '#${dexNumber.toString().padLeft(3, '0')}',
              style: TextStyle(
                fontSize: 14,
                color: discovered ? Colors.white70 : Colors.white24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 4),

            // Nombre
            Text(
              discovered ? name : '???',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: discovered ? Colors.white : Colors.white24,
              ),
              textAlign: TextAlign.center,
            ),

            if (discovered) ...[
              const SizedBox(height: 8),
              _RarityBadge(rarity: rarity),
            ],
          ],
        ),
      ),
    );
  }
}

class _RarityBadge extends StatelessWidget {
  final String rarity;

  const _RarityBadge({required this.rarity});

  Color _getRarityColor() {
    switch (rarity) {
      case 'common':
        return Colors.grey;
      case 'uncommon':
        return Colors.green;
      case 'rare':
        return Colors.blue;
      case 'epic':
        return Colors.purple;
      case 'legendary':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _getRarityLabel() {
    switch (rarity) {
      case 'common':
        return 'Común';
      case 'uncommon':
        return 'Poco común';
      case 'rare':
        return 'Raro';
      case 'epic':
        return 'Épico';
      case 'legendary':
        return 'Legendario';
      default:
        return rarity;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: _getRarityColor().withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getRarityColor()),
      ),
      child: Text(
        _getRarityLabel(),
        style: TextStyle(
          fontSize: 12,
          color: _getRarityColor(),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
