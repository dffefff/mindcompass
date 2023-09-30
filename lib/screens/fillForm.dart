import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FillFromScreen extends StatefulWidget {
  const FillFromScreen({super.key});

  @override
  State<FillFromScreen> createState() => _FillFromScreenState();
}

class _FillFromScreenState extends State<FillFromScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Map<String, dynamic>? userData;
  Map<String, String> answers = {};

  @override
  void initState() {
    super.initState();
    getUserInfo().then((data) {
      print(data!['questions']);
      setState(() {
        userData = data;
      });
    });
  }

  void _submitDailyForm() async {
    if (answers.isEmpty) {
      return;
    }

    final user = FirebaseAuth.instance.currentUser!;

    try {
      await FirebaseFirestore.instance.collection('answers').doc(user.uid).set({
        'answers': answers,
        'createdAt': Timestamp.now(),
        'userId': user.uid,
      });

      Navigator.pop(context);
    } catch (e) {
      print('Error adding data to Firestore: $e');
    }
  }

  Future<User?> getCurrentUser() async {
    return _auth.currentUser;
  }

  Future<Map<String, dynamic>?> getUserData(String userId) async {
    try {
      DocumentSnapshot userDataSnapshot =
          await _firestore.collection('questions').doc(userId).get();
      if (userDataSnapshot.exists) {
        print(userDataSnapshot.data());
        return userDataSnapshot.data() as Map<String, dynamic>;
      } else {
        return null;
      }
    } catch (e) {
      print("Error getting user data: $e");
      return null;
    }
  }

  Future<Map<String, dynamic>?> getUserInfo() async {
    try {
      User? user = await getCurrentUser();
      if (user != null) {
        String userId = user.uid;
        return await getUserData(userId);
      } else {
        return null;
      }
    } catch (e) {
      print("Error getting user info: $e");
      return null;
    }
  }

  Widget buildForm(List<String> questions) {
    return ListView.builder(
      itemCount: questions.length,
      itemBuilder: (context, index) {
        final question = questions[index];

        return ListTile(
          title: Text(question),
          subtitle: TextFormField(
            onChanged: (value) {
              answers[question] = value;
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fill the form'),
      ),
      body: userData != null
          ? Column(
              children: [
                Expanded(
                  child: buildForm(
                    (userData!['questions'] as List<dynamic>).cast<String>(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ElevatedButton(
                    onPressed: _submitDailyForm,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16.0),
                      minimumSize: const Size(double.infinity, 48.0),
                    ),
                    child: const Text('Finish'),
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
              ],
            )
          : const CircularProgressIndicator(),
    );
  }
}
