import 'package:flutter/material.dart';

class eventEndPage extends StatefulWidget {
  const eventEndPage({super.key});

  @override
  State<eventEndPage> createState() => _eventEndPageState();
}

class _eventEndPageState extends State<eventEndPage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text("Event Ended, Thanks for Joining"),
      ),
    );
  }
}
