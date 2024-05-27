import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_detection_demo/controller/steps-controller.dart';
import 'package:image_detection_demo/face-detector-painter.dart';
import 'package:image_detection_demo/widgets/detector-views.dart';

class FaceDetectorView extends ConsumerStatefulWidget {
  @override
  ConsumerState<FaceDetectorView> createState() => _FaceDetectorViewState();
}

class _FaceDetectorViewState extends ConsumerState<FaceDetectorView> {
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
        enableContours: true,
        enableLandmarks: true,
        enableClassification: true),
  );
  bool _canProcess = true;
  bool _isBusy = false;
  CustomPaint? _customPaint;
  String? _text;
  var _cameraLensDirection = CameraLensDirection.front;

  @override
  void dispose() {
    _canProcess = false;
    _faceDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DetectorView(
      title: 'Face Detector',
      customPaint: _customPaint,
      text: _text,
      onImage: _processImage,
      initialCameraLensDirection: _cameraLensDirection,
      onCameraLensDirectionChanged: (value) => _cameraLensDirection = value,
      onImageCapture: _getImage,
    );
  }

  XFile? f;
  close() {
    if (f != null) {
      Navigator.pop(context, File(f!.path));
    }
  }

  _getImage(
    XFile? inputImage,
  ) async {
    f = inputImage;
  }

  Future<void> _processImage(
    InputImage inputImage,
  ) async {
    final dataController = ref.watch(controllerProvider);
    if (!_canProcess) return;
    if (_isBusy) return;
    _isBusy = true;
    setState(() {
      _text = '';
    });
    final faces = await _faceDetector.processImage(inputImage);
    if (inputImage.metadata?.size != null &&
        inputImage.metadata?.rotation != null) {
      final painter = FaceDetectorPainter(
        faces,
        inputImage.metadata!.size,
        inputImage.metadata!.rotation,
        _cameraLensDirection,
      );
      _customPaint = CustomPaint(painter: painter);
      for (var face in faces) {
        // print("leftEyeOpenProbability:::${face.leftEyeOpenProbability}");
        // print("smilling probability:::${face.smilingProbability}");

        if (dataController.steps == GestureSteps.start) {
          print('detecting smile');
          if ((face.smilingProbability ?? 0.0) >= 0.6) {
            print(':::You are smilling else ');
            dataController.nextStep();
            await Future.delayed(Duration(seconds: 1));
          } else {
            print(':::You are not smilling else ');
          }
        } else if (dataController.steps == GestureSteps.hasStepOne) {
          ///check for blinking
          print('detecting blink');
          if ((face.leftEyeOpenProbability ?? 0.0) <= 0.6 &&
              (face.rightEyeOpenProbability ?? 0.0) <= 0.6) {
            print('blinked:::');
            dataController.nextStep();
            // XFile file = await _c.takePicture();
            // return file;
            // dataController.capture(() async => await captureImage());
          } else {
            print('not blinked:::');
          }
        }
      }
    } else {
      String text = 'Faces found: ${faces.length}\n\n';
      for (final face in faces) {
        text += 'face: ${face.boundingBox}\n\n';
      }
      _text = text;
      // TODO: set _customPaint to draw boundingRect on top of image
      _customPaint = null;
    }
    _isBusy = false;
    if (mounted) {
      setState(() {});
    }
  }

  Future<XFile?> takePicture() async {
    final c = ref.watch(controllerProvider);
    final CameraController? cameraController = c.controller;
    if (cameraController == null || !cameraController.value.isInitialized) {
      print('Error: select a camera first.');
      return null;
    }

    if (cameraController.value.isTakingPicture) {
      // A capture is already pending, do nothing.
      return null;
    }

    try {
      XFile file = await cameraController.takePicture();
      return file;
    } on CameraException catch (e) {
      print(e.description);
      return null;
    }
  }

  captureImage() async {
    takePicture().then((XFile? file) {
      /// Return image callback
      if (file != null) {
        Navigator.pop(context, File(file.path));
      }

      /// Resume image stream after 2 seconds of capture
      // Future.delayed(const Duration(seconds: 2)).whenComplete(() {});
    });
  }
}
