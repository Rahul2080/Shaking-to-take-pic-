import 'package:camera/camera.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shakingpic/Authentication/Splash.dart';
import 'package:shakingpic/sample.dart';

import 'Get_App_Link.dart';
import 'Home.dart';
import 'firebase_options.dart';

late List<CameraDescription> cameras; // Global variable to store available cameras

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  cameras = await availableCameras(); // Fetch available cameras
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late ShakeDetector _shakeDetector;

  @override
  void initState() {
    super.initState();
    _shakeDetector = ShakeDetector(() {
      // Handle shake event
      _openApp();
    });
    _shakeDetector.startListening();
  }

  void _openApp() {
    // Navigate to your desired screen or perform the desired action
    print("App opened!");
  }

  @override
  void dispose() {
    // Dispose of the shake detector if necessary
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return  ScreenUtilInit(
        designSize: const Size(360, 690),
    minTextAdapt: true,
    splitScreenMode: true,
    builder: (_ , child) {
    return  MaterialApp(debugShowCheckedModeBanner: false,
      home: Splash(),
    );
  });
}
}

