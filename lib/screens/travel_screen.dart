// ============================================================
// travel_screen.dart
// Search any city in the world:
//   • Search bar + popular city chips
//   • GPS button — loads weather for your current location
//   • Embedded mini-map showing the searched city
//   • Full weather card + AQI + travel packing tips
//   • 5-day forecast
// ============================================================

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';
import '../services/weather_service.dart';
import '../services/aqi_service.dart';
import '../services/location_service.dart';
import '../models/weather_model.dart';
import '../models/aqi_model.dart';
import '../utils/weather_utils.dart';
import '../theme/app_theme.dart';
import '../l10n/app_localizations.dart';

class TravelScreen extends StatefulWidget {
  const TravelScreen({super.key});
  @override
  State<TravelScreen> createState() => _TravelScreenState();
}

class _TravelScreenState extends State<TravelScreen> {
  final _searchController = TextEditingController();
  final _weatherService = WeatherService();
  final _aqiService = AqiService();
  final _locationService = LocationService();

  bool _isLoading = false;
  String _error = '';
  WeatherModel? _weather;
  AqiModel? _aqi;
  double? _resultLat;
  double? _resultLon;

  // Autocomplete state
  List<Map<String, dynamic>> _suggestions = [];
  bool _isSearching = false;
  bool _showSuggestions = false;
  Timer? _debounceTimer;

