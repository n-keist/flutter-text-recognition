import 'dart:developer';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:testfl/bloc/camera/camera_bloc.dart';
import 'package:testfl/bloc/camera/camera_state.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  static Widget cubit() {
    return BlocProvider(
      create: (_) => CameraCubit()..init(),
      child: const CameraScreen(),
    );
  }

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> with WidgetsBindingObserver, TickerProviderStateMixin {
  CameraCubit get cubit => context.read<CameraCubit>();

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (context.read<CameraCubit>().state.controller == null ||
        !context.read<CameraCubit>().state.controller!.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive || state == AppLifecycleState.detached) {
      context.read<CameraCubit>().state.controller?.dispose();
    }
    if (state == AppLifecycleState.resumed) {
      context.read<CameraCubit>().init();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('text recognition'),
        centerTitle: false,
      ),
      backgroundColor: Colors.black,
      body: Center(
        child: BlocSelector<CameraCubit, CameraState, CameraController?>(
          selector: (state) => state.controller,
          builder: (context, controller) {
            if (controller == null) {
              return const Center(
                child: Text('Controller is Null!'),
              );
            }
            if (!controller.value.isInitialized) {
              return const Center(
                child: Text('Controller is not Initialized!'),
              );
            }
            return AspectRatio(
              aspectRatio: 1 / controller.value.aspectRatio,
              child: CameraPreview(
                controller,
                child: LayoutBuilder(builder: (context, constraints) {
                  cubit.containingBoxSize = Size(constraints.maxWidth, constraints.maxHeight);
                  return BlocSelector<CameraCubit, CameraState, List<RecognizedTextElement>>(
                    selector: (state) => state.elements,
                    builder: (context, elements) => _recognizedElementsBuilder(elements),
                  );
                }),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: cubit.snapshot,
        icon: const Icon(Icons.camera_alt_rounded),
        label: const Text('snapshot'),
      ),
    );
  }

  Widget _recognizedElementsBuilder(List<RecognizedTextElement> elements) {
    log('${elements.length}', name: 'DRAW');
    return Stack(
      children: [
        for (final element in elements)
          Positioned.fromRect(
            rect: element.position,
            child: Container(
              height: element.position.height,
              width: element.position.width,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white),
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: GestureDetector(
                onTap: () => _showTappedValue(element.text),
                child: Center(
                  child: Text(
                    element.text,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10.0,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _showTappedValue(String text) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        content: Text(text),
      ),
    );
  }
}
