import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stillwalks/services/esencia_service.dart';
import 'package:stillwalks/services/orbe_service.dart';
import 'package:stillwalks/models/upgrade.dart';
import 'package:stillwalks/models/orbe.dart';
import 'package:provider/provider.dart';
import 'package:stillwalks/services/esencia_service.dart';
import 'package:stillwalks/services/orbe_service.dart';
import 'package:stillwalks/models/upgrade.dart';
import 'package:stillwalks/models/orbe.dart';

/// Pantalla de la tienda para comprar Orbes y mejoras
class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

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
    // Escuchar servicios
    final esenciaService = Provider.of<EsenciaService>(context);
    final orbeService = Provider.of<OrbeService>(context);
    
    final currentEsencia = esenciaService.playerState.totalEsencia;
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
                      'Esencia: ${currentEsencia.toStringAsFixed(0)}',
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
    final orbeService = Provider.of<OrbeService>(context, listen: false);
    final esenciaService = Provider.of<EsenciaService>(context);
    final currentEsencia = esenciaService.playerState.totalEsencia;
    
    // Obtener tipos de orbes disponibles (en el futuro vendran de BD)
    // Por ahora usamos datos mockeados o checkeamos orbeService.orbeTypes si está cargado
    // Como fallback, hardcodeamos visualmente pero lógica real
    
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _ShopItem(
          icon: Icons.circle_outlined,
          title: 'Orbe Básico',
          description: 'Requiere 2,000 pasos para canalizar',
          cost: 500.0, // Base cost
          currentEsencia: currentEsencia,
          onPurchase: () async {
            // Verificar si ya tiene un orbe activo (simplificación MVP)
            if (orbeService.orbes.isNotEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Ya tienes un Orbe activo. Termínalo primero.')),
              );
              return;
            }

            final reduction = esenciaService.getOrbeCostReduction();
            // ID debe coincidir con InitialData
            final result = await orbeService.purchaseOrbe('orbe_basic', currentEsencia, reduction);
            
            if (result != null) {
              // Descontar esencia
              // 1. Calcular coste real
              // 2. Gastar en EsenciaService
              // 3. Añadir orbe en OrbeService (necesitamos metodo 'addOrbe' o similar que no valide dinero si ya pagamos)
              // O mejor: purchaseOrbe en OrbeService debería recibir el callback de pago?
              // SIMPLIFICACION: purchaseOrbe en OrbeService solo crea el orbe en BD. El gasto lo hace EsenciaService.
              
              // RE-READING OrbeService code from previous artifacts...
              // purchaseOrbe(typeId, esenciaAvailable, reduction) -> Returns Orbe?
              // Code:
              // final cost = baseCost * (1.0 - reduction);
              // if (esenciaAvailable < cost) return null;
              // ... insert into DB ...
              
              // It creates the orb but DOES NOT deduct essence from PlayerState because it doesn't have access to it.
              // So we must manually deduct essence here.
              // We need to know the cost calculated. 
              final realCost = 500.0 * (1.0 - reduction);
              await esenciaService.spendEsencia(realCost);
              
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('¡Orbe adquirido!')),
                );
                Navigator.pop(context); // Volver al santuario
              }
            } else {
               if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('No tienes suficiente Esencia')),
                );
              }
            }
          },
        ),
      ],
    );
  }

  Widget _buildUpgradesTab() {
     final esenciaService = Provider.of<EsenciaService>(context);
     final upgrades = esenciaService.upgrades;
     final currentEsencia = esenciaService.playerState.totalEsencia;

    if (upgrades.isEmpty) {
      return const Center(child: Text("Cargando mejoras...", style: TextStyle(color: Colors.white)));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: upgrades.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final upgrade = upgrades[index];
        return _UpgradeItem(
          icon: _getUpgradeIcon(upgrade.type),
          title: upgrade.name,
          description: upgrade.description,
          currentLevel: upgrade.currentLevel,
          cost: upgrade.calculateNextLevelCost(),
          currentEsencia: currentEsencia,
          multiplier: _getUpgradeMultiplierText(upgrade.type),
          onPurchase: () async {
            final success = await esenciaService.purchaseUpgrade(upgrade.id);
            if (success) {
               ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('¡Mejora "${upgrade.name}" realizada!')),
              );
            } else {
               ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No tienes suficiente Esencia')),
              );
            }
          },
        );
      },
    );
  }

  IconData _getUpgradeIcon(UpgradeType type) {
    switch (type) {
      case UpgradeType.idleMultiplier: return Icons.schedule;
      case UpgradeType.sanctuarySpeed: return Icons.speed;
      case UpgradeType.orbeCostReduction: return Icons.discount;
      default: return Icons.star;
    }
  }

  String _getUpgradeMultiplierText(UpgradeType type) {
    switch (type) {
      case UpgradeType.idleMultiplier: return '+10% Gen/Hora'; // Hardcoded for display, match model logic
      case UpgradeType.sanctuarySpeed: return '+5% Velocidad';
      case UpgradeType.orbeCostReduction: return '-5% Coste'; // Assuming logic in model
      default: return '';
    }
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
