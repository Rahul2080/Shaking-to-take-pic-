import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shake/shake.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart'; // Import the audio player

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
    _initializeCamera(); // Ensure the camera is initialized
    _startShakeDetection(); // Start shake detection
  }

  // Start the shake detection and capture image on shake
  void _startShakeDetection() {
    _shakeDetector = ShakeDetector.autoStart(
      onPhoneShake: () async {
        if (!_isCameraInitialized) {
          await _initializeCamera(); // Initialize camera if not already done
        }
        print('Phone shaken, attempting to take a picture...');
        await Future.delayed(Duration(seconds: 1)); // Delay for better UX

        try {
          // Take the picture and save it to a file
          final image = await _cameraController!.takePicture();
          setState(() {
            _capturedImageFile = File(image.path); // Update the UI with the captured image
          });
          print('Picture taken: ${image.path}');
          // Fetch and play multiple audio files from Firestore
          await _playAudioFromFirestore(); // Ensure this is awaited
        } catch (e) {
          print('Error while capturing photo: $e');
        }
      },
    );
  }

  // Initialize the camera
  Future<void> _initializeCamera() async {
    if (_cameraController != null) return; // Camera already initialized
    try {
      _cameraController = CameraController(cameras[0], ResolutionPreset.high);
      await _cameraController!.initialize();
      setState(() {
        _isCameraInitialized = true;
      });
      print('Camera initialized successfully');
    } catch (e) {
      print('Error initializing camera: $e');
    }
  }

  // Dispose the camera controller
  void _disposeCamera() {
    _cameraController?.dispose();
    _cameraController = null;
    _isCameraInitialized = false;
  }

  // Fetch audio URLs from Firestore and play them sequentially
  Future<void> _playAudioFromFirestore() async {
    List<Map<String, String>> audioFiles = [
      {'Naselsad': 'https://firebasestorage.googleapis.com/v0/b/capture-image-e5a7f.appspot.com/o/Audios%2Fnasel%20Audios%2Fnasel%20sad.mp3?alt=media&token=f8cb6baa-732c-457c-8f81-c5d7e1bf6fa1'},
      {'Naselhappy': 'https://firebasestorage.googleapis.com/v0/b/capture-image-e5a7f.appspot.com/o/Audios%2Fnasel%20Audios%2Fnasel%20happy.mp3?alt=media&token=a66fa405-05d5-4bc2-989c-76011699427d'},
      // Add other audio files here...
    ];

    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('Response').get();

      if (snapshot.docs.isNotEmpty) {
        for (var doc in snapshot.docs) {
          String name = doc['name'];
          String emotion = doc['emotion'];

          print('Fetched from Firestore - Name: $name, Emotion: $emotion');
          String key = '$name$emotion';
          String? audioFileUrl = _findAudioFileByKey(audioFiles, key);

          if (audioFileUrl != null) {
            print('Playing audio: $audioFileUrl for key: $key');
            await _audioPlayer.play(UrlSource(audioFileUrl)); // Use UrlSource for network audio
            await _audioPlayer.onPlayerComplete.first; // Wait for the audio to complete before playing the next
          } else {
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
        title: const Text('Shake to Take Photo'),
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
          'Shake your phone to take a photo',
          style: TextStyle(fontSize: 18.sp),
        ),
      ),
    );
  }
}
