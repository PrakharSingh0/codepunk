import 'dart:async'; // Import Timer
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codepunk/Mode/User/Pages/RiddlePage.dart';
import 'package:codepunk/Mode/User/Widgets/userDetailWidget.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'package:flutter/material.dart';

class rsvpPage extends StatefulWidget {
  const rsvpPage({super.key});

  @override
  _rsvpPageState createState() => _rsvpPageState();
}

class _rsvpPageState extends State<rsvpPage> {
  late DateTime eventStartTime;
  late Duration remainingTime;
  Timer? _timer; // Nullable to avoid unnecessary calls
  bool isTimerStarted = false;
  bool isTimeEnded = false; // Flag to check if time has ended
  bool isLoading = true; // Flag for loading state

  @override
  void initState() {
    super.initState();
    _fetchEventData();
  }

  // Fetch event start timestamp using snapshot for real-time updates
  void _fetchEventData() {
    FirebaseFirestore.instance
        .collection('eventTiming')
        .doc('1sVOLXflwzOlTM8ZrhYt')
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        Timestamp eventTimestamp =
            snapshot['startTime']; // Timestamp field in Firestore
        eventStartTime = eventTimestamp.toDate();

        setState(() {
          remainingTime = eventStartTime.difference(DateTime.now());
          isTimerStarted = true;
          isLoading = false; // Stop loading after data is fetched
          isTimeEnded =
              remainingTime <= Duration.zero; // Check time immediately
        });

        // Start the countdown timer only if the event hasn't ended
        if (!isTimeEnded) {
          _startCountdown();
        } else {
          // Ensure remaining time stays at zero when time is over
          setState(() {
            remainingTime = Duration.zero;
          });
        }
      } else {
        // Handle case where event data doesn't exist
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Event data not found!')),
        );
      }
    });
  }

  // Starts the countdown timer and updates every second
  void _startCountdown() {
    _timer?.cancel(); // Cancel any previous timer if running
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        remainingTime = eventStartTime.difference(DateTime.now());
        if (remainingTime <= Duration.zero) {
          remainingTime = Duration.zero;
          isTimeEnded = true; // Set the flag when time ends
          _timer?.cancel(); // Stop the timer when it hits zero
        }
      });
    });
  }

  // Format the duration to hh:mm:ss format
  String formatDuration(Duration duration) {
    return '${duration.inHours.toString().padLeft(2, '0')}:${(duration.inMinutes % 60).toString().padLeft(2, '0')}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  // Handle RSVP button press
  Future<void> _handleRSVP() async {
    // Get the current user email from FirebaseAuth
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String userEmail =
          user.email ?? 'Unknown'; // Default to 'Unknown' if no email exists
      DateTime timestamp = DateTime.now(); // Current timestamp

      // Reference to the Firestore collection
      CollectionReference rsvpCollection =
          FirebaseFirestore.instance.collection('rsvp');

      // Check if an RSVP already exists for the user
      QuerySnapshot querySnapshot =
          await rsvpCollection.where('teamID', isEqualTo: userEmail).get();

      if (querySnapshot.docs.isNotEmpty) {
        // If RSVP exists, update the timestamp
        String docId = querySnapshot.docs.first.id; // Get the document ID
        await rsvpCollection.doc(docId).update({
          'timestamp': timestamp, // Update the timestamp
          'isPresent': true, // Ensure user presence is marked
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('RSVP updated successfully!')),
        );
      } else {
        // If RSVP doesn't exist, create a new one
        await rsvpCollection.add({
          'teamID': userEmail,
          'timestamp': timestamp,
          'isPresent': true, // Store a bool value indicating user is present
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
      // Handle case where the user is not logged in
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to RSVP')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Return false to prevent the back action
        return false;
      },
      child: Scaffold(
        body: Stack(children: [
          Center(
            child: Container(
              height: 350,
              decoration: const BoxDecoration(
                  color: Color.fromRGBO(0, 0, 0, .75),
                  borderRadius: BorderRadius.all(Radius.circular(20))),
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  SizedBox(child: userDetailWidget()),
                  const Text(
                    "You are participating in the CodePunk event held by Driod Club.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20, color: Colors.orange),
                  ),
                  const SizedBox(height: 50),
                  isLoading
                      ? const CircularProgressIndicator() // Loading state
                      : Column(
                          children: [
                            // Show the countdown timer
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  isTimerStarted
                                      ? 'Event Starts In :'
                                      : 'Loading...',
                                  style: const TextStyle(
                                      fontSize: 30, color: Colors.white),
                                ),
                                const SizedBox(width: 10), // Add some spacing
                                Text(
                                  isTimerStarted
                                      ? formatDuration(remainingTime)
                                      : 'Loading...',
                                  style: const TextStyle(
                                      fontSize: 30, color: Colors.white),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            // RSVP Button (enabled when time ends)
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(200, 50),
                                backgroundColor: isTimeEnded
                                    ? Colors.orange
                                    : Colors.grey, // Color when disabled
                              ),
                              onPressed: isTimeEnded
                                  ? _handleRSVP // Call _handleRSVP when time ends
                                  : null, // Disable button until the time ends
                              child: const Text(
                                "I, RSVP",
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                          ],
                        ),
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }

  @override
  void dispose() {
    // Dispose the timer when the widget is disposed
    _timer?.cancel();
    super.dispose();
  }
}
