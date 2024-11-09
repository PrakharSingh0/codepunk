import 'package:codepunk/pages/userMode/puzzlePage.dart';
import 'package:flutter/material.dart';

class rsvpPage extends StatelessWidget {
  const rsvpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(heightFactor: 20,
        child: Column(
          children: [
            const Text(
                "This is here is to inform you that you are participaring \n in the CodePunk event held by Driod Club"),
            const SizedBox(height: 20,),
            ElevatedButton(onPressed: () {
              Navigator.push(context,MaterialPageRoute(builder: (context)=>const puzzlePage()));
            }, child: const Text("I, RSVP"))
          ],
        ),
      ),
    );
  }
}
