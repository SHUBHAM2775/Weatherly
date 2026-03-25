// ============================================================
// weather_service.dart
// Talks to two free Open-Meteo APIs:
//   1. forecast API  → current weather + hourly + 7-day
//   2. geocoding API → city name → lat/lon (for Travel search)
// No API key required!
// ============================================================

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';
import '../utils/weather_utils.dart';

class WeatherService {

  // Base URLs for the two Open-Meteo endpoints
  static const String _forecastUrl  = 'https://api.open-meteo.com/v1/forecast';
  static const String _geocodeUrl   = 'https://geocoding-api.open-meteo.com/v1/search';

  // ----------------------------------------------------------
  // getCityCoordinates
  // Used by Travel Search: converts a city name → lat/lon
  // ----------------------------------------------------------
  Future<Map<String, dynamic>> getCityCoordinates(String city) async {
    // Build URL e.g. ...?name=Paris&count=1&language=en&format=json
    final url = Uri.parse(
      '$_geocodeUrl?name=${Uri.encodeComponent(city)}&count=5&language=en&format=json',
    );

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Could not reach geocoding server');
    }

    final data = json.decode(response.body);
    final results = data['results'] as List?;

    if (results == null || results.isEmpty) {
      throw Exception('City "$city" not found. Try a different spelling.');
    }

