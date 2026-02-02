import 'package:flutter/material.dart';

/// Pantalla del santuario donde se visualiza y gestiona el Orbe asignado
class SanctuaryScreen extends StatefulWidget {
  const SanctuaryScreen({super.key});

  @override
  State<SanctuaryScreen> createState() => _SanctuaryScreenState();
}

class _SanctuaryScreenState extends State<SanctuaryScreen> {
  // TODO: Conectar con services
  bool _hasOrbe = false;
  int _currentSteps = 500;
  int _requiredSteps = 2000;
  bool _isReadyToChannel = false;

  @override
  Widget build(BuildContext context) {
    final progress = _hasOrbe ? (_currentSteps / _requiredSteps).clamp(0.0, 1.0) : 0.0;

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
                        colors: _hasOrbe
                            ? [
                                Colors.purpleAccent.withOpacity(0.6),
                                Colors.deepPurple.withOpacity(0.3),
                              ]
                            : [
                                Colors.grey.withOpacity(0.3),
                                Colors.grey.withOpacity(0.1),
                              ],
                      ),
                      boxShadow: _hasOrbe
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
                        _hasOrbe ? Icons.circle : Icons.add_circle_outline,
                        size: 100,
                        color: _hasOrbe ? Colors.white : Colors.white30,
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Información del estado
                  if (_hasOrbe) ...[
                    Text(
                      _isReadyToChannel ? '¡Listo para Canalizar!' : 'Canalizando...',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: _isReadyToChannel ? Colors.greenAccent : Colors.white,
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
                                '$_currentSteps / $_requiredSteps pasos',
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
                                _isReadyToChannel ? Colors.greenAccent : Colors.cyanAccent,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Botón de acción
                    if (_isReadyToChannel)
                      ElevatedButton(
                        onPressed: () {
                          // TODO: Navegar a pantalla de canalización
                          Navigator.pushNamed(context, '/channeling');
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
                        Navigator.pushNamed(context, '/shop');
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
