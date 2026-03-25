// ============================================================
// weather_provider.dart
// The "brain" of the app. Holds all data and settings.
// Every screen reads from here using Provider.
// ============================================================

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/weather_model.dart';
import '../models/aqi_model.dart';
import '../services/weather_service.dart';
import '../services/aqi_service.dart';
import '../services/location_service.dart';
import '../services/notification_service.dart';

enum LoadingState { idle, loading, success, error }

class WeatherProvider extends ChangeNotifier {

  final _weatherService     = WeatherService();
  final _aqiService         = AqiService();
  final _locationService    = LocationService();
  final _notificationService = NotificationService();

  WeatherModel? weatherData;
  AqiModel?     aqiData;

  LoadingState loadingState = LoadingState.idle;
  String errorMessage = '';

  // Store real GPS coords — exposed publicly for MapScreen
  double? _lat;
  double? _lon;
  String  _cityName = '';
  String  _country  = '';

  // Public getters — MapScreen uses these to centre the map correctly
  double? get currentLat => _lat;
  double? get currentLon => _lon;

  bool   isCelsius          = true;
  bool   notificationsOn    = true;
  int    aqiAlertThreshold  = 100;
  String windUnit           = 'km/h';
  int    notificationTestAqi = 150;

  bool _aqiAlertActive = false;

  String get tempSymbol => isCelsius ? '°C' : '°F';

  /// Convert wind speed from km/h to the selected unit
  double convertWindSpeed(double windSpeedKmh) {
    switch (windUnit) {
      case 'm/s':
        return windSpeedKmh / 3.6;
      case 'mph':
        return windSpeedKmh * 0.621371;
      case 'km/h':
      default:
        return windSpeedKmh;
    }
  }

  WeatherProvider() {
    _loadSettings();
    _notificationService.initialize();
  }

  Future<void> fetchWeatherByLocation() async {
    _setLoading();
    try {
      final loc = await _locationService.getCurrentLocation();
      _lat      = loc['lat'];
      _lon      = loc['lon'];
      _cityName = loc['city'];
      _country  = loc['country'];
      await _fetchBothAPIs();
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<void> fetchWeatherByCity(String city) async {
    _setLoading();
    try {
      final coords = await _weatherService.getCityCoordinates(city);
      _lat      = coords['lat'];
      _lon      = coords['lon'];
      _cityName = coords['city'];
      _country  = coords['country'];
      await _fetchBothAPIs();
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<void> refresh() async {
    if (_lat != null && _lon != null) {
      _setLoading();
      await _fetchBothAPIs();
    } else {
      await fetchWeatherByLocation();
    }
  }

  Future<void> _fetchBothAPIs() async {
    try {
      // Fetch weather first
      final weather = await _weatherService.getWeather(
        lat:       _lat!,
        lon:       _lon!,
        cityName:  _cityName,
        country:   _country,
        isCelsius: isCelsius,
      );
      
      // Then fetch AQI with wind direction from weather data
      final aqi = await _aqiService.getAqi(
        lat:      _lat!,
        lon:      _lon!,
        cityName: _cityName,
        windDirection: weather.windDirection,
      );
      
      weatherData  = weather;
      aqiData      = aqi;
      _checkAqiAlertTrigger();
      loadingState = LoadingState.success;
      notifyListeners();
    } catch (e) {
      _setError('Failed to load data. Check your internet connection.');
    }
  }

  void setTemperatureUnit(bool celsius) {
    isCelsius = celsius;
    _saveSettings();
    if (_lat != null) { _setLoading(); _fetchBothAPIs(); }
    notifyListeners();
  }

  void setNotifications(bool enabled) {
    notificationsOn = enabled;
    if (!enabled) {
      _aqiAlertActive = false;
    }
    _saveSettings();
    notifyListeners();
  }

  void setAqiThreshold(int threshold) {
    aqiAlertThreshold = threshold;
    // Re-evaluate with the current AQI so threshold changes can trigger alerts.
    _aqiAlertActive = false;
    _checkAqiAlertTrigger();
    _saveSettings();
    notifyListeners();
  }

  void setNotificationTestAqi(int value) {
    notificationTestAqi = value;
    notifyListeners();
  }

  void sendTestAqiNotification() {
    if (!notificationsOn) {
      // Silently ignore if notifications are off
      return;
    }

    _notificationService.showTestNotification(
      testAqi: notificationTestAqi,
      threshold: aqiAlertThreshold,
    );
  }

  void setWindUnit(String unit) {
    windUnit = unit;
    _saveSettings();
    notifyListeners();
  }

  void _setLoading() {
    loadingState = LoadingState.loading;
    errorMessage = '';
    notifyListeners();
  }

  void _setError(String msg) {
    loadingState = LoadingState.error;
    errorMessage = msg;
    notifyListeners();
  }

  Future<void> _loadSettings() async {
    final prefs       = await SharedPreferences.getInstance();
    isCelsius         = prefs.getBool('isCelsius')    ?? true;
    notificationsOn   = prefs.getBool('notifications') ?? true;
    aqiAlertThreshold = prefs.getInt('aqiThreshold')   ?? 100;
    windUnit          = prefs.getString('windUnit')    ?? 'km/h';
    notifyListeners();
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isCelsius',     isCelsius);
    await prefs.setBool('notifications', notificationsOn);
    await prefs.setInt('aqiThreshold',   aqiAlertThreshold);
    await prefs.setString('windUnit',    windUnit);
  }

  void _checkAqiAlertTrigger() {
    if (!notificationsOn || aqiData == null) {
      _aqiAlertActive = false;
      return;
    }

    final currentAqi = aqiData!.aqi;
    if (currentAqi >= aqiAlertThreshold) {
      if (!_aqiAlertActive) {
        _notificationService.showHighAqiAlert(
          aqi: currentAqi,
          threshold: aqiAlertThreshold,
          cityName: _cityName,
        );
        _aqiAlertActive = true;
      }
    } else {
      _aqiAlertActive = false;
    }
  }
}
