import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shake/shake.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart'; // Import the audio player

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
  AudioPlayer _audioPlayer = AudioPlayer(); // Initialize the AudioPlayer
  final response =
      FirebaseFirestore.instance.collection("Response").snapshots();

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
              _capturedImageFile =
                  File(image.path); // Update the UI with the captured image
            });

            // Store the captured image in Firebase Storage and Firestore
            String imageUrl = await _storeImageAndGetUrl(_capturedImageFile!);

            // Store the image URL in Firestore
            await _saveImageUrlToFirestore(imageUrl);

            // Fetch and play multiple audio files from Firestore
            await _playAudioFromFirestore();
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

// Store the captured image in Firebase Storage and return the download URL
  Future<String> _storeImageAndGetUrl(File imageFile) async {
    try {
      String filePath =
          'images/${DateTime.now().millisecondsSinceEpoch}.png'; // Unique file path
      await FirebaseStorage.instance.ref(filePath).putFile(imageFile);

      // Get the download URL of the uploaded image
      String downloadUrl =
          await FirebaseStorage.instance.ref(filePath).getDownloadURL();
      print('Image stored in Firebase Storage at: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      print('Error storing image in Firebase Storage: $e');
      throw e; // Rethrow the exception to handle it in the calling function
    }
  }

// Save the image URL to Firestore
  Future<void> _saveImageUrlToFirestore(String imageUrl) async {
    try {
      FirebaseAuth auth =
          FirebaseAuth.instance; // Get the FirebaseAuth instance
      // Get the current user's ID
      String userId = auth.currentUser!.uid;

      // Create a reference to the Firestore collection
      await FirebaseFirestore.instance
          .collection("Users") // Top-level collection
          .doc(userId) // Document for the current user
          .collection("Images") // Subcollection for images
          .add({
        'url': imageUrl, // Save the image URL
        'timestamp': FieldValue.serverTimestamp(), // Save the timestamp
      });

      print('Image URL saved to Firestore: $imageUrl');
    } catch (e) {
      print('Error saving image URL to Firestore: $e');
    }
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

  // Fetch audio URLs from Firestore and play them sequentially
  Future<void> _playAudioFromFirestore() async {
    // Define a list of maps with keys as 'name + emotion' and corresponding audio file URLs
    List<Map<String, String>> audioFiles = [
      //Nasel Audios
      {
        'Naselsad':
            'https://firebasestorage.googleapis.com/v0/b/capture-image-e5a7f.appspot.com/o/Audios%2Fnasel%20Audios%2Fnasel%20sad.mp3?alt=media&token=f8cb6baa-732c-457c-8f81-c5d7e1bf6fa1'
      },
      {
        'Naselhappy':
            'https://firebasestorage.googleapis.com/v0/b/capture-image-e5a7f.appspot.com/o/Audios%2Fnasel%20Audios%2Fnasel%20happy.mp3?alt=media&token=a66fa405-05d5-4bc2-989c-76011699427d'
      },
      {
        'Naselangry':
            'https://firebasestorage.googleapis.com/v0/b/capture-image-e5a7f.appspot.com/o/Audios%2Fnasel%20Audios%2Fnasel%20angry.mp3?alt=media&token=c34b53db-28dd-4777-aa94-7e02ae36b29f'
      },
      {
        'Naseldisgust':
            'https://firebasestorage.googleapis.com/v0/b/capture-image-e5a7f.appspot.com/o/Audios%2Fnasel%20Audios%2Fnasel%20disgust.mp3?alt=media&token=5e51a8bd-4a79-49a8-94fa-db25b0aefab3'
      },
      {
        'Naselfear':
            'https://firebasestorage.googleapis.com/v0/b/capture-image-e5a7f.appspot.com/o/Audios%2Fnasel%20Audios%2Fnasel%20fear.mp3?alt=media&token=b5f8d3ed-b259-460e-b34b-bbd7e0f83f3b'
      },
      {
        'Naselsurprise':
            'https://firebasestorage.googleapis.com/v0/b/capture-image-e5a7f.appspot.com/o/Audios%2Fnasel%20Audios%2Fnasel%20surprise.mp3?alt=media&token=b3a97c59-432d-46dd-9013-f6f5636d742b'
      },
      {
        'Naselneutral':
            'https://firebasestorage.googleapis.com/v0/b/capture-image-e5a7f.appspot.com/o/Audios%2Fnasel%20Audios%2Fnasel%20neutral.mp3?alt=media&token=04578c3b-d3a5-4144-b010-2af9565fbe0b'
      },
//Mahesh Audios

      {
        'Maheeshsad':
            'https://firebasestorage.googleapis.com/v0/b/capture-image-e5a7f.appspot.com/o/Audios%2FMaheesh%20Audios%2Fmaheesh%20sad.mp3?alt=media&token=3be943e5-32b0-4796-9464-2bea2664154b'
      },
      {
        'Maheeshhappy':
            'https://firebasestorage.googleapis.com/v0/b/capture-image-e5a7f.appspot.com/o/Audios%2FMaheesh%20Audios%2Fmaheesh%20happy.mp3?alt=media&token=29dfc53f-55b2-441a-b6c3-b12d34b9c488'
      },
      {
        'Maheeshangry':
            'https://firebasestorage.googleapis.com/v0/b/capture-image-e5a7f.appspot.com/o/Audios%2FMaheesh%20Audios%2Fmaheesh%20angry.mp3?alt=media&token=97bc5311-369d-440d-9e81-fe874ef421e2'
      },
      {
        'Maheeshdisgust':
            'https://firebasestorage.googleapis.com/v0/b/capture-image-e5a7f.appspot.com/o/Audios%2FMaheesh%20Audios%2Fmaheesh%20disgust.mp3?alt=media&token=79816dba-ef38-4cb9-aaf5-641cb8b0a431'
      },
      {
        'Maheeshfear':
            'https://firebasestorage.googleapis.com/v0/b/capture-image-e5a7f.appspot.com/o/Audios%2FMaheesh%20Audios%2Fmaheesh%20fear.mp3?alt=media&token=5f5f4902-5948-4fee-a45a-bbb63fc6e1b9'
      },
      {
        'Maheeshsurprise':
            'https://firebasestorage.googleapis.com/v0/b/capture-image-e5a7f.appspot.com/o/Audios%2FMaheesh%20Audios%2Fmaheesh%20surprise.mp3?alt=media&token=fb1da13a-fa2f-4dad-9383-02242ffc94d8'
      },
      {
        'Maheeshneutral':
            'https://firebasestorage.googleapis.com/v0/b/capture-image-e5a7f.appspot.com/o/Audios%2FMaheesh%20Audios%2FMaheesh%20neutral.mp3?alt=media&token=5732562e-0aff-4bda-8c64-1a00171d1b5a'
      },

      //Rojin Audios

      {
        'Rojinsad':
            'https://firebasestorage.googleapis.com/v0/b/capture-image-e5a7f.appspot.com/o/Audios%2FRojin%20Audios%2Frojin%20sad.mp3?alt=media&token=ea5adb65-6c05-42fd-987d-dd6a65afabaa'
      },
      {
        'Rojinhappy':
            'https://firebasestorage.googleapis.com/v0/b/capture-image-e5a7f.appspot.com/o/Audios%2FRojin%20Audios%2Frojin%20happy.mp3?alt=media&token=6a8eee86-59a1-49d9-ba53-b5321c9e801a'
      },
      {
        'Rojinangry':
            'https://firebasestorage.googleapis.com/v0/b/capture-image-e5a7f.appspot.com/o/Audios%2FRojin%20Audios%2FRojin%20angry.mp3?alt=media&token=7ac5251a-06ae-4524-adfa-2d4a2292b441'
      },
      {
        'Rojindisgust':
            'https://firebasestorage.googleapis.com/v0/b/capture-image-e5a7f.appspot.com/o/Audios%2FRojin%20Audios%2Frojin%20disgust.mp3?alt=media&token=94769a4a-2c7e-4644-9f3c-dc3747a8152c'
      },
      {
        'Rojinfear':
            'https://firebasestorage.googleapis.com/v0/b/capture-image-e5a7f.appspot.com/o/Audios%2FRojin%20Audios%2Frojin%20fear.mp3?alt=media&token=ecf1db6d-1324-4ca8-9593-ba95b54fb4b9'
      },
      {
        'Rojinsurprise':
            'https://firebasestorage.googleapis.com/v0/b/capture-image-e5a7f.appspot.com/o/Audios%2FRojin%20Audios%2Frojin%20surprise.mp3?alt=media&token=3d48c9de-473d-44ba-b8d6-2f3ece5b5125'
      },
      {
        'Rojinneutral':
            'https://firebasestorage.googleapis.com/v0/b/capture-image-e5a7f.appspot.com/o/Audios%2FRojin%20Audios%2Frojin%20neutral.mp3?alt=media&token=3dda5f15-1d64-4e37-b455-c5230271450f'
      },

      // Unknown Person Audio

      {
        'unknown':
            'https://firebasestorage.googleapis.com/v0/b/capture-image-e5a7f.appspot.com/o/Audios%2FUnknown%20Person%2Funknowperson.mp3?alt=media&token=b82f9195-0e3c-4ba3-b2fd-9ddf25a31bee'
      }, // URL for unknown audio
    ];

    try {
      // Fetch audio documents from Firestore's 'Response' collection
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('Response').get();

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
            await _audioPlayer.play(
                UrlSource(audioFileUrl)); // Use UrlSource for network audio
            await _audioPlayer.onPlayerComplete
                .first; // Wait for the audio to complete before playing the next
          } else {
            // If no matching audio file was found, play the unknown audio
            print(
                'No matching audio file found for key: $key. Playing unknown audio.');
            String? unknownAudioUrl =
                _findAudioFileByKey(audioFiles, 'unknown');
            if (unknownAudioUrl != null) {
              await _audioPlayer.play(UrlSource(
                  unknownAudioUrl)); // Use UrlSource for network audio
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
  String? _findAudioFileByKey(
      List<Map<String, String>> audioFiles, String key) {
    for (var audioMap in audioFiles) {
      // Check if the key exists in the map
      if (audioMap.containsKey(key)) {
        return audioMap[
            key]; // Return the corresponding audio file URL if the key matches
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
                    final SharedPreferences prefs =
                        await SharedPreferences.getInstance();
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
