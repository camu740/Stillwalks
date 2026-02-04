import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stillwalks/services/orbe_service.dart';
import 'package:stillwalks/models/orbe.dart';
import 'package:stillwalks/models/inventory_item.dart';

class InventoryScreen extends StatelessWidget {
  final bool isSelectionMode;
  final String? sanctuaryId;
  final bool isSanctuarySelectionMode;

  const InventoryScreen({
    super.key, 
    this.isSelectionMode = false,
    this.sanctuaryId,
    this.isSanctuarySelectionMode = false,
  });

  @override
  Widget build(BuildContext context) {
    final orbeService = Provider.of<OrbeService>(context);
    final availableOrbes = orbeService.getAvailableOrbes();
    final inventoryItems = orbeService.inventory;

    // Determinar qué mostrar según el modo
    final showOrbes = !isSanctuarySelectionMode;
    final showItems = !isSelectionMode || isSanctuarySelectionMode;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isSanctuarySelectionMode 
              ? 'Seleccionar Santuario' 
              : (isSelectionMode ? 'Seleccionar Orbe' : 'Tu Bolsa')
        ),
        backgroundColor: Colors.deepPurple,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.deepPurple.withOpacity(0.8), Colors.black],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            // Sección de Orbes (solo si no estamos en modo selección de santuarios)
            if (showOrbes) ...[
              SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Orbes en Espera (${availableOrbes.length})',
                  style: const TextStyle(fontSize: 20, fontStyle: FontStyle.italic, color: Colors.purpleAccent),
                ),
              ),
            ),
            if (availableOrbes.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: isSelectionMode
                      ? Card(
                          color: Colors.white.withOpacity(0.05),
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              children: [
                                const Icon(
                                  Icons.shopping_bag_outlined,
                                  size: 64,
                                  color: Colors.white30,
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'No tienes orbes disponibles',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Visita la tienda para comprar orbes y comenzar a canalizar criaturas',
                                  style: TextStyle(color: Colors.white54),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 24),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    Navigator.pushNamed(context, '/shop');
                                  },
                                  icon: const Icon(Icons.shopping_bag),
                                  label: const Text('Ir a la Tienda'),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 32,
                                      vertical: 16,
                                    ),
                                    backgroundColor: Colors.deepPurple,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : const Center(
                          child: Text(
                            'No tienes orbes sin asignar',
                            style: TextStyle(color: Colors.white54),
                          ),
                        ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final orbe = availableOrbes[index];
                    final type = orbeService.getOrbeType(orbe.orbeTypeId);
                    return Card(
                      color: Colors.white.withOpacity(0.05),
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: const Icon(Icons.circle, color: Colors.purpleAccent, size: 40),
                        title: Text(type?.name ?? 'Orbe Desconocido', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('${type?.requiredSteps ?? 0} pasos requeridos'),
                        trailing: isSelectionMode 
                          ? ElevatedButton(
                              onPressed: () async {
                                if (sanctuaryId != null) {
                                  await orbeService.assignOrbeToSanctuary(orbe.id, sanctuaryId!);
                                  Navigator.pop(context);
                                }
                              },
                              child: const Text('Asignar'),
                            )
                          : null,
                      ),
                    );
                  },
                  childCount: availableOrbes.length,
                ),
              ),
            ],

            // Sección de Objetos (Temporales, etc.)
            if (showItems) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Objetos y Santuarios (${inventoryItems.fold<int>(0, (sum, item) => sum + item.quantity)})',
                    style: const TextStyle(fontSize: 20, fontStyle: FontStyle.italic, color: Colors.cyanAccent),
                  ),
                ),
              ),
              if (inventoryItems.isEmpty)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 32.0),
                    child: Center(child: Text('Bolsa de objetos vacía', style: TextStyle(color: Colors.white54))),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final item = inventoryItems[index];
                      final name = InventoryItemTypes.getName(item.typeId);
                      final desc = InventoryItemTypes.getDescription(item.typeId);
                      
                      return Card(
                        color: Colors.white.withOpacity(0.05),
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: ListTile(
                          leading: Icon(
                            InventoryItemTypes.getIcon(item.typeId),
                            color: Colors.cyanAccent,
                            size: 40,
                          ),
                          title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('$desc\nCantidad: ${item.quantity}'),
                          isThreeLine: true,
                          trailing: ElevatedButton(
                            onPressed: () async {
                              final success = await orbeService.activateTemporarySanctuary(item.typeId);
                              if (success && context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('$name Activado')),
                                );
                                
                                // Encontrar el santuario temporal recién creado
                                try {
                                  final tempSanctuary = orbeService.sanctuaries.firstWhere((s) => s.isTemporary);
                                  
                                  // Navegar directamente al selector (reemplazando esta pantalla)
                                  if (context.mounted) {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => InventoryScreen(
                                          isSelectionMode: true,
                                          sanctuaryId: tempSanctuary.id,
                                        )
                                      )
                                    );
                                  }
                                } catch (e) {
                                  // No se encontró santuario temporal, volver normalmente
                                  debugPrint('Error finding temporary sanctuary: $e');
                                  if (context.mounted) {
                                    Navigator.pop(context);
                                  }
                                }
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Ya tienes un santuario temporal activo')),
                                );
                              }
                            },
                            child: const Text('Usar'),
                          ),
                        ),
                      );
                    },
                    childCount: inventoryItems.length,
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
