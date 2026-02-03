import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stillwalks/services/orbe_service.dart';
import 'package:stillwalks/services/esencia_service.dart';
import 'package:stillwalks/screens/shop_screen.dart';
import 'package:stillwalks/models/orbe.dart';
import 'package:stillwalks/screens/channeling_screen.dart';

/// Pantalla del santuario donde se visualiza y gestiona el Orbe asignado
class SanctuaryScreen extends StatefulWidget {
  const SanctuaryScreen({super.key});

  @override
  State<SanctuaryScreen> createState() => _SanctuaryScreenState();
}

class _SanctuaryScreenState extends State<SanctuaryScreen> {
  @override
  Widget build(BuildContext context) {
    final orbeService = Provider.of<OrbeService>(context);
    final orbe = orbeService.orbes.isNotEmpty ? orbeService.orbes.first : null; // Asumiendo 1 orbe por ahora
    final hasOrbe = orbe != null;
    
    // Calcular progreso real
    double progress = 0.0;
    int currentSteps = 0;
    int requiredSteps = 1;
    bool isReadyToChannel = false;

    if (hasOrbe) {
      currentSteps = orbe.currentProgress; // Mostrar pasos siempre, aunque el tipo sea desconocido
      final type = orbeService.getOrbeType(orbe.orbeTypeId);
      if (type != null) {
        requiredSteps = type.requiredSteps;
        progress = (currentSteps / requiredSteps).clamp(0.0, 1.0);
        isReadyToChannel = orbe.isReadyToChannel(requiredSteps);
      } else {
        // Fallback para orbes legacy/corruptos
        requiredSteps = 2000;
        progress = (currentSteps / requiredSteps).clamp(0.0, 1.0);
        isReadyToChannel = currentSteps >= requiredSteps;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Santuario Primordial'),
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
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Visualización del Orbe
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: hasOrbe
                            ? [
                                Colors.purpleAccent.withOpacity(0.6),
                                Colors.deepPurple.withOpacity(0.3),
                              ]
                            : [
                                Colors.grey.withOpacity(0.3),
                                Colors.grey.withOpacity(0.1),
                              ],
                      ),
                      boxShadow: hasOrbe
                          ? [
                              BoxShadow(
                                color: Colors.purpleAccent.withOpacity(0.5),
                                blurRadius: 40,
                                spreadRadius: 10,
                              ),
                            ]
                          : [],
                    ),
                    child: Center(
                      child: Icon(
                        hasOrbe ? Icons.circle : Icons.add_circle_outline,
                        size: 100,
                        color: hasOrbe ? Colors.white : Colors.white30,
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Información del estado
                    if (hasOrbe) ...[
                    Text(
                      isReadyToChannel ? '¡Listo para Canalizar!' : 'Canalizando...',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isReadyToChannel ? Colors.greenAccent : Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Barra de progreso
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Progreso:', style: TextStyle(fontSize: 16)),
                              Text(
                                '$currentSteps / $requiredSteps pasos',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.cyanAccent,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 20,
                              backgroundColor: Colors.grey.withOpacity(0.3),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                isReadyToChannel ? Colors.greenAccent : Colors.cyanAccent,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Botón de acción
                    if (isReadyToChannel || (orbe != null && orbe.isChanneled))
                      ElevatedButton(
                        onPressed: () async {
                          if (orbe!.isChanneled) {
                            // Si ya está canalizado, recuperar la instancia y mostrar la animación de nuevo
                            final instance = await orbeService.getCreatureInstanceById(orbe.stillwalkId!);
                            
                            if (instance != null && context.mounted) {
                              final species = await orbeService.getSpeciesById(instance.speciesId);
                              const isNew = false; 

                              if (species != null && context.mounted) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ChannelingScreen(
                                      instance: instance,
                                      species: species,
                                      isNew: isNew,
                                    ),
                                  ),
                                ).then((_) {
                                  orbeService.deleteChanneledOrbe(orbe.id);
                                });
                              }
                            } else {
                              await orbeService.deleteChanneledOrbe(orbe.id);
                            }
                          } else {
                            // Canalizar orbe normal
                            final instance = await orbeService.channelOrbe(orbe.id);
                            
                            if (instance != null && context.mounted) {
                              final species = await orbeService.getSpeciesById(instance.speciesId);
                              final isNew = await orbeService.isNewDiscovery(instance.speciesId);

                              if (species != null && context.mounted) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ChannelingScreen(
                                      instance: instance,
                                      species: species,
                                      isNew: isNew,
                                    ),
                                  ),
                                ).then((_) {
                                  orbeService.deleteChanneledOrbe(orbe.id);
                                });
                              }
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Error al canalizar. Intenta de nuevo.')),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.greenAccent,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 48,
                            vertical: 16,
                          ),
                        ),
                        child: const Text(
                          'Canalizar Ahora',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                  ] else ...[
                    const Text(
                      'Santuario Vacío',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Compra un Orbe en la tienda y colócalo aquí para comenzar',
                      style: TextStyle(fontSize: 16, color: Colors.white54),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const ShopScreen()));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurpleAccent,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                      ),
                      child: const Text(
                        'Ir a la Tienda',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