  // ---- Search by typed city name ----
  Future<void> _searchCity() async {
    final city = _searchController.text.trim();
    if (city.isEmpty) return;
    setState(() => _showSuggestions = false);
    _startLoading();
    try {
      final coords = await _weatherService.getCityCoordinates(city);
      await _loadWeatherForCoords(
        lat: coords['lat'],
        lon: coords['lon'],
        cityName: coords['city'],
        country: coords['country'],
      );
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // ---- Fetch autocomplete suggestions with debounce ----
  void _fetchSuggestions(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () async {
      if (!mounted) return;
      setState(() => _isSearching = true);
      try {
        final results = await _weatherService.getCitySuggestions(query);
        if (!mounted) return;
        setState(() {
          _suggestions = results;
          _isSearching = false;
          _showSuggestions = results.isNotEmpty || query.isEmpty;
        });
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _isSearching = false;
          _showSuggestions = false;
        });
      }
    });
  }

  // ---- Select a suggestion ----
  void _selectSuggestion(Map<String, dynamic> city) {
    _searchController.text = city['name'];
    setState(() => _showSuggestions = false);
    _loadWeatherForCoords(
      lat: city['latitude'] as double,
      lon: city['longitude'] as double,
      cityName: city['name'] as String,
      country: 'IN',
    );
  }

  // ---- GPS button: use device location ----
  Future<void> _searchByGPS() async {
    _startLoading();
    try {
      final loc = await _locationService.getCurrentLocation();
      _searchController.text = loc['city'];
      await _loadWeatherForCoords(
        lat: loc['lat'],
        lon: loc['lon'],
        cityName: loc['city'],
        country: loc['country'],
      );
    } catch (e) {
      final l10n = AppLocalizations.of(context)!;
      _setError(
          '${l10n.failedToLoadData}: ${e.toString().replaceAll('Exception: ', '')}');
    }
  }

  Future<void> _loadWeatherForCoords({
    required double lat,
    required double lon,
    required String cityName,
    String country = '',
  }) async {
    try {
      final results = await Future.wait([
        _weatherService.getWeather(
            lat: lat, lon: lon, cityName: cityName, country: country),
        _aqiService.getAqi(lat: lat, lon: lon, cityName: cityName),
      ]);
      setState(() {
        _weather = results[0] as WeatherModel;
        _aqi = results[1] as AqiModel;
        _resultLat = lat;
        _resultLon = lon;
        _isLoading = false;
        _error = '';
      });
    } catch (e) {
      final l10n = AppLocalizations.of(context)!;
      _setError(l10n.failedToLoadData);
    }
  }

  void _startLoading() {
    setState(() {
      _isLoading = true;
      _error = '';
      _weather = null;
      _aqi = null;
    });
  }

  void _setError(String msg) {
    setState(() {
      _isLoading = false;
      _error = msg;
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: GestureDetector(
        onTap: () {
          // Dismiss suggestions when tapping outside
          if (_showSuggestions) {
            setState(() => _showSuggestions = false);
          }
        },
        child: CustomScrollView(
          slivers: [
            // ---- Header ----
            SliverAppBar(
              expandedHeight: 150,
              pinned: true,
              backgroundColor: const Color(0xFF0288D1),
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF0D47A1), Color(0xFF0288D1)],
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(l10n.travelWeather,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold)),
                          SizedBox(height: 4),
                          Text(l10n.searchCitiesIndia,
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 14)),
                          SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Container(
                decoration: const BoxDecoration(
                  color: AppTheme.backgroundLight,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),

                    // ---- Search bar with autocomplete ----
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _searchController,
                                  textCapitalization: TextCapitalization.words,
                                  decoration: InputDecoration(
                                    hintText: l10n.searchCitiesHint,
                                    hintStyle: TextStyle(
                                        color: AppTheme.textSecondary,
                                        fontSize: 14),
                                    prefixIcon: _isSearching
                                        ? const Padding(
                                            padding: EdgeInsets.all(12),
                                            child: SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Color(0xFF0288D1),
                                              ),
                                            ),
                                          )
                                        : const Icon(Icons.search_rounded,
                                            color: Color(0xFF0288D1)),
                                    suffixIcon:
                                        _searchController.text.isNotEmpty
                                            ? IconButton(
                                                icon: const Icon(
                                                    Icons.clear_rounded,
                                                    color: Colors.grey),
                                                onPressed: () {
                                                  _searchController.clear();
                                                  _fetchSuggestions('');
                                                },
                                              )
                                            : null,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: BorderSide.none,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                  ),
                                  onChanged: _fetchSuggestions,
                                  onSubmitted: (_) => _searchCity(),
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Search button
                              _actionBtn(
                                icon: Icons.search_rounded,
                                colors: const [
                                  Color(0xFF0D47A1),
                                  Color(0xFF0288D1)
                                ],
                                onTap: _searchCity,
                                tooltip: l10n.retry,
                              ),
                              const SizedBox(width: 8),
                              // GPS button
                              _actionBtn(
                                icon: Icons.my_location_rounded,
                                colors: const [
                                  Color(0xFF00897B),
                                  Color(0xFF26A69A)
                                ],
                                onTap: _searchByGPS,
                                tooltip: l10n.detectingLocation,
                              ),
                            ],
                          ),
                          // Suggestions dropdown
                          if (_showSuggestions && _suggestions.isNotEmpty)
                            Container(
                              constraints: const BoxConstraints(maxHeight: 250),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: ListView.builder(
                                shrinkWrap: true,
                                physics: const ClampingScrollPhysics(),
                                itemCount: _suggestions.length > 8
                                    ? 8
                                    : _suggestions.length,
                                itemBuilder: (context, index) {
                                  final city = _suggestions[index];
                                  final stateName = city['admin1'] as String?;
                                  final displayName = stateName != null
                                      ? '${city['name']}, $stateName'
                                      : '${city['name']}, India';
                                  return ListTile(
                                    leading: const Icon(
                                        Icons.location_city_rounded,
                                        color: Color(0xFF0288D1),
                                        size: 20),
                                    title: Text(displayName,
                                        style: const TextStyle(fontSize: 14)),
                                    onTap: () => _selectSuggestion(city),
                                  );
                                },
                              ),
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // ---- Popular Indian city chips ----
                    Text(l10n.popularCitiesIndia,
                        style: TextStyle(
                            color: AppTheme.textSecondary, fontSize: 13)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        l10n.mumbai,
                        l10n.delhi,
                        l10n.bangalore,
                        l10n.hyderabad,
                        l10n.chennai,
                        l10n.kolkata,
                        l10n.pune,
                        l10n.jaipur,
                        'Goa',
                        'Ahmedabad'
                      ]
                          .map((city) => GestureDetector(
                                onTap: () {
                                  _searchController.text = city;
                                  _searchCity();
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 7),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [AppTheme.cardShadow],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.location_city_rounded,
                                          size: 13, color: Color(0xFF0288D1)),
                                      const SizedBox(width: 4),
                                      Text(city,
                                          style: const TextStyle(
                                              color: Color(0xFF0288D1),
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500)),
                                    ],
                                  ),
                                ),
                              ))
                          .toList(),
                    ),

                    const SizedBox(height: 24),

                    // ---- Result area ----
                    if (_isLoading)
                      Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 48),
                          child: Column(
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 12),
                              Text(l10n.fetchingWeather,
                                  style:
                                      TextStyle(color: AppTheme.textSecondary)),
                            ],
                          ),
                        ),
                      )
                    else if (_error.isNotEmpty)
                      _buildErrorCard()
                    else if (_weather != null)
                      _buildResults(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---- Full results section ----
  Widget _buildResults() {
    final weather = _weather!;
    final l10n = AppLocalizations.of(context)!;
    final gradients = WeatherUtils.getWeatherGradient(weather.weatherCode);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // === MINI MAP (embedded) ===
        _buildMiniMap(),
        const SizedBox(height: 16),

        // === MAIN WEATHER CARD ===
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: gradients),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [AppTheme.cardShadow],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.location_on_rounded,
                      color: Colors.white70, size: 16),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      weather.country.isNotEmpty
                          ? '${weather.cityName}, ${weather.country}'
                          : weather.cityName,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${weather.temperature.toStringAsFixed(0)}°',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 72,
                          fontWeight: FontWeight.w200,
                          height: 1.0)),
                  const SizedBox(width: 14),
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(WeatherUtils.getWeatherIcon(weather.weatherCode),
                            color: Colors.white, size: 40),
                        const SizedBox(height: 6),
                        Text(
                            WeatherUtils.getConditionLocalized(
                                weather.weatherCode, l10n),
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500)),
                        Text(
                            WeatherUtils.getDescriptionLocalized(
                                weather.weatherCode, l10n),
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.75),
                                fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              // Stats row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _miniStat(Icons.water_drop_rounded, '${weather.humidity}%',
                      l10n.humidity),
                  _miniStat(
                      Icons.air_rounded,
                      '${weather.windSpeed.toStringAsFixed(0)} km/h',
                      l10n.wind),
                  _miniStat(
                      Icons.thermostat_rounded,
                      '${weather.feelsLike.toStringAsFixed(0)}°',
                      l10n.feelsLike),
                  _miniStat(Icons.arrow_downward_rounded,
                      '${weather.tempMin.toStringAsFixed(0)}°', l10n.low),
                  _miniStat(Icons.arrow_upward_rounded,
                      '${weather.tempMax.toStringAsFixed(0)}°', l10n.high),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // === AQI CARD ===
        if (_aqi != null) _buildAqiCard(),

        const SizedBox(height: 20),

        // === 5-DAY FORECAST ===
        Text(l10n.fiveDayForecast,
            style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),

        ...weather.dailyForecast.take(5).toList().asMap().entries.map((e) {
          final day = e.value;
          final isToday = e.key == 0;
          final grad = WeatherUtils.getWeatherGradient(day.weatherCode);
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [AppTheme.cardShadow],
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 68,
                  child: Text(
                      isToday
                          ? l10n.today
                          : DateFormat('EEE d').format(day.date),
                      style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500)),
                ),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: grad),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(WeatherUtils.getWeatherIcon(day.weatherCode),
                      color: Colors.white, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                    child: Text(
                        WeatherUtils.getConditionLocalized(
                            day.weatherCode, l10n),
                        style: TextStyle(
                            color: AppTheme.textSecondary, fontSize: 13))),
                if (day.precipitationSum > 0) ...[
                  Icon(Icons.water_drop_rounded,
                      color: Colors.blue.shade300, size: 13),
                  const SizedBox(width: 2),
                  Text('${day.precipitationSum.toStringAsFixed(0)}mm',
                      style: const TextStyle(
                          color: Color(0xFF42A5F5), fontSize: 11)),
                  const SizedBox(width: 8),
                ],
                Text(
                    '${day.tempMin.toStringAsFixed(0)}° / ${day.tempMax.toStringAsFixed(0)}°',
                    style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          );
        }),

        const SizedBox(height: 32),
      ],
    );
  }

  // ---- Embedded mini map showing the searched city ----
  Widget _buildMiniMap() {
    final l10n = AppLocalizations.of(context)!;
    if (_resultLat == null || _resultLon == null)
      return const SizedBox.shrink();
    final center = LatLng(_resultLat!, _resultLon!);
    final gradients = WeatherUtils.getWeatherGradient(_weather!.weatherCode);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(l10n.locationOnMap,
                style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700)),
            const Spacer(),
            Icon(Icons.map_rounded, color: AppTheme.deepBlue, size: 18),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: SizedBox(
            height: 200,
            child: FlutterMap(
              options: MapOptions(
                initialCenter: center,
                initialZoom: 10.0,
                interactionOptions: const InteractionOptions(
                  flags:
                      InteractiveFlag.pinchZoom | InteractiveFlag.doubleTapZoom,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.weather_app',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: center,
                      width: 64,
                      height: 64,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: gradients),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                              boxShadow: [
                                BoxShadow(
                                    color: gradients.first.withOpacity(0.5),
                                    blurRadius: 10)
                              ],
                            ),
                            child: Icon(
                              WeatherUtils.getWeatherIcon(
                                  _weather!.weatherCode),
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(top: 2),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(
                              color: gradients.first,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${_weather!.temperature.toStringAsFixed(0)}°',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAqiCard() {
    final l10n = AppLocalizations.of(context)!;
    final aqi = _aqi!;
    final color = WeatherUtils.getAqiColor(aqi.aqi);
    final readableColor = WeatherUtils.getReadableAqiAccentColor(color);

    // Pollutant reference limits for progress bars
    const limits = {
      'PM2.5': 35.0,
      'PM10': 50.0,
      'CO': 4.0,
      'SO2': 35.0,
      'NO2': 53.0,
    };

    final orderedKeys = ['PM2.5', 'PM10', 'CO', 'SO2', 'NO2'];
    final orderedPollutants = <MapEntry<String, double>>[];
    for (final key in orderedKeys) {
      final matchKey = aqi.pollutants.keys.firstWhere(
        (k) => k.toUpperCase() == key.toUpperCase(),
        orElse: () => '',
      );
      orderedPollutants.add(
        MapEntry(
          key,
          (matchKey.isNotEmpty && aqi.pollutants[matchKey] != null)
              ? aqi.pollutants[matchKey]!
              : 0.0,
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [AppTheme.cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top band: AQI number + category ──────────────
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: color.withOpacity(0.09),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
              border:
                  Border(bottom: BorderSide(color: color.withOpacity(0.15))),
            ),
            child: Row(
              children: [
                // Large AQI number circle
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: color.withOpacity(0.4), width: 2),
                  ),
                  child: Center(
                    child: Text('${aqi.aqi}',
                        style: TextStyle(
                            color: readableColor,
                            fontSize: 22,
                            fontWeight: FontWeight.w800)),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.airQualityIndex,
                          style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w500)),
                      const SizedBox(height: 2),
                      Text(aqi.category,
                          style: TextStyle(
                              color: readableColor,
                              fontSize: 18,
                              fontWeight: FontWeight.w800)),
                      const SizedBox(height: 2),
                      Row(children: [
                        Icon(Icons.circle, color: readableColor, size: 8),
                        const SizedBox(width: 5),
                        Text('${l10n.mainPollutant} ${aqi.mainPollutant}',
                            style: TextStyle(
                                color: readableColor.withOpacity(0.85),
                                fontSize: 12)),
                      ]),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Health recommendation ─────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.health_and_safety_rounded,
                    color: readableColor, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    aqi.healthRecommendation,
                    style: TextStyle(
                        color: AppTheme.textPrimary, fontSize: 13, height: 1.4),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),
          const Divider(indent: 16, endIndent: 16, height: 1),
          const SizedBox(height: 12),

          // ── Pollutant progress bars ───────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
            child: Text(l10n.pollutants,
                style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              children: orderedPollutants.map((entry) {
                final limit = limits[entry.key] ?? 100.0;
                final ratio = (entry.value / limit).clamp(0.0, 1.0);
                final barColor = ratio < 0.5
                    ? const Color(0xFF4CAF50)
                    : ratio < 0.8
                        ? const Color(0xFFFF9800)
                        : const Color(0xFFF44336);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 46,
                        child: Text(entry.key,
                            style: const TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600)),
                      ),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: ratio,
                            backgroundColor: Colors.grey.shade100,
                            valueColor: AlwaysStoppedAnimation<Color>(barColor),
                            minHeight: 7,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 62,
                        child: Text(
                          '${entry.value.toStringAsFixed(1)} µg/m³',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                              color: barColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTravelTips() {
    final l10n = AppLocalizations.of(context)!;
    final weather = _weather!;
    final aqi = _aqi;
    final tips = <Map<String, dynamic>>[];

    if (weather.weatherCode >= 95) {
      tips.add({
        'icon': Icons.thunderstorm_rounded,
        'color': const Color(0xFF5C6BC0),
        'tip': l10n.thunderstormAlert
      });
    }
    if (weather.weatherCode >= 61 && weather.weatherCode <= 82) {
      tips.add({
        'icon': Icons.umbrella_rounded,
        'color': const Color(0xFF42A5F5),
        'tip': l10n.packRainJacket
      });
    }
    if (weather.temperature < 5) {
      tips.add({
        'icon': Icons.ac_unit_rounded,
        'color': const Color(0xFF81D4FA),
        'tip': l10n.heavyWinterClothing
      });
    } else if (weather.temperature < 15) {
      tips.add({
        'icon': Icons.ac_unit_rounded,
        'color': const Color(0xFF81D4FA),
        'tip': l10n.bundleUp
      });
    }
    if (weather.temperature > 35) {
      tips.add({
        'icon': Icons.wb_sunny_rounded,
        'color': const Color(0xFFFFD54F),
        'tip': l10n.carrySunscreen
      });
    } else if (weather.temperature > 28) {
      tips.add({
        'icon': Icons.wb_sunny_rounded,
        'color': const Color(0xFFFFD54F),
        'tip': l10n.lightClothing
      });
    }
    if (aqi != null && aqi.aqi > 150) {
      tips.add({
        'icon': Icons.masks_rounded,
        'color': const Color(0xFFEF5350),
        'tip': l10n.avoidOutdoorActivities
      });
    } else if (aqi != null && aqi.aqi > 100) {
      tips.add({
        'icon': Icons.masks_rounded,
        'color': const Color(0xFFFF9800),
        'tip': l10n.checkAqiBeforeOutdoor
      });
    }
    if (weather.humidity > 80) {
      tips.add({
        'icon': Icons.water_drop_rounded,
        'color': const Color(0xFF26A69A),
        'tip': l10n.lightClothing
      });
    }
    if (weather.windSpeed > 40) {
      tips.add({
        'icon': Icons.air_rounded,
        'color': const Color(0xFF78909C),
        'tip': l10n.windyDay
      });
    }
    if (tips.isEmpty) {
      tips.add({
        'icon': Icons.check_circle_rounded,
        'color': const Color(0xFF4CAF50),
        'tip': l10n.clearSunny
      });
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.travelTips,
            style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [AppTheme.cardShadow],
          ),
          child: Column(
            children: tips
                .map((tip) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: (tip['color'] as Color).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(tip['icon'] as IconData,
                                color: tip['color'] as Color, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(tip['tip'] as String,
                                  style: TextStyle(
                                      color: AppTheme.textPrimary,
                                      fontSize: 14)),
                            ),
                          ),
                        ],
                      ),
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _miniStat(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 16),
        const SizedBox(height: 3),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w700)),
        Text(label,
            style:
                TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 10)),
      ],
    );
  }

  Widget _actionBtn({
    required IconData icon,
    required List<Color> colors,
    required VoidCallback onTap,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: colors),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [AppTheme.cardShadow],
          ),
          child: Icon(icon, color: Colors.white, size: 22),
        ),
      ),
    );
  }

  Widget _buildErrorCard() {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [AppTheme.cardShadow],
      ),
      child: Column(
        children: [
          const Icon(Icons.search_off_rounded,
              color: Color(0xFFEF5350), size: 48),
          const SizedBox(height: 12),
          Text(_error,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF546E7A), fontSize: 14)),
          const SizedBox(height: 8),
          Text(l10n.tryExample,
              style: const TextStyle(color: Color(0xFF90A4AE), fontSize: 12)),
        ],
      ),
    );
  }
}
