import 'package:flutter/material.dart';
import '../views/login_view.dart';
import '../views/signup_view.dart';
import '../views/firebase_check_page.dart';

class AppRoutes {
  // Route names
  static const String login = '/login';
  static const String signupScreen = '/signupscreen';
  static const String check = '/check';

  // Route map
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      login: (_) => const LoginView(),
      signupScreen: (_) => const SignUpScreen(),
      check: (_) => const FirebaseCheckPage(),
    };
  }
}
