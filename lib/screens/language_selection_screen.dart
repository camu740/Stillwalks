import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stillwalks/providers/locale_provider.dart';
import 'package:stillwalks/services/notification_preferences_service.dart';
import 'package:stillwalks/l10n/app_localizations.dart';

class LanguageSelectionScreen extends StatelessWidget {
  const LanguageSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Access supported locales from AppLocalizations
    final supportedLocales = AppLocalizations.supportedLocales;
    final localeProvider = Provider.of<LocaleProvider>(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.language,
                size: 80,
                color: Colors.deepPurpleAccent,
              ),
              const SizedBox(height: 32),
              Text(
                l10n.languageSelectionTitle,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.languageSelectionSubtitle,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              
              // Dynamic list of languages
              ...supportedLocales.map((locale) {
                final isSelected = localeProvider.locale.languageCode == locale.languageCode;
                
                String label;
                String flag;

                switch (locale.languageCode) {
                  case 'es':
                    label = 'Español';
                    flag = '🇪🇸';
                    break;
                  case 'en':
                    label = 'English';
                    flag = '🇺🇸';
                    break;
                  default:
                    label = locale.languageCode.toUpperCase();
                    flag = '🌍';
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: InkWell(
                    onTap: () {
                       Provider.of<LocaleProvider>(context, listen: false).setLocale(locale.languageCode);
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.deepPurpleAccent.withOpacity(0.2) : Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? Colors.deepPurpleAccent : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(flag, style: const TextStyle(fontSize: 24)),
                          const SizedBox(width: 16),
                          Text(
                            label,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected ? Colors.white : Colors.white70,
                            ),
                          ),
                          const Spacer(),
                          if (isSelected)
                            const Icon(Icons.check_circle, color: Colors.deepPurpleAccent),
                        ],
                      ),
                    ),
                  ),
                );
              }),

              const Spacer(),
              
              ElevatedButton(
                onPressed: () async {
                  final prefs = Provider.of<NotificationPreferencesService>(context, listen: false);
                  final currentLocale = localeProvider.locale.languageCode;
                  
                  // Save language and mark as selected
                  await prefs.setLanguage(currentLocale);
                  
                  // The AppInitializer will rebuild and proceed to PermissionsScreen
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.deepPurple,
                ),
                child: Text(
                  l10n.languageSelectionContinue,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
