import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:codepunk/backgroundWidget.dart';
import 'package:codepunk/pages/userMode/problemStatementPage.dart';
import 'dart:async';
import 'dart:math';

class puzzlePage extends StatefulWidget {
  const puzzlePage({super.key});

  @override
  State<puzzlePage> createState() => _puzzlePageState();
}

class _puzzlePageState extends State<puzzlePage> {
  final TextEditingController _answerController = TextEditingController();
  String _correctAnswer = "";
  String _errorMessage = "";
  String _question = "";
  bool _isLoading = true;

  Timer? _timer;
  int _remainingTime = 70;

  @override
  void initState() {
    super.initState();
    _fetchPuzzleQuestion();
    _startTimer();
  }

  Future<void> _fetchPuzzleQuestion() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      setState(() {
        _errorMessage = "No internet connection.";
        _isLoading = false;
      });
      return;
    }

    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Puzzle')
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        int randomIndex = Random().nextInt(querySnapshot.docs.length);
        DocumentSnapshot doc = querySnapshot.docs[randomIndex];

        setState(() {
          _question = doc['Puzzle_Question'];
          _correctAnswer = doc['Puzzle_Answer'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _question = "No questions available.";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Failed to load question: $e";
        _isLoading = false;
      });
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        setState(() {
          _remainingTime--;
        });
      } else {
        timer.cancel();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const problemStatementPage()),
        );
      }
    });
  }

  void _checkAnswer() async {
    var connectivityResult = await (Connectivity().checkConnectivity());

    if (connectivityResult == ConnectivityResult.none) {
      _showNoConnectionDialog();
      return;
    }

    if (_answerController.text.trim().toLowerCase() == _correctAnswer.toLowerCase()) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const problemStatementPage()),
      );
    } else {
      setState(() {
        _errorMessage = "Incorrect answer. Please try again.";
        _answerController.clear();
      });
    }
  }

  void _showNoConnectionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Connection Error"),
          content: const Text("No internet connection, please try again."),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _fetchPuzzleQuestion();
              },
              child: const Text("Refresh"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  void _resetErrorMessage() {
    setState(() {
      _errorMessage = "";
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String getFormattedTime(int totalSeconds) {
    int minutes = totalSeconds ~/ 60;
    int seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        const backgroundWidget(),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isLoading)
                const CircularProgressIndicator()
              else if (_question.isNotEmpty)
                Text(
                  _question,
                  style: const TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                )
              else
                const Text(
                  "Error loading question.",
                  style: TextStyle(fontSize: 18, color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 20),
              TextField(
                controller: _answerController,
                decoration: InputDecoration(
                  labelText: 'Your Answer',
                  errorText: _errorMessage.isNotEmpty ? _errorMessage : null,
                ),
                onTap: _resetErrorMessage,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _checkAnswer,
                child: const Text('Submit'),
              ),
            ],
          ),
        ),

        Positioned(
          top: 40,
          right: 20,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            color: Colors.black54,
            child: Text(
              'Time Left: ${getFormattedTime(_remainingTime)}',
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ),
      ]),
    );
  }
}