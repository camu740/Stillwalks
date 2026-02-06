import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Credits screen showing project information
class CreditsScreen extends StatefulWidget {
  const CreditsScreen({super.key});

  @override
  State<CreditsScreen> createState() => _CreditsScreenState();
}

class _CreditsScreenState extends State<CreditsScreen> {
  String _version = '';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _version = packageInfo.version;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Créditos'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // Title and version
          const Center(
            child: Text(
              'Stillwalks',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.tealAccent,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'Versión $_version',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white54,
              ),
            ),
          ),
          
          const SizedBox(height: 48),
          
          _buildSection(
            title: 'CREACIÓN Y DESARROLLO',
            content: 'Idea, diseño y desarrollo\nCamu',
          ),
          
          _buildSection(
            title: 'TECNOLOGÍA',
            content: 'Desarrollado con tecnologías multiplataforma para dispositivos móviles.\n\n'
                'Seguimiento de actividad física mediante APIs nativas del sistema.\n\n'
                'Sistema de notificaciones y ejecución en segundo plano implementados de forma local.',
          ),
          
          _buildSection(
            title: 'AGRADECIMIENTOS',
            content: 'Gracias a todas las personas que han probado el juego, '
                'han dado feedback y han apoyado la idea de un uso más consciente del móvil.\n\n'
                'Gracias también a quienes buscan equilibrar tecnología y bienestar en su día a día.',
          ),
          
          _buildSection(
            title: 'FILOSOFÍA DEL PROYECTO',
            content: 'Stillwalks no pretende que uses más el móvil, sino que lo uses mejor.\n\n'
                'Diseñado para acompañarte, no para exigirte.',
          ),
          
          _buildSection(
            title: 'INFORMACIÓN LEGAL',
            content: '© 2026 Camu. Todos los derechos reservados.\n\n'
                'Este proyecto utiliza librerías y tecnologías de terceros '
                'cuyas licencias pueden consultarse en la sección correspondiente.',
          ),
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String content,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.tealAccent,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              height: 1.6,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}
