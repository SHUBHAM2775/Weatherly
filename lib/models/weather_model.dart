// ============================================================
// weather_model.dart
// This file defines the data structures (blueprints) for
// all weather-related information in the app.
// ============================================================

// ---- Main weather object ----
class WeatherModel {
  final double temperature;       // Current temp e.g. 28.5
  final double feelsLike;         // Feels-like temp
  final double tempMin;           // Today's low
  final double tempMax;           // Today's high
  final int humidity;             // % humidity
  final double windSpeed;         // Wind in km/h
  final int windDirection;        // Wind direction in degrees (0-360)
  final int weatherCode;          // WMO code (0=clear, 61=rain, etc.)
  final String condition;         // Human label e.g. "Rain"
  final String description;       // Longer e.g. "Moderate rain"
  final String cityName;          // e.g. "Mumbai"
  final String country;           // e.g. "IN"
  final DateTime timestamp;       // When data was fetched
  final List<HourlyForecast> hourlyForecast;  // Next 24 h
  final List<DailyForecast> dailyForecast;    // Next 7 days

  WeatherModel({
    required this.temperature,
    required this.feelsLike,
    required this.tempMin,
    required this.tempMax,
    required this.humidity,
    required this.windSpeed,
    required this.windDirection,
    required this.weatherCode,
    required this.condition,
    required this.description,
    required this.cityName,
    required this.country,
    required this.timestamp,
    required this.hourlyForecast,
    required this.dailyForecast,
  });
}

// ---- One entry in the hourly forecast ----
class HourlyForecast {
  final DateTime time;
  final double temperature;
  final int weatherCode;
  final int humidity;
  final double windSpeed;
  final int windDirection;       // Wind direction in degrees (0-360)

  HourlyForecast({
    required this.time,
    required this.temperature,
    required this.weatherCode,
    required this.humidity,
    required this.windSpeed,
    required this.windDirection,
  });
}

// ---- One day in the 7-day forecast ----
class DailyForecast {
  final DateTime date;
  final double tempMax;
  final double tempMin;
  final int weatherCode;
  final double precipitationSum;  // Rain in mm
  final double windSpeedMax;
  final int windDirection;        // Wind direction in degrees (0-360)

  DailyForecast({
    required this.date,
    required this.tempMax,
    required this.tempMin,
    required this.weatherCode,
    required this.precipitationSum,
    required this.windSpeedMax,
    required this.windDirection,
  });
}
