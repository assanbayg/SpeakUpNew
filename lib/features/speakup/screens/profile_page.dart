import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:speakup/common/widgets/appbar.dart';
import 'package:speakup/features/authentication/screens/login_screen.dart';
import 'package:speakup/features/speakup/models/user_model.dart';
import 'package:speakup/features/speakup/screens/converter_screen.dart';
import 'package:speakup/features/speakup/screens/home_screen.dart';
import 'package:speakup/features/speakup/screens/map_screen.dart';
import 'package:speakup/util/helpers/helper_functions.dart';
import 'package:speakup/util/helpers/supabase_helper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  int _selectedIndex = 3;
  UserModel? userModel;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Load user data from Supabase
  Future<void> _loadUserData() async {
    try {
      if (SSupabaseHelper.currentUser != null) {
        final response = await SSupabaseHelper.client
            .from('users')
            .select()
            .eq('id', SSupabaseHelper.currentUser!.id)
            .single();

        setState(() {
          userModel = UserModel.fromJson(response);
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      SHelperFunctions.showSnackBar('Error loading user data: $e');
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0:
        Get.to(const HomeScreen());
        break;
      case 1:
        Get.to(ConverterScreen());
        break;
      case 2:
        Get.to(const MapScreen(text: ""));
        break;
      case 3:
        Get.to(const UserProfilePage());
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
                color: _selectedIndex == index ? Colors.blue : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final User? user = SSupabaseHelper.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('Пожалуйста, войдите в систему для доступа к профилю.'),
        ),
      );
    }

    return Scaffold(
      appBar: const SAppBar(title: "Профиль", page: "Profile"),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 80,
              backgroundColor: Colors.grey,
              child: Icon(Icons.person, size: 80, color: Colors.white),
            ),
            const SizedBox(height: 20),
            if (userModel?.displayName.isNotEmpty == true)
              Text(
                userModel!.displayName,
                style: const TextStyle(
                  fontSize: 22,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: 10),
            Text(
              user.email ?? 'Нет электронной почты',
              style: const TextStyle(
                fontSize: 18,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 3.0),
                child: ElevatedButton(
                  onPressed: () => _confirmDeleteAccount(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: 3.0, horizontal: 3.0),
                    child: Text(
                      'Удалить аккаунт',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SizedBox(
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
    );
  }

  // Confirmation dialog for account deletion
  void _confirmDeleteAccount() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Подтвердите удаление'),
          content: const Text(
              'Вы уверены, что хотите удалить свой аккаунт? Это действие необратимо.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Отмена'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                _deleteAccount(); // Proceed with deletion
              },
              child: const Text('Удалить'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteAccount() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user != null) {
      try {
        // Call your FastAPI backend
        final response = await http.post(
          Uri.parse("${dotenv.env['VAR_NAME']}/delete-user"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({"user_id": user.id}),
        );

        if (response.statusCode == 200) {
          await supabase.auth.signOut();
          Get.offAll(const LoginScreen());
          Get.snackbar('Успех', 'Аккаунт успешно удален.');
        } else {
          Get.snackbar('Ошибка', 'Сервер вернул ошибку: ${response.body}');
        }
      } catch (e) {
        Get.snackbar('Ошибка', 'Не удалось удалить аккаунт: $e');
      }
    }
  }
}
