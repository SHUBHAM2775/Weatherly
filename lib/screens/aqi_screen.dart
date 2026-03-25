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

                  // Wind direction card
                  _buildWindDirectionCard(aqi.windDirection, l10n),
                  const SizedBox(height: 16),

                  // Health advice banner
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

                  // Sensitive groups
                  Text(l10n.sensitiveGroups,
                      style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  _buildGroupCard(Icons.child_care_rounded, l10n.children,
                      aqi.childrenAdvice, const Color(0xFF26A69A)),
                  const SizedBox(height: 10),
                  _buildGroupCard(Icons.elderly_rounded, l10n.elderly,
                      aqi.elderlyAdvice, const Color(0xFF7E57C2)),
                  const SizedBox(height: 10),
                  _buildGroupCard(
                      Icons.medical_services_rounded,
                      l10n.asthmaRespiratory,
                      aqi.asthmaAdvice,
                      const Color(0xFFEF5350)),
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
                          color: color,
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
                            color: color,
                            fontSize: 14,
                            fontWeight: FontWeight.w700)),
                    const SizedBox(height: 3),
                    Text('${l10n.mainPollutant} $pollutant',
                        style: TextStyle(
                            color: color.withOpacity(0.8), fontSize: 11)),
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
          Icon(Icons.health_and_safety_rounded, color: color, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.healthRecommendation,
                    style: TextStyle(
                        color: color,
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(advice,
                    style: TextStyle(
                        color: color.withOpacity(0.85),
                        fontSize: 13,
                        height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWindDirectionCard(int windDirection, AppLocalizations l10n) {
    final direction = WeatherUtils.getWindDirection(windDirection);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [AppTheme.cardShadow],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFF26A69A).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.air_rounded,
                color: const Color(0xFF26A69A), size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.windDirection,
                    style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text('$direction (${windDirection}°)',
                    style: const TextStyle(
                        color: AppTheme.textSecondary, fontSize: 13)),
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
      'CO2': 1000.0,
      'CO': 4.0,
      'SO2': 35.0,
      'NO2': 53.0,
    };

    // Keep only the specified pollutants in the specified order
    final orderedKeys = ['CO2', 'CO', 'SO2', 'NO2'];
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

  Widget _buildGroupCard(
      IconData icon, String label, String advice, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [AppTheme.cardShadow],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(advice,
                    style: const TextStyle(
                        color: AppTheme.textSecondary, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
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
                        color: color,
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
