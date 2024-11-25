import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RiddleListPage extends StatefulWidget {
  const RiddleListPage({super.key});

  @override
  State<RiddleListPage> createState() => _RiddleListPageState();
}

class _RiddleListPageState extends State<RiddleListPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add a new riddle
  Future<void> addNewRiddle() async {
    final TextEditingController riddleController = TextEditingController();
    final TextEditingController answerController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text(
            "Add New Riddle",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                minLines: 3,
                maxLines: 5,
                controller: riddleController,
                decoration: InputDecoration(
                  labelText: "Riddle",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: answerController,
                decoration: InputDecoration(
                  labelText: "Answer",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (riddleController.text.isNotEmpty &&
                    answerController.text.isNotEmpty) {
                  await _firestore.collection('RiddlesQues').add({
                    'riddle': riddleController.text,
                    'answer': answerController.text,
                  });
                  Navigator.pop(context); // Close the dialog
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Riddle added successfully!')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('All fields are required.')),
                  );
                }
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }

  // Delete a riddle with confirmation
  Future<void> deleteRiddle(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text(
            "Delete Riddle",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text("Are you sure you want to delete this riddle?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await _firestore.collection('RiddlesQues').doc(id).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Riddle deleted successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Riddle Questions"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: _firestore.collection('RiddlesQues').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            final riddles = snapshot.data?.docs ?? [];

            if (riddles.isEmpty) {
              return const Center(
                child: Text(
                  'No riddles available.',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              );
            }

            return ListView.builder(
              itemCount: riddles.length,
              itemBuilder: (context, index) {
                final riddle = riddles[index];

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    title: Text(
                      riddle['riddle'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('Answer: ${riddle['answer']}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => deleteRiddle(riddle.id),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: addNewRiddle,
        backgroundColor: Colors.blue,
        icon: const Icon(Icons.add),
        label: const Text("Add Riddle"),
      ),
    );
  }
}
