import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
    apiKey: 'AIzaSyDZcyYDM7KM29oYiS67dmb-kvksdmCTNxc',
    appId: '1:272807240764:web:39e11b33bb9350baf64f39',
    messagingSenderId: '272807240764',
    projectId: 'my-blog-1766143027',
    authDomain: 'my-blog-1766143027.firebaseapp.com',
    storageBucket: 'my-blog-1766143027.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDZcyYDM7KM29oYiS67dmb-kvksdmCTNxc',
    appId: '1:272807240764:android:acf272cde24dadfaf64f39',
    messagingSenderId: '272807240764',
    projectId: 'my-blog-1766143027',
    storageBucket: 'my-blog-1766143027.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCn9iJf4u0-21IBXE9Nm19g0Nvjneuf94c',
    appId: '1:272807240764:ios:467c4685fd584386f64f39',
    messagingSenderId: '272807240764',
    projectId: 'my-blog-1766143027',
    storageBucket: 'my-blog-1766143027.firebasestorage.app',
    iosBundleId: 'com.example.myBlog',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'YOUR_MACOS_API_KEY',
    appId: 'YOUR_MACOS_APP_ID',
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    storageBucket: 'YOUR_STORAGE_BUCKET',
    iosBundleId: 'YOUR_MACOS_BUNDLE_ID',
  );
}