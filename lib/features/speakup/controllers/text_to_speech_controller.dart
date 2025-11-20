import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class TextToSpeechController extends GetxController {
  final RxString spokenText = ''.obs;
  final RxBool _isSpeaking = false.obs;
  final RxBool _isThinking = false.obs;
  final player = AudioPlayer();
  final RxString _lastChatResponse = ''.obs;

  String get backendUrl => dotenv.env['BACKEND_URL'] ?? 'http://localhost:8000';

  Future<void> generateText(String inputText, bool onlyListen) async {
    _isThinking.value = true;

    if (onlyListen) {
      _lastChatResponse.value = inputText;
      await speakText(inputText);
      return;
    }

    try {
      final response = await http
          .post(
        Uri.parse('$backendUrl/chat/sync'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'messages': [
            {
              "role": "system",
              "content":
                  "Тебя зовут Спичи, это твое имя. Нужно чтобы бот поддерживал разговор (сonversional bot). Он отвечал на вопрос или утверждение от пользователя комментариями и поддерживал диалог, задавая какие то еще то наталкивающие вопросы. Это твой слоган: Привет! Меня зовут Спичи, и я готова с тобой общаться в любое время. Нажми на микрофон, задавай интересующие тебя вопросы или просто расскажи о том, как прошел твой день. Давай дружить и развиваться!",
            },
            {"role": "user", "content": inputText},
          ],
          'model': "qwen2.5:0.5b-instruct",
        }),
      )
          .timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException('Request timed out');
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String responseText = '';
        responseText = data['response'].toString();
        _lastChatResponse.value = responseText;
        await speakText(responseText);
      } else {
        throw Exception(
            'Backend returned ${response.statusCode}: ${response.body}');
      }
    } on SocketException {
      _isThinking.value = false;
      Get.snackbar('Ошибка соединения', 'Не удается подключиться к серверу');
    } on TimeoutException {
      _isThinking.value = false;
      Get.snackbar('Превышено время ожидания', 'Сервер не отвечает');
    } catch (e) {
      _isThinking.value = false;
      Get.snackbar('Ошибка', 'Не удалось получить ответ: $e');
      if (kDebugMode) {
        print('Error in generateText: $e');
      }
    }
  }

  Future<void> speakText(String message) async {
    try {
      Directory appDocDir = await getApplicationDocumentsDirectory();
      String appDocPath = appDocDir.path;

      // Call custom backend TTS endpoint
      final response = await http
          .post(
        Uri.parse('$backendUrl/tts'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'text': message,
        }),
      )
          .timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException('TTS request timed out');
        },
      );

      if (response.statusCode == 200) {
        // Save audio file
        final audioDir = Directory('$appDocPath/speechOutput');
        if (!await audioDir.exists()) {
          await audioDir.create(recursive: true);
        }

        final audioFile = File(
            '${audioDir.path}/speech_${DateTime.now().millisecondsSinceEpoch}.mp3');
        await audioFile.writeAsBytes(response.bodyBytes);

        // Play audio
        await player.play(DeviceFileSource(audioFile.path));
        await player.pause();

        final duration = player.getDuration();
        await player.seek(Duration.zero);
        await player.play(DeviceFileSource(audioFile.path));

        _isThinking.value = false;
        _isSpeaking.value = true;

        Duration? durationValue = await duration;
        if (durationValue != null) {
          await Future.delayed(durationValue);
        }

        _isSpeaking.value = false;
        await player.pause();

        // Clean up old audio files to save space
        _cleanupOldAudioFiles(audioDir);
      } else {
        throw Exception('TTS failed with status ${response.statusCode}');
      }
    } on SocketException {
      _isThinking.value = false;
      _isSpeaking.value = false;
      Get.snackbar('Ошибка соединения', 'Не удается подключиться к серверу');
    } on TimeoutException {
      _isThinking.value = false;
      _isSpeaking.value = false;
      Get.snackbar('Превышено время ожидания', 'Сервер не отвечает');
    } catch (e) {
      _isThinking.value = false;
      _isSpeaking.value = false;
      Get.snackbar('Ошибка TTS', 'Не удалось озвучить текст: $e');
      if (kDebugMode) {
        print('Error in speakText: $e');
      }
    }
  }

  // Clean up audio files older than 1 hour to prevent storage bloat
  void _cleanupOldAudioFiles(Directory audioDir) async {
    try {
      final files = audioDir.listSync();
      final now = DateTime.now();

      for (var file in files) {
        if (file is File) {
          final stat = await file.stat();
          final age = now.difference(stat.modified);

          if (age.inHours > 1) {
            await file.delete();
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error cleaning up audio files: $e');
      }
    }
  }

  bool get isSpeaking => _isSpeaking.value;
  bool get isThinking => _isThinking.value;
  String get lastChatResponse => _lastChatResponse.value;

  set lastChatResponse(String value) {
    _lastChatResponse.value = value;
  }

  @override
  void onClose() {
    player.dispose();
    super.onClose();
  }
}
