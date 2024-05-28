import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_detection_demo/controller/steps-controller.dart';
import 'package:image_detection_demo/face-detector-painter.dart';
import 'package:image_detection_demo/widgets/custom-circle.dart';
import 'package:image_detection_demo/widgets/detector-views.dart';
import 'package:image_detection_demo/widgets/instructions.dart';

class ICameraView extends ConsumerStatefulWidget {
  const ICameraView(
      {super.key,
      this.onCameraFeedReady,
      this.onDetectorViewModeChanged,
      this.initialCameraLensDirection = CameraLensDirection.front});

  final VoidCallback? onCameraFeedReady;
  final VoidCallback? onDetectorViewModeChanged;
  final CameraLensDirection initialCameraLensDirection;

  @override
  ConsumerState<ICameraView> createState() => _CameraViewState();
}

class _CameraViewState extends ConsumerState<ICameraView> {
  late DetectorViewMode _mode;
  static List<CameraDescription> _cameras = [];
  CameraController? _controller;
  int _cameraIndex = -1;
  double _currentZoomLevel = 1.0;
  double _minAvailableZoom = 1.0;
  double _maxAvailableZoom = 1.0;
  double _minAvailableExposureOffset = 0.0;
  double _maxAvailableExposureOffset = 0.0;
  double _currentExposureOffset = 0.0;
  bool _changingCameraLens = false;
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
    _stopLiveFeed();
    super.dispose();
  }

  @override
  void initState() {
    _mode = DetectorViewMode.liveFeed;
    _initialize();
    super.initState();
  }

  void _initialize() async {
    if (_cameras.isEmpty) {
      _cameras = await availableCameras();
    }
    // _controller = CameraController(_cameras[0], ResolutionPreset.low);
    for (var i = 0; i < _cameras.length; i++) {
      if (_cameras[i].lensDirection == widget.initialCameraLensDirection) {
        _cameraIndex = i;
        break;
      }
    }
    // _startLiveFeed();
    if (_cameraIndex != -1) {
      _startLiveFeed();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _liveFeedBody());
  }

  Widget _liveFeedBody() {
    if (_cameras.isEmpty)
      return Container(
        color: Colors.red,
      );
    if (_controller == null)
      return Container(
        color: Colors.orange,
      );
    if (_controller?.value.isInitialized == false)
      return Container(
        color: Colors.brown,
      );
    return ColoredBox(
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Center(
            child: _changingCameraLens
                ? const Center(
                    child: Text('Changing camera lens'),
                  )
                : CameraPreview(
                    _controller!,
                    child: _customPaint,
                  ),
          ),
          instructions(),
          circle(),
          _backButton(),
          // _switchLiveCameraToggle(),
          // _detectionViewModeToggle(),
          // _zoomControl(),
          // _exposureControl(),
        ],
      ),
    );
  }

  Widget _backButton() => Positioned(
        top: 30,
        left: 8,
        child: SizedBox(
          height: 50.0,
          width: 50.0,
          child: FloatingActionButton(
            heroTag: Object(),
            onPressed: () => Navigator.of(context).pop(),
            backgroundColor: Colors.black54,
            child: const Icon(
              Icons.arrow_back_ios_outlined,
              size: 20,
              color: Colors.blue,
            ),
          ),
        ),
      );

  Widget circle() => const Positioned(
        right: 0,
        left: 0,
        bottom: 50,
        child: SizedBox(
          height: 150.0,
          width: 150.0,
          child: CustomCircle(),
        ),
      );

  Widget instructions() => const Positioned(
        right: 10,
        left: 10,
        top: 100,
        child: InstructionsWidget(),
      );

  Future _startLiveFeed() async {
    final camera = _cameras[_cameraIndex];
    _controller = CameraController(
      camera,
      // Set to ResolutionPreset.high. Do NOT set it to ResolutionPreset.max because for some phones does NOT work.
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid
          ? ImageFormatGroup.nv21
          : ImageFormatGroup.bgra8888,
    );
    _controller?.initialize().then((_) {
      if (!mounted) {
        return;
      }
      _controller?.getMinZoomLevel().then((value) {
        _currentZoomLevel = value;
        _minAvailableZoom = value;
      });
      _controller?.getMaxZoomLevel().then((value) {
        _maxAvailableZoom = value;
      });
      _currentExposureOffset = 0.0;
      _controller?.getMinExposureOffset().then((value) {
        _minAvailableExposureOffset = value;
      });
      _controller?.getMaxExposureOffset().then((value) {
        _maxAvailableExposureOffset = value;
      });
      _controller?.startImageStream(_processCameraImage).then((value) {
        if (widget.onCameraFeedReady != null) {
          widget.onCameraFeedReady!();
        }
        if (_cameraLensDirection != null) {
          // widget.onCameraLensDirectionChanged!(camera.lensDirection);
        }
      });

      setState(() {});
    });
  }

  Future _stopLiveFeed() async {
    await _controller?.stopImageStream();
    await _controller?.dispose();
    _controller = null;
  }

  void _processCameraImage(CameraImage image) async {
    final inputImage = _inputImageFromCameraImage(image);
    if (inputImage == null) return;

    _processImage(inputImage, context);
  }

  Future<void> _processImage(
      InputImage inputImage, BuildContext context) async {
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
        if (dataController.steps == GestureSteps.start) {
          debugPrint('detecting smile');
          if ((face.smilingProbability ?? 0.0) >= 0.6) {
            debugPrint(':::You are smiling else ');
            dataController.nextStep();
            await Future.delayed(const Duration(seconds: 1));
          } else {
            debugPrint(':::You are not smiling else ');
          }
        } else if (dataController.steps == GestureSteps.hasStepOne) {
          ///check for blinking
          debugPrint('detecting blink');
          if ((face.leftEyeOpenProbability ?? 0.0) <= 0.6 &&
              (face.rightEyeOpenProbability ?? 0.0) <= 0.6) {
            debugPrint('blinked:::');
            dataController.nextStep();
            await Future.delayed(const Duration(milliseconds: 100));
            await takePicture();
            // _stopLiveFeed();
            Navigator.pop(context, dataController.file);
            return;
          } else {
            debugPrint('not blinked:::');
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

  final _orientations = {
    DeviceOrientation.portraitUp: 0,
    DeviceOrientation.landscapeLeft: 90,
    DeviceOrientation.portraitDown: 180,
    DeviceOrientation.landscapeRight: 270,
  };

  InputImage? _inputImageFromCameraImage(CameraImage image) {
    if (_controller == null) return null;

    // get image rotation
    // it is used in android to convert the InputImage from Dart to Java: https://github.com/flutter-ml/google_ml_kit_flutter/blob/master/packages/google_mlkit_commons/android/src/main/java/com/google_mlkit_commons/InputImageConverter.java
    // `rotation` is not used in iOS to convert the InputImage from Dart to Obj-C: https://github.com/flutter-ml/google_ml_kit_flutter/blob/master/packages/google_mlkit_commons/ios/Classes/MLKVisionImage%2BFlutterPlugin.m
    // in both platforms `rotation` and `camera.lensDirection` can be used to compensate `x` and `y` coordinates on a canvas: https://github.com/flutter-ml/google_ml_kit_flutter/blob/master/packages/example/lib/vision_detector_views/painters/coordinates_translator.dart
    final camera = _cameras[_cameraIndex];
    final sensorOrientation = camera.sensorOrientation;
    // print(
    //     'lensDirection: ${camera.lensDirection}, sensorOrientation: $sensorOrientation, ${_controller?.value.deviceOrientation} ${_controller?.value.lockedCaptureOrientation} ${_controller?.value.isCaptureOrientationLocked}');
    InputImageRotation? rotation;
    if (Platform.isIOS) {
      rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
    } else if (Platform.isAndroid) {
      var rotationCompensation =
          _orientations[_controller!.value.deviceOrientation];
      if (rotationCompensation == null) return null;
      if (camera.lensDirection == CameraLensDirection.front) {
        // front-facing
        rotationCompensation = (sensorOrientation + rotationCompensation) % 360;
      } else {
        // back-facing
        rotationCompensation =
            (sensorOrientation - rotationCompensation + 360) % 360;
      }
      rotation = InputImageRotationValue.fromRawValue(rotationCompensation);
      // print('rotationCompensation: $rotationCompensation');
    }
    if (rotation == null) return null;
    // print('final rotation: $rotation');

    // get image format
    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    // validate format depending on platform
    // only supported formats:
    // * nv21 for Android
    // * bgra8888 for iOS
    if (format == null ||
        (Platform.isAndroid && format != InputImageFormat.nv21) ||
        (Platform.isIOS && format != InputImageFormat.bgra8888)) return null;

    // since format is constraint to nv21 or bgra8888, both only have one plane
    if (image.planes.length != 1) return null;
    final plane = image.planes.first;

    // compose InputImage using bytes
    return InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation, // used only in Android
        format: format, // used only in iOS
        bytesPerRow: plane.bytesPerRow,
        // used only in iOS
      ),
    );
  }

  Future<void> takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      print('Error: select a camera first.');
      return;
    }

    if (_controller!.value.isTakingPicture) {
      // A capture is already pending, do nothing.
      return;
    }
    final dataController = ref.watch(controllerProvider);
    try {
      XFile file = await _controller!.takePicture();
      if (file != null) {
        print('closing app::${file.path}');
        dataController.setFile(file);
        return;
      }
    } on CameraException catch (e) {
      print(e.description);
      return null;
    }
  }

  // captureImage() async {
  //   takePicture().then((XFile? file) {
  //     /// Return image callback
  //     if (file != null) {
  //       print('closing app::${file.path}');
  //       Navigator.pop(context, file.path);
  //     }
  //
  //     /// Resume image stream after 2 seconds of capture
  //     // Future.delayed(const Duration(seconds: 2)).whenComplete(() {});
  //   });
  // }
}
