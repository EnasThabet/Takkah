import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  // Supabase Configuration
  static late String supabaseUrl;
  static late String supabaseAnonKey;

  // Firebase Configuration
  static late FirebaseOptions firebaseWebOptions;

  // Load configuration from .env file
  static void loadFromEnv() {
    supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
    supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';

    firebaseWebOptions = FirebaseOptions(
      apiKey: dotenv.env['FIREBASE_API_KEY'] ?? '',
      authDomain: dotenv.env['FIREBASE_AUTH_DOMAIN'] ?? '',
      projectId: dotenv.env['FIREBASE_PROJECT_ID'] ?? '',
      storageBucket: dotenv.env['FIREBASE_STORAGE_BUCKET'] ?? '',
      messagingSenderId: dotenv.env['FIREBASE_MESSAGING_SENDER_ID'] ?? '',
      appId: dotenv.env['FIREBASE_APP_ID'] ?? '',
      measurementId: dotenv.env['FIREBASE_MEASUREMENT_ID'] ?? '',
    );
  }
}
