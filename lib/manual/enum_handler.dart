import 'package:camera/camera.dart';
import 'package:flutter/services.dart';

class EnumHandler {
  static ResolutionPreset imageResolutionToResolutionPreset(
      ImageResolution res) {
    switch (res) {
      case ImageResolution.low:
        // TODO: Handle this case.
        return ResolutionPreset.low;
      case ImageResolution.medium:
        // TODO: Handle this case.
        return ResolutionPreset.medium;
      case ImageResolution.high:
        // TODO: Handle this case.
        return ResolutionPreset.high;
      case ImageResolution.veryHigh:
        // TODO: Handle this case.
        return ResolutionPreset.veryHigh;
      case ImageResolution.ultraHigh:
        // TODO: Handle this case.
        return ResolutionPreset.ultraHigh;
      case ImageResolution.max:
        // TODO: Handle this case.
        return ResolutionPreset.max;
    }
  }

  static CameraLensDirection? cameraLensToCameraLensDirection(
      CameraLens? lens) {
    switch (lens) {
      case CameraLens.front:
        // TODO: Handle this case.
        return CameraLensDirection.front;
      case CameraLens.back:
        // TODO: Handle this case.
        return CameraLensDirection.back;
      case CameraLens.external:
        // TODO: Handle this case.
        return CameraLensDirection.external;
      default:
        return null;
    }
  }

  static CameraLens? cameraLensDirectionToCameraLens(
      CameraLensDirection? lens) {
    switch (lens) {
      case CameraLensDirection.front:
        // TODO: Handle this case.
        return CameraLens.front;
      case CameraLensDirection.back:
        // TODO: Handle this case.
        return CameraLens.back;
      case CameraLensDirection.external:
        // TODO: Handle this case.
        return CameraLens.external;
      default:
        return null;
    }
  }

  static FlashMode cameraFlashModeToFlashMode(CameraFlashMode mode) {
    switch (mode) {
      case CameraFlashMode.off:
        // TODO: Handle this case.
        return FlashMode.off;
      case CameraFlashMode.auto:
        // TODO: Handle this case.
        return FlashMode.auto;
      case CameraFlashMode.always:
        // TODO: Handle this case.
        return FlashMode.always;
    }
  }

  static DeviceOrientation? cameraOrientationToDeviceOrientation(
      CameraOrientation? orientation) {
    switch (orientation) {
      case CameraOrientation.portraitUp:
        // TODO: Handle this case.
        return DeviceOrientation.portraitUp;
      case CameraOrientation.landscapeLeft:
        // TODO: Handle this case.
        return DeviceOrientation.landscapeLeft;
      case CameraOrientation.portraitDown:
        // TODO: Handle this case.
        return DeviceOrientation.portraitDown;
      case CameraOrientation.landscapeRight:
        // TODO: Handle this case.
        return DeviceOrientation.landscapeRight;
      default:
        return null;
    }
  }
}

// Copyright 2022 Conezi. All rights reserved.

/// Affect the quality of video recording and image capture:
///
/// If a preset is not available on the camera being used a preset of lower quality will be selected automatically.
enum ImageResolution {
  /// 352x288 on iOS, 240p (320x240) on Android and Web
  low,

  /// 480p (640x480 on iOS, 720x480 on Android and Web)
  medium,

  /// 720p (1280x720)
  high,

  /// 1080p (1920x1080)
  veryHigh,

  /// 2160p (3840x2160 on Android and iOS, 4096x2160 on Web)
  ultraHigh,

  /// The highest resolution available.
  max,
}

/// The direction the camera is facing.
enum CameraLens {
  /// Front facing camera (a user looking at the screen is seen by the camera).
  front,

  /// Back facing camera (a user looking at the screen is not seen by the camera).
  back,

  /// External camera which may not be mounted to the device.
  external,
}

/// The possible flash modes that can be set for a camera
enum CameraFlashMode {
  /// Do not use the flash when taking a picture.
  off,

  /// Let the device decide whether to flash the camera when taking a picture.
  auto,

  /// Always use the flash when taking a picture.
  always
}

enum CameraOrientation {
  /// If the device shows its boot logo in portrait, then the boot logo is shown
  /// in [portraitUp]. Otherwise, the device shows its boot logo in landscape
  /// and this orientation is obtained by rotating the device 90 degrees
  /// clockwise from its boot orientation.
  portraitUp,

  /// The orientation that is 90 degrees clockwise from [portraitUp].
  ///
  /// If the device shows its boot logo in landscape, then the boot logo is
  /// shown in [landscapeLeft].
  landscapeLeft,

  /// The orientation that is 180 degrees from [portraitUp].
  portraitDown,

  /// The orientation that is 90 degrees counterclockwise from [portraitUp].
  landscapeRight,
}

/// Face indicator shapes
enum IndicatorShape {
  defaultShape,
  square,
  circle,
  triangle,
  triangleInverted,

  /// Uses an asset image as face indicator
  image,

  /// Hide face indicator
  none
}
