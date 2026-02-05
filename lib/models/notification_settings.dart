class StillwalksSettings {
  // General
  final String language;
  final bool soundVibrationEnabled;
  final bool batterySaverMode;

  // Notificaciones
  final bool permanentNotificationEnabled;
  final bool eventsNotificationEnabled; // Orbes + Hitos de esencia
  final bool walkReminderEnabled;
  final String walkReminderPreset; // 'none', 'soft', 'normal'
  
  // Deprecated - kept for backward compatibility
  @Deprecated('Use eventsNotificationEnabled instead')
  bool get orbReadyNotificationEnabled => eventsNotificationEnabled;
  @Deprecated('Use eventsNotificationEnabled instead')
  bool get essenceMilestoneEnabled => eventsNotificationEnabled;

  // Bienestar
  final bool pauseProgress;
  final bool doNotDisturbEnabled;
  final String dndStartTime; // Formato "HH:mm"
  final String dndEndTime;   // Formato "HH:mm"
  final int dailyStepGoal; // 0 = Sin objetivo
  final bool dailyGoalNotificationEnabled;

  const StillwalksSettings({
    this.language = 'es',
    this.soundVibrationEnabled = true,
    this.batterySaverMode = false,
    this.permanentNotificationEnabled = true,
    this.eventsNotificationEnabled = true,
    this.walkReminderEnabled = false,
    this.walkReminderPreset = 'none',
    this.pauseProgress = false,
    this.doNotDisturbEnabled = false,
    this.dndStartTime = '22:00',
    this.dndEndTime = '08:00',
    this.dailyStepGoal = 5000,
    this.dailyGoalNotificationEnabled = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'language': language,
      'soundVibrationEnabled': soundVibrationEnabled,
      'batterySaverMode': batterySaverMode,
      'permanentNotificationEnabled': permanentNotificationEnabled,
      'eventsNotificationEnabled': eventsNotificationEnabled,
      'walkReminderEnabled': walkReminderEnabled,
      'walkReminderPreset': walkReminderPreset,
      'pauseProgress': pauseProgress,
      'doNotDisturbEnabled': doNotDisturbEnabled,
      'dndStartTime': dndStartTime,
      'dndEndTime': dndEndTime,
      'dailyStepGoal': dailyStepGoal,
      'dailyGoalNotificationEnabled': dailyGoalNotificationEnabled,
    };
  }

  factory StillwalksSettings.fromJson(Map<String, dynamic> json) {
    // Backward compatibility: if eventsNotificationEnabled doesn't exist,
    // fall back to orbReadyNotificationEnabled OR essenceMilestoneEnabled
    final eventsEnabled = json['eventsNotificationEnabled'] ??
        (json['orbReadyNotificationEnabled'] ?? json['essenceMilestoneEnabled'] ?? true);
    
    return StillwalksSettings(
      language: json['language'] ?? 'es',
      soundVibrationEnabled: json['soundVibrationEnabled'] ?? true,
      batterySaverMode: json['batterySaverMode'] ?? false,
      permanentNotificationEnabled: json['permanentNotificationEnabled'] ?? true,
      eventsNotificationEnabled: eventsEnabled,
      walkReminderEnabled: json['walkReminderEnabled'] ?? false,
      walkReminderPreset: json['walkReminderPreset'] ?? 'none',
      pauseProgress: json['pauseProgress'] ?? false,
      doNotDisturbEnabled: json['doNotDisturbEnabled'] ?? false,
      dndStartTime: json['dndStartTime'] ?? '22:00',
      dndEndTime: json['dndEndTime'] ?? '08:00',
      dailyStepGoal: json['dailyStepGoal'] ?? 5000,
      dailyGoalNotificationEnabled: json['dailyGoalNotificationEnabled'] ?? false,
    );
  }

  StillwalksSettings copyWith({
    String? language,
    bool? soundVibrationEnabled,
    bool? batterySaverMode,
    bool? permanentNotificationEnabled,
    bool? eventsNotificationEnabled,
    bool? walkReminderEnabled,
    String? walkReminderPreset,
    bool? pauseProgress,
    bool? doNotDisturbEnabled,
    String? dndStartTime,
    String? dndEndTime,
    int? dailyStepGoal,
    bool? dailyGoalNotificationEnabled,
  }) {
    return StillwalksSettings(
      language: language ?? this.language,
      soundVibrationEnabled: soundVibrationEnabled ?? this.soundVibrationEnabled,
      batterySaverMode: batterySaverMode ?? this.batterySaverMode,
      permanentNotificationEnabled: permanentNotificationEnabled ?? this.permanentNotificationEnabled,
      eventsNotificationEnabled: eventsNotificationEnabled ?? this.eventsNotificationEnabled,
      walkReminderEnabled: walkReminderEnabled ?? this.walkReminderEnabled,
      walkReminderPreset: walkReminderPreset ?? this.walkReminderPreset,
      pauseProgress: pauseProgress ?? this.pauseProgress,
      doNotDisturbEnabled: doNotDisturbEnabled ?? this.doNotDisturbEnabled,
      dndStartTime: dndStartTime ?? this.dndStartTime,
      dndEndTime: dndEndTime ?? this.dndEndTime,
      dailyStepGoal: dailyStepGoal ?? this.dailyStepGoal,
      dailyGoalNotificationEnabled: dailyGoalNotificationEnabled ?? this.dailyGoalNotificationEnabled,
    );
  }
}
