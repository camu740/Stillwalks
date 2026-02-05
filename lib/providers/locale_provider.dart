import 'package:flutter/material.dart';

/// Provider que gestiona el idioma actual de la aplicación
class LocaleProvider extends ChangeNotifier {
  Locale _locale;
  
  LocaleProvider([String languageCode = 'es']) 
      : _locale = _parseLocale(languageCode);
  
  Locale get locale => _locale;
  
  /// Actualiza el locale basado en el código de idioma guardado
  void setLocale(String languageCode) {
    _locale = _parseLocale(languageCode);
    notifyListeners();
  }
  
  static Locale _parseLocale(String languageCode) {
    if (languageCode == 'system') {
      // Usar el idioma del sistema
      final systemLocale = WidgetsBinding.instance.platformDispatcher.locale;
      // Si el idioma del sistema es soportado, usarlo; sino, usar español por defecto
      if (['es', 'en'].contains(systemLocale.languageCode)) {
        return systemLocale;
      }
      return const Locale('es');
    }
    
    return Locale(languageCode);
  }
}
