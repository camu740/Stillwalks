# Stillwalks - Guía de Desarrollo

## 🚀 Inicio Rápido

### Requisitos Previos
- Flutter SDK 3.0+ instalado (ver [FLUTTER_INSTALL_GUIDE.md](FLUTTER_INSTALL_GUIDE.md))
- Android Studio con Android SDK
- Dispositivo Android físico o emulador (API 21+)

### Primer Uso

1. **Instalar dependencias**:
   ```bash
   cd c:\Users\adria\.gemini\antigravity\scratch\stillwalks
   flutter pub get
   ```

2. **Conectar dispositivo o iniciar emulador**:
   ```bash
   flutter devices
   ```

3. **Ejecutar la app**:
   ```bash
   flutter run
   ```

La primera ejecución puede tardar varios minutos mientras se compila el código Android.

## 📱 Testing del MVP

### Escenarios de Testing Críticos

#### 1. Test de Generación de Esencia
- Abrir la app → Bloquear pantalla (botón apagar) → Esperar 5 minutos → Desbloquear
- **Resultado esperado**: Ver Esencia incrementada en HomeScreen

#### 2. Test de Contador de Pasos
- Abrir la app → Caminar 100 pasos
- **Resultado esperado**: Ver progreso de Orbe en SanctuaryScreen

#### 3. Test de Anti-Cheat (Cambio de Hora)
- Abrir la app → Cerrar app → Cambiar hora del sistema +2 horas → Abrir app
- **Resultado esperado**: NO debería generar Esencia por el salto temporal

#### 4. Test de Límite de 12 Horas
- Dejar app cerrada por 24 horas → Abrir app
- **Resultado esperado**: Solo recibir Esencia de 12 horas máximo

#### 5. Test de Persistencia después de Reboot
- Con app instalada → Reiniciar dispositivo → Abrir app
-resultado esperado**: Tracking se reinicia automáticamente

### Logs de Debugging

Para ver logs detallados:
```bash
flutter logs
```

Buscar por:
- `🎯` - Eventos de Esencia desde nativo
- `👟` - Eventos de pasos desde nativo
- `💰` - Transacciones de Esencia
- `✅` - Inicialización exitosa
- `❌` - Errores

### Inspección de Base de Datos

**Usando Android Studio Device File Explorer**:
1. View → Tool Windows → Device File Explorer
2. Navegar a: `/data/data/com.stillwalks.app/databases/stillwalks.db`
3. Click derecho → Save As... → Abrir con SQLite browser

## 🔧 Desarrollo

### Estructura de Código

```
lib/
├── main.dart                 # Entry point con providers
├── models/                   # Modelos de datos
│   ├── player_state.dart
│   ├── orbe.dart
│   ├── sanctuary.dart
│   ├── creature_species.dart
│   ├── creature_instance.dart
│   └── upgrade.dart
├── services/                 # Lógica de negocio
│   ├── esencia_service.dart
│   ├── orbe_service.dart
│   ├── collection_service.dart
│   ├── permission_service.dart
│   └── native_bridge.dart
├── screens/                  # UI
│   ├── home_screen.dart
│   ├── sanctuary_screen.dart
│   ├── shop_screen.dart
│   ├── explorer_journal_screen.dart
│   ├── channeling_screen.dart
│   └── permissions_screen.dart
└── data/
    ├── database/
    │   └── database_helper.dart
    └── seeds/
        └── initial_data.dart

android/app/src/main/kotlin/com/stillwalks/app/
├── MainActivity.kt
├── ScreenLockTracker.kt
├── StepCounterService.kt
├── TrackingForegroundService.kt
└── BootReceiver.kt
```

### Hot Reload

Durante desarrollo, usa hot reload para ver cambios inmediatos:
- Presiona `r` en terminal para hot reload
- Presiona `R` para hot restart (reinicio completo)
- Presiona `q` para salir

### Modificar Datos de Seed

Editar `lib/data/seeds/initial_data.dart` y luego:
```bash
flutter clean
flutter run
```

Esto recreará la base de datos con los nuevos datos.

### Añadir Nuevas Criaturas

1. Generar sprite (64x64 pixel art PNG)
2. Colocar en `assets/creatures/[nombre].png`
3. Añadir a `pubspec.yaml` en sección `assets`
4. Actualizar `initial_data.dart` con nueva especie
5. Actualizar loot table del OrbeType

## 🐛 Solución de Problemas

### Error: "Esencia no se genera"
- Verificar que el servicio Android está corriendo: Ver notificación persistente
- Revisar logs: `flutter logs | grep "ScreenLockTracker"`
- Confirmar que el dispositivo se bloqueó realmente (ACTION_SCREEN_OFF)

### Error: "Pasos no se cuentan"
- Verificar sensor disponible: algunos emuladores no tienen step counter
- Usar dispositivo físico para testing de pasos
- Revisar logs: `flutter logs | grep "StepCounter"`

### Error: "La app crash al abrir"
- Limpiar build: `flutter clean && flutter pub get`
- Verificar que todos los assets existen
- Revisar parámetros esperado en DatabaseHelper

### Permisos Denegados
- Ir a Ajustes → Apps → Stillwalks → Permisos → Actividad física
- Reiniciar la app

## 📊 Métricas de Performance

### Consumo de Batería (Objetivo)
- **Idle (pantalla bloqueada)**: < 0.5% por hora
- **Activo**: < 3% por hora
- **Después de 8 horas**: < 3% total

### Uso de Memoria
- **RAM**: < 100 MB idle
- **Almacenamiento BD**: < 5 MB

### Verificar Performance
```bash
# Android Profiler
# En Android Studio: View → Tool Windows → Profiler
# Seleccionar app y ver CPU/Memory/Battery
```

## 📦 Build para Distribución

### APK de Debug (Testing)
```bash
flutter build apk --debug
```
Archivo generado: `build/app/outputs/flutter-apk/app-debug.apk`

### APK de Release (Manual Install)
```bash
flutter build apk --release
```

### App Bundle (Google Play Store)
```bash
flutter build appbundle --release
```
Archivo generado: `build/app/outputs/bundle/release/app-release.aab`

## 🧪 Testing Automatizado

### Unit Tests
```bash
flutter test
```

### Widget Tests
```bash
flutter test test/widget_test.dart
```

### Integration Tests
```bash
flutter test integration_test/
```

## 🔄 Actualizar Dependencias

```bash
flutter pub upgrade
flutter pub outdated  # Ver paquetes desactualizados
```

## 📝 Changelog

Ver `CHANGELOG.md` para historial de versiones.

## 🚧 Próximas Features (Post-MVP)

- [ ] Widget de pantalla de inicio  
- [ ] Notificaciones push para Orbes completados
- [ ] Múltiples tipos de Orbes
- [ ] Sistema de evolución de criaturas
- [ ] Trading entre jugadores (requiere backend)
- [ ] Eventos temporales

## 📞 Soporte

Para issues de desarrollo, revisar:
1. `NEXT_STEPS.md` - Tareas pendientes
2. `quick_reference.md` - Referencia rápida
3. GitHub Issues (si el proyecto está en GitHub)

---

**Versión**: 0.1.0-alpha  
**Última actualización**: Febrero 2026