    return {
      'lat':     (results[0]['latitude']  as num).toDouble(),
      'lon':     (results[0]['longitude'] as num).toDouble(),
      'city':    results[0]['name'] as String,
      'country': results[0]['country_code'] as String? ?? '',
    };
  }

  // ----------------------------------------------------------
  // getCitySuggestions
  // Returns autocomplete suggestions for cities in India
  // ----------------------------------------------------------
  Future<List<Map<String, dynamic>>> getCitySuggestions(String query) async {
    if (query.isEmpty) {
      // Return some popular Indian cities when query is empty
      return [
        {'name': 'Mumbai', 'country': 'IN', 'latitude': 19.0760, 'longitude': 72.8777, 'admin1': 'Maharashtra'},
        {'name': 'Delhi', 'country': 'IN', 'latitude': 28.7041, 'longitude': 77.1025, 'admin1': 'Delhi'},
        {'name': 'Bangalore', 'country': 'IN', 'latitude': 12.9716, 'longitude': 77.5946, 'admin1': 'Karnataka'},
        {'name': 'Hyderabad', 'country': 'IN', 'latitude': 17.3850, 'longitude': 78.4867, 'admin1': 'Telangana'},
        {'name': 'Chennai', 'country': 'IN', 'latitude': 13.0827, 'longitude': 80.2707, 'admin1': 'Tamil Nadu'},
        {'name': 'Kolkata', 'country': 'IN', 'latitude': 22.5726, 'longitude': 88.3639, 'admin1': 'West Bengal'},
        {'name': 'Pune', 'country': 'IN', 'latitude': 18.5204, 'longitude': 73.8567, 'admin1': 'Maharashtra'},
        {'name': 'Ahmedabad', 'country': 'IN', 'latitude': 23.0225, 'longitude': 72.5714, 'admin1': 'Gujarat'},
        {'name': 'Jaipur', 'country': 'IN', 'latitude': 26.9124, 'longitude': 75.7873, 'admin1': 'Rajasthan'},
        {'name': 'Goa', 'country': 'IN', 'latitude': 15.2993, 'longitude': 74.1240, 'admin1': 'Goa'},
        {'name': 'Lucknow', 'country': 'IN', 'latitude': 26.8467, 'longitude': 80.9462, 'admin1': 'Uttar Pradesh'},
        {'name': 'Kanpur', 'country': 'IN', 'latitude': 26.4499, 'longitude': 80.3329, 'admin1': 'Uttar Pradesh'},
        {'name': 'Nagpur', 'country': 'IN', 'latitude': 21.1458, 'longitude': 79.0882, 'admin1': 'Maharashtra'},
        {'name': 'Indore', 'country': 'IN', 'latitude': 22.7196, 'longitude': 75.8577, 'admin1': 'Madhya Pradesh'},
        {'name': 'Thane', 'country': 'IN', 'latitude': 19.2183, 'longitude': 72.9781, 'admin1': 'Maharashtra'},
        {'name': 'Bhopal', 'country': 'IN', 'latitude': 23.2599, 'longitude': 77.4126, 'admin1': 'Madhya Pradesh'},
        {'name': 'Visakhapatnam', 'country': 'IN', 'latitude': 17.6868, 'longitude': 83.2185, 'admin1': 'Andhra Pradesh'},
        {'name': 'Pimpri-Chinchwad', 'country': 'IN', 'latitude': 18.6298, 'longitude': 73.7997, 'admin1': 'Maharashtra'},
        {'name': 'Patna', 'country': 'IN', 'latitude': 25.5941, 'longitude': 85.1376, 'admin1': 'Bihar'},
        {'name': 'Vadodara', 'country': 'IN', 'latitude': 22.3072, 'longitude': 73.1812, 'admin1': 'Gujarat'},
      ].map((city) => {
        'name': city['name'] as String,
        'country': city['country'] as String,
        'latitude': city['latitude'] as double,
        'longitude': city['longitude'] as double,
        'admin1': city['admin1'] as String,
      }).toList();
    }

    // Build URL to fetch city suggestions
    final url = Uri.parse(
      '$_geocodeUrl?name=${Uri.encodeComponent(query)}&count=20&language=en&format=json',
    );

    final response = await http.get(url);

    if (response.statusCode != 200) {
      return [];
    }

    final data = json.decode(response.body);
    final results = data['results'] as List?;

    if (results == null || results.isEmpty) {
      return [];
    }

    // Filter for Indian cities only and limit to 10 results
    final indianCities = results
        .where((r) => (r['country_code'] as String?) == 'IN')
        .take(10)
        .toList();

    return indianCities.map((result) => {
      'name': result['name'] as String,
      'country': result['country_code'] as String? ?? 'IN',
      'latitude': (result['latitude'] as num).toDouble(),
      'longitude': (result['longitude'] as num).toDouble(),
      'admin1': result['admin1'] as String?, // State/region
    }).toList();
  }

  // ----------------------------------------------------------
  // getWeather
  // Fetches current + hourly + 7-day forecast from Open-Meteo
  // ----------------------------------------------------------
  Future<WeatherModel> getWeather({
    required double lat,
    required double lon,
    required String cityName,
    String country     = '',
    bool   isCelsius   = true,
  }) async {
    final tempUnit = isCelsius ? 'celsius' : 'fahrenheit';

    // Build the request URL with all the fields we need
    final url = Uri.parse(
      '$_forecastUrl'
      '?latitude=$lat'
      '&longitude=$lon'
      '&current=temperature_2m,relative_humidity_2m,apparent_temperature,weather_code,wind_speed_10m,wind_direction_10m'
      '&hourly=temperature_2m,weather_code,relative_humidity_2m,wind_speed_10m,wind_direction_10m'
      '&daily=weather_code,temperature_2m_max,temperature_2m_min,precipitation_sum,wind_speed_10m_max,wind_direction_10m_dominant'
      '&temperature_unit=$tempUnit'
      '&wind_speed_unit=kmh'
      '&timezone=auto'
      '&forecast_days=7',
    );

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch weather. Check your internet connection.');
    }

    // Parse the JSON response
    final data    = json.decode(response.body);
    final current = data['current'] as Map<String, dynamic>;
    final hourly  = data['hourly']  as Map<String, dynamic>;
    final daily   = data['daily']   as Map<String, dynamic>;

    final int weatherCode = (current['weather_code'] as num).toInt();
    final now = DateTime.now();

    // ----- Build hourly list (next 24 hours only) -----
    final List<HourlyForecast> hourlyList = [];
    final times = hourly['time'] as List;
    for (int i = 0; i < times.length && hourlyList.length < 24; i++) {
      final t = DateTime.parse(times[i] as String);
      if (t.isAfter(now)) {
        hourlyList.add(HourlyForecast(
          time:        t,
          temperature: (hourly['temperature_2m'][i]          as num).toDouble(),
          weatherCode: (hourly['weather_code'][i]            as num).toInt(),
          humidity:    (hourly['relative_humidity_2m'][i]    as num).toInt(),
          windSpeed:   (hourly['wind_speed_10m'][i]          as num).toDouble(),
          windDirection: (hourly['wind_direction_10m'][i]    as num).toInt(),
        ));
      }
    }

    // ----- Build 7-day daily list -----
    final List<DailyForecast> dailyList = [];
    final dates = daily['time'] as List;
    for (int i = 0; i < dates.length; i++) {
      dailyList.add(DailyForecast(
        date:              DateTime.parse(dates[i] as String),
        tempMax:           (daily['temperature_2m_max'][i]   as num).toDouble(),
        tempMin:           (daily['temperature_2m_min'][i]   as num).toDouble(),
        weatherCode:       (daily['weather_code'][i]         as num).toInt(),
        precipitationSum:  (daily['precipitation_sum'][i]    as num?)?.toDouble() ?? 0.0,
        windSpeedMax:      (daily['wind_speed_10m_max'][i]   as num).toDouble(),
        windDirection:     (daily['wind_direction_10m_dominant'][i] as num).toInt(),
      ));
    }

    // Today's low and high come from the daily forecast (index 0 = today)
    final double tempMin = dailyList.isNotEmpty ? dailyList.first.tempMin : (current['temperature_2m'] as num).toDouble() - 3;
    final double tempMax = dailyList.isNotEmpty ? dailyList.first.tempMax : (current['temperature_2m'] as num).toDouble() + 3;

    return WeatherModel(
      temperature:     (current['temperature_2m']       as num).toDouble(),
      feelsLike:       (current['apparent_temperature'] as num).toDouble(),
      tempMin:         tempMin,
      tempMax:         tempMax,
      humidity:        (current['relative_humidity_2m'] as num).toInt(),
      windSpeed:       (current['wind_speed_10m']       as num).toDouble(),
      windDirection:   (current['wind_direction_10m']   as num).toInt(),
      weatherCode:     weatherCode,
      condition:       WeatherUtils.getCondition(weatherCode),
      description:     WeatherUtils.getDescription(weatherCode),
      cityName:        cityName,
      country:         country,
      timestamp:       DateTime.now(),
      hourlyForecast:  hourlyList,
      dailyForecast:   dailyList,
    );
  }
}
