import 'package:flutter/material.dart';

/// Pantalla de la tienda para comprar Orbes y mejoras
class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // TODO: Conectar con EsenciaService y OrbeService
  final double _currentEsencia = 1500.0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tienda'),
        backgroundColor: Colors.deepPurple.withOpacity(0.8),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.circle), text: 'Orbes'),
            Tab(icon: Icon(Icons.trending_up), text: 'Mejoras'),
          ],
        ),
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
            // Balance de Esencia
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amberAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amberAccent.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.auto_awesome, color: Colors.amberAccent),
                    const SizedBox(width: 8),
                    Text(
                      'Esencia: ${_currentEsencia.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.amberAccent,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Contenido con tabs
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildOrbesTab(),
                  _buildUpgradesTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrbesTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _ShopItem(
          icon: Icons.circle_outlined,
          title: 'Orbe Básico',
          description: 'Requiere 2,000 pasos para canalizar',
          cost: 500,
          currentEsencia: _currentEsencia,
          onPurchase: () {
            // TODO: Implementar compra de Orbe
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Orbe comprado!')),
            );
          },
        ),
      ],
    );
  }

  Widget _buildUpgradesTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _UpgradeItem(
          icon: Icons.schedule,
          title: 'Generación Pasiva',
          description: 'Aumenta la Esencia generada por hora',
          currentLevel: 0,
          cost: 100,
          currentEsencia: _currentEsencia,
          multiplier: '+10% por nivel',
          onPurchase: () {
            // TODO: Implementar compra de mejora
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Mejora comprada!')),
            );
          },
        ),
        const SizedBox(height: 12),
        _UpgradeItem(
          icon: Icons.speed,
          title: 'Velocidad de Santuario',
          description: 'Los Orbes requieren menos pasos',
          currentLevel: 0,
          cost: 200,
          currentEsencia: _currentEsencia,
          multiplier: '+5% por nivel',
          onPurchase: () {
            // TODO: Implementar compra de mejora
          },
        ),
        const SizedBox(height: 12),
        _UpgradeItem(
          icon: Icons.discount,
          title: 'Maestría en Orbes',
          description: 'Reduce el costo de compra de Orbes',
          currentLevel: 0,
          cost: 150,
          currentEsencia: _currentEsencia,
          multiplier: '+2% por nivel',
          onPurchase: () {
            // TODO: Implementar compra de mejora
          },
        ),
      ],
    );
  }
}

class _ShopItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final double cost;
  final double currentEsencia;
  final VoidCallback onPurchase;

  const _ShopItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.cost,
    required this.currentEsencia,
    required this.onPurchase,
  });

  @override
  Widget build(BuildContext context) {
    final canAfford = currentEsencia >= cost;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 48, color: Colors.deepPurpleAccent),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.auto_awesome, size: 16, color: Colors.amberAccent),
                    const SizedBox(width: 4),
                    Text(
                      cost.toStringAsFixed(0),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.amberAccent,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: canAfford ? onPurchase : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurpleAccent,
              disabledBackgroundColor: Colors.grey.withOpacity(0.3),
            ),
            child: const Text('Comprar'),
          ),
        ],
      ),
    );
  }
}

class _UpgradeItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final int currentLevel;
  final double cost;
  final double currentEsencia;
  final String multiplier;
  final VoidCallback onPurchase;

  const _UpgradeItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.currentLevel,
    required this.cost,
    required this.currentEsencia,
    required this.multiplier,
    required this.onPurchase,
  });

  @override
  Widget build(BuildContext context) {
    final canAfford = currentEsencia >= cost;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, size: 40, color: Colors.greenAccent),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.blueAccent.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Nv. $currentLevel',
                            style: const TextStyle(fontSize: 12, color: Colors.blueAccent),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(fontSize: 14, color: Colors.white70),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      multiplier,
                      style: const TextStyle(fontSize: 12, color: Colors.greenAccent),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.auto_awesome, size: 20, color: Colors.amberAccent),
                  const SizedBox(width: 4),
                  Text(
                    cost.toStringAsFixed(0),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.amberAccent,
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: canAfford ? onPurchase : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.greenAccent.withOpacity(0.8),
                  foregroundColor: Colors.black,
                  disabledBackgroundColor: Colors.grey.withOpacity(0.3),
                ),
                child: const Text('Mejorar'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
