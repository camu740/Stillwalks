import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stillwalks/services/notification_preferences_service.dart';
import 'package:stillwalks/providers/locale_provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:stillwalks/l10n/app_localizations.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _appVersion = '';

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = packageInfo.version;
    });
  }

  @override
  Widget build(BuildContext context) {
    final preferencesService = Provider.of<NotificationPreferencesService>(context);
    final settings = preferencesService.settings;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.settings),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        children: [
          // GENERAL Section
          _buildSectionHeader(AppLocalizations.of(context)!.general),
          _buildSettingTile(
            icon: Icons.language,
            iconColor: Colors.tealAccent,
            title: AppLocalizations.of(context)!.language,
            subtitle: _getLanguageName(settings.language),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white54),
            onTap: () => _showLanguageDialog(context, preferencesService),
          ),
          _buildSwitchTile(
            icon: Icons.volume_up,
            iconColor: Colors.orangeAccent,
            title: AppLocalizations.of(context)!.soundVibration,
            value: settings.soundVibrationEnabled,
            onChanged: (value) => preferencesService.setSoundVibrationEnabled(value),
          ),
          _buildSwitchTile(
            icon: Icons.battery_saver,
            iconColor: Colors.greenAccent,
            title: AppLocalizations.of(context)!.batterySaver,
            value: settings.batterySaverMode,
            onChanged: (value) => preferencesService.setBatterySaverMode(value),
          ),

          // NOTIFICACIONES Section
          _buildSectionHeader(AppLocalizations.of(context)!.notifications),
          _buildSwitchTile(
            icon: Icons.notifications_active,
            iconColor: Colors.purpleAccent,
            title: AppLocalizations.of(context)!.permanent,
            subtitle: AppLocalizations.of(context)!.permanentDesc,
            value: settings.permanentNotificationEnabled,
            onChanged: (value) => preferencesService.setPermanentNotificationEnabled(value),
          ),
          _buildSwitchTile(
            icon: Icons.auto_awesome,
            iconColor: Colors.amberAccent,
            title: AppLocalizations.of(context)!.events,
            subtitle: AppLocalizations.of(context)!.eventsDesc,
            value: settings.eventsNotificationEnabled,
            onChanged: (value) => preferencesService.setEventsNotificationEnabled(value),
          ),
          _buildSwitchTile(
            icon: Icons.directions_walk,
            iconColor: settings.batterySaverMode ? Colors.grey : Colors.blueAccent,
            title: AppLocalizations.of(context)!.reminders,
            subtitle: settings.batterySaverMode 
                ? AppLocalizations.of(context)!.disabledInBatterySaver
                : AppLocalizations.of(context)!.remindersDesc,
            value: settings.walkReminderEnabled,
            onChanged: settings.batterySaverMode 
                ? null // Disable toggle when battery saver is on
                : (value) {
                    if (value) {
                      preferencesService.setWalkReminderPreset('soft');
                    } else {
                      preferencesService.setWalkReminderPreset('none');
                    }
                  },
          ),
          _buildSwitchTile(
            icon: Icons.emoji_events,
            iconColor: settings.dailyStepGoal == 0 ? Colors.grey : Colors.amber, 
            title: AppLocalizations.of(context)!.notifyGoal,
            subtitle: AppLocalizations.of(context)!.notifyGoalDesc,
            value: settings.dailyGoalNotificationEnabled,
            onChanged: settings.dailyStepGoal == 0
                ? null // Disabled if 0
                : (value) => preferencesService.setDailyGoalNotificationEnabled(value),
          ),

          // BIENESTAR Section
          _buildSectionHeader(AppLocalizations.of(context)!.wellbeing),
          _buildSwitchTile(
            icon: Icons.pause_circle_filled,
            iconColor: Colors.redAccent,
            title: AppLocalizations.of(context)!.pauseProgress,
            subtitle: AppLocalizations.of(context)!.pauseProgressDesc,
            value: settings.pauseProgress,
            onChanged: (value) => preferencesService.setPauseProgress(value),
          ),
          _buildSettingTile(
            icon: Icons.nights_stay,
            iconColor: Colors.indigoAccent,
            title: AppLocalizations.of(context)!.doNotDisturb,
            subtitle: settings.doNotDisturbEnabled 
                ? AppLocalizations.of(context)!.dndTimeRange(settings.dndStartTime, settings.dndEndTime)
                : AppLocalizations.of(context)!.configure,
            trailing: Switch(
              value: settings.doNotDisturbEnabled,
              onChanged: (value) => preferencesService.setDoNotDisturbEnabled(value),
              activeColor: Colors.indigoAccent,
            ),
            onTap: settings.doNotDisturbEnabled 
                ? () => _showDndTimeDialog(context, preferencesService)
                : null,
          ),
          _buildSettingTile(
            icon: Icons.flag,
            iconColor: Colors.cyanAccent,
            title: AppLocalizations.of(context)!.dailyGoal,
            subtitle: settings.dailyStepGoal == 0 
                ? AppLocalizations.of(context)!.noGoal 
                : AppLocalizations.of(context)!.dailyGoalSteps(settings.dailyStepGoal),
            onTap: () => _showDailyGoalDialog(context, preferencesService),
          ),


          // PRIVACIDAD Y SISTEMA Section
          _buildSectionHeader(AppLocalizations.of(context)!.privacySystem),
          _buildSettingTile(
            icon: Icons.security,
            iconColor: Colors.grey,
            title: AppLocalizations.of(context)!.permissions,
            subtitle: AppLocalizations.of(context)!.permissionsDesc,
            onTap: () {
              // TODO: Abrir ajustes de permisos
            },
          ),
          _buildSettingTile(
            icon: Icons.sensors,
            iconColor: Colors.grey,
            title: AppLocalizations.of(context)!.sensors,
            subtitle: AppLocalizations.of(context)!.sensorsDesc,
            onTap: () {
              // TODO: Mostrar estado de sensores
            },
          ),
          _buildSettingTile(
            icon: Icons.query_stats,
            iconColor: Colors.grey,
            title: AppLocalizations.of(context)!.trackingStatus,
            subtitle: AppLocalizations.of(context)!.trackingStatusDesc,
            onTap: () {
              // TODO: Mostrar log técnico
            },
          ),

          // INFORMACIÓN Section
          _buildSectionHeader(AppLocalizations.of(context)!.information),
          _buildSettingTile(
            icon: Icons.help_outline,
            iconColor: Colors.white54,
            title: AppLocalizations.of(context)!.help,
            onTap: () {
              // TODO: Abrir guía de uso
            },
          ),
          _buildSettingTile(
            icon: Icons.mail_outline,
            iconColor: Colors.white54,
            title: AppLocalizations.of(context)!.contact,
            onTap: () {
              // TODO: Abrir email de soporte
            },
          ),
          _buildSettingTile(
            icon: Icons.people_outline,
            iconColor: Colors.white54,
            title: AppLocalizations.of(context)!.credits,
            subtitle: AppLocalizations.of(context)!.version(_appVersion),
            onTap: () {
              // TODO: Mostrar créditos
            },
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  String _getLanguageName(String languageCode) {
    final l10n = AppLocalizations.of(context)!;
    switch (languageCode) {
      case 'es':
        return l10n.spanish;
      case 'en':
        return l10n.english;
      case 'system':
        return l10n.system;
      default:
        return l10n.spanish;
    }
  }

  void _showLanguageDialog(BuildContext context, NotificationPreferencesService service) {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(AppLocalizations.of(context)!.selectLanguage),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDialogOption(
              title: 'Español',
              isSelected: service.settings.language == 'es',
              onTap: () {
                service.setLanguage('es');
                localeProvider.setLocale('es');
                Navigator.pop(context);
              },
            ),
            _buildDialogOption(
              title: 'English',
              isSelected: service.settings.language == 'en',
              onTap: () {
                service.setLanguage('en');
                localeProvider.setLocale('en');
                Navigator.pop(context);
              },
            ),
            _buildDialogOption(
              title: 'Sistema',
              isSelected: service.settings.language == 'system',
              onTap: () {
                service.setLanguage('system');
                localeProvider.setLocale('system');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDailyGoalDialog(BuildContext context, NotificationPreferencesService service) {
    int currentGoal = service.settings.dailyStepGoal;
    final List<int> goals = [0, 3000, 5000, 7000, 10000, 12000, 15000];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(AppLocalizations.of(context)!.selectDailyGoal),
        content: SingleChildScrollView(
          child: Column(
          mainAxisSize: MainAxisSize.min,
          children: goals.map((goal) => _buildDialogOption(
            title: goal == 0 
                ? AppLocalizations.of(context)!.noGoal 
                : '${goal.toString()} ${AppLocalizations.of(context)!.stepsLower}',
            isSelected: currentGoal == goal,
            onTap: () {
              service.setDailyStepGoal(goal);
              Navigator.pop(context);
            },
          )).toList(),
        ),
       ),
      ),
    );
  }

  void _showDndTimeDialog(BuildContext context, NotificationPreferencesService service) async {
    final settings = service.settings;
    
    // Simplificado para usar TimePickers de Flutter de forma secuencial
    final startParts = settings.dndStartTime.split(':');
    final endParts = settings.dndEndTime.split(':');
    
    final startTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: int.parse(startParts[0]), minute: int.parse(startParts[1])),
      helpText: 'HORA DE INICIO',
    );

    if (startTime != null && mounted) {
      final endTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay(hour: int.parse(endParts[0]), minute: int.parse(endParts[1])),
        helpText: 'HORA DE FIN',
      );

      if (endTime != null) {
        final startStr = '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';
        final endStr = '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}';
        service.setDndStartTime(startStr);
        service.setDndEndTime(endStr);
      }
    }
  }

  Widget _buildDialogOption({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return ListTile(
      title: Text(title, style: TextStyle(
        color: isSelected ? Colors.tealAccent : Colors.white,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      )),
      trailing: isSelected ? const Icon(Icons.check, color: Colors.tealAccent) : null,
      onTap: onTap,
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white54,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: ListTile(
        leading: Icon(icon, color: iconColor),
        title: Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: const TextStyle(fontSize: 12, color: Colors.white70),
              )
            : null,
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool>? onChanged, // Made nullable to support disabled state
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: value ? iconColor.withOpacity(0.3) : Colors.white.withOpacity(0.1),
        ),
      ),
      child: SwitchListTile(
        secondary: Icon(icon, color: iconColor),
        title: Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: const TextStyle(fontSize: 12, color: Colors.white70),
              )
            : null,
        value: value,
        onChanged: onChanged,
        activeColor: iconColor,
      ),
    );
  }
}
