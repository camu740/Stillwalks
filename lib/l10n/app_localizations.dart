import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es')
  ];

  /// Application title
  ///
  /// In es, this message translates to:
  /// **'Stillwalks'**
  String get appTitle;

  /// No description provided for @settings.
  ///
  /// In es, this message translates to:
  /// **'Ajustes'**
  String get settings;

  /// No description provided for @general.
  ///
  /// In es, this message translates to:
  /// **'GENERAL'**
  String get general;

  /// No description provided for @notifications.
  ///
  /// In es, this message translates to:
  /// **'NOTIFICACIONES'**
  String get notifications;

  /// No description provided for @wellbeing.
  ///
  /// In es, this message translates to:
  /// **'BIENESTAR'**
  String get wellbeing;

  /// No description provided for @privacySystem.
  ///
  /// In es, this message translates to:
  /// **'PRIVACIDAD Y SISTEMA'**
  String get privacySystem;

  /// No description provided for @information.
  ///
  /// In es, this message translates to:
  /// **'INFORMACIÓN'**
  String get information;

  /// No description provided for @language.
  ///
  /// In es, this message translates to:
  /// **'Idioma'**
  String get language;

  /// No description provided for @spanish.
  ///
  /// In es, this message translates to:
  /// **'Español'**
  String get spanish;

  /// No description provided for @english.
  ///
  /// In es, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @system.
  ///
  /// In es, this message translates to:
  /// **'Sistema'**
  String get system;

  /// No description provided for @selectLanguage.
  ///
  /// In es, this message translates to:
  /// **'Seleccionar Idioma'**
  String get selectLanguage;

  /// No description provided for @soundVibration.
  ///
  /// In es, this message translates to:
  /// **'Sonido / vibración'**
  String get soundVibration;

  /// No description provided for @soundVibrationDesc.
  ///
  /// In es, this message translates to:
  /// **'Feedback sonoro y háptico'**
  String get soundVibrationDesc;

  /// No description provided for @batterySaver.
  ///
  /// In es, this message translates to:
  /// **'Modo ahorro batería'**
  String get batterySaver;

  /// No description provided for @batterySaverDesc.
  ///
  /// In es, this message translates to:
  /// **'Reduce el consumo de batería'**
  String get batterySaverDesc;

  /// No description provided for @permanent.
  ///
  /// In es, this message translates to:
  /// **'Permanente'**
  String get permanent;

  /// No description provided for @permanentDesc.
  ///
  /// In es, this message translates to:
  /// **'Tracking activo en segundo plano'**
  String get permanentDesc;

  /// No description provided for @events.
  ///
  /// In es, this message translates to:
  /// **'Eventos'**
  String get events;

  /// No description provided for @eventsDesc.
  ///
  /// In es, this message translates to:
  /// **'Orbes e hitos de esencia'**
  String get eventsDesc;

  /// No description provided for @reminders.
  ///
  /// In es, this message translates to:
  /// **'Recordatorios'**
  String get reminders;

  /// No description provided for @remindersDesc.
  ///
  /// In es, this message translates to:
  /// **'Invitaciones a caminar'**
  String get remindersDesc;

  /// No description provided for @disabledInBatterySaver.
  ///
  /// In es, this message translates to:
  /// **'Desactivado en modo ahorro'**
  String get disabledInBatterySaver;

  /// No description provided for @pauseProgress.
  ///
  /// In es, this message translates to:
  /// **'Pausar progreso'**
  String get pauseProgress;

  /// No description provided for @pauseProgressDesc.
  ///
  /// In es, this message translates to:
  /// **'Detiene temporalmente el tracking'**
  String get pauseProgressDesc;

  /// No description provided for @doNotDisturb.
  ///
  /// In es, this message translates to:
  /// **'Horas no molestar'**
  String get doNotDisturb;

  /// No description provided for @configure.
  ///
  /// In es, this message translates to:
  /// **'Configurar'**
  String get configure;

  /// No description provided for @dndTimeRange.
  ///
  /// In es, this message translates to:
  /// **'{start} - {end}'**
  String dndTimeRange(String start, String end);

  /// No description provided for @dndStartTime.
  ///
  /// In es, this message translates to:
  /// **'HORA DE INICIO'**
  String get dndStartTime;

  /// No description provided for @dndEndTime.
  ///
  /// In es, this message translates to:
  /// **'HORA DE FIN'**
  String get dndEndTime;

  /// No description provided for @dailyGoal.
  ///
  /// In es, this message translates to:
  /// **'Objetivo diario'**
  String get dailyGoal;

  /// No description provided for @dailyGoalSteps.
  ///
  /// In es, this message translates to:
  /// **'{count} pasos'**
  String dailyGoalSteps(int count);

  /// No description provided for @selectDailyGoal.
  ///
  /// In es, this message translates to:
  /// **'Objetivo Diario'**
  String get selectDailyGoal;

  /// No description provided for @permissions.
  ///
  /// In es, this message translates to:
  /// **'Permisos'**
  String get permissions;

  /// No description provided for @permissionsDesc.
  ///
  /// In es, this message translates to:
  /// **'Gestionar accesos de la app'**
  String get permissionsDesc;

  /// No description provided for @sensors.
  ///
  /// In es, this message translates to:
  /// **'Sensores'**
  String get sensors;

  /// No description provided for @sensorsDesc.
  ///
  /// In es, this message translates to:
  /// **'Estado del podómetro'**
  String get sensorsDesc;

  /// No description provided for @trackingStatus.
  ///
  /// In es, this message translates to:
  /// **'Estado de seguimiento'**
  String get trackingStatus;

  /// No description provided for @trackingStatusDesc.
  ///
  /// In es, this message translates to:
  /// **'Resumen del sistema'**
  String get trackingStatusDesc;

  /// No description provided for @help.
  ///
  /// In es, this message translates to:
  /// **'Ayuda'**
  String get help;

  /// No description provided for @contact.
  ///
  /// In es, this message translates to:
  /// **'Contacto'**
  String get contact;

  /// No description provided for @credits.
  ///
  /// In es, this message translates to:
  /// **'Créditos'**
  String get credits;

  /// No description provided for @version.
  ///
  /// In es, this message translates to:
  /// **'Versión v{version}'**
  String version(String version);

  /// No description provided for @essence.
  ///
  /// In es, this message translates to:
  /// **'Esencia'**
  String get essence;

  /// No description provided for @orbs.
  ///
  /// In es, this message translates to:
  /// **'Orbes'**
  String get orbs;

  /// No description provided for @sanctuary.
  ///
  /// In es, this message translates to:
  /// **'Santuario'**
  String get sanctuary;

  /// No description provided for @collection.
  ///
  /// In es, this message translates to:
  /// **'Colección'**
  String get collection;

  /// No description provided for @shop.
  ///
  /// In es, this message translates to:
  /// **'Tienda'**
  String get shop;

  /// No description provided for @freeSlot.
  ///
  /// In es, this message translates to:
  /// **'Ranura libre'**
  String get freeSlot;

  /// No description provided for @activeOrb.
  ///
  /// In es, this message translates to:
  /// **'Orbe activo'**
  String get activeOrb;

  /// No description provided for @readyToChannel.
  ///
  /// In es, this message translates to:
  /// **'¡Listo para canalizar!'**
  String get readyToChannel;

  /// No description provided for @channel.
  ///
  /// In es, this message translates to:
  /// **'Canalizar'**
  String get channel;

  /// No description provided for @channeling.
  ///
  /// In es, this message translates to:
  /// **'Canalizando...'**
  String get channeling;

  /// No description provided for @selectOrb.
  ///
  /// In es, this message translates to:
  /// **'Seleccionar Orbe'**
  String get selectOrb;

  /// No description provided for @cancel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In es, this message translates to:
  /// **'Confirmar'**
  String get confirm;

  /// No description provided for @progressSteps.
  ///
  /// In es, this message translates to:
  /// **'{current}/{total} pasos'**
  String progressSteps(int current, int total);

  /// No description provided for @progressEssence.
  ///
  /// In es, this message translates to:
  /// **'{current}/{total} esencia'**
  String progressEssence(int current, int total);

  /// No description provided for @creature.
  ///
  /// In es, this message translates to:
  /// **'Criatura'**
  String get creature;

  /// No description provided for @evolution.
  ///
  /// In es, this message translates to:
  /// **'Evolución'**
  String get evolution;

  /// No description provided for @basePower.
  ///
  /// In es, this message translates to:
  /// **'Poder base'**
  String get basePower;

  /// No description provided for @generation.
  ///
  /// In es, this message translates to:
  /// **'Generación'**
  String get generation;

  /// No description provided for @buy.
  ///
  /// In es, this message translates to:
  /// **'Comprar'**
  String get buy;

  /// No description provided for @cost.
  ///
  /// In es, this message translates to:
  /// **'Costo'**
  String get cost;

  /// No description provided for @owned.
  ///
  /// In es, this message translates to:
  /// **'Posees'**
  String get owned;

  /// No description provided for @upgrades.
  ///
  /// In es, this message translates to:
  /// **'Mejoras'**
  String get upgrades;

  /// No description provided for @items.
  ///
  /// In es, this message translates to:
  /// **'Objetos'**
  String get items;

  /// No description provided for @permissionsRequired.
  ///
  /// In es, this message translates to:
  /// **'Permisos Necesarios'**
  String get permissionsRequired;

  /// No description provided for @permissionsDescription.
  ///
  /// In es, this message translates to:
  /// **'Stillwalks necesita los siguientes permisos para funcionar:'**
  String get permissionsDescription;

  /// No description provided for @activityPermission.
  ///
  /// In es, this message translates to:
  /// **'Actividad física'**
  String get activityPermission;

  /// No description provided for @activityPermissionDesc.
  ///
  /// In es, this message translates to:
  /// **'Para contar pasos'**
  String get activityPermissionDesc;

  /// No description provided for @notificationPermission.
  ///
  /// In es, this message translates to:
  /// **'Notificaciones'**
  String get notificationPermission;

  /// No description provided for @notificationPermissionDesc.
  ///
  /// In es, this message translates to:
  /// **'Para mostrar progreso'**
  String get notificationPermissionDesc;

  /// No description provided for @requestPermissions.
  ///
  /// In es, this message translates to:
  /// **'Solicitar permisos'**
  String get requestPermissions;

  /// No description provided for @continueButton.
  ///
  /// In es, this message translates to:
  /// **'Continuar'**
  String get continueButton;

  /// No description provided for @welcome.
  ///
  /// In es, this message translates to:
  /// **'Bienvenido'**
  String get welcome;

  /// No description provided for @loading.
  ///
  /// In es, this message translates to:
  /// **'Cargando...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In es, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @retry.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get retry;

  /// No description provided for @close.
  ///
  /// In es, this message translates to:
  /// **'Cerrar'**
  String get close;

  /// No description provided for @save.
  ///
  /// In es, this message translates to:
  /// **'Guardar'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In es, this message translates to:
  /// **'Eliminar'**
  String get delete;

  /// No description provided for @noCreatures.
  ///
  /// In es, this message translates to:
  /// **'No hay criaturas disponibles'**
  String get noCreatures;

  /// No description provided for @noOrbs.
  ///
  /// In es, this message translates to:
  /// **'No tienes orbes activos'**
  String get noOrbs;

  /// No description provided for @notEnoughEssence.
  ///
  /// In es, this message translates to:
  /// **'No tienes suficiente esencia'**
  String get notEnoughEssence;

  /// No description provided for @orbTypes.
  ///
  /// In es, this message translates to:
  /// **'TIPOS DE ORBE'**
  String get orbTypes;

  /// No description provided for @mystical.
  ///
  /// In es, this message translates to:
  /// **'Místico'**
  String get mystical;

  /// No description provided for @primal.
  ///
  /// In es, this message translates to:
  /// **'Primigenio'**
  String get primal;

  /// No description provided for @ethereal.
  ///
  /// In es, this message translates to:
  /// **'Etéreo'**
  String get ethereal;

  /// No description provided for @sanctuarySlots.
  ///
  /// In es, this message translates to:
  /// **'Ranuras de Santuario'**
  String get sanctuarySlots;

  /// No description provided for @availableSlots.
  ///
  /// In es, this message translates to:
  /// **'{count} disponibles'**
  String availableSlots(int count);

  /// No description provided for @standardOrbs.
  ///
  /// In es, this message translates to:
  /// **'Orbes Estándar'**
  String get standardOrbs;

  /// No description provided for @specialOrbs.
  ///
  /// In es, this message translates to:
  /// **'Orbes Especiales'**
  String get specialOrbs;

  /// No description provided for @walkReminder.
  ///
  /// In es, this message translates to:
  /// **'Recordatorio para caminar'**
  String get walkReminder;

  /// No description provided for @orbReady.
  ///
  /// In es, this message translates to:
  /// **'Orbe listo'**
  String get orbReady;

  /// No description provided for @milestoneReached.
  ///
  /// In es, this message translates to:
  /// **'¡Hito alcanzado!'**
  String get milestoneReached;

  /// No description provided for @essenceGenerated.
  ///
  /// In es, this message translates to:
  /// **'Esencia generada'**
  String get essenceGenerated;

  /// No description provided for @locked.
  ///
  /// In es, this message translates to:
  /// **'Bloqueado'**
  String get locked;

  /// No description provided for @unlocked.
  ///
  /// In es, this message translates to:
  /// **'Desbloqueado'**
  String get unlocked;

  /// No description provided for @upgrade.
  ///
  /// In es, this message translates to:
  /// **'Mejorar'**
  String get upgrade;

  /// No description provided for @maxLevel.
  ///
  /// In es, this message translates to:
  /// **'Nivel máximo'**
  String get maxLevel;

  /// No description provided for @perHour.
  ///
  /// In es, this message translates to:
  /// **'/ hora'**
  String get perHour;

  /// No description provided for @level.
  ///
  /// In es, this message translates to:
  /// **'Nv.'**
  String get level;

  /// No description provided for @orbsReady.
  ///
  /// In es, this message translates to:
  /// **'¡Orbe listo para canalizar!'**
  String get orbsReady;

  /// No description provided for @noActiveOrbs.
  ///
  /// In es, this message translates to:
  /// **'Orbes activos'**
  String get noActiveOrbs;

  /// No description provided for @idleProduction.
  ///
  /// In es, this message translates to:
  /// **'Producción pasiva'**
  String get idleProduction;

  /// No description provided for @storage.
  ///
  /// In es, this message translates to:
  /// **'Almacén'**
  String get storage;

  /// No description provided for @explorerJournal.
  ///
  /// In es, this message translates to:
  /// **'Diario de Explorador'**
  String get explorerJournal;

  /// No description provided for @sanctuaries.
  ///
  /// In es, this message translates to:
  /// **'Santuarios'**
  String get sanctuaries;

  /// No description provided for @temporarySanctuaries.
  ///
  /// In es, this message translates to:
  /// **'Santuarios Temporales'**
  String get temporarySanctuaries;

  /// No description provided for @orbPurchased.
  ///
  /// In es, this message translates to:
  /// **'¡Orbe comprado! Revisa tu Bolsa.'**
  String get orbPurchased;

  /// No description provided for @sanctuaryPurchased.
  ///
  /// In es, this message translates to:
  /// **'¡Santuario comprado! Revisa tu Bolsa.'**
  String get sanctuaryPurchased;

  /// No description provided for @upgradeCompleted.
  ///
  /// In es, this message translates to:
  /// **'¡Mejora \"{name}\" realizada!'**
  String upgradeCompleted(String name);

  /// No description provided for @sanctuaryUpgraded.
  ///
  /// In es, this message translates to:
  /// **'¡Mejora de \"{name}\" a Nivel {level}!'**
  String sanctuaryUpgraded(String name, int level);

  /// No description provided for @checkBag.
  ///
  /// In es, this message translates to:
  /// **'Revisa tu Bolsa'**
  String get checkBag;

  /// No description provided for @permanentSanctuaryUpgrades.
  ///
  /// In es, this message translates to:
  /// **'Mejora de Santuario Permanente'**
  String get permanentSanctuaryUpgrades;

  /// No description provided for @globalUpgrades.
  ///
  /// In es, this message translates to:
  /// **'Mejoras Globales'**
  String get globalUpgrades;

  /// No description provided for @loadingUpgrades.
  ///
  /// In es, this message translates to:
  /// **'Cargando mejoras...'**
  String get loadingUpgrades;

  /// No description provided for @primordialSanctuaries.
  ///
  /// In es, this message translates to:
  /// **'Santuarios Primordiales'**
  String get primordialSanctuaries;

  /// No description provided for @yourBag.
  ///
  /// In es, this message translates to:
  /// **'Tu Bolsa'**
  String get yourBag;

  /// No description provided for @emptySanctuary.
  ///
  /// In es, this message translates to:
  /// **'Santuario Vacío'**
  String get emptySanctuary;

  /// No description provided for @placeOrb.
  ///
  /// In es, this message translates to:
  /// **'Colocar Orbe'**
  String get placeOrb;

  /// No description provided for @channelNow.
  ///
  /// In es, this message translates to:
  /// **'¡Canalizar ahora!'**
  String get channelNow;

  /// No description provided for @symbiosisReward.
  ///
  /// In es, this message translates to:
  /// **'¡Santuario de Simbiosis te otorgó {essence} de Esencia!'**
  String symbiosisReward(String essence);

  /// No description provided for @orb.
  ///
  /// In es, this message translates to:
  /// **'Orbe'**
  String get orb;

  /// No description provided for @stepsProgress.
  ///
  /// In es, this message translates to:
  /// **'{current} / {total} pasos'**
  String stepsProgress(int current, int total);

  /// No description provided for @discoveredCount.
  ///
  /// In es, this message translates to:
  /// **'{current} / {total} Descubiertos'**
  String discoveredCount(int current, int total);

  /// No description provided for @rarityCommon.
  ///
  /// In es, this message translates to:
  /// **'Común'**
  String get rarityCommon;

  /// No description provided for @rarityUncommon.
  ///
  /// In es, this message translates to:
  /// **'Poco común'**
  String get rarityUncommon;

  /// No description provided for @rarityRare.
  ///
  /// In es, this message translates to:
  /// **'Raro'**
  String get rarityRare;

  /// No description provided for @rarityEpic.
  ///
  /// In es, this message translates to:
  /// **'Épico'**
  String get rarityEpic;

  /// No description provided for @rarityLegendary.
  ///
  /// In es, this message translates to:
  /// **'Legendario'**
  String get rarityLegendary;

  /// No description provided for @selectSanctuary.
  ///
  /// In es, this message translates to:
  /// **'Seleccionar Santuario'**
  String get selectSanctuary;

  /// No description provided for @selectOrbTitle.
  ///
  /// In es, this message translates to:
  /// **'Seleccionar Orbe'**
  String get selectOrbTitle;

  /// No description provided for @waitingOrbs.
  ///
  /// In es, this message translates to:
  /// **'Orbes en Espera'**
  String get waitingOrbs;

  /// No description provided for @noOrbsAvailable.
  ///
  /// In es, this message translates to:
  /// **'No tienes orbes disponibles'**
  String get noOrbsAvailable;

  /// No description provided for @noOrbsInstructions.
  ///
  /// In es, this message translates to:
  /// **'Visita la tienda para comprar orbes y comenzar a canalizar criaturas'**
  String get noOrbsInstructions;

  /// No description provided for @goToShop.
  ///
  /// In es, this message translates to:
  /// **'Ir a tienda'**
  String get goToShop;

  /// No description provided for @inventoryItems.
  ///
  /// In es, this message translates to:
  /// **'Objetos de Inventario'**
  String get inventoryItems;

  /// No description provided for @noItemsAvailable.
  ///
  /// In es, this message translates to:
  /// **'No tienes objetos disponibles'**
  String get noItemsAvailable;

  /// No description provided for @noItemsInstructions.
  ///
  /// In es, this message translates to:
  /// **'Los objetos especiales aparecerán aquí cuando los consigas'**
  String get noItemsInstructions;

  /// No description provided for @use.
  ///
  /// In es, this message translates to:
  /// **'Usar'**
  String get use;

  /// No description provided for @quantity.
  ///
  /// In es, this message translates to:
  /// **'Cantidad'**
  String get quantity;

  /// No description provided for @noUnassignedOrbs.
  ///
  /// In es, this message translates to:
  /// **'No tienes orbes sin asignar'**
  String get noUnassignedOrbs;

  /// No description provided for @unknownOrb.
  ///
  /// In es, this message translates to:
  /// **'Orbe Desconocido'**
  String get unknownOrb;

  /// No description provided for @stepsRequired.
  ///
  /// In es, this message translates to:
  /// **'{count} pasos requeridos'**
  String stepsRequired(int count);

  /// No description provided for @assign.
  ///
  /// In es, this message translates to:
  /// **'Asignar'**
  String get assign;

  /// No description provided for @inventoryItemsAndSanctuaries.
  ///
  /// In es, this message translates to:
  /// **'Objetos y Santuarios'**
  String get inventoryItemsAndSanctuaries;

  /// No description provided for @emptyInventoryBag.
  ///
  /// In es, this message translates to:
  /// **'Bolsa de objetos vacía'**
  String get emptyInventoryBag;

  /// No description provided for @quantityDisplay.
  ///
  /// In es, this message translates to:
  /// **'Cantidad: {count}'**
  String quantityDisplay(int count);

  /// No description provided for @itemActivated.
  ///
  /// In es, this message translates to:
  /// **'{name} Activado'**
  String itemActivated(String name);

  /// No description provided for @steps.
  ///
  /// In es, this message translates to:
  /// **'pasos'**
  String get steps;

  /// No description provided for @tempSanctuaryAlreadyActive.
  ///
  /// In es, this message translates to:
  /// **'Ya tienes un santuario temporal activo'**
  String get tempSanctuaryAlreadyActive;

  /// No description provided for @newCreatureBadge.
  ///
  /// In es, this message translates to:
  /// **'¡NUEVO!'**
  String get newCreatureBadge;

  /// No description provided for @useSingular.
  ///
  /// In es, this message translates to:
  /// **'uso'**
  String get useSingular;

  /// No description provided for @usesPlural.
  ///
  /// In es, this message translates to:
  /// **'usos'**
  String get usesPlural;

  /// No description provided for @energyStorage.
  ///
  /// In es, this message translates to:
  /// **'Almacén de Energía'**
  String get energyStorage;

  /// No description provided for @orbReadyTitle.
  ///
  /// In es, this message translates to:
  /// **'✨ Orbe Listo'**
  String get orbReadyTitle;

  /// No description provided for @orbReadyBody.
  ///
  /// In es, this message translates to:
  /// **'Tu {type} ha terminado de canalizar'**
  String orbReadyBody(String type);

  /// No description provided for @walkReminderTitle.
  ///
  /// In es, this message translates to:
  /// **'🌿 Momento de Paseo'**
  String get walkReminderTitle;

  /// No description provided for @walkMsg1.
  ///
  /// In es, this message translates to:
  /// **'¿Un paseo tranquilo?'**
  String get walkMsg1;

  /// No description provided for @walkMsg2.
  ///
  /// In es, this message translates to:
  /// **'Tal vez es buen momento para caminar'**
  String get walkMsg2;

  /// No description provided for @walkMsg3.
  ///
  /// In es, this message translates to:
  /// **'El aire fresco siempre viene bien'**
  String get walkMsg3;

  /// No description provided for @walkMsg4.
  ///
  /// In es, this message translates to:
  /// **'¿Qué tal estirar las piernas?'**
  String get walkMsg4;

  /// No description provided for @noGoal.
  ///
  /// In es, this message translates to:
  /// **'Sin objetivo'**
  String get noGoal;

  /// No description provided for @notifyGoal.
  ///
  /// In es, this message translates to:
  /// **'Notificar al conseguir objetivo'**
  String get notifyGoal;

  /// No description provided for @notifyGoalDesc.
  ///
  /// In es, this message translates to:
  /// **'Recibe un aviso cuando cumplas tu meta diaria de pasos'**
  String get notifyGoalDesc;

  /// No description provided for @goalReachedTitle.
  ///
  /// In es, this message translates to:
  /// **'¡Objetivo Cumplido!'**
  String get goalReachedTitle;

  /// No description provided for @goalReachedBody.
  ///
  /// In es, this message translates to:
  /// **'Has alcanzado tu objetivo diario de {goal} pasos'**
  String goalReachedBody(Object goal);

  /// No description provided for @trackingServiceTitle.
  ///
  /// In es, this message translates to:
  /// **'Stillwalks activo'**
  String get trackingServiceTitle;

  /// No description provided for @trackingServiceBody.
  ///
  /// In es, this message translates to:
  /// **'Generando Esencia...'**
  String get trackingServiceBody;

  /// No description provided for @primordial.
  ///
  /// In es, this message translates to:
  /// **'Primordial'**
  String get primordial;

  /// No description provided for @temporary.
  ///
  /// In es, this message translates to:
  /// **'Temporal'**
  String get temporary;

  /// No description provided for @ready.
  ///
  /// In es, this message translates to:
  /// **'¡Listo!'**
  String get ready;

  /// No description provided for @noActiveOrbsStatus.
  ///
  /// In es, this message translates to:
  /// **'Sin orbes activos'**
  String get noActiveOrbsStatus;

  /// No description provided for @orbsAvailableForPurchase.
  ///
  /// In es, this message translates to:
  /// **'Orbes disponibles para comprar'**
  String get orbsAvailableForPurchase;

  /// No description provided for @levelAbbr.
  ///
  /// In es, this message translates to:
  /// **'Nv.'**
  String get levelAbbr;

  /// No description provided for @emptySlot.
  ///
  /// In es, this message translates to:
  /// **'Vacío'**
  String get emptySlot;

  /// No description provided for @useStorage.
  ///
  /// In es, this message translates to:
  /// **'Usar Almacén'**
  String get useStorage;

  /// No description provided for @channelEnergy.
  ///
  /// In es, this message translates to:
  /// **'Canalizar Energía'**
  String get channelEnergy;

  /// No description provided for @chooseEnergyTransfer.
  ///
  /// In es, this message translates to:
  /// **'Elige cuánta energía transferir:'**
  String get chooseEnergyTransfer;

  /// No description provided for @stepsLower.
  ///
  /// In es, this message translates to:
  /// **'pasos'**
  String get stepsLower;

  /// No description provided for @storageVsNeeded.
  ///
  /// In es, this message translates to:
  /// **'Almacén: {stored} | Necesarios: {needed}'**
  String storageVsNeeded(int stored, int needed);

  /// No description provided for @transfer.
  ///
  /// In es, this message translates to:
  /// **'Transferir'**
  String get transfer;

  /// No description provided for @stepsChanneledFromStorage.
  ///
  /// In es, this message translates to:
  /// **'¡Se canalizaron {count} pasos del almacén!'**
  String stepsChanneledFromStorage(int count);

  /// No description provided for @stats.
  ///
  /// In es, this message translates to:
  /// **'Características:'**
  String get stats;

  /// No description provided for @typePermanent.
  ///
  /// In es, this message translates to:
  /// **'Tipo: Santuario Permanente'**
  String get typePermanent;

  /// No description provided for @upgradeLevel.
  ///
  /// In es, this message translates to:
  /// **'Nivel de mejora: {level} (-{percentage}%)'**
  String upgradeLevel(int level, String percentage);

  /// No description provided for @unlimitedUses.
  ///
  /// In es, this message translates to:
  /// **'Usos: Ilimitados ♾️'**
  String get unlimitedUses;

  /// No description provided for @specialAbility.
  ///
  /// In es, this message translates to:
  /// **'Habilidad Especial:'**
  String get specialAbility;

  /// No description provided for @infiniteChannelingDesc.
  ///
  /// In es, this message translates to:
  /// **'Canalización Infinita. Nunca se agota y permite canalizar cualquier tipo de orbe.'**
  String get infiniteChannelingDesc;

  /// No description provided for @improveSpeedHint.
  ///
  /// In es, this message translates to:
  /// **'Mejora la velocidad de canalización en la tienda para reducir los pasos necesarios.'**
  String get improveSpeedHint;

  /// No description provided for @activateSanctuary.
  ///
  /// In es, this message translates to:
  /// **'Activar'**
  String get activateSanctuary;

  /// No description provided for @tapToSelectSanctuary.
  ///
  /// In es, this message translates to:
  /// **'Toca para seleccionar santuario'**
  String get tapToSelectSanctuary;

  /// No description provided for @emptyUses.
  ///
  /// In es, this message translates to:
  /// **'Vacío ({count} usos)'**
  String emptyUses(int count);

  /// No description provided for @tapToActivate.
  ///
  /// In es, this message translates to:
  /// **'Toca para activar'**
  String get tapToActivate;

  /// No description provided for @typeTemporary.
  ///
  /// In es, this message translates to:
  /// **'Tipo: Santuario Temporal'**
  String get typeTemporary;

  /// No description provided for @noSanctuariesInBag.
  ///
  /// In es, this message translates to:
  /// **'Sin santuarios disponibles'**
  String get noSanctuariesInBag;

  /// No description provided for @remainingUses.
  ///
  /// In es, this message translates to:
  /// **'Usos restantes: {count}'**
  String remainingUses(int count);

  /// No description provided for @destroyWarning.
  ///
  /// In es, this message translates to:
  /// **'Se destruye automáticamente después de agotar todos los usos.'**
  String get destroyWarning;

  /// No description provided for @abilityFastFlow.
  ///
  /// In es, this message translates to:
  /// **'Reduce los pasos requeridos en un 10% (multiplicador 1.11x de velocidad).'**
  String get abilityFastFlow;

  /// No description provided for @abilitySymbiosis.
  ///
  /// In es, this message translates to:
  /// **'Otorga 1 punto de Esencia por cada 10 pasos realizados durante la canalización.'**
  String get abilitySymbiosis;

  /// No description provided for @abilityQuietude.
  ///
  /// In es, this message translates to:
  /// **'Permite eclosionar orbes usando Esencia en lugar de pasos.'**
  String get abilityQuietude;

  /// No description provided for @abilityEcho.
  ///
  /// In es, this message translates to:
  /// **'Reduce pasos en 70% pero solo genera criaturas comunes/inusuales.'**
  String get abilityEcho;

  /// No description provided for @abilityResonance.
  ///
  /// In es, this message translates to:
  /// **'Aumenta la probabilidad de obtener criaturas raras en +10%.'**
  String get abilityResonance;

  /// No description provided for @sanctuary_temp_sanctuary_symbiosis_desc.
  ///
  /// In es, this message translates to:
  /// **'Genera Esencia extra al completar el orbe.'**
  String get sanctuary_temp_sanctuary_symbiosis_desc;

  /// No description provided for @abilityActive.
  ///
  /// In es, this message translates to:
  /// **'Habilidad especial activa.'**
  String get abilityActive;

  /// No description provided for @sanctuary_temp_sanctuary_quietude_name.
  ///
  /// In es, this message translates to:
  /// **'Santuario de Quietud'**
  String get sanctuary_temp_sanctuary_quietude_name;

  /// No description provided for @sanctuary_temp_sanctuary_quietude_desc.
  ///
  /// In es, this message translates to:
  /// **'Convierte la Esencia obtenida en pasos para el orbe.'**
  String get sanctuary_temp_sanctuary_quietude_desc;

  /// No description provided for @upgradeIdleName.
  ///
  /// In es, this message translates to:
  /// **'Recolector de Esencia'**
  String get upgradeIdleName;

  /// No description provided for @upgradeIdleDesc.
  ///
  /// In es, this message translates to:
  /// **'Aumenta la velocidad de generación pasiva de Esencia.'**
  String get upgradeIdleDesc;

  /// No description provided for @upgradeIdleBonus.
  ///
  /// In es, this message translates to:
  /// **'+2% bono / nivel'**
  String get upgradeIdleBonus;

  /// No description provided for @upgradeStorageName.
  ///
  /// In es, this message translates to:
  /// **'Almacén de Energía'**
  String get upgradeStorageName;

  /// No description provided for @upgradeStorageDesc.
  ///
  /// In es, this message translates to:
  /// **'Permite almacenar pasos no usados cuando no hay orbes activos.'**
  String get upgradeStorageDesc;

  /// No description provided for @upgradeStorageBonus.
  ///
  /// In es, this message translates to:
  /// **'+300 capacidad / nivel'**
  String get upgradeStorageBonus;

  /// No description provided for @upgradeSpeedName.
  ///
  /// In es, this message translates to:
  /// **'Mejora de Velocidad'**
  String get upgradeSpeedName;

  /// No description provided for @sancPrimordialName.
  ///
  /// In es, this message translates to:
  /// **'Primordial'**
  String get sancPrimordialName;

  /// No description provided for @sancPrimordialDesc.
  ///
  /// In es, this message translates to:
  /// **'El primer santuario descubierto. Un lugar tranquilo donde los Orbes pueden canalizar su energía.'**
  String get sancPrimordialDesc;

  /// No description provided for @sancFastFlowName.
  ///
  /// In es, this message translates to:
  /// **'Flujo Rápido'**
  String get sancFastFlowName;

  /// No description provided for @sancFastFlowDesc.
  ///
  /// In es, this message translates to:
  /// **'Reduce en un 10% los pasos requeridos (1 uso)'**
  String get sancFastFlowDesc;

  /// No description provided for @sancSymbiosisName.
  ///
  /// In es, this message translates to:
  /// **'Simbiosis'**
  String get sancSymbiosisName;

  /// No description provided for @sancSymbiosisDesc.
  ///
  /// In es, this message translates to:
  /// **'+1 Esencia cada 10 pasos (2 usos)'**
  String get sancSymbiosisDesc;

  /// No description provided for @sancQuietudeName.
  ///
  /// In es, this message translates to:
  /// **'Quietud Absoluta'**
  String get sancQuietudeName;

  /// No description provided for @sancQuietudeDesc.
  ///
  /// In es, this message translates to:
  /// **'Eclosión con Esencia (1 uso)'**
  String get sancQuietudeDesc;

  /// No description provided for @sancEchoName.
  ///
  /// In es, this message translates to:
  /// **'Eco Vital'**
  String get sancEchoName;

  /// No description provided for @sancEchoDesc.
  ///
  /// In es, this message translates to:
  /// **'-70% pasos | Solo comunes/inusuales (1 uso)'**
  String get sancEchoDesc;

  /// No description provided for @sancResonanceName.
  ///
  /// In es, this message translates to:
  /// **'Resonancia'**
  String get sancResonanceName;

  /// No description provided for @sancResonanceDesc.
  ///
  /// In es, this message translates to:
  /// **'+10% prob. criatura rara (1 uso)'**
  String get sancResonanceDesc;

  /// No description provided for @orbBasicName.
  ///
  /// In es, this message translates to:
  /// **'Orbe Básico'**
  String get orbBasicName;

  /// No description provided for @orbBasicDesc.
  ///
  /// In es, this message translates to:
  /// **'Un Orbe común. Requiere 2000 pasos.'**
  String get orbBasicDesc;

  /// No description provided for @orbAdvancedName.
  ///
  /// In es, this message translates to:
  /// **'Orbe Avanzado'**
  String get orbAdvancedName;

  /// No description provided for @orbAdvancedDesc.
  ///
  /// In es, this message translates to:
  /// **'Mejora probabilidad de Poco Comunes. Requiere 5000 pasos.'**
  String get orbAdvancedDesc;

  /// No description provided for @orbExpertName.
  ///
  /// In es, this message translates to:
  /// **'Orbe Experto'**
  String get orbExpertName;

  /// No description provided for @orbExpertDesc.
  ///
  /// In es, this message translates to:
  /// **'Mejora probabilidad de Raros. Requiere 10000 pasos.'**
  String get orbExpertDesc;

  /// No description provided for @orbQuietudeName.
  ///
  /// In es, this message translates to:
  /// **'Orbe de Quietud'**
  String get orbQuietudeName;

  /// No description provided for @orbQuietudeDesc.
  ///
  /// In es, this message translates to:
  /// **'Permite usar Esencia para avanzar. Ideal para días tranquilos.'**
  String get orbQuietudeDesc;

  /// No description provided for @orbEssenceName.
  ///
  /// In es, this message translates to:
  /// **'Orbe Esencial'**
  String get orbEssenceName;

  /// No description provided for @orbEssenceDesc.
  ///
  /// In es, this message translates to:
  /// **'Genera Esencia extra al caminar. No acelera canalización.'**
  String get orbEssenceDesc;

  /// No description provided for @infuseEssence.
  ///
  /// In es, this message translates to:
  /// **'Infundir Esencia'**
  String get infuseEssence;

  /// No description provided for @infuseEssenceDesc.
  ///
  /// In es, this message translates to:
  /// **'Convierte {essence} Esencia en {steps} pasos'**
  String infuseEssenceDesc(Object essence, Object steps);

  /// No description provided for @essenceInfused.
  ///
  /// In es, this message translates to:
  /// **'¡{steps} pasos obtenidos!'**
  String essenceInfused(Object steps);

  /// No description provided for @descSpiristone.
  ///
  /// In es, this message translates to:
  /// **'Una pequeña piedra encantada con manitas y piernitas. Curiosa y amigable.'**
  String get descSpiristone;

  /// No description provided for @descRadispirit.
  ///
  /// In es, this message translates to:
  /// **'Un rábano mágico que camina sobre cuatro patas. Sus hojas brillan al atardecer.'**
  String get descRadispirit;

  /// No description provided for @descSlugrry.
  ///
  /// In es, this message translates to:
  /// **'Una babosa peluda blanca de movimientos lentos pero pensamiento rápido.'**
  String get descSlugrry;

  /// No description provided for @physicalActivity.
  ///
  /// In es, this message translates to:
  /// **'Actividad física'**
  String get physicalActivity;

  /// No description provided for @notificationsPermission.
  ///
  /// In es, this message translates to:
  /// **'Notificaciones'**
  String get notificationsPermission;

  /// No description provided for @backgroundExecution.
  ///
  /// In es, this message translates to:
  /// **'Ejecución en segundo plano'**
  String get backgroundExecution;

  /// No description provided for @granted.
  ///
  /// In es, this message translates to:
  /// **'Concedido'**
  String get granted;

  /// No description provided for @denied.
  ///
  /// In es, this message translates to:
  /// **'Denegado'**
  String get denied;

  /// No description provided for @permissionsMessage.
  ///
  /// In es, this message translates to:
  /// **'Sin estos permisos el juego funciona, pero con menos precisión.'**
  String get permissionsMessage;

  /// No description provided for @openSystemSettings.
  ///
  /// In es, this message translates to:
  /// **'Abrir ajustes del sistema'**
  String get openSystemSettings;

  /// No description provided for @stepCounter.
  ///
  /// In es, this message translates to:
  /// **'Contador de pasos'**
  String get stepCounter;

  /// No description provided for @lastUpdate.
  ///
  /// In es, this message translates to:
  /// **'Última actualización'**
  String get lastUpdate;

  /// No description provided for @dataSource.
  ///
  /// In es, this message translates to:
  /// **'Fuente de datos'**
  String get dataSource;

  /// No description provided for @deviceSensor.
  ///
  /// In es, this message translates to:
  /// **'Sensor del dispositivo'**
  String get deviceSensor;

  /// No description provided for @minutesAgo.
  ///
  /// In es, this message translates to:
  /// **'Hace {minutes} min'**
  String minutesAgo(int minutes);

  /// No description provided for @hoursAgo.
  ///
  /// In es, this message translates to:
  /// **'Hace {hours} h'**
  String hoursAgo(int hours);

  /// No description provided for @sensorActive.
  ///
  /// In es, this message translates to:
  /// **'Activo'**
  String get sensorActive;

  /// No description provided for @sensorInactive.
  ///
  /// In es, this message translates to:
  /// **'Inactivo'**
  String get sensorInactive;

  /// No description provided for @systemStatus.
  ///
  /// In es, this message translates to:
  /// **'Estado del sistema'**
  String get systemStatus;

  /// No description provided for @trackingActive.
  ///
  /// In es, this message translates to:
  /// **'Seguimiento activo'**
  String get trackingActive;

  /// No description provided for @trackingPaused.
  ///
  /// In es, this message translates to:
  /// **'Seguimiento pausado'**
  String get trackingPaused;

  /// No description provided for @activeNotifications.
  ///
  /// In es, this message translates to:
  /// **'Notificaciones activas'**
  String get activeNotifications;

  /// No description provided for @sanctuariesInProgress.
  ///
  /// In es, this message translates to:
  /// **'Santuarios en progreso'**
  String get sanctuariesInProgress;

  /// No description provided for @lastSync.
  ///
  /// In es, this message translates to:
  /// **'Última sincronización'**
  String get lastSync;

  /// No description provided for @systemHealthy.
  ///
  /// In es, this message translates to:
  /// **'Sistema funcionando correctamente'**
  String get systemHealthy;

  /// No description provided for @noIssues.
  ///
  /// In es, this message translates to:
  /// **'No se detectaron problemas'**
  String get noIssues;

  /// No description provided for @none.
  ///
  /// In es, this message translates to:
  /// **'Ninguno'**
  String get none;

  /// No description provided for @justNow.
  ///
  /// In es, this message translates to:
  /// **'Justo ahora'**
  String get justNow;

  /// No description provided for @tutorialWelcome.
  ///
  /// In es, this message translates to:
  /// **'BIENVENIDO A STILLWALKS'**
  String get tutorialWelcome;

  /// No description provided for @tutorialWelcomeDesc.
  ///
  /// In es, this message translates to:
  /// **'Descubre criaturas mágicas caminando en el mundo real y usando menos el móvil.\n\nCuando el teléfono está bloqueado,\ngeneras Esencia automáticamente.\n\nLa Esencia te ayuda a avanzar y a descubrir nuevas criaturas.\n\nPara empezar tu aventura,\nte regalamos Esencia suficiente\npara comprar tu primer Orbe.'**
  String get tutorialWelcomeDesc;

  /// No description provided for @startAdventure.
  ///
  /// In es, this message translates to:
  /// **'¡Empezar Aventura!'**
  String get startAdventure;

  /// No description provided for @essenceGrant.
  ///
  /// In es, this message translates to:
  /// **'+{amount} Esencia recibida'**
  String essenceGrant(Object amount);

  /// No description provided for @energyTutorialTitle.
  ///
  /// In es, this message translates to:
  /// **'¡ENERGÍA NECESARIA!'**
  String get energyTutorialTitle;

  /// No description provided for @energyTutorialDesc.
  ///
  /// In es, this message translates to:
  /// **'Los Orbes se canalizan en los Santuarios.\n\nAl caminar, generas Energía.\nLa Energía canaliza el Orbe hasta estar listo para descubrir el stillwalk que contiene.\n\nComo es tu primera vez,\nvamos a acelerar un poco el proceso.'**
  String get energyTutorialDesc;

  /// No description provided for @walkingSim.
  ///
  /// In es, this message translates to:
  /// **'Caminando...'**
  String get walkingSim;

  /// No description provided for @letsGo.
  ///
  /// In es, this message translates to:
  /// **'¡Vamos!'**
  String get letsGo;

  /// No description provided for @tutorialCompleteTitle.
  ///
  /// In es, this message translates to:
  /// **'¡Tutorial Completado!'**
  String get tutorialCompleteTitle;

  /// No description provided for @tutorialCompleteDesc.
  ///
  /// In es, this message translates to:
  /// **'¡Felicidades! Ahora eres libre de explorar el mundo real para encontrar más criaturas.\n\nRecuerda: ¡Tienes que moverte para conseguir Esencia!'**
  String get tutorialCompleteDesc;

  /// No description provided for @tutorialConclusionTitle.
  ///
  /// In es, this message translates to:
  /// **'TU AVENTURA CONTINÚA'**
  String get tutorialConclusionTitle;

  /// No description provided for @tutorialConclusionDesc.
  ///
  /// In es, this message translates to:
  /// **'Utiliza la Esencia que consigues al descansar para comprar orbes, mejorar santuarios y avanzar. Recuerda salir a caminar para seguir canalizando orbes y descubrir a todas las criaturas!\n\nStillwalks avanza contigo,\na tu ritmo.'**
  String get tutorialConclusionDesc;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
