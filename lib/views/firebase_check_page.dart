import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'signup_view.dart';

class FirebaseCheckPage extends StatelessWidget {
  const FirebaseCheckPage({super.key});

  bool get _firebaseAvailable => Firebase.apps.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Firebase Check'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _firebaseAvailable
                  ? 'Firebase Connected!'
                  : 'Firebase NOT initialized',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                debugPrint('Firebase.apps: ${Firebase.apps}');
              },
              child: const Text('Print Firebase.apps'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SignUpView()),
                );
              },
              child: const Text('Open Sign Up Page'),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tip: Run `flutterfire configure` to generate firebase_options.dart for web.',
            ),
          ],
        ),
      ),
    );
  }
}
