import 'dart:io';

import 'package:flutter/services.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
// import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

Future<String> getAssetPath(String asset) async {
  final path = await getLocalPath(asset);
  await Directory(dirname(path)).create(recursive: true);
  final file = File(path);
  if (!await file.exists()) {
    final byteData = await rootBundle.load(asset);
    await file.writeAsBytes(byteData.buffer
        .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
  }
  return file.path;
}

Future<String> getLocalPath(String path) async {
  return '${(await getApplicationSupportDirectory()).path}/$path';
}

class ImageConversionUtils {
  Future<String?> getImagePath(InputImage inputImage) async {
    Uint8List? bytes = inputImage.bytes;
    final tempDir = Directory.systemTemp;
    final tempPath = tempDir.path;
    final file = File('$tempPath/image.jpg');
    await file.writeAsBytes(bytes!);
    return file.path;
  }
}
