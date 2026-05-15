import 'dart:convert';
import 'package:location/location.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationService {
  final Location _location = Location();

  Future<String?> checkAndRequestPermissions() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) {
        return "Location services are disabled.";
      }
    }

    permissionGranted = await _location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return "Location permission denied.";
      }
    }

    return null; // Null means success
  }

  Stream<LocationData> getLocationStream() {
    _location.enableBackgroundMode(enable: true);
    return _location.onLocationChanged;
  }

  Future<List<LatLng>> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final String? historyJson = prefs.getString('location_history');
    if (historyJson != null) {
      try {
        final List<dynamic> decoded = jsonDecode(historyJson);
        return decoded.map((item) => LatLng(item['lat'], item['lng'])).toList();
      } catch (e) {
        // Handle error
      }
    }
    return [];
  }

  Future<void> saveHistory(List<LatLng> history) async {
    final prefs = await SharedPreferences.getInstance();
    final String historyJson = jsonEncode(history.map((ll) => {'lat': ll.latitude, 'lng': ll.longitude}).toList());
    await prefs.setString('location_history', historyJson);
  }
}