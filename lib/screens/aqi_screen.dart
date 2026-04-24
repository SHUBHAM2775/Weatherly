// ============================================================
// aqi_screen.dart
// Full Air Quality dashboard showing:
//   • Big AQI number + colour-coded gauge
//   • Health recommendation
//   • Pollutant breakdown with progress bars
//   • Advice for children, elderly, asthma
//   • 7-day AQI forecast
// ============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/weather_provider.dart';
import '../utils/weather_utils.dart';
import '../theme/app_theme.dart';
import '../l10n/app_localizations.dart';

class AqiScreen extends StatelessWidget {
  const AqiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WeatherProvider>();
    final aqi = provider.aqiData;
    final l10n = AppLocalizations.of(context)!;

    if (provider.loadingState == LoadingState.loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (aqi == null) {
      return Scaffold(body: Center(child: Text(l10n.noAqiData)));
    }

    final aqiColor = WeatherUtils.getAqiColor(aqi.aqi);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // --- Coloured header based on AQI level ---
          SliverAppBar(
            expandedHeight: 170,
            pinned: true,
            backgroundColor: aqiColor,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [aqiColor.withOpacity(0.8), aqiColor],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(l10n.airQuality,
                            style: const TextStyle(
                                color: Colors.black,
                                fontSize: 28,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.location_on_rounded,
                                color: Colors.black87, size: 14),
                            const SizedBox(width: 4),
                            Text(aqi.cityName,
                                style: const TextStyle(
                                    color: Colors.black87, fontSize: 14)),
                            const Spacer(),
                            Text(DateFormat('HH:mm').format(aqi.timestamp),
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 12)),
                          ],
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // --- White content area ---
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

                  // AQI number + scale bar
                  _buildAqiGauge(
                      aqi.aqi, aqiColor, aqi.category, aqi.mainPollutant, l10n),
                  const SizedBox(height: 16),

                  // Health advice banner
                  if (provider.aiSuggestionLoading)
                    _buildHealthBanner('Loading AI tip...', aqiColor, l10n)
                  else if (provider.aqiAiSuggestion != null)
                    _buildHealthBanner(provider.aqiAiSuggestion!, aqiColor, l10n)
                  else
                    _buildHealthBanner(aqi.healthRecommendation, aqiColor, l10n),
                  const SizedBox(height: 20),

                  // Pollutant breakdown
                  Text(l10n.pollutantBreakdown,
                      style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  _buildPollutants(aqi.pollutants),
                  const SizedBox(height: 20),

                    // Pollutant-specific tip
                    Text('Pollutant-Specific Tip',
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),
                    _buildPollutantTipCard(aqi.mainPollutant, aqi.aqi),
                  const SizedBox(height: 20),

                  // 7-day AQI forecast
                  Text(l10n.aqiForecast,
                      style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  _buildAqiForecastList(aqi, l10n),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ------ Big AQI number with colour scale bar ------
  Widget _buildAqiGauge(int aqiVal, Color color, String category,
      String pollutant, AppLocalizations l10n) {
    final readableAccent = WeatherUtils.getReadableAqiAccentColor(color);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [AppTheme.cardShadow],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Big number
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$aqiVal',
                      style: TextStyle(
                        color: readableAccent,
                          fontSize: 72,
                          fontWeight: FontWeight.w200,
                          height: 1)),
                  Text(l10n.aqi,
                      style: const TextStyle(
                          color: AppTheme.textSecondary, fontSize: 14)),
                ],
              ),
              const Spacer(),
              // Category badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: color.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Text(category,
                        style: TextStyle(
                            color: readableAccent,
                            fontSize: 14,
                            fontWeight: FontWeight.w700)),
                    const SizedBox(height: 3),
                    Text('${l10n.mainPollutant} $pollutant',
                        style: TextStyle(
                            color: readableAccent.withOpacity(0.85),
                            fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Colour scale bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: const SizedBox(
              height: 10,
              child: Row(
                children: [
                  Expanded(child: ColoredBox(color: Color(0xFF4CAF50))),
                  Expanded(child: ColoredBox(color: Color(0xFFFFEB3B))),
                  Expanded(child: ColoredBox(color: Color(0xFFFF9800))),
                  Expanded(child: ColoredBox(color: Color(0xFFF44336))),
                  Expanded(child: ColoredBox(color: Color(0xFF9C27B0))),
                  Expanded(child: ColoredBox(color: Color(0xFF7B1FA2))),
                ],
              ),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              l10n.aqiGood,
              l10n.aqiModerate,
              l10n.aqiUsg,
              l10n.aqiUnhealthy,
              l10n.aqiVeryUnhealthy,
              l10n.aqiHazardous
            ]
                .map((l) => Text(l,
                    style: const TextStyle(fontSize: 9, color: Colors.grey),
                    textAlign: TextAlign.center))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthBanner(String advice, Color color, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.health_and_safety_rounded,
              color: AppTheme.textPrimary, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('AI Suggestion',
                    style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(advice,
                    style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 13,
                        height: 1.4),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPollutants(Map<String, double> pollutants) {
    // Reference limits for each pollutant (µg/m³)
    const limits = {
      'PM2.5': 35.0,
      'PM10': 50.0,
      'CO': 4.0,
      'SO2': 35.0,
      'NO2': 53.0,
      'O3': 100.0,
    };

    // Keep only the specified pollutants in the specified order
    final orderedKeys = ['PM2.5', 'PM10', 'NO2', 'SO2', 'CO', 'O3'];
    final filteredPollutants = <String, double>{};

    for (final key in orderedKeys) {
      // Check for exact match or case-insensitive match
      final matchKey = pollutants.keys.firstWhere(
        (k) => k.toUpperCase() == key.toUpperCase(),
        orElse: () => '',
      );

      // Always render all four rows in requested order.
      filteredPollutants[key] =
          (matchKey.isNotEmpty && pollutants[matchKey] != null)
              ? pollutants[matchKey]!
              : 0.0;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [AppTheme.cardShadow],
      ),
      child: Column(
        children: filteredPollutants.entries.map((entry) {
          final limit = limits[entry.key] ?? 100.0;
          final ratio = (entry.value / limit).clamp(0.0, 1.0);
          final barColor = ratio < 0.5
              ? const Color(0xFF4CAF50)
              : ratio < 0.8
                  ? const Color(0xFFFF9800)
                  : const Color(0xFFF44336);
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(entry.key,
                        style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600)),
                    Text('${entry.value.toStringAsFixed(1)} µg/m³',
                        style: TextStyle(
                            color: barColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w500)),
                  ],
                ),
                const SizedBox(height: 6),
                LinearProgressIndicator(
                  value: ratio,
                  backgroundColor: Colors.grey.shade100,
                  valueColor: AlwaysStoppedAnimation<Color>(barColor),
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPollutantTipCard(String mainPollutant, int aqi) {
    final severityColor = WeatherUtils.getAqiColor(aqi);
    final tip = _getPollutantTip(mainPollutant, aqi);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [AppTheme.cardShadow],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: severityColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.science_rounded, color: severityColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Main pollutant: ${mainPollutant.toUpperCase()}',
                        style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w700),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildSeverityChip(aqi, severityColor),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  tip,
                  style: const TextStyle(
                      color: AppTheme.textSecondary, fontSize: 13, height: 1.3),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeverityChip(int aqi, Color color) {
    final readableAccent = WeatherUtils.getReadableAqiAccentColor(color);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        _getSeverityLabel(aqi),
        style: TextStyle(
            color: readableAccent, fontSize: 11, fontWeight: FontWeight.w700),
      ),
    );
  }

  String _getSeverityLabel(int aqi) {
    if (aqi <= 50) return 'Good';
    if (aqi <= 100) return 'Moderate';
    if (aqi <= 150) return 'USG';
    if (aqi <= 200) return 'Unhealthy';
    if (aqi <= 300) return 'Very Unhealthy';
    return 'Hazardous';
  }

  String _getPollutantTip(String pollutant, int aqi) {
    final normalized = pollutant.toUpperCase().replaceAll('.', '').trim();
    final highRisk = aqi > 150;

    final tips = <String, String>{
      'PM25': highRisk
          ? 'Wear a mask outdoors and keep windows closed during peak traffic hours.'
          : 'Avoid heavy traffic routes and ventilate rooms when outdoor air looks clear.',
      'PM10': highRisk
          ? 'Limit outdoor workouts and rinse face after returning indoors.'
          : 'Reduce dust exposure and avoid outdoor exercise near construction areas.',
      'O3': highRisk
          ? 'Avoid afternoon outdoor activity and exercise indoors if possible.'
          : 'Prefer morning walks and reduce intense activity in direct sunlight.',
      'NO2': highRisk
          ? 'Stay away from busy roads and keep children indoors during rush hours.'
          : 'Choose low-traffic streets and avoid long roadside exposure.',
      'SO2': highRisk
          ? 'Keep rescue medication nearby and avoid outdoor exertion today.'
          : 'If breathing feels irritated, move indoors and rest.',
      'CO': highRisk
          ? 'Avoid enclosed parking areas and ensure indoor ventilation.'
          : 'Keep indoor spaces ventilated and avoid lingering near vehicle exhaust.',
      'CO2': highRisk
          ? 'Increase room ventilation and avoid crowded indoor spaces for long periods.'
          : 'Open windows periodically to refresh indoor air.',
    };

    return tips[normalized] ??
        (highRisk
            ? 'Air quality is elevated. Reduce outdoor activity and keep windows closed.'
            : 'Air quality is manageable. Prefer light outdoor activity and stay hydrated.');
  }

  Widget _buildAqiForecastList(dynamic aqi, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [AppTheme.cardShadow],
      ),
      child: Column(
        children: aqi.forecast.asMap().entries.map<Widget>((e) {
          final i = e.key;
          final f = e.value;
          final color = WeatherUtils.getAqiColor(f.avgAqi);
          final readableAccent = WeatherUtils.getReadableAqiAccentColor(color);
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                SizedBox(
                  width: 80,
                  child: Text(
                    i == 0
                        ? l10n.today
                        : DateFormat('EEE d MMM').format(f.date),
                    style: const TextStyle(
                        color: AppTheme.textSecondary, fontSize: 12),
                  ),
                ),
                Expanded(
                  child: LinearProgressIndicator(
                    value: (f.avgAqi / 300).clamp(0.0, 1.0),
                    backgroundColor: Colors.grey.shade100,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 55,
                  child: Text(
                    '${f.avgAqi} ${f.category.split(' ').first}',
                    style: TextStyle(
                    color: readableAccent,
                        fontSize: 11,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
