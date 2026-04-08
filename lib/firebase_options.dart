import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions no está configurado para web.',
      );
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions no está configurado para esta plataforma.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBFSZgberDFSVg-xw9Ci2nhnKd9udZd8MQ',
    appId: '1:243551909774:android:a5fabda11ca12935afd6df',
    messagingSenderId: '243551909774',
    projectId: 'correlativas-pscs',
    storageBucket: 'correlativas-pscs.firebasestorage.app',
    databaseURL: 'https://correlativas-pscs-default-rtdb.firebaseio.com',
  );
}
