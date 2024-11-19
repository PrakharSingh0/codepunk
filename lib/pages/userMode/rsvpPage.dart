import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codepunk/backgroundWidget.dart';
import 'package:codepunk/pages/userMode/puzzlePage.dart';
import 'package:flutter/material.dart';

class rsvpPage extends StatelessWidget {
  const rsvpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        const backgroundWidget(),
        Center(
          child: Container(
            height: 300,
            decoration:
            const BoxDecoration(color: Color.fromRGBO(0, 0, 0, .75)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                const Text(
                  "This is here to inform you that you are participating in the CodePunk event held by Driod Club.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, color: Colors.orange),
                ),
                const SizedBox(height: 50),
                StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('Timer')
                      .doc('iVAV5v7wlQN86fahDEol')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const CircularProgressIndicator();
                    }

                    // Check if the timer has started
                    bool timerStarted = snapshot.data!['Start'] ?? false;

                    return ElevatedButton(
                      onPressed: timerStarted ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const puzzlePage()),
                        );
                      } : null, // Disable button if timer hasn't started
                      child: const Text("I, RSVP"),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ]),
    );
  }
}