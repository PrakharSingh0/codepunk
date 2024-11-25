import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codepunk/Auth/LoginScreen.dart';
import 'package:codepunk/Mode/User/Pages/RSVP.dart';
import 'package:flutter/material.dart';

import 'Mode/User/Pages/EventEndPage.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  // Function to check event's end time
  Future<void> checkEventEndTime(BuildContext context) async {
    try {
      // Fetch the event's end time from Firestore
      DocumentSnapshot eventDoc = await FirebaseFirestore.instance
          .collection('eventTiming')  // Replace with your collection
          .doc('1sVOLXflwzOlTM8ZrhYt')  // Replace with the actual document ID
          .get();

      if (eventDoc.exists) {
        // Get the event's end time and compare it with the current time
        Timestamp eventEndTimestamp = eventDoc['endTime'];  // 'time' is the field storing the end time
        DateTime eventEndTime = eventEndTimestamp.toDate();

        if (eventEndTime.isBefore(DateTime.now())) {
          // If the event time has passed, navigate to the EndPage
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const EventEndPage()),
          );
        } else {
          // If event time hasn't passed, navigate to the RSVP page
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        }
      } else {
        // If no event data found in Firestore, show an error message or handle it appropriately
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Event data not found!')),
        );
      }
    } catch (e) {
      // Handle errors such as Firestore fetch issues
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.blueAccent,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Welcome To CodePunk",
                style: TextStyle(color: Colors.white, fontSize: 32),
              ),
              ElevatedButton(
                onPressed: () {
                  // Check event end time and navigate accordingly
                  checkEventEndTime(context);
                },
                child: const Text("Click me"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
