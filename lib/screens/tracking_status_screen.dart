import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stillwalks/services/notification_preferences_service.dart';
import 'package:stillwalks/services/esencia_service.dart';
import 'package:stillwalks/services/permission_service.dart';
import 'package:stillwalks/services/native_bridge.dart';
import 'package:stillwalks/services/google_fit_service.dart';
import 'package:stillwalks/l10n/app_localizations.dart';

/// Diagnostic screen showing overall system tracking status
class TrackingStatusScreen extends StatelessWidget {
  const TrackingStatusScreen({super.key});

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
      return '${lastUpdate.day}/${lastUpdate.month}/${lastUpdate.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final notificationPrefs = Provider.of<NotificationPreferencesService>(context);
    final esenciaService = Provider.of<EsenciaService>(context);
    final permissionService = Provider.of<PermissionService>(context);
    final l10n = AppLocalizations.of(context)!;
    
    final settings = notificationPrefs.settings;
    final isPaused = settings.pauseProgress;
    final lastUpdate = esenciaService.lastUpdate;
    final hasPermission = permissionService.hasPermission;

    // Determine system health
    final bool systemHealthy = !isPaused && 
                               hasPermission &&
                               lastUpdate != null && 
                               DateTime.now().difference(lastUpdate).inHours < 2;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(l10n.trackingStatus),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // System Health Indicator with contextual message
          _buildSystemHealthCard(systemHealthy, isPaused, hasPermission, lastUpdate, l10n),
          
          const SizedBox(height: 24),
          
          // Tracking Status
          _buildStatusCard(
            icon: isPaused ? Icons.pause_circle : Icons.play_circle,
            iconColor: isPaused ? Colors.orangeAccent : Colors.greenAccent,
            title: l10n.trackingStatus,
            value: isPaused ? l10n.trackingPaused : l10n.trackingActive,
            valueColor: isPaused ? Colors.orangeAccent : Colors.greenAccent,
            l10n: l10n,
          ),
          
          const SizedBox(height: 12),
          
          // Last Sync
          _buildStatusCard(
            icon: Icons.sync,
            iconColor: Colors.blueAccent,
            title: l10n.lastSync,
            value: lastUpdate != null 
                ? _formatTimeSince(lastUpdate, l10n)
                : l10n.none,
            l10n: l10n,
          ),
          
          const SizedBox(height: 24),
          
          // Step Counting Diagnostics
          _buildStepDiagnosticsSection(context, l10n),
        ],
      ),
    );
  }

  Widget _buildStatusCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    Color? valueColor,
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
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: valueColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required List<String> items,
    required AppLocalizations l10n,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 32),
              const SizedBox(width: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(left: 48, bottom: 4),
            child: Row(
              children: [
                Icon(Icons.circle, size: 6, color: Colors.white54),
                const SizedBox(width: 8),
                Text(
                  item,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
  
  Widget _buildSystemHealthCard(bool systemHealthy, bool isPaused, bool hasPermission, DateTime? lastUpdate, AppLocalizations l10n) {
    String statusText;
    String? helpText;
    Color bgColor;
    Color borderColor;
    Color statusColor;
    IconData icon;
    
    if (systemHealthy) {
      statusText = l10n.systemHealthy;
      helpText = l10n.noIssues;
      bgColor = Colors.green.withOpacity(0.1);
      borderColor = Colors.greenAccent.withOpacity(0.3);
      statusColor = Colors.greenAccent;
      icon = Icons.check_circle;
    } else if (isPaused) {
      statusText = 'Sistema pausado';
      helpText = 'El seguimiento está pausado. Reactívalo desde Ajustes > Bienestar > Pausar progreso.';
      bgColor = Colors.orange.withOpacity(0.1);
      borderColor = Colors.orangeAccent.withOpacity(0.3);
      statusColor = Colors.orangeAccent;
      icon = Icons.pause_circle;
    } else if (!hasPermission) {
      statusText = 'Permiso requerido';
      helpText = 'El permiso de actividad física está denegado. Ve a Ajustes > Privacidad y Sistema > Permisos para activarlo.';
      bgColor = Colors.red.withOpacity(0.1);
      borderColor = Colors.redAccent.withOpacity(0.3);
      statusColor = Colors.redAccent;
      icon = Icons.warning;
    } else if (lastUpdate == null || DateTime.now().difference(lastUpdate).inHours >= 2) {
      statusText = 'Sin actividad reciente';
      helpText = 'No se han detectado pasos en las últimas horas. Verifica que la app tenga permisos y no esté pausada.';
      bgColor = Colors.blue.withOpacity(0.1);
      borderColor = Colors.blueAccent.withOpacity(0.3);
      statusColor = Colors.blueAccent;
      icon = Icons.info;
    } else {
      statusText = l10n.systemHealthy;
      helpText = null;
      bgColor = Colors.green.withOpacity(0.1);
      borderColor = Colors.greenAccent.withOpacity(0.3);
      statusColor = Colors.greenAccent;
      icon = Icons.check_circle;
    }
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: statusColor, size: 48),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.systemStatus,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      statusText,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (helpText != null) ...[
            const SizedBox(height: 12),
            const Divider(color: Colors.white24, height: 1),
            const SizedBox(height: 12),
            Text(
              helpText,
              style: TextStyle(
                color: statusColor,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildStepDiagnosticsSection(BuildContext context, AppLocalizations l10n) {
    final nativeBridge = Provider.of<NativeBridge>(context, listen: false);
    final googleFitService = Provider.of<GoogleFitService>(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.stepCounter,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        
        // Native Sensor Status
        FutureBuilder<bool>(
          future: nativeBridge.isStepCountingWorking(),
          builder: (context, snapshot) {
            final isWorking = snapshot.data ?? false;
            return _buildSourceCard(
              icon: Icons.smartphone,
              iconColor: isWorking ? Colors.greenAccent : Colors.redAccent,
              title: l10n.deviceSensor,
              status: isWorking ? l10n.sensorActive : l10n.sensorInactive,
              statusColor: isWorking ? Colors.greenAccent : Colors.redAccent,
              details: isWorking 
                  ? 'Conteo de pasos del hardware del dispositivo'
                  : 'Sensor nativo no disponible o sin permisos',
            );
          },
        ),
        
        const SizedBox(height: 12),
        
        // Google Fit Status
        _buildSourceCard(
          icon: Icons.track_changes,
          iconColor: googleFitService.isEnabled 
              ? Colors.blueAccent 
              : Colors.grey,
          title: 'Google Fit / Health Connect',
          status: googleFitService.isEnabled 
              ? l10n.sensorActive 
              : 'Desactivado',
          statusColor: googleFitService.isEnabled 
              ? Colors.blueAccent 
              : Colors.grey,
          details: googleFitService.isEnabled
              ? 'Sincronización automática de pasos cada 5 minutos'
              : 'Activa Google Fit en Ajustes para mayor precisión',
        ),
        
        const SizedBox(height: 16),
        
        // Info Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.blue.withOpacity(0.1),
                Colors.purple.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.lightbulb_outline, color: Colors.blue, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Tip: Habilita Google Fit para validación cruzada y mayor precisión en el conteo de pasos',
                  style: TextStyle(
                    color: Colors.blue.shade200,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildSourceCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String status,
    required Color statusColor,
    required String details,
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
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      status.contains('Activo') || status.contains('Active') 
                          ? Icons.check_circle 
                          : Icons.cancel,
                      color: statusColor,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      status,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  details,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white60,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
