import 'package:adora/location_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

class LocationMap extends StatelessWidget {
  const LocationMap({super.key});

  @override
  Widget build(BuildContext context) {
    final locationData = context.watch<LocationProvider>().locationData;
    return locationData == null
        ? Center(child: CircularProgressIndicator())
        : FlutterMap(
            options: MapOptions(
              initialCenter: LatLng(
                locationData.latitude ?? 0,
                locationData.longitude ?? 0,
              ), // Center the map over London, UK
              initialZoom: 9.2,
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
