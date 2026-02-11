// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Stillwalks';

  @override
  String get settings => 'Settings';

  @override
  String get general => 'GENERAL';

  @override
  String get notifications => 'NOTIFICATIONS';

  @override
  String get wellbeing => 'WELLBEING';

  @override
  String get privacySystem => 'PRIVACY & SYSTEM';

  @override
  String get information => 'INFORMATION';

  @override
  String get language => 'Language';

  @override
  String get spanish => 'Español';

  @override
  String get english => 'English';

  @override
  String get system => 'System';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get languageSelectionTitle => 'Choose your language';

  @override
  String get languageSelectionSubtitle =>
      'You can change this anytime in settings';

  @override
  String get languageSelectionContinue => 'Continue';

  @override
  String get tutorialBlockShop =>
      'Please purchase an orb to continue the tutorial.';

  @override
  String get tutorialBlockHome =>
      'Complete the tutorial to unlock full access.';

  @override
  String get welcomeTitle => 'Welcome to Stillwalks';

  @override
  String get welcomeSubtitle =>
      'To provide the best experience, we need your permission for:';

  @override
  String get permissionActivityTitle => 'Activity Recognition';

  @override
  String get permissionActivityDesc =>
      'To count your steps and channel Orbs while you walk.';

  @override
  String get permissionNotificationTitle => 'Persistent Notification';

  @override
  String get permissionNotificationDesc =>
      'To show your progress without opening the app.';

  @override
  String get privacyPolicySummary =>
      '✓ We don\'t sell your data\n✓ All information is stored locally\n✓ No ads (for now)';

  @override
  String get permissionDeniedMessage =>
      'We need this permission for the game to work';

  @override
  String get continueButton => 'Continue';

  @override
  String get tutorialWelcomeTitle => 'Welcome, Explorer';

  @override
  String get tutorialWelcomeDesc =>
      'I am the Forgotten Guardian and I am going to need your help to find all the stillwalks that are lost around the world.\n\nWhen you lock your phone, the Essence collectors start working. This will help you in your adventure.\n\nI have gotten you some Essence so you can buy your first orb without waiting.';

  @override
  String get tutorialShopTitle => 'The Shop';

  @override
  String get tutorialShopDesc =>
      'Go to the Shop and buy your first basic orb. It\'s on me!';

  @override
  String get tutorialSanctuaryTitle => 'The Sanctuary';

  @override
  String get tutorialSanctuaryDesc =>
      'Now assign your new orb to the Primordial Sanctuary to begin its channeling.';

  @override
  String get tutorialEnergyTitle => 'Energy of your steps';

  @override
  String get tutorialEnergyDesc =>
      'Orbs are channeled in the sanctuaries thanks to the energy of your steps.\n\nWalk to progress and discover new stillwalks.\n\nSince it\'s your first time, I have helped you with some energy I had stored.';

  @override
  String get tutorialHatchTitle => 'Ready to Channel';

  @override
  String get tutorialHatchDesc =>
      'Your orb has enough energy! Interact with the Sanctuary to complete the channeling.';

  @override
  String get tutorialAdventureTitle => 'Your adventure begins';

  @override
  String get tutorialAdventureDesc =>
      '¡Espectacular! has encontrado una Gamusarra, es una criatura mítica super rara de encontrar\n\nUtiliza la esencia para comprar nuevos orbes o mejoras en la tienda.\n\nRecuerda salir a caminar para que tus orbes canalicen y ¡encuentra a todos los Stillwalks perdidos!';

  @override
  String get soundVibration => 'Sonido / vibración';

  @override
  String get soundVibrationDesc => 'Feedback sonoro y háptico';

  @override
  String get batterySaver => 'Modo ahorro batería';

  @override
  String get batterySaverDesc => 'Reduce el consumo de batería';

  @override
  String get permanent => 'Permanente';

  @override
  String get permanentDesc => 'Tracking activo en segundo plano';

  @override
  String get events => 'Eventos';

  @override
  String get eventsDesc => 'Orbes e hitos de esencia';

  @override
  String get reminders => 'Recordatorios';

  @override
  String get remindersDesc => 'Invitaciones a caminar';

  @override
  String get disabledInBatterySaver => 'Desactivado en modo ahorro';

  @override
  String get pauseProgress => 'Pausar progreso';

  @override
  String get pauseProgressDesc => 'Detiene temporalmente el tracking';

  @override
  String get doNotDisturb => 'Horas no molestar';

  @override
  String get configure => 'Configurar';

  @override
  String dndTimeRange(String start, String end) {
    return '$start - $end';
  }

  @override
  String get dndStartTime => 'HORA DE INICIO';

  @override
  String get dndEndTime => 'HORA DE FIN';

  @override
  String get dailyGoal => 'Objetivo diario';

  @override
  String dailyGoalSteps(int count) {
    return '$count pasos';
  }

  @override
  String get selectDailyGoal => 'Objetivo Diario';

  @override
  String get permissions => 'Permisos';

  @override
  String get permissionsDesc => 'Gestionar accesos de la app';

  @override
  String get sensors => 'Sensores';

  @override
  String get sensorsDesc => 'Estado del podómetro';

  @override
  String get trackingStatus => 'Estado de seguimiento';

  @override
  String get trackingStatusDesc => 'Resumen del sistema';

  @override
  String get help => 'Ayuda';

  @override
  String get contact => 'Contacto';

  @override
  String get credits => 'Créditos';

  @override
  String version(String version) {
    return 'Versión v$version';
  }

  @override
  String get essence => 'Esencia';

  @override
  String get orbs => 'Orbes';

  @override
  String get sanctuary => 'Santuario';

  @override
  String get collection => 'Colección';

  @override
  String get shop => 'Tienda';

  @override
  String get essenceCollectorLabel => 'Recolector de Esencia';

  @override
  String get freeSlot => 'Ranura libre';

  @override
  String get activeOrb => 'Orbe activo';

  @override
  String get readyToChannel => '¡Listo para canalizar!';

  @override
  String get channel => 'Canalizar';

  @override
  String get channeling => 'Canalizando...';

  @override
  String get selectOrb => 'Seleccionar Orbe';

  @override
  String get cancel => 'Cancelar';

  @override
  String get confirm => 'Confirmar';

  @override
  String progressSteps(int current, int total) {
    return '$current/$total pasos';
  }

  @override
  String progressEssence(int current, int total) {
    return '$current/$total esencia';
  }

  @override
  String get creature => 'Criatura';

  @override
  String get evolution => 'Evolución';

  @override
  String get basePower => 'Poder base';

  @override
  String get generation => 'Generación';

  @override
  String get buy => 'Comprar';

  @override
  String get cost => 'Costo';

  @override
  String get owned => 'Posees';

  @override
  String get upgrades => 'Mejoras';

  @override
  String get items => 'Objetos';

  @override
  String get permissionsRequired => 'Permisos Necesarios';

  @override
  String get permissionsDescription =>
      'Stillwalks necesita los siguientes permisos para funcionar:';

  @override
  String get activityPermission => 'Actividad física';

  @override
  String get activityPermissionDesc => 'Para contar pasos';

  @override
  String get notificationPermission => 'Notificaciones';

  @override
  String get notificationPermissionDesc => 'Para mostrar progreso';

  @override
  String get requestPermissions => 'Solicitar permisos';

  @override
  String get welcome => 'Bienvenido';

  @override
  String get loading => 'Cargando...';

  @override
  String get error => 'Error';

  @override
  String get retry => 'Reintentar';

  @override
  String get close => 'Close';

  @override
  String get save => 'Guardar';

  @override
  String get delete => 'Eliminar';

  @override
  String get noCreatures => 'No hay criaturas disponibles';

  @override
  String get noOrbs => 'No tienes orbes activos';

  @override
  String get notEnoughEssence => 'No tienes suficiente esencia';

  @override
  String get orbTypes => 'TIPOS DE ORBE';

  @override
  String get mystical => 'Místico';

  @override
  String get primal => 'Primigenio';

  @override
  String get ethereal => 'Etéreo';

  @override
  String get sanctuarySlots => 'Ranuras de Santuario';

  @override
  String availableSlots(int count) {
    return '$count disponibles';
  }

  @override
  String get standardOrbs => 'Orbes Estándar';

  @override
  String get specialOrbs => 'Orbes Especiales';

  @override
  String get walkReminder => 'Recordatorio para caminar';

  @override
  String get orbReady => 'Orbe listo';

  @override
  String get milestoneReached => '¡Hito alcanzado!';

  @override
  String get essenceGenerated => 'Esencia generada';

  @override
  String get locked => 'Bloqueado';

  @override
  String get unlocked => 'Desbloqueado';

  @override
  String get upgrade => 'Mejorar';

  @override
  String get maxLevel => 'Nivel máximo';

  @override
  String get perHour => '/ hora';

  @override
  String get level => 'Nv.';

  @override
  String get orbsReady => '¡Orbe listo para canalizar!';

  @override
  String get noActiveOrbs => 'Orbes activos';

  @override
  String get idleProduction => 'Producción pasiva';

  @override
  String get storage => 'Almacén';

  @override
  String get explorerJournal => 'Diario de Explorador';

  @override
  String get sanctuaries => 'Santuarios';

  @override
  String get temporarySanctuaries => 'Santuarios Temporales';

  @override
  String get orbPurchased => '¡Orbe comprado! Revisa tu Bolsa.';

  @override
  String get sanctuaryPurchased => '¡Santuario comprado! Revisa tu Bolsa.';

  @override
  String upgradeCompleted(String name) {
    return '¡Mejora \"$name\" realizada!';
  }

  @override
  String sanctuaryUpgraded(String name, int level) {
    return '¡Mejora de \"$name\" a Nivel $level!';
  }

  @override
  String get checkBag => 'Revisa tu Bolsa';

  @override
  String get permanentSanctuaryUpgrades => 'Mejora de Santuario Permanente';

  @override
  String get globalUpgrades => 'Mejoras Globales';

  @override
  String get loadingUpgrades => 'Cargando mejoras...';

  @override
  String get primordialSanctuaries => 'Santuarios Primordiales';

  @override
  String get yourBag => 'Tu Bolsa';

  @override
  String get emptySanctuary => 'Santuario Vacío';

  @override
  String get placeOrb => 'Colocar Orbe';

  @override
  String get channelNow => '¡Canalizar ahora!';

  @override
  String symbiosisReward(String essence) {
    return '¡Santuario de Simbiosis te otorgó $essence de Esencia!';
  }

  @override
  String get orb => 'Orb';

  @override
  String stepsProgress(int current, int total) {
    return '$current / $total pasos';
  }

  @override
  String discoveredCount(int current, int total) {
    return '$current / $total Discovered';
  }

  @override
  String get rarityCommon => 'Common';

  @override
  String get rarityUncommon => 'Uncommon';

  @override
  String get rarityRare => 'Rare';

  @override
  String get rarityEpic => 'Epic';

  @override
  String get rarityLegendary => 'Legendary';

  @override
  String get selectSanctuary => 'Seleccionar Santuario';

  @override
  String get selectOrbTitle => 'Seleccionar Orbe';

  @override
  String get waitingOrbs => 'Orbes en Espera';

  @override
  String get noOrbsAvailable => 'No tienes orbes disponibles';

  @override
  String get noOrbsInstructions =>
      'Visita la tienda para comprar orbes y comenzar a canalizar criaturas';

  @override
  String get goToShop => 'Ir a tienda';

  @override
  String get inventoryItems => 'Objetos de Inventario';

  @override
  String get noItemsAvailable => 'No tienes objetos disponibles';

  @override
  String get noItemsInstructions =>
      'Los objetos especiales aparecerán aquí cuando los consigas';

  @override
  String get use => 'Usar';

  @override
  String get quantity => 'Cantidad';

  @override
  String get noUnassignedOrbs => 'No tienes orbes sin asignar';

  @override
  String get noOrbAssigned => 'Sin orbe asignado';

  @override
  String get unknownOrb => 'Orbe Desconocido';

  @override
  String stepsRequired(int count) {
    return '$count pasos requeridos';
  }

  @override
  String get assign => 'Asignar';

  @override
  String get inventoryItemsAndSanctuaries => 'Objetos y Santuarios';

  @override
  String get emptyInventoryBag => 'Bolsa de objetos vacía';

  @override
  String quantityDisplay(int count) {
    return 'Cantidad: $count';
  }

  @override
  String itemActivated(String name) {
    return '$name Activado';
  }

  @override
  String get steps => 'pasos';

  @override
  String get tempSanctuaryAlreadyActive =>
      'Ya tienes un santuario temporal activo';

  @override
  String get newCreatureBadge => 'NEW!';

  @override
  String get useSingular => 'uso';

  @override
  String get usesPlural => 'usos';

  @override
  String get energyStorage => 'Almacén de Energía';

  @override
  String get orbReadyTitle => '✨ Orbe Listo';

  @override
  String orbReadyBody(String type) {
    return 'Tu $type ha terminado de canalizar';
  }

  @override
  String get walkReminderTitle => '🌿 Momento de Paseo';

  @override
  String get walkMsg1 => '¿Un paseo tranquilo?';

  @override
  String get walkMsg2 => 'Tal vez es buen momento para caminar';

  @override
  String get walkMsg3 => 'El aire fresco siempre viene bien';

  @override
  String get walkMsg4 => '¿Qué tal estirar las piernas?';

  @override
  String get noGoal => 'Sin objetivo';

  @override
  String get notifyGoal => 'Notificar al conseguir objetivo';

  @override
  String get notifyGoalDesc =>
      'Recibe un aviso cuando cumplas tu meta diaria de pasos';

  @override
  String get goalReachedTitle => '¡Objetivo Cumplido!';

  @override
  String goalReachedBody(Object goal) {
    return 'Has alcanzado tu objetivo diario de $goal pasos';
  }

  @override
  String get trackingServiceTitle => 'Stillwalks activo';

  @override
  String get trackingServiceBody => 'Generando Esencia...';

  @override
  String get primordial => 'Primordial';

  @override
  String get temporary => 'Temporal';

  @override
  String get ready => '¡Listo!';

  @override
  String get noActiveOrbsStatus => 'Sin orbes activos';

  @override
  String get orbsAvailableForPurchase => 'Orbes disponibles para comprar';

  @override
  String get levelAbbr => 'Nv.';

  @override
  String get emptySlot => 'Vacío';

  @override
  String get useStorage => 'Usar Almacén';

  @override
  String get channelEnergy => 'Canalizar Energía';

  @override
  String get chooseEnergyTransfer => 'Elige cuánta energía transferir:';

  @override
  String get stepsLower => 'pasos';

  @override
  String storageVsNeeded(int stored, int needed) {
    return 'Almacén: $stored | Necesarios: $needed';
  }

  @override
  String get transfer => 'Transferir';

  @override
  String stepsChanneledFromStorage(int count) {
    return '¡Se canalizaron $count pasos del almacén!';
  }

  @override
  String get stats => 'Características:';

  @override
  String get typePermanent => 'Tipo: Santuario Permanente';

  @override
  String upgradeLevel(int level, String percentage) {
    return 'Nivel de mejora: $level (-$percentage%)';
  }

  @override
  String get unlimitedUses => 'Usos: Ilimitados ♾️';

  @override
  String get specialAbility => 'Habilidad Especial:';

  @override
  String get infiniteChannelingDesc =>
      'Canalización Infinita. Nunca se agota y permite canalizar cualquier tipo de orbe.';

  @override
  String get improveSpeedHint =>
      'Mejora la velocidad de canalización en la tienda para reducir los pasos necesarios.';

  @override
  String get activateSanctuary => 'Activar';

  @override
  String get tapToSelectSanctuary => 'Seleccionar santuarios';

  @override
  String emptyUses(int count) {
    return 'Vacío ($count usos)';
  }

  @override
  String get tapToActivate => 'Toca para activar';

  @override
  String get typeTemporary => 'Tipo: Santuario Temporal';

  @override
  String get noSanctuariesInBag => 'Sin santuarios disponibles';

  @override
  String remainingUses(int count) {
    return 'Usos restantes: $count';
  }

  @override
  String get destroyWarning =>
      'Se destruye automáticamente después de agotar todos los usos.';

  @override
  String get abilityFastFlow =>
      'Reduce los pasos requeridos en un 10% (multiplicador 1.11x de velocidad).';

  @override
  String get abilitySymbiosis =>
      'Otorga 1 punto de Esencia por cada 10 pasos realizados durante la canalización.';

  @override
  String get abilityQuietude =>
      'Permite eclosionar orbes usando Esencia en lugar de pasos.';

  @override
  String get abilityEcho =>
      'Reduce pasos en 70% pero solo genera criaturas comunes/inusuales.';

  @override
  String get abilityResonance =>
      'Aumenta la probabilidad de obtener criaturas raras en +10%.';

  @override
  String get sanctuary_temp_sanctuary_symbiosis_desc =>
      'Genera Esencia extra al completar el orbe.';

  @override
  String get abilityActive => 'Habilidad especial activa.';

  @override
  String get sanctuary_temp_sanctuary_quietude_name => 'Santuario de Quietud';

  @override
  String get sanctuary_temp_sanctuary_quietude_desc =>
      'Convierte la Esencia obtenida en pasos para el orbe.';

  @override
  String get upgradeIdleName => 'Recolector de Esencia';

  @override
  String get upgradeIdleDesc =>
      'Aumenta la velocidad de generación pasiva de Esencia.';

  @override
  String get upgradeIdleBonus => '+2% bono / nivel';

  @override
  String get upgradeStorageName => 'Almacén de Energía';

  @override
  String get upgradeStorageDesc =>
      'Permite almacenar pasos no usados cuando no hay orbes activos.';

  @override
  String get upgradeStorageBonus => '+200 capacidad / nivel';

  @override
  String get upgradeSpeedName => 'Mejora de Velocidad';

  @override
  String get sancPrimordialName => 'Primordial';

  @override
  String get sancPrimordialDesc =>
      'El primer santuario descubierto. Un lugar tranquilo donde los Orbes pueden canalizar su energía.';

  @override
  String get sancFastFlowName => 'Flujo Rápido';

  @override
  String get sancFastFlowDesc =>
      'Reduce en un 10% los pasos requeridos (1 uso)';

  @override
  String get sancSymbiosisName => 'Simbiosis';

  @override
  String get sancSymbiosisDesc => '+1 Esencia cada 10 pasos (2 usos)';

  @override
  String get sancQuietudeName => 'Quietud Absoluta';

  @override
  String get sancQuietudeDesc => 'Eclosión con Esencia (1 uso)';

  @override
  String get sancEchoName => 'Eco Vital';

  @override
  String get sancEchoDesc => '-70% pasos | Solo comunes/inusuales (1 uso)';

  @override
  String get sancResonanceName => 'Resonancia';

  @override
  String get sancResonanceDesc => '+10% prob. criatura rara (1 uso)';

  @override
  String get orbBasicName => 'Orbe Básico';

  @override
  String get orbBasicDesc => 'Un Orbe común. Requiere 2000 pasos.';

  @override
  String get orbAdvancedName => 'Orbe Avanzado';

  @override
  String get orbAdvancedDesc =>
      'Mejora probabilidad de Poco Comunes. Requiere 5000 pasos.';

  @override
  String get orbExpertName => 'Orbe Experto';

  @override
  String get orbExpertDesc =>
      'Mejora probabilidad de Raros. Requiere 10000 pasos.';

  @override
  String get orbQuietudeName => 'Orbe de Quietud';

  @override
  String get orbQuietudeDesc =>
      'Permite usar Esencia para avanzar. Ideal para días tranquilos.';

  @override
  String get orbEssenceName => 'Orbe Esencial';

  @override
  String get orbEssenceDesc =>
      'Genera Esencia extra al caminar. No acelera canalización.';

  @override
  String get infuseEssence => 'Infundir Esencia';

  @override
  String infuseEssenceDesc(Object essence, Object steps) {
    return 'Convierte $essence Esencia en $steps pasos';
  }

  @override
  String essenceInfused(Object steps) {
    return '¡$steps pasos obtenidos!';
  }

  @override
  String get nameSpiristone => 'Spiristone';

  @override
  String get descSpiristone =>
      'A small enchanted stone with little hands and legs. Curious and friendly.';

  @override
  String get nameRadispirit => 'Radispirit';

  @override
  String get descRadispirit =>
      'A magical radish that walks on four legs. Its leaves glow at dusk.';

  @override
  String get nameSlugrry => 'Slugrry';

  @override
  String get descSlugrry =>
      'A white furry slug of slow movements but quick thinking.';

  @override
  String get nameGamusarra => 'Gamusarra';

  @override
  String get descGamusarra =>
      'Gamusarra lives in forests and rural paths, where it is rarely seen. It lures travelers with strange noises and playful hops, but when someone gets too close, it strikes with its sharp claws and vanishes into the undergrowth. It is said to appear only when no one can prove they have truly seen it.';

  @override
  String get physicalActivity => 'Actividad física';

  @override
  String get notificationsPermission => 'Notificaciones';

  @override
  String get backgroundExecution => 'Ejecución en segundo plano';

  @override
  String get granted => 'Concedido';

  @override
  String get denied => 'Denegado';

  @override
  String get permissionsMessage =>
      'Sin estos permisos el juego funciona, pero con menos precisión.';

  @override
  String get openSystemSettings => 'Abrir ajustes del sistema';

  @override
  String get stepCounter => 'Contador de pasos';

  @override
  String get lastUpdate => 'Última actualización';

  @override
  String get dataSource => 'Fuente de datos';

  @override
  String get deviceSensor => 'Sensor del dispositivo';

  @override
  String minutesAgo(int minutes) {
    return 'Hace $minutes min';
  }

  @override
  String hoursAgo(int hours) {
    return 'Hace $hours h';
  }

  @override
  String get sensorActive => 'Activo';

  @override
  String get sensorInactive => 'Inactivo';

  @override
  String get systemStatus => 'Estado del sistema';

  @override
  String get trackingActive => 'Seguimiento activo';

  @override
  String get trackingPaused => 'Seguimiento pausado';

  @override
  String get activeNotifications => 'Notificaciones activas';

  @override
  String get sanctuariesInProgress => 'Santuarios en progreso';

  @override
  String get lastSync => 'Última sincronización';

  @override
  String get systemHealthy => 'Sistema funcionando correctamente';

  @override
  String get noIssues => 'No se detectaron problemas';

  @override
  String get none => 'Ninguno';

  @override
  String get justNow => 'Justo ahora';

  @override
  String get adventureContinues => 'Adventure awaits!';

  @override
  String get explorerLevel => 'Explorer Level';

  @override
  String get howToGainXp => 'How to gain experience?';

  @override
  String get xpSourceBuyOrbs => 'Buy orbs';

  @override
  String get xpSourceChannelOrbs => 'Channel orbs';

  @override
  String get xpSourceBuyUpgrades => 'Buy upgrades';

  @override
  String get xpSourceBuySanctuaries => 'Buy sanctuaries';

  @override
  String get xpSourceUpgradeSanctuaries => 'Upgrade sanctuaries';

  @override
  String get levelUpToUnlock => 'Level up to unlock new features';

  @override
  String get understood => 'Got it';
}
