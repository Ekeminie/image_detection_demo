import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_detection_demo/controller/steps-controller.dart';
import 'package:image_detection_demo/kyc-image-capture.dart';
import 'package:image_detection_demo/manual/face_camera.dart';

late List<CameraDescription> cameras_;
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FaceCamera.initialize();
  cameras_ = await availableCameras();
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: FaceCaptureDemo() //MyHomePage(),
        );
  }
}

class FaceCaptureDemo extends ConsumerWidget {
  FaceCaptureDemo({super.key});
  ValueNotifier<XFile?> image = ValueNotifier(null);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = ref.watch(controllerProvider);
    return Scaffold(
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Spacer(),
            if (c.file != null)
              SizedBox(
                  child: AspectRatio(
                      aspectRatio: 3 / 2,
                      child: Image.file(File(c.file!.path)))),
            if (c.file != null)
              const SizedBox(
                height: 34,
              ),
            GestureDetector(
                onTap: () async {
                  c.reset();
                  XFile? imagePath =
                      await KycImageCapture.instance.captureImage(context);
                  image.value = imagePath;
                },
                child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(12)),
                    child: const Text("Auto-Capture Image"))),
            const SizedBox(height: 14),
            GestureDetector(
                onTap: () async {
                  XFile? imagePath = await KycImageCapture.instance
                      .captureImage(context, auto: false);
                  image.value = imagePath;
                },
                child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(12)),
                    child: const Text("Capture Image Manually"))),
            ValueListenableBuilder(
                valueListenable: image,
                builder: (context, photo, _) => photo != null
                    ? Visibility(
                        visible: photo != null,
                        child: AspectRatio(
                            aspectRatio: 3 / 2,
                            child: Image.file(File(photo.path))))
                    : const SizedBox.shrink()),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
