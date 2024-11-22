import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codepunk/backgroundWidget.dart';
import 'package:codepunk/pages/userMode/countDownPage.dart';
import 'package:flutter/material.dart';

class problemStatementPage extends StatefulWidget {
  const problemStatementPage({super.key, required this.remainingTime});

  final remainingTime;

  @override
  State<problemStatementPage> createState() => _problemStatementPageState();
}

class _problemStatementPageState extends State<problemStatementPage> {
  int? selectedIndex;
  bool isConfirmed = false;
  List<Map<String, dynamic>> problemStatements = [];

  Timer? _timer;
  int _remainingTime = 70;

  @override
  void initState() {
    super.initState();
    _fetchProblemStatements();
    _startAutoRefresh();
    _remainingTime = widget.remainingTime > 0 ? widget.remainingTime : 70;
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        setState(() {
          _remainingTime--;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startAutoRefresh() {
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      _fetchProblemStatements();
    });
  }

  Future<void> _fetchProblemStatements() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('Problem_Statement').get();
    setState(() {
      problemStatements = snapshot.docs.map((doc) {
        return {
          'Problem Statement': doc['Title'] as String? ?? 'No Title',
          'Status': doc['Status'] ? 'Open' : 'Closed',
          'PSID': doc['ID'] as String? ?? 'No ID',
          'Description': doc['Description'] as String? ?? 'No Description',
          'DocID': doc.id,
        } as Map<String, dynamic>;
      }).toList();

      problemStatements.sort((a, b) => a['PSID']!.compareTo(b['PSID']!));
    });
  }

  void _onCheckboxChanged(int index, bool? value) {
    if (value == true) {
      setState(() {
        selectedIndex = index;
        isConfirmed = false;
      });
    } else {
      setState(() {
        selectedIndex = null;
      });
    }
  }

  void _onConfirmCheckboxChanged(bool? value) {
    setState(() {
      isConfirmed = value ?? false;
    });
  }

  void _showDetailsModal(int index) {
    if (index < 0 || index >= problemStatements.length) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("ID: ${problemStatements[index]['PSID']}",
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text("Title: ${problemStatements[index]['Problem Statement']}",
                    style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 8),
                Text("Description: ${problemStatements[index]['Description']}",
                    style: const TextStyle(fontSize: 14)),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showConfirmationDialog() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Selection"),
        content:
            const Text("Are you sure you want to proceed with this selection?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              if (selectedIndex != null) {
                String psid =
                    problemStatements[selectedIndex!]['PSID'] ?? 'No PSID';
                String problemStatement = problemStatements[selectedIndex!]
                        ['Problem Statement'] ??
                    'No Title';

                await FirebaseFirestore.instance
                    .collection('Problem_Statement')
                    .doc(problemStatements[selectedIndex!]['DocID'])
                    .update({'Status': false});

                setState(() {
                  problemStatements.removeAt(selectedIndex!);
                  selectedIndex = null;
                });
                _fetchProblemStatements();
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => countDownPage(
                      psid: psid,
                      problemStatement: problemStatement,
                    ),
                  ),
                );
              }
            },
            child: const Text("Confirm"),
          ),
        ],
      ),
    );
  }

  String getFormattedTime(int totalSeconds) {
    int minutes = totalSeconds ~/ 60;
    int seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(children: [
        const backgroundWidget(),
        Center(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    DataTable(
                      dataRowColor: WidgetStateProperty.resolveWith<Color?>(
                          (Set<WidgetState> states) =>
                              states.contains(WidgetState.selected)
                                  ? Colors.orange
                                  : null),
                      columns: List.generate(
                          4,
                          (index) => DataColumn(
                              label: Text(_getColumnHeader(index),
                                  style: AppTextStyles.defaultTextStyle()))),
                      rows: List<DataRow>.generate(
                          problemStatements.length,
                          (index) =>
                              DataRow(selected: selectedIndex == index, cells: [
                                DataCell(CustomCheckbox(
                                  value: selectedIndex == index,
                                  onChanged: problemStatements[index]
                                              ['Status'] ==
                                          'Open'
                                      ? (value) =>
                                          _onCheckboxChanged(index, value)
                                      : null,
                                  isEnabled: problemStatements[index]
                                          ['Status'] ==
                                      'Open',
                                )),
                                DataCell(GestureDetector(
                                  onTap: () => _showDetailsModal(index),
                                  child: Text(problemStatements[index]['PSID']!,
                                      style: AppTextStyles.defaultTextStyle()),
                                )),
                                DataCell(GestureDetector(
                                  onTap: () => _showDetailsModal(index),
                                  child: Text(
                                      problemStatements[index]
                                          ['Problem Statement']!,
                                      style: AppTextStyles.defaultTextStyle()),
                                )),
                                DataCell(Text(
                                    problemStatements[index]['Status']!,
                                    style: AppTextStyles.defaultTextStyle())),
                              ])),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const SizedBox(
                          width: 65,
                        ),
                        CustomCheckbox(
                          value: isConfirmed && selectedIndex != null,
                          onChanged: selectedIndex != null
                              ? _onConfirmCheckboxChanged
                              : null,
                          isEnabled: selectedIndex != null,
                        ),
                        Text(
                            "I confirm that the Problem Statement that I have chosen will not be changed.",
                            style: AppTextStyles.defaultTextStyle()),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: selectedIndex != null && isConfirmed
                          ? () => _showConfirmationDialog()
                          : null,
                      style: ButtonStyle(
                        backgroundColor:
                            WidgetStateProperty.resolveWith<Color?>(
                                (Set<WidgetState> states) =>
                                    states.contains(WidgetState.disabled)
                                        ? Colors.grey[300]
                                        : (selectedIndex != null && isConfirmed)
                                            ? Colors.orange
                                            : Colors.white),
                        foregroundColor:
                            WidgetStateProperty.resolveWith<Color?>(
                                (Set<WidgetState> states) =>
                                    states.contains(WidgetState.disabled)
                                        ? Colors.black
                                        : (selectedIndex != null && isConfirmed)
                                            ? Colors.white
                                            : Colors.black),
                      ),
                      child: Text("Proceed to Confirm",
                          style: AppTextStyles.buttonTextStyle()),
                    ),
                  ],
                ),
              ),
            ),
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

  String _getColumnHeader(int index) {
    switch (index) {
      case 0:
        return 'Select';
      case 1:
        return 'PSID';
      case 2:
        return 'Problem Statement';
      case 3:
        return 'Status';
      default:
        return '';
    }
  }
}

class AppTextStyles {
  static TextStyle defaultTextStyle({Color color = Colors.black}) {
    return TextStyle(color: color, fontSize: 16);
  }

  static TextStyle titleTextStyle() {
    return defaultTextStyle(color: Colors.black)
        .copyWith(fontSize: 20, fontWeight: FontWeight.bold);
  }

  static TextStyle buttonTextStyle() {
    return defaultTextStyle(color: Colors.white).copyWith(fontSize: 16);
  }

  static TextStyle confirmationTextStyle() {
    return defaultTextStyle(color: Colors.black).copyWith(fontSize: 16);
  }
}

class CustomCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?>? onChanged;
  final bool isEnabled;

  const CustomCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Checkbox(
      value: value,
      activeColor: Colors.orangeAccent,
      onChanged: isEnabled ? onChanged : null,
      visualDensity: VisualDensity.compact,
    );
  }
}
