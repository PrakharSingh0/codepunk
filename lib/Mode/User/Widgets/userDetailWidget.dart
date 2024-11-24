import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class userDetailWidget extends StatelessWidget {
  userDetailWidget({super.key});

  final String? userName =FirebaseAuth.instance.currentUser?.email;

  @override
  Widget build(BuildContext context) {
    return  Container(
      decoration: const BoxDecoration(
        color: Colors.blueGrey
      ),

      height: 80,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('User : $userName',style: const TextStyle(fontSize:18,color: Colors.white),),
            Text('Riddle Status : $userName',style: const TextStyle(fontSize:18,color: Colors.white),),
            Text('Problem ID : $userName',style: const TextStyle(fontSize:18,color: Colors.white),),
          ],
        ),
      ),
    );

  }
}
