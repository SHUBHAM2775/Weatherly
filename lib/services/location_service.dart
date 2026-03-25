// ============================================================
// location_service.dart
// Uses the device GPS to get the user's current coordinates,
// then uses geocoding to turn those into a city name.
// ============================================================

import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {

  /// Returns a map like:
  /// { 'lat': 19.07, 'lon': 72.87, 'city': 'Mumbai', 'country': 'IN' }
  Future<Map<String, dynamic>> getCurrentLocation() async {
    // Step 1 — Check if location services (GPS) are on
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled. Please turn on GPS.');
    }

    // Step 2 — Check app permission
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      // Ask the user for permission
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permission denied. Please allow it to detect your city.');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permission permanently denied. Go to App Settings to allow it.');
    }

    // Step 3 — Get GPS coordinates
    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.medium,   // medium = faster than high
    );

    // Step 4 — Convert coordinates to city name
    String cityName = 'Unknown';
    String country  = '';
    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        // Try different fields in case some are null
        cityName = place.locality ??
                   place.subAdministrativeArea ??
                   place.administrativeArea ??
                   'Unknown';
        country  = place.isoCountryCode ?? '';
      }
    } catch (_) {
      // If geocoding fails, we still have coordinates — just no city name
    }

    return {
      'lat':     position.latitude,
      'lon':     position.longitude,
      'city':    cityName,
      'country': country,
    };
  }
}
