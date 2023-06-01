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
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAnUlRTOhesjgr-GItKDiD_U8aFRYZqlNM',
    appId: '1:490190755048:android:2441a57abc9fefef56a55d',
    messagingSenderId: '490190755048',
    projectId: 'leviathan-app',
    storageBucket: 'leviathan-app.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAtsuNwKeALOI_fDdaxhz9NZJFg4LfuJOE',
    appId: '1:490190755048:ios:ae68d7951d2f46b556a55d',
    messagingSenderId: '490190755048',
    projectId: 'leviathan-app',
    storageBucket: 'leviathan-app.appspot.com',
    androidClientId: '490190755048-1v1c1g54ncni5cfji88vhic9l7l7j8ma.apps.googleusercontent.com',
    iosClientId: '490190755048-fe5dm74rjskf6jed4tb304i0n5uomh78.apps.googleusercontent.com',
    iosBundleId: 'com.leviathanapp.leviathanApp',
  );
}