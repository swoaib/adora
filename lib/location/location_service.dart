import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:location/location.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationService {
  final Location _location = Location();
  static const platform = MethodChannel('samples.flutter.dev/location');

  Future<void> startNativeBackgroundTracking() async {
    try {
      await platform.invokeMethod<bool>('startBackgroundTracking');
    } catch (e) {
      debugPrint("Failed to start tracking: $e");
    }
  }

  Future<void> stopNativeBackgroundTracking() async {
    try {
      await platform.invokeMethod<bool>('stopBackgroundTracking');
    } catch (e) {
      debugPrint("Failed to stop tracking: $e");
    }
  }

  Future<String?> checkAndRequestPermissions() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    try {
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
    } catch (e) {
      debugPrint("Error checking location permission: $e");
      return "Failed to determine location permissions: $e";
    }

    // Try to enable background mode, which requests "Always" location permission
    try {
      bool bgModeEnabled = await _location.isBackgroundModeEnabled();
      if (!bgModeEnabled) {
        await _location.enableBackgroundMode(enable: true);
      }
    } catch (e) {
      debugPrint("Failed to enable background mode: $e");
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
        debugPrint("Failed to decode location history: $e");
      }
    }
    return [];
  }

  Future<List<LatLng>> loadNativeHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final String? historyJson = prefs.getString('native_location_history');
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