import 'package:flutter/material.dart';
import 'package:stillwalks/l10n/app_localizations.dart';

/// FAQ/Help screen with frequently asked questions
class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(l10n.helpTitle),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildFAQItem(
            question: l10n.helpEssenceQ,
            answer: l10n.helpEssenceA,
          ),
          
          _buildFAQItem(
            question: l10n.helpOrbsQ,
            answer: l10n.helpOrbsA,
          ),
          
          _buildFAQItem(
            question: l10n.helpSanctuariesQ,
            answer: l10n.helpSanctuariesA,
          ),
          
          _buildFAQItem(
            question: l10n.helpStepsQ,
            answer: l10n.helpStepsA,
          ),
          
          _buildFAQItem(
            question: l10n.helpStepsDelayQ,
            answer: l10n.helpStepsDelayA,
          ),
          
          _buildFAQItem(
            question: l10n.helpNotificationsQ,
            answer: l10n.helpNotificationsA,
          ),
          
          _buildFAQItem(
            question: l10n.helpPermissionsQ,
            answer: l10n.helpPermissionsA,
          ),
          
          _buildFAQItem(
            question: l10n.helpBatteryQ,
            answer: l10n.helpBatteryA,
          ),
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildFAQItem({
    required String question,
    required String answer,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Theme(
        data: ThemeData(
          dividerColor: Colors.transparent,
          textTheme: const TextTheme(
            titleMedium: TextStyle(color: Colors.white),
            bodyMedium: TextStyle(color: Colors.white70),
          ),
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          iconColor: Colors.tealAccent,
          collapsedIconColor: Colors.white54,
          title: Text(
            question,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          children: [
            Text(
              answer,
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
