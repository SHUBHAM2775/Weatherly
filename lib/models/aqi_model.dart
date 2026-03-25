// ============================================================
// aqi_model.dart
// Data structure for Air Quality Index information.
// ============================================================

class AqiModel {
  final int aqi;                          // 0–500 index number
  final String category;                  // e.g. "Good", "Moderate"
  final String mainPollutant;             // e.g. "PM2.5"
  final String cityName;
  final DateTime timestamp;
  final Map<String, double> pollutants;   // e.g. {"PM2.5": 18.4}
  final List<AqiForecast> forecast;       // 7-day AQI trend
  final int windDirection;                // Wind direction in degrees (0-360)

  AqiModel({
    required this.aqi,
    required this.category,
    required this.mainPollutant,
    required this.cityName,
    required this.timestamp,
    required this.pollutants,
    required this.forecast,
    required this.windDirection,
  });

  // --- Computed health advice based on AQI value ---

  String get healthRecommendation {
    if (aqi <= 50)  return 'Air quality is good. Great time to be outdoors!';
    if (aqi <= 100) return 'Air quality is acceptable. Sensitive individuals should limit prolonged outdoor exertion.';
    if (aqi <= 150) return 'Sensitive groups may experience health effects. Limit prolonged outdoor exertion.';
    if (aqi <= 200) return 'Everyone may experience effects. Avoid prolonged outdoor activities.';
    if (aqi <= 300) return 'Health alert! Avoid outdoor activities.';
    return 'Hazardous! Stay indoors and keep windows closed.';
  }

  String get childrenAdvice {
    if (aqi <= 50)  return 'Safe for all outdoor play';
    if (aqi <= 100) return 'Generally safe; limit heavy play';
    if (aqi <= 150) return 'Reduce heavy outdoor activities';
    return 'Keep children indoors';
  }

  String get elderlyAdvice {
    if (aqi <= 50)  return 'No restrictions needed';
    if (aqi <= 100) return 'Consider reducing time outdoors';
    if (aqi <= 150) return 'Stay indoors if possible';
    return 'Remain indoors';
  }

  String get asthmaAdvice {
    if (aqi <= 50)  return 'Low risk — keep inhaler handy';
    if (aqi <= 100) return 'Moderate risk — carry medication';
    if (aqi <= 150) return 'High risk — minimise outdoor exposure';
    return 'Critical — stay indoors';
  }
}

// ---- One day in the AQI forecast ----
class AqiForecast {
  final DateTime date;
  final int avgAqi;
  final String category;

  AqiForecast({
    required this.date,
    required this.avgAqi,
    required this.category,
  });
}
