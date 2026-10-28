// ===== FIREBASE OPTIONS - KONFIGURASI FLUTTERFIRE =====

// File ini merupakan konfigurasi Firebase Options untuk project Campus Lost & Found.
// Sesuai aturan UTS, file ini wajib di-commit ke Git dan TIDAK dimasukkan ke .gitignore.
// Jalankan `flutterfire configure` untuk menimpa dengan kredensial project Firebase aktif Anda.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] untuk integrasi Firebase di Flutter.
///
/// Dihasilkan atau diperbarui melalui:
/// ```bash
/// flutterfire configure
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
          'DefaultFirebaseOptions belum dikonfigurasi untuk Linux - '
          'jalankan kembali FlutterFire CLI untuk mengonfigurasi.',
        );
      default:
        throw UnsupportedError(
          'Platform ini tidak didukung oleh DefaultFirebaseOptions.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBj0raN8-erm9fvOAkOtZPSeVkUYoZb1TM',
    appId: '1:612822225429:web:24da4fe84a5a1c175bf41c',
    messagingSenderId: '612822225429',
    projectId: 'campus-lost-found-70ded',
    authDomain: 'campus-lost-found-70ded.firebaseapp.com',
    storageBucket: 'campus-lost-found-70ded.firebasestorage.app',
    measurementId: 'G-MZ75ZQ7LTG',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAq4Yo3c3sq5-90PMll88VwgwSFaLMgfSA',
    appId: '1:612822225429:android:0814440cc91a006a5bf41c',
    messagingSenderId: '612822225429',
    projectId: 'campus-lost-found-70ded',
    storageBucket: 'campus-lost-found-70ded.firebasestorage.app',
  );
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDemoIosApiKeyForCompilationOnly123',
    appId: '1:100000000000:ios:abcdef1234567890',
    messagingSenderId: '100000000000',
    projectId: 'campus-lost-found',
    storageBucket: 'campus-lost-found.appspot.com',
    iosBundleId: 'com.campusi.lostfound',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDemoMacosApiKeyForCompilation123',
    appId: '1:100000000000:ios:abcdef1234567890',
    messagingSenderId: '100000000000',
    projectId: 'campus-lost-found',
    storageBucket: 'campus-lost-found.appspot.com',
    iosBundleId: 'com.campusi.lostfound',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBj0raN8-erm9fvOAkOtZPSeVkUYoZb1TM',
    appId: '1:612822225429:web:6aa1b10e9d7fec265bf41c',
    messagingSenderId: '612822225429',
    projectId: 'campus-lost-found-70ded',
    authDomain: 'campus-lost-found-70ded.firebaseapp.com',
    storageBucket: 'campus-lost-found-70ded.firebasestorage.app',
    measurementId: 'G-E6YWE7C850',
  );
}
