// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```https://carpooling-df2d9-default-rtdb.firebaseio.com/
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDQaqKftoapNLtx7JJeZr3MKIZckOmJQYw',
    appId: '1:355367198365:web:20104641b88bc5f3fdfe74',
    messagingSenderId: '355367198365',
    projectId: 'carpooling-df2d9',
    authDomain: 'carpooling-df2d9.firebaseapp.com',
    storageBucket: 'carpooling-df2d9.appspot.com',
    measurementId: 'G-NR61TYZCTZ',
    databaseURL: 'https://carpooling-df2d9-default-rtdb.firebaseio.com/',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBRyj-ThkS3NzfrxFhw-8C8_v7RRwdvA-M',
    appId: '1:355367198365:android:1b1c47efd788a85afdfe74',
    messagingSenderId: '355367198365',
    projectId: 'carpooling-df2d9',
    storageBucket: 'carpooling-df2d9.appspot.com',
    databaseURL: 'https://carpooling-df2d9-default-rtdb.firebaseio.com/',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDnuIf6git1VLXko4VOGI_z3Z2rpEK-Xes',
    appId: '1:355367198365:ios:84c9d118a7aced7efdfe74',
    messagingSenderId: '355367198365',
    projectId: 'carpooling-df2d9',
    storageBucket: 'carpooling-df2d9.appspot.com',
    iosBundleId: 'com.example.carPooling',
    databaseURL: 'https://carpooling-df2d9-default-rtdb.firebaseio.com/',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDnuIf6git1VLXko4VOGI_z3Z2rpEK-Xes',
    appId: '1:355367198365:ios:b1bae793d8e19bbffdfe74',
    messagingSenderId: '355367198365',
    projectId: 'carpooling-df2d9',
    storageBucket: 'carpooling-df2d9.appspot.com',
    iosBundleId: 'com.example.carPooling.RunnerTests',
  );
}
