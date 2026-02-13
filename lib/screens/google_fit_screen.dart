import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stillwalks/services/google_fit_service.dart';
import 'package:stillwalks/services/notification_preferences_service.dart';
import 'package:stillwalks/screens/home_screen.dart';
import 'package:stillwalks/l10n/app_localizations.dart';
import 'package:health/health.dart'; // Needed for HealthConnectSdkStatus

class GoogleFitScreen extends StatefulWidget {
  const GoogleFitScreen({super.key});

  @override
  State<GoogleFitScreen> createState() => _GoogleFitScreenState();
}

class _GoogleFitScreenState extends State<GoogleFitScreen> with WidgetsBindingObserver {
  bool _isLoading = false;
  HealthConnectSdkStatus? _hcStatus;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkStatus();
    }
  }

  Future<void> _checkStatus() async {
    final service = Provider.of<GoogleFitService>(context, listen: false);
    final status = await service.getHealthConnectStatus();
    if (mounted) {
      setState(() {
        _hcStatus = status;
      });
    }
  }

  void _finish(BuildContext context) {
    if (!mounted) return;
    
    // Mark as seen - this will trigger a rebuild in main.dart
    Provider.of<NotificationPreferencesService>(context, listen: false)
        .setHasSeenGoogleFitPrompt(true);
  }

  Future<void> _handlePrimaryAction() async {
    final service = Provider.of<GoogleFitService>(context, listen: false);

    if (_hcStatus == HealthConnectSdkStatus.sdkUnavailableProviderUpdateRequired || 
        _hcStatus == HealthConnectSdkStatus.sdkUnavailable) {
      // Install flow
      await service.installHealthConnect();
      return; 
    }

    // Connect flow
    setState(() => _isLoading = true);
    
    try {
      final granted = await service.enable();
      
      if (granted && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.googleFitConnected)),
        );
        _finish(context);
      } else if (mounted) {
         // Denied
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Permisos denegados. Por favor, habilítalos en Ajustes.'),
              action: SnackBarAction(label: 'Ajustes', onPressed: () => service.openHealthConnectSettings()), // Instance method via service
              duration: const Duration(seconds: 5),
            ),
          );
      }
    } catch (e) {
      debugPrint('Error connecting: $e');
      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    String title = l10n.googleFitTitle;
    String desc = l10n.googleFitDescription;
    String btnLabel = l10n.connectGoogleFit;
    IconData btnIcon = Icons.check;
    Color btnColor = Colors.redAccent;

    // Adjust UI based on status
    if (_hcStatus == HealthConnectSdkStatus.sdkUnavailableProviderUpdateRequired) {
      title = 'Instalar Health Connect';
      desc = 'Para sincronizar tus pasos, necesitas instalar o actualizar Health Connect (de Google).';
      btnLabel = 'Instalar / Actualizar';
      btnIcon = Icons.download;
      btnColor = Colors.blue;
    } else if (_hcStatus == HealthConnectSdkStatus.sdkUnavailable) {
      title = 'No compatible';
      desc = 'Tu dispositivo no parece soportar Health Connect. Verifica tu versión de Android.';
      btnLabel = 'Instalar (Intentar)';
      btnIcon = Icons.warning;
      btnColor = Colors.grey;
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Icon(
                Icons.favorite,
                size: 80,
                color: btnColor,
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
                  onPressed: _handlePrimaryAction,
                  icon: Icon(btnIcon),
                  label: Text(btnLabel),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: btnColor,
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => _finish(context),
                  child: Text(
                    l10n.maybeLater,
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
