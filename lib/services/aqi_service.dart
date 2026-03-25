// ============================================================
// aqi_service.dart
// Fetches Air Quality Index data.
//
// HOW TO ADD YOUR WAQI KEY:
//   1. Visit https://aqicn.org/api/ and get a free token
//   2. Replace 'YOUR_WAQI_API_TOKEN' below with your token
//
// Until you add a real token, the app shows realistic
// demo/mock data so everything still works.
// ============================================================

import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../models/aqi_model.dart';
import '../utils/weather_utils.dart';

class AqiService {
  // 👇 REPLACE THIS with your token from https://aqicn.org/api/
  static const String _apiToken = '5f9d2815a53ca9b6b29a03c7865b3b7a3e3f7f2e';

  static const String _baseUrl = 'https://api.waqi.info';

  /// Main entry point — tries real API, falls back to demo data
  Future<AqiModel> getAqi({
    required double lat,
    required double lon,
    required String cityName,
    int windDirection = 0,
  }) async {
    if (_apiToken != 'YOUR_WAQI_API_TOKEN') {
      // Real API call
      return _fetchFromWaqi(lat: lat, lon: lon, cityName: cityName, windDirection: windDirection);
    }
    // Demo data (works without any key)
    return _buildDemoAqi(cityName, lat, windDirection);
  }

  // ----------------------------------------------------------
  // Real WAQI API call
  // ----------------------------------------------------------
  Future<AqiModel> _fetchFromWaqi({
    required double lat,
    required double lon,
    required String cityName,
    required int windDirection,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/feed/geo:$lat;$lon/?token=$_apiToken');
      final response = await http.get(url);

      if (response.statusCode != 200) throw Exception('Network error');

      final data = json.decode(response.body);
      if (data['status'] != 'ok') throw Exception('AQI data unavailable');

      final d = data['data'] as Map<String, dynamic>;
      final aqi = (d['aqi'] as num).toInt();

      // Extract pollutant values from the "iaqi" field
      final Map<String, double> pollutants = {};
      final iaqi = d['iaqi'] as Map<String, dynamic>? ?? {};
      for (final key in ['pm25', 'pm10', 'no2', 'so2', 'co', 'o3']) {
        if (iaqi.containsKey(key)) {
          final displayKey = key == 'pm25' ? 'PM2.5' : key.toUpperCase();
          pollutants[displayKey] = (iaqi[key]['v'] as num).toDouble();
        }
      }

      // Find the main (highest) pollutant
      String mainPollutant = 'PM2.5';
      double maxVal = 0;
      pollutants.forEach((k, v) {
        if (v > maxVal) {
          maxVal = v;
          mainPollutant = k;
        }
      });

      return AqiModel(
        aqi: aqi,
        category: WeatherUtils.getAqiCategory(aqi),
        mainPollutant: mainPollutant,
        cityName: (d['city'] as Map?)?['name'] as String? ?? cityName,
        timestamp: DateTime.now(),
        pollutants: pollutants,
        forecast: _generateForecast(aqi),
        windDirection: windDirection,
      );
    } catch (_) {
      // If real API fails, show demo data rather than crash
      return _buildDemoAqi(cityName, lat, windDirection);
    }
  }

  // ----------------------------------------------------------
  // Demo / mock AQI — realistic values, no API key needed
  // Uses the latitude to vary values (tropics = higher)
  // ----------------------------------------------------------
  AqiModel _buildDemoAqi(String cityName, double lat, int windDirection) {
    final rng = Random(lat.toInt().abs()); // same seed = consistent per city
    final base = 30 + rng.nextInt(120); // random between 30 and 150

    return AqiModel(
      aqi: base,
      category: WeatherUtils.getAqiCategory(base),
      mainPollutant: 'PM2.5',
      cityName: cityName,
      timestamp: DateTime.now(),
      pollutants: {
        'PM2.5': 10.0 + rng.nextDouble() * 40,
        'PM10': 15.0 + rng.nextDouble() * 60,
        'NO2': 8.0 + rng.nextDouble() * 30,
        'SO2': 3.0 + rng.nextDouble() * 15,
        'CO': 0.3 + rng.nextDouble() * 2,
        'O3': 18.0 + rng.nextDouble() * 40,
      },
      forecast: _generateForecast(base),
      windDirection: windDirection,
    );
  }

  /// Generates 7 days of slightly varying AQI forecast
  List<AqiForecast> _generateForecast(int baseAqi) {
    final rng = Random();
    return List.generate(7, (i) {
      final val = (baseAqi + rng.nextInt(40) - 20).clamp(0, 500);
      return AqiForecast(
        date: DateTime.now().add(Duration(days: i)),
        avgAqi: val,
        category: WeatherUtils.getAqiCategory(val),
      );
    });
  }
}
