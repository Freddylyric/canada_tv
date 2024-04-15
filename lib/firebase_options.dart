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
    apiKey: 'AIzaSyD1gGNMqST-htd2aOV995wOCk8SEGT6GFU',
    appId: '1:843611395709:web:79b78e7d67319dc43c0314',
    messagingSenderId: '843611395709',
    projectId: 'codecraft-ca43a',
    authDomain: 'codecraft-ca43a.firebaseapp.com',
    databaseURL: 'https://codecraft-ca43a-default-rtdb.firebaseio.com',
    storageBucket: 'codecraft-ca43a.appspot.com',
    measurementId: 'G-1XGHTJVM7Z',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyClDuaUdFOMa9506R2BprgjEOvBa1dW2EE',
    appId: '1:843611395709:android:648a22fbdf25752f3c0314',
    messagingSenderId: '843611395709',
    projectId: 'codecraft-ca43a',
    databaseURL: 'https://codecraft-ca43a-default-rtdb.firebaseio.com',
    storageBucket: 'codecraft-ca43a.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDM_h5MQAMxJF8pwl1bF3ZuqqUjwF7ZNgs',
    appId: '1:843611395709:ios:4d8f170f87b71ffc3c0314',
    messagingSenderId: '843611395709',
    projectId: 'codecraft-ca43a',
    databaseURL: 'https://codecraft-ca43a-default-rtdb.firebaseio.com',
    storageBucket: 'codecraft-ca43a.appspot.com',
    iosBundleId: 'com.codecraft.canadaIptv',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDM_h5MQAMxJF8pwl1bF3ZuqqUjwF7ZNgs',
    appId: '1:843611395709:ios:a6296596d34d1a413c0314',
    messagingSenderId: '843611395709',
    projectId: 'codecraft-ca43a',
    databaseURL: 'https://codecraft-ca43a-default-rtdb.firebaseio.com',
    storageBucket: 'codecraft-ca43a.appspot.com',
    iosBundleId: 'com.codecraft.canadaIptv.RunnerTests',
  );
}
