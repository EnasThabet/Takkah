import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import './config/app_config.dart';
import './config/app_routes.dart';
import './config/app_theme.dart';
import './services/firebase_service.dart';
import './services/supabase_service.dart';
import './views/splash_view.dart';

void main() async {
  // 1. تأكد من الـ binding
  WidgetsFlutterBinding.ensureInitialized();

  // 2. تحميل ملف .env
  await dotenv.load(fileName: '.env');

  // 3. تهيئة التكوين
  AppConfig.loadFromEnv();

  // 4. تهيئة Firebase
  await FirebaseService.initialize();

  // 5. تهيئة Supabase (بعد Firebase)
  await SupabaseService.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const TakkehApp();
  }
}

class TakkehApp extends StatelessWidget {
  const TakkehApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Takkeh',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashView(),
      routes: AppRoutes.getRoutes(),
    );
  }
}
