import 'dart:convert';
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
      print("Failed to start tracking: $e");
    }
  }

  Future<void> stopNativeBackgroundTracking() async {
    try {
      await platform.invokeMethod<bool>('stopBackgroundTracking');
    } catch (e) {
      print("Failed to stop tracking: $e");
    }
  }

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

    // Try to enable background mode, which requests "Always" location permission
    try {
      bool bgModeEnabled = await _location.isBackgroundModeEnabled();
      if (!bgModeEnabled) {
        await _location.enableBackgroundMode(enable: true);
      }
    } catch (e) {
      print("Failed to enable background mode: $e");
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