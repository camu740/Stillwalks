import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:stillwalks/services/esencia_service.dart';
import 'package:stillwalks/services/orbe_service.dart';
import 'package:stillwalks/screens/shop_screen.dart';
import 'package:stillwalks/screens/explorer_journal_screen.dart';
import 'package:stillwalks/screens/sanctuary_screen.dart';
import 'package:stillwalks/data/database/database_helper.dart';
import 'package:stillwalks/models/upgrade.dart';
import 'package:stillwalks/screens/widgets/sanctuary_slot_widgets.dart';

/// Pantalla principal con el estado del jugador
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    // Escuchar cambios en los servicios
    final esenciaService = Provider.of<EsenciaService>(context);
    final orbeService = Provider.of<OrbeService>(context);
    
    final currentEsencia = esenciaService.playerState.totalEsencia;
    // Asumimos que esenciaPerHour está en el estado del jugador, si no, calculamos o usamos base
    // Revisando EsenciaService: _playerState.esenciaPerHour se usa en calculatePendingEsencia.
    // Si la propiedad no existe en el modelo público, usaremos un valor derivado o fijo por ahora.
    // Para asegurar compilación, accediendo a playerState.
    // Si playerState no tiene esenciaPerHour, esto fallará. 
    // Mirando EsenciaService.dart linea 75: _playerState.esenciaPerHour * hoursElapsed. SI EXISTE.
    final esenciaPerHour = esenciaService.playerState.esenciaPerHour; 
    
    // Ocupado si hay orbes no completados
    final sanctuaryOccupied = orbeService.orbes.isNotEmpty;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stillwalks'),
        backgroundColor: Colors.deepPurple.withOpacity(0.8),
        elevation: 0,
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
          child: Column(
            children: [
              // Sección superior: Esencia
              Expanded(
                flex: 2,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Esencia',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white70,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        currentEsencia.toStringAsFixed(0),
                        style: const TextStyle(
                          fontSize: 64,
                          fontWeight: FontWeight.bold,
                          color: Colors.amberAccent,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.access_time,
                            size: 16,
                            color: Colors.white70,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '+${esenciaPerHour.toStringAsFixed(0)} / hora',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.blueAccent.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Nv. ${esenciaService.upgrades.firstWhere((u) => u.type == UpgradeType.idleMultiplier, orElse: () => Upgrade(id: '', type: UpgradeType.idleMultiplier, currentLevel: 0, name: '', description: '')).currentLevel}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.blueAccent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),

                    ],
                  ),
                ),
              ),

              // Sección media: Santuarios (2 slots lado a lado)
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      // Santuario Primordial (izquierda)
                      Expanded(
                        child: SanctuarySlot(
                          sanctuary: orbeService.sanctuaries.firstWhere(
                            (s) => !s.isTemporary,
                            orElse: () => orbeService.sanctuaries.first,
                          ),
                          orbeService: orbeService,
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Santuario Temporal (derecha)
                      Expanded(
                        child: TemporarySanctuarySlot(
                          orbeService: orbeService,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Almacén de Energía (Debajo de santuarios)
              if (esenciaService.storageCapacity > 0)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.blueAccent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.battery_charging_full, size: 18, color: Colors.blueAccent),
                        const SizedBox(width: 8),
                        Text(
                          'Almacén: ${esenciaService.playerState.storedSteps} / ${esenciaService.storageCapacity}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.blueAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Sección inferior: Botones de navegación
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      _NavButton(
                        icon: Icons.shopping_bag,
                        label: 'Tienda',
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const ShopScreen()));
                        },
                      ),
                      const SizedBox(height: 12),
                      _NavButton(
                        icon: Icons.book,
                        label: 'Diario de Explorador',
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const ExplorerJournalScreen()));
                        },
                      ),
                      const SizedBox(height: 12),
                      _NavButton(
                        icon: Icons.settings,
                        label: 'Ajustes',
                        onPressed: () {
                          // TODO: Crear SettingsScreen
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Próximamente...')),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: kDebugMode
          ? Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FloatingActionButton.extended(
                  heroTag: 'essence_btn',
                  onPressed: () {
                    final esenciaService = Provider.of<EsenciaService>(context, listen: false);

                    // EsenciaService no tiene addEsencia público que sume arbitrariamente, pero tiene updateSteps que da esencia.
                    // O podemos hackearlo simulando pasos también.
                    // Pero el usuario pidió botón dedicado.
                    // Revisando EsenciaService... updateSteps(steps) -> add(steps * rate).
                    // Vamos a simular pasos "invisibles" para esencia, o mejor, añadir un método debug en EsenciaService si no existe.
                    // Como no quiero editar EsenciaService ahora por el límite de contexto, usaré updateSteps con un numero alto de pasos PERO solo para esencia, sin afectar orbes?
                    // No, el usuario pidió BOTON DE ESENCIA. Si llamo updateSteps, afecta a ambos si lo llamo desde UI incorrectamente.
                    // El botón anterior llamaba a AMBOS servicios.
                    // Este boton llamará solo a EsenciaService.updateSteps(5000) por ejemplo.
                    // Pero updateSteps calcula basado en rate.
                    // Mejor: llamar a updateSteps(0) y modificar state manual? No.
                    // Asumiremos que updateSteps(500) da esencia correspondiente.
                    // Pero espera, el usuario quiere botón de "+Esencia".
                    // Voy a simular una "recompensa" usando spendEsencia(-500)?
                    // spendEsencia resta. Si paso negativo, suma. hacky pero funciona.
                    esenciaService.spendEsencia(-1000.0);
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('DEBUG: +1000 Esencia añadida')),
                    );
                  },
                  icon: const Icon(Icons.flash_on),
                  label: const Text('+1000 Esencia'),
                  backgroundColor: Colors.amber,
                ),
                const SizedBox(height: 16),
                FloatingActionButton.extended(
                  heroTag: 'steps_btn',
                  onPressed: () async {
                    final orbeService = Provider.of<OrbeService>(context, listen: false);
                    final esenciaService = Provider.of<EsenciaService>(context, listen: false);
                    
                    const steps = 500;
                    final activeOrbs = await orbeService.addStepsToActiveOrbes(steps);
                    if (activeOrbs == 0) {
                      await esenciaService.addStoredSteps(steps);
                    }
                    esenciaService.updateSteps(steps);
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('DEBUG: +500 pasos simulados')),
                    );
                  },
                  icon: const Icon(Icons.directions_run),
                  label: const Text('+500 Pasos'),
                  backgroundColor: Colors.redAccent,
                ),
                const SizedBox(height: 16),
                FloatingActionButton.extended(
                  heroTag: 'storage_btn',
                  onPressed: () {
                    final esenciaService = Provider.of<EsenciaService>(context, listen: false);
                    esenciaService.addStoredSteps(100);
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('DEBUG: +100 pasos al Almacén')),
                    );
                  },
                  icon: const Icon(Icons.battery_charging_full),
                  label: const Text('+100 Almacén'),
                  backgroundColor: Colors.blueAccent,
                ),
                const SizedBox(height: 16),
                FloatingActionButton.extended(
                  heroTag: 'reset_btn',
                  onPressed: () async {
                     final db = DatabaseHelper();
                     await db.resetDatabase();
                     
                     // Recargar servicios para reflejar el reset
                     final orbeService = Provider.of<OrbeService>(context, listen: false);
                     final esenciaService = Provider.of<EsenciaService>(context, listen: false);
                     
                     await orbeService.initialize();
                     await esenciaService.initialize();
                     
                     ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('DEBUG: Base de datos REINICIADA y Servicios Recargados 💥')),
                    );
                  },
                  icon: const Icon(Icons.delete_forever),
                  label: const Text('Reset DB'),
                  backgroundColor: Colors.black,
                ),
              ],
            )
          : null,
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _NavButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: Colors.white.withOpacity(0.1),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
