import 'dart:async';
import 'dart:math';
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
  Duration countdownDuration = Duration.zero;
  DateTime? endTime;

  @override
  void initState() {
    super.initState();
    fetchRiddle();
    fetchEndTime();
  }

  @override
  void dispose() {
    countdownTimer?.cancel();
    super.dispose();
  }

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

        startCountdown();
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

  void startCountdown() {
    if (endTime == null) return;

    countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final now = DateTime.now();
      final remaining = endTime!.difference(now);

      if (remaining.isNegative) {
        timer.cancel();
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

  String formatTime(Duration duration) {
    String minutes = duration.inMinutes.toString().padLeft(2, '0');
    String seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF121212), Color(0xFF2E2E2E), Color(0xFF373737)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: [0.1, 0.6, 0.9],
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "RIDDLE TIME",
                style: TextStyle(
                  fontSize: 40,
                  color: Colors.cyanAccent,
                  fontFamily: 'Orbitron',
                  fontWeight: FontWeight.bold,
                  letterSpacing: 3,
                  shadows: [
                    Shadow(blurRadius: 10, color: Colors.cyan, offset: Offset(0, 0)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border.all(width: 1, color: Colors.cyanAccent),
                  borderRadius: const BorderRadius.all(Radius.circular(40)),
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.8),
                      Colors.blueGrey.withOpacity(0.3)
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.cyanAccent.withOpacity(0.3),
                      blurRadius: 10,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      "Time Remaining: ${formatTime(countdownDuration)}",
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                        fontFamily: 'Orbitron',
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      question ?? 'Loading question...',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.orangeAccent,
                        fontFamily: 'RobotoMono',
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      onTap: () => setState(() => errorMessage = ''),
                      onChanged: (value) => setState(() => userAnswer = value),
                      decoration: InputDecoration(
                        hintText: 'Your answer',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.1),
                        hintStyle: const TextStyle(color: Colors.white70),
                      ),
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(200, 50),
                        backgroundColor: Colors.cyanAccent,
                        shadowColor: Colors.cyanAccent.withOpacity(0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      onPressed: checkAnswer,
                      child: const Text(
                        'Submit Answer',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontFamily: 'Orbitron',
                        ),
                      ),
                    ),
                    if (errorMessage.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Text(
                          errorMessage,
                          style: const TextStyle(color: Colors.red, fontSize: 16),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
