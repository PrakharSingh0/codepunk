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
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Orbitron',
            ),
          ),
          backgroundColor: const Color(0xFF1E1E2C), // Dark background color
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1E1E2C), Color(0xFF232331)], // Previous page scheme
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('ProblemStatements')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Colors.pinkAccent,
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error: ${snapshot.error}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  }

                  final problemStatements = snapshot.data?.docs ?? [];

                  final selectedProblems = problemStatements.where((problem) {
                    return problem['lockedBy'] == currentUserId;
                  }).toList();

                  final otherProblems = problemStatements.where((problem) {
                    return problem['lockedBy'] != currentUserId;
                  }).toList();

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
                          color: isSelected
                              ? const Color(0xFF2A2A40)
                              : const Color(0xFF1E1E2C),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: isSelected
                                  ? Colors.blueAccent
                                  : Colors.grey[700]!,
                              width: isSelected ? 2.0 : 1.0,
                            ),
                          ),
                          elevation: isSelected ? 8 : 4,
                          child: ListTile(
                            title: Text(
                              problem["title"],
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: isSelected
                                    ? Colors.blueAccent
                                    : Colors.white,
                                fontFamily: 'Orbitron',
                              ),
                            ),
                            leading: Icon(
                              isLocked ? Icons.lock : Icons.lock_open,
                              color:
                              isLocked ? Colors.redAccent : Colors.greenAccent,
                              size: 30,
                            ),
                            onTap: () {
                              _showProblemDialog(context, problem);
                            },
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
              // Global Countdown Widget
              Positioned(
                bottom: 16,
                right: 16,
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E2C),
                    border: Border.all(color: Colors.pinkAccent, width: 1.5),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.pinkAccent.withOpacity(0.8),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: const GlobalCountDown(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showProblemDialog(BuildContext context, DocumentSnapshot problem) {
    final isLocked = problem["isLocked"] ?? false;
    final lockedBy = problem["lockedBy"];
    final isSelected = lockedBy == currentUserId;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E2C),
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Row(
            children: [
              Icon(Icons.info, color: Colors.pinkAccent),
              SizedBox(width: 8),
              Text(
                'Problem Details',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: 'Orbitron',
                ),
              ),
            ],
          ),
          content: SingleChildScrollView( // Fix for overflow
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'PSID:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      problem['psid'] ?? 'No PSID',
                      style: const TextStyle(color: Colors.pinkAccent),
                    ),
                  ],
                ),
                const Divider(thickness: 1, height: 16, color: Colors.grey),
                Row(
                  children: [
                    const Text(
                      'Title:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        problem['title'] ?? 'No Title',
                        style: const TextStyle(color: Colors.grey),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
                const Divider(thickness: 1, height: 16, color: Colors.grey),
                const Text(
                  'Details:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  problem['details'] ?? 'No details available',
                  style: const TextStyle(color: Colors.grey),
                ),
                const Divider(thickness: 1, height: 16, color: Colors.grey),
                Row(
                  children: [
                    const Text(
                      'Locked By:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      problem['lockedBy'] ?? 'None',
                      style: const TextStyle(color: Colors.orange),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            if (!isLocked) ...[
              ElevatedButton.icon(
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
                    Navigator.pop(context);
                  }
                },
                icon: const Icon(Icons.lock, color: Colors.white),
                label: const Text(
                  "Select this Problem",
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pinkAccent,
                ),
              ),
            ],
            if (isSelected) ...[
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProblemDetailsPage(
                        problemId: problem.id,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.visibility, color: Colors.white),
                label: const Text("View Problem"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.greenAccent,
                ),
              ),
            ],
            OutlinedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.close, color: Colors.grey),
              label: const Text(
                "Cancel",
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        );
      },
    );
  }

  void lockProblemStatement(String id) {
    FirebaseFirestore.instance.collection('ProblemStatements').doc(id).update({
      'isLocked': true,
      'lockedBy': currentUserId,
    });
  }

  Future<bool> _checkIfUserHasLockedProblem() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('ProblemStatements')
        .where('lockedBy', isEqualTo: currentUserId)
        .get();
    return querySnapshot.docs.isNotEmpty;
  }
}
