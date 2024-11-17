import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codepunk/backgroundWidget.dart';
import 'package:codepunk/pages/userMode/eventEndPage.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class countDownPage extends StatefulWidget {
  final String psid;
  final String problemStatement;

  const countDownPage(
      {super.key, required this.psid, required this.problemStatement});

  @override
  State<countDownPage> createState() => _countDownPageState();
}

class _countDownPageState extends State<countDownPage> {
  late Timer _timer; // Timer for countdown
  late Timer _statusCheckTimer; // Timer for checking status
  int _start = 10; // Default countdown time
  bool _shouldStartTimer = false; // Flag to check if timer should start

  @override
  void initState() {
    super.initState();
    _checkTimerStatus(); // Initial check for timer status
    _startStatusCheckTimer(); // Start checking status every 5 seconds
  }

  void _startStatusCheckTimer() {
    _statusCheckTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      _checkTimerStatus(); // Check the timer status from Firestore every 5 seconds
    });
  }

  Future<void> _checkTimerStatus() async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('Timer')
        .doc('iVAV5v7wlQN86fahDEol') // Replace with your document ID
        .get();

    if (snapshot.exists) {
      bool startField = snapshot['Start'] ?? false; // Default to false if not found
      if (startField && !_shouldStartTimer) {
        _shouldStartTimer = true; // Start timer only if startField is true
        _startTimer(); // Start the countdown timer
      } else if (!startField) {
        // Handle case where startField is false (e.g., show a message)
        setState(() {
          _shouldStartTimer = false; // Ensure timer does not start
        });
      }
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_start > 0) {
        setState(() {
          _start--;
        });
      } else {
        _timer.cancel();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const eventEndPage()),
        );
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _statusCheckTimer.cancel(); // Cancel status check timer when disposing
    super.dispose();
  }

  String get timerString {
    Duration duration = Duration(seconds: _start);
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String hours = twoDigits(duration.inHours.remainder(24));
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));

    return "$hours:$minutes:$seconds";
  }

  double get progress => (_start / 10);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        //const BackgroundWidget(),
        Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_shouldStartTimer) ...[
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 200,
                        height: 200,
                        child: CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 10,
                          backgroundColor: Colors.grey[300],
                          valueColor:
                          const AlwaysStoppedAnimation<Color>(Colors.orangeAccent),
                        ),
                      ),
                      Text(
                        timerString,
                        style:
                        const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'PSID: ${widget.psid}\n',
                        style: const TextStyle(
                          fontSize: 20,
                        ),
                        textAlign: TextAlign.left,
                      ),
                      Text(
                        'Problem Statement: ${widget.problemStatement}',
                        style: const TextStyle(fontSize: 20),
                      ),
                    ],
                  ),
                ] else ...[
                  const Text("The timer cannot start yet.", style: TextStyle(fontSize: 20)),
                ],
              ],
            )),
      ]),
    );
  }
}