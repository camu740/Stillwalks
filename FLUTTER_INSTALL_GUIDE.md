# Guía de Instalación de Flutter para Stillwalks

Esta guía te ayudará a configurar Flutter en Windows para poder desarrollar y ejecutar el proyecto Stillwalks.

## 📋 Requisitos Previos

- Windows 10/11 (64-bit)
- Memoria RAM: Mínimo 8 GB (recomendado 16 GB)
- Espacio en disco: ~15 GB para Flutter SDK + Android Studio + emulador
- Conexión a internet estable

## 🔧 Paso 1: Instalar Flutter SDK

### Descargar Flutter

1. Ve a la página oficial de Flutter: https://docs.flutter.dev/get-started/install/windows
2. Descarga el archivo `flutter_windows_X.X.X-stable.zip` (última versión estable)
3. Extrae el archivo en una ubicación permanente, **NO lo pongas en `C:\Program Files`**
   - Ubicación recomendada: `C:\src\flutter`
   - Evita rutas con espacios o caracteres especiales

### Añadir Flutter al PATH

1. Busca "Editar las variables de entorno del sistema" en el menú de Windows
2. Haz clic en el botón "Variables de entorno..."
3. En "Variables del sistema", busca `Path` y haz clic en "Editar"
4. Haz clic en "Nuevo" y añade la ruta: `C:\src\flutter\bin` (ajusta según donde hayas extraído Flutter)
5. Haz clic en "Aceptar" en todas las ventanas

### Verificar la instalación

Abre una **nueva** ventana de PowerShell o CMD y ejecuta:

```powershell
flutter --version
```

Deberías ver algo como:

```
Flutter 3.16.x • channel stable
```

## 🛠️ Paso 2: Instalar Android Studio

Flutter necesita Android Studio para compilar aplicaciones Android.

### Descarga e instalación

1. Descarga Android Studio desde: https://developer.android.com/studio
2. Ejecuta el instalador
3. Durante la instalación, asegúrate de seleccionar:
   - ✅ Android SDK
   - ✅ Android SDK Platform-Tools
   - ✅ Android SDK Build-Tools
   - ✅ Android Virtual Device (si quieres usar emulador)

### Configuración inicial

1. Abre Android Studio
2. Sigue el asistente de configuración inicial
3. Cuando te pregunte sobre el SDK, acepta la ubicación predeterminada (suele ser`C:\Users\TU_USUARIO\AppData\Local\Android\Sdk`)

### Instalar complementos de Flutter

1. En Android Studio, ve a `File` → `Settings` → `Plugins`
2. Busca "Flutter" e instala el plugin
3. También se instalará automáticamente el plugin de "Dart"
4. Reinicia Android Studio

## ⚙️ Paso 3: Configurar Android SDK

### Aceptar licencias

Abre PowerShell/CMD y ejecuta:

```powershell
flutter doctor --android-licenses
```

Presiona `y` (yes) para aceptar todas las licencias.

### Verificar configuración

```powershell
flutter doctor
```

Deberías ver algo como:

```
Doctor summary (to see all details, run flutter doctor -v):
[✓] Flutter (Channel stable, 3.16.x, on Microsoft Windows)
[✓] Android toolchain - develop for Android devices (Android SDK version 34.0.0)
[✓] Visual Studio - develop Windows apps (Visual Studio Community 2022)
[✓] Android Studio (version 2023.x)
[✓] Connected device (1 available)
[✓] Network resources
```

> **Nota**: Es normal que algunas checks aparezcan con `[!]` si no tienes Xcode (solo Mac) o Chrome instalado. No son necesarios para desarrollo Android básico.

## 📱 Paso 4: Configurar un Dispositivo

Tienes dos opciones: usar un emulador o un dispositivo físico.

### Opción A: Emulador Android (Recomendado para testing)

