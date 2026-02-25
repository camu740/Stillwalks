import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:stillwalks/l10n/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(l10n.creditsTitle),
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
              l10n.creditsVersion(_version),
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white54,
              ),
            ),
          ),
          
          const SizedBox(height: 48),
          
          _buildSection(
            title: l10n.creditsCreationTitle,
            content: l10n.creditsCreationContent,
          ),
          
          _buildSection(
            title: l10n.creditsTechTitle,
            content: l10n.creditsTechContent,
          ),
          
          _buildSection(
            title: l10n.creditsMusicTitle,
            content: l10n.creditsMusicContent,
          ),
          
          _buildSection(
            title: l10n.creditsThanksTitle,
            content: l10n.creditsThanksContent,
          ),
          
          _buildSection(
            title: l10n.creditsPhilosophyTitle,
            content: l10n.creditsPhilosophyContent,
          ),
          
          _buildSection(
            title: l10n.creditsLegalTitle,
            content: l10n.creditsLegalContent,
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
