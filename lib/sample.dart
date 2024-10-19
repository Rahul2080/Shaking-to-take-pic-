// import 'dart:async';
// import 'dart:math';
//
// import 'package:background_fetch/background_fetch.dart';
// import 'package:flutter/material.dart';
// import 'package:sensors_plus/sensors_plus.dart';
//
// class ShakeAndFetchScreen extends StatefulWidget {
//   @override
//   _ShakeAndFetchScreenState createState() => _ShakeAndFetchScreenState();
// }
//
// class _ShakeAndFetchScreenState extends State<ShakeAndFetchScreen> {
//   static const double shakeThreshold = 2.7; // Sensitivity threshold for shake detection
//   AccelerometerEvent? _lastEvent;
//   Timer? _shakeTimer;
//
//   @override
//   void initState() {
//     super.initState();
//
//     // Initialize Background Fetch
//     initBackgroundFetch();
//
//     // Initialize shake detection using accelerometer
//     accelerometerEvents.listen((AccelerometerEvent event) {
//       if (_lastEvent != null) {
//         double deltaX = event.x - _lastEvent!.x;
//         double deltaY = event.y - _lastEvent!.y;
//         double deltaZ = event.z - _lastEvent!.z;
//         double acceleration = sqrt(deltaX * deltaX + deltaY * deltaY + deltaZ * deltaZ);
//
//         if (acceleration > shakeThreshold) {
//           _onShakeDetected();
//         }
//       }
//       _lastEvent = event;
//     });
//   }
//
//   // Function to handle background fetch configuration
//   void initBackgroundFetch() async {
//     BackgroundFetch.configure(BackgroundFetchConfig(
//         minimumFetchInterval: 15,  // <-- minutes
//         stopOnTerminate: false,
//         startOnBoot: true
//     ), (String taskId) async {  // <-- Event callback
//       // This callback is typically fired every 15 minutes while in the background.
//       print('[BackgroundFetch] Event received.');
//       // IMPORTANT:  You must signal completion of your fetch task or the OS could
//       // punish your app for spending much time in the background.
//       BackgroundFetch.finish(taskId);
//     }, (String taskId) async {  // <-- Task timeout callback
//       // This task has exceeded its allowed running-time.  You must stop what you're doing and immediately .finish(taskId)
//       BackgroundFetch.finish(taskId);
//     }).then((int status) {
//       print('[BackgroundFetch] Configure success: $status');
//     }).catchError((e) {
//       print('[BackgroundFetch] Configure error: $e');
//     });
//   }
//
//   // Function to handle shake detection
//   void _onShakeDetected() {
//     if (_shakeTimer != null && _shakeTimer!.isActive) {
//       return; // Ignore additional shakes within the time frame
//     }
//
//     // Take action on shake detected
//     print('Shake detected!');
//
//     // For demonstration, you can trigger a method or change the state
//     // Here, we can log or perform other actions you need
//     _performShakeAction();
//
//     // Set a cooldown timer to avoid triggering multiple shake detections in quick succession
//     _shakeTimer = Timer(Duration(seconds: 2), () {});
//   }
//
//   // Example function to perform an action on shake
//   void _performShakeAction() {
//     // Your logic here
//     // For example, you can change the state or update the UI if needed
//     // Call setState if you need to update the UI
//     print('Performing action due to shake event.');
//   }
//
//   @override
//   void dispose() {
//     _shakeTimer?.cancel();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//     );
//   }
// }
