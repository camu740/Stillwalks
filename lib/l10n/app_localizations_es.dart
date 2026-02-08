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
  String get continueButton => 'Continuar';

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
  String get tapToSelectSanctuary => 'Toca para seleccionar santuario';

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
  String get descSpiristone =>
      'Una pequeña piedra encantada con manitas y piernitas. Curiosa y amigable.';

  @override
  String get descRadispirit =>
      'Un rábano mágico que camina sobre cuatro patas. Sus hojas brillan al atardecer.';

  @override
  String get descSlugrry =>
      'Una babosa peluda blanca de movimientos lentos pero pensamiento rápido.';

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
  String get tutorialWelcome => 'BIENVENIDO A STILLWALKS';

  @override
  String get tutorialWelcomeDesc =>
      'Descubre criaturas mágicas caminando en el mundo real y usando menos el móvil.\n\nCuando el teléfono está bloqueado,\ngeneras Esencia automáticamente.\n\nLa Esencia te ayuda a avanzar y a descubrir nuevas criaturas.\n\nPara empezar tu aventura,\nte regalamos Esencia suficiente\npara comprar tu primer Orbe.';

  @override
  String get startAdventure => '¡Empezar Aventura!';

  @override
  String essenceGrant(Object amount) {
    return '+$amount Esencia recibida';
  }

  @override
  String get energyTutorialTitle => '¡ENERGÍA NECESARIA!';

  @override
  String get energyTutorialDesc =>
      'Los Orbes se canalizan en los Santuarios.\n\nAl caminar, generas Energía.\nLa Energía canaliza el Orbe hasta estar listo para descubrir el stillwalk que contiene.\n\nComo es tu primera vez,\nvamos a acelerar un poco el proceso.';

  @override
  String get walkingSim => 'Caminando...';

  @override
  String get letsGo => '¡Vamos!';

  @override
  String get tutorialCompleteTitle => '¡Tutorial Completado!';

  @override
  String get tutorialCompleteDesc =>
      '¡Felicidades! Ahora eres libre de explorar el mundo real para encontrar más criaturas.\n\nRecuerda: ¡Tienes que moverte para conseguir Esencia!';

  @override
  String get tutorialConclusionTitle => 'TU AVENTURA CONTINÚA';

  @override
  String get tutorialConclusionDesc =>
      'Utiliza la Esencia que consigues al descansar para comprar orbes, mejorar santuarios y avanzar. Recuerda salir a caminar para seguir canalizando orbes y descubrir a todas las criaturas!\n\nStillwalks avanza contigo,\na tu ritmo.';
}
