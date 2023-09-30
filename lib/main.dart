import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
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

// class App extends StatelessWidget {
//   const App({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'FlutterChat',
//       theme: ThemeData().copyWith(
//         useMaterial3: true,
//         colorScheme: ColorScheme.fromSeed(
//             seedColor: const Color.fromARGB(255, 63, 17, 177)),
//       ),
//       home: FutureBuilder<bool>(
//         future: getUserIsNewStatus(),
//         builder: (ctx, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const SplashScreen();
//           }
//           if (snapshot.hasData && FirebaseAuth.instance.currentUser != null) {
//             final bool isNewUser = snapshot.data!;
//             if (isNewUser) {
//               return const FormQuestionListScreen();
//             }
//             if (!isNewUser) {
//               return const HomeScreen();
//             }
//           }
//           return const AuthScreen();
//         },
//       ),
//     );
//   }
// }

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  late StreamController<bool> _userStatusController;

  @override
  void initState() {
    super.initState();
    _userStatusController = StreamController<bool>();

    // Call your asynchronous function and add the result to the stream
    getUserIsNewStatus().then((isNewUser) {
      _userStatusController.add(isNewUser);
    });
  }

  Future<bool> getUserIsNewStatus() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        await user.reload(); // Refresh user data, including metadata
        await user.getIdToken(); // Refresh user token to get the latest claims

        // Check if the user was created recently (e.g., within the last 1 minute)
        final creationTime = user.metadata.creationTime;
        final currentTime = DateTime.now();
        final timeDifference = currentTime.difference(creationTime!);

        // Updated threshold to 1 minute
        const maxNewUserAge = Duration(minutes: 1);

        return timeDifference <= maxNewUserAge;
      }
    } catch (e) {
      print('Error getting user data: $e');
    }

    // Default to false if there was an error or if the user is not logged in
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlutterChat',
      theme: ThemeData().copyWith(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 63, 17, 177),
        ),
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SplashScreen();
          }

          final user = snapshot.data;
          if (user != null) {
            return FutureBuilder<bool>(
              future: getUserIsNewStatus(),
              builder: (ctx, isNewUserSnapshot) {
                if (isNewUserSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const SplashScreen();
                }

                final isNewUser = isNewUserSnapshot.data ?? false;

                if (isNewUser) {
                  return const FormQuestionListScreen();
                } else {
                  return const HomeScreen();
                }
              },
            );
          } else {
            // User is not logged in
            return const AuthScreen(); // Replace AuthScreen with your login screen widget
          }
        },
      ),
    );
  }
}