1. Abre Android Studio
2. Ve a `Tools` → `Device Manager`
3. Haz clic en "Create Device"
4. Selecciona un dispositivo (por ejemplo, Pixel 6)
5. Selecciona una imagen del sistema (recomendado: Android 13 - API 33 con Google APIs)
6. Descarga la imagen si es necesario
7. Finaliza la creación y lanza el emulador

### Opción B: Dispositivo Físico Android

1. **En tu teléfono Android**:
   - Ve a `Ajustes` → `Acerca del teléfono`
   - Toca 7 veces en "Número de compilación" para activar opciones de desarrollador
   - Ve a `Ajustes` → `Sistema` → `Opciones de desarrollador`
   - Activa "Depuración USB"

2. **Conecta tu teléfono al PC** con un cable USB

3. **Acepta la depuración USB** en el teléfono cuando aparezca el mensaje

4. **Verifica la conexión**:
   ```powershell
   flutter devices
   ```

## 🚀 Paso 5: Ejecutar Stillwalks

### Configurar dependencias

1. Abre PowerShell/CMD en la carpeta del proyecto:
   ```powershell
   cd c:\Users\adria\.gemini\antigravity\scratch\stillwalks
   ```

2. Obtén las dependencias de Flutter:
   ```powershell
   flutter pub get
   ```

### Ejecutar el proyecto

Con el emulador abierto o el dispositivo conectado:

```powershell
flutter run
```

La primera compilación puede tardar varios minutos. Las siguientes serán más rápidas gracias a la compilación incremental.

### Modo debug vs release

- **Debug** (predeterminado): Permite hot reload, debugging, pero es más lento
  ```powershell
  flutter run
  ```

- **Release** (para testinglast de rendimiento):
  ```powershell
  flutter run --release
  ```

## 🔥 Hot Reload durante desarrollo

Mientras la app está corriendo en modo debug:

- Presiona `r` en la terminal para hacer **hot reload** (actualización rápida)
- Presiona `R` para hacer **hot restart** (reinicio completo)
- Presiona `q` para salir

## 🐛 Solución de Problemas Comunes

### "flutter no se reconoce como comando"

- Asegúrate de haber añadido `C:\src\flutter\bin` al PATH
- Cierra y abre una **nueva** ventana de terminal

###  "Android license status unknown"

```powershell
flutter doctor --android-licenses
```

### Error "Gradle build failed"

1. Asegúrate de tener conexión a internet (Gradle descarga dependencias)
2. Intenta limpiar el proyecto:
   ```powershell
   flutter clean
   flutter pub get
   ```

### El emulador va muy lento

- Asegúrate de tener habilitada la aceleración de hardware (HAXM/WHPX)
- Usa un dispositivo físico para mejor rendimiento

### "Unable to locate Android SDK"

1. Ve a Android Studio → `File` → `Settings` → `Appearance & Behavior` → `System Settings` → `Android SDK`
2. Copia la ruta del SDK
3. Establece la variable de entorno `ANDROID_HOME`:
   - En "Variables del sistema", clic en "Nueva"
   - Nombre: `ANDROID_HOME`
   - Valor: (la ruta que copiaste, ej: `C:\Users\TU_USUARIO\AppData\Local\Android\Sdk`)

## ✅ ¡Listo!

Una vez completados estos pasos, deberías poder ejecutar Stillwalks en tu dispositivo/emulador.

### Recursos adicionales

- Documentación oficial de Flutter: https://docs.flutter.dev/
- Guía de solución de problemas: https://docs.flutter.dev/get-started/install/windows#troubleshooting
- Discord de Flutter (comunidad): https://discord.gg/flutter

### Próximos pasos del desarrollo

1. Implementar los servicios nativos Android (Kotlin)
2. Conectar la UI con los servicios de datos
3. Testing en dispositivo físico
4. Optimización de batería

---

**Nota**: Esta guía asume que ya tienes el código del proyecto en `c:\Users\adria\.gemini\antigravity\scratch\stillwalks`. Si encuentras problemas, revisa el archivo `README.md` del proyecto para información adicional.
