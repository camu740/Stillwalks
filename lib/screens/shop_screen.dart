import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stillwalks/services/esencia_service.dart';
import 'package:stillwalks/services/orbe_service.dart';
import 'package:stillwalks/models/upgrade.dart';
import 'package:stillwalks/models/orbe.dart';
import 'package:stillwalks/models/sanctuary.dart';
import 'package:stillwalks/models/inventory_item.dart';
import 'package:stillwalks/l10n/app_localizations.dart';
import 'package:stillwalks/l10n/data_localizations.dart';

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
        title: Text(AppLocalizations.of(context)!.shop),
        backgroundColor: Colors.deepPurple.withOpacity(0.8),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(icon: const Icon(Icons.circle), text: AppLocalizations.of(context)!.orbs),
            Tab(icon: const Icon(Icons.auto_awesome), text: AppLocalizations.of(context)!.sanctuaries),
            Tab(icon: const Icon(Icons.trending_up), text: AppLocalizations.of(context)!.upgrades),
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
                      '${AppLocalizations.of(context)!.essence}: ${currentEsencia.toStringAsFixed(0)}',
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
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            AppLocalizations.of(context)!.orbsAvailableForPurchase,
            style: const TextStyle(
              color: Colors.purpleAccent,
              fontStyle: FontStyle.italic,
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(height: 8),
        _ShopItem(
          icon: Icons.circle_outlined,
          title: AppLocalizations.of(context)!.getOrbName('orbe_basic', 'Orbe Básico'),
          description: AppLocalizations.of(context)!.getOrbDescription('orbe_basic', 'Requiere 2000 pasos'),
          cost: 500.0,
          currentEsencia: currentEsencia,
          onPurchase: () async {
            final result = await orbeService.purchaseOrbe('orbe_basic', currentEsencia);
            if (result != null) {
              await esenciaService.spendEsencia(500.0);
              if (mounted) ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(AppLocalizations.of(context)!.orbPurchased))
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
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            AppLocalizations.of(context)!.temporarySanctuaries,
            style: const TextStyle(
              color: Colors.cyanAccent,
              fontStyle: FontStyle.italic,
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(height: 8),
        _ShopItem(
          icon: InventoryItemTypes.getIcon(InventoryItemTypes.tempSanctuaryFastFlow),
          title: AppLocalizations.of(context)!.getSanctuaryName('', InventoryItemTypes.tempSanctuaryFastFlow, 'Fast Flow'),
          description: AppLocalizations.of(context)!.getSanctuaryDescription('', InventoryItemTypes.tempSanctuaryFastFlow, ''),
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
                  SnackBar(content: Text(AppLocalizations.of(context)!.sanctuaryPurchased)),
                );
              }
            }
          },
        ),
        const SizedBox(height: 12),
        _ShopItem(
          icon: InventoryItemTypes.getIcon(InventoryItemTypes.tempSanctuarySymbiosis),
          title: AppLocalizations.of(context)!.getSanctuaryName('', InventoryItemTypes.tempSanctuarySymbiosis, 'Symbiosis'),
          description: AppLocalizations.of(context)!.getSanctuaryDescription('', InventoryItemTypes.tempSanctuarySymbiosis, ''),
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
                  SnackBar(content: Text(AppLocalizations.of(context)!.sanctuaryPurchased)),
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
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              const Icon(Icons.fort, color: Colors.purpleAccent, size: 20),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context)!.permanentSanctuaryUpgrades,
                style: const TextStyle(
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
              title: AppLocalizations.of(context)!.getSanctuaryName(sanctuary.id, sanctuary.typeId, sanctuary.name),
              description: AppLocalizations.of(context)!.getSanctuaryDescription(sanctuary.id, sanctuary.typeId, sanctuary.description),
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
                      SnackBar(content: Text(AppLocalizations.of(context)!.sanctuaryUpgraded(
                        AppLocalizations.of(context)!.getSanctuaryName(sanctuary.id, sanctuary.typeId, sanctuary.name),
                        currentLevel + 1
                      ))),
                    );
                  }
                } else {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(AppLocalizations.of(context)!.notEnoughEssence)),
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
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              const Icon(Icons.trending_up, color: Colors.greenAccent, size: 20),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context)!.globalUpgrades,
                style: const TextStyle(
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
          Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                AppLocalizations.of(context)!.loadingUpgrades,
                style: const TextStyle(color: Colors.white54),
              ),
            ),
          )
        else
          ...globalUpgrades.map((upgrade) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _UpgradeItem(
                icon: _getUpgradeIcon(upgrade.type),
                title: AppLocalizations.of(context)!.getUpgradeName(upgrade.type),
                description: AppLocalizations.of(context)!.getUpgradeDescription(upgrade.type),
                currentLevel: upgrade.currentLevel,
                maxLevel: upgrade.type.maxLevel,
                cost: upgrade.calculateNextLevelCost(),
                currentEsencia: currentEsencia,
                multiplier: AppLocalizations.of(context)!.getUpgradeBonusText(upgrade.type),
                bonusText: upgrade.type == UpgradeType.energyStorage
                    ? 'Capacidad: ${(upgrade.currentLevel * 300)}'
                    : 'Bono actual: +${(upgrade.currentLevel * 2)}%',
                onPurchase: () async {
                  final success = await esenciaService.purchaseUpgrade(upgrade.id);
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(AppLocalizations.of(context)!.upgradeCompleted(
                        AppLocalizations.of(context)!.getUpgradeName(upgrade.type)
                      ))),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(AppLocalizations.of(context)!.notEnoughEssence)),
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
            child: Text(AppLocalizations.of(context)!.buy),
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
                  child: Text(AppLocalizations.of(context)!.upgrade),
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
                  child: Text(AppLocalizations.of(context)!.upgrade),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
