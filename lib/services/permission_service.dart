import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionService extends ChangeNotifier {
  bool _activityRecognitionGranted = false;
  bool _hasChecked = false;

  bool get hasAllPermissions => _activityRecognitionGranted;
  bool get hasChecked => _hasChecked;

  /// Verifica el estado actual de los permisos
  Future<void> checkPermissions() async {
    _activityRecognitionGranted = await Permission.activityRecognition.isGranted;
    _hasChecked = true;
    notifyListeners();
  }

  /// Solicita el permiso de reconocimiento de actividad
  Future<bool> requestActivityRecognition() async {
    final status = await Permission.activityRecognition.request();
    _activityRecognitionGranted = status.isGranted;
    notifyListeners();
    return _activityRecognitionGranted;
  }

  /// Abre la configuración de la app si el permiso fue denegado permanentemente
  Future<void> openAppSettings() async {
    await openAppSettings();
  }
}
