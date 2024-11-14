import 'package:codepunk/backgroundWidget.dart';
import 'package:codepunk/pages/userMode/problemStatementPage.dart';
import 'package:flutter/material.dart';

class puzzlePage extends StatefulWidget {
  const puzzlePage({super.key});

  @override
  State<puzzlePage> createState() => _puzzlePageState();
}

class _puzzlePageState extends State<puzzlePage> {
  final TextEditingController _answerController = TextEditingController();
  final String _correctAnswer = "Gand";
  String _errorMessage = "";

  void _checkAnswer() {
    setState(() {
      if (_answerController.text.trim() == _correctAnswer) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const problemStatementPage()),
        );
      } else {
        _errorMessage = "Incorrect";
        _answerController.clear();
      }
    });
  }

  void _resetErrorMessage() {
    setState(() {
      _errorMessage = "";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        backgroundWidget(),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'What is the answer to life, the universe, and everything?',
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _answerController,
                decoration: InputDecoration(
                  labelText: 'Your Answer',
                  errorText: _errorMessage.isNotEmpty ? _errorMessage : null,
                ),
                onTap: _resetErrorMessage, // Reset error message on tap
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _checkAnswer,
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ]),
    );
  }
}
