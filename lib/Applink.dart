import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math'; // Import this for the sqrt function

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _shakeCount = 0;

  @override
  void initState() {
    super.initState();
    _startShakeDetection();
  }

  void _startShakeDetection() {
    accelerometerEvents.listen((AccelerometerEvent event) {
      double x = event.x;
      double y = event.y;
      double z = event.z;

      // Calculate the magnitude of the acceleration vector
      double magnitude = sqrt(x * x + y * y + z * z); // Use sqrt here

      if (magnitude > 12) { // Adjust threshold as necessary
        _shakeCount++;
        if (_shakeCount >= 3) { // Number of shakes needed
          _openLink();
          _shakeCount = 0; // Reset count
        }
      }
    });
  }

  Future<void> _openLink() async {
    const String url = 'https://com.example.shakingpic.com'; // Your app link here
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Shake to Open Link')),
      body: Center(child: Text('Shake the device!')),
    );
  }
}
