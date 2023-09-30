import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mindcompass/screens/home.dart';

class FormQuestionListScreen extends StatefulWidget {
  const FormQuestionListScreen({super.key});

  @override
  State<FormQuestionListScreen> createState() => _FormQuestionListScreenState();
}

class _FormQuestionListScreenState extends State<FormQuestionListScreen> {
  List<TextEditingController> controllers = [];
  List<String> textList = [];
  bool canContinue = false;

  void updateContinueButtonState() {
    int nonEmptyFields = textList.where((text) => text.isNotEmpty).length;
    setState(() {
      canContinue = nonEmptyFields >= 3;
    });
  }

  void _submitQuestionForm() async {
    if (textList.isEmpty) {
      return;
    }

    final user = FirebaseAuth.instance.currentUser!;

    try {
      final docRef =
          await FirebaseFirestore.instance.collection('questions').add({
        'questions': textList,
        'createdAt': Timestamp.now(),
        'userId': user.uid,
      });

      if (docRef.id.isNotEmpty) {
        // Data added successfully
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (ctx) => const HomeScreen(),
          ),
        );
      } else {
        // Handle the case where data was not added successfully
        print('Data was not added to Firestore');
      }
    } catch (e) {
      // Handle any Firestore errors
      print('Error adding data to Firestore: $e');
    }
  }

  List<Widget> _buildTextFields() {
    List<Widget> fields = [];
    for (int index = 0; index < controllers.length; index++) {
      fields.add(
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Text('${index + 1}.'),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: controllers[index],
                  onChanged: (value) {
                    setState(() {
                      textList[index] = value;
                      updateContinueButtonState();
                    });
                  },
                  decoration: const InputDecoration(
                    hintText: 'Enter text',
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
    return fields;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create questions for you"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(10),
        children: [
          Column(
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize:
                      const Size(double.infinity, 48), // Full width button
                ),
                onPressed: () {
                  if (controllers.length < 8 &&
                      (controllers.isEmpty || textList.last.isNotEmpty)) {
                    setState(() {
                      controllers.add(TextEditingController());
                      textList.add('');
                    });
                  }
                },
                child: const Text('Create question'),
              ),
              ..._buildTextFields(),
              const SizedBox(
                height: 15,
              ),
              ElevatedButton.icon(
                onPressed: canContinue ? _submitQuestionForm : null,
                label: const Text('Continue'),
                icon: const Icon(Icons.arrow_right),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
