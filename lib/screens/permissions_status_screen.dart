import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stillwalks/services/permission_service.dart';
import 'package:stillwalks/l10n/app_localizations.dart';
import 'package:permission_handler/permission_handler.dart';

/// Diagnostic screen showing current permission status
class PermissionsStatusScreen extends StatefulWidget {
  const PermissionsStatusScreen({super.key});

  @override
  State<PermissionsStatusScreen> createState() => _PermissionsStatusScreenState();
}

class _PermissionsStatusScreenState extends State<PermissionsStatusScreen> {
  bool _notificationPermission = false;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    // Check notification permission (Android 13+)
    final notificationStatus = await Permission.notification.status;
    
    if (mounted) {
      setState(() {
        _notificationPermission = notificationStatus.isGranted;
      });
    }
  }

  Future<void> _openSystemSettings() async {
    await openAppSettings();
  }

  @override
  Widget build(BuildContext context) {
    final permissionService = Provider.of<PermissionService>(context);
    final l10n = AppLocalizations.of(context)!;
    final hasActivityPermission = permissionService.hasPermission;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(l10n.permissions),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Info message
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blueAccent, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.permissionsMessage,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Permission cards
          _buildPermissionCard(
            icon: Icons.directions_walk,
            iconColor: hasActivityPermission ? Colors.greenAccent : Colors.redAccent,
            title: l10n.physicalActivity,
            isGranted: hasActivityPermission,
            l10n: l10n,
          ),
          
          const SizedBox(height: 12),
          
          _buildPermissionCard(
            icon: Icons.notifications_active,
            iconColor: _notificationPermission ? Colors.greenAccent : Colors.redAccent,
            title: l10n.notificationsPermission,
            isGranted: _notificationPermission,
            l10n: l10n,
          ),
          
          const SizedBox(height: 32),
          
          // Open settings button
          ElevatedButton.icon(
            onPressed: _openSystemSettings,
            icon: const Icon(Icons.settings),
            label: Text(l10n.openSystemSettings),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.tealAccent.withOpacity(0.2),
              foregroundColor: Colors.tealAccent,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.tealAccent.withOpacity(0.5)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required bool isGranted,
    required AppLocalizations l10n,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isGranted 
              ? Colors.greenAccent.withOpacity(0.3)
              : Colors.redAccent.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isGranted 
                  ? Colors.greenAccent.withOpacity(0.2)
                  : Colors.redAccent.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isGranted ? Icons.check_circle : Icons.cancel,
                  color: isGranted ? Colors.greenAccent : Colors.redAccent,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  isGranted ? l10n.granted : l10n.denied,
                  style: TextStyle(
                    color: isGranted ? Colors.greenAccent : Colors.redAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
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
