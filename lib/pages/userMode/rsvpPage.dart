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
            // heightFactor: 20,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                const Text(
                  "This is here is to inform you that you are participating in the CodePunk event held by Driod Club.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, color: Colors.orange),
                ),
                const SizedBox(
                  height: 50,
                ),
                ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const puzzlePage()));
                    },
                    child: const Text("I, RSVP"))
              ],
            ),
          ),
        ),
      ]),
    );
  }
}
