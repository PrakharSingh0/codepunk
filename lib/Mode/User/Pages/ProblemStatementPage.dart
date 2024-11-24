import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codepunk/Mode/User/Widgets/GlobalCountDown.dart';
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
      onWillPop: () async => false, // Prevent back navigation
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Problem Statements"),
          backgroundColor: Colors.blueAccent,
        ),
        body: Stack(
          children: [
            StreamBuilder<QuerySnapshot>(
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

                // Separate the selected problem(s) and other problems
                final selectedProblems = problemStatements.where((problem) {
                  return problem['lockedBy'] == currentUserId;
                }).toList();

                final otherProblems = problemStatements.where((problem) {
                  return problem['lockedBy'] != currentUserId;
                }).toList();

                // Combine the lists: selected problems at the top
                final sortedProblems = [...selectedProblems, ...otherProblems];

                return ListView.builder(
                  itemCount: sortedProblems.length,
                  itemBuilder: (context, index) {
                    final problem = sortedProblems[index];
                    final isLocked = problem["isLocked"] ?? false;
                    final lockedBy = problem["lockedBy"];
                    final isSelected = lockedBy == currentUserId;

                    final isExpanded = expandedStates[problem.id] ?? false;

                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                        color: isSelected
                            ? Colors.blue.shade50 // Distinct background for the selected problem
                            : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(
                            color: isSelected ? Colors.blueAccent : Colors.grey,
                            width: isSelected ? 2.0 : 1.0,
                          ),
                        ),
                        elevation: isSelected ? 8 : 5, // Higher elevation for selected problem
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ListTile(
                              title: Text(
                                problem["title"],
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: isSelected ? Colors.blue : Colors.black,
                                ),
                              ),
                              leading: Icon(
                                isLocked ? Icons.lock : Icons.lock_open,
                                color: isLocked ? Colors.red : Colors.green,
                              ),
                              trailing: Icon(isExpanded
                                  ? Icons.arrow_drop_up
                                  : Icons.arrow_drop_down),
                              onTap: () {
                                setState(() {
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
                              if (!isLocked)
                                ElevatedButton(
                                  onPressed: isSelected
                                      ? null
                                      : () async {
                                    if (await _checkIfUserHasLockedProblem()) {
                                      ScaffoldMessenger.of(context).showSnackBar(
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
                                      ? const Text("You have selected this problem")
                                      : const Text("Select this Problem"),
                                ),
                              ElevatedButton(
                                onPressed: isSelected
                                    ? () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ProblemDetailsPage(
                                          problemId: problem.id),
                                    ),
                                  );
                                }
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                  isSelected ? Colors.green : Colors.grey,
                                ),
                                child: const Text("View Problem"),
                              ),
                              if (isLocked && !isSelected)
                                const Padding(
                                  padding: EdgeInsets.all(8.0),
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
            // Add the floating Global Countdown widget
            Positioned(
              bottom: 16,
              right: 16,
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.blueAccent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),padding: EdgeInsets.all(5),
                child: const GlobalCountDown(), // Your custom countdown widget
              ),
            ),
          ],
        ),
      ),
    );
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

      // Refresh UI after locking the problem
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error locking problem: $e")),
      );
    }
  }

  // Check if the user has already locked a problem
  Future<bool> _checkIfUserHasLockedProblem() async {
    try {
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
