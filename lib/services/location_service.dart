import 'package:url_launcher/url_launcher.dart';

/// Service layer handling location and map-related utilities.
///
/// Provides methods for launching external map navigation and
/// other location-based operations.
class LocationService {
  /// Launches Google Maps with turn-by-turn directions to the specified
  /// [latitude] and [longitude].
  ///
  /// Falls back to opening the coordinates in a browser if Google Maps
  /// app is not installed.
  Future<bool> launchDirections(double latitude, double longitude) async {
    // Google Maps URL scheme for navigation
    final googleMapsUrl = Uri.parse(
      'google.navigation:q=$latitude,$longitude&mode=d',
    );

    // Fallback: Google Maps web URL
    final webUrl = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude&travelmode=driving',
    );

    try {
      // Try launching the Google Maps app first
      if (await canLaunchUrl(googleMapsUrl)) {
        return await launchUrl(googleMapsUrl);
      }
      // Fall back to web URL
      if (await canLaunchUrl(webUrl)) {
        return await launchUrl(webUrl, mode: LaunchMode.externalApplication);
      }
      return false;
    } catch (e) {
      // If both fail, try the web URL as last resort
      try {
        return await launchUrl(webUrl, mode: LaunchMode.externalApplication);
      } catch (_) {
        return false;
      }
    }
  }

  /// Opens Google Maps centered on the specified coordinates without
  /// navigation directions.
  Future<bool> openInMaps(double latitude, double longitude, String label) async {
    final url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude&query_place_id=$label',
    );

    try {
      return await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }
}
