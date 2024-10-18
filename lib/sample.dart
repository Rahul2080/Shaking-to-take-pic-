import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shake/shake.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart'; // Import the audio player
import 'package:url_launcher/url_launcher.dart'; // Import url_launcher

import 'Authentication/Login.dart';
import 'main.dart'; // Assumes cameras list is defined here

class Sample extends StatefulWidget {
  const Sample({super.key});

  @override
  _SampleState createState() => _SampleState();
}

class _SampleState extends State<Sample> {
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  ShakeDetector? _shakeDetector;
  File? _capturedImageFile;
  AudioPlayer _audioPlayer = AudioPlayer(); // Initialize the AudioPlayer
  final response = FirebaseFirestore.instance.collection("Response").snapshots();

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

            // Fetch and play multiple audio files from Firestore
            _playAudioFromFirestore();

            // Open an app or launch a URL
            _openAppOrURL(); // Call the method to open the app or URL
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

  // Method to open an app or a URL
  Future<void> _openAppOrURL() async {
    const url = 'tel://1234567890'; // Example for opening a phone dialer app with a phone number
    // Or open another app using its deep link or URL
    // const url = 'myapp://some/path'; // Example for custom app URL scheme

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  // Fetch audio URLs from Firestore and play them sequentially
  Future<void> _playAudioFromFirestore() async {
    // Define a list of maps with keys as 'name + emotion' and corresponding audio file URLs
    List<Map<String, String>> audioFiles = [
      // Nasel Audios
      {'Naselsad': 'https://firebasestorage.googleapis.com/...'},
      {'Naselhappy': 'https://firebasestorage.googleapis.com/...'},
      // Add other audio URLs as needed...
    ];

    try {
      // Fetch audio documents from Firestore's 'Response' collection
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('Response').get();

      if (snapshot.docs.isNotEmpty) {
        // Iterate through the documents in Firestore
        for (var doc in snapshot.docs) {
          // Fetch 'name' and 'emotion' fields from Firestore
          String name = doc['name'];
          String emotion = doc['emotion'];

          // Log the fetched data
          print('Fetched from Firestore - Name: $name, Emotion: $emotion');

          // Create a key combining 'name' and 'emotion'
          String key = '$name$emotion';

          // Find the matching audio file based on the key
          String? audioFileUrl = _findAudioFileByKey(audioFiles, key);

          if (audioFileUrl != null) {
            // Log the selected audio file
            print('Playing audio: $audioFileUrl for key: $key');
            // Play the matching audio file from the network
            await _audioPlayer.play(UrlSource(audioFileUrl)); // Use UrlSource for network audio
            await _audioPlayer.onPlayerComplete.first; // Wait for the audio to complete before playing the next
          } else {
            // If no matching audio file was found, play the unknown audio
            print('No matching audio file found for key: $key. Playing unknown audio.');
            String? unknownAudioUrl = _findAudioFileByKey(audioFiles, 'unknown');
            if (unknownAudioUrl != null) {
              await _audioPlayer.play(UrlSource(unknownAudioUrl)); // Use UrlSource for network audio
              await _audioPlayer.onPlayerComplete.first;
            }
          }
        }
      } else {
        print('No documents found in Firestore');
      }
    } catch (e) {
      print('Error playing audio from Firestore: $e');
    }
  }

  // Helper function to find the audio file from the list of maps based on the constructed key
  String? _findAudioFileByKey(List<Map<String, String>> audioFiles, String key) {
    for (var audioMap in audioFiles) {
      // Check if the key exists in the map
      if (audioMap.containsKey(key)) {
        return audioMap[key]; // Return the corresponding audio file URL if the key matches
      }
    }
    return null; // Return null if no match is found
  }

  @override
  void dispose() {
    _shakeDetector?.stopListening();
    _disposeCamera();
    _audioPlayer.dispose(); // Dispose the audio player
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
        title: const Text('Shake to Take Photo and Launch App'),
      ),
      body: _capturedImageFile != null
          ? Image.file(
        _capturedImageFile!,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover, // Make the image fill the screen
      )
          : Center(
        child: Text(
          'Shake your phone to take a photo and launch app',
          style: TextStyle(fontSize: 18.sp),
        ),
      ),
    );
  }
}
