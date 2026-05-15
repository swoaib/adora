import 'package:adora/location/location_provider.dart';
import 'package:adora/location/widgets/location_history_map.dart';
import 'package:adora/location/widgets/location_map.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LocationPage extends StatefulWidget {
  const LocationPage({super.key});

  @override
  State<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LocationProvider>().fetchLocation();
    });
  }

  @override
  Widget build(BuildContext context) {
    final locationMessage = context.watch<LocationProvider>().locationMessage;
    final locationHistory = context.watch<LocationProvider>().locationHistory;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("User location"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsetsGeometry.all(16),
          child: Column(
            children: [
              const SizedBox(height: 32),
              const Text(
                'Your Current Location:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Text(
                  locationMessage,
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(color: Colors.blueAccent),
                ),
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: const SizedBox(
                  height: 200,
                  width: 400,
                  child: LocationMap(),
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Your Location History:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: const SizedBox(
                  height: 300,
                  width: 400,
                  child: LocationHistoryMap(),
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Stored Coordinates:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              if (locationHistory.isEmpty)
                const Text("No locations saved yet."),
              if (locationHistory.isNotEmpty)
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: locationHistory.length,
                  itemBuilder: (context, index) {
                    final loc = locationHistory[index];
                    return ListTile(
                      leading: const Icon(
                        Icons.location_on,
                        color: Colors.blueAccent,
                      ),
                      title: Text("Saved Point ${index + 1}"),
                      subtitle: Text(
                        "Lat: ${loc.latitude.toStringAsFixed(4)}, Lng: ${loc.longitude.toStringAsFixed(4)}",
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: _refreshLocation,
      //   tooltip: 'Refresh Location',
      //   child: const Icon(Icons.my_location),
      // ),
    );
  }
}
