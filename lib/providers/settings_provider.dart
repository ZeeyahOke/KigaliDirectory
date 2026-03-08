import 'package:flutter/material.dart';

/// Provider managing user settings and preferences.
///
/// Handles notification toggle (simulated locally) and other
/// user-configurable settings.
class SettingsProvider extends ChangeNotifier {
  // ── State fields ──────────────────────────────────────────────────────────
  bool _locationNotificationsEnabled = false;

  // ── Getters ───────────────────────────────────────────────────────────────
  bool get locationNotificationsEnabled => _locationNotificationsEnabled;

  // ═══════════════════════════════════════════════════════════════════════════
  // ACTIONS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Toggles the location-based notifications preference.
  ///
  /// This is a local simulation — in a production app, this would persist
  /// to shared preferences or Firestore and configure actual push notifications.
  void toggleLocationNotifications(bool value) {
    _locationNotificationsEnabled = value;
    notifyListeners();
  }
}
