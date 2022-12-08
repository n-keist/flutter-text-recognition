import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:worker_manager/worker_manager.dart';

class CameraImageArgs {
  late CameraImage cameraImage;
  late CameraDescription cameraDescription;
}

Future<InputImage?> toInputImage(CameraImageArgs args, TypeSendPort sendPort) async {
  final allBytes = WriteBuffer();
  for (final plane in args.cameraImage.planes) {
    allBytes.putUint8List(plane.bytes);
  }
  final bytes = allBytes.done().buffer.asUint8List();

  final imageSize = Size(args.cameraImage.width.toDouble(), args.cameraImage.height.toDouble());

  final imageRotation = InputImageRotationValue.fromRawValue(args.cameraDescription.sensorOrientation);
  if (imageRotation == null) return null;

  final inputImageFormat = InputImageFormatValue.fromRawValue(args.cameraImage.format.raw);
  if (inputImageFormat == null) return null;

  final planeData = args.cameraImage.planes.map((plane) {
    return InputImagePlaneMetadata(
      bytesPerRow: plane.bytesPerRow,
      height: plane.height,
      width: plane.width,
    );
  }).toList();

  final inputImageData = InputImageData(
    size: imageSize,
    imageRotation: imageRotation,
    inputImageFormat: inputImageFormat,
    planeData: planeData,
  );

  var inputImage = InputImage.fromBytes(bytes: bytes, inputImageData: inputImageData);
  return inputImage;
}
