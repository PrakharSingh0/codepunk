import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';

class backgroundWidget extends StatefulWidget {
  const backgroundWidget({super.key});

  @override
  _backgroundWidgetState createState() => _backgroundWidgetState();
}

class _backgroundWidgetState extends State<backgroundWidget> {
  late VideoPlayerController _controller;

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
  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: _controller.value.size.width ?? 400,
            height: _controller.value.size.height ?? 1200,
            // child: VideoPlayer(_controller),
            child: Container(
              decoration: const BoxDecoration(gradient: LinearGradient(colors: [Colors.greenAccent,Colors.blueAccent])),
            ),
          ),
        ),
      );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}
