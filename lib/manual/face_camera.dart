import 'dart:async';

import 'package:camera/camera.dart';
import 'package:image_detection_demo/manual/manual-kyc.dart';

export 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class FaceCamera {
  //static const MethodChannel _channel = MethodChannel('face_camera');
  // static List<CameraDescription> _cameras = [];

  /// Initialize device cameras
  static Future<void> initialize() async {
    /// Fetch the available cameras before initializing the app.
    try {
      // _cameras = await availableCameras();
    } on CameraException catch (e) {
      logError(e.code, e.description);
    }
  }

  /// Returns available cameras
  // static List<CameraDescription> get cameras {
  //   return _cameras;
  // }
}
