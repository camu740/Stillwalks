import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stillwalks/services/esencia_service.dart';
import 'package:stillwalks/services/notification_preferences_service.dart';
import 'package:stillwalks/services/permission_service.dart';
import 'package:stillwalks/l10n/app_localizations.dart';

/// Diagnostic screen showing step counter sensor status
class SensorsScreen extends StatelessWidget {
  const SensorsScreen({super.key});

  String _formatTimeSince(DateTime lastUpdate, AppLocalizations l10n) {
    final now = DateTime.now();
    final difference = now.difference(lastUpdate);
    
    if (difference.inMinutes < 1) {
      return l10n.justNow;
    } else if (difference.inMinutes < 60) {
      return l10n.minutesAgo(difference.inMinutes);
    } else if (difference.inHours < 24) {
      return l10n.hoursAgo(difference.inHours);
    } else {
      return '${lastUpdate.day}/${lastUpdate.month}/${lastUpdate.year} ${lastUpdate.hour}:${lastUpdate.minute.toString().padLeft(2, '0')}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final esenciaService = Provider.of<EsenciaService>(context);
    final notificationPrefs = Provider.of<NotificationPreferencesService>(context);
    final permissionService = Provider.of<PermissionService>(context);
    final l10n = AppLocalizations.of(context)!;
    
    // Check if sensor is active (has recent activity)
    final lastUpdate = esenciaService.lastUpdate;
    final now = DateTime.now();
    final isActive = lastUpdate != null && now.difference(lastUpdate).inMinutes < 30;
    
    // Detect why it might be inactive
    final isPaused = notificationPrefs.settings.pauseProgress;
    final hasPermission = permissionService.hasPermission;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(l10n.sensors),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Step Counter Status
          _buildStatusCard(
            icon: Icons.sensors,
            iconColor: isActive ? Colors.greenAccent : Colors.orangeAccent,
            title: l10n.stepCounter,
            status: isActive ? l10n.sensorActive : l10n.sensorInactive,
            isActive: isActive,
            l10n: l10n,
          ),
          
          const SizedBox(height: 16),
          
          // Last Update
          _buildInfoCard(
            icon: Icons.update,
            iconColor: Colors.blueAccent,
            title: l10n.lastUpdate,
            value: lastUpdate != null 
                ? _formatTimeSince(lastUpdate, l10n)
                : l10n.none,
            l10n: l10n,
          ),
          
          const SizedBox(height: 24),
          
          // Info message
          _buildInfoMessage(isActive, isPaused, hasPermission, l10n),
        ],
      ),
    );
  }

  Widget _buildStatusCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String status,
    required bool isActive,
    required AppLocalizations l10n,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive 
              ? Colors.greenAccent.withOpacity(0.3)
              : Colors.orangeAccent.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 40),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isActive 
                        ? Colors.greenAccent.withOpacity(0.2)
                        : Colors.orangeAccent.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: isActive ? Colors.greenAccent : Colors.orangeAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            isActive ? Icons.check_circle : Icons.warning,
            color: isActive ? Colors.greenAccent : Colors.orangeAccent,
            size: 32,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required AppLocalizations l10n,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildInfoMessage(bool isActive, bool isPaused, bool hasPermission, AppLocalizations l10n) {
    String message;
    Color bgColor;
    Color borderColor;
    Color iconColor;
    IconData icon;
    
    if (isActive) {
      // Everything is working fine
      message = 'El contador de pasos está funcionando correctamente. Se actualiza automáticamente mientras caminas.';
      bgColor = Colors.green.withOpacity(0.1);
      borderColor = Colors.greenAccent.withOpacity(0.3);
      iconColor = Colors.greenAccent;
      icon = Icons.check_circle;
    } else if (isPaused) {
      // Tracking is paused
      message = 'El seguimiento está pausado. Reactívalo desde Ajustes > Bienestar > Pausar progreso.';
      bgColor = Colors.orange.withOpacity(0.1);
      borderColor = Colors.orangeAccent.withOpacity(0.3);
      iconColor = Colors.orangeAccent;
      icon = Icons.pause_circle;
    } else if (!hasPermission) {
      // Permission denied
      message = 'El permiso de actividad física está denegado. Ve a Ajustes > Privacidad y Sistema > Permisos para activarlo.';
      bgColor = Colors.red.withOpacity(0.1);
      borderColor = Colors.redAccent.withOpacity(0.3);
      iconColor = Colors.redAccent;
      icon = Icons.warning;
    } else {
      // Inactive for other reasons (no recent activity)
      message = 'No se han detectado pasos recientemente. Prueba a caminar un poco para verificar que el sensor funciona.';
      bgColor = Colors.blue.withOpacity(0.1);
      borderColor = Colors.blueAccent.withOpacity(0.3);
      iconColor = Colors.blueAccent;
      icon = Icons.info_outline;
    }
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: iconColor,
                fontSize: 14,
                height: 1.4,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
