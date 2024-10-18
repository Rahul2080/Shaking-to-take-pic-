import 'package:flutter/material.dart';
import 'package:shake/shake.dart';

class ShakeDetectionPage extends StatefulWidget {
  @override
  _ShakeDetectionPageState createState() => _ShakeDetectionPageState();
}

class _ShakeDetectionPageState extends State<ShakeDetectionPage> {
  ShakeDetector? detector;

  @override
  void initState() {
    super.initState();
    detector = ShakeDetector.autoStart(
      onPhoneShake: () {
        // When phone shakes, print something or trigger an action
        print("Phone shaken!");
        // You can add logic here to perform an action (e.g., show a dialog, open a screen)
      },
    );
  }

  @override
  void dispose() {
    detector?.stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Shake your phone!'),
      ),
    );
  }
}
