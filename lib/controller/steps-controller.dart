import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class DataModel extends ChangeNotifier {
  CameraController? _controller;

  initCameraController(CameraController? c) {
    print('xxxxxx:::camera');
    _controller = c;
    notifyListeners();
  }

  disposeCameraController() async {
    await _controller?.stopImageStream();
    await _controller?.dispose();
    print('yyyyyyyy:::camera');
    notifyListeners();
  }

  capture(Function() f) async {
    controller!.stopImageStream().whenComplete(() async {
      await Future.delayed(const Duration(milliseconds: 500));
      f();
    });
  }

  CameraController? get controller {
    return _controller;
  }

  GestureSteps steps = GestureSteps.start;

  nextStep() {
    if (steps == GestureSteps.hasStepTwo) return;
    if (steps == GestureSteps.start) {
      steps = GestureSteps.hasStepOne;
    } else {
      steps = GestureSteps.hasStepTwo;
    }
    notifyListeners();
  }

  bool start = false;

  bool hasPassedStepOne = false;
  bool hasPassedStepTwo = false;

  completeStepOne() {
    hasPassedStepOne = true;
    notifyListeners();
  }

  completeStepTwo() {
    hasPassedStepTwo = true;
    notifyListeners();
  }

  startAction() {
    start = true;
    notifyListeners();
  }

  stop() {
    start = false;
    notifyListeners();
  }

  reset() {
    start = false;
    hasPassedStepOne = false;
    hasPassedStepTwo = false;
    notifyListeners();
  }

  XFile? file;
  setFile(XFile f) {
    file = f;
    notifyListeners();
  }
}

final controllerProvider = ChangeNotifierProvider.autoDispose(
  (_) => DataModel(),
);

enum GestureSteps {
  start(instruction: "Please Smile", value: "0"),
  hasStepOne(instruction: "Please Blink", value: "1"),
  hasStepTwo(instruction: "", value: "2");

  final String? instruction;
  final String? value;
  const GestureSteps({this.instruction, this.value});
}
