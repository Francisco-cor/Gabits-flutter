import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Initialized in main.dart and overridden via ProviderScope
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (_) => throw UnimplementedError('SharedPreferences not initialized'),
);

class AppSettings {
  final ThemeMode themeMode;
  final Locale? locale;

  const AppSettings({
    this.themeMode = ThemeMode.dark,
    this.locale,
  });

  AppSettings copyWith({ThemeMode? themeMode}) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      locale: locale,
    );
  }
}

class SettingsNotifier extends Notifier<AppSettings> {
  static const _themeModeKey = 'theme_mode';
  static const _localeKey = 'locale';

  SharedPreferences get _prefs => ref.read(sharedPreferencesProvider);

  @override
  AppSettings build() {
    final prefs = ref.read(sharedPreferencesProvider);
    final savedIndex = prefs.getInt(_themeModeKey);
    // Default to dark mode if nothing saved yet
    final themeMode = savedIndex != null
        ? ThemeMode.values[savedIndex]
        : ThemeMode.dark;
    final localeString = prefs.getString(_localeKey);
    return AppSettings(
      themeMode: themeMode,
      locale: localeString != null ? Locale(localeString) : null,
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await _prefs.setInt(_themeModeKey, mode.index);
    state = state.copyWith(themeMode: mode);
  }

  Future<void> setLocale(Locale? locale) async {
    if (locale != null) {
      await _prefs.setString(_localeKey, locale.languageCode);
    } else {
      await _prefs.remove(_localeKey);
    }
    state = AppSettings(themeMode: state.themeMode, locale: locale);
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, AppSettings>(
  SettingsNotifier.new,
);
