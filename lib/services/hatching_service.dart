import 'package:flutter/material.dart';
import 'package:stillwalks/models/creature_species.dart';
import 'package:stillwalks/models/creature_instance.dart';
import 'package:stillwalks/screens/channeling_screen.dart';

class HatchEvent {
  final BuildContext context;
  final CreatureSpecies species;
  final CreatureInstance instance;
  final bool isNew;
  final int channelingXp;
  final int discoveryXp;

  HatchEvent({
    required this.context,
    required this.species,
    required this.instance,
    required this.isNew,
    required this.channelingXp,
    required this.discoveryXp,
  });
}

class HatchingService extends ChangeNotifier {
  final List<HatchEvent> _queue = [];
  bool _isAnimating = false;

  void addHatchToQueue({
    required BuildContext context,
    required CreatureSpecies species,
    required CreatureInstance instance,
    required bool isNew,
    required int channelingXp,
    required int discoveryXp,
  }) {
    _queue.add(HatchEvent(
      context: context,
      species: species,
      instance: instance,
      isNew: isNew,
      channelingXp: channelingXp,
      discoveryXp: discoveryXp,
    ));
    
    _processQueue();
  }

  Future<void> _processQueue() async {
    if (_isAnimating || _queue.isEmpty) return;
    
    _isAnimating = true;
    final event = _queue.removeAt(0);

    // Check if context is still valid
    if (!event.context.mounted) {
      _isAnimating = false;
      _processQueue(); // Process next
      return;
    }

    // Navigate to ChannelingScreen and wait for it to pop
    await Navigator.push(
      event.context,
      MaterialPageRoute(
        builder: (_) => ChannelingScreen(
          species: event.species,
          instance: event.instance,
          isNew: event.isNew,
          channelingXp: event.channelingXp,
          discoveryXp: event.discoveryXp,
        ),
      ),
    );

    _isAnimating = false;
    
    // Small delay to prevent visual glitch/overlap
    await Future.delayed(const Duration(milliseconds: 300));
    
    // Process next item
    _processQueue();
  }
}
