import 'package:flutter/foundation.dart';
import 'package:location/location.dart';

class LocationProvider with ChangeNotifier {
  final Location _location = Location();

  LocationData? _locationData;
  String _locationMessage = "";

  LocationData? get locationData => _locationData;
  String get locationMessage => _locationMessage;

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
      _locationData = await _location.getLocation();
      if (_locationData != null) {
        _locationMessage = "Lat: ${_locationData!.latitude}\nLng: ${_locationData!.longitude}";
      } else {
        _locationMessage = "Failed to get location.";
      }
    } catch (e) {
      _locationMessage = "Error fetching location: $e";
    }
    notifyListeners();
  }
}