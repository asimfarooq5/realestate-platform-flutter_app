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
}
