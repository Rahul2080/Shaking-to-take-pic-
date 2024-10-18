import 'package:sensors_plus/sensors_plus.dart';
class ShakeDetector {
  final Function onShake;

  ShakeDetector(this.onShake);

  void startListening() {
    // Listen to accelerometer events
    accelerometerEvents.listen((AccelerometerEvent event) {
      if (_isShake(event)) {
        onShake();
      }
    });
  }

  bool _isShake(AccelerometerEvent event) {
    // A simple shake detection algorithm
    const double threshold = 15.0; // Adjust this value as needed
    return (event.x > threshold || event.y > threshold || event.z > threshold);
  }
}
