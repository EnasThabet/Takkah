import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import '../config/app_config.dart';

class FirebaseService {
  static Future<void> initialize() async {
    WidgetsFlutterBinding.ensureInitialized();

    if (kIsWeb) {
      try {
        await Firebase.initializeApp(options: AppConfig.firebaseWebOptions);
      } catch (e) {
        debugPrint('Firebase.initializeApp() failed on web: $e');
      }
    } else {
      await Firebase.initializeApp();
    }
  }
}
