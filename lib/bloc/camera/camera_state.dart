import 'package:camera/camera.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class RecognizedTextElement extends Equatable {
  final String text;
  final Rect position;

  const RecognizedTextElement({
    required this.text,
    required this.position,
  });

  @override
  List<Object?> get props => [text, position];
}

class CameraState extends Equatable {
  final CameraController? controller;
  final List<RecognizedTextElement> elements;

  const CameraState({
    this.controller,
    this.elements = const [],
  });

  CameraState with$({CameraController? Function()? controller, List<RecognizedTextElement>? elements}) {
    return CameraState(
      controller: controller != null ? controller.call() : this.controller,
      elements: elements ?? this.elements,
    );
  }

  @override
  List<Object?> get props => [controller, elements];
}
