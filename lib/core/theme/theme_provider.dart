import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/pref_keys.dart';
import '../di/providers.dart';

/// Persisted [ThemeMode] for the app.
///
/// Written through to SharedPreferences so the user's choice survives restart,
/// and exposed as a `Notifier` so `MaterialApp.router` rebuilds immediately.
class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final stored = prefs.getString(PrefKeys.themeMode);
    return _decode(stored);
  }

  Future<void> setMode(ThemeMode mode) async {
    if (state == mode) return;
    state = mode;
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(PrefKeys.themeMode, _encode(mode));
  }

  Future<void> cycle() {
    final next = switch (state) {
      ThemeMode.system => ThemeMode.light,
      ThemeMode.light => ThemeMode.dark,
      ThemeMode.dark => ThemeMode.system,
    };
    return setMode(next);
  }

  static ThemeMode _decode(String? value) => switch (value) {
    'light' => ThemeMode.light,
    'dark' => ThemeMode.dark,
    _ => ThemeMode.system,
  };

  static String _encode(ThemeMode mode) => switch (mode) {
    ThemeMode.light => 'light',
    ThemeMode.dark => 'dark',
    ThemeMode.system => 'system',
  };
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);
