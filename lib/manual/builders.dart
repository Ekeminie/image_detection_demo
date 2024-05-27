import 'package:flutter/material.dart';
import 'package:image_detection_demo/manual/enum_handler.dart';
import 'package:image_detection_demo/manual/face-identifier.dart';

/// Returns widget for flash modes
typedef FlashControlBuilder = Widget Function(
    BuildContext context, CameraFlashMode mode);

/// Returns message based on face position
typedef MessageBuilder = Widget Function(
    BuildContext context, DetectedFace? detectedFace);

/// Returns widget for detector
typedef IndicatorBuilder = Widget Function(
    BuildContext context, DetectedFace? detectedFace, Size? imageSize);

/// Returns widget for capture control
typedef CaptureControlBuilder = Widget Function(
    BuildContext context, DetectedFace? detectedFace);
