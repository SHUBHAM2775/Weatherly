# 🌦️ Weatherly — Smart Weather App

A modern Flutter weather application with real-time data, AQI tracking,
interactive maps, and smart daily suggestions.

---

## 📱 Screens Included

| Screen | Description |
|--------|-------------|
| **Splash** | Animated loading screen while GPS + weather loads |
| **Home** | Current weather, stats, hourly forecast, smart tip |
| **Forecast** | 7-day daily forecast + 8-hour hourly strip |
| **Air Quality** | AQI gauge, pollutant bars, health advice, 7-day trend |
| **Map** | Interactive OpenStreetMap with weather marker + popup |
| **Travel** | Search any city — weather + AQI + packing tips |
| **Settings** | Units, notifications, AQI alert threshold |

---

## 🚀 Quick Start

### Step 1 — Install Flutter
If you haven't already:
```
https://docs.flutter.dev/get-started/install
```

### Step 2 — Get dependencies
```bash
cd weather_app
flutter pub get
```

### Step 3 — Run the app
```bash
# On a connected Android/iOS device or emulator:
flutter run

# Or target a specific device:
flutter run -d android
flutter run -d ios
```

---

## 🔑 API Keys

### Open-Meteo (Weather + Geocoding)
✅ **No API key needed!** Completely free and open.

### WAQI (Air Quality)
The app shows **demo AQI data** by default.
To use real AQI data:

1. Visit https://aqicn.org/api/ and sign up for a free token
2. Open `lib/services/aqi_service.dart`
3. Replace this line:
   ```dart
   static const String _apiToken = 'YOUR_WAQI_API_TOKEN';
   ```
   with:
   ```dart
   static const String _apiToken = 'your_actual_token_here';
   ```

---

## 📁 Project Structure

```
lib/
├── main.dart                    ← App entry point
├── models/
│   ├── weather_model.dart       ← Weather data structures
│   └── aqi_model.dart           ← AQI data structures
├── services/
│   ├── weather_service.dart     ← Open-Meteo API calls
│   ├── aqi_service.dart         ← WAQI API calls
│   ├── location_service.dart    ← GPS location
│   └── weather_provider.dart    ← App state (Provider)
├── screens/
│   ├── splash_screen.dart       ← Loading screen
│   ├── main_screen.dart         ← Bottom nav shell
│   ├── home_screen.dart         ← Dashboard
│   ├── forecast_screen.dart     ← 7-day forecast
│   ├── aqi_screen.dart          ← Air quality
│   ├── map_screen.dart          ← Interactive map
│   ├── travel_screen.dart       ← City search
│   └── settings_screen.dart     ← Preferences
├── widgets/
│   └── widgets.dart             ← Reusable UI components
├── utils/
│   └── weather_utils.dart       ← Helper functions
└── theme/
    └── app_theme.dart           ← Colours & styles
```

---

## 🛠️ Dependencies Used

| Package | Purpose |
|---------|---------|
| `http` | HTTP requests to weather APIs |
| `geolocator` | GPS coordinates |
| `geocoding` | Coordinates → city name |
| `flutter_map` | Interactive map widget |
| `latlong2` | Lat/lon coordinate type |
| `intl` | Date/time formatting |
| `shared_preferences` | Save settings locally |
| `provider` | State management |
| `shimmer` | Loading skeleton effect |
| `permission_handler` | Location permission |

---

## ⚙️ Android Setup (already done)

`android/app/src/main/AndroidManifest.xml` already includes:
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
```

## 🍎 iOS Setup (already done)

`ios/Runner/Info.plist` already includes:
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Weatherly needs your location to show local weather.</string>
```

---

## 🗺️ Map Screen Note

The map uses a fixed default location (Mumbai) for the marker position.
To make it fully dynamic with the real GPS location, expose `_lat` and `_lon`
as public getters in `weather_provider.dart`:

```dart
// In weather_provider.dart, add:
double? get currentLat => _lat;
double? get currentLon => _lon;
```

Then in `map_screen.dart`, read them:
```dart
final lat = provider.currentLat ?? 20.5937;
final lon = provider.currentLon ?? 78.9629;
```

---

## 🔮 Future Improvements

- [ ] Live weather radar map layers
- [ ] Push notifications for rain/AQI alerts
- [ ] Multiple saved cities
- [ ] Widget for home screen
- [ ] Dark mode
- [ ] Voice assistant integration
- [ ] Offline caching with Hive

---

## 📄 Data Sources

- **Weather:** [Open-Meteo](https://open-meteo.com/) — Free, no key
- **Air Quality:** [WAQI](https://waqi.info/) — Free tier available
- **Maps:** [OpenStreetMap](https://www.openstreetmap.org/) — Free, open-source
- **Geocoding:** [Open-Meteo Geocoding](https://open-meteo.com/en/docs/geocoding-api) — Free

---

Built with ❤️ using Flutter
