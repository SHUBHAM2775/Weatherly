// ============================================================
// map_screen.dart
// Each city marker has a distinct colour scheme per condition:
//   ☀️  Clear     → amber/orange gradient
//   ⛅  Cloudy    → light blue/white gradient
//   🌫️  Fog       → grey/silver gradient
//   🌧️  Rain      → deep blue/indigo gradient
//   ❄️  Snow      → cyan/white gradient
//   ⛈️  Thunder   → dark charcoal gradient
//   🌦️  Drizzle   → steel blue gradient
//
// PLACE THIS FILE AT: lib/screens/map_screen.dart
// ============================================================

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../services/weather_provider.dart';
import '../utils/weather_utils.dart';
import '../theme/app_theme.dart';
import '../l10n/app_localizations.dart';

// ── Colour palette for every weather type ──────────────────
class _MarkerStyle {
  final List<Color> gradient;
  final Color iconColor;
  final Color glowColor;
  const _MarkerStyle(this.gradient, this.iconColor, this.glowColor);
}

_MarkerStyle _styleForCode(int code) {
  // ☀️ Clear
  if (code == 0)
    return const _MarkerStyle(
      [Color(0xFFFFB300), Color(0xFFFF8F00)],
      Color(0xFFFFF9C4),
      Color(0xFFFFB300),
    );
  // 🌤 Mainly clear / partly cloudy
  if (code <= 2)
    return const _MarkerStyle(
      [Color(0xFF90CAF9), Color(0xFF42A5F5)],
      Colors.white,
      Color(0xFF42A5F5),
    );
  // ☁️ Overcast
  if (code == 3)
    return const _MarkerStyle(
      [Color(0xFFB0BEC5), Color(0xFF78909C)],
      Colors.white,
      Color(0xFF90A4AE),
    );
  // 🌫️ Fog
  if (code <= 49)
    return const _MarkerStyle(
      [Color(0xFFCFD8DC), Color(0xFF90A4AE)],
      Color(0xFF546E7A),
      Color(0xFFB0BEC5),
    );
  // 🌦️ Drizzle
  if (code <= 59)
    return const _MarkerStyle(
      [Color(0xFF64B5F6), Color(0xFF1E88E5)],
      Colors.white,
      Color(0xFF1E88E5),
    );
  // 🌧️ Rain
  if (code <= 67)
    return const _MarkerStyle(
      [Color(0xFF1565C0), Color(0xFF0D47A1)],
      Color(0xFFBBDEFB),
      Color(0xFF1565C0),
    );
  // ❄️ Snow
  if (code <= 77)
    return const _MarkerStyle(
      [Color(0xFFE0F7FA), Color(0xFF80DEEA)],
      Color(0xFF00838F),
      Color(0xFF80DEEA),
    );
  // 🌧️ Rain showers
  if (code <= 82)
    return const _MarkerStyle(
      [Color(0xFF1976D2), Color(0xFF0D47A1)],
      Color(0xFFBBDEFB),
      Color(0xFF1976D2),
    );
  // 🌨️ Snow showers
  if (code <= 86)
    return const _MarkerStyle(
      [Color(0xFFB2EBF2), Color(0xFF4DD0E1)],
      Color(0xFF006064),
      Color(0xFF4DD0E1),
    );
  // ⛈️ Thunderstorm
  return const _MarkerStyle(
    [Color(0xFF37474F), Color(0xFF263238)],
    Color(0xFFFFE082),
    Color(0xFF455A64),
  );
}

// ── Data class for one city ─────────────────────────────────
class _CityWeather {
  final String name;
  final double lat, lon;
  int weatherCode = -1;
  double temperature = 0;
  int humidity = 0;
  double windSpeed = 0;
  bool loaded = false;

  _CityWeather({
    required this.name,
    required this.lat,
    required this.lon,
  });
}

