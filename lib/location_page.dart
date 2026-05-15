import 'package:adora/location_provider.dart';
import 'package:adora/widgets/location_map.dart';
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("User location"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.blueAccent,
                ),
              ),
            ),
            LocationMap()
          ],
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