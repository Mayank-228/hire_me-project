// File generated manually from android/app/google-services.json
// Project: hireme-4aec7
// To regenerate: flutterfire configure --project=hireme-4aec7

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      // For web preview — uses Android config as placeholder
      // To fully support web, add your Firebase web app config here
      return android;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for iOS — '
          'reconfigure using the FlutterFire CLI.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBD0HiMafV-Kk-4H51QYovWPukVHuC66dU',
    appId: '1:558410707304:android:8b588e57e66219624866dd',
    messagingSenderId: '558410707304',
    projectId: 'hireme-4aec7',
    storageBucket: 'hireme-4aec7.firebasestorage.app',
  );
}
