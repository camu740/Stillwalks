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
  String get soundVibration => 'Sound / vibration';

  @override
  String get soundVibrationDesc => 'Sound and haptic feedback';

  @override
  String get batterySaver => 'Battery saver mode';

  @override
  String get batterySaverDesc => 'Reduce battery consumption';

  @override
  String get permanent => 'Permanent';

  @override
  String get permanentDesc => 'Active background tracking';

  @override
  String get events => 'Events';

  @override
  String get eventsDesc => 'Orbs and essence milestones';

  @override
  String get reminders => 'Reminders';

  @override
  String get remindersDesc => 'Walking invitations';

  @override
  String get disabledInBatterySaver => 'Disabled in battery saver';

  @override
  String get pauseProgress => 'Pause progress';

  @override
  String get pauseProgressDesc => 'Temporarily stop tracking';

  @override
  String get doNotDisturb => 'Do not disturb hours';

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
  String get dailyGoal => 'Daily goal';

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
  String get trackingStatus => 'Tracking status';

  @override
  String get trackingStatusDesc => 'View activity log';

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
  String get orbs => 'Orbs';

  @override
  String get sanctuary => 'Sanctuary';

  @override
  String get collection => 'Collection';

  @override
  String get shop => 'Shop';

  @override
  String get freeSlot => 'Free slot';

  @override
  String get activeOrb => 'Active orb';

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
  String get basePower => 'Base power';

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
  String get permissionsRequired => 'Required Permissions';

  @override
  String get permissionsDescription =>
      'Stillwalks needs the following permissions to work:';

  @override
  String get activityPermission => 'Physical activity';

  @override
  String get activityPermissionDesc => 'To count steps';

  @override
  String get notificationPermission => 'Notifications';

  @override
  String get notificationPermissionDesc => 'To show progress';

  @override
  String get requestPermissions => 'Request permissions';

  @override
  String get continueButton => 'Continue';

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
  String get walkReminder => 'Walking reminder';

  @override
  String get orbReady => 'Orb ready';

  @override
  String get milestoneReached => 'Milestone reached!';

  @override
  String get essenceGenerated => 'Essence generated';

  @override
  String get locked => 'Locked';

  @override
  String get unlocked => 'Unlocked';

  @override
  String get upgrade => 'Upgrade';

  @override
  String get maxLevel => 'Max level';

  @override
  String get perHour => '/ hour';

  @override
  String get level => 'Lv.';

  @override
  String get orbsReady => 'Orb ready to channel!';

  @override
  String get noActiveOrbs => 'Active orbs';

  @override
  String get idleProduction => 'Idle production';

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
  String upgradeCompleted(String name) {
    return 'Upgrade \"$name\" completed!';
  }

  @override
  String sanctuaryUpgraded(String name, int level) {
    return '$name upgraded to Level $level!';
  }

  @override
  String get checkBag => 'Check your Bag';

  @override
  String get permanentSanctuaryUpgrades => 'Permanent Sanctuary Upgrades';

  @override
  String get globalUpgrades => 'Global Upgrades';

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
  String get channelNow => 'Channel now!';

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
  String get rarityLegendary => 'Legendario';

  @override
  String get selectSanctuary => 'Select Sanctuary';

  @override
  String get selectOrbTitle => 'Select Orb';

  @override
  String get waitingOrbs => 'Orbs on Hold';

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
  String get emptyInventoryBag => 'Inventory bag empty';

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
      'You already have an active temporary sanctuary';

  @override
  String get newCreatureBadge => 'NEW!';

  @override
  String get useSingular => 'use';

  @override
  String get usesPlural => 'uses';

  @override
  String get energyStorage => 'Energy Storage';

  @override
  String get orbReadyTitle => '✨ Orb Ready';

  @override
  String orbReadyBody(String type) {
    return 'Your $type finished channeling';
  }

  @override
  String get walkReminderTitle => '🌿 Time for a Walk';

  @override
  String get walkMsg1 => 'A quiet walk?';

  @override
  String get walkMsg2 => 'Maybe it\'s a good time for a walk';

  @override
  String get walkMsg3 => 'Fresh air is always good';

  @override
  String get walkMsg4 => 'How about stretching your legs?';

  @override
  String get noGoal => 'No Goal';

  @override
  String get notifyGoal => 'Notify on goal reached';

  @override
  String get notifyGoalDesc =>
      'Get notified when you reach your daily step goal';

  @override
  String get goalReachedTitle => 'Goal Reached!';

  @override
  String goalReachedBody(Object goal) {
    return 'You reached your daily goal of $goal steps';
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
  String get chooseEnergyTransfer => 'Choose energy to transfer:';

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
  String get stats => 'Stats:';

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
      'Infinite Channeling. Never runs out and allows channeling of any orb type.';

  @override
  String get improveSpeedHint =>
      'Upgrade channeling speed in the shop to reduce required steps.';

  @override
  String get activateSanctuary => 'Activate';

  @override
  String get tapToSelectSanctuary => 'Tap to select sanctuary';

  @override
  String emptyUses(int count) {
    return 'Empty ($count uses)';
  }

  @override
  String get tapToActivate => 'Tap to activate';

  @override
  String get typeTemporary => 'Type: Temporary Sanctuary';

  @override
  String get noSanctuariesInBag => 'No available sanctuaries';

  @override
  String remainingUses(int count) {
    return 'Remaining uses: $count';
  }

  @override
  String get destroyWarning =>
      'Automatically destroyed after depleting all uses.';

  @override
  String get abilityFastFlow =>
      'Reduces required steps by 10% (1.11x speed multiplier).';

  @override
  String get abilitySymbiosis =>
      'Grants 1 Essence for every 10 steps taken during channeling.';

  @override
  String get abilityQuietude =>
      'Allows hatching orbs using Essence instead of steps.';

  @override
  String get abilityEcho =>
      'Reduces steps by 70% but only generates common/uncommon creatures.';

  @override
  String get abilityResonance =>
      'Increases chance of obtaining rare creatures by +10%.';

  @override
  String get sanctuary_temp_sanctuary_symbiosis_desc =>
      'Generates extra Essence upon orb completion.';

  @override
  String get abilityActive => 'Special ability active.';

  @override
  String get sanctuary_temp_sanctuary_quietude_name => 'Quietude Sanctuary';

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
      'The first discovered sanctuary. A peaceful place where Orbs can channel their energy.';

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
  String get sancResonanceDesc => '+10% rare chance (1 use)';

  @override
  String get orbBasicName => 'Basic Orb';

  @override
  String get orbBasicDesc => 'A common Orb. Requires 2000 steps.';

  @override
  String get orbAdvancedName => 'Advanced Orb';

  @override
  String get orbAdvancedDesc =>
      'Better chance for Uncommon. Requires 5000 steps.';

  @override
  String get orbExpertName => 'Expert Orb';

  @override
  String get orbExpertDesc => 'Better chance for Rare. Requires 10000 steps.';

  @override
  String get orbQuietudeName => 'Quietude Orb';

  @override
  String get orbQuietudeDesc =>
      'Allows using Essence to progress. Ideal for quiet days.';

  @override
  String get orbEssenceName => 'Essence Orb';

  @override
  String get orbEssenceDesc => 'Generates extra Essence while walking.';

  @override
  String get infuseEssence => 'Infuse Essence';

  @override
  String infuseEssenceDesc(Object essence, Object steps) {
    return 'Convert $essence Essence into $steps steps';
  }

  @override
  String essenceInfused(Object steps) {
    return '$steps steps gained!';
  }

  @override
  String get descSpiristone =>
      'A small enchanted stone with tiny hands and legs. Curious and friendly.';

  @override
  String get descRadispirit =>
      'A magical radish walking on four legs. Its leaves glow at sunset.';

  @override
  String get descSlugrry =>
      'A furry white slug with slow movements but quick thinking.';

  @override
  String get physicalActivity => 'Physical activity';

  @override
  String get notificationsPermission => 'Notifications';

  @override
  String get backgroundExecution => 'Background execution';

  @override
  String get granted => 'Granted';

  @override
  String get denied => 'Denied';

  @override
  String get permissionsMessage =>
      'Without these permissions the game works, but with less accuracy.';

  @override
  String get openSystemSettings => 'Open system settings';

  @override
  String get stepCounter => 'Step counter';

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
  String get lastSync => 'Last synchronization';

  @override
  String get systemHealthy => 'System working correctly';

  @override
  String get noIssues => 'No issues detected';

  @override
  String get none => 'None';

  @override
  String get justNow => 'Just now';

  @override
  String get tutorialWelcome => 'WELCOME TO STILLWALKS';

  @override
  String get tutorialWelcomeDesc =>
      'Discover magical creatures by walking in the real world and using your phone less.\n\nWhen your phone is locked,\nyou generate Essence automatically.\n\n\nEssence helps you advance and discover new creatures.\n\nTo start your adventure,\nwe grant you enough Essence\nto buy your first Orb.';

  @override
  String get startAdventure => 'Start Adventure!';

  @override
  String essenceGrant(Object amount) {
    return '+$amount Essence received';
  }

  @override
  String get energyTutorialTitle => 'ENERGY NEEDED!';

  @override
  String get energyTutorialDesc =>
      'Orbs are channeled in Sanctuaries.\n\nBy walking, you generate Energy.\nEnergy channels the Orb until it is ready to discover the stillwalk inside.\n\nSince it\'s your first time,\nlet\'s speed up the process a bit.';

  @override
  String get walkingSim => 'Walking...';

  @override
  String get letsGo => 'Let\'s Go!';

  @override
  String get tutorialCompleteTitle => 'Tutorial Completed!';

  @override
  String get tutorialCompleteDesc =>
      'Congratulations! You are now free to explore the real world to find more creatures.\n\nRemember: You have to move to get Essence!';

  @override
  String get tutorialConclusionTitle => 'YOUR ADVENTURE CONTINUES';

  @override
  String get tutorialConclusionDesc =>
      'Use the Essence you get from resting to buy orbs, upgrade sanctuaries, and advance. Remember to go for a walk to continue channeling orbs and discover all the creatures!\n\nStillwalks moves with you,\nat your own pace.';
}
