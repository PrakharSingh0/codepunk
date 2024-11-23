import 'package:codepunk/backgroundWidget.dart';
import 'package:codepunk/pages/authPages/logInPage.dart';
import 'package:codepunk/pages/userMode/rsvpPage.dart';
import 'package:flutter/material.dart';

class welcomePage extends StatelessWidget {
  const welcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const backgroundWidget(),
          Center(
            child: 
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text("Welcome To CodePunk",style: TextStyle(color: Colors.white,fontSize: 32),),
              ElevatedButton(onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const rsvpPage() ));
              }, child: const Text("Click me "))
              ],
            ),
          )
        ],
      ),
    );
    
  }
}
