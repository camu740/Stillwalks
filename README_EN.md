# 🌿 Stillwalks — Digital Wellbeing Idle Game

<p align="center">
  <img src="assets/ui/stillwalks-logo.png" alt="Stillwalks Logo" width="180"/>
</p>

<p align="center">
  <strong>Disconnect from your phone. Walk. Discover mystical creatures.</strong>
</p>

<p align="center">
  <a href="README.md">🇪🇸 Versión en Español</a>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.38+-02569B?logo=flutter" alt="Flutter"/>
  <img src="https://img.shields.io/badge/Dart-3.10+-0175C2?logo=dart" alt="Dart"/>
  <img src="https://img.shields.io/badge/Platform-Android-3DDC84?logo=android" alt="Android"/>
  <img src="https://img.shields.io/badge/Status-MVP-orange" alt="Status"/>
  <img src="https://img.shields.io/badge/License-GPL%20v3-blue" alt="License"/>
</p>

---

## 📖 Table of Contents

- [Overview](#-overview)
- [Try the App (Non-Developers)](#-try-the-app-non-developers)
- [Tech Stack](#-tech-stack)
- [Prerequisites](#-prerequisites)
- [Installation & Running](#-installation--running)
- [Project Structure](#-project-structure)
- [Main Features](#-main-features)
- [Game Terminology](#-game-terminology)
- [Available Creatures](#-available-creatures)
- [Progression System](#-progression-system)
- [Android Permissions](#-android-permissions)
- [Useful Commands](#-useful-commands)
- [Project Status & Future Ideas](#-project-status--future-ideas)
- [License](#-license)
- [Author](#-author)

---

## 🌟 Overview

**Stillwalks** is an Android mobile application that combines **idle/incremental game** mechanics with the promotion of **digital wellbeing** and **physical activity**.

### How does it work?

The concept is simple and serves a dual purpose:

1. **Digital Wellbeing**: Players earn **Essence** (the in-game currency) by keeping their phone **locked**. The longer you stay away from your phone, the more Essence you accumulate.
2. **Physical Activity**: With that Essence, players buy **Orbs** that are placed inside **Sanctuaries**. For an Orb to hatch and reveal a creature (**Stillwalk**), the player must **walk** a certain number of real-world steps.

### The Game Loop

```
🔒 Lock your phone → 💎 Earn Essence → 🔮 Buy Orbs → 🏛️ Place them in Sanctuaries
     → 🚶 Walk → ✨ Channel the Orb → 🐾 Discover a Stillwalk → 📖 Complete your Journal
```

The ultimate goal is to complete the **Explorer's Journal** by discovering all available creatures, while encouraging a healthier relationship with your phone and an active lifestyle.

---

## 📱 Try the App (Non-Developers)

If you just want to try Stillwalks without building anything:

1. Download the latest `.apk` file from the [Releases](../../releases) section of this repository (or request it from the author).
2. Transfer the `.apk` to your Android device.
3. Open the file on your device. You may need to enable **"Install from unknown sources"** in your Android security settings.
4. Once installed, open the app and follow the built-in tutorial.

> **Note:** Android 8.0 (Oreo) or higher is required.

---

## 🛠️ Tech Stack

| Technology | Purpose | Version |
|---|---|---|
| **Flutter** | Cross-platform UI framework | 3.38+ |
| **Dart** | Primary programming language | 3.10+ |
| **Kotlin** | Native Android code (background services) | — |
| **SQLite** (sqflite) | Local database for game persistence | 2.3+ |
| **Provider** | Reactive state management | 6.1+ |
| **Pedometer** | Step counting via device sensors | 4.0+ |
| **Health Connect** | Google Fit / Health Connect integration | 13.3+ |
| **SharedPreferences** | User preferences storage | 2.2+ |
| **home_widget** | Native Android home screen widget | 0.9+ |
| **flutter_native_splash** | Native splash screen on app launch | 2.3+ |
| **flutter_launcher_icons** | Automatic app icon generation | 0.13+ |
| **package_info_plus** | Package info reading (version, etc.) | 8.0+ |
| **intl** | Internationalization (i18n) and data formatting | — |

### Architecture

The app follows a **service-based architecture** with state management using **Provider**:

```
┌────────────────────────────────┐
│          Screens (UI)          │  ← User-facing screens
├────────────────────────────────┤
│          Providers             │  ← State management (Provider)
├────────────────────────────────┤
│          Services              │  ← Business logic
├────────────────────────────────┤
│          Models                │  ← Data models
├────────────────────────────────┤
│      Data (SQLite + Seeds)     │  ← Persistence layer
├────────────────────────────────┤
│    Native Code (Kotlin)        │  ← Android services (steps, lock tracking)
└────────────────────────────────┘
```

---

## 📋 Prerequisites

Before you can build and run the project, you need to install the following tools:

### 1. Flutter SDK (v3.38 or higher)

1. **Download Flutter**:
   - Visit the official guide: [https://docs.flutter.dev/get-started/install](https://docs.flutter.dev/get-started/install)
   - Select your operating system and follow the instructions.
   - Download and extract the Flutter SDK to a folder (e.g., `C:\src\flutter` on Windows).

2. **Add Flutter to your system PATH**:
   - **Windows**: Search for "Environment Variables" in the Start menu → Edit the `Path` user variable → Add `<your_path>\flutter\bin`.
   - **macOS/Linux**: Add `export PATH="$PATH:<your_path>/flutter/bin"` to your `~/.bashrc`, `~/.zshrc`, or equivalent.

3. **Verify the installation**:
   ```bash
   flutter doctor
   ```
   This command will tell you if any component is missing.

### 2. Android Studio

1. Download and install [Android Studio](https://developer.android.com/studio).
2. During installation, make sure to include:
   - **Android SDK** (API 26 or higher)
   - **Android SDK Platform-Tools**
   - **Android SDK Build-Tools**
   - **Android Emulator** (optional, for testing without a physical device)
3. Accept Android licenses:
   ```bash
   flutter doctor --android-licenses
   ```

### 3. Device or Emulator

- **Physical device**: Connect your Android device via USB and enable **USB Debugging** in Developer Options.
- **Emulator**: Create a virtual device from Android Studio (AVD Manager) with API 26+.

> **Note:** Some native features (step counting, screen lock tracking) only work correctly on a **physical device**.

---

## 🚀 Installation & Running

Once Flutter and Android Studio are set up:

```bash
# 1. Clone the repository
git clone <repository-url>
cd stillwalks

# 2. Get project dependencies
flutter pub get

# 3. Run on a connected Android device or emulator
flutter run

# 4. (Optional) Build a debug APK for manual installation
flutter build apk --debug
```

The generated APK will be located at `build/app/outputs/flutter-apk/app-debug.apk`.

### Troubleshooting

| Issue | Solution |
|---|---|
| `flutter doctor` shows errors | Follow the instructions provided by the command itself to resolve each point |
| Android license errors | Run `flutter doctor --android-licenses` and accept all |
| Device not detected | Verify USB Debugging is enabled and drivers are installed |
| Kotlin build errors | Make sure Java 17 is configured in Android Studio |

---

## 📁 Project Structure

```
stillwalks/
│
├── android/                            # Native Android code
│   └── app/src/main/kotlin/
│       └── com/stillwalks/app/
│           ├── MainActivity.kt             # Main Activity + Method Channel
│           ├── ScreenLockTracker.kt         # Screen lock/unlock detection
│           ├── StepCounterService.kt        # Background step counting service
│           ├── TrackingForegroundService.kt  # Foreground service for persistent tracking
│           ├── StillwalksWidget.kt          # Native home screen widget
│           ├── StillwalksNotificationManager.kt # Native notification management
│           ├── NotificationChannels.kt      # Notification channel definitions
│           ├── BootReceiver.kt              # Auto-restart services after device reboot
│           └── WalkReminderWorker.kt        # Periodic walk reminders
│
├── lib/                                # Flutter (Dart) code
│   ├── main.dart                           # Application entry point
│   │
│   ├── models/                             # Data models
│   │   ├── player_state.dart                   # Global player state (essence, XP, level, etc.)
│   │   ├── upgrade.dart                        # Purchasable upgrades (7 types defined)
│   │   ├── building.dart                       # Essence-generating buildings (5 types)
│   │   ├── orbe.dart                           # Orbs (types and instances)
│   │   ├── sanctuary.dart                      # Sanctuaries (permanent and temporary)
│   │   ├── creature_species.dart               # Stillwalk species (static data)
│   │   ├── creature_instance.dart              # Discovered creature instances
│   │   ├── inventory_item.dart                 # Inventory items (bag)
│   │   └── notification_settings.dart          # Notification settings
│   │
│   ├── services/                           # Business logic
│   │   ├── esencia_service.dart                # Essence generation, purchases, XP, leveling
│   │   ├── orbe_service.dart                   # Orb management, sanctuaries, channeling
│   │   ├── progression_service.dart            # Level system, unlocks, upgrade caps
│   │   ├── collection_service.dart             # Creature collection management
│   │   ├── step_aggregator_service.dart        # Step aggregation from multiple sources
│   │   ├── google_fit_service.dart             # Google Fit / Health Connect integration
│   │   ├── native_bridge.dart                  # Flutter ↔ Kotlin communication (Method Channel)
│   │   ├── hatching_service.dart               # Orb hatching logic
│   │   ├── tutorial_service.dart               # Initial tutorial management
│   │   ├── widget_service.dart                 # Home screen widget synchronization
│   │   ├── active_time_tracker.dart            # Active app time tracking
│   │   ├── permission_service.dart             # System permission management
│   │   ├── notification_guard_service.dart     # Notification frequency control
│   │   └── notification_preferences_service.dart # Notification preferences
│   │
│   ├── screens/                            # UI screens
│   │   ├── home_screen.dart                    # Main screen (essence, tap, sanctuaries)
│   │   ├── shop_screen.dart                    # Shop (orbs, upgrades, buildings)
│   │   ├── channeling_screen.dart              # Orb channeling animation
│   │   ├── explorer_journal_screen.dart        # Explorer's Journal (collection)
│   │   ├── sanctuary_screen.dart               # Detailed sanctuary management
│   │   ├── inventory_screen.dart               # Player inventory / Bag
│   │   ├── settings_screen.dart                # Settings screen
│   │   ├── help_screen.dart                    # In-game help guide
│   │   ├── credits_screen.dart                 # Project credits
│   │   ├── sensors_screen.dart                 # Sensor diagnostics
│   │   ├── tracking_status_screen.dart         # Background tracking status
│   │   ├── permissions_screen.dart             # Initial permission requests
│   │   ├── permissions_status_screen.dart      # Granted permissions status
│   │   ├── google_fit_screen.dart              # Google Fit configuration
│   │   ├── language_selection_screen.dart       # Language selection
│   │   └── widgets/                            # Reusable sub-widgets
│   │       ├── sanctuary_slot_widgets.dart          # Sanctuary slot UI
│   │       ├── tutorial_manager.dart                # Tutorial flow manager
│   │       ├── tutorial_overlay.dart                # Visual tutorial overlay
│   │       ├── floating_essence_text.dart           # Floating essence earned text
│   │       ├── random_essence_orb.dart              # Random essence orb event
│   │       ├── level_up_dialog.dart                 # Level up dialog
│   │       ├── shop_shortcut_button.dart            # Shop quick access button
│   │       └── shortcut_button.dart                 # Generic shortcut button
│   │
│   ├── data/                               # Data layer
│   │   ├── database/
│   │   │   └── database_helper.dart            # SQLite helper (table creation, CRUD)
│   │   └── seeds/
│   │       └── initial_data.dart               # Initial game data (creatures, orbs, upgrades)
│   │
│   ├── l10n/                               # Internationalization
│   │   ├── app_es.arb                          # Spanish translations (primary language)
│   │   ├── app_en.arb                          # English translations
│   │   ├── app_localizations.dart              # Auto-generated localization class
│   │   ├── app_localizations_es.dart           # Generated localization (ES)
│   │   ├── app_localizations_en.dart           # Generated localization (EN)
│   │   └── data_localizations.dart             # Dynamic game data translations
│   │
│   ├── providers/                          # State providers
│   │   └── locale_provider.dart                # Locale provider for language switching
│   │
│   └── widgets/                            # Global widgets
│       └── tutorial_dialog.dart                # Tutorial dialog
│
├── assets/                             # Graphic resources
│   ├── creatures/                          # Creature sprites (PNG)
│   ├── ui/                                 # UI elements (logo)
│   └── animations/                         # (Reserved for future animations)
│
├── documentation/                      # Internal design documentation
├── test/                               # Tests
├── pubspec.yaml                        # Project dependencies and configuration
├── l10n.yaml                           # Internationalization configuration
├── analysis_options.yaml               # Dart static analysis rules
├── Makefile                            # Build and run shortcuts
├── README.md                           # Documentación en español
└── README_EN.md                        # This file (English documentation)
```

---

## ⚙️ Main Features

### 1. 💎 Essence System (In-Game Currency)

- **Passive generation**: Accumulates automatically while the phone is locked, via native Kotlin tracking (`ScreenLockTracker`).
- **Active generation (Tap)**: Players can tap the main screen to manually generate essence, with a configurable cooldown.
- **Generator buildings**: Buildings can be purchased (Collector, Mine, Quarry, Deposit, Factory) that generate essence continuously.
- **Offline cap**: Maximum 12 hours of essence accumulation while offline (scales with explorer level).
- **Essence Rain**: Special event triggered when reaching certain milestones.

### 2. 🔮 Orb & Channeling System

- **Orb Types**: Three tiers available:
  - **Basic Orb** (2,000 steps) — Mostly common creatures.
  - **Advanced Orb** (5,000 steps) — Higher chance for uncommon and rare creatures.
  - **Expert Orb** (10,000 steps) — Higher chance for rare, epic, and mythic creatures.
- **Orb Bag**: Purchased orbs are stored in a bag before being assigned to a sanctuary.
- **Channeling**: When an orb completes the required steps, the player can "channel" it to reveal the creature, with a dedicated animation.

### 3. 🏛️ Sanctuary System

- **Permanent Sanctuary** (Primordial Sanctuary): Included from the start, its speed can be upgraded (up to 12 levels, reducing required steps by up to 24%).
- **Temporary Sanctuaries**: Purchased from the shop with limited uses and special effects:
  - *Fast Flow*: -10% required steps.
  - *Symbiosis*: +1 Essence every 10 steps taken.
  - *Absolute Quietude*: Allows hatching with Essence instead of steps.

### 4. 👣 Step Tracking

- **Native sensor**: Step counting through the device's hardware pedometer, managed by `StepCounterService` in Kotlin.
- **Background tracking**: Foreground service that keeps counting active even with the app closed.
- **Google Fit / Health Connect**: Optional integration to sync steps from Health Connect (Android 14+).
- **Step storage**: Steps accumulate in a "battery" and are consumed to progress active orbs in sanctuaries.

### 5. 📖 Explorer's Journal (Collection)

- Visual registry of all discovered creatures.
- Undiscovered creatures appear as silhouettes.
- Each creature has a name, description, rarity, and Dex number.

### 6. 🛒 Shop & Upgrades

Available upgrades include:

| Upgrade | Description | Max Level |
|---|---|---|
| Essence Collector | Increases passive generation speed | 12 |
| Energy Storage | Increases storable step capacity | 12 |
| Tap Strength | Increases essence earned per tap | 30 |
| Inner Rhythm | Reduces cooldown between taps | 5 |
| Essence Flow | Global essence multiplier | 20 |
| Persistent Echo | Improves offline essence efficiency | 15 |
| Persistent Memory | Increases max offline accumulation time | 15 |

Additionally, **buildings** with automatic essence production can be purchased:

| Building | Base Production | Base Cost |
|---|---|---|
| Collector | 0.1/s | 100 |
| Mine | 0.5/s | 750 |
| Quarry | 2.0/s | 4,000 |
| Deposit | 7.5/s | 15,000 |
| Factory | 25.0/s | 75,000 |

### 7. 📊 Progression System (Explorer Level)

- Level system based on **XP** earned through in-game actions (purchasing upgrades, channeling orbs, etc.).
- Each level unlocks new upgrades, buildings, orb types, and increases existing upgrade caps.
- Progression controls what content is available in the shop.

### 8. 🌐 Internationalization (i18n)

- Full support for **Spanish** 🇪🇸 and **English** 🇬🇧.
- Language switching from the app settings.
- Implemented using Flutter's official system (`flutter_localizations` + `.arb` files).

### 9. 📱 Home Screen Widget

- Native Android widget displaying game information directly on the home screen.
- Updates every 15 minutes.

### 10. 🔔 Notification System

- Configurable notifications for essence milestones, orbs ready to channel, and walk reminders.
- Frequency control system to prevent excessive notifications.

### 11. 🎓 Interactive Tutorial

- Step-by-step tutorial for new players guiding them through the main mechanics.
- Visual overlay with pointers on UI elements.

---

## 📝 Game Terminology

The game uses its own terminology inspired by a mystical theme. It's important to use it consistently:

| Game Term | Conceptual Equivalent | Description |
|---|---|---|
| **Essence** | Currency/Resource | Main currency, earned by keeping your phone locked |
| **Orbs** | "Eggs" | Contain creatures, require steps to hatch |
| **Sanctuaries** | "Incubators" | Where Orbs are placed for development |
| **Channeling** | "Hatching" | The process of completing an Orb and revealing the creature |
| **Stillwalks** | Creatures | The collectible creatures |
| **Explorer's Journal** | Pokédex / Collection | Registry of all discovered creatures |
| **Buildings** | Generators | Structures that automatically produce essence |

---

## 🐾 Available Creatures

| # | Name | Rarity | Probability (Basic Orb) |
|---|---|---|---|
| 1 | **Yedrantía** | Common | 43% |
| 2 | **Trasgüeco** | Common | 43% |
| 3 | **Harijaun** | Uncommon | 11% |
| 4 | **Lierpes** | Epic | 1% |
| 5 | **Velanta** | Rare | 2% |
| 0 | **Gamusarra** | Mythic | — (Advanced/Expert Orbs only) |

> All creatures are inspired by Iberian mythology and folklore.

---

## 📈 Progression System

Players level up through **XP** earned from various in-game actions. Each level unlocks new content:

- **New buildings and orb types** unlock as the player levels up.
- **Upgrade caps** increase with the explorer level, controlled by `ProgressionService`.
- **Temporary sanctuaries** unlock at specific levels.

For more details on the economy and progression, check the `/documentation/` folder, particularly:
- `ECONOMY_PROGRESSION.md` — Detailed economic design.
- `unlocks_and_costs.md` — Full table of unlocks and costs per level.
- `PROGRESION_NIVELES.txt` — Level definitions and XP requirements.

---

## 🔐 Android Permissions

The app requires the following permissions, all justified by game features:

| Permission | Reason |
|---|---|
| `ACTIVITY_RECOGNITION` | Step counting through the device sensor |
| `FOREGROUND_SERVICE` / `FOREGROUND_SERVICE_HEALTH` | Background service for continuous tracking |
| `WAKE_LOCK` | Keep services active during device sleep |
| `RECEIVE_BOOT_COMPLETED` | Auto-restart services after device reboot |
| `POST_NOTIFICATIONS` | Send game notifications to the player |
| `health.READ_STEPS` / `health.WRITE_STEPS` | Optional Google Fit / Health Connect integration |

---

## 💻 Useful Commands

```bash
# Get/update dependencies
flutter pub get

# Run in debug mode
flutter run

# Build debug APK
flutter build apk --debug

# Build release APK
flutter build apk --release

# Run tests
flutter test

# Lint analysis
flutter analyze

# Format code
dart format .

# Clean build
flutter clean
```

---

## 🔮 Project Status & Future Ideas

### Current Status: Functional MVP ✅

The project is at its **first functional MVP stage**. The APK is fully playable from start to finish and serves to validate the core game concept. All main mechanics are implemented and working.

### Future Ideas

- [ ] **iOS migration** (minimizing native Kotlin dependencies).
- [ ] More creatures and orb types.
- [ ] Temporary events and weekly challenges.
- [ ] More variety of temporary sanctuaries.
- [ ] Enhanced channeling animations.
- [ ] Achievement system.
- [ ] Dark mode / visual themes.
- [ ] **Google Play Store** publication.
- [ ] More extensive unit and integration tests.

---

## 📄 License

This project uses a **dual license**:

- **Source code**: Licensed under the [GNU General Public License v3.0 (GPL-3.0)](LICENSE). You can use, modify, and distribute the code as long as you maintain the same license and comply with GPL obligations.

- **Graphic assets** (creature images, logo, UI): The images included in the `assets/` folder have been **generated with Artificial Intelligence** and are distributed under the [Creative Commons Attribution-NonCommercial 4.0 International (CC BY-NC 4.0)](https://creativecommons.org/licenses/by-nc/4.0/) license. This means you can share and adapt these resources as long as credit is given to the author and they are **not used for commercial purposes**.

---

## 👤 Author

**Adrián Cámara Muñoz**

---

<p align="center">
  <i>Stillwalks — Disconnect. Walk. Discover. 🌿</i>
</p>
