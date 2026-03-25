import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Handles app localization for multiple languages.
/// Loads JSON translation files and provides translated strings.
class AppLocalizations {
  final Locale locale;
  late Map<String, String> _localizedStrings;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      AppLocalizationsDelegate();

  /// Load the JSON file for the current locale
  Future<bool> load() async {
    String jsonString = await rootBundle.loadString(
      'lib/l10n/app_${locale.languageCode}.arb',
    );
    Map<String, dynamic> jsonMap = json.decode(jsonString);
    _localizedStrings = jsonMap.map((key, value) {
      return MapEntry(key, value.toString());
    });
    return true;
  }

  /// Get a translated string by key
  String translate(String key) {
    return _localizedStrings[key] ?? key;
  }

  // --- App Info ---
  String get appName => translate('appName');
  String get appTagline => translate('appTagline');

  // --- Navigation ---
  String get home => translate('home');
  String get forecast => translate('forecast');
  String get air => translate('air');
  String get map => translate('map');
  String get travel => translate('travel');
  String get settings => translate('settings');

  // --- Splash Screen ---
  String get startingUp => translate('startingUp');
  String get detectingLocation => translate('detectingLocation');
  String get ready => translate('ready');

  // --- Home Screen ---
  String get humidity => translate('humidity');
  String get wind => translate('wind');
  String get feelsLike => translate('feelsLike');
  String get hourlyForecast => translate('hourlyForecast');
  String get todayRange => translate('todayRange');
  String get updated => translate('updated');
  String get loadingWeather => translate('loadingWeather');
  String get unableToLoadWeather => translate('unableToLoadWeather');
  String get retry => translate('retry');

  // --- Forecast Screen ---
  String get sevenDayForecast => translate('sevenDayForecast');
  String get nextEightHours => translate('nextEightHours');
  String get dailyForecast => translate('dailyForecast');
  String get today => translate('today');
  String get noForecastData => translate('noForecastData');

  // --- AQI Screen ---
  String get airQuality => translate('airQuality');
  String get aqi => translate('aqi');
  String get healthRecommendation => translate('healthRecommendation');
  String get windDirection => translate('windDirection');
  String get pollutantBreakdown => translate('pollutantBreakdown');
  String get sensitiveGroups => translate('sensitiveGroups');
  String get children => translate('children');
  String get elderly => translate('elderly');
  String get asthmaRespiratory => translate('asthmaRespiratory');
  String get aqiForecast => translate('aqiForecast');
  String get noAqiData => translate('noAqiData');

  // --- AQI Categories ---
  String get aqiGood => translate('aqiGood');
  String get aqiModerate => translate('aqiModerate');
  String get aqiUsg => translate('aqiUsg');
  String get aqiUnhealthy => translate('aqiUnhealthy');
  String get aqiVeryUnhealthy => translate('aqiVeryUnhealthy');
  String get aqiHazardous => translate('aqiHazardous');

  // --- Map Screen ---
  String get weatherMap => translate('weatherMap');
  String get legend => translate('legend');
  String get clear => translate('clear');
  String get cloudy => translate('cloudy');
  String get rain => translate('rain');
  String get snow => translate('snow');
  String get thunder => translate('thunder');
  String get loadingCity => translate('loadingCity');

  // --- Travel Screen ---
  String get travelWeather => translate('travelWeather');
  String get searchCitiesIndia => translate('searchCitiesIndia');
  String get searchCitiesHint => translate('searchCitiesHint');
  String get popularCitiesIndia => translate('popularCitiesIndia');
  String get fetchingWeather => translate('fetchingWeather');
  String get locationOnMap => translate('locationOnMap');
  String get low => translate('low');
  String get high => translate('high');
  String get airQualityIndex => translate('airQualityIndex');
  String get mainPollutant => translate('mainPollutant');
  String get pollutants => translate('pollutants');
  String get travelTips => translate('travelTips');
  String get fiveDayForecast => translate('fiveDayForecast');
  String get tryExample => translate('tryExample');

  // --- Popular Cities ---
  String get mumbai => translate('mumbai');
  String get delhi => translate('delhi');
  String get bangalore => translate('bangalore');
  String get hyderabad => translate('hyderabad');
  String get chennai => translate('chennai');
  String get kolkata => translate('kolkata');
  String get pune => translate('pune');
  String get jaipur => translate('jaipur');
  String get lucknow => translate('lucknow');
  String get chandigarh => translate('chandigarh');

