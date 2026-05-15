import 'package:adora/location/location_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

class LocationMap extends StatefulWidget {
  const LocationMap({super.key});

  @override
  State<LocationMap> createState() => _LocationMapState();
}

class _LocationMapState extends State<LocationMap> {
  final MapController _mapController = MapController();

  @override
  Widget build(BuildContext context) {
    final locationData = context.watch<LocationProvider>().locationData;

    // Automatically move the map camera when the location updates
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (locationData != null && mounted) {
        _mapController.move(
          LatLng(locationData.latitude ?? 0, locationData.longitude ?? 0),
          _mapController.camera.zoom, // Keep current zoom level
        );
      }
    });

    return locationData == null
        ? Center(child: CircularProgressIndicator())
        : FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: LatLng(
                locationData.latitude ?? 0,
                locationData.longitude ?? 0,
              ), 
              initialZoom: 15.0, // Zoomed in a bit closer for user tracking
            ),
            children: [
              TileLayer(
                // Bring your own tiles
                urlTemplate:
                    'https://basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png', // CartoDB is permissive and free for dev
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: LatLng(
                      locationData.latitude ?? 0,
                      locationData.longitude ?? 0,
                    ),
                    width: 40,
                    height: 40,
                    child: const Icon(
                      Icons.location_pin,
                      color: Colors.red,
                      size: 40,
                    ),
                  ),
                ],
              ),
              RichAttributionWidget(
                // Include a stylish prebuilt attribution widget that meets all requirments
                attributions: [
                  TextSourceAttribution('OpenStreetMap contributors'),
                  // Also add images...
                ],
              ),
            ],
          );
  }
}
