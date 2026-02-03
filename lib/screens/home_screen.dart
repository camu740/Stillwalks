import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stillwalks/services/esencia_service.dart';
import 'package:stillwalks/services/orbe_service.dart';
import 'package:stillwalks/screens/shop_screen.dart';
import 'package:stillwalks/screens/explorer_journal_screen.dart';
import 'package:stillwalks/screens/sanctuary_screen.dart';

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
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Sección media: Estado del santuario
              Expanded(
                flex: 1,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                  child: InkWell(
                    onTap: () {
                       Navigator.push(
                        context, 
                        MaterialPageRoute(builder: (_) => const SanctuaryScreen())
                      );
                    },
                    child: Row(
                      children: [
                        Icon(
                          sanctuaryOccupied ? Icons.hourglass_bottom : Icons.add_circle_outline,
                          size: 40,
                          color: sanctuaryOccupied ? Colors.greenAccent : Colors.white54,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Santuario Primordial',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                sanctuaryOccupied
                                    ? 'Canalizando Orbe...'
                                    : 'Vacío - Toca para asignar',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: sanctuaryOccupied
                                      ? Colors.greenAccent
                                      : Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right,
                          color: Colors.white54,
                        ),
                      ],
                    ),
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
