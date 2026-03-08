import 'package:flutter/material.dart';

/// Application-wide constants for the Kigali Directory app.
class AppConstants {
  // ── App Info ──────────────────────────────────────────────────────────────
  static const String appName = 'Kigali Directory';
  static const String appTagline = 'Find Services & Places in Kigali';

  // ── Kigali Default Coordinates ────────────────────────────────────────────
  static const double kigaliLat = -1.9403;
  static const double kigaliLng = 29.8739;
  static const double defaultZoom = 13.0;
  static const double detailMapZoom = 15.0;

  // ── Firestore Collections ─────────────────────────────────────────────────
  static const String usersCollection = 'users';
  static const String listingsCollection = 'listings';

  // ── Listing Categories ────────────────────────────────────────────────────
  static const List<String> categories = [
    'Hospital',
    'Police Station',
    'Library',
    'Utility Office',
    'Restaurant',
    'Café',
    'Park',
    'Tourist Attraction',
  ];

  // ── Category Icons ────────────────────────────────────────────────────────
  static IconData categoryIcon(String category) {
    switch (category) {
      case 'Hospital':
        return Icons.local_hospital;
      case 'Police Station':
        return Icons.local_police;
      case 'Library':
        return Icons.local_library;
      case 'Utility Office':
        return Icons.business;
      case 'Restaurant':
        return Icons.restaurant;
      case 'Café':
        return Icons.coffee;
      case 'Park':
        return Icons.park;
      case 'Tourist Attraction':
        return Icons.attractions;
      default:
        return Icons.place;
    }
  }

  // ── Category Colors ───────────────────────────────────────────────────────
  static Color categoryColor(String category) {
    switch (category) {
      case 'Hospital':
        return Colors.red.shade600;
      case 'Police Station':
        return Colors.blue.shade800;
      case 'Library':
        return Colors.amber.shade700;
      case 'Utility Office':
        return Colors.grey.shade700;
      case 'Restaurant':
        return Colors.orange.shade600;
      case 'Café':
        return Colors.brown.shade500;
      case 'Park':
        return Colors.green.shade600;
      case 'Tourist Attraction':
        return Colors.purple.shade500;
      default:
        return Colors.teal;
    }
  }

  // ── Theme ─────────────────────────────────────────────────────────────────
  static const Color primaryColor = Color(0xFF0D7377);
  static const Color primaryDark = Color(0xFF095456);
  static const Color accentColor = Color(0xFF14BDEB);
  static const Color scaffoldBg = Color(0xFFF5F7FA);
  static const Color cardBg = Colors.white;
  static const Color errorColor = Color(0xFFD32F2F);
  static const Color successColor = Color(0xFF388E3C);
}
