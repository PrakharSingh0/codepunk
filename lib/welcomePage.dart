import 'package:flutter/material.dart';

class welcomePage extends StatelessWidget {
  const welcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 400,
        decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [
              Color.fromRGBO(0, 0, 0, .5),
              Color.fromRGBO(0, 0, 0, .8)
            ]),
            border: Border.all(width: 2, color: Colors.orange),
            borderRadius: const BorderRadius.all(Radius.circular(40))),
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Code Punk",
                style: TextStyle(color: Colors.white,fontSize: 40),
              ),
              const SizedBox(height: 50,),
              ElevatedButton(onPressed: () {}, child: const Text("Lets Go"))
            ],
          ),
        ),
      ),
    );
  }
}
