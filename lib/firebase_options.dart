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
        return windows;
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
    apiKey: 'AIzaSyDgXKB2K0w1WCrrFJbju-uuCBO8zwch68I',
    appId: '1:464883505849:web:316fb2041b496e12249968',
    messagingSenderId: '464883505849',
    projectId: 'Paradise-d3e67',
    authDomain: 'Paradise-d3e67.firebaseapp.com',
    storageBucket: 'Paradise-d3e67.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDgXKB2K0w1WCrrFJbju-uuCBO8zwch68I',
    appId: '1:464883505849:android:316fb2041b496e12249968',
    messagingSenderId: '464883505849',
    projectId: 'Paradise-d3e67',
    storageBucket: 'Paradise-d3e67.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDgXKB2K0w1WCrrFJbju-uuCBO8zwch68I',
    appId: '1:464883505849:ios:316fb2041b496e12249968',
    messagingSenderId: '464883505849',
    projectId: 'Paradise-d3e67',
    storageBucket: 'Paradise-d3e67.firebasestorage.app',
    iosBundleId: 'com.example.paradise_app',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDgXKB2K0w1WCrrFJbju-uuCBO8zwch68I',
    appId: '1:464883505849:ios:316fb2041b496e12249968',
    messagingSenderId: '464883505849',
    projectId: 'Paradise-d3e67',
    storageBucket: 'Paradise-d3e67.firebasestorage.app',
    iosBundleId: 'com.example.paradise_app',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDgXKB2K0w1WCrrFJbju-uuCBO8zwch68I',
    appId: '1:464883505849:web:316fb2041b496e12249968',
    messagingSenderId: '464883505849',
    projectId: 'Paradise-d3e67',
    authDomain: 'Paradise-d3e67.firebaseapp.com',
    storageBucket: 'Paradise-d3e67.firebasestorage.app',
  );
}