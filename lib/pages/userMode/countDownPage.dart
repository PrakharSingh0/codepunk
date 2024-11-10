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
  late Timer _timer;
  int _start = 5;

  @override
  void initState() {
    super.initState();
    _startTimer();
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

  double get progress => (_start / 5);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Countdown Timer'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
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
        ],
      )),
    );
  }
}
