// ============================================================
// weather_utils.dart
// Helper functions used across the app:
//   - Convert WMO weather codes → labels, icons, colours
//   - AQI colours and categories
//   - Smart suggestion text
// ============================================================

import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class WeatherUtils {
  // ----------------------------------------------------------
  // WEATHER CODE HELPERS
  // Open-Meteo uses WMO codes. Full list:
  //   0 = Clear sky
  //   1-3 = Partly/mostly cloudy
  //   45,48 = Fog
  //   51-55 = Drizzle
  //   61-67 = Rain
  //   71-77 = Snow
  //   80-82 = Rain showers
  //   95,96,99 = Thunderstorm
  // ----------------------------------------------------------

  /// Returns a short condition label, e.g. "Rain"
  static String getCondition(int code) {
    if (code == 0) return 'Clear Sky';
    if (code <= 2) return 'Partly Cloudy';
    if (code == 3) return 'Overcast';
    if (code <= 49) return 'Foggy';
    if (code <= 59) return 'Drizzle';
    if (code <= 67) return 'Rain';
    if (code <= 77) return 'Snow';
    if (code <= 82) return 'Rain Showers';
    if (code <= 86) return 'Snow Showers';
    if (code <= 99) return 'Thunderstorm';
    return 'Unknown';
  }

  static String getConditionLocalized(int code, AppLocalizations l10n) {
    if (code == 0) return l10n.clearSky;
    if (code <= 2) return l10n.partlyCloudy;
    if (code == 3) return l10n.overcast;
    if (code <= 49) return l10n.foggy;
    if (code <= 59) return l10n.drizzle;
    if (code <= 67) return l10n.rainWeather;
    if (code <= 77) return l10n.snowWeather;
    if (code <= 82) return l10n.rainShowers;
    if (code <= 86) return l10n.snowShowers;
    if (code <= 99) return l10n.thunderstorm;
    return l10n.unknown;
  }

  /// Returns a longer description, e.g. "Moderate rain"
  static String getDescription(int code) {
    if (code == 0) return 'Clear and sunny skies';
    if (code == 1) return 'Mainly clear';
    if (code == 2) return 'Partly cloudy';
    if (code == 3) return 'Overcast clouds';
    if (code == 45) return 'Foggy conditions';
    if (code == 48) return 'Rime fog';
    if (code == 51) return 'Light drizzle';
    if (code == 53) return 'Moderate drizzle';
    if (code == 55) return 'Dense drizzle';
    if (code == 61) return 'Slight rain';
    if (code == 63) return 'Moderate rain';
    if (code == 65) return 'Heavy rain';
    if (code == 71) return 'Slight snow';
    if (code == 73) return 'Moderate snow';
    if (code == 75) return 'Heavy snow';
    if (code == 80) return 'Slight rain showers';
    if (code == 81) return 'Moderate rain showers';
    if (code == 82) return 'Violent rain showers';
    if (code == 95) return 'Thunderstorm';
    if (code == 96) return 'Thunderstorm with hail';
    if (code == 99) return 'Thunderstorm, heavy hail';
    return getCondition(code);
  }

  static String getDescriptionLocalized(int code, AppLocalizations l10n) {
    if (code == 0) return l10n.clearSunny;
    if (code == 1) return l10n.mainlyClear;
    if (code == 2) return l10n.partlyCloudyDesc;
    if (code == 3) return l10n.overcastDesc;
    if (code == 45) return l10n.foggyDesc;
    if (code == 48) return l10n.foggyDesc;
    if (code == 51) return l10n.drizzleDesc;
    if (code == 53) return l10n.drizzleDesc;
    if (code == 55) return l10n.drizzleDesc;
    if (code == 61) return l10n.rainDesc;
    if (code == 63) return l10n.rainDesc;
    if (code == 65) return l10n.rainDesc;
    if (code == 71) return l10n.snowDesc;
    if (code == 73) return l10n.snowDesc;
    if (code == 75) return l10n.snowDesc;
    if (code == 80) return l10n.rainShowersDesc;
    if (code == 81) return l10n.rainShowersDesc;
    if (code == 82) return l10n.rainShowersDesc;
    if (code == 95) return l10n.thunderstormDesc;
    if (code == 96) return l10n.thunderstormDesc;
    if (code == 99) return l10n.thunderstormDesc;
    return getConditionLocalized(code, l10n);
  }

  /// Returns a Material icon for the weather code
  static IconData getWeatherIcon(int code) {
    if (code == 0) return Icons.wb_sunny_rounded;
    if (code <= 2) return Icons.wb_cloudy_rounded;
    if (code == 3) return Icons.cloud_rounded;
    if (code <= 49) return Icons.foggy;
    if (code <= 59) return Icons.grain;
    if (code <= 67) return Icons.water_drop_rounded;
    if (code <= 77) return Icons.ac_unit_rounded;
    if (code <= 82) return Icons.umbrella_rounded;
    if (code <= 86) return Icons.snowing;
    if (code <= 99) return Icons.thunderstorm_rounded;
    return Icons.wb_cloudy_rounded;
  }

  /// Returns gradient colours for the background based on weather
  static List<Color> getWeatherGradient(int code) {
    if (code == 0) return [const Color(0xFF4FC3F7), const Color(0xFF0288D1)];
    if (code <= 2) return [const Color(0xFF81D4FA), const Color(0xFF4FC3F7)];
    if (code == 3) return [const Color(0xFF90A4AE), const Color(0xFF607D8B)];
    if (code <= 49) return [const Color(0xFFB0BEC5), const Color(0xFF90A4AE)];
    if (code <= 59) return [const Color(0xFF78909C), const Color(0xFF546E7A)];
    if (code <= 67) return [const Color(0xFF5C6BC0), const Color(0xFF3949AB)];
    if (code <= 77) return [const Color(0xFFB3E5FC), const Color(0xFF81D4FA)];
    if (code <= 82) return [const Color(0xFF42A5F5), const Color(0xFF1E88E5)];
    if (code <= 86) return [const Color(0xFFB3E5FC), const Color(0xFF4FC3F7)];
    return [
      const Color(0xFF424242),
      const Color(0xFF212121)
    ]; // thunderstorm = dark
  }

  // ----------------------------------------------------------
  // AQI HELPERS
  // AQI Scale: 0-50 Good | 51-100 Moderate | 101-150 USG
  //            151-200 Unhealthy | 201-300 Very Unhealthy
  //            301+ Hazardous
  // ----------------------------------------------------------

  /// Returns a colour representing the AQI level
  static Color getAqiColor(int aqi) {
    if (aqi <= 50) return const Color(0xFF4CAF50); // green
    if (aqi <= 100) return const Color(0xFFFFEB3B); // yellow
    if (aqi <= 150) return const Color(0xFFFF9800); // orange
    if (aqi <= 200) return const Color(0xFFF44336); // red
    if (aqi <= 300) return const Color(0xFF9C27B0); // purple
    return const Color(0xFF7B1FA2); // maroon
  }

  /// Returns the AQI category label
  static String getAqiCategory(int aqi) {
    if (aqi <= 50) return 'Good';
    if (aqi <= 100) return 'Moderate';
    if (aqi <= 150) return 'Unhealthy for Sensitive Groups';
    if (aqi <= 200) return 'Unhealthy';
    if (aqi <= 300) return 'Very Unhealthy';
    return 'Hazardous';
  }

  // ----------------------------------------------------------
  // WIND DIRECTION HELPERS
  // Convert degrees (0-360) to cardinal directions
  // ----------------------------------------------------------

  /// Returns cardinal direction from degree (N, NE, E, SE, S, SW, W, NW)
  static String getWindDirection(int degrees) {
    // Normalize to 0-360
    final normalized = (degrees % 360 + 360) % 360;

    // Standard 8-point compass with 45° per quadrant
    if (normalized >= 348.75 || normalized < 11.25) return 'N';
    if (normalized >= 11.25 && normalized < 33.75) return 'NE';
    if (normalized >= 33.75 && normalized < 56.25) return 'E';
    if (normalized >= 56.25 && normalized < 78.75) return 'SE';
    if (normalized >= 78.75 && normalized < 101.25) return 'S';
    if (normalized >= 101.25 && normalized < 123.75) return 'SW';
    if (normalized >= 123.75 && normalized < 146.25) return 'W';
    return 'NW'; // 146.25 to 168.75 and beyond
  }

  // ----------------------------------------------------------
  // SMART ASSISTANT SUGGESTION
  // Generates one helpful daily tip based on weather + AQI
  // ----------------------------------------------------------

  static String getSmartSuggestion(int weatherCode, int humidity, int? aqi) {
    // Thunderstorm — highest priority warning
    if (weatherCode >= 95) return '⛈️ Thunderstorm alert — stay indoors today';

    // Rain
    if (weatherCode >= 61 && weatherCode <= 82)
      return '🌂 Carry an umbrella — rain expected';

    // Snow
    if (weatherCode >= 71 && weatherCode <= 79)
      return '🧥 Bundle up — snow is expected';

    // Poor air quality
    if (aqi != null && aqi > 150)
      return '😷 Very poor air quality — avoid going outside';
    if (aqi != null && aqi > 100)
      return '😷 Poor air quality — avoid outdoor jogging';

    // High humidity
    if (humidity > 85) return '💧 Very humid today — stay hydrated';

    // Perfect conditions
    if (aqi != null && aqi <= 50 && weatherCode == 0) {
      return '🏃 Perfect day — great for a morning run!';
    }

    // Clear sky
    if (weatherCode == 0) return '☀️ Beautiful day — enjoy the sunshine!';

    return '🌤️ Have a wonderful day!';
  }

  static String getSmartSuggestionLocalized(
      int weatherCode, int humidity, int? aqi, AppLocalizations l10n) {
    if (weatherCode >= 95) return l10n.thunderstormAlert;
    if (weatherCode >= 61 && weatherCode <= 82) return l10n.carryUmbrella;
    if (weatherCode >= 71 && weatherCode <= 79) return l10n.bundleUp;
    if (aqi != null && aqi > 150) return l10n.poorAirQuality;
    if (aqi != null && aqi > 100) return l10n.avoidOutdoorActivities;
    if (humidity > 85) return l10n.hotDay;
    if (aqi != null && aqi <= 50 && weatherCode == 0) {
      return l10n.clearSunny;
    }
    if (weatherCode == 0) return l10n.clearSunny;
    return l10n.mainlyClear;
  }
}
