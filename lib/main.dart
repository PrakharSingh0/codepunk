import 'package:codepunk/Mode/Admin/AdminPage.dart';
import 'package:codepunk/Mode/User/Pages/RSVP.dart';
import 'package:codepunk/welcomePage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'Mode/Admin/AdminStart.dart';
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
      home: WelcomePage(),
    ),
  ); //runApp
}