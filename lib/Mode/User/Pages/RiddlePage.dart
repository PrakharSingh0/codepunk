import 'dart:math'; // Import dart:math for random number generation
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codepunk/Mode/User/Pages/ProblemStatementPage.dart';
import 'package:codepunk/Mode/User/Widgets/GlobalCountDown.dart';
import 'package:codepunk/Mode/User/Widgets/userDetailWidget.dart';
import 'package:flutter/material.dart';

class RiddlePage extends StatefulWidget {
  const RiddlePage({super.key});

  @override
  State<RiddlePage> createState() => _RiddlePageState();
}

class _RiddlePageState extends State<RiddlePage> {
  String? question;
  String? correctAnswer;
  String userAnswer = '';
  String errorMessage = '';
  bool isLoading = true;

  // Fetch riddle data from Firestore
  Future<void> fetchRiddle() async {
    try {
      // Fetch all documents from the 'RiddlesQues' collection
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('RiddlesQues')
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Randomly select a riddle from the fetched documents
        var randomDoc = querySnapshot.docs[Random().nextInt(querySnapshot.docs.length)];

        setState(() {
          question = randomDoc['riddle'];
          correctAnswer = randomDoc['answer'];
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'No riddles found.';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching riddles: $e';
        isLoading = false;
      });
    }
  }

  // Check if the answer is correct
  void checkAnswer() {
    if (userAnswer.trim().toLowerCase() == correctAnswer?.toLowerCase()) {
      // Answer is correct, proceed to next page
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ProblemStatementPage()),
      );
    } else {
      setState(() {
        errorMessage = 'Incorrect answer. Try again!';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchRiddle();  // Fetch riddle when the page is loaded
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Riddle Time')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator()) // Show loading indicator while fetching data
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            userDetailWidget(),
            SizedBox(height: 50,),
            GlobalCountDown(),
            // Display the riddle question
            Text(
              question ?? 'Loading question...',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TextField(
              onTap: _resetErrorMessage,
              onChanged: (value) {
                setState(() {
                  userAnswer = value;
                });
              },
              decoration: const InputDecoration(
                hintText: 'Your answer',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: checkAnswer,
              child: const Text('Submit Answer'),
            ),
            const SizedBox(height: 20),
            // Show error message if the answer is incorrect
            if (errorMessage.isNotEmpty)
              Text(
                errorMessage,
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
          ],
        ),
      ),
    );
  }
  void _resetErrorMessage() {
    setState(() {
      errorMessage = "";
    });
  }
}

