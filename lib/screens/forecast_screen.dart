// ============================================================
// forecast_screen.dart
// Shows:
//   • Horizontal 8-hour quick-view
//   • Full 7-day daily forecast list
// ============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/weather_provider.dart';
import '../utils/weather_utils.dart';
import '../theme/app_theme.dart';
import '../l10n/app_localizations.dart';

class ForecastScreen extends StatelessWidget {
  const ForecastScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WeatherProvider>();
    final weather = provider.weatherData;
    final l10n = AppLocalizations.of(context)!;

    if (provider.loadingState == LoadingState.loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (weather == null) {
      return Scaffold(body: Center(child: Text(l10n.noForecastData)));
    }

    final gradients = WeatherUtils.getWeatherGradient(weather.weatherCode);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // --- Header ---
          SliverAppBar(
            expandedHeight: 150,
            pinned: true,
            backgroundColor: gradients.first,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: gradients),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(l10n.sevenDayForecast,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(weather.cityName,
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 14)),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // --- Content ---
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

                  // 8-hour quick strip
                  _buildHourlyStrip(provider, l10n),
                  const SizedBox(height: 24),

                  // 7-day list heading
                  Text(l10n.dailyForecast,
                      style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),

                  // One card per day
                  ...weather.dailyForecast.asMap().entries.map((entry) {
                    return _buildDayCard(
                        entry.value, entry.key == 0, provider.tempSymbol, l10n);
                  }),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ----- 8-hour horizontal overview -----
  Widget _buildHourlyStrip(WeatherProvider provider, AppLocalizations l10n) {
    final hourly = provider.weatherData!.hourlyForecast.take(8).toList();
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [AppTheme.cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.nextEightHours,
              style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: hourly.map((h) {
              return Column(
                children: [
                  Text(DateFormat('ha').format(h.time).toLowerCase(),
                      style: const TextStyle(
                          color: AppTheme.textSecondary, fontSize: 11)),
                  const SizedBox(height: 6),
                  Icon(WeatherUtils.getWeatherIcon(h.weatherCode),
                      color: AppTheme.deepBlue, size: 20),
                  const SizedBox(height: 6),
                  Text('${h.temperature.toStringAsFixed(0)}°',
                      style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600)),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ----- One row for a single day -----
  Widget _buildDayCard(
      dynamic day, bool isToday, String tempSymbol, AppLocalizations l10n) {
    final gradient = WeatherUtils.getWeatherGradient(day.weatherCode);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [AppTheme.cardShadow],
      ),
      child: Row(
        children: [
          // Day name
          SizedBox(
            width: 72,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isToday ? l10n.today : DateFormat('EEE').format(day.date),
                  style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600),
                ),
                Text(DateFormat('MMM d').format(day.date),
                    style: const TextStyle(
                        color: AppTheme.textSecondary, fontSize: 11)),
              ],
            ),
          ),
          // Weather icon
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: gradient),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(WeatherUtils.getWeatherIcon(day.weatherCode),
                color: Colors.white, size: 20),
          ),
          const SizedBox(width: 10),
          // Condition label
          Expanded(
            child: Text(
              WeatherUtils.getConditionLocalized(day.weatherCode, l10n),
              style:
                  const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
            ),
          ),
          // Rain amount (only shown when > 0)
          if (day.precipitationSum > 0) ...[
            Icon(Icons.water_drop_rounded,
                color: Colors.blue.shade300, size: 13),
            const SizedBox(width: 2),
            Text('${day.precipitationSum.toStringAsFixed(0)}mm',
                style: const TextStyle(color: Color(0xFF42A5F5), fontSize: 11)),
            const SizedBox(width: 8),
          ],
          // Low temp
          Text('${day.tempMin.toStringAsFixed(0)}$tempSymbol',
              style: const TextStyle(
                  color: Color(0xFF42A5F5),
                  fontSize: 15,
                  fontWeight: FontWeight.w600)),
          const Text(' / ', style: TextStyle(color: Colors.grey, fontSize: 13)),
          // High temp
          Text('${day.tempMax.toStringAsFixed(0)}$tempSymbol',
              style: const TextStyle(
                  color: Color(0xFFEF5350),
                  fontSize: 15,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
