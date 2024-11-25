import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codepunk/Mode/User/Widgets/GlobalCountDown.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProblemStatementPage extends StatefulWidget {
  const ProblemStatementPage({super.key});

  @override
  State<ProblemStatementPage> createState() => _ProblemStatementPageState();
}

class _ProblemStatementPageState extends State<ProblemStatementPage> {
  String? currentUserId = FirebaseAuth.instance.currentUser?.email
      .toString()
      .replaceAll("@droid.com", "");

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Prevent back navigation
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Problem Statements",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.blueAccent,
        ),
        body: Stack(
          children: [
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('ProblemStatements')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final problemStatements = snapshot.data?.docs ?? [];
                final selectedProblems = problemStatements
                    .where((problem) => problem['lockedBy'] == currentUserId)
                    .toList();
                final otherProblems = problemStatements
                    .where((problem) => problem['lockedBy'] != currentUserId)
                    .toList();
                final sortedProblems = [...selectedProblems, ...otherProblems];

                return ListView.builder(
                  itemCount: sortedProblems.length,
                  itemBuilder: (context, index) {
                    final problem = sortedProblems[index];
                    final isLocked = problem["isLocked"] ?? false;
                    final lockedBy = problem["lockedBy"];
                    final isSelected = lockedBy == currentUserId;

                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                        color: isSelected ? Colors.blue.shade50 : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: isSelected ? Colors.blueAccent : Colors.grey,
                            width: isSelected ? 2.0 : 1.0,
                          ),
                        ),
                        elevation: isSelected ? 8 : 5,
                        child: ExpansionTile(
                          leading: Icon(
                            isLocked ? Icons.lock : Icons.lock_open,
                            color: isLocked ? Colors.red : Colors.green,
                          ),
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
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Text('PSID:',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      const SizedBox(width: 8),
                                      Text(problem['psid'] ?? 'No PSID',
                                          style: const TextStyle(
                                              color: Colors.blue)),
                                    ],
                                  ),
                                  const Divider(thickness: 1, height: 16),
                                  Row(
                                    children: [
                                      const Text('Title:',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      const SizedBox(width: 8),
                                      Flexible(
                                          child: Text(
                                              problem['title'] ?? 'No Title',
                                              style: const TextStyle(
                                                  color: Colors.black))),
                                    ],
                                  ),
                                  const Divider(thickness: 1, height: 16),
                                  const Text('Details:',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 4),
                                  Text(
                                      problem['details'] ??
                                          'No details available',
                                      style:
                                      const TextStyle(color: Colors.grey)),
                                  const Divider(thickness: 1, height: 16),
                                  Row(
                                    children: [
                                      const Text('Locked By:',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      const SizedBox(width: 8),
                                      Text(problem['lockedBy'] ?? 'None',
                                          style: const TextStyle(
                                              color: Colors.orange)),
                                    ],
                                  ),
                                  const Divider(thickness: 1, height: 16),
                                  Row(
                                    children: [
                                      const Text('Locked:',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      const SizedBox(width: 8),
                                      Icon(
                                          isLocked
                                              ? Icons.lock
                                              : Icons.lock_open,
                                          color: isLocked
                                              ? Colors.red
                                              : Colors.green),
                                      const SizedBox(width: 4),
                                      Text(isLocked ? 'Yes' : 'No',
                                          style: TextStyle(
                                              color: isLocked
                                                  ? Colors.red
                                                  : Colors.green,
                                              fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  if (!isLocked) ...[
                                    ElevatedButton.icon(
                                      onPressed: isSelected
                                          ? null
                                          : () async {
                                        if (await _checkIfUserHasLockedProblem()) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(const SnackBar(
                                              content: Text(
                                                  "You can only select one problem at a time.")));
                                        } else {
                                          await lockProblemStatement(
                                              problem.id);
                                          setState(() {}); // Update UI
                                        }
                                      },
                                      icon: const Icon(Icons.lock,
                                          color: Colors.white),
                                      label: const Text("Select this Problem",
                                          style:
                                          TextStyle(color: Colors.white)),
                                      style: ElevatedButton.styleFrom(
                                        elevation: 4,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                            BorderRadius.circular(8)),
                                        backgroundColor: Colors.blueAccent,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 12, horizontal: 20),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
            // Floating Global Countdown
            Positioned(
              bottom: 16,
              right: 16,
              child: Container(
                height: 60,
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
                ),
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: const GlobalCountDown(), // Your custom countdown widget
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> lockProblemStatement(String problemId) async {
    try {
      final problemDoc = FirebaseFirestore.instance
          .collection('ProblemStatements')
          .doc(problemId);
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(problemDoc);
        if (!snapshot.exists)
          throw Exception("Problem statement does not exist");
        if (snapshot["isLocked"] == true)
          throw Exception("This problem is already locked by another user.");
        transaction.update(problemDoc, {
          "isLocked": true,
          "lockedBy": currentUserId,
        });
      });
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error locking problem: $e")));
    }
  }

  Future<bool> _checkIfUserHasLockedProblem() async {
    try {
      final result = await FirebaseFirestore.instance
          .collection('ProblemStatements')
          .where("lockedBy", isEqualTo: currentUserId)
          .where("isLocked", isEqualTo: true)
          .limit(1)
          .get();

      return result.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}
