import 'package:flutter/material.dart';
import 'package:image_detection_demo/manual/home.dart';
import 'package:image_detection_demo/widgets/new-camera-view.dart';

class KycImageCapture {
  //* MARK: - Converting Package to Singleton
  //? =========================================================
  KycImageCapture._privateConstructor();

  static final KycImageCapture instance = KycImageCapture._privateConstructor();

  //* MARK: - Private Variables
  //? =========================================================

  //* MARK: - Public Variables
  //? =========================================================

  //* MARK: - Public Methods
  //? =========================================================

  /// A single line functoin to detect weather the face is live or not.
  /// Parameters: -
  /// * context: - Positional Parameter that will accept a `BuildContext` using which it will redirect the a new screen.
  Future<String?> captureImage(BuildContext context, {auto = true}) async {
    // if(!context.mounted)return;
    final String? capturedFacePath = auto
        ? await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ICameraView(),
            ),
          )
        : await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ManualCamera(),
            ),
          );
    return capturedFacePath;
  }
}
