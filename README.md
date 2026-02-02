# Stillwalks - Digital Wellbeing Idle Game

Una aplicación móvil que fomenta el bienestar digital y la actividad física. Gana Esencia manteniendo tu teléfono bloqueado y camina para canalizar Orbes y coleccionar Stillwalks.

## Requisitos Previos

### Instalar Flutter SDK

1. **Descargar Flutter**:
   - Visita: https://docs.flutter.dev/get-started/install/windows
   - Descarga el Flutter SDK para Windows
   - Extrae el archivo en una ubicación (ej: `C:\src\flutter`)

2. **Añadir Flutter al PATH**:
   - Busca "Variables de entorno" en Windows
   - Edita la variable `Path` del usuario
   - Añade: `C:\src\flutter\bin` (ajusta según tu ubicación)

3. **Verificar instalación**:
   ```bash
   flutter doctor
   ```

4. **Instalar Android Studio**:
   - Descarga desde: https://developer.android.com/studio
   - Durante la instalación, incluye:
     - Android SDK
     - Android SDK Platform-Tools
     - Android SDK Build-Tools
     - Android Emulator

5. **Aceptar licencias**:
   ```bash
   flutter doctor --android-licenses
   ```

## Configuración del Proyecto

Una vez instalado Flutter:

```bash
# Obtener dependencias
flutter pub get

# Ejecutar en dispositivo Android conectado o emulador
flutter run
```

## Estructura del Proyecto

```
stillwalks/
├── android/                    # Código nativo Android (Kotlin)
│   └── app/src/main/kotlin/
│       └── com/stillwalks/app/
│           ├── ScreenLockTracker.kt
│           ├── StepCounterService.kt
│           ├── StillwalksWidget.kt
│           └── PersistentNotification.kt
├── lib/
│   ├── main.dart              # Punto de entrada
│   ├── models/                 # Modelos de datos
│   ├── services/               # Lógica de negocio
│   ├── screens/                # Pantallas UI
│   ├── widgets/                # Componentes reutilizables
│   └── data/
│       ├── database/           # SQLite
│       └── seeds/              # Datos iniciales
├── assets/                     # Sprites y recursos
│   ├── creatures/
│   ├── ui/
│   └── animations/
└── test/                       # Tests unitarios

```

## Nomenclatura del Juego

**Términos oficiales (NO usar terminología Pokémon)**:
- **Esencia**: Moneda del juego
- **Orbes**: "Huevos" que se incuban
- **Santuarios**: "Incubadoras" para Orbes
- **Canalizar**: Proceso de completar un Orbe
- **Diario de explorador**: Colección de criaturas descubiertas
- **Stillwalks**: Las criaturas coleccionables

## Criaturas MVP

1. **Spiristone** (Común - 50%)
   - Pequeña piedra cute con manitas y piernitas

2. **Radispirit** (Poco común - 35%)
   - Pequeño rábano a cuatro patas, hojas como cola

3. **Slugrry** (Raro - 15%)
   - Babosa peluda blanca

## Desarrollo

### Orden de Implementación (según MVP)

1. ✅ Estructura del proyecto
2. ⏳ Tracking de tiempo bloqueado (Android nativo)
3. ⏳ Sistema de Esencia pasiva
4. ⏳ UI mínima
5. ⏳ Tracking de pasos
6. ⏳ Sistema de Santuarios y Orbes
7. ⏳ Stillwalks + canalización
8. ⏳ Animación de canalización

### Comandos Útiles

```bash
# Ejecutar en modo debug
flutter run

# Build APK para testing
flutter build apk --debug

# Ejecutar tests
flutter test

# Analizar código
flutter analyze

# Formatear código
dart format .
```

## Notas Técnicas

### Anti-Cheat
- Límite de 12 horas de Esencia acumulable
- Validación de timestamps con tiempo de boot del dispositivo
- Los puntos se persisten en base de datos antes de reinicios

### Permisos Android
- `ACTIVITY_RECOGNITION`: Para contar pasos
- `FOREGROUND_SERVICE`: Para tracking en background
- `WAKE_LOCK`: Para mantener servicios activos
- `RECEIVE_BOOT_COMPLETED`: Para reiniciar servicios después de reinicio

### Optimización
- Objetivo: <3% consumo de batería en 8 horas
- Widget actualizado cada 15 minutos
- Servicios eficientes en background

## Licencia

Proyecto privado - Todos los derechos reservados
