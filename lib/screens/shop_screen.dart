import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stillwalks/services/esencia_service.dart';
import 'package:stillwalks/services/orbe_service.dart';
import 'package:stillwalks/models/upgrade.dart';
import 'package:stillwalks/models/orbe.dart';
import 'package:stillwalks/models/sanctuary.dart';
import 'package:stillwalks/models/inventory_item.dart';

/// Pantalla de la tienda para comprar Orbes y mejoras
class ShopScreen extends StatefulWidget {
  final int initialTab;
  
  const ShopScreen({super.key, this.initialTab = 0});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: widget.initialTab);
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
            Tab(icon: Icon(Icons.auto_awesome), text: 'Santuarios'),
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
                  _buildSanctuariesTab(),
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
    final orbeService = Provider.of<OrbeService>(context);
    final esenciaService = Provider.of<EsenciaService>(context);
    final currentEsencia = esenciaService.playerState.totalEsencia;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            'Orbes disponibles para comprar',
            style: TextStyle(
              color: Colors.purpleAccent,
              fontStyle: FontStyle.italic,
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(height: 8),
        _ShopItem(
          icon: Icons.circle_outlined,
          title: 'Orbe Básico',
          description: 'Requiere 2.000 pasos para canalizar',
          cost: 500.0,
          currentEsencia: currentEsencia,
          onPurchase: () async {
            final result = await orbeService.purchaseOrbe('orbe_basic', currentEsencia);
            if (result != null) {
              await esenciaService.spendEsencia(500.0);
              if (mounted) ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('¡Orbe comprado! Revisa tu Bolsa.'))
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildSanctuariesTab() {
    final orbeService = Provider.of<OrbeService>(context);
    final esenciaService = Provider.of<EsenciaService>(context);
    final currentEsencia = esenciaService.playerState.totalEsencia;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            'Santuarios Temporales',
            style: TextStyle(
              color: Colors.cyanAccent,
              fontStyle: FontStyle.italic,
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(height: 8),
        _ShopItem(
          icon: Icons.flash_on,
          title: 'Santuario de Flujo Rápido',
          description: 'Reduce requisito de pasos en 50% (1 uso)',
          cost: 1200.0,
          currentEsencia: currentEsencia,
          onPurchase: () async {
            final success = await orbeService.purchaseInventoryItem(
              InventoryItemTypes.tempSanctuaryFastFlow,
              1200.0,
              currentEsencia,
            );
            if (success) {
              await esenciaService.spendEsencia(1200.0);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('¡Santuario comprado! Revisa tu Bolsa.')),
                );
              }
            }
          },
        ),
        const SizedBox(height: 12),
        _ShopItem(
          icon: Icons.all_inclusive,
          title: 'Santuario de Simbiosis',
          description: 'Otorga esencia al canalizar: 1 esencia / 10 pasos (2 usos)',
          cost: 2000.0,
          currentEsencia: currentEsencia,
          onPurchase: () async {
            final success = await orbeService.purchaseInventoryItem(
              InventoryItemTypes.tempSanctuarySymbiosis,
              2000.0,
              currentEsencia,
            );
            if (success) {
              await esenciaService.spendEsencia(2000.0);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('¡Santuario comprado! Revisa tu Bolsa.')),
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
    final orbeService = Provider.of<OrbeService>(context);
    final currentEsencia = esenciaService.playerState.totalEsencia;
    
    // Obtener mejoras globales
    final globalUpgrades = esenciaService.upgrades;
    
    // Obtener santuarios permanentes
    final permanentSanctuaries = orbeService.sanctuaries.where((s) => !s.isTemporary).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Sección: Mejoras de Santuarios
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              Icon(Icons.fort, color: Colors.purpleAccent, size: 20),
              SizedBox(width: 8),
              Text(
                'Mejoras de Santuarios Permanentes',
                style: TextStyle(
                  color: Colors.purpleAccent,
                  fontStyle: FontStyle.italic,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        
        // Mostrar una tarjeta por cada santuario permanente
        ...permanentSanctuaries.map((sanctuary) {
          final canUpgrade = sanctuary.canUpgrade();
          final cost = Sanctuary.getUpgradeCost(sanctuary.speedUpgradeLevel);
          final currentLevel = sanctuary.speedUpgradeLevel;
          final reductionPercent = (currentLevel * 2);
          
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _SanctuaryUpgradeItem(
              title: sanctuary.name,
              description: sanctuary.description,
              currentLevel: currentLevel,
              maxLevel: 15,
              cost: cost,
              currentEsencia: currentEsencia,
              reductionPercent: reductionPercent,
              onPurchase: () async {
                final success = await orbeService.upgradeSanctuarySpeed(sanctuary.id, currentEsencia);
                if (success) {
                  await esenciaService.spendEsencia(cost);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('¡Mejora de "${sanctuary.name}" a Nivel ${currentLevel + 1}!')),
                    );
                  }
                } else {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('No tienes suficiente Esencia')),
                    );
                  }
                }
              },
            ),
          );
        }).toList(),
        
        const SizedBox(height: 24),
        const Divider(color: Colors.white24),
        const SizedBox(height: 16),
        
        // Sección: Mejoras Globales
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              Icon(Icons.trending_up, color: Colors.greenAccent, size: 20),
              SizedBox(width: 8),
              Text(
                'Mejoras Globales',
                style: TextStyle(
                  color: Colors.greenAccent,
                  fontStyle: FontStyle.italic,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        
        // Mostrar mejoras globales
        if (globalUpgrades.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                "Cargando mejoras...",
                style: TextStyle(color: Colors.white54),
              ),
            ),
          )
        else
          ...globalUpgrades.map((upgrade) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _UpgradeItem(
                icon: _getUpgradeIcon(upgrade.type),
                title: upgrade.name,
                description: upgrade.description,
                currentLevel: upgrade.currentLevel,
                maxLevel: upgrade.type.maxLevel,
                cost: upgrade.calculateNextLevelCost(),
                currentEsencia: currentEsencia,
                multiplier: _getUpgradeMultiplierText(upgrade.type),
                bonusText: upgrade.type == UpgradeType.energyStorage
                    ? 'Capacidad: ${(upgrade.currentLevel * 300)}'
                    : 'Bono actual: +${(upgrade.currentLevel * 2)}%',
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
              ),
            );
          }).toList(),
      ],
    );
  }

  IconData _getUpgradeIcon(UpgradeType type) {
    if (type == UpgradeType.idleMultiplier) return Icons.schedule;
    if (type == UpgradeType.energyStorage) return Icons.battery_charging_full;
    return Icons.star;
  }

  String _getUpgradeMultiplierText(UpgradeType type) {
    if (type == UpgradeType.idleMultiplier) return '+2% bono / nivel';
    if (type == UpgradeType.energyStorage) return '+300 capacidad / nivel';
    return '';
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
  final int maxLevel;
  final double cost;
  final double currentEsencia;
  final String multiplier;
  final String bonusText;
  final VoidCallback onPurchase;

  const _UpgradeItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.currentLevel,
    required this.maxLevel,
    required this.cost,
    required this.currentEsencia,
    required this.multiplier,
    required this.bonusText,
    required this.onPurchase,
  });

  @override
  Widget build(BuildContext context) {
    final isMaxLevel = currentLevel >= maxLevel;
    final canAfford = currentEsencia >= cost && !isMaxLevel;

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
                            color: isMaxLevel ? Colors.amber.withOpacity(0.2) : Colors.blueAccent.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            isMaxLevel ? 'MAX' : 'Nv. $currentLevel',
                            style: TextStyle(
                              fontSize: 12, 
                              color: isMaxLevel ? Colors.amber : Colors.blueAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(fontSize: 14, color: Colors.white70),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      bonusText,
                      style: const TextStyle(fontSize: 13, color: Colors.greenAccent, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      multiplier,
                      style: const TextStyle(fontSize: 11, color: Colors.white54),
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
              if (!isMaxLevel)
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
                )
              else
                const Text(
                  'Nivel máximo alcanzado',
                  style: TextStyle(color: Colors.amber, fontSize: 13, fontWeight: FontWeight.bold),
                ),
              if (!isMaxLevel)
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

class _SanctuaryUpgradeItem extends StatelessWidget {
  final String title;
  final String description;
  final int currentLevel;
  final int maxLevel;
  final double cost;
  final double currentEsencia;
  final int reductionPercent;
  final VoidCallback onPurchase;

  const _SanctuaryUpgradeItem({
    required this.title,
    required this.description,
    required this.currentLevel,
    required this.maxLevel,
    required this.cost,
    required this.currentEsencia,
    required this.reductionPercent,
    required this.onPurchase,
  });

  @override
  Widget build(BuildContext context) {
    final isMaxLevel = currentLevel >= maxLevel;
    final canAfford = currentEsencia >= cost && !isMaxLevel;

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
              const Icon(Icons.fort, size: 40, color: Colors.purpleAccent),
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
                            color: isMaxLevel 
                                ? Colors.amber.withOpacity(0.2)
                                : Colors.purpleAccent.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            isMaxLevel ? 'MAX' : 'Nv. $currentLevel',
                            style: TextStyle(
                              fontSize: 12,
                              color: isMaxLevel ? Colors.amber : Colors.purpleAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(fontSize: 14, color: Colors.white70),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Bono actual: -$reductionPercent%',
                      style: const TextStyle(fontSize: 13, color: Colors.purpleAccent, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      '-2% pasos a realizar / nivel',
                      style: TextStyle(fontSize: 11, color: Colors.white54),
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
              if (!isMaxLevel)
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
                )
              else
                const Text(
                  'Nivel máximo alcanzado',
                  style: TextStyle(color: Colors.amber, fontSize: 13, fontWeight: FontWeight.bold),
                ),
              if (!isMaxLevel)
                ElevatedButton(
                  onPressed: canAfford ? onPurchase : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purpleAccent.withOpacity(0.8),
                    foregroundColor: Colors.white,
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
