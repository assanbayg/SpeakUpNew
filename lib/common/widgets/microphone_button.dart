import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:speakup/features/speakup/controllers/speech_controller.dart';
import 'package:speakup/features/speakup/controllers/text_to_speech_controller.dart';

class MicrophoneButton extends StatelessWidget {
  const MicrophoneButton({
    super.key,
    this.onlyListen = false,
  });

  final bool onlyListen;

  @override
  Widget build(BuildContext context) {
    final speechController = Get.find<SpeechController>();
    final textController = Get.find<TextToSpeechController>();

    return Obx(() {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 40.0),
            child: IconButton(
              padding: const EdgeInsets.all(8),
              icon: SvgPicture.asset(
                'assets/icons/Audio.svg',
                width: 80,
                height: 80,
                colorFilter: const ColorFilter.mode(
                  Colors.white,
                  BlendMode.srcIn,
                ),
              ),
              iconSize: 80,
              onPressed: () {
                if (textController.isThinking || textController.isSpeaking) {
                  return;
                } else {
                  speechController.listen(onlyListen);
                  textController.lastChatResponse = '';
                }
              },
              alignment: Alignment.center,
              style: IconButton.styleFrom(
                backgroundColor:
                    speechController.isListening ? Colors.green : Colors.red,
              ),
            ),
          ),
        ],
      );
    });
  }
}
