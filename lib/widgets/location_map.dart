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
            children: [],
            // children: [
            //   TileLayer( // Bring your own tiles
            //     urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', // For demonstration only
            //     userAgentPackageName: /*'com.example.app'*/, // Add your app identifier
            //     // And many more recommended properties!
            //   ),
            //   RichAttributionWidget( // Include a stylish prebuilt attribution widget that meets all requirments
            //     attributions: [
            //       TextSourceAttribution(
            //         'OpenStreetMap contributors',
            //         onTap: () => launchUrl(Uri.parse('https://openstreetmap.org/copyright')), // (external)
            //       ),
            //       // Also add images...
            //     ],
            //   ),
            // ],
          );
  }
}
