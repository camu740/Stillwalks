import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stillwalks/services/orbe_service.dart';
import 'package:stillwalks/services/esencia_service.dart';
import 'package:stillwalks/screens/shop_screen.dart';
import 'package:stillwalks/models/orbe.dart';
import 'package:stillwalks/models/sanctuary.dart';
import 'package:stillwalks/screens/channeling_screen.dart';
import 'package:stillwalks/screens/inventory_screen.dart';

class SanctuaryScreen extends StatelessWidget {
  const SanctuaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orbeService = Provider.of<OrbeService>(context);
    final sanctuaries = orbeService.sanctuaries;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Santuarios Primordiales'),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: const Icon(Icons.inventory_2_outlined),
            onPressed: () {
              Navigator.push(
                context, 
                MaterialPageRoute(builder: (_) => const InventoryScreen())
              );
            },
            tooltip: 'Tu Bolsa',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.deepPurple.withOpacity(0.8), Colors.black],
          ),
        ),
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: sanctuaries.length,
          itemBuilder: (context, index) {
            return SanctuaryWidget(sanctuary: sanctuaries[index]);
          },
        ),
      ),
    );
  }
}

class SanctuaryWidget extends StatelessWidget {
  final Sanctuary sanctuary;

  const SanctuaryWidget({super.key, required this.sanctuary});

  @override
  Widget build(BuildContext context) {
    final orbeService = Provider.of<OrbeService>(context);
    final orbe = sanctuary.orbeId != null 
        ? orbeService.orbes.firstWhere((o) => o.id == sanctuary.orbeId) 
        : null;
    
    final hasOrbe = orbe != null;
    final type = hasOrbe ? orbeService.getOrbeType(orbe.orbeTypeId) : null;
    
    double progress = 0.0;
    int currentSteps = 0;
    int requiredSteps = 1;
    bool isReadyToChannel = false;

    if (hasOrbe && type != null) {
      currentSteps = orbe.currentProgress;
      // El santuario reduce el requisito visualmente
      final effectiveRequiredSteps = (type.requiredSteps / sanctuary.speedMultiplier).round();
      requiredSteps = effectiveRequiredSteps;
      progress = (currentSteps / requiredSteps).clamp(0.0, 1.0);
      isReadyToChannel = currentSteps >= requiredSteps;
    }

    return Card(
      color: Colors.white.withOpacity(0.05),
      margin: const EdgeInsets.only(bottom: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  sanctuary.isTemporary ? Icons.timer : Icons.fort_outlined,
                  color: sanctuary.isTemporary ? Colors.cyanAccent : Colors.purpleAccent,
                ),
                const SizedBox(width: 8),
                Text(
                  sanctuary.name,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                if (sanctuary.isTemporary)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.cyan.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${sanctuary.remainingUses} usos',
                      style: const TextStyle(fontSize: 12, color: Colors.cyanAccent),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            
            if (!hasOrbe)
              Column(
                children: [
                  const Icon(Icons.circle_outlined, size: 60, color: Colors.white10),
                  const SizedBox(height: 12),
                  const Text('Santuario Vacío', style: TextStyle(color: Colors.white30)),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.push(
                      context, 
                      MaterialPageRoute(
                        builder: (_) => InventoryScreen(
                          isSelectionMode: true, 
                          sanctuaryId: sanctuary.id
                        )
                      )
                    ),
                    icon: const Icon(Icons.add),
                    label: const Text('Colocar Orbe'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.purpleAccent.withOpacity(0.3)),
                  ),
                ],
              )
            else
              Column(
                children: [
                  // Icono y progreso
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 80,
                        height: 80,
                        child: CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 8,
                          backgroundColor: Colors.white10,
                          color: isReadyToChannel ? Colors.greenAccent : Colors.cyanAccent,
                        ),
                      ),
                      const Icon(Icons.circle, size: 40, color: Colors.white),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    type?.name ?? 'Orbe',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '$currentSteps / $requiredSteps pasos',
                    style: const TextStyle(color: Colors.white54),
                  ),
                  const SizedBox(height: 20),
                  
                  if (isReadyToChannel)
                    ElevatedButton(
                      onPressed: () async {
                        final instance = await orbeService.channelOrbe(orbe.id);
                        
                        // Verificar si hay recompensa de Simbiosis
                        final symbiosisReward = orbeService.lastSymbiosisReward;
                        if (symbiosisReward > 0 && context.mounted) {
                          final esenciaService = Provider.of<EsenciaService>(context, listen: false);
                          await esenciaService.addEsencia(symbiosisReward);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('¡Santuario de Simbiosis te otorgó ${symbiosisReward.toStringAsFixed(0)} de Esencia!'),
                              backgroundColor: Colors.cyanAccent.withOpacity(0.8),
                              duration: const Duration(seconds: 3),
                            ),
                          );
                          orbeService.clearSymbiosisReward();
                        }
                        
                        if (instance != null && context.mounted) {
                          final species = await orbeService.getSpeciesById(instance.speciesId);
                          if (species != null && context.mounted) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChannelingScreen(
                                  instance: instance,
                                  species: species,
                                  isNew: false, // O lógia isNewDiscovery
                                ),
                              ),
                            ).then((_) {
                              orbeService.deleteChanneledOrbe(orbe.id);
                            });
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.greenAccent,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                      ),
                      child: const Text('Canalizar Ahora', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
