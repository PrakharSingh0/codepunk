import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../Mode/User/Pages/RSVP.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String? errorMassage = '';
  bool isLoading = false;
  int delayTime = 500;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _passwordVisible = false;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? validateInput(String email, String password) {
    if (email.isEmpty || password.isEmpty) {
      return "Both Email & Password are required.";
    }

    // Simple regex for email validation
    String emailPattern =
        r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$";
    RegExp emailRegex = RegExp(emailPattern);

    if (!emailRegex.hasMatch(email)) {
      return "Please enter a valid email address.";
    }

    if (password.length < 6) {
      return "Password must be at least 6 characters.";
    }

    return null;
  }

  Future<void> checkCredential() async {
    setState(() {
      isLoading = true;
      errorMassage = '';
    });

    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    // Input validation
    String? validationError = validateInput(email, password);
    if (validationError != null) {
      Timer(Duration(milliseconds: delayTime), () {
        setState(() {
          errorMassage = validationError;
          isLoading = false;
        });
      });
      return;
    }

    try {

      final QuerySnapshot userSnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .where('password', isEqualTo: password)
          .get();

      if (userSnapshot.docs.isNotEmpty) {
        // If credentials are valid, navigate to RSVP page
        Timer(Duration(milliseconds: delayTime), () {
          setState(() {
            isLoading = false;
          });
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const rsvpPage()),
          );
        });
      } else {
        // Invalid credentials
        Timer(Duration(milliseconds: delayTime), () {
          setState(() {
            errorMassage = "Incorrect email or password.";
            isLoading = false;
          });
          _emailController.clear();
          _passwordController.clear();
        });
      }
    } catch (e) {

      setState(() {
        errorMassage = "An error occurred. Please try again.";
        isLoading = false;
      });
    }
  }

  void _resetErrorMessage() {
    setState(() {
      errorMassage = "";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [
              Color.fromRGBO(0, 0, 0, .5),
              Color.fromRGBO(0, 0, 0, .8)
            ]),
            border: Border.all(width: 2, color: Colors.orange),
            borderRadius: const BorderRadius.all(Radius.circular(40)),
          ),
          width: 380,
          height: 300,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Log In',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  onTap: _resetErrorMessage,
                  style: const TextStyle(color: Colors.white54),
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelStyle: TextStyle(color: Colors.white),
                    hintText: "Team001@droid.com",
                    labelText: 'Email',
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                // Password ----------------->
                const SizedBox(height: 16),
                TextField(
                  onTap: _resetErrorMessage,
                  style: const TextStyle(color: Colors.white54),
                  controller: _passwordController,
                  obscureText: !_passwordVisible,
                  decoration: InputDecoration(
                    labelStyle: const TextStyle(color: Colors.white),
                    labelText: 'Password',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _passwordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        setState(() {
                          _passwordVisible = !_passwordVisible;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                if (errorMassage != null && errorMassage!.isNotEmpty)
                  Text(
                    errorMassage!,
                    style: const TextStyle(
                        color: Colors.redAccent, fontSize: 16),
                  ),
                const SizedBox(height: 10),
                SizedBox(
                  width: 150,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: checkCredential,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orangeAccent,
                      padding: const EdgeInsets.symmetric(vertical: 0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      textStyle:
                      const TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    child: isLoading
                        ? const SizedBox(
                      height: 25,
                      width: 25,
                      child: CircularProgressIndicator(),
                    )
                        : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.login,
                          color: Colors.white,
                        ),
                        SizedBox(width: 10),
                        Text('Log In', style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
