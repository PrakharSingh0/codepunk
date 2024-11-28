import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ProblemListPage extends StatelessWidget {
  const ProblemListPage({super.key});

  void _showAddProblemDialog(BuildContext context, {DocumentSnapshot? problem}) {
    final _formKey = GlobalKey<FormState>();
    final TextEditingController psidController = TextEditingController(
        text: problem != null ? problem['psid'] ?? '' : '');
    final TextEditingController titleController = TextEditingController(
        text: problem != null ? problem['title'] ?? '' : '');
    final TextEditingController detailsController = TextEditingController(
        text: problem != null ? problem['details'] ?? '' : '');
    bool isLocked = problem != null ? problem['isLocked'] ?? false : false;
    bool isEdit = problem != null; // Check if we are editing an existing problem

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(isEdit ? 'Edit Problem Statement' : 'Add New Problem Statement'),
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
                    maxLines: 5,
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
            ElevatedButton.icon(
              onPressed: () async {
                if (_formKey.currentState?.validate() ?? false) {
                  try {
                    if (isEdit) {
                      // Update existing problem
                      await problem?.reference.update({
                        'title': titleController.text,
                        'details': detailsController.text,
                        'isLocked': isLocked,
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Problem updated successfully!')),
                      );
                    } else {
                      // Add new problem
                      await FirebaseFirestore.instance
                          .collection('ProblemStatements')
                          .add({
                        'psid': psidController.text,
                        'title': titleController.text,
                        'details': detailsController.text,
                        'isLocked': isLocked,
                        'lockedBy': null,
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Problem added successfully!')),
                      );
                    }
                    Navigator.of(context).pop();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                }
              },
              icon: const Icon(Icons.update), // Update icon
              label: Text(isEdit ? 'Update' : 'Add'), // Label depending on edit or add
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
                    _showAddProblemDialog(context, problem: problem);
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
