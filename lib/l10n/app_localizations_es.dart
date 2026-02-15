// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Stillwalks';

  @override
  String get settings => 'Ajustes';

  @override
  String get general => 'GENERAL';

  @override
  String get notifications => 'NOTIFICACIONES';

  @override
  String get wellbeing => 'BIENESTAR';

  @override
  String get privacySystem => 'PRIVACIDAD Y SISTEMA';

  @override
  String get information => 'INFORMACIÓN';

  @override
  String get language => 'Idioma';

  @override
  String get spanish => 'Español';

  @override
  String get english => 'English';

  @override
  String get system => 'Sistema';

  @override
  String get selectLanguage => 'Seleccionar Idioma';

  @override
  String get languageSelectionTitle => 'Elige tu idioma';

  @override
  String get languageSelectionSubtitle => 'Puedes cambiarlo después en ajustes';

  @override
  String get languageSelectionContinue => 'Continuar';

  @override
  String get tutorialBlockShop =>
      'Por favor compra un orbe para continuar el tutorial.';

  @override
  String get tutorialBlockHome =>
      'Completa el tutorial para desbloquear todo el acceso.';

  @override
  String get welcomeTitle => 'Bienvenido a Stillwalks';

  @override
  String get welcomeSubtitle =>
      'Para ofrecerte la mejor experiencia, necesitamos tu permiso para:';

  @override
  String get permissionActivityTitle => 'Reconocimiento de Actividad';

  @override
  String get permissionActivityDesc =>
      'Para contar tus pasos y canalizar los Orbes mientras caminas.';

  @override
  String get permissionNotificationTitle => 'Notificación Persistente';

  @override
  String get permissionNotificationDesc =>
      'Para mostrarte tu progreso sin necesidad de abrir la app.';

  @override
  String get privacyPolicySummary =>
      '✓ No vendemos tus datos\n✓ Toda la información se guarda localmente\n✓ Sin anuncios (por ahora)';

  @override
  String get permissionDeniedMessage =>
      'Necesitamos este permiso para que el juego funcione';

  @override
  String get continueButton => 'Continuar';

  @override
  String get tutorialWelcomeTitle => 'Bienvenido, Explorador';

  @override
  String get tutorialWelcomeDesc =>
      'Soy el Guardián Olvidado y necesito tu ayuda para encontrar a los stillwalks perdidos.\n\nToca en la pantalla para generar Esencia. También puedes comprar mejoras para que se genere automáticamente.\n\nTe he concedido algo de Esencia inicial para que compres tu primer orbe ahora mismo.';

  @override
  String get tutorialShopTitle => 'La Tienda';

  @override
  String get tutorialShopDesc =>
      'Ve a la Tienda y compra tu primer orbe básico. ¡Invito yo!';

  @override
  String get tutorialSanctuaryTitle => 'El Santuario';

  @override
  String get tutorialSanctuaryDesc =>
      'Ahora asigna tu nuevo orbe al Santuario Primordial para comenzar su canalización.';

  @override
  String get tutorialEnergyTitle => 'Energía de tus pasos';

  @override
  String get tutorialEnergyDesc =>
      'Los orbes se canalizan en los santuarios gracias a la energía de tus pasos.\n\ncamina para progresar y descubrir nuevos stillwalks.\n\nComo es tu primera vez, te he ayudado con algo de energía que tenía almacenada.';

  @override
  String get tutorialHatchTitle => 'Listo para Canalizar';

  @override
  String get tutorialHatchDesc =>
      '¡Tu orbe tiene energía suficiente! Interactúa con el Santuario para completar la canalización.';

  @override
  String get tutorialAdventureTitle => 'Empieza tu aventura';

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
  String get googleFit => 'Google Fit';

  @override
  String get googleFitDesc => 'Usar Google Fit para contar pasos';

  @override
  String get googleFitNotAvailable =>
      'Google Fit no disponible en este dispositivo';

  @override
  String get googleFitEnabled => 'Google Fit activado';

  @override
  String get googleFitDisabled => 'Google Fit desactivado';

  @override
  String get googleFitPermissionDenied => 'Permisos de Google Fit denegados';

  @override
  String get googleFitTitle => 'Conecta con Google Fit';

  @override
  String get googleFitDescription =>
      'Conecta con Google Fit para sincronizar pasos de tus relojes inteligentes y otras apps de fitness, mejorando tu generación de Esencia.';

  @override
  String get connectGoogleFit => 'Conectar';

  @override
  String get maybeLater => 'Quizás luego';

  @override
  String get googleFitConnected => '¡Google Fit conectado!';

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
  String get buildings => 'Edificios';

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
  String get close => 'Cerrar';

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
  String get offlineEssenceCollectedTitle => '¡Esencia Recolectada!';

  @override
  String get offlineEssenceCollectedBody =>
      'Los recolectores de esencia han seguido trabajando durante tu ausencia';

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
  String purchaseCompleted(String name) {
    return '¡Compra de \"$name\" completada!';
  }

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
  String get permanentSanctuaryUpgrades => 'Mejoras Permanentes de Santuarios';

  @override
  String get globalUpgrades => 'Mejoras de Esencia';

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
  String get orb => 'Orbe';

  @override
  String stepsProgress(int current, int total) {
    return '$current / $total pasos';
  }

  @override
  String discoveredCount(int current, int total) {
    return '$current / $total Descubiertos';
  }

  @override
  String get rarityCommon => 'Común';

  @override
  String get rarityUncommon => 'Poco común';

  @override
  String get rarityRare => 'Raro';

  @override
  String get rarityEpic => 'Épico';

  @override
  String get rarityLegendary => 'Legendario';

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
  String get newCreatureBadge => '¡NUEVO!';

  @override
  String get useSingular => 'uso';

  @override
  String get usesPlural => 'usos';

  @override
  String get strengthLabel => 'Fuerza';

  @override
  String get capacityLabel => 'Capacidad';

  @override
  String get unlockCapacityLabel => 'Desbloquea capacidad';

  @override
  String get unlockLevel1 => 'Desbloquear nivel 1';

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
      'Una pequeña piedra encantada con manitas y piernitas. Curiosa y amigable.';

  @override
  String get nameRadispirit => 'Radispirit';

  @override
  String get descRadispirit =>
      'Un rábano mágico que camina sobre cuatro patas. Sus hojas brillan al atardecer.';

  @override
  String get nameSlugrry => 'Slugrry';

  @override
  String get descSlugrry =>
      'Una babosa peluda blanca de movimientos lentos pero pensamiento rápido.';

  @override
  String get nameGamusarra => 'Gamusarra';

  @override
  String get descGamusarra =>
      'Gamusarra habita en bosques y caminos rurales donde apenas se le puede ver. Atrae a los viajeros con ruidos extraños y saltos juguetones, pero cuando alguien se acerca demasiado, ataca con sus afiladas garras y desaparece entre la maleza. Se dice que solo aparece cuando nadie puede demostrar que realmente lo ha visto.';

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
  String get adventureContinues => '¡Genial!';

  @override
  String get explorerLevel => 'Nivel de Explorador';

  @override
  String get howToGainXp => '¿Cómo ganar experiencia?';

  @override
  String get xpSourceBuyOrbs => 'Comprar Orbes';

  @override
  String get xpSourceBuyBuildings => 'Comprar Edificios';

  @override
  String get xpSourceChannelOrbs => 'Canalizar Orbes';

  @override
  String get xpSourceBuyUpgrades => 'Comprar mejoras';

  @override
  String get xpSourceBuySanctuaries => 'Comprar santuarios';

  @override
  String get xpSourceUpgradeSanctuaries => 'Mejorar santuarios';

  @override
  String get levelUpToUnlock =>
      'Sube de nivel para desbloquear nuevas funcionalidades';

  @override
  String get understood => 'Entendido';

  @override
  String get upgradeTapStrengthName => 'Fuerza de Tap';

  @override
  String get upgradeTapStrengthDesc =>
      'Aumenta la Esencia generada por cada tap.';

  @override
  String get upgradeTapMultiplierName => 'Ritmo Interior';

  @override
  String get upgradeTapMultiplierDesc => 'Reduce el enfriamiento del tap.';

  @override
  String get upgradeGlobalMultiplierName => 'Flujo Esencial';

  @override
  String get upgradeGlobalMultiplierDesc =>
      'Multiplica la producción pasiva de Esencia.';

  @override
  String get upgradeOfflineEfficiencyName => 'Eco Persistente';

  @override
  String get upgradeOfflineEfficiencyDesc =>
      'Aumenta la eficiencia de producción desconectado.';

  @override
  String get upgradeOfflineTimeName => 'Eco Duradero';

  @override
  String get upgradeOfflineTimeDesc =>
      'Aumenta el tiempo de producción desconectado.';

  @override
  String get perLevel => '/ nivel';

  @override
  String get building_recolector_name => 'Recolector';

  @override
  String get building_recolector_desc =>
      'Genera esencia básica automáticamente.';

  @override
  String get building_mina_name => 'Mina';

  @override
  String get building_mina_desc => 'Extrae esencia de la tierra.';

  @override
  String get building_cantera_name => 'Cantera';

  @override
  String get building_cantera_desc => 'Producción industrial de esencia.';

  @override
  String get building_yacimiento_name => 'Yacimiento';

  @override
  String get building_yacimiento_desc => 'Fuente masiva de esencia pura.';

  @override
  String get building_fabrica_name => 'Fábrica';

  @override
  String get building_fabrica_desc => 'La cúspide de la tecnología de esencia.';

  @override
  String errOrbLimitReached(int max) {
    return 'Límite de orbes alcanzado (máx. $max)';
  }

  @override
  String errInventoryLimitReached(int max) {
    return 'Bolsa de santuarios llena (máx. $max)';
  }

  @override
  String get bagCapacity => 'Capacidad de Bolsa';

  @override
  String lockedAtLevel(int level) {
    return 'Bloqueado (Nv. $level)';
  }

  @override
  String limitCountReached(int count, int max) {
    return 'Límite alcanzado ($count/$max)';
  }

  @override
  String buildingLimitReached(Object max) {
    return 'Límite: $max';
  }

  @override
  String requiresLevel(Object level) {
    return 'Requiere Nivel $level';
  }
}
