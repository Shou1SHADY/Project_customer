import 'package:flutter/material.dart';
import 'Layout/layout.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // final FirebaseOptions firebaseOptions = await getFirebaseOptions();
  // await Firebase.initializeApp(options: firebaseOptions);

  runApp(MyApp());
}

// default account : shadyosama659@gmail.com
//default pass : 123456

//driver : Shady@yahoo.com
//pass :123456