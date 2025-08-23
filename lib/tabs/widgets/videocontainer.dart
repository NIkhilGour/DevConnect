import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_player/video_player.dart';

class Videocontainer extends StatefulWidget {
  const Videocontainer({super.key, required this.url});
  final String url;

  @override
  State<Videocontainer> createState() => _VideocontainerState();
}

class _VideocontainerState extends State<Videocontainer> {
  late VideoPlayerController controller;
  bool isInitialized = false;

  @override
  void initState() {
    super.initState();
    controller = VideoPlayerController.networkUrl(
      Uri.parse(widget.url),
      videoPlayerOptions: VideoPlayerOptions(),
    )..initialize().then((_) {
        setState(() {
          isInitialized = true;
        });
      });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Column(
        children: [
          if (isInitialized)
            AspectRatio(
              aspectRatio: controller.value.aspectRatio,
              child: VideoPlayer(controller),
            )
          else
            Center(child: const CircularProgressIndicator()),

          const SizedBox(height: 10),

          // Play/Pause button
          IconButton(
            icon: Icon(
              controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
              size: 30,
            ),
            onPressed: () {
              setState(() {
                controller.value.isPlaying
                    ? controller.pause()
                    : controller.play();
              });
            },
          ),
        ],
      ),
    );
  }
}