// ── Screen ──────────────────────────────────────────────────
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});
  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  _CityWeather? _selectedCity;
  bool _centeredOnUser = false;

  final List<_CityWeather> _cities = [
    _CityWeather(name: 'Mumbai', lat: 19.076, lon: 72.877),
    _CityWeather(name: 'Delhi', lat: 28.635, lon: 77.225),
    _CityWeather(name: 'Bengaluru', lat: 12.972, lon: 77.594),
    _CityWeather(name: 'Chennai', lat: 13.083, lon: 80.270),
    _CityWeather(name: 'Kolkata', lat: 22.572, lon: 88.363),
    _CityWeather(name: 'Hyderabad', lat: 17.385, lon: 78.487),
    _CityWeather(name: 'Pune', lat: 18.520, lon: 73.856),
    _CityWeather(name: 'Ahmedabad', lat: 23.023, lon: 72.572),
    _CityWeather(name: 'Jaipur', lat: 26.912, lon: 75.787),
    _CityWeather(name: 'Lucknow', lat: 26.847, lon: 80.947),
    _CityWeather(name: 'Bhopal', lat: 23.259, lon: 77.413),
    _CityWeather(name: 'Patna', lat: 25.594, lon: 85.137),
    _CityWeather(name: 'Bhubaneswar', lat: 20.296, lon: 85.825),
    _CityWeather(name: 'Raipur', lat: 21.251, lon: 81.629),
    _CityWeather(name: 'Ranchi', lat: 23.344, lon: 85.310),
    _CityWeather(name: 'Guwahati', lat: 26.145, lon: 91.736),
    _CityWeather(name: 'Chandigarh', lat: 30.733, lon: 76.779),
    _CityWeather(name: 'Dehradun', lat: 30.316, lon: 78.032),
    _CityWeather(name: 'Shimla', lat: 31.104, lon: 77.173),
    _CityWeather(name: 'Srinagar', lat: 34.084, lon: 74.797),
    _CityWeather(name: 'Amritsar', lat: 31.634, lon: 74.873),
    _CityWeather(name: 'Kochi', lat: 9.931, lon: 76.267),
    _CityWeather(name: 'Thiruvananthapuram', lat: 8.524, lon: 76.936),
    _CityWeather(name: 'Visakhapatnam', lat: 17.686, lon: 83.218),
    _CityWeather(name: 'Nagpur', lat: 21.145, lon: 79.088),
    _CityWeather(name: 'Surat', lat: 21.170, lon: 72.831),
    _CityWeather(name: 'Indore', lat: 22.719, lon: 75.857),
    _CityWeather(name: 'Coimbatore', lat: 11.017, lon: 76.955),
    _CityWeather(name: 'Varanasi', lat: 25.320, lon: 82.987),
    _CityWeather(name: 'Agra', lat: 27.176, lon: 78.008),
  ];

  @override
  void initState() {
    super.initState();
    _fetchAllCitiesWeather();
  }

  Future<void> _fetchAllCitiesWeather() async {
    for (int i = 0; i < _cities.length; i += 5) {
      final batch = _cities.sublist(i, (i + 5).clamp(0, _cities.length));
      await Future.wait(batch.map(_fetchOneCity));
      if (mounted) setState(() {});
    }
  }

  Future<void> _fetchOneCity(_CityWeather city) async {
    try {
      final url = Uri.parse(
        'https://api.open-meteo.com/v1/forecast'
        '?latitude=${city.lat}&longitude=${city.lon}'
        '&current=temperature_2m,relative_humidity_2m,weather_code,wind_speed_10m'
        '&temperature_unit=celsius&wind_speed_unit=kmh&timezone=auto',
      );
      final resp = await http.get(url).timeout(const Duration(seconds: 8));
      if (resp.statusCode == 200) {
        final c = json.decode(resp.body)['current'];
        city.weatherCode = (c['weather_code'] as num).toInt();
        city.temperature = (c['temperature_2m'] as num).toDouble();
        city.humidity = (c['relative_humidity_2m'] as num).toInt();
        city.windSpeed = (c['wind_speed_10m'] as num).toDouble();
        city.loaded = true;
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WeatherProvider>();
    final l10n = AppLocalizations.of(context)!;
    final weather = provider.weatherData;
    final double lat = provider.currentLat ?? 20.5937;
    final double lon = provider.currentLon ?? 78.9629;
    final userCenter = LatLng(lat, lon);

    // Fly to real GPS position once it is available
    if (!_centeredOnUser && provider.currentLat != null) {
      _centeredOnUser = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _mapController.move(userCenter, 5.5);
      });
    }

    return Scaffold(
      body: Stack(
        children: [
          // ── MAP ──────────────────────────────────────────
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: const LatLng(20.5937, 78.9629),
              initialZoom: 5.0,
              minZoom: 3,
              maxZoom: 18,
              onTap: (_, __) => setState(() => _selectedCity = null),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.weather_app',
              ),
              MarkerLayer(
                markers: [
                  // Blue GPS dot — user's real location
                  Marker(
                    point: userCenter,
                    width: 60,
                    height: 60,
                    child: _buildUserDot(),
                  ),
                  // Indian city pins
                  ..._cities.map((city) => Marker(
                        point: LatLng(city.lat, city.lon),
                        width: 72,
                        height: 76,
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedCity = city),
                          child: _buildCityPin(city),
                        ),
                      )),
                ],
              ),
            ],
          ),

          // ── HEADER ───────────────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF0288D1).withOpacity(0.93),
                    Colors.transparent,
                  ],
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  child: Row(
                    children: [
                      const Icon(Icons.map_rounded,
                          color: Colors.white, size: 22),
                      const SizedBox(width: 8),
                      Text(l10n.weatherMap,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold)),
                      const Spacer(),
                      if (weather != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.22),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            const Icon(Icons.my_location_rounded,
                                color: Colors.white, size: 12),
                            const SizedBox(width: 4),
                            Text(weather.cityName,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 12)),
                          ]),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── LEGEND (bottom-left) ─────────────────────────
          Positioned(
            left: 12,
            bottom: 110,
            child: _buildLegend(l10n),
          ),

          // ── ZOOM BUTTONS (bottom-right) ──────────────────
          Positioned(
            right: 16,
            bottom: 110,
            child: Column(
              children: [
                _zoomBtn(
                    Icons.add,
                    () => _mapController.move(_mapController.camera.center,
                        _mapController.camera.zoom + 1)),
                const SizedBox(height: 6),
                _zoomBtn(
                    Icons.remove,
                    () => _mapController.move(_mapController.camera.center,
                        _mapController.camera.zoom - 1)),
                const SizedBox(height: 6),
                _zoomBtn(Icons.my_location_rounded,
                    () => _mapController.move(userCenter, 10)),
              ],
            ),
          ),

          // ── CITY POPUP ───────────────────────────────────
          if (_selectedCity != null)
            Positioned(
              bottom: 100,
              left: 16,
              right: 16,
              child: _buildPopup(_selectedCity!, provider, l10n),
            ),
        ],
      ),
    );
  }

  // ── Widgets ──────────────────────────────────────────────

  /// Blue pulsing dot that marks the user's real GPS location
  Widget _buildUserDot() {
    return Stack(alignment: Alignment.center, children: [
      Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: const Color(0xFF0288D1).withOpacity(0.18),
          shape: BoxShape.circle,
          border: Border.all(
              color: const Color(0xFF0288D1).withOpacity(0.45), width: 2),
        ),
      ),
      Container(
        width: 20,
        height: 20,
        decoration: const BoxDecoration(
          color: Color(0xFF0288D1),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: Color(0x660288D1), blurRadius: 8, spreadRadius: 2)
          ],
        ),
      ),
      Container(
        width: 8,
        height: 8,
        decoration:
            const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
      ),
    ]);
  }

  /// Coloured weather pin for each Indian city
  Widget _buildCityPin(_CityWeather city) {
    // Use "overcast" style as placeholder while data is loading
    final style = _styleForCode(city.loaded ? city.weatherCode : 3);
    final isSelected = _selectedCity?.name == city.name;
    final double sz = isSelected ? 52 : 42;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: sz,
          height: sz,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: style.gradient,
            ),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withOpacity(isSelected ? 1.0 : 0.8),
              width: isSelected ? 2.5 : 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: style.glowColor.withOpacity(isSelected ? 0.7 : 0.45),
                blurRadius: isSelected ? 16 : 8,
                spreadRadius: isSelected ? 2 : 1,
              ),
            ],
          ),
          child: Icon(
            city.loaded
                ? WeatherUtils.getWeatherIcon(city.weatherCode)
                : Icons.hourglass_top_rounded,
            color: style.iconColor,
            size: isSelected ? 28 : 22,
          ),
        ),
        // Temperature badge shown after data loads
        if (city.loaded)
          Container(
            margin: const EdgeInsets.only(top: 2),
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
            decoration: BoxDecoration(
              color: style.gradient.last,
              borderRadius: BorderRadius.circular(6),
              boxShadow: [
                BoxShadow(
                    color: style.glowColor.withOpacity(0.3), blurRadius: 4)
              ],
            ),
            child: Text(
              '${city.temperature.toStringAsFixed(0)}°',
              style: TextStyle(
                  color: style.iconColor,
                  fontSize: 9,
                  fontWeight: FontWeight.w800),
            ),
          ),
      ],
    );
  }

  /// Info popup shown when a city pin is tapped
  Widget _buildPopup(
      _CityWeather city, WeatherProvider provider, AppLocalizations l10n) {
    final style = _styleForCode(city.weatherCode);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.14),
              blurRadius: 24,
              offset: const Offset(0, 6)),
        ],
      ),
      child: city.loaded
          ? Row(children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: style.gradient),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                        color: style.glowColor.withOpacity(0.4), blurRadius: 8)
                  ],
                ),
                child: Icon(WeatherUtils.getWeatherIcon(city.weatherCode),
                    color: style.iconColor, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(city.name,
                        style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 17,
                            fontWeight: FontWeight.w700)),
                    Text(
                        WeatherUtils.getConditionLocalized(
                            city.weatherCode, l10n),
                        style: TextStyle(
                            color: AppTheme.textSecondary, fontSize: 13)),
                    const SizedBox(height: 6),
                    Wrap(spacing: 10, children: [
                      _badge(
                          Icons.thermostat_rounded,
                          '${city.temperature.toStringAsFixed(0)}${provider.tempSymbol}',
                          style.gradient.first),
                      _badge(Icons.water_drop_rounded, '${city.humidity}%',
                          const Color(0xFF1565C0)),
                      _badge(
                          Icons.air_rounded,
                          '${city.windSpeed.toStringAsFixed(0)} km/h',
                          const Color(0xFF26A69A)),
                    ]),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => setState(() => _selectedCity = null),
                child: Icon(Icons.close_rounded, color: Colors.grey.shade400),
              ),
            ])
          : Row(children: [
              const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2)),
              const SizedBox(width: 12),
              Text(l10n.loadingCity.replaceAll('{city}', city.name),
                  style: TextStyle(color: AppTheme.textSecondary)),
            ]),
    );
  }

  /// Small legend card bottom-left explaining the colour coding
  Widget _buildLegend(AppLocalizations l10n) {
    final items = [
      _LegendItem(
          l10n.clear, _styleForCode(0).gradient, Icons.wb_sunny_rounded),
      _LegendItem(l10n.cloudy, _styleForCode(3).gradient, Icons.cloud_rounded),
      _LegendItem(
          l10n.rain, _styleForCode(63).gradient, Icons.water_drop_rounded),
      _LegendItem(l10n.snow, _styleForCode(73).gradient, Icons.ac_unit_rounded),
      _LegendItem(
          l10n.thunder, _styleForCode(95).gradient, Icons.thunderstorm_rounded),
    ];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(l10n.legend,
              style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 10,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: item.gradient),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(item.icon, color: Colors.white, size: 10),
                  ),
                  const SizedBox(width: 6),
                  Text(item.label,
                      style: TextStyle(
                          color: AppTheme.textSecondary, fontSize: 10)),
                ]),
              )),
        ],
      ),
    );
  }

  Widget _badge(IconData icon, String label, Color color) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, color: color, size: 13),
      const SizedBox(width: 3),
      Text(label,
          style: TextStyle(
              color: color, fontSize: 12, fontWeight: FontWeight.w600)),
    ]);
  }

  Widget _zoomBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.11), blurRadius: 8)
          ],
        ),
        child: Icon(icon, color: AppTheme.deepBlue, size: 18),
      ),
    );
  }
}

class _LegendItem {
  final String label;
  final List<Color> gradient;
  final IconData icon;
  const _LegendItem(this.label, this.gradient, this.icon);
}
