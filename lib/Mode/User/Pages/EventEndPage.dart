import 'package:flutter/material.dart';

class EventEndPage extends StatelessWidget {
  const EventEndPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2C), // Dark Cyberpunk Background
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Glowing Icon
              Icon(
                Icons.warning_amber_rounded,
                size: 120,
                color: Colors.cyanAccent.withOpacity(0.8),
                shadows: const [
                  Shadow(
                    blurRadius: 20,
                    color: Colors.cyanAccent,
                    offset: Offset(0, 0),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Title Text
              Text(
                'The event has ended!',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.cyanAccent,
                  fontFamily: 'Orbitron',
                  shadows: [
                    Shadow(
                      blurRadius: 10.0,
                      color: Colors.cyanAccent,
                      offset: Offset(0, 0),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              // Exit Button
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(
                  Icons.exit_to_app,
                  color: Colors.black,
                ),
                label: const Text(
                  'Exit',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purpleAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                      vertical: 14, horizontal: 40),
                  shadowColor: Colors.purpleAccent,
                  elevation: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
