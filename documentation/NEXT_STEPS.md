# Próximos Pasos para Completar el MVP de Stillwalks

Este documento describe las tareas pendientes para tener un MVP funcional listo para testing.

## 🔴 Crítico - Implementación Inmediata

### 1. Servicios Nativos Android (Kotlin)

Los skeletons ya están creados, pero necesitan implementación completa:

#### ScreenLockTracker.kt
**Archivo**: `android/app/src/main/kotlin/com/stillwalks/app/ScreenLockTracker.kt`

**Tareas**:
- [ ] Convertir en Foreground Service con notificación persistente
- [ ] Implementar cálculo de Esencia basado en timestamps
- [ ] Detectar manipulación de hora usando `SystemClock.elapsedRealtime()`
- [ ] Persistir estado en SQLite Android
- [ ] Crear MethodChannel para comunicación con Flutter
- [ ] Manejar reinicios del dispositivo (guardar estado antes)

**Referencias**:
- [Android Foreground Services](https://developer.android.com/guide/components/foreground-services)
- [MethodChannel Flutter](https://docs.flutter.dev/platform-integration/platform-channels)

#### StepCounterService.kt
**Archivo**: `android/app/src/main/kotlin/com/stillwalks/app/StepCounterService.kt`

**Tareas**:
- [ ] Completar implementación de SensorEventListener
- [ ] Añadir validación anti-cheat (máx 250 pasos/minuto)
- [ ] Actualizar progreso de Orbes en base de datos
- [ ] Crear MethodChannel para comunicación con Flutter
- [ ] Convertir en Foreground Service
- [ ] Optimizar para no consumir batería excesivamente

###.2. Integración Flutter ↔ Android

**Archivo a crear**: `lib/services/native_bridge.dart`

**Tareas**:
- [ ] Crear MethodChannel para recibir eventos de servicios nativos
- [ ] Implementar listeners para `onEsenciaGenerated` y `onStepsUpdated`
- [ ] Conectar con EsenciaService y OrbeService
- [ ] Manejar errores de comunicación

### 3. Conectar UI con Services

Todos los archivos de pantallas tienen TODOs para conectar con providers. Necesitas:

**Archivos afectados**:
- `lib/main.dart`
- `lib/screens/home_screen.dart`
- `lib/screens/sanctuary_screen.dart`
- `lib/screens/shop_screen.dart`
- `lib/screens/explorer_journal_screen.dart`
- `lib/screens/channeling_screen.dart`

**Tareas**:
- [ ] Añadir providers de services al árbol de widgets en `main.dart`
- [ ] Reemplazar datos hardcodeados con datos reales de services
- [ ] Implementar lógica de compra en ShopScreen
- [ ] Implementar asignación de Orbes a Santuarios
- [ ] Conectar ChannelingScreen con OrbeService para determinar criatura

**Ejemplo de integración en main.dart**:
```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => EsenciaService()),
    ChangeNotifierProvider(create: (_) => OrbeService()),
    ChangeNotifierProvider(create: (_) => CollectionService()),
    ChangeNotifierProvider(create: (_) => PermissionService()),
  ],
  child: MaterialApp(...),
)
```

### 4. Inicialización de Base de Datos

**Archivo**: `lib/main.dart` (modificar)

**Tareas**:
- [ ] Al iniciar la app, verificar si la BD está seeded
- [ ] Si no está seeded, llamar a `InitialData.seedDatabase()`
- [ ] Cargar estado del jugador y datos iniciales
- [ ] Mostrar splash screen durante init

## 🟡 Importante - Segunda Fase

### 5. Navegación y Routing

**Archivo a crear**: `lib/routes.dart`

**Tareas**:
- [ ] Definir rutas nombradas para todas las pantallas
- [ ] Implementar navegación desde HomeScreen a Shop, Sanctuary, ExplorerJournal
- [ ] Pasar parámetros entre pantallas (ej: qué criatura mostrar en ChannelingScreen)

### 6. Notificación Persistente

**Archivo a crear**: `android/app/src/main/kotlin/com/stillwalks/app/PersistentNotification.kt`

**Tareas**:
- [ ] Crear notificación con formato para lockscreen
- [ ] Mostrar Esencia actual y tasa de generación
- [ ] Actualizar en tiempo real
- [ ] Crear notification channel (requerido Android 8+)

### 7. Widget Android

**Archivo a crear**: `android/app/src/main/kotlin/com/stillwalks/app/StillwalksWidget.kt`

**Tareas**:
- [ ] Crear AppWidgetProvider
- [ ] Diseñar layout del widget (XML)
- [ ] Mostrar Esencia, tasa, y estado de santuario
- [ ] Actualizar cada 15 minutos
- [ ] Permitir clic para abrir la app

## 🟢 Refinamientos - Tercera Fase

### 8. Manejo de Permisos Mejorado

**Archivo**: `lib/screens/permissions_screen.dart`

**Tareas**:
- [ ] Conectar botón "Continuar" con PermissionService
- [ ] Manejar caso de permiso denegado
- [ ] Mostrar diálogo para ir a ajustes si es permanentemente denegado

### 9. Animaciones y Feedback

**Tareas**:
- [ ] Añadir animaciones de transición entre pantallas
- [ ] Feedback háptico al comprar items
- [ ] Partículas o efectos visuales al ganar Esencia
- [ ] Mejorar animación de canalización en ChannelingScreen

### 10. Tutorial Inicial

**Archivo a crear**: `lib/screens/tutorial_screen.dart`

**Tareas**:
- [ ] Explicar mecánica de Esencia pasiva
- [ ] Mostrar cómo comprar Orbes
- [ ] Explicar el sistema de Santuarios
- [ ] Solo mostrar en primera ejecución

### 11. Testing

**Directorio**: `test/`

**Tareas**:
- [ ] Unit tests para PlayerState.calculatePendingEsencia()
- [ ] Unit tests para loot table en OrbeService
- [ ] Unit tests para validación anti-cheat
- [ ] Widget tests para navegación básica

### 12. Optimización de Batería

**Tareas**:
- [ ] Perfilar consumo de batería con Android Profiler
- [ ] Optimizar frecuencia de actualización de widget
- [ ] Reducir wake locks innecesarios
- [ ] Objetivo: <3% de batería en 8 horas

## 📱 Testing en Dispositivo Real

Una vez completados los pasos críticos:

1. **Instalar en dispositivo físico**:
   ```bash
   flutter run --release
   ```

2. **Escenarios de testing**:
   - [ ] Bloquear pantalla 1 hora → Verificar Esencia generada
   - [ ] Caminar 2000 pasos → Verificar canalización de Orbe
   - [ ] Cambiar hora del sistema → Verificar que no genera Esencia extra
   - [ ] Reiniciar dispositivo → Verificar que no se pierden puntos
   - [ ] Dejar app en background 12+ horas → Verificar límite
   - [ ] Consumo de batería en 24h

3. **Verificar**:
   - [ ] Widget se actualiza correctamente
   - [ ] Notificación persiste en lockscreen
   - [ ] App no crashea
   - [ ] Performance es fluida

## 🚀 Preparación para Google Play Store

Cuando el MVP esté estable:

### Requisitos previos:
- [ ] Crear cuenta de desarrollador Google Play ($25 one-time)
- [ ] Política de privacidad (aunque no recopiles datos externos)
- [ ] Capturas de pantalla (mínimo 2)
- [ ] Ícono de la app (512x512 PNG)
- [ ] Feature graphic (1024x500)

### Build de producción:
```bash
flutter build appbundle --release
```

### Checklist de publicación:
- [ ] Probar APK en múltiples dispositivos
- [ ] Verificar que app pesa <50 MB
- [ ] Descripción clara de permisos en listing
- [ ] Rating: Everyone (contenido apropiado para todos)
- [ ] Categoría: Health & Fitness o Casual Games

## 📚 Recursos Útiles

- **Flutter Docs**: https://docs.flutter.dev/
- **Android Sensors**: https://developer.android.com/guide/topics/sensors/sensors_motion
- **Foreground Services**: https://developer.android.com/guide/components/foreground-services
- **SQLite en Android**: https://developer.android.com/training/data-storage/sqlite
- **Google Play Policies**: https://play.google.com/console/about/guides/

## 🎯 Orden Recomendado de Implementación

1. ✅ Estructura del proyecto (COMPLETADO)
2. **Servicios nativos Android** ← EMPEZAR AQUÍ
3. **Integración Flutter-Android**
4. **Conectar UI con services**
5. Navegación
6. Inicialización de BD
7. Testing básico
8. Widget y notificaciones
9. Refinamientos
10. PublicaciónDirecta en Play Store

---

**Estimación de tiempo**:
- Servicios nativos: 2-3 días
- Integración y UI: 1-2 días
- Testing y refinamiento: 1-2 días
- **Total MVP funcional: ~1 semana**

**Siguiente paso inmediato**: Implementar `ScreenLockTracker.kt` como Foreground Service.
