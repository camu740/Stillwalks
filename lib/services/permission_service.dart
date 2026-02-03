import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart' as ph;

class PermissionService extends ChangeNotifier {
  bool _activityRecognitionGranted = false;
  bool _hasChecked = false;

  bool get hasAllPermissions => _activityRecognitionGranted;
  bool get hasChecked => _hasChecked;

  /// Alias para main.dart
  bool get hasPermission => hasAllPermissions;
  
  /// Alias para main.dart
  Future<void> checkPermission() async => await checkPermissions();

  /// Verifica el estado actual de los permisos
  Future<void> checkPermissions() async {
    _activityRecognitionGranted = await ph.Permission.activityRecognition.isGranted;
    _hasChecked = true;
    notifyListeners();
  }

  /// Solicita el permiso de reconocimiento de actividad
  Future<bool> requestActivityRecognition() async {
    // Solicitar ambos permisos
    final activityStatus = await ph.Permission.activityRecognition.request();
    final notificationStatus = await ph.Permission.notification.request();
    
    _activityRecognitionGranted = activityStatus.isGranted;
    // No bloqueamos si no hay notificaciones, pero es bueno tenerlo
    
    notifyListeners();
    return _activityRecognitionGranted;
  }

  /// Abre la configuración de la app si el permiso fue denegado permanentemente
  Future<void> openAppSettings() async {
    await ph.openAppSettings();
  }
}
