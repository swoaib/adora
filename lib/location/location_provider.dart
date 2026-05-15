import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:location/location.dart';
import 'package:latlong2/latlong.dart';
import 'package:adora/location/location_service.dart';

class LocationProvider with ChangeNotifier {
  final LocationService _locationService = LocationService();

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
    _locationHistory = await _locationService.loadHistory();
    notifyListeners();
  }

  Future<void> fetchLocation() async {
    _locationMessage = "Checking location services...";
    notifyListeners();

    final errorMsg = await _locationService.checkAndRequestPermissions();
    if (errorMsg != null) {
      _locationMessage = errorMsg;
      notifyListeners();
      return;
    }

    _locationMessage = "Fetching location...";
    notifyListeners();

    try {
      _locationSubscription = _locationService.getLocationStream().listen((LocationData currentLocation) {
        _locationData = currentLocation;
        if (_locationData != null) {
          _locationMessage = "Lat: ${_locationData!.latitude}\nLng: ${_locationData!.longitude}";
          
          final newLatLng = LatLng(_locationData!.latitude!, _locationData!.longitude!);
          if (_locationHistory.isEmpty || _locationHistory.last.latitude != newLatLng.latitude || _locationHistory.last.longitude != newLatLng.longitude) {
            _locationHistory.add(newLatLng);
            _locationService.saveHistory(_locationHistory);
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