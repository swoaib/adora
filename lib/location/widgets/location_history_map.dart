import 'package:adora/location/location_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

class LocationHistoryMap extends StatefulWidget {
  const LocationHistoryMap({super.key});

  @override
  State<LocationHistoryMap> createState() => _LocationHistoryMapState();
}

class _LocationHistoryMapState extends State<LocationHistoryMap> {
  final MapController _mapController = MapController();

  @override
  Widget build(BuildContext context) {
    final locationHistory = context.watch<LocationProvider>().locationHistory;

    // Automatically adjust the map bounds when the history updates
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (locationHistory.isNotEmpty && mounted) {
        final bounds = LatLngBounds.fromPoints(locationHistory);
        _mapController.fitCamera(
          CameraFit.bounds(
            bounds: bounds,
            padding: const EdgeInsets.all(32.0),
          ),
        );
      }
    });

    return locationHistory.isEmpty
        ? const Center(child: Text("No location history available yet."))
        : FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: locationHistory.last,
              initialZoom: 13.0,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png',
              ),
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: locationHistory,
                    strokeWidth: 4.0,
                    color: Colors.blueAccent,
                  ),
                ],
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: locationHistory.last,
                    width: 40,
                    height: 40,
                    child: const Icon(
                      Icons.location_pin,
                      color: Colors.red,
                      size: 40,
                    ),
                  ),
                  if (locationHistory.length > 1)
                    Marker(
                      point: locationHistory.first,
                      width: 40,
                      height: 40,
                      child: const Icon(
                        Icons.flag,
                        color: Colors.green,
                        size: 40,
                      ),
                    ),
                ],
              ),
              RichAttributionWidget(
                attributions: [
                  TextSourceAttribution('OpenStreetMap contributors'),
                ],
              ),
            ],
          );
  }
}
