import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class SBottomNavigationBar extends StatelessWidget {
  const SBottomNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  final int selectedIndex;
  final ValueChanged<int> onItemTapped;

  Widget _buildNavItem(
    BuildContext context,
    String asset,
    String label,
    int index,
  ) {
    return GestureDetector(
      onTap: () => onItemTapped(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            asset,
            width: 24,
            height: 24,
            colorFilter: ColorFilter.mode(
              selectedIndex == index ? Colors.blue : Colors.grey,
              BlendMode.srcIn,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: selectedIndex == index ? Colors.blue : Colors.grey,
              fontWeight: selectedIndex == index ? FontWeight.w600 : null,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildNavItems(BuildContext context) {
    return [
      _buildNavItem(context, 'assets/icons/Message.svg', 'Спичи', 0),
      _buildNavItem(context, 'assets/icons/Convert.svg', 'Конвертер', 1),
      _buildNavItem(context, 'assets/icons/Map.svg', 'Центры', 2),
      _buildNavItem(context, 'assets/icons/Profile.svg', 'Профайл', 3),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .05),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: _buildNavItems(context)
              .map((item) => Expanded(child: item))
              .toList(),
        ),
      ),
    );
  }
}
