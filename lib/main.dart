import 'package:color_picker/template/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ); // Initialisation Firebase
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Color Picker App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'FugazOne',
        primaryColor: Colors.black,
      ),
      home: const SplashScreen(),
    );
  }
}