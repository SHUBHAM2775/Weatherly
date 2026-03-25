// ============================================================
// home_screen.dart
// Main dashboard — shows:
//   • Current temperature + condition
//   • Humidity, wind, feels-like cards
//   • Smart suggestion banner
//   • AQI mini card
//   • Hourly forecast scroll
//   • Today's min/max
// ============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/weather_provider.dart';
import '../utils/weather_utils.dart';
import '../theme/app_theme.dart';
import '../widgets/widgets.dart';
import '../l10n/app_localizations.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Watch the provider — this screen rebuilds when data changes
    final provider = context.watch<WeatherProvider>();
    final weather = provider.weatherData;
    final aqi = provider.aqiData;
    final l10n = AppLocalizations.of(context)!;

    // Show spinner while loading
    if (provider.loadingState == LoadingState.loading) {
      return _buildLoading(context);
    }

    // Show error screen if something went wrong
    if (provider.loadingState == LoadingState.error || weather == null) {
      return _buildError(context, provider);
    }

    // Get gradient colours from the current weather code
    final gradientColors = WeatherUtils.getWeatherGradient(weather.weatherCode);

    return Scaffold(
      body: RefreshIndicator(
        // Pull-to-refresh to reload weather
        onRefresh: provider.refresh,
        color: Colors.white,
        backgroundColor: gradientColors.first,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // ---- Expanding top hero section ----
            SliverAppBar(
              expandedHeight: 340,
              floating: false,
              pinned: true,
              backgroundColor: gradientColors.first,
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                  onPressed: provider.refresh,
                ),
              ],
              // The big weather display when scrolled up
              flexibleSpace: FlexibleSpaceBar(
                background: _buildHero(provider, gradientColors, l10n),
              ),
            ),

            // ---- Scrollable content below hero ----
            SliverToBoxAdapter(
              child: Container(
                // White rounded top over the gradient
                decoration: const BoxDecoration(
                  color: AppTheme.backgroundLight,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Smart suggestion banner
                      SmartSuggestionBanner(
                        suggestion: WeatherUtils.getSmartSuggestionLocalized(
                          weather.weatherCode,
                          weather.humidity,
                          aqi?.aqi,
                          l10n,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Stats row: Humidity | Wind | Feels Like
                      Row(
                        children: [
                          Expanded(
                              child: WeatherStatCard(
                            icon: Icons.water_drop_rounded,
                            label: l10n.humidity,
                            value: '${weather.humidity}%',
                            color: const Color(0xFF29B6F6),
                          )),
                          const SizedBox(width: 10),
                          Expanded(
                              child: WeatherStatCard(
                            icon: Icons.air_rounded,
                            label: l10n.wind,
                            value:
                                '${provider.convertWindSpeed(weather.windSpeed).toStringAsFixed(0)} ${provider.windUnit}',
                            subtitle: WeatherUtils.getWindDirection(
                                weather.windDirection),
                            color: const Color(0xFF26A69A),
                          )),
                          const SizedBox(width: 10),
                          Expanded(
                              child: WeatherStatCard(
                            icon: Icons.thermostat_rounded,
                            label: l10n.feelsLike,
                            value:
                                '${weather.feelsLike.toStringAsFixed(0)}${provider.tempSymbol}',
                            color: const Color(0xFFEF5350),
                          )),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // AQI card
                      if (aqi != null) AqiMiniCard(aqi: aqi),

                      const SizedBox(height: 20),

                      // Hourly forecast heading
                      Text(
                        l10n.hourlyForecast,
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            ),

            // ---- Hourly scroll (separate sliver so it scrolls nicely) ----
            SliverToBoxAdapter(
              child: Container(
                color: AppTheme.backgroundLight,
                height: 110,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: weather.hourlyForecast.length > 12
                      ? 12
                      : weather.hourlyForecast.length,
                  itemBuilder: (context, index) {
                    return HourlyForecastCard(
                      hourly: weather.hourlyForecast[index],
                      tempSymbol: provider.tempSymbol,
                    );
                  },
                ),
              ),
            ),

            // ---- Min/Max card ----
            SliverToBoxAdapter(
              child: Container(
                color: AppTheme.backgroundLight,
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
                child: _buildMinMaxCard(weather, provider, l10n),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------ Hero section (big temperature display) ------
  Widget _buildHero(
      WeatherProvider provider, List<Color> gradient, AppLocalizations l10n) {
    final weather = provider.weatherData!;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: gradient,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 56, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Location row
              Row(
                children: [
                  const Icon(Icons.location_on_rounded,
                      color: Colors.white70, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    weather.country.isNotEmpty
                        ? '${weather.cityName}, ${weather.country}'
                        : weather.cityName,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              // Date
              Text(
                DateFormat('EEEE, MMM d').format(weather.timestamp),
                style: TextStyle(
                    color: Colors.white.withOpacity(0.8), fontSize: 14),
              ),
              const SizedBox(height: 16),
              // Big temperature + icon + condition
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${weather.temperature.toStringAsFixed(0)}°',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 88,
                      fontWeight: FontWeight.w200,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(WeatherUtils.getWeatherIcon(weather.weatherCode),
                            color: Colors.white, size: 44),
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMinMaxCard(
      dynamic weather, WeatherProvider provider, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [AppTheme.cardShadow],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.todayRange,
                    style: const TextStyle(
                        color: AppTheme.textSecondary, fontSize: 13)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.arrow_downward_rounded,
                        color: Color(0xFF42A5F5), size: 16),
                    const SizedBox(width: 4),
                    Text(
                        '${weather.tempMin.toStringAsFixed(0)}${provider.tempSymbol}',
                        style: const TextStyle(
                            color: Color(0xFF42A5F5),
                            fontSize: 20,
                            fontWeight: FontWeight.w700)),
                    const SizedBox(width: 14),
                    const Icon(Icons.arrow_upward_rounded,
                        color: Color(0xFFEF5350), size: 16),
                    const SizedBox(width: 4),
                    Text(
                        '${weather.tempMax.toStringAsFixed(0)}${provider.tempSymbol}',
                        style: const TextStyle(
                            color: Color(0xFFEF5350),
                            fontSize: 20,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(l10n.updated,
                  style: const TextStyle(
                      color: AppTheme.textSecondary, fontSize: 12)),
              const SizedBox(height: 4),
              Text(
                DateFormat('HH:mm').format(weather.timestamp),
                style: const TextStyle(
                    color: Color(0xFF0288D1),
                    fontSize: 16,
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoading(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
            const SizedBox(height: 20),
            Text(l10n.loadingWeather,
                style: TextStyle(color: Colors.white, fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context, WeatherProvider provider) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF37474F), Color(0xFF607D8B)],
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cloud_off_rounded,
                  color: Colors.white, size: 72),
              const SizedBox(height: 16),
              Text(l10n.unableToLoadWeather,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Text(provider.errorMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70, fontSize: 14)),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: provider.fetchWeatherByLocation,
                icon: const Icon(Icons.refresh_rounded),
                label: Text(l10n.retry),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF0288D1),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
