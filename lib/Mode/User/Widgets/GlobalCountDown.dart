import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codepunk/Mode/User/Pages/EventEndPage.dart';
import 'package:flutter/material.dart';

class GlobalCountDown extends StatefulWidget {
  const GlobalCountDown({super.key});

  @override
  State<GlobalCountDown> createState() => _GlobalCountDownState();
}

class _GlobalCountDownState extends State<GlobalCountDown> {
  late DateTime eventEndTime;
  late Duration remainingTime;
  Timer? _timer;
  bool isTimerStarted = false;
  bool isTimeEnded = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchEventData();
  }

  void _fetchEventData() {
    FirebaseFirestore.instance
        .collection('eventTiming')
        .doc('1sVOLXflwzOlTM8ZrhYt') // Replace with actual doc ID
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        Timestamp eventTimestamp = snapshot['endTime'];
        eventEndTime = eventTimestamp.toDate();

        setState(() {
          remainingTime = eventEndTime.difference(DateTime.now());
          isTimerStarted = true;
          isLoading = false;
          isTimeEnded = remainingTime <= Duration.zero;
        });

        if (!isTimeEnded) {
          _startCountdown();
        } else {
          setState(() {
            remainingTime = Duration.zero;
          });
          _redirectToEndPage(); // Redirect immediately if time is already over
        }
      } else {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Event data not found!')),
        );
      }
    });
  }

  void _startCountdown() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        remainingTime = eventEndTime.difference(DateTime.now());
        if (remainingTime <= Duration.zero) {
          remainingTime = Duration.zero;
          isTimeEnded = true;
          _timer?.cancel();
          _redirectToEndPage(); // Redirect when time ends
        }
      });
    });
  }

  void _redirectToEndPage() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const EventEndPage()),
    );
  }

  String formatDuration(Duration duration) {
    return '${duration.inHours.toString().padLeft(2, '0')}:${(duration.inMinutes % 60).toString().padLeft(2, '0')}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          color: Colors.blueAccent,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
                blurRadius: 8, color: Colors.black26, offset: Offset(0, 4))
          ],
        ),
        child: isLoading
            ? const Center(
                child:
                    CircularProgressIndicator()) // Show loading indicator while fetching data
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isTimerStarted ? 'Event Ends In:' : 'Loading...',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(
                      width: 10), // Add spacing between the text elements
                  Text(
                    isTimerStarted
                        ? formatDuration(remainingTime)
                        : 'Loading...',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ));
  }
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
