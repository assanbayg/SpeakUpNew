import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:speakup/features/speakup/controllers/sprite_controller.dart';
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

    // Try to find sprite controller, but don't crash if not available
    final SpriteController? spriteController =
        Get.isRegistered<SpriteController>()
            ? Get.find<SpriteController>()
            : null;

    return Obx(() {
      final isSpeaking = textController.isSpeaking;
      final selectedSpriteUrl = spriteController?.selectedSpriteUrl;
      final isUsingCustomSprite = selectedSpriteUrl != null;

      if (isSpeaking) {
        // When speaking, show video for default or animated sprite
        if (isUsingCustomSprite) {
          // For custom sprites, show the static image with a subtle animation
          return _AnimatedSpriteImage(
            imageUrl: selectedSpriteUrl,
            isAnimating: true,
          );
        } else {
          // Default: play the video
          videoController.play();
          return AspectRatio(
            aspectRatio: videoController.value.aspectRatio,
            child: VideoPlayer(videoController),
          );
        }
      } else {
        // When not speaking, show static image
        videoController.pause();

        if (isUsingCustomSprite) {
          return _AnimatedSpriteImage(
            imageUrl: selectedSpriteUrl,
            isAnimating: false,
          );
        } else {
          // Default Speechy
          return Image.asset(
            'assets/images/speechy_default.png',
            width: MediaQuery.of(context).size.width,
            fit: BoxFit.cover,
          );
        }
      }
    });
  }
}

/// Widget that displays a sprite image with optional animation
class _AnimatedSpriteImage extends StatefulWidget {
  const _AnimatedSpriteImage({
    required this.imageUrl,
    required this.isAnimating,
  });

  final String imageUrl;
  final bool isAnimating;

  @override
  State<_AnimatedSpriteImage> createState() => _AnimatedSpriteImageState();
}

class _AnimatedSpriteImageState extends State<_AnimatedSpriteImage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    if (widget.isAnimating) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(_AnimatedSpriteImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isAnimating && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.isAnimating && _controller.isAnimating) {
      _controller.stop();
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: widget.isAnimating
          ? _scaleAnimation
          : const AlwaysStoppedAnimation(1.0),
      child: Image.network(
        widget.imageUrl,
        width: MediaQuery.of(context).size.width,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.width,
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          // Fallback to default image on error
          return Image.asset(
            'assets/images/speechy_default.png',
            width: MediaQuery.of(context).size.width,
            fit: BoxFit.cover,
          );
        },
      ),
    );
  }
}
