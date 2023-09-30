import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mindcompass/screens/fillForm.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _openFillFormScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => const FillFromScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mindcompass'),
        actions: [
          IconButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
            icon: Icon(
              Icons.exit_to_app,
              color: Theme.of(context).colorScheme.primary,
            ),
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Welcome, new user!'),
            const SizedBox(
              height: 10,
            ),
            ElevatedButton(
              onPressed: () => _openFillFormScreen(context),
              child: const Text('Fill Form'),
            ),
          ],
        ),
      ),
    );
  }
}
