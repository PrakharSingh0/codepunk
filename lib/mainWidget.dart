import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';

class mainWidget extends StatefulWidget {
  const mainWidget({super.key});

  @override
  _mainWidgetState createState() => _mainWidgetState();
}

class _mainWidgetState extends State<mainWidget> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(
        'assets/backGroundVideoLoop.mp4')
      ..initialize().then((_) {
        _controller.play();
        _controller.setLooping(true);
        // Ensure the first frame is shown after the video is initialized
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(color: Colors.black,),
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
          const Padding(padding: EdgeInsets.all(20),
          child: welcomePage(),
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


class welcomePage extends StatelessWidget {
  const welcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
    );
  }
}
