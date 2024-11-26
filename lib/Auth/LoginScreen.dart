import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
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

  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? validateInput(String email, String password) {
    if (email.isEmpty || password.isEmpty) {
      return "Both Email & Password are required.";
    }

    String emailPattern = r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$";
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

    String? validationError = validateInput(email, password);
    if (validationError != null) {
      setState(() {
        errorMassage = validationError;
        isLoading = false;
      });
      return;
    }

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        setState(() {
          isLoading = false;
        });
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const rsvpPage()),
        );
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = "No user found for that email.";
          break;
        case 'wrong-password':
          errorMessage = "Wrong password provided.";
          break;
        case 'invalid-email':
          errorMessage = "The email address is not valid.";
          break;
        case 'user-disabled':
          errorMessage = "This user has been disabled.";
          break;
        default:
          errorMessage = "An error occurred. Please try again.";
      }

      setState(() {
        errorMassage = errorMessage;
        isLoading = false;
      });

      _emailController.clear();
      _passwordController.clear();
    } catch (e) {
      setState(() {
        errorMassage = "An unexpected error occurred: ${e.toString()}";
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

          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF111111),  // Dark background
                Color(0xFF333333),  // Dark gradient
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            // borderRadius: BorderRadius.all(Radius.circular(40)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.computer,
                  color: Colors.cyanAccent,
                  size: 100,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Log In',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.cyanAccent,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                // Email Input
                TextField(
                  onTap: _resetErrorMessage,
                  style: const TextStyle(color: Colors.white54),
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelStyle: TextStyle(color: Colors.white),
                    hintText: "Team001@droid.com",
                    labelText: 'Email',
                    filled: true,
                    fillColor: Color(0xFF1A1A1A),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(28)),
                      borderSide: BorderSide(
                        color: Colors.cyanAccent,
                        width: 2,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(28)),
                      borderSide: BorderSide(
                        color: Colors.cyanAccent,
                        width: 3,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(28)),
                      borderSide: BorderSide(
                        color: Colors.cyanAccent,
                        width: 2,
                      ),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                // Password Input
                TextField(
                  onTap: _resetErrorMessage,
                  style: const TextStyle(color: Colors.white54),
                  controller: _passwordController,
                  obscureText: !_passwordVisible,
                  decoration: InputDecoration(
                    labelStyle: const TextStyle(color: Colors.white),
                    labelText: 'Password',
                    filled: true,
                    fillColor: const Color(0xFF1A1A1A),
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
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(28)),
                      borderSide: const BorderSide(
                        color: Colors.cyanAccent,
                        width: 2,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(28)),
                      borderSide: const BorderSide(
                        color: Colors.cyanAccent,
                        width: 3,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                if (errorMassage != null && errorMassage!.isNotEmpty)
                  Text(
                    errorMassage!,
                    style: const TextStyle(color: Colors.redAccent, fontSize: 16),
                  ),
                const SizedBox(height: 20),
                // Login Button
                SizedBox(
                  width: 150,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: checkCredential,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.cyanAccent,
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
                          color: Colors.black,
                        ),
                        SizedBox(width: 10),
                        Text('Log In', style: TextStyle(color: Colors.black)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
