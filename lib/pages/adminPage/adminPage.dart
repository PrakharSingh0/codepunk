import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class adminPage extends StatelessWidget {
  const adminPage({super.key});

  Future<void> _startTimer() async {
    await FirebaseFirestore.instance
        .collection('Timer')
        .doc('iVAV5v7wlQN86fahDEol')
        .update({'Start': true});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Page'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            await _startTimer();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Timer has been started!')),
            );
          },
          child: const Text('Start Timer'),
        ),
      ),
    );
  }
}