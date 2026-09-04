import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

/// Requests location permission and reports the device's current position,
/// so results can be shown nearest-first. The app is Pakistan-only, so
/// there's no need for a country/region picker anywhere this is used.
class LocationService {
  /// Returns the current position, or null if the user denies permission,
  /// denies it permanently, or location services are turned off.
  Future<Position?> getCurrentLocation() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      return null;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return null;
    }

    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
        ),
      );
    } catch (_) {
      return null;
    }
  }

  /// Best-effort "City, Pakistan" label for a position. Returns null on any
  /// failure (no network, no result, etc.) — callers should fall back to a
  /// generic label rather than blocking on this.
  Future<String?> describePosition(Position position) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isEmpty) return null;
      final place = placemarks.first;
      final city = place.locality?.isNotEmpty == true
          ? place.locality
          : place.subAdministrativeArea;
      if (city == null || city.isEmpty) return null;
      return '$city, Pakistan';
    } catch (_) {
      return null;
    }
  }
}
