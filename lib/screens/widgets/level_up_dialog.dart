import 'package:flutter/material.dart';
import 'package:stillwalks/services/progression_service.dart';
import 'package:stillwalks/l10n/app_localizations.dart';

class LevelUpDialog extends StatelessWidget {
  final int newLevel;
  final List<Unlock> unlocks;
  final VoidCallback onDismiss;

  const LevelUpDialog({
    super.key,
    required this.newLevel,
    required this.unlocks,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.deepPurple.shade900,
              Colors.black,
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.amber, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.amber.withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            const Icon(Icons.star, size: 64, color: Colors.amber),
            const SizedBox(height: 16),
            Text(
              '¡NIVEL ALCANZADO!', // TODO: Localize
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.amber,
                letterSpacing: 2,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Nivel de Explorador $newLevel', // TODO: Localize
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            
            // Unlocks
            if (unlocks.isNotEmpty) ...[
              const Divider(color: Colors.white24),
              const SizedBox(height: 16),
              const Text(
                'DESBLOQUEADO:', // TODO: Localize
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: unlocks.length,
                  itemBuilder: (context, index) {
                    final unlock = unlocks[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Icon(_getUnlockIcon(unlock.type), color: Colors.greenAccent),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              unlock.description ?? 'Nuevo contenido',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ] else 
              const Text(
                '¡Sigue explorando para más recompensas!',
                style: TextStyle(color: Colors.white70),
                textAlign: TextAlign.center,
              ),

            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: onDismiss,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'CONTINUAR', // TODO: Localize
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getUnlockIcon(UnlockType type) {
    switch (type) {
      case UnlockType.feature:
        return Icons.extension;
      case UnlockType.item:
        return Icons.shopping_bag;
      case UnlockType.upgradeCap:
        return Icons.arrow_upward;
    }
  }
}
