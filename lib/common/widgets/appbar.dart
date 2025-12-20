import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:speakup/features/authentication/screens/login_screen.dart';
import 'package:speakup/util/constants/sizes.dart';
import 'package:speakup/util/device/device_utility.dart';
import 'package:speakup/util/helpers/supabase_helper.dart';

class SAppBar extends StatelessWidget implements PreferredSizeWidget {
  const SAppBar({
    super.key,
    required this.title,
    required this.page,
  });

  final String title;
  final String page;
  @override
  Widget build(BuildContext context) {
    return AppBar(
        centerTitle: false,
        leading: IconButton(
          style: IconButton.styleFrom(
            backgroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          ),
          icon: SvgPicture.asset(
            'assets/icons/Arrow_left.svg',
            width: 24,
            height: 24,
            colorFilter: ColorFilter.mode(
              Colors.grey.withValues(
                alpha: .8,
              ),
              BlendMode.srcIn,
            ),
          ),
          onPressed: () {
            Get.back();
          },
        ),
        title: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                  horizontal: SSizes.md, vertical: SSizes.sm / 2),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.black),
                ),
              ),
              child: Text(title),
            ),
          ],
        ),
        actions: page == 'Profile'
            ? <Widget>[
                IconButton(
                  icon: SvgPicture.asset(
                    'assets/icons/Out_right.svg',
                    width: 24,
                    height: 24,
                  ),
                  onPressed: () async {
                    await SSupabaseHelper.auth.signOut();
                    Get.offAll(const LoginScreen());
                  },
                ),
              ]
            : null,
        iconTheme: const IconThemeData());
  }

  @override
  Size get preferredSize => Size.fromHeight(SDeviceUtils.getAppBarHeight());
}
