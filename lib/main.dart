import 'package:codepunk/pages/adminPage/adminPage.dart';
import 'package:codepunk/pages/userMode/problemStatementPage.dart';
import 'package:codepunk/welcomePage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';

// ...
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: welcomePage(),
    ),
  ); //runApp
}