import 'package:camera/camera.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shake/shake.dart';
import 'package:shakingpic/Authentication/SignUp.dart';
import 'package:shakingpic/Authentication/Splash.dart';

import 'Home.dart';
import 'firebase_options.dart';

late List<CameraDescription> cameras; // Global variable to store available cameras

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  cameras = await availableCameras(); // Fetch available cameras
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false,
      home: Splash(),
    );
  }
}


