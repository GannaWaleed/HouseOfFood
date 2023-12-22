import 'package:flutter/material.dart';
import 'package:house_of_food/MyProfilePage.dart';
import 'Login.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'chooser.dart';
import 'HmRegistration.dart';
import 'UserRegistration.dart';
import 'HomePage2.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoginPage(),
    );
  }
}
