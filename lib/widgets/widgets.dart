// ============================================================
// widgets.dart
// All small reusable UI components used across screens.
// Keeping them here makes it easy to find and update them.
// ============================================================

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/weather_model.dart';
import '../models/aqi_model.dart';
import '../utils/weather_utils.dart';
import '../theme/app_theme.dart';
import '../l10n/app_localizations.dart';

// ----------------------------------------------------------
// WeatherStatCard
// The small card showing one stat (humidity, wind, feels-like)
// ----------------------------------------------------------
class WeatherStatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String? subtitle;
  final Color color;

  const WeatherStatCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [AppTheme.cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Coloured icon background
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 10),
          Text(value,
              style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.w700)),
          if (subtitle != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(subtitle!,
                  style: const TextStyle(
                      color: AppTheme.textSecondary, fontSize: 12)),
            ),
          const SizedBox(height: 2),
          Text(label,
              style:
                  const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
        ],
      ),
    );
  }
}

// ----------------------------------------------------------
// HourlyForecastCard
// One card in the horizontal hourly scroll
// ----------------------------------------------------------
class HourlyForecastCard extends StatelessWidget {
  final HourlyForecast hourly;
  final String tempSymbol;

  const HourlyForecastCard(
      {super.key, required this.hourly, required this.tempSymbol});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [AppTheme.cardShadow],
      ),
      child: Column(
        children: [
          Text(
            DateFormat('ha').format(hourly.time).toLowerCase(), // e.g. "3pm"
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
          ),
          const SizedBox(height: 6),
          Icon(WeatherUtils.getWeatherIcon(hourly.weatherCode),
              color: AppTheme.deepBlue, size: 20),
          const SizedBox(height: 6),
          Text(
            '${hourly.temperature.toStringAsFixed(0)}°',
            style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

// ----------------------------------------------------------
// SmartSuggestionBanner
// The blue banner with the AI-style daily tip
// ----------------------------------------------------------
class SmartSuggestionBanner extends StatelessWidget {
  final String suggestion;

  const SmartSuggestionBanner({super.key, required this.suggestion});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0288D1), Color(0xFF4FC3F7)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [AppTheme.cardShadow],
      ),
      child: Row(
        children: [
          const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              suggestion,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

// ----------------------------------------------------------
// AqiMiniCard
// Compact AQI summary shown on the Home screen
// ----------------------------------------------------------
class AqiMiniCard extends StatelessWidget {
  final AqiModel aqi;

  const AqiMiniCard({super.key, required this.aqi});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final color = WeatherUtils.getAqiColor(aqi.aqi);
    final readableColor = WeatherUtils.getReadableAqiAccentColor(color);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [AppTheme.cardShadow],
      ),
      child: Row(
        children: [
          // AQI number badge
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${aqi.aqi}',
                style: TextStyle(
                    color: readableColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w800),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.airQualityIndex,
                    style: const TextStyle(
                        color: AppTheme.textSecondary, fontSize: 12)),
                const SizedBox(height: 2),
                Text(aqi.category,
                    style: TextStyle(
                    color: readableColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w700)),
                Text('${l10n.mainPollutant} ${aqi.mainPollutant}',
                    style: const TextStyle(
                        color: AppTheme.textSecondary, fontSize: 11)),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: Colors.grey.shade300),
        ],
      ),
    );
  }
}
