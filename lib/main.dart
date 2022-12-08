import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:testfl/screens/camera_screen.dart';
import 'package:worker_manager/worker_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GetIt.I.registerSingleton<Executor>(Executor()..warmUp(log: false));
  GetIt.I.registerSingleton<TextRecognizer>(TextRecognizer());
  await GetIt.I.allReady();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      showPerformanceOverlay: true,
      home: CameraScreen.cubit(),
    );
  }
}
