import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:speakup/features/speakup/controllers/text_to_speech_controller.dart';
import 'package:video_player/video_player.dart';

class VideoImageWidget extends StatelessWidget {
  const VideoImageWidget({
    super.key,
    required this.videoController,
  });

  final VideoPlayerController videoController;

  @override
  Widget build(BuildContext context) {
    final textController = Get.find<TextToSpeechController>();

    return Obx(() {
      if (textController.isSpeaking) {
        videoController.play();
        return AspectRatio(
          aspectRatio: videoController.value.aspectRatio,
          child: VideoPlayer(videoController),
        );
      } else {
        videoController.pause();
        return Image.asset(
          'assets/images/speechy_default.png',
          width: MediaQuery.of(context).size.width,
          fit: BoxFit.cover,
        );
      }
    });
  }
}

