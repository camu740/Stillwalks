import 'package:flutter/material.dart';

/// Representa un objeto en el inventario (Bolsa)
class InventoryItem {
  final String id;
  final String typeId;
  final int quantity;
  final Map<String, dynamic>? metadata;

  InventoryItem({
    required this.id,
    required this.typeId,
    required this.quantity,
    this.metadata,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'typeId': typeId,
      'quantity': quantity,
      'metadata': metadata != null ? metadata.toString() : null, // Simplificado para SQLite
    };
  }

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    return InventoryItem(
      id: json['id'] as String,
      typeId: json['typeId'] as String,
      quantity: json['quantity'] as int,
      // Metadata se ignorará o parseará si es necesario en el futuro
    );
  }
}

/// Tipos de objetos de inventario definidos en el diseño
class InventoryItemTypes {
  static const String tempSanctuaryFastFlow = 'temp_sanctuary_fast_flow';
  static const String tempSanctuarySymbiosis = 'temp_sanctuary_symbiosis';
  static const String tempSanctuaryQuietude = 'temp_sanctuary_quietude';
  static const String tempSanctuaryEcho = 'temp_sanctuary_echo';
  static const String tempSanctuaryResonance = 'temp_sanctuary_resonance';
  
  static String getName(String typeId) {
    switch (typeId) {
      case tempSanctuaryFastFlow: return 'Santuario de Flujo Rápido';
      case tempSanctuarySymbiosis: return 'Santuario de Simbiosis';
      case tempSanctuaryQuietude: return 'Santuario de Quietud Absoluta';
      case tempSanctuaryEcho: return 'Santuario del Eco Vital';
      case tempSanctuaryResonance: return 'Santuario de Resonancia';
      default: return 'Objeto Desconocido';
    }
  }

  static String getShortName(String typeId) {
    switch (typeId) {
      case tempSanctuaryFastFlow: return 'Flujo Rápido';
      case tempSanctuarySymbiosis: return 'Simbiosis';
      case tempSanctuaryQuietude: return 'Quietud Absoluta';
      case tempSanctuaryEcho: return 'Eco Vital';
      case tempSanctuaryResonance: return 'Resonancia';
      default: return 'Desconocido';
    }
  }

  static String getDescription(String typeId) {
    switch (typeId) {
      case tempSanctuaryFastFlow: return '-50% pasos requeridos (1 uso)';
      case tempSanctuarySymbiosis: return '+1 Esencia cada 10 pasos (2 usos)';
      case tempSanctuaryQuietude: return 'Eclosión con Esencia (1 uso)';
      case tempSanctuaryEcho: return '-70% pasos | Solo comunes/inusuales (1 uso)';
      case tempSanctuaryResonance: return '+10% prob. criatura rara (1 uso)';
      default: return '';
    }
  }

  static IconData getIcon(String typeId) {
    switch (typeId) {
      case tempSanctuaryFastFlow: return Icons.flash_on;
      case tempSanctuarySymbiosis: return Icons.all_inclusive;
      case tempSanctuaryQuietude: return Icons.self_improvement;
      case tempSanctuaryEcho: return Icons.graphic_eq;
      case tempSanctuaryResonance: return Icons.blur_circular;
      default: return Icons.auto_awesome;
    }
  }
}
