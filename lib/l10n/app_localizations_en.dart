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
      'You can change this later in settings';

  @override
  String get languageSelectionContinue => 'Continue';

  @override
  String get tutorialBlockShop =>
      'Please purchase an orb to continue the tutorial.';

  @override
  String get tutorialBlockHome => 'Complete the tutorial to unlock all access.';

  @override
  String get welcomeTitle => 'Welcome to Stillwalks';

  @override
  String get welcomeSubtitle =>
      'To give you the best experience, we need your permission for:';

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
      'I am the Forgotten Guardian and I need your help to find the lost stillwalks.\n\nTap the screen to generate Essence. You can also buy upgrades to generate it automatically.\n\nI have granted you some starting Essence so you can buy your first orb right away.';

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
  String get tutorialEnergyTitle => 'Step Energy';

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
      'Spectacular! You\'ve found a Gamusarra, a mythical creature very rare to find.\n\nUse Essence to buy new orbs or upgrades in the shop.\n\nRemember to go out for a walk so your orbs channel and find all the lost Stillwalks!';

  @override
  String get soundVibration => 'Sound / Vibration';

  @override
  String get soundVibrationDesc => 'Sound and haptic feedback';

  @override
  String get batterySaver => 'Battery Saver Mode';

  @override
  String get batterySaverDesc => 'Reduces battery consumption';

  @override
  String get permanent => 'Permanent';

  @override
  String get permanentDesc => 'Active background tracking';

  @override
  String get events => 'Events';

  @override
  String get eventsDesc => 'Orbs and Essence milestones';

  @override
  String get reminders => 'Reminders';

  @override
  String get remindersDesc => 'Walk invitations';

  @override
  String get disabledInBatterySaver => 'Disabled in battery saver mode';

  @override
  String get pauseProgress => 'Pause progress';

  @override
  String get pauseProgressDesc => 'Temporarily stops tracking';

  @override
  String get doNotDisturb => 'Do Not Disturb hours';

  @override
  String get configure => 'Configure';

  @override
  String dndTimeRange(String start, String end) {
    return '$start - $end';
  }

  @override
  String get dndStartTime => 'START TIME';

  @override
  String get dndEndTime => 'END TIME';

  @override
  String get dailyGoal => 'Daily Goal';

  @override
  String dailyGoalSteps(int count) {
    return '$count steps';
  }

  @override
  String get selectDailyGoal => 'Daily Goal';

  @override
  String get permissions => 'Permissions';

  @override
  String get permissionsDesc => 'Manage app access';

  @override
  String get sensors => 'Sensors';

  @override
  String get sensorsDesc => 'Pedometer status';

  @override
  String get trackingStatus => 'Tracking Status';

  @override
  String get trackingStatusDesc => 'System summary';

  @override
  String get googleFit => 'Google Fit';

  @override
  String get googleFitDesc => 'Use Google Fit for step counting';

  @override
  String get googleFitNotAvailable => 'Google Fit not available on this device';

  @override
  String get googleFitEnabled => 'Google Fit enabled';

  @override
  String get googleFitDisabled => 'Google Fit disabled';

  @override
  String get googleFitPermissionDenied => 'Google Fit permissions denied';

  @override
  String get googleFitTitle => 'Connect with Google Fit';

  @override
  String get googleFitDescription =>
      'Connect to Google Fit to sync steps from your smartwatches and other fitness apps, improving your Essence generation.';

  @override
  String get connectGoogleFit => 'Connect';

  @override
  String get maybeLater => 'Maybe Later';

  @override
  String get googleFitConnected => 'Google Fit connected!';

  @override
  String get help => 'Help';

  @override
  String get contact => 'Contact';

  @override
  String get credits => 'Credits';

  @override
  String version(String version) {
    return 'Version v$version';
  }

  @override
  String get essence => 'Essence';

  @override
  String get buildings => 'Buildings';

  @override
  String get orbs => 'Orbs';

  @override
  String get sanctuary => 'Sanctuary';

  @override
  String get collection => 'Collection';

  @override
  String get shop => 'Shop';

  @override
  String get essenceCollectorLabel => 'Essence Collector';

  @override
  String get freeSlot => 'Free Slot';

  @override
  String get activeOrb => 'Active Orb';

  @override
  String get readyToChannel => 'Ready to channel!';

  @override
  String get channel => 'Channel';

  @override
  String get channeling => 'Channeling...';

  @override
  String get selectOrb => 'Select Orb';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String progressSteps(int current, int total) {
    return '$current/$total steps';
  }

  @override
  String progressEssence(int current, int total) {
    return '$current/$total essence';
  }

  @override
  String get creature => 'Creature';

  @override
  String get evolution => 'Evolution';

  @override
  String get basePower => 'Base Power';

  @override
  String get generation => 'Generation';

  @override
  String get buy => 'Buy';

  @override
  String get cost => 'Cost';

  @override
  String get owned => 'Owned';

  @override
  String get upgrades => 'Upgrades';

  @override
  String get items => 'Items';

  @override
  String get permissionsRequired => 'Permissions Required';

  @override
  String get permissionsDescription =>
      'Stillwalks needs the following permissions to work:';

  @override
  String get activityPermission => 'Physical Activity';

  @override
  String get activityPermissionDesc => 'To count steps';

  @override
  String get notificationPermission => 'Notifications';

  @override
  String get notificationPermissionDesc => 'To show progress';

  @override
  String get requestPermissions => 'Request Permissions';

  @override
  String get welcome => 'Welcome';

  @override
  String get loading => 'Loading...';

  @override
  String get error => 'Error';

  @override
  String get retry => 'Retry';

  @override
  String get close => 'Close';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get noCreatures => 'No creatures available';

  @override
  String get noOrbs => 'You have no active orbs';

  @override
  String get notEnoughEssence => 'Not enough essence';

  @override
  String get orbTypes => 'ORB TYPES';

  @override
  String get mystical => 'Mystical';

  @override
  String get primal => 'Primal';

  @override
  String get ethereal => 'Ethereal';

  @override
  String get sanctuarySlots => 'Sanctuary Slots';

  @override
  String availableSlots(int count) {
    return '$count available';
  }

  @override
  String get standardOrbs => 'Standard Orbs';

  @override
  String get specialOrbs => 'Special Orbs';

  @override
  String get walkReminder => 'Walk Reminder';

  @override
  String get orbReady => 'Orb Ready';

  @override
  String get milestoneReached => 'Milestone Reached!';

  @override
  String get essenceGenerated => 'Essence Generated';

  @override
  String get offlineEssenceCollectedTitle => 'Essence Collected!';

  @override
  String get offlineEssenceCollectedBody =>
      'The essence collectors have continued working in your absence';

  @override
  String get locked => 'Locked';

  @override
  String get unlocked => 'Unlocked';

  @override
  String get upgrade => 'Upgrade';

  @override
  String get maxLevel => 'Max Level';

  @override
  String get perHour => '/ hour';

  @override
  String get level => 'Lv.';

  @override
  String get orbsReady => 'Orb ready to channel!';

  @override
  String get noActiveOrbs => 'Active Orbs';

  @override
  String get idleProduction => 'Passive Production';

  @override
  String get storage => 'Storage';

  @override
  String get explorerJournal => 'Explorer Journal';

  @override
  String get sanctuaries => 'Sanctuaries';

  @override
  String get temporarySanctuaries => 'Temporary Sanctuaries';

  @override
  String get orbPurchased => 'Orb purchased! Check your Bag.';

  @override
  String get sanctuaryPurchased => 'Sanctuary purchased! Check your Bag.';

  @override
  String purchaseCompleted(String name) {
    return '\"$name\" purchase completed!';
  }

  @override
  String upgradeCompleted(String name) {
    return '\"$name\" upgrade completed!';
  }

  @override
  String sanctuaryUpgraded(String name, int level) {
    return '\"$name\" upgraded to Level $level!';
  }

  @override
  String get checkBag => 'Check your Bag';

  @override
  String get permanentSanctuaryUpgrades => 'Permanent Sanctuary Upgrades';

  @override
  String get globalUpgrades => 'Essence Upgrades';

  @override
  String get loadingUpgrades => 'Loading upgrades...';

  @override
  String get primordialSanctuaries => 'Primordial Sanctuaries';

  @override
  String get yourBag => 'Your Bag';

  @override
  String get emptySanctuary => 'Empty Sanctuary';

  @override
  String get placeOrb => 'Place Orb';

  @override
  String get channelNow => 'Channel Now!';

  @override
  String symbiosisReward(String essence) {
    return 'Symbiosis Sanctuary granted you $essence Essence!';
  }

  @override
  String get orb => 'Orb';

  @override
  String stepsProgress(int current, int total) {
    return '$current / $total steps';
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
  String get selectSanctuary => 'Select Sanctuary';

  @override
  String get selectOrbTitle => 'Select Orb';

  @override
  String get waitingOrbs => 'Waiting Orbs';

  @override
  String get noOrbsAvailable => 'No orbs available';

  @override
  String get noOrbsInstructions =>
      'Visit the shop to buy orbs and start channeling creatures';

  @override
  String get goToShop => 'Go to Shop';

  @override
  String get inventoryItems => 'Inventory Items';

  @override
  String get noItemsAvailable => 'No items available';

  @override
  String get noItemsInstructions =>
      'Special items will appear here when you get them';

  @override
  String get use => 'Use';

  @override
  String get quantity => 'Quantity';

  @override
  String get noUnassignedOrbs => 'No unassigned orbs';

  @override
  String get noOrbAssigned => 'No orb assigned';

  @override
  String get unknownOrb => 'Unknown Orb';

  @override
  String stepsRequired(int count) {
    return '$count steps required';
  }

  @override
  String get assign => 'Assign';

  @override
  String get inventoryItemsAndSanctuaries => 'Items and Sanctuaries';

  @override
  String get emptyInventoryBag => 'Empty inventory bag';

  @override
  String quantityDisplay(int count) {
    return 'Quantity: $count';
  }

  @override
  String itemActivated(String name) {
    return '$name Activated';
  }

  @override
  String get steps => 'steps';

  @override
  String get tempSanctuaryAlreadyActive =>
      'You already have a temporary sanctuary active';

  @override
  String get newCreatureBadge => 'NEW!';

  @override
  String get useSingular => 'use';

  @override
  String get usesPlural => 'uses';

  @override
  String get strengthLabel => 'Strength';

  @override
  String get capacityLabel => 'Capacity';

  @override
  String get unlockCapacityLabel => 'Unlock capacity';

  @override
  String get unlockLevel1 => 'Unlock level 1';

  @override
  String get energyStorage => 'Energy Storage';

  @override
  String get orbReadyTitle => '✨ Orb Ready';

  @override
  String orbReadyBody(String type) {
    return 'Your $type has finished channeling';
  }

  @override
  String get walkReminderTitle => '🌿 Time for a Walk';

  @override
  String get walkMsg1 => 'Time for a walk?';

  @override
  String get walkMsg2 => 'Maybe it\'s a good time to walk';

  @override
  String get walkMsg3 => 'Fresh air always feels good';

  @override
  String get walkMsg4 => 'How about stretching your legs?';

  @override
  String get noGoal => 'No goal';

  @override
  String get notifyGoal => 'Notify on goal reached';

  @override
  String get notifyGoalDesc =>
      'Get a notification when you meet your daily step goal';

  @override
  String get goalReachedTitle => 'Goal Achieved!';

  @override
  String goalReachedBody(Object goal) {
    return 'You\'ve reached your daily goal of $goal steps';
  }

  @override
  String get trackingServiceTitle => 'Stillwalks Active';

  @override
  String get trackingServiceBody => 'Generating Essence...';

  @override
  String get primordial => 'Primordial';

  @override
  String get temporary => 'Temporary';

  @override
  String get ready => 'Ready!';

  @override
  String get noActiveOrbsStatus => 'No active orbs';

  @override
  String get orbsAvailableForPurchase => 'Orbs available for purchase';

  @override
  String get levelAbbr => 'Lv.';

  @override
  String get emptySlot => 'Empty';

  @override
  String get useStorage => 'Use Storage';

  @override
  String get channelEnergy => 'Channel Energy';

  @override
  String get chooseEnergyTransfer => 'Choose how much energy to transfer:';

  @override
  String get stepsLower => 'steps';

  @override
  String storageVsNeeded(int stored, int needed) {
    return 'Storage: $stored | Needed: $needed';
  }

  @override
  String get transfer => 'Transfer';

  @override
  String stepsChanneledFromStorage(int count) {
    return '$count steps channeled from storage!';
  }

  @override
  String get stats => 'Characteristics:';

  @override
  String get typePermanent => 'Type: Permanent Sanctuary';

  @override
  String upgradeLevel(int level, String percentage) {
    return 'Upgrade Level: $level (-$percentage%)';
  }

  @override
  String get unlimitedUses => 'Uses: Unlimited ♾️';

  @override
  String get specialAbility => 'Special Ability:';

  @override
  String get infiniteChannelingDesc =>
      'Infinite Channeling. Never runs out and allows channeling any type of orb.';

  @override
  String get improveSpeedHint =>
      'Improve channeling speed in the shop to reduce required steps.';

  @override
  String get activateSanctuary => 'Activate';

  @override
  String get tapToSelectSanctuary => 'Select Sanctuaries';

  @override
  String emptyUses(int count) {
    return 'Empty ($count uses)';
  }

  @override
  String get tapToActivate => 'Tap to activate';

  @override
  String get typeTemporary => 'Type: Temporary Sanctuary';

  @override
  String get noSanctuariesInBag => 'No sanctuaries available';

  @override
  String remainingUses(int count) {
    return 'Remaining uses: $count';
  }

  @override
  String get destroyWarning =>
      'Automatically destroyed after all uses are exhausted.';

  @override
  String get abilityFastFlow =>
      'Reduces required steps by 10% (1.11x speed multiplier).';

  @override
  String get abilitySymbiosis =>
      'Grants 1 Essence point for every 10 steps taken during channeling.';

  @override
  String get abilityQuietude =>
      'Allows hatching orbs using Essence instead of steps.';

  @override
  String get abilityEcho =>
      'Reduces steps by 70% but only generates common/uncommon creatures.';

  @override
  String get abilityResonance =>
      'Increases the probability of obtaining rare creatures by +10%.';

  @override
  String get sanctuary_temp_sanctuary_symbiosis_desc =>
      'Generates extra Essence upon completing the orb.';

  @override
  String get abilityActive => 'Special ability active.';

  @override
  String get sanctuary_temp_sanctuary_quietude_name => 'Sanctuary of Quietude';

  @override
  String get sanctuary_temp_sanctuary_quietude_desc =>
      'Converts obtained Essence into steps for the orb.';

  @override
  String get upgradeIdleName => 'Essence Collector';

  @override
  String get upgradeIdleDesc => 'Increases passive Essence generation speed.';

  @override
  String get upgradeIdleBonus => '+2% bonus / level';

  @override
  String get upgradeStorageName => 'Energy Storage';

  @override
  String get upgradeStorageDesc =>
      'Allows storing unused steps when no orbs are active.';

  @override
  String get upgradeStorageBonus => '+200 capacity / level';

  @override
  String get upgradeSpeedName => 'Speed Upgrade';

  @override
  String get sancPrimordialName => 'Primordial';

  @override
  String get sancPrimordialDesc =>
      'The first discovered sanctuary. A quiet place where Orbs can channel their energy.';

  @override
  String get sancFastFlowName => 'Fast Flow';

  @override
  String get sancFastFlowDesc => 'Reduces required steps by 10% (1 use)';

  @override
  String get sancSymbiosisName => 'Symbiosis';

  @override
  String get sancSymbiosisDesc => '+1 Essence every 10 steps (2 uses)';

  @override
  String get sancQuietudeName => 'Absolute Quietude';

  @override
  String get sancQuietudeDesc => 'Hatch with Essence (1 use)';

  @override
  String get sancEchoName => 'Vital Echo';

  @override
  String get sancEchoDesc => '-70% steps | Common/Uncommon only (1 use)';

  @override
  String get sancResonanceName => 'Resonance';

  @override
  String get sancResonanceDesc => '+10% chance for rare creature (1 use)';

  @override
  String get orbBasicName => 'Basic Orb';

  @override
  String get orbBasicDesc => 'A common Orb. Requires 2,000 steps.';

  @override
  String get orbAdvancedName => 'Advanced Orb';

  @override
  String get orbAdvancedDesc =>
      'Improves chance for Uncommon creatures. Requires 5,000 steps.';

  @override
  String get orbExpertName => 'Expert Orb';

  @override
  String get orbExpertDesc =>
      'Improves chance for Rare creatures. Requires 10,000 steps.';

  @override
  String get orbQuietudeName => 'Orb of Quietude';

  @override
  String get orbQuietudeDesc =>
      'Allows using Essence to progress. Ideal for quiet days.';

  @override
  String get orbEssenceName => 'Essential Orb';

  @override
  String get orbEssenceDesc =>
      'Generates extra Essence while walking. Does not accelerate channeling.';

  @override
  String get infuseEssence => 'Infuse Essence';

  @override
  String infuseEssenceDesc(Object essence, Object steps) {
    return 'Converts $essence Essence into $steps steps';
  }

  @override
  String essenceInfused(Object steps) {
    return '$steps steps obtained!';
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
      'A white furry slug with slow movements but quick thinking.';

  @override
  String get nameGamusarra => 'Gamusarra';

  @override
  String get descGamusarra =>
      'Gamusarra dwells in forests and rural roads where it is barely seen. It lures travelers with strange noises and playful jumps, but when anyone gets too close, it attacks with its sharp claws and vanishes into the undergrowth. It is said to appear only when no one can prove they have truly seen it.';

  @override
  String get nameTrasgueco => 'Trasgüeco';

  @override
  String get descTrasgueco =>
      'Trasgüeco lives in old houses and secluded granaries. At night, it moves objects around and leaves small wooden carvings as proof of its presence. Though it looks like a simple puppet, it moves when no one is watching and delights in testing the patience of those who try to catch it.';

  @override
  String get physicalActivity => 'Physical Activity';

  @override
  String get notificationsPermission => 'Notifications';

  @override
  String get backgroundExecution => 'Background Execution';

  @override
  String get granted => 'Granted';

  @override
  String get denied => 'Denied';

  @override
  String get permissionsMessage =>
      'Without these permissions the game will work, but with less precision.';

  @override
  String get openSystemSettings => 'Open system settings';

  @override
  String get stepCounter => 'Step Counter';

  @override
  String get lastUpdate => 'Last update';

  @override
  String get dataSource => 'Data source';

  @override
  String get deviceSensor => 'Device sensor';

  @override
  String minutesAgo(int minutes) {
    return '$minutes min ago';
  }

  @override
  String hoursAgo(int hours) {
    return '$hours h ago';
  }

  @override
  String get sensorActive => 'Active';

  @override
  String get sensorInactive => 'Inactive';

  @override
  String get systemStatus => 'System status';

  @override
  String get trackingActive => 'Tracking active';

  @override
  String get trackingPaused => 'Tracking paused';

  @override
  String get activeNotifications => 'Active notifications';

  @override
  String get sanctuariesInProgress => 'Sanctuaries in progress';

  @override
  String get lastSync => 'Last sync';

  @override
  String get systemHealthy => 'System working correctly';

  @override
  String get noIssues => 'No issues detected';

  @override
  String get none => 'None';

  @override
  String get justNow => 'Just now';

  @override
  String get adventureContinues => 'Wonderful!';

  @override
  String get explorerLevel => 'Explorer Level';

  @override
  String get howToGainXp => 'How to gain experience?';

  @override
  String get xpSourceBuyOrbs => 'Buy Orbs';

  @override
  String get xpSourceBuyBuildings => 'Buy Buildings';

  @override
  String get xpSourceChannelOrbs => 'Channel Orbs';

  @override
  String get xpSourceBuyUpgrades => 'Buy upgrades';

  @override
  String get xpSourceBuySanctuaries => 'Buy sanctuaries';

  @override
  String get xpSourceUpgradeSanctuaries => 'Upgrade sanctuaries';

  @override
  String get levelUpToUnlock => 'Level up to unlock new functionalities';

  @override
  String get understood => 'Understood';

  @override
  String get upgradeTapStrengthName => 'Tap Strength';

  @override
  String get upgradeTapStrengthDesc => 'Increases Essence generated per tap.';

  @override
  String get upgradeTapMultiplierName => 'Inner Rhythm';

  @override
  String get upgradeTapMultiplierDesc => 'Reduce tap cooling.';

  @override
  String get upgradeGlobalMultiplierName => 'Essential Flow';

  @override
  String get upgradeGlobalMultiplierDesc =>
      'Multiply the passive production of Essence.';

  @override
  String get upgradeOfflineEfficiencyName => 'Lingering Echo';

  @override
  String get upgradeOfflineEfficiencyDesc =>
      'Increases offline production efficiency.';

  @override
  String get upgradeOfflineTimeName => 'Durable Echo';

  @override
  String get upgradeOfflineTimeDesc => 'Increases offline production time.';

  @override
  String get perLevel => '/ level';

  @override
  String get building_recolector_name => 'Collector';

  @override
  String get building_recolector_desc =>
      'Generates basic essence automatically.';

  @override
  String get building_mina_name => 'Mine';

  @override
  String get building_mina_desc => 'Extracts essence from the earth.';

  @override
  String get building_cantera_name => 'Quarry';

  @override
  String get building_cantera_desc => 'Industrial essence production.';

  @override
  String get building_yacimiento_name => 'Deposit';

  @override
  String get building_yacimiento_desc => 'Massive source of pure essence.';

  @override
  String get building_fabrica_name => 'Factory';

  @override
  String get building_fabrica_desc => 'The pinnacle of essence technology.';

  @override
  String errOrbLimitReached(int max) {
    return 'Orb limit reached (max $max)';
  }

  @override
  String errInventoryLimitReached(int max) {
    return 'Sanctuary bag full (max $max)';
  }

  @override
  String get bagCapacity => 'Bag Capacity';

  @override
  String lockedAtLevel(int level) {
    return 'Locked (Level $level)';
  }

  @override
  String limitCountReached(int count, int max) {
    return 'Limit reached ($count/$max)';
  }

  @override
  String buildingLimitReached(Object max) {
    return 'Limit: $max';
  }

  @override
  String requiresLevel(Object level) {
    return 'Required Level $level';
  }
}
