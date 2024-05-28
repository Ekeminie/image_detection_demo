import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_detection_demo/manual/enum_handler.dart';
import 'package:image_detection_demo/manual/manual-kyc.dart';

import 'face_camera.dart';

class ManualCamera extends StatefulWidget {
  const ManualCamera({Key? key}) : super(key: key);

  @override
  State<ManualCamera> createState() => _ManualCameraState();
}

class _ManualCameraState extends State<ManualCamera> {
  final ValueNotifier<File?> _capturedImage = ValueNotifier(null);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('FaceCamera example app'),
        ),
        body: ValueListenableBuilder(
          valueListenable: _capturedImage,
          builder: (context, image, _) => Builder(builder: (context) {
            if (image != null) {
              return Center(
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    Image.file(
                      image,
                      width: double.maxFinite,
                      fit: BoxFit.fitWidth,
                    ),
                    ElevatedButton(
                        onPressed: () => _capturedImage.value = null,
                        child: const Text(
                          'Capture Again',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w700),
                        )),
                    ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(image),
                        child: const Text(
                          'Go back ',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w700),
                        )),
                    //    Navigator.pop(context, image);
                  ],
                ),
              );
            }
            return SmartFaceCamera(
                autoCapture: false,
                defaultCameraLens: CameraLens.front,
                onCapture: (File? image) {
                  // _capturedImage.value = image;
                  Navigator.pop(context, XFile(image!.path));
                },
                onFaceDetected: (Face? face) {
                  //Do something
                },
                messageBuilder: (context, face) {
                  if (face == null) {
                    return _message('Place your face in the camera');
                  }
                  if (!face.wellPositioned) {
                    return _message('Center your face in the square');
                  }
                  return const SizedBox.shrink();
                });
          }),
        ));
  }

  Widget _message(String msg) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 55, vertical: 15),
        child: Text(msg,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 14, height: 1.5, fontWeight: FontWeight.w400)),
      );
}
