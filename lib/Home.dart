import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shake/shake.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Authentication/Login.dart';
import 'main.dart'; // Assumes cameras list is defined here

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  ShakeDetector? _shakeDetector;
  File? _capturedImageFile;
  String? _capturedImageUrl;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _startShakeDetection();
  }

  // Start the shake detection and capture image on shake
  void _startShakeDetection() {
    _shakeDetector = ShakeDetector.autoStart(
      onPhoneShake: () async {
        if (_isCameraInitialized) {
          // Add a 2-second delay before capturing the photo
          await Future.delayed(Duration(seconds: 1));

          try {
            // Take the picture and save it to a file
            final image = await _cameraController!.takePicture();
            setState(() {
              _capturedImageFile = File(image.path); // Update the UI with the captured image
            });

            // Upload the captured image to Firebase
            await _uploadToFirebase(_capturedImageFile!);
          } catch (e) {
            if (kDebugMode) {
              print('Error while capturing photo: $e');
            }
          }
        } else {
          if (kDebugMode) {
            print('Camera not initialized');
          }
        }
      },
    );
  }

  // Initialize the camera
  Future<void> _initializeCamera() async {
    if (_cameraController != null) return; // Camera already initialized
    _cameraController = CameraController(cameras[0], ResolutionPreset.high);
    try {
      await _cameraController!.initialize();
      setState(() {
        _isCameraInitialized = true;
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing camera: $e');
      }
    }
  }

  // Dispose the camera controller
  void _disposeCamera() {
    _cameraController?.dispose();
    _cameraController = null;
    _isCameraInitialized = false;
  }

  // Upload the captured image to Firebase Storage
  Future<void> _uploadToFirebase(File imageFile) async {
    try {
      FirebaseAuth auth = FirebaseAuth.instance;
      final User? user = auth.currentUser;

      if (user != null) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String? userName = prefs.getString('userName');
        final fileName = basename(imageFile.path);
        final destination = 'images/$userName/$fileName';  // Create a user-specific folder in Firebase Storage
        final ref = FirebaseStorage.instance.ref().child(destination);
        final uploadTask = ref.putFile(imageFile);
        final snapshot = await uploadTask.whenComplete(() {});
        final downloadUrl = await snapshot.ref.getDownloadURL();

        // Store the image URL and user ID in the user's subcollection 'images'
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(user.uid)
            .collection('images')  // Subcollection named 'images' for each user
            .add({
          'imageUrl': downloadUrl,
          'userId': user.uid,
          'uploadedAt': FieldValue.serverTimestamp(),  // Optional: store upload timestamp
        });

        setState(() {
          _capturedImageUrl = downloadUrl;
        });

        if (kDebugMode) {
          print('Image uploaded successfully. URL: $downloadUrl');
        }
      } else {
        throw Exception('User not authenticated');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error while uploading image: $e');
      }
    }
  }

  @override
  void dispose() {
    _shakeDetector?.stopListening();
    _disposeCamera();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: PopupMenuButton<int>(
          icon: Icon(Icons.more_vert, color: Colors.black),
          onSelected: (value) {
            if (value == 1) {
              // Handle logout logic here
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 1,
              child: GestureDetector(
                  onTap: () async {
                    final SharedPreferences prefs = await SharedPreferences.getInstance();
                    prefs.clear();
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => Login()),
                          (route) => false,
                    );
                  },
                  child: Center(child: Text('Logout'))),
            ),
          ],
        ),
        title: const Text('Shake to Take Photo'),
      ),
      body: _capturedImageFile != null
          ? Column(
        children: [
          // Show the image at the top
          Padding(
            padding: EdgeInsets.only(top: 20.h), // Add some padding from the top
            child: Image.file(
              _capturedImageFile!,
              width: double.infinity,
              height: 300.h, // Adjust the image height to show in top center
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(height: 20.h),
          // Display the image URL after upload
          if (_capturedImageUrl != null)
            Padding(
              padding: EdgeInsets.all(10.h),
              child: Text(
                'Image Uploaded! URL: $_capturedImageUrl',
                style: TextStyle(fontSize: 16.sp),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      )
          : Center(
        child: Text(
          'Shake your phone to take a photo',
          style: TextStyle(fontSize: 18.sp),
        ),
      ),
    );
  }
}
