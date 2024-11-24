import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ProblemDetailsPage extends StatefulWidget {
  final String problemId;

  const ProblemDetailsPage({super.key, required this.problemId});

  @override
  State<ProblemDetailsPage> createState() => _ProblemDetailsPageState();
}

class _ProblemDetailsPageState extends State<ProblemDetailsPage> {
  Map<String, dynamic>? problemDetails;

  @override
  void initState() {
    super.initState();
    fetchProblemDetails();
  }

  // Fetch problem details from Firestore
  Future<void> fetchProblemDetails() async {
    try {
      DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
          .collection('ProblemStatements')
          .doc(widget.problemId)
          .get();

      setState(() {
        problemDetails = docSnapshot.data() as Map<String, dynamic>;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching problem details: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Problem Details"),
          backgroundColor: Colors.blueAccent,
        ),
        body: problemDetails == null
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      problemDetails!["title"],
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      problemDetails!["details"],
                      style: const TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              ),

    );
  }
}
