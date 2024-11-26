import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codepunk/Mode/User/Pages/RiddlePage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class rsvpPage extends StatefulWidget {
  const rsvpPage({super.key});

  @override
  _rsvpPageState createState() => _rsvpPageState();
}

class _rsvpPageState extends State<rsvpPage> {
  late DateTime eventStartTime;
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
        .doc('1sVOLXflwzOlTM8ZrhYt')
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        Timestamp eventTimestamp = snapshot['startTime'];
        eventStartTime = eventTimestamp.toDate();

        setState(() {
          remainingTime = eventStartTime.difference(DateTime.now());
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
        remainingTime = eventStartTime.difference(DateTime.now());
        if (remainingTime <= Duration.zero) {
          remainingTime = Duration.zero;
          isTimeEnded = true;
          _timer?.cancel();
        }
      });
    });
  }

  String formatDuration(Duration duration) {
    return '${duration.inHours.toString().padLeft(2, '0')}:${(duration.inMinutes % 60).toString().padLeft(2, '0')}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  Future<void> _handleRSVP() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String userEmail = user.email ?? 'Unknown';
      DateTime timestamp = DateTime.now();
      CollectionReference rsvpCollection =
      FirebaseFirestore.instance.collection('rsvp');

      QuerySnapshot querySnapshot =
      await rsvpCollection.where('teamID', isEqualTo: userEmail).get();

      if (querySnapshot.docs.isNotEmpty) {
        String docId = querySnapshot.docs.first.id;
        await rsvpCollection.doc(docId).update({
          'timestamp': timestamp,
          'isPresent': true,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('RSVP updated successfully!')),
        );
      } else {
        await rsvpCollection.add({
          'teamID': userEmail,
          'timestamp': timestamp,
          'isPresent': true,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('RSVP submitted successfully!')),
        );
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const RiddlePage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to RSVP')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false; // Prevent back action
      },
      child: Scaffold(
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
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "RSVP",
                    style: TextStyle(
                      fontSize: 50,
                      color: Colors.cyanAccent,
                      fontFamily: 'Orbitron', // Cyberpunk font
                      fontWeight: FontWeight.bold,
                      letterSpacing: 3,
                      shadows: [
                        Shadow(blurRadius: 10, color: Colors.cyan, offset: Offset(0, 0)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity, // Make width flexible
                    constraints: const BoxConstraints(maxWidth: 400), // Maximum width constraint
                    decoration: BoxDecoration(
                      border: Border.all(width: 1, color: Colors.cyanAccent),
                      borderRadius: const BorderRadius.all(Radius.circular(40)),
                      gradient: LinearGradient(
                        colors: [Colors.black.withOpacity(0.8), Colors.blueGrey.withOpacity(0.3)],
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
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          isLoading
                              ? const CircularProgressIndicator()
                              : Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.access_time_filled,
                                    color: Colors.cyanAccent,
                                    size: 36,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    isTimerStarted
                                        ? 'Event Starts In :'
                                        : 'Loading...',
                                    style: const TextStyle(
                                      fontSize: 22,
                                      color: Colors.cyanAccent,
                                      fontFamily: 'Orbitron',
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    isTimerStarted
                                        ? formatDuration(remainingTime)
                                        : 'Loading...',
                                    style: const TextStyle(
                                      fontSize: 22,
                                      color: Colors.cyanAccent,
                                      fontFamily: 'Orbitron',
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 40),
                              const Text(
                                "Confirm your participation in CodePunk V.1 and get ready for an unforgettable experience! By proceeding, you're officially joining the Droid Club event.",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.orangeAccent,
                                  fontFamily: 'RobotoMono',
                                ),
                              ),
                              const SizedBox(height: 40),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size(220, 60),
                                  backgroundColor: isTimeEnded
                                      ? Colors.cyanAccent
                                      : Colors.grey,
                                  shadowColor:
                                  Colors.cyanAccent.withOpacity(0.5),
                                  elevation: 15,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30)),
                                ),
                                onPressed: isTimeEnded ? _handleRSVP : null,
                                child: const Text(
                                  "I, RSVP",
                                  style: TextStyle(
                                      fontSize: 20, color: Colors.black, fontFamily: 'Orbitron'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
