import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shake/shake.dart';

import 'main.dart';


class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late CameraController _cameraController;
  bool _isCameraInitialized = false;
  late ShakeDetector _shakeDetector;

  @override
  void initState() {
    super.initState();
    _initializeCamera();    // Initialize camera
    _startShakeDetection(); // Start shake detection
  }

  // Initialize the camera
  void _initializeCamera() async {
    // Initialize the back camera (or use the front camera if you prefer)
    _cameraController = CameraController(cameras[0], ResolutionPreset.high);
    await _cameraController.initialize();
    setState(() {
      _isCameraInitialized = true;
    });
  }

  // Detect shake and take a photo when the phone shakes
  void _startShakeDetection() {
    _shakeDetector = ShakeDetector.autoStart(
      onPhoneShake: () async {
        if (_isCameraInitialized) {
          print("Shaken! Taking a photo...");

          // Automatically take a picture when the shake is detected
          try {
            final image = await _cameraController.takePicture();
            print('Photo captured: ${image.path}');
            // You can display or save the captured image here
          } catch (e) {
            print('Error while capturing photo: $e');
          }
        }
      },
    );
  }

  @override
  void dispose() {
    _cameraController.dispose();
    _shakeDetector.stopListening();  // Ensure shake detection is stopped
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Shake to Take Photo')),
      body: Center(
        child: _isCameraInitialized
            ? CameraPreview(_cameraController) // Show camera preview
            : CircularProgressIndicator(), // Show loading indicator while initializing
      ),
    );
  }
}
