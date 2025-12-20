import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:speakup/features/speakup/controllers/text_to_speech_controller.dart';
import 'package:speakup/features/speakup/screens/converter_screen.dart';
import 'package:speakup/features/speakup/screens/home_screen.dart';
import 'package:speakup/features/speakup/screens/map_screen.dart';
import 'package:speakup/features/speakup/screens/profile_screen.dart';

class SBottomNavigationBar extends StatelessWidget {
  const SBottomNavigationBar({
    super.key,
    required this.selectedIndex,
  });

  final int selectedIndex;

  void _onItemTapped(int index) {
    final textController = Get.find<TextToSpeechController>();
    textController.lastChatResponse = '';

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

  Widget _buildNavItem(
    BuildContext context,
    String asset,
    String label,
    int index,
  ) {
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: SizedBox(
        width: MediaQuery.of(context).size.width / 4,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              asset,
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(
                Colors.grey.withValues(
                  alpha: .7,
                ),
                BlendMode.srcIn,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: selectedIndex == index ? Colors.blue : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        height: 60,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            _buildNavItem(context, 'assets/icons/Message.svg', 'Спичи', 0),
            _buildNavItem(context, 'assets/icons/Convert.svg', 'Конвертер', 1),
            _buildNavItem(context, 'assets/icons/Map.svg', 'Центры', 2),
            _buildNavItem(context, 'assets/icons/Profile.svg', 'Профайл', 3),
          ],
        ),
      ),
    );
  }
}
