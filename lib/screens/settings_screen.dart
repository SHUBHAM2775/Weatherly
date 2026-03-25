// ============================================================
// settings_screen.dart
// User preferences:
//   • Temperature unit (°C / °F)
//   • Wind speed unit
//   • Notifications toggle
//   • AQI alert threshold slider
//   • About / data sources info
// ============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/weather_provider.dart';
import '../services/locale_provider.dart';
import '../l10n/app_localizations.dart';
import '../utils/weather_utils.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WeatherProvider>();
    final localeProvider = context.watch<LocaleProvider>();
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: CustomScrollView(
        slivers: [
          // --- Header ---
          SliverAppBar(
            expandedHeight: 140,
            pinned: true,
            backgroundColor: const Color(0xFF0D47A1),
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
                        Text(l10n.settings,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // --- Settings content ---
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

                  // ---- UNITS ----
                  _sectionTitle(l10n.units),
                  const SizedBox(height: 10),
                  _card(children: [
                    // Temperature toggle: Celsius / Fahrenheit
                    _settingRow(
                      icon: Icons.thermostat_rounded,
                      iconColor: const Color(0xFFEF5350),
                      title: l10n.temperature,
                      subtitle:
                          provider.isCelsius ? l10n.celsius : l10n.fahrenheit,
                      trailing: Switch.adaptive(
                        value: provider.isCelsius,
                        onChanged: (v) => provider.setTemperatureUnit(v),
                        activeColor: AppTheme.deepBlue,
                      ),
                    ),

                    _divider(),

                    // Wind unit selector
                    _settingRow(
                      icon: Icons.air_rounded,
                      iconColor: const Color(0xFF26A69A),
                      title: l10n.windSpeed,
                      subtitle: provider.windUnit,
                      trailing: DropdownButton<String>(
                        value: provider.windUnit,
                        underline: const SizedBox(),
                        items: ['km/h', 'm/s', 'mph']
                            .map((u) =>
                                DropdownMenuItem(value: u, child: Text(u)))
                            .toList(),
                        onChanged: (v) => provider.setWindUnit(v ?? 'km/h'),
                        style: const TextStyle(
                            color: AppTheme.textPrimary, fontSize: 14),
                      ),
                    ),
                  ]),

                  const SizedBox(height: 20),

                  // ---- LANGUAGE ----
                  _sectionTitle(l10n.language),
                  const SizedBox(height: 10),
                  _card(children: [
                    _settingRow(
                      icon: Icons.language_rounded,
                      iconColor: AppTheme.deepBlue,
                      title: l10n.language,
                      subtitle: _localeLabel(localeProvider.locale, l10n),
                      trailing: DropdownButton<String>(
                        value: localeProvider.locale.languageCode,
                        underline: const SizedBox(),
                        items: LocaleProvider.supportedLocales
                            .map((locale) => DropdownMenuItem<String>(
                                  value: locale.languageCode,
                                  child: Text(_localeLabel(locale, l10n)),
                                ))
                            .toList(),
                        onChanged: (code) {
                          if (code == null) return;
                          final selected =
                              LocaleProvider.supportedLocales.firstWhere(
                            (locale) => locale.languageCode == code,
                            orElse: () => localeProvider.locale,
                          );
                          localeProvider.setLocale(selected);
                        },
                        style: const TextStyle(
                            color: AppTheme.textPrimary, fontSize: 14),
                      ),
                    ),
                  ]),

                  const SizedBox(height: 20),

                  // ---- NOTIFICATIONS ----
                  _sectionTitle(l10n.notifications),
                  const SizedBox(height: 10),
                  _card(children: [
                    _settingRow(
                      icon: Icons.notifications_rounded,
                      iconColor: const Color(0xFFFF9800),
                      title: l10n.weatherAlerts,
                      subtitle: l10n.notifySignificantChanges,
                      trailing: Switch.adaptive(
                        value: provider.notificationsOn,
                        onChanged: (v) => provider.setNotifications(v),
                        activeColor: AppTheme.deepBlue,
                      ),
                    ),

                    _divider(),

                    // AQI alert slider
                    _settingRow(
                      icon: Icons.air_rounded,
                      iconColor: const Color(0xFF9C27B0),
                      title: l10n.aqiAlertThreshold,
                      subtitle:
                          '${l10n.alertWhenAqiExceeds} ${provider.aqiAlertThreshold}',
                      trailing: const SizedBox.shrink(),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: Column(
                        children: [
                          Slider(
                            value: provider.aqiAlertThreshold.toDouble(),
                            min: 50,
                            max: 300,
                            divisions: 5,
                            activeColor: WeatherUtils.getAqiColor(
                                provider.aqiAlertThreshold),
                            label: '${provider.aqiAlertThreshold}',
                            onChanged: (v) =>
                                provider.setAqiThreshold(v.toInt()),
                          ),
                          // Label row under the slider
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('${l10n.aqiGood}\n50',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 9, color: Colors.grey)),
                              Text('${l10n.aqiModerate}\n100',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 9, color: Colors.grey)),
                              Text('${l10n.aqiUsg}\n150',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 9, color: Colors.grey)),
                              Text('${l10n.aqiUnhealthy}\n200',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 9, color: Colors.grey)),
                              Text('${l10n.aqiHazardous}\n300',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 9, color: Colors.grey)),
                            ],
                          ),
                        ],
                      ),
                    ),

                    _divider(),

                    _settingRow(
                      icon: Icons.notification_add_rounded,
                      iconColor: const Color(0xFFD32F2F),
                      title: l10n.notificationTesting,
                      subtitle: l10n.simulateAqiTest,
                      trailing: const SizedBox.shrink(),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (!provider.notificationsOn)
                            Container(
                              padding: const EdgeInsets.all(10),
                              margin: const EdgeInsets.only(bottom: 10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFEBEE),
                                borderRadius: BorderRadius.circular(8),
                                border:
                                    Border.all(color: const Color(0xFFFFCDD2)),
                              ),
                              child: Text(
                                l10n.enableWeatherAlertsToTest,
                                style: const TextStyle(
                                    color: Color(0xFFC62828),
                                    fontSize: 12,
                                    height: 1.4),
                              ),
                            ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(l10n.testAqi,
                                  style: const TextStyle(
                                      color: AppTheme.textSecondary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600)),
                              Text('${provider.notificationTestAqi}',
                                  style: const TextStyle(
                                      color: AppTheme.textPrimary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700)),
                            ],
                          ),
                          Slider(
                            value: provider.notificationTestAqi.toDouble(),
                            min: 0,
                            max: 500,
                            divisions: 50,
                            activeColor: WeatherUtils.getAqiColor(
                                provider.notificationTestAqi),
                            label: '${provider.notificationTestAqi}',
                            onChanged: provider.notificationsOn
                                ? (v) =>
                                    provider.setNotificationTestAqi(v.toInt())
                                : null,
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.send_rounded),
                              label: Text(l10n.sendTestAlert),
                              onPressed: provider.notificationsOn
                                  ? provider.sendTestAqiNotification
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFD32F2F),
                                foregroundColor: Colors.white,
                                disabledBackgroundColor:
                                    const Color(0xFFBDBDBD),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ]),

                  const SizedBox(height: 20),

                  // ---- DATA ----
                  _sectionTitle(l10n.data),
                  const SizedBox(height: 10),
                  _card(children: [
                    _settingRow(
                      icon: Icons.refresh_rounded,
                      iconColor: const Color(0xFF0288D1),
                      title: l10n.refreshNow,
                      subtitle: l10n.reloadWeatherData,
                      trailing: IconButton(
                        icon: const Icon(Icons.chevron_right_rounded,
                            color: Colors.grey),
                        onPressed: provider.refresh,
                      ),
                    ),
                  ]),

                  const SizedBox(height: 20),

                  // ---- ABOUT ----
                  _sectionTitle(l10n.about),
                  const SizedBox(height: 10),
                  _card(children: [
                    _settingRow(
                      icon: Icons.wb_cloudy_rounded,
                      iconColor: const Color(0xFF4FC3F7),
                      title: l10n.weatherData,
                      subtitle: l10n.openMeteoInfo,
                      trailing: const SizedBox.shrink(),
                    ),
                    _divider(),
                    _settingRow(
                      icon: Icons.air_rounded,
                      iconColor: const Color(0xFF26A69A),
                      title: l10n.aqiData,
                      subtitle: l10n.waqiInfo,
                      trailing: const SizedBox.shrink(),
                    ),
                    _divider(),
                    _settingRow(
                      icon: Icons.map_rounded,
                      iconColor: const Color(0xFF7E57C2),
                      title: l10n.mapTiles,
                      subtitle: l10n.openStreetMapInfo,
                      trailing: const SizedBox.shrink(),
                    ),
                    _divider(),
                    _settingRow(
                      icon: Icons.info_outline_rounded,
                      iconColor: Colors.grey,
                      title: l10n.version,
                      subtitle: l10n.versionInfo,
                      trailing: const SizedBox.shrink(),
                    ),
                  ]),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---- Reusable helpers for this screen ----

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Color(0xFF0288D1),
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _card({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [AppTheme.cardShadow],
      ),
      child: Column(children: children),
    );
  }

  Widget _divider() {
    return const Divider(indent: 64, endIndent: 20, height: 1, thickness: 0.5);
  }

  Widget _settingRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required Widget trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Coloured icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          // Title + subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textPrimary)),
                Text(subtitle,
                    style: const TextStyle(
                        fontSize: 12, color: AppTheme.textSecondary)),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }

  String _localeLabel(Locale locale, AppLocalizations l10n) {
    switch (locale.languageCode) {
      case 'hi':
        return l10n.hindi;
      case 'mr':
        return l10n.marathi;
      default:
        return l10n.english;
    }
  }
}
