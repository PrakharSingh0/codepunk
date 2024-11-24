import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  DateTime? startTime;
  DateTime? endTime;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch current event configuration from Firestore
  Future<void> fetchEventConfig() async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('eventTiming')
          .doc('1sVOLXflwzOlTM8ZrhYt')
          .get();

      if (doc.exists) {
        setState(() {
          startTime = (doc['startTime'] as Timestamp).toDate();
          endTime = (doc['endTime'] as Timestamp).toDate();
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching event config: $e')),
      );
    }
  }

  // Update event configuration in Firestore
  Future<void> updateEventConfig() async {
    if (startTime == null || endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select both start and end times.')),
      );
      return;
    }

    try {
      await _firestore.collection('eventTiming').doc('1sVOLXflwzOlTM8ZrhYt').set({
        'startTime': Timestamp.fromDate(startTime!),
        'endTime': Timestamp.fromDate(endTime!),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event configuration updated successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating event config: $e')),
      );
    }
  }

  Future<void> resetProblemLocks() async {
    try {
      // Get all documents from ProblemStatements collection
      QuerySnapshot snapshot = await _firestore.collection('ProblemStatements').get();

      // Loop through each document and update isLocked and lockedBy fields
      for (var doc in snapshot.docs) {
        await doc.reference.update({
          'isLocked': false,
          'lockedBy': null,
        });
      }

      // Show a success message after updating
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("All problem statements have been reset.")),
      );
    } catch (e) {
      // Handle errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error resetting problem statements: $e")),
      );
    }
  }





  @override
  void initState() {
    super.initState();
    fetchEventConfig(); // Load initial data
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Control Panel'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Text(
              'Configure Event Timing',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            // Start Time Picker
            ListTile(
              title: const Text('Start Time:'),
              subtitle: Text(
                startTime != null
                    ? startTime.toString()
                    : 'Select a start time',
              ),
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: startTime ?? DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                  );

                  if (picked != null) {
                    TimeOfDay? time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(startTime ?? DateTime.now()),
                    );

                    if (time != null) {
                      setState(() {
                        startTime = DateTime(
                          picked.year,
                          picked.month,
                          picked.day,
                          time.hour,
                          time.minute,
                        );
                      });
                    }
                  }
                },
              ),
            ),
            const SizedBox(height: 10),
            // End Time Picker
            ListTile(
              title: const Text('End Time:'),
              subtitle: Text(
                endTime != null ? endTime.toString() : 'Select an end time',
              ),
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: endTime ?? DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                  );

                  if (picked != null) {
                    TimeOfDay? time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(endTime ?? DateTime.now()),
                    );

                    if (time != null) {
                      setState(() {
                        endTime = DateTime(
                          picked.year,
                          picked.month,
                          picked.day,
                          time.hour,
                          time.minute,
                        );
                      });
                    }
                  }
                },
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: updateEventConfig,
              child: const Text('Save Changes'),
            ),

            // ------------------------------------------------ Problem Statement Reset ---------

            Divider(),

            ElevatedButton(
              onPressed: resetProblemLocks,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent, // Red color for reset button
              ),
              child: const Text("Reset All Problem Statements",style: TextStyle(color: Colors.white),),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore.collection('ProblemStatements').snapshots(),
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
                      return ListTile(
                        title: Text(problem['title']),
                        subtitle: Text('Locked by: ${problem['lockedBy'] ?? "None"}'),
                        trailing: Icon(
                          problem['isLocked'] == true ? Icons.lock : Icons.lock_open,
                          color: problem['isLocked'] == true ? Colors.red : Colors.green,
                        ),
                      );
                    },
                  );
                },
              ),
            ),


          ],
        ),
      ),
    );
  }
}
