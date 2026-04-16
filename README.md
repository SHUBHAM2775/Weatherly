# 🌦️ Weatherly

Weatherly is a smart Flutter weather app that combines real-time weather, AQI tracking, map-based location viewing, city search, travel planning, and multilingual support in one clean experience.

## Quick Snapshot

| Item             | Details                                  |
| ---------------- | ---------------------------------------- |
| Platform         | Flutter cross-platform app               |
| Targets          | Android, iOS, Web, Windows, Linux, macOS |
| State Management | Provider                                 |
| Localization     | English, Hindi, Marathi                  |
| Data Sources     | Open-Meteo, WAQI, OpenStreetMap          |

## What the App Does

Weatherly starts on a splash screen, detects the user's location, fetches weather and AQI data, then opens a bottom-navigation dashboard with the main features.

The app is organized around a simple layered architecture:

User Interaction -> UI Screens -> Providers -> Services -> External APIs and Device Services -> Models -> UI Rendering

## Screens

| Screen      | Purpose                                               |
| ----------- | ----------------------------------------------------- |
| Splash      | Animated startup while location and weather load      |
| Home        | Current weather, stats, smart tips, hourly forecast   |
| Forecast    | 8-hour quick view and 7-day forecast                  |
| Air Quality | AQI dashboard, pollutants, and health advice          |
| Map         | Interactive weather map for the current location      |
| Travel      | Search any city and view destination weather plus AQI |
| Settings    | Units, notifications, AQI threshold, and language     |

### Navigation Flow

SplashScreen -> MainScreen -> HomeScreen

- SplashScreen replaces itself with MainScreen after startup data loads.
- MainScreen uses IndexedStack so each tab stays alive.
- TravelScreen performs its own city-based lookup and does not overwrite the main dashboard state.

## Architecture

### Providers

- WeatherProvider: central state manager for weather, AQI, location, settings, loading, refresh, and alerts.
- LocaleProvider: stores and restores the selected app language.

### Services

- WeatherService: Open-Meteo weather and geocoding requests.
- AqiService: WAQI AQI requests with demo fallback data.
- LocationService: GPS permission checks, coordinate lookup, and reverse geocoding.
- NotificationService: native AQI alert notifications.

## Main Data Flow

1. App launches.
2. SplashScreen animates.
3. LocationService checks GPS and permissions.
4. WeatherProvider gets current coordinates.
5. WeatherService fetches forecast data.
6. AqiService fetches AQI data or generates demo values.
7. WeatherProvider stores the results.
8. MainScreen appears.
9. Screens render the data through Provider listeners.

## Weather and AQI Features

### Weather Data

- Current temperature
- Feels-like temperature
- Minimum and maximum temperature
- Humidity
- Wind speed and direction
- Weather code and condition
- Hourly forecast
- 7-day forecast

### AQI Data

- AQI score and category
- Main pollutant
- Pollutant breakdown
- Health recommendation
- Advice for children, elderly users, and asthma-sensitive users
- 7-day AQI trend

### Smart Extras

- Smart suggestion banner on Home
- Pull-to-refresh support
- Localized text in English, Hindi, and Marathi
- Native AQI notifications

## APIs and Data Sources

### Open-Meteo

No API key is required.

Used for:

- Weather forecast
- Hourly and daily data
- City geocoding and suggestions

Endpoints:

- https://api.open-meteo.com/v1/forecast
- https://geocoding-api.open-meteo.com/v1/search

### WAQI

Used for air quality data.

If the WAQI call fails, the app falls back to realistic demo AQI data so the UI still works.

### OpenStreetMap

Used through flutter_map for interactive map rendering.

## Models

- WeatherModel: current weather plus hourly and daily forecast data.
- HourlyForecast: one hour of forecast data.
- DailyForecast: one day of forecast data.
- AqiModel: AQI value, pollutants, forecast trend, and health advice.
- AqiForecast: one day in the AQI trend.

## Dependencies

| Package                     | Purpose                  |
| --------------------------- | ------------------------ |
| http                        | API requests             |
| geolocator                  | GPS location             |
| geocoding                   | Reverse geocoding        |
| flutter_map                 | Interactive maps         |
| latlong2                    | Coordinate handling      |
| intl                        | Date and time formatting |
| shared_preferences          | Local settings storage   |
| provider                    | State management         |
| flutter_local_notifications | Native notifications     |
| shimmer                     | Loading skeletons        |
| permission_handler          | Permission flow          |
| flutter_localizations       | Localization support     |

## Project Structure

```text
lib/
├── main.dart
├── models/
│   ├── weather_model.dart
│   └── aqi_model.dart
├── services/
│   ├── weather_service.dart
│   ├── aqi_service.dart
│   ├── location_service.dart
│   ├── weather_provider.dart
│   ├── locale_provider.dart
│   └── notification_service.dart
├── screens/
│   ├── splash_screen.dart
│   ├── main_screen.dart
│   ├── home_screen.dart
│   ├── forecast_screen.dart
│   ├── aqi_screen.dart
│   ├── map_screen.dart
│   ├── travel_screen.dart
│   └── settings_screen.dart
├── widgets/
├── utils/
├── theme/
└── l10n/
```

## Setup

Install dependencies:

```bash
flutter pub get
```

Run the app:

```bash
flutter run
```

Run on a specific device:

```bash
flutter run -d android
flutter run -d ios
```

## Permissions and Notes

Weatherly needs location permission to load the current city and nearby weather. Notifications are used for AQI alerts. The map view uses the current coordinates when available.

If you want real AQI data, configure the WAQI token in lib/services/aqi_service.dart. If not, the app still works with demo AQI data.

## Data Logic

- WMO weather codes are mapped to icons and labels.
- AQI values are mapped to health categories and advice.
- User settings are stored locally with SharedPreferences.
- Temperature and wind units are converted from the Settings screen.
- Locale changes update the app language immediately.

Built with Flutter.
