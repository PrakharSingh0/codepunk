import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'ProblemDetailsPage.dart';

class ProblemStatementPage extends StatefulWidget {
  const ProblemStatementPage({super.key});

  @override
  State<ProblemStatementPage> createState() => _ProblemStatementPageState();
}

class _ProblemStatementPageState extends State<ProblemStatementPage> {
  String? currentUserId = FirebaseAuth.instance.currentUser?.email;
  Map<String, bool> expandedStates = {}; // Store the expanded state locally

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          // Return false to prevent the back action
          return false;
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text("Problem Statements"),
            backgroundColor: Colors.blueAccent,
          ),
          body: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('ProblemStatements')
                .snapshots(), // Listen for real-time updates
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              final problemStatements = snapshot.data?.docs ?? [];

              return ListView.builder(
                itemCount: problemStatements.length,
                itemBuilder: (context, index) {
                  final problem = problemStatements[index];
                  final isLocked = problem["isLocked"] ?? false;
                  final lockedBy = problem["lockedBy"];
                  final isSelected = lockedBy == currentUserId;

                  // Get the expanded state from local map
                  final isExpanded = expandedStates[problem.id] ?? false;

                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 5,
                      child: Column(
                        children: [
                          ListTile(
                            title: Text(
                              problem["title"],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            leading: Icon(
                              isLocked
                                  ? Icons.lock // Locked icon
                                  : Icons.lock_open, // Unlocked icon
                              color: isLocked ? Colors.red : Colors.green,
                            ),
                            trailing: Icon(isExpanded
                                ? Icons.arrow_drop_up
                                : Icons.arrow_drop_down),
                            onTap: () {
                              setState(() {
                                // Toggle the expansion state locally
                                expandedStates[problem.id] = !isExpanded;
                              });
                            },
                          ),
                          if (isExpanded) ...[
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 8.0,
                              ),
                              child: Text(
                                problem["details"],
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                            // Display the Select button if the problem is not locked
                            if (!isLocked)
                              ElevatedButton(
                                onPressed: isSelected
                                    ? null
                                    : () async {
                                  if (await _checkIfUserHasLockedProblem()) {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            "You can only select one problem at a time."),
                                      ),
                                    );
                                  } else {
                                    lockProblemStatement(problem.id);
                                  }
                                },
                                child: isSelected
                                    ? const Text(
                                    "You have selected this problem")
                                    : const Text("Select this Problem"),
                              ),
                            // Show a message if the problem is already locked by the current user
                            if (isSelected)
                              const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  "You have selected this problem.",
                                  style: TextStyle(color: Colors.green),
                                ),
                              ),
                            // Display if the problem is already locked by someone else
                            if (isLocked && !isSelected)
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  "This problem is locked by another user.",
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ));
  }

  // Lock a problem statement for the current user
  Future<void> lockProblemStatement(String problemId) async {
    try {
      final problemDoc = FirebaseFirestore.instance
          .collection('ProblemStatements')
          .doc(problemId);

      FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(problemDoc);
        if (!snapshot.exists) {
          throw Exception("Problem statement does not exist");
        }

        // Check if the problem is already locked
        if (snapshot["isLocked"] == true) {
          throw Exception("This problem is already locked by another user.");
        }

        // Lock the problem
        transaction.update(problemDoc, {
          "isLocked": true,
          "lockedBy": currentUserId,
        });
      });

      // Redirect to the details page for the selected problem
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ProblemDetailsPage(problemId: problemId),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error locking problem: $e")),
      );
    }
  }

  // Check if the user has already locked a problem
  Future<bool> _checkIfUserHasLockedProblem() async {
    try {
      // Query to find if the user has already locked a problem
      final result = await FirebaseFirestore.instance
          .collection('ProblemStatements')
          .where("lockedBy", isEqualTo: currentUserId)
          .where("isLocked", isEqualTo: true)
          .limit(1)
          .get();

      return result.docs.isNotEmpty; // If any locked problem is found, return true
    } catch (e) {
      return false;
    }
  }
}
