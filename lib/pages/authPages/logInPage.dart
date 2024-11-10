import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../services/firebaseAuthService.dart';
import '../userMode/rsvpPage.dart';

class logInPage extends StatefulWidget {
  const logInPage({super.key});

  @override
  State<logInPage> createState() => _logInPageState();
}

class _logInPageState extends State<logInPage> {
  String? errorMassage = '';
  String? _error = '';

  bool isLoading = false;

  int delayTime = 500;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _passwordVisible = false;

  Future<void> signInWithEmailAndPassword() async {
    try {
      await Auth().signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        _error = e.message;
      });
    }
  }

  Future<void> checkCredential() async {
    setState(() {
      isLoading = true;
    });

    if (_emailController.text == "" || _passwordController.text == "") {
      Timer(Duration(milliseconds: delayTime), () {
        errorMassage = "Both Email & Password Required";
        _emailController.clear();
        _passwordController.clear();
        setState(() {
          isLoading = false;
        });
      });
    }
    else {
      final user = await Auth()
          .signInWithEmailAndPassword(
          email: _emailController.text, password: _passwordController.text)
          .onError(
            (error, stackTrace) {
          _resetErrorMessage();
          errorMassage = "Incorrect Credentials";
          _emailController.clear();
          _passwordController.clear();
          setState(() {
            isLoading = false;
          });
          return null;
        },
      );

      if (Auth().currentUser != null) {
        Timer(Duration(milliseconds: delayTime), () {
          setState(() {
            isLoading = false;
          });
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const rsvpPage()));
        });
      }
    }
  }

  void _resetErrorMessage() {
    setState(() {
      errorMassage = "";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [
              Color.fromRGBO(0, 0, 0, .5),
              Color.fromRGBO(0, 0, 0, .8)
            ]),
            border: Border.all(width: 2, color: Colors.orange),
            borderRadius: const BorderRadius.all(Radius.circular(40))),
        width: 450,
        height: 500,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(40, 0, 40, 0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Code-Punk',
                style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              const SizedBox(height: 50),
              const Text(
                'Log In',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              Column(
                children: [
                  const SizedBox(height: 16),

                  // Email ----------------->
                  TextField(
                    onTap: () {
                      _resetErrorMessage();
                    },
                    style: const TextStyle(
                      color: Colors.white54,
                    ),
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelStyle: TextStyle(color: Colors.white),
                      hintText: "Team001@droid.com",
                      // errorText: errorMassage,
                      labelText: 'Email',
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),

                  // Password -------------->
                  const SizedBox(height: 16),
                  TextField(
                    onTap: () {
                      _resetErrorMessage();
                    },
                    style: const TextStyle(
                      color: Colors.white54,
                    ),
                    controller: _passwordController,
                    obscureText: !_passwordVisible,
                    decoration: InputDecoration(
                      labelStyle: const TextStyle(color: Colors.white),
                      // errorText: errorMassage,
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
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    errorMassage!,
                    style:
                        const TextStyle(color: Colors.redAccent, fontSize: 16),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    width: 150,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        // Handle login

                        checkCredential();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orangeAccent,
                        padding: const EdgeInsets.symmetric(vertical: 16),
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
                        children: [Icon(Icons.login,color: Colors.white,),
                          SizedBox(width: 10,),
                          Text('Log In',
                          style: TextStyle(color: Colors.white)),],),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
