import 'package:flutter/material.dart';
import 'package:codepunk/Mode/Admin/AdminPage.dart';

class Adminstart extends StatefulWidget {
  Adminstart({super.key});

  @override
  State<Adminstart> createState() => _AdminstartState();
}

class _AdminstartState extends State<Adminstart> {
  TextEditingController passController = TextEditingController();
  String errorMessage = '';
  bool obscureText = true; // Variable to manage password visibility

  @override
  void dispose() {
    passController.dispose();
    super.dispose();
  }

  void checkPass() {
    setState(() {
      if (passController.text == "Admin P10") {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AdminPage()),
        );
      } else {
        errorMessage = "You are not an admin!";
      }
    });
  }

  void togglePasswordVisibility() {
    setState(() {
      obscureText = !obscureText; // Toggle password visibility
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[50], // Light background color
      body: Center(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white, // White background for the login box
            borderRadius: BorderRadius.circular(12),
            border: Border.all(width: 1,color: Colors.blueAccent),// Rounded corners
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 5,
                offset: Offset(0, 4), // Shadow direction
              ),
            ],
          ),
          width: 300,
          height: 300,
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title for the page
              Text(
                "Admin Login",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey[800],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // Password text field with improved UI
              TextField(
                controller: passController,
                obscureText: obscureText,
                decoration: InputDecoration(
                  labelText: "Password",
                  labelStyle: TextStyle(color: Colors.blueGrey[600]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.blueGrey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscureText ? Icons.visibility_off : Icons.visibility,
                      color: Colors.blueGrey[600],
                    ),
                    onPressed: togglePasswordVisibility,
                  ),
                ),
                style: TextStyle(color: Colors.blueGrey[800]),
              ),
              const SizedBox(height: 20),

              // "Check Admin" button with better styling
              ElevatedButton(
                onPressed: checkPass,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, // Button color
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  "Check Admin",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Error message with improved styling
              if (errorMessage.isNotEmpty)
                Text(
                  errorMessage,
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
