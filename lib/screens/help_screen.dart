import 'package:flutter/material.dart';

/// FAQ/Help screen with frequently asked questions
class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Ayuda'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildFAQItem(
            question: '¿Qué es la Esencia y cómo se genera?',
            answer: 'La Esencia es el recurso principal de Stillwalks.\n'
                'Se genera automáticamente cuando tu móvil está bloqueado, sin que tengas que hacer nada.\n\n'
                'Cuanto más tiempo pases sin usar el teléfono, más Esencia acumulas.\n'
                'La Esencia se utiliza para comprar Orbes, Santuarios y mejoras que aceleran tu progreso.',
          ),
          
          _buildFAQItem(
            question: '¿Cómo funcionan los Orbes?',
            answer: 'Los Orbes son semillas de vida que contienen a los Stillwalks.\n'
                'Cada Orbe necesita una cantidad determinada de pasos para poder canalizarse.\n\n'
                'Una vez compras un Orbe:\n'
                '• Lo colocas en un Santuario\n'
                '• Caminas para generar Energía (pasos)\n'
                '• Cuando el progreso se completa, puedes canalizarlo\n'
                '• Al canalizarlo, descubres una nueva criatura\n\n'
                'Existen diferentes tipos de Orbes, algunos más raros y exigentes que otros.',
          ),
          
          _buildFAQItem(
            question: '¿Cómo funcionan los Santuarios?',
            answer: 'Los Santuarios son el lugar donde los Orbes se canalizan.\n'
                'En ellos se transforma la Energía (pasos) en progreso del Orbe.\n\n'
                'Hay dos tipos de Santuarios:\n'
                '• Permanentes: se pueden mejorar y usar de forma indefinida\n'
                '• Temporales: ofrecen ventajas especiales, pero duran un número limitado de canalizaciones\n\n'
                'Los Santuarios pueden tener diferentes beneficios dependiendo de su nivel o el tipo que sea.',
          ),
          
          _buildFAQItem(
            question: '¿Cómo cuenta la app mis pasos?',
            answer: 'Stillwalks utiliza el contador de pasos del sistema de tu dispositivo.\n'
                'No mide tu ubicación ni registra recorridos, solo el número de pasos.\n\n'
                'El conteo funciona en segundo plano y se actualiza de forma periódica para reducir el consumo de batería.',
          ),
          
          _buildFAQItem(
            question: '¿Por qué los pasos no se actualizan al instante?',
            answer: 'Para ahorrar batería y respetar el funcionamiento del sistema, '
                'los pasos no se actualizan en tiempo real.\n\n'
                'La app recibe los datos en intervalos, por lo que es normal que haya pequeños retrasos.\n'
                'Todos los pasos realizados acaban contándose correctamente.',
          ),
          
          _buildFAQItem(
            question: '¿Qué notificaciones puedo recibir?',
            answer: 'Dependiendo de tu configuración, puedes recibir:\n'
                '• Avisos cuando un Orbe está listo para canalizar\n'
                '• Notificaciones sobre eventos del juego\n'
                '• Recordatorios no intrusivos para recordarte salir a caminar\n'
                '• Notificación permanente para ver en todo momento el estado de tu cuenta\n\n'
                'Todas las notificaciones se pueden activar o desactivar desde Ajustes.',
          ),
          
          _buildFAQItem(
            question: '¿Qué permisos necesita la app?',
            answer: 'Stillwalks puede solicitar:\n'
                '• Acceso a actividad física (para contar pasos)\n'
                '• Permiso de notificaciones (para avisos opcionales)\n\n'
                'Sin estos permisos el juego sigue funcionando, pero algunas funciones pueden ser menos precisas.',
          ),
          
          _buildFAQItem(
            question: '¿Consume mucha batería?',
            answer: 'No.\n'
                'Stillwalks está diseñado para tener un impacto mínimo en la batería.\n\n'
                'Utiliza:\n'
                '• El contador de pasos del sistema\n'
                '• Actualizaciones periódicas, no constantes\n'
                '• Opciones como el modo ahorro batería\n\n'
                'Puedes controlar este comportamiento desde Ajustes en cualquier momento.',
          ),
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildFAQItem({
    required String question,
    required String answer,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Theme(
        data: ThemeData(
          dividerColor: Colors.transparent,
          textTheme: const TextTheme(
            titleMedium: TextStyle(color: Colors.white),
            bodyMedium: TextStyle(color: Colors.white70),
          ),
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          iconColor: Colors.tealAccent,
          collapsedIconColor: Colors.white54,
          title: Text(
            question,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          children: [
            Text(
              answer,
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
