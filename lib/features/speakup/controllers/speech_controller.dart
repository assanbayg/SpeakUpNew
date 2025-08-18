import 'dart:async';
import 'package:get/get.dart';
// import 'package:azure_speech_recognition_null_safety/azure_speech_recognition_null_safety.dart'; // DISABLED
import 'package:speakup/features/speakup/controllers/text_to_speech_controller.dart';
import 'package:permission_handler/permission_handler.dart';

class SpeechController extends GetxController {
  // late AzureSpeechRecognition _speechAzure; // DISABLED
  bool wasStoppedByUser = false;
  final RxBool _isListening = false.obs;
  final RxString listenText = ''.obs;
  String subKey = '325c5affd8944f2b8a1ab0ce9c9d0817';
  String region = 'southeastasia';
  String lang = 'ru-RU';

  final textConroller = Get.find<TextToSpeechController>();

  void activateSpeechRecognizer(bool onlyListen) {
    // TEMPORARILY DISABLED - Azure Speech Recognition
    /*
    AzureSpeechRecognition.initialize(subKey, region,
        lang: lang, timeout: "1000");

    _speechAzure.setFinalTranscription((text) {
      _isListening.value = false;
      listenText.value = text;
      print(listenText.value);
      AzureSpeechRecognition.stopContinuousRecognition();
    });

    _speechAzure.setRecognitionResultHandler((text) {
      print("Received partial result in recognizer: $text");
      // _isListening.value = false;
    });

    _speechAzure.setRecognitionStartedHandler(() {
      _isListening.value = true;
      print("Recognition started");
    });

    _speechAzure.setRecognitionStoppedHandler(() {
      _isListening.value = false;
      print("Recognition stopped");
      if (!wasStoppedByUser) {
        textConroller.generateText(listenText.value, onlyListen);
      }
    });
    */
    
    // Temporary mock behavior
    print("Speech recognition is temporarily disabled");
  }

  void listen(bool onlyListen) async {
    var status = await Permission.microphone.status;
    if (status.isDenied) {
      // Мы не имеем разрешения на микрофон, уведомляем пользователя
      Get.snackbar('Нет доступа',
          'Пожалуйста, предоставьте доступ к микрофону в настройках');
    } else {
      // TEMPORARILY DISABLED - Mock behavior instead of real speech recognition
      /*
      if (!_isListening.value) {
        _isListening.value = true;
        activateSpeechRecognizer(onlyListen);
        AzureSpeechRecognition.continuousRecording();
      }
      */
      
      // Temporary mock behavior for testing
      if (!_isListening.value) {
        _isListening.value = true;
        print("Mock: Started listening...");
        
        // Simulate listening for 3 seconds then provide mock text
        Future.delayed(Duration(seconds: 3), () {
          _isListening.value = false;
          listenText.value = "Привет, это тестовое сообщение"; // Mock Russian text
          print("Mock: Stopped listening, generated mock text");
          textConroller.generateText(listenText.value, onlyListen);
        });
      }
    }
  }

  void stopListening() {
    // TEMPORARILY DISABLED
    /*
    AzureSpeechRecognition.stopContinuousRecognition();
    */
    
    // Mock behavior
    _isListening.value = false;
    print("Mock: Stopped recognition");
  }

  @override
  void onInit() {
    // TEMPORARILY DISABLED
    // _speechAzure = AzureSpeechRecognition();
    
    print("SpeechController initialized (Azure disabled)");
    super.onInit();
  }

  bool get isListening => _isListening.value;

  set isListening(bool value) {
    _isListening.value = value;
  }
}