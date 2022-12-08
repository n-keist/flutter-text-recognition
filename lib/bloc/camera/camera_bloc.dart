import 'dart:async';
import 'dart:developer' as d;
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:testfl/bloc/camera/camera_state.dart';
import 'package:testfl/isolate/camera_image_extension.dart';
import 'package:testfl/isolate/coordinates_translator.dart';
import 'package:worker_manager/worker_manager.dart';

class CameraCubit extends Cubit<CameraState> {
  CameraCubit() : super(const CameraState());

  Size? containingBoxSize;

  final offset = 4.0;
  final int detectionThreshold = 1000;

  CameraController? get cameraController => state.controller;
  void log(String msg) => d.log(msg, name: 'OCR');

  void init() async {
    final cameras = await availableCameras();
    if (cameras.isNotEmpty) {
      final controller = CameraController(
        cameras.first,
        ResolutionPreset.max,
        enableAudio: false,
      );
      await controller.initialize();
      await controller.setExposureMode(ExposureMode.auto);
      await controller.setFocusMode(FocusMode.auto);
      await controller.lockCaptureOrientation();
      controller.startImageStream(onImage);
      emit(
        CameraState(controller: controller),
      );
    }
  }

  void snapshot() async {
    if (cameraController?.value.isPreviewPaused ?? false) {
      await cameraController?.resumePreview();
      await cameraController?.startImageStream(onImage);
      return;
    }
    await cameraController?.pausePreview();
    await cameraController?.stopImageStream();
  }

  Timer? timer;
  Future<void> onImage(CameraImage image) async {
    if (cameraController == null) return;
    if (timer == null || !timer!.isActive) {
      timer = Timer(Duration(milliseconds: detectionThreshold), () async {
        var args = CameraImageArgs()
          ..cameraDescription = cameraController!.description
          ..cameraImage = image;

        final inputImage = await GetIt.I<Executor>().execute(
          fun1: toInputImage,
          arg1: args,
        );

        if (inputImage != null) {
          var recognizedText = await GetIt.I<TextRecognizer>().processImage(inputImage);
          if (isClosed) return;
          final elements = <TextElement>[];

          final blocks = recognizedText.blocks;
          for (final block in blocks) {
            for (final line in block.lines) {
              elements.addAll(line.elements);
            }
          }
          calculatePositionsForRecognizedText(
            elements,
            image.width.toDouble(),
            image.height.toDouble(),
          );
        }
      });
    }
  }

  Future<void> calculatePositionsForRecognizedText(List<TextElement> elements, double width, double height) async {
    if (containingBoxSize == null) return;

    final bool ios = Platform.isIOS;
    final rotation = cameraController!.description.sensorOrientation;
    List<RecognizedTextElement> results = [];
    for (final element in elements) {
      final options = <String, dynamic>{
        'ios': ios,
        'x': element.boundingBox.left,
        'y': element.boundingBox.top,
        'rotation': rotation,
        'width': containingBoxSize!.width,
        'height': containingBoxSize!.height,
        'absWidth': width,
        'absHeight': height,
      };

      double left = await compute(calcX, options);
      double top = await compute(calcY, options);

      options.update('x', (_) => element.boundingBox.right);
      options.update('y', (_) => element.boundingBox.bottom);
      double right = await compute(calcX, options);
      double bottom = await compute(calcY, options);
      final recognizedElement = RecognizedTextElement(
        text: element.text,
        position: Rect.fromLTRB(left - offset, top - offset, right + offset, bottom + offset),
      );
      results.add(recognizedElement);
    }
    emit(
      state.with$(elements: results),
    );
  }
}
