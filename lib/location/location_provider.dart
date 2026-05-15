import 'dart:async';

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:location/location.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationProvider with ChangeNotifier {
  final Location _location = Location();

  LocationData? _locationData;
  String _locationMessage = "";
  StreamSubscription<LocationData>? _locationSubscription;
  List<LatLng> _locationHistory = [];

  LocationData? get locationData => _locationData;
  String get locationMessage => _locationMessage;
  List<LatLng> get locationHistory => _locationHistory;

  LocationProvider() {
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final String? historyJson = prefs.getString('location_history');
    if (historyJson != null) {
      try {
        final List<dynamic> decoded = jsonDecode(historyJson);
        _locationHistory = decoded.map((item) => LatLng(item['lat'], item['lng'])).toList();
        notifyListeners();
      } catch (e) {
        debugPrint("Error loading history: $e");
      }
    }
  }

  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final String historyJson = jsonEncode(_locationHistory.map((ll) => {'lat': ll.latitude, 'lng': ll.longitude}).toList());
    await prefs.setString('location_history', historyJson);
  }

  Future<void> fetchLocation() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    _locationMessage = "Checking location services...";
    notifyListeners();

    serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) {
        _locationMessage = "Location services are disabled.";
        notifyListeners();
        return;
      }
    }

    _locationMessage = "Checking permissions...";
    notifyListeners();

    permissionGranted = await _location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        _locationMessage = "Location permission denied.";
        notifyListeners();
        return;
      }
    }

    _locationMessage = "Fetching location...";
    notifyListeners();

    try {
      _location.enableBackgroundMode(enable: true);
      _locationSubscription = _location.onLocationChanged.listen((LocationData currentLocation) {
        _locationData = currentLocation;
        if (_locationData != null) {
          _locationMessage = "Lat: ${_locationData!.latitude}\nLng: ${_locationData!.longitude}";
          
          final newLatLng = LatLng(_locationData!.latitude!, _locationData!.longitude!);
          if (_locationHistory.isEmpty || _locationHistory.last.latitude != newLatLng.latitude || _locationHistory.last.longitude != newLatLng.longitude) {
            _locationHistory.add(newLatLng);
            _saveHistory();
          }
        } else {
          _locationMessage = "Failed to get location.";
        }
        notifyListeners();
      });
    } catch (e) {
      _locationMessage = "Error fetching location: $e";
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    super.dispose();
  }
}