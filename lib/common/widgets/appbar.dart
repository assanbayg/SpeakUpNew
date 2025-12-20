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
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: .08),
        surfaceTintColor: Colors.white,
        backgroundColor: Colors.white,
        centerTitle: false,
        automaticallyImplyLeading: false,
        title: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                  horizontal: SSizes.md, vertical: SSizes.sm / 2),
              child: Text(
                title,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
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
