import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:speakup/features/authentication/screens/login_screen.dart';
import 'package:speakup/features/speakup/controllers/text_to_speech_controller.dart';
import 'package:speakup/features/speakup/screens/profile_page.dart';
import 'package:speakup/firebase_options.dart';
import 'package:speakup/util/helpers/firebase_hepler.dart';
import 'package:speakup/util/theme/theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// TODO: FIX BUG
// when signing out and signing in, i get some TTS error
Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  // TODO: remove when cleaning up repo
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug,
    appleProvider: AppleProvider.debug,
  );
  Get.lazyPut(() => TextToSpeechController());

  runApp(const SpeakUp());
}

class SpeakUp extends StatelessWidget {
  const SpeakUp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      theme: STheme.sTheme,
      debugShowCheckedModeBanner: false,
      home: SFireHelper.fireAuth.currentUser != null
          // ? const HomeScreen()
          // ? const MapScreen(text: "")
          ? const UserProfilePage()
          : const LoginScreen(),
    );
  }
}
