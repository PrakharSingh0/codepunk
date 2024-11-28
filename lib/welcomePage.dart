import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:codepunk/Auth/LoginScreen.dart';
import 'package:codepunk/Mode/User/Pages/EventEndPage.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  // Function to check event's end time
  Future<void> checkEventEndTime(BuildContext context) async {
    try {
      DocumentSnapshot eventDoc = await FirebaseFirestore.instance
          .collection('eventTiming')
          .doc('1sVOLXflwzOlTM8ZrhYt')
          .get();

      if (eventDoc.exists) {
        Timestamp eventEndTimestamp = eventDoc['endTime'];
        DateTime eventEndTime = eventEndTimestamp.toDate();

        if (eventEndTime.isBefore(DateTime.now())) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const EventEndPage()),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Event data not found!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
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
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Icon with subtle neon effect
                const Icon(
                  Icons.computer,
                  color: Colors.cyanAccent,
                  size: 100,
                ),
                const SizedBox(height: 30),

                // Title with a clean neon glow effect
                const Text(
                  "Welcome to",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.cyanAccent,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'RobotoMono',
                    letterSpacing: 1.5,
                    shadows: [
                      Shadow(
                        offset: Offset(0, 0),
                        blurRadius: 8.0,
                        color: Color(0xFF00FFFF),
                      ),
                    ],
                  ),
                ),SizedBox(height: 10,),
                const Text(
                  "CODEPUNK",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.cyanAccent,
                    fontSize: 46,
                    fontWeight: FontWeight.normal,
                    fontFamily: 'MyCustomFont',
                    letterSpacing: 10,
                    shadows: [
                      Shadow(
                        offset: Offset(0, 0),
                        blurRadius: 8.0,
                        color: Color(0xFF00FFFF),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // Subtitle with clean, minimal styling
                const Text(
                  "A tech revolution awaits you.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 18,
                    fontFamily: 'RobotoMono',
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 40),

                // "Get Started" button with subtle glow
                ElevatedButton(
                  onPressed: () {
                    checkEventEndTime(context);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    backgroundColor: Colors.cyanAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    shadowColor: Colors.cyanAccent.withOpacity(0.5),
                    elevation: 10,
                  ),
                  child: const Text(
                    "Get Started",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Footer text with subtle, minimal styling
                const Text(
                  "Powered by Droid Club",
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 14,
                    fontFamily: 'RobotoMono',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
