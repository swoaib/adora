import 'package:adora/location/location_page.dart';
import 'package:adora/location/location_provider.dart';
import 'package:adora/location/location_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: ChangeNotifierProvider(
        create: (context) =>
            LocationProvider(locationService: LocationService()),
        child: const LocationPage(),
      ),
    );
  }
}
