import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stillwalks/services/google_fit_service.dart';
import 'package:stillwalks/services/notification_preferences_service.dart';
import 'package:stillwalks/screens/home_screen.dart';
import 'package:stillwalks/l10n/app_localizations.dart';

class GoogleFitScreen extends StatefulWidget {
  const GoogleFitScreen({super.key});

  @override
  State<GoogleFitScreen> createState() => _GoogleFitScreenState();
}

class _GoogleFitScreenState extends State<GoogleFitScreen> {
  bool _isLoading = false;

  void _finish(BuildContext context) {
    if (!mounted) return;
    
    // Mark as seen
    Provider.of<NotificationPreferencesService>(context, listen: false)
        .setHasSeenGoogleFitPrompt(true);

    // Navigate to Home
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  Future<void> _connectGoogleFit() async {
    setState(() => _isLoading = true);
    
    try {
      final googleFitService = Provider.of<GoogleFitService>(context, listen: false);
      final granted = await googleFitService.enable();
      
      if (granted && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.googleFitConnected)),
        );
        // Only finish if successful
        _finish(context);
      } else if (mounted) {
         // Show error or denial message
         ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudieron obtener los permisos. Asegúrate de tener Health Connect instalado y configurado.'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error connecting Google Fit: $e');
      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al conectar: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
        // Do NOT automatically finish on failure, let the user try again or skip manually
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Fallback if strings not yet available (though they should be)
    final title = AppLocalizations.of(context)?.googleFitTitle ?? 'Connect Google Fit';
    final desc = AppLocalizations.of(context)?.googleFitDescription ?? 
        'Sync your steps from smartwatches and other apps to generate more Essence.';
    final connectBtn = AppLocalizations.of(context)?.connectGoogleFit ?? 'Connect';
    final skipBtn = AppLocalizations.of(context)?.maybeLater ?? 'Maybe Later';

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              const Icon(
                Icons.favorite,
                size: 80,
                color: Colors.redAccent,
              ),
              const SizedBox(height: 32),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                desc,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else ...[
                ElevatedButton.icon(
                  onPressed: _connectGoogleFit,
                  icon: const Icon(Icons.check),
                  label: Text(connectBtn),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => _finish(context),
                  child: Text(
                    skipBtn,
                    style: const TextStyle(color: Colors.white54),
                  ),
                ),
              ],
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
