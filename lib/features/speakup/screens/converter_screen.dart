import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:speakup/common/widgets/appbar.dart';
import 'package:speakup/features/speakup/controllers/speech_controller.dart';
import 'package:speakup/features/speakup/controllers/text_to_speech_controller.dart';
import 'package:speakup/features/speakup/screens/home_screen.dart';
import 'package:speakup/features/speakup/screens/map_screen.dart';
import 'package:speakup/features/speakup/screens/profile_screen.dart';
import 'package:speakup/util/constants/sizes.dart';
import 'package:speakup/util/device/device_utility.dart';
import 'package:video_player/video_player.dart';

class ConverterScreen extends StatefulWidget {
  const ConverterScreen({super.key});

  @override
  State<ConverterScreen> createState() => _ConverterScreenState();
}

class _ConverterScreenState extends State<ConverterScreen> {
  final SpeechController speechController = Get.put(SpeechController());
  final TextToSpeechController textController =
      Get.put(TextToSpeechController());
  final ValueNotifier<bool> isListeningNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<bool> isPlayingNotifier = ValueNotifier<bool>(false);

  late final VideoPlayerController videoController;

  int _selectedIndex = 1;
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      textController.lastChatResponse = '';
    });
    switch (index) {
      case 0:
        Get.to(const HomeScreen());
        break;
      case 1:
        Get.to(const ConverterScreen());
        break;
      case 2:
        Get.to(const MapScreen(text: ""));
        break;
      case 3:
        Get.to(const UserProfileScreen());
        break;
    }
  }

  Widget _buildNavItem(String asset, String label, int index) {
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: SizedBox(
        width: MediaQuery.of(context).size.width / 4,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(asset, width: 24, height: 24),
            Text(
              label,
              style: TextStyle(
                color: _selectedIndex == index
                    ? Colors.blue
                    : Colors.grey, // Change color based on selection
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    videoController = VideoPlayerController.asset('assets/images/video.mp4')
      ..initialize().then((_) {
        videoController.setLooping(true);
        setState(() {});
      });
  }

  String get statusText {
    if (speechController.isListening) {
      return 'Слушаю...';
    } else if (textController.isThinking) {
      return 'Обрабатываю...';
    } else if (textController.lastChatResponse.isEmpty) {
      return '';
    } else {
      return textController.lastChatResponse;
    }
  }

  @override
  void dispose() {
    super.dispose();
    videoController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
      body: Stack(
        children: [
          buildBody(),
          Align(
            alignment: Alignment.bottomCenter,
            child: buildBottomSheet(),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: SizedBox(
          height: 60,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: <Widget>[
              _buildNavItem('assets/images/chat.png', 'Спичи', 0),
              _buildNavItem('assets/images/convert.png', 'Конвертер', 1),
              _buildNavItem('assets/images/marker.png', 'Центры', 2),
              _buildNavItem('assets/images/profile.png', 'Профайл', 3),
            ],
          ),
        ),
      ),
    );
  }

  SAppBar buildAppBar() {
    return const SAppBar(
      page: "Converter",
      title: "Конвертер",
    );
  }

  Widget buildBody() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(SSizes.defaultSpace),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            buildVideoOrImage(),
          ],
        ),
      ),
    );
  }

  Obx buildVideoOrImage() {
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
          'assets/images/speechy_default.PNG',
          width: MediaQuery.of(context).size.width,
          fit: BoxFit.cover,
        );
      }
    });
  }

  Container buildBottomSheet() {
    return Container(
      // padding: const EdgeInsets.all(SSizes.spaceBtwSections * 2),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
            topRight: Radius.circular(30), topLeft: Radius.circular(30)),
      ),

      height: SDeviceUtils.getScreenHeight(context) * .4,
      width: SDeviceUtils.getScreenWidth(context),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  buildStatusText(),
                ],
              ),
            ),
          ),
          const SizedBox(height: SSizes.spaceBtwSections),
          buildMicButton(),
        ],
      ),
    );
  }

  Obx buildStatusText() {
    return Obx(() {
      return Container(
        padding: const EdgeInsets.all(SSizes.spaceBtwSections),
        width: MediaQuery.of(context)
            .size
            .width, // Ensures the container takes full width
        child: Text(
          statusText,
          textAlign:
              TextAlign.center, // Optional based on your desired text alignment
          style: Theme.of(context)
              .textTheme
              .titleLarge!
              .copyWith(fontSize: 14, height: 2),
        ),
      );
    });
  }

  Obx buildLastChatResponse() {
    return Obx(() {
      return Text(
        textController.lastChatResponse,
        style: Theme.of(context).textTheme.titleLarge,
      );
    });
  }

  Obx buildMicButton() {
    return Obx(() {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 40.0),
            child: IconButton(
              padding: const EdgeInsets.all(8),
              icon: const Icon(
                Icons.mic,
                color: Colors.white,
              ),
              iconSize: 80,
              onPressed: () {
                // Если isThinking или isSpeaking равно true, просто вернуться
                if (textController.isThinking || textController.isSpeaking) {
                  return;
                } else {
                  speechController.listen(true);
                  textController.lastChatResponse = '';
                  isListeningNotifier.value = speechController.isListening;
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
