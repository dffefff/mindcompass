import 'package:mindcompass/screens/auth.dart';
import 'package:mindcompass/screens/formQuestionList.dart';
import 'package:mindcompass/screens/home.dart';
import 'package:mindcompass/screens/splash.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlutterChat',
      theme: ThemeData().copyWith(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 63, 17, 177)),
      ),
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SplashScreen();
          }

          if (snapshot.hasData) {
            final user = FirebaseAuth.instance.currentUser;
            if (user != null &&
                user.metadata.creationTime == user.metadata.lastSignInTime) {
              return const FormQuestionListScreen(); // Show NewUserScreen for new users
            } else {
              return const HomeScreen(); // Show HomeScreen for returning users
            }
          }

          return const AuthScreen();
        },
      ),
    );
  }
}
