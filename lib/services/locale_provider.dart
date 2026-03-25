import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages the app's locale/language setting.
/// Persists the user's language choice using SharedPreferences.
class LocaleProvider extends ChangeNotifier {
  static const String _localeKey = 'selected_locale';

  Locale _locale = const Locale('en');
  Locale get locale => _locale;

  /// Supported locales
  static const List<Locale> supportedLocales = [
    Locale('en'), // English
    Locale('hi'), // Hindi
    Locale('mr'), // Marathi
  ];

  /// Locale names for display
  static const Map<String, String> localeNames = {
    'en': 'English',
    'hi': 'हिंदी',
    'mr': 'मराठी',
  };

  LocaleProvider() {
    _loadLocale();
  }

  /// Load saved locale from SharedPreferences
  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLocale = prefs.getString(_localeKey);
    if (savedLocale != null && supportedLocales.any((l) => l.languageCode == savedLocale)) {
      _locale = Locale(savedLocale);
      notifyListeners();
    }
  }

  /// Change the app's locale and persist the choice
  Future<void> setLocale(Locale locale) async {
    if (!supportedLocales.contains(locale)) return;

    _locale = locale;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, locale.languageCode);
  }

  /// Get the display name for a locale
  static String getLocaleName(Locale locale) {
    return localeNames[locale.languageCode] ?? locale.languageCode;
  }
}