  // --- Settings Screen ---
  String get units => translate('units');
  String get temperature => translate('temperature');
  String get celsius => translate('celsius');
  String get fahrenheit => translate('fahrenheit');
  String get windSpeed => translate('windSpeed');
  String get notifications => translate('notifications');
  String get weatherAlerts => translate('weatherAlerts');
  String get notifySignificantChanges => translate('notifySignificantChanges');
  String get aqiAlertThreshold => translate('aqiAlertThreshold');
  String get alertWhenAqiExceeds => translate('alertWhenAqiExceeds');
  String get notificationTesting => translate('notificationTesting');
  String get simulateAqiTest => translate('simulateAqiTest');
  String get enableWeatherAlertsToTest => translate('enableWeatherAlertsToTest');
  String get testAqi => translate('testAqi');
  String get sendTestAlert => translate('sendTestAlert');
  String get data => translate('data');
  String get refreshNow => translate('refreshNow');
  String get reloadWeatherData => translate('reloadWeatherData');
  String get about => translate('about');
  String get weatherData => translate('weatherData');
  String get openMeteoInfo => translate('openMeteoInfo');
  String get aqiData => translate('aqiData');
  String get waqiInfo => translate('waqiInfo');
  String get mapTiles => translate('mapTiles');
  String get openStreetMapInfo => translate('openStreetMapInfo');
  String get version => translate('version');
  String get versionInfo => translate('versionInfo');

  // --- Language Selection ---
  String get language => translate('language');
  String get english => translate('english');
  String get hindi => translate('hindi');
  String get marathi => translate('marathi');

  // --- Weather Conditions ---
  String get clearSky => translate('clearSky');
  String get partlyCloudy => translate('partlyCloudy');
  String get overcast => translate('overcast');
  String get foggy => translate('foggy');
  String get drizzle => translate('drizzle');
  String get rainWeather => translate('rainWeather');
  String get snowWeather => translate('snowWeather');
  String get rainShowers => translate('rainShowers');
  String get snowShowers => translate('snowShowers');
  String get thunderstorm => translate('thunderstorm');
  String get unknown => translate('unknown');

  // --- Weather Descriptions ---
  String get clearSunny => translate('clearSunny');
  String get mainlyClear => translate('mainlyClear');
  String get partlyCloudyDesc => translate('partlyCloudyDesc');
  String get overcastDesc => translate('overcastDesc');
  String get foggyDesc => translate('foggyDesc');
  String get drizzleDesc => translate('drizzleDesc');
  String get rainDesc => translate('rainDesc');
  String get snowDesc => translate('snowDesc');
  String get rainShowersDesc => translate('rainShowersDesc');
  String get snowShowersDesc => translate('snowShowersDesc');
  String get thunderstormDesc => translate('thunderstormDesc');

  // --- Smart Suggestions ---
  String get thunderstormAlert => translate('thunderstormAlert');
  String get carryUmbrella => translate('carryUmbrella');
  String get bundleUp => translate('bundleUp');
  String get poorAirQuality => translate('poorAirQuality');
  String get hotDay => translate('hotDay');
  String get coldDay => translate('coldDay');
  String get windyDay => translate('windyDay');

  // --- Travel Tips ---
  String get packRainJacket => translate('packRainJacket');
  String get heavyWinterClothing => translate('heavyWinterClothing');
  String get lightClothing => translate('lightClothing');
  String get carrySunscreen => translate('carrySunscreen');
  String get checkAqiBeforeOutdoor => translate('checkAqiBeforeOutdoor');
  String get avoidOutdoorActivities => translate('avoidOutdoorActivities');

  // --- Notifications ---
  String get aqiAlerts => translate('aqiAlerts');
  String get aqiAlertsDescription => translate('aqiAlertsDescription');
  String get highAqiAlert => translate('highAqiAlert');
  String get aqiExceedsThreshold => translate('aqiExceedsThreshold');
  String get notificationTest => translate('notificationTest');
  String get testAqiExceedsThreshold => translate('testAqiExceedsThreshold');
  String get testAqiBelowThreshold => translate('testAqiBelowThreshold');

  // --- Error Messages ---
  String get failedToLoadData => translate('failedToLoadData');
}

/// Delegate class that Flutter uses to load localizations
class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'hi', 'mr'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    AppLocalizations localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}