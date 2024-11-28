import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import '../Widgets/GlobalCountDown.dart';

class ProblemDetailsPage extends StatefulWidget {
  final String problemId;

  const ProblemDetailsPage({super.key, required this.problemId});

  @override
  State<ProblemDetailsPage> createState() => _ProblemDetailsPageState();
}

class _ProblemDetailsPageState extends State<ProblemDetailsPage> {
  Map<String, dynamic>? problemDetails;

  // Global Countdown Timer
  Duration globalCountdown = const Duration(minutes: 30);
  Timer? timer;

  @override
  void initState() {
    super.initState();
    fetchProblemDetails();
    startGlobalCountdown();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
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

  // Start the global countdown timer
  void startGlobalCountdown() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (globalCountdown.inSeconds <= 0) {
        timer.cancel();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Global countdown has ended!")),
        );
      } else {
        setState(() {
          globalCountdown = globalCountdown - const Duration(seconds: 1);
        });
      }
    });
  }

  // Format duration to MM:SS
  String formatDuration(Duration duration) {
    String minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    String seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  // Format problem details with bold labels
  List<InlineSpan> formatDetails(String details) {
    final List<String> lines = details.split('\n');
    List<InlineSpan> formattedSpans = [];

    for (String line in lines) {
      final parts = line.split(':');
      if (parts.length > 1) {
        formattedSpans.add(
          TextSpan(
            text: "${parts[0].trim()}: ",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.orangeAccent,
              fontSize: 16,
            ),
          ),
        );
        formattedSpans.add(
          TextSpan(
            text: parts.sublist(1).join(':').trim(),
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
        );
        formattedSpans.add(const TextSpan(text: '\n'));
      } else {
        formattedSpans.add(
          TextSpan(
            text: "$line\n",
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
        );
      }
    }

    return formattedSpans;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2C),
      appBar: AppBar(
        backgroundColor: const Color(0xFF28293E),
        iconTheme: const IconThemeData(color: Colors.cyanAccent),
        title: const Text(
          "Problem Details",
          style: TextStyle(
            fontFamily: 'Orbitron',
            color: Colors.cyanAccent,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          problemDetails == null
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Problem Title
                Text(
                  problemDetails!["title"] ?? "No Title",
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.cyanAccent,
                    fontFamily: 'Orbitron',
                    shadows: [
                      Shadow(
                        blurRadius: 10.0,
                        color: Colors.cyanAccent,
                        offset: Offset(0, 0),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // PSID
                Row(
                  children: [
                    const Text(
                      "PSID:",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.orangeAccent,
                        fontFamily: 'Orbitron',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        problemDetails!["psid"] ?? "No PSID",
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontFamily: 'Roboto',
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const Divider(color: Colors.cyanAccent, thickness: 0.5),
                const SizedBox(height: 10),

                // Locked By
                Row(
                  children: [
                    const Text(
                      "Locked By:",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.orangeAccent,
                        fontFamily: 'Orbitron',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        problemDetails!["lockedBy"] ?? "None",
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontFamily: 'Roboto',
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const Divider(color: Colors.cyanAccent, thickness: 0.5),
                const SizedBox(height: 10),

                // Lock Status
                Row(
                  children: [
                    const Text(
                      "Locked:",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.orangeAccent,
                        fontFamily: 'Orbitron',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      (problemDetails!["isLocked"] ?? false)
                          ? Icons.lock
                          : Icons.lock_open,
                      color: (problemDetails!["isLocked"] ?? false)
                          ? Colors.redAccent
                          : Colors.greenAccent,
                      size: 24,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      (problemDetails!["isLocked"] ?? false) ? "Yes" : "No",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: (problemDetails!["isLocked"] ?? false)
                            ? Colors.redAccent
                            : Colors.greenAccent,
                        fontFamily: 'Roboto',
                      ),
                    ),
                  ],
                ),
                const Divider(color: Colors.cyanAccent, thickness: 0.5),
                const SizedBox(height: 10),

                // Problem Details
                const Text(
                  "Details:",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.orangeAccent,
                    fontFamily: 'Orbitron',
                  ),
                ),
                const SizedBox(height: 8),
                RichText(
                  text: TextSpan(
                    children: formatDetails(
                        problemDetails!["details"] ?? "No details available"),
                  ),
                ),
                const Divider(color: Colors.cyanAccent, thickness: 0.5),
                const SizedBox(height: 10),

                // Action Button
              ],
            ),
          ),

          // Floating Countdown Timer
          Positioned(
            bottom: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF28293E),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.cyanAccent.withOpacity(0.5),
                    blurRadius: 10,
                    offset: const Offset(0, 0),
                  ),
                ],
              ),
              child: const GlobalCountDown(),
              ),
            ),
        ],
      ),
    );
  }
}
