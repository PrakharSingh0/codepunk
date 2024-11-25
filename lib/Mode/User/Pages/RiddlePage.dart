import 'dart:async'; // Import for Timer
import 'dart:math'; // Import for random number generation
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:codepunk/Mode/User/Pages/ProblemStatementPage.dart';


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

  Timer? countdownTimer;
  Duration countdownDuration = Duration.zero; // Remaining time
  DateTime? endTime; // End time fetched from Firestore

  @override
  void initState() {
    super.initState();
    fetchRiddle(); // Fetch the riddle from Firestore
    fetchEndTime(); // Fetch the countdown end time from Firestore
  }

  @override
  void dispose() {
    countdownTimer?.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  // Fetch the countdown end time from Firestore
  Future<void> fetchEndTime() async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('eventTiming')
          .doc('1sVOLXflwzOlTM8ZrhYt')
          .get();

      if (snapshot.exists) {
        Timestamp firestoreEndTime = snapshot['startTime'];
        DateTime time = firestoreEndTime.toDate();
        endTime = time.add(const Duration(minutes: 20));

        startCountdown(); // Start the countdown timer
      } else {
        setState(() {
          errorMessage = 'Countdown end time not found.';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching countdown: $e';
      });
    }
  }

  // Start the countdown timer
  void startCountdown() {
    if (endTime == null) return;

    countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final now = DateTime.now();
      final remaining = endTime!.difference(now);

      if (remaining.isNegative) {
        timer.cancel();
        // Redirect to ProblemStatementPage when the countdown ends
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ProblemStatementPage()),
        );
      } else {
        setState(() {
          countdownDuration = remaining;
        });
      }
    });
  }

  // Fetch riddle data from Firestore
  Future<void> fetchRiddle() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('RiddlesQues')
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var randomDoc =
        querySnapshot.docs[Random().nextInt(querySnapshot.docs.length)];

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
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ProblemStatementPage()),
      );
    } else {
      setState(() {
        errorMessage = 'Incorrect answer. Try again!';
      });
    }
  }

  // Format the remaining time as MM:SS
  String formatTime(Duration duration) {
    String minutes = duration.inMinutes.toString().padLeft(2, '0');
    String seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Riddle Time')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 50),
            // Countdown Timer Display
            Text(
              "Time Remaining: ${formatTime(countdownDuration)}",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 20),
            // Display the riddle question
            Text(
              question ?? 'Loading question...',
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TextField(
              onTap: () => setState(() => errorMessage = ''),
              onChanged: (value) => setState(() => userAnswer = value),
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
}
