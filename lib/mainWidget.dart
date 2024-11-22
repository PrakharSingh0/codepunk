import 'package:codepunk/pages/authPages/logInPage.dart';
import 'package:codepunk/pages/userMode/countDownPage.dart';
import 'package:codepunk/pages/userMode/problemStatementPage.dart';
import 'package:codepunk/pages/userMode/puzzlePage.dart';
import 'package:codepunk/pages/userMode/rsvpPage.dart';
import 'package:codepunk/welcomePage.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';

class mainWidget extends StatefulWidget {
  const mainWidget({super.key});

  @override
  _mainWidgetState createState() => _mainWidgetState();
}

class _mainWidgetState extends State<mainWidget> {
  late VideoPlayerController _controller;
  static int currentPageIndex = 1;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/backGroundVideoLoop.mp4')
      ..initialize().then((_) {
        _controller.play();
        _controller.setLooping(true);
        // Ensure the first frame is shown after the video is initialized
        setState(() {});
      });
  }

  final List<Widget> wt = [
    const welcomePage(),
    const logInPage(),
    const rsvpPage(),
    const puzzlePage(),
    const problemStatementPage(remainingTime: '',),
    const countDownPage(psid: '', problemStatement: '',)
  ];

  void changePage(int index) {
    setState(() {
      currentPageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          // Container(
          //   color: Colors.black,
          // ),
          SizedBox.expand(
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _controller.value.size.width ?? 0,
                height: _controller.value.size.height ?? 0,
                child: VideoPlayer(_controller),
              ),
            ),
          ),

          // Widget here
          Padding(
            padding: const EdgeInsets.all(30),
            child: wt[currentPageIndex],
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}

// class welcomePage extends StatelessWidget {
//   const welcomePage({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return const welcomePage();
//   }
// }
