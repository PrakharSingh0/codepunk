import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ProblemListPage extends StatelessWidget {
  const ProblemListPage({super.key});

  void _showAddProblemDialog(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final TextEditingController psidController = TextEditingController();
    final TextEditingController titleController = TextEditingController();
    final TextEditingController detailsController = TextEditingController();
    bool isLocked = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Problem Statement'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: psidController,
                    decoration: const InputDecoration(
                      labelText: 'Problem Statement ID (PSID)',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a PSID';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Problem Title',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a title';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: detailsController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Problem Details',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter problem details';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  SwitchListTile(
                    title: const Text('Is Locked'),
                    value: isLocked,
                    onChanged: (value) {
                      isLocked = value;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState?.validate() ?? false) {
                  try {
                    // Check if PSID is unique
                    final existing = await FirebaseFirestore.instance
                        .collection('ProblemStatements')
                        .where('psid', isEqualTo: psidController.text)
                        .get();
                    if (existing.docs.isNotEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('PSID already exists!')),
                      );
                      return;
                    }

                    // Add the new problem statement to Firestore
                    await FirebaseFirestore.instance
                        .collection('ProblemStatements')
                        .add({
                      'psid': psidController.text,
                      'title': titleController.text,
                      'details': detailsController.text,
                      'isLocked': isLocked,
                      'lockedBy': null,
                    });

                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content:
                          Text('Problem statement added successfully!')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('Error adding problem statement: $e')),
                    );
                  }
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _toggleLock(DocumentSnapshot problem) async {
    try {
      final isLocked = problem['isLocked'] as bool;
      await problem.reference.update({
        'isLocked': !isLocked,
        'lockedBy': isLocked ? null : 'Admin',
      });
    } catch (e) {
      // Error handling
    }
  }

  Future<void> _deleteProblemWithConfirmation(
      DocumentSnapshot problem, BuildContext context) async {
    final confirmation = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Confirmation'),
          content: const Text(
              'Are you sure you want to delete this problem statement?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmation == true) {
      try {
        await problem.reference.delete();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Problem statement deleted successfully.')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting problem statement: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Problem Statements'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('ProblemStatements')
            .orderBy('psid') // Sorting the documents by PSID in ascending order
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final problemStatements = snapshot.data?.docs ?? [];

          if (problemStatements.isEmpty) {
            return const Center(
              child: Text(
                'No Problem Statements Found!',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: problemStatements.length,
            itemBuilder: (context, index) {
              final problem = problemStatements[index];
              return Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  leading: Text(
                    problem['psid'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                      fontSize: 16,
                    ),
                  ),
                  title: Text(
                    problem['title'],
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: Text(
                    'Locked by: ${problem['lockedBy'] ?? "None"}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          problem['isLocked'] ? Icons.lock : Icons.lock_open,
                          color:
                          problem['isLocked'] ? Colors.red : Colors.green,
                        ),
                        onPressed: () => _toggleLock(problem),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () =>
                            _deleteProblemWithConfirmation(problem, context),
                      ),
                    ],
                  ),
                  onTap: () {
                    // Show dialog with problem details
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          title: const Row(
                            children: [
                              Icon(Icons.info, color: Colors.blue),
                              SizedBox(width: 8),
                              Text('Problem Details',
                                  style:
                                  TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Text('PSID:',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  const SizedBox(width: 8),
                                  Text(problem['psid'],
                                      style:
                                      const TextStyle(color: Colors.blue)),
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
                                      problem['title'],
                                      style:
                                      const TextStyle(color: Colors.black),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(thickness: 1, height: 16),
                              const Text('Details:',
                                  style:
                                  TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text(
                                problem['details'],
                                style: const TextStyle(color: Colors.grey),
                              ),
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
                                  const Text('Is Locked:',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  const SizedBox(width: 8),
                                  Icon(
                                    problem['isLocked']
                                        ? Icons.lock
                                        : Icons.lock_open,
                                    color: problem['isLocked']
                                        ? Colors.red
                                        : Colors.green,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    problem['isLocked'] ? 'Yes' : 'No',
                                    style: TextStyle(
                                      color: problem['isLocked']
                                          ? Colors.red
                                          : Colors.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          actions: [
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              icon: const Icon(Icons.close),
                              label: const Text('Close'),
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddProblemDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
