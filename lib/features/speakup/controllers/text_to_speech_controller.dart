import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

class TextToSpeechController extends GetxController {
  final RxString spokenText = ''.obs;
  final RxBool _isSpeaking = false.obs;
  final RxBool _isThinking = false.obs;
  final player = AudioPlayer();
  final RxString _lastChatResponse = ''.obs;

  Future<void> generateText(String inputText, bool onlyListen) async {
    _isThinking.value = true;
    if (onlyListen) {
      _lastChatResponse.value = inputText;
      await speakText(inputText);
      return;
    }
    OpenAI.apiKey = 'sk-proj-PolJysccKgf6teCVSl2vT3BlbkFJmWiAUYbiua0LRYlKZx5U';
    final systemMessage = OpenAIChatCompletionChoiceMessageModel(
      content: [
        OpenAIChatCompletionChoiceMessageContentItemModel.text(
          "Тебя зовут Спичи, это твое имя. Нужно чтобы бот поддерживал разговор (сonversional bot). Он отвечал на вопрос или утверждение от пользователя комментариями и поддерживал диалог, задавая какие то еще то наталкивающие вопросы. Это твой слоган: Привет! Меня зовут Спичи, и я готова с тобой общаться в любое время. Нажми на микрофон, задавай интересующие тебя вопросы или просто расскажи о том, как прошел твой день. Давай дружить и развиваться!",
        ),
      ],
      role: OpenAIChatMessageRole.assistant,
    );

    final userMessage = OpenAIChatCompletionChoiceMessageModel(
      content: [
        OpenAIChatCompletionChoiceMessageContentItemModel.text(
          inputText,
        ),
      ],
      role: OpenAIChatMessageRole.user,
    );

    final requestMessages = [
      systemMessage,
      userMessage,
    ];

    OpenAIChatCompletionModel chatCompletion =
        await OpenAI.instance.chat.create(
      model: "gpt-3.5-turbo-1106",
      responseFormat: {"type": "text"},
      seed: 6,
      messages: requestMessages,
      temperature: 0.2,
      maxTokens: 500,
    );

    // Обработка ответа
    String response =
        chatCompletion.choices.first.message.content?.join() ?? '';
    // print('Ответ от OpenAI: $response');

    // print(chatCompletion.choices.first.message);
    String text = '';
    chatCompletion.choices.first.message.content?.forEach((element) {
      text += element.toString();
    });
    List<String> words = text.split(" ");
    String newText = words.skip(3).join(" ");
    newText =
        newText.substring(0, newText.length - 1); // Удаление последнего символа
    // print(newText);
    _lastChatResponse.value = newText;
    await speakText(newText);
  }

  Future<void> speakText(String message) async {
    // The speech request.
    OpenAI.apiKey = 'sk-proj-PolJysccKgf6teCVSl2vT3BlbkFJmWiAUYbiua0LRYlKZx5U';

    Directory appDocDir = await getApplicationDocumentsDirectory();
    String appDocPath = appDocDir.path;

    File speechFile = await OpenAI.instance.audio.createSpeech(
      model: "tts-1",
      input: message,
      voice: "nova",
      responseFormat: OpenAIAudioSpeechResponseFormat.mp3,
      outputDirectory: await Directory("$appDocPath/speechOutput").create(),
      outputFileName: "anas",
    );
    // The file result.
    // print(speechFile.path);

    await player.play(
        DeviceFileSource(speechFile.path)); // will immediately start playing
    await player.pause(); // immediately pause to get the duration

    final duration = player.getDuration(); // get the duration

    await player.seek(Duration.zero); // seek back to the start
    await player.play(
        DeviceFileSource(speechFile.path)); // will immediately start playing
    _isThinking.value = false;
    _isSpeaking.value = true;

    Duration? durationValue = await duration;
    if (durationValue != null) {
      await Future.delayed(durationValue); // wait for the duration of the audio
    }

    _isSpeaking.value = false;
    // _lastChatResponse.value = '';
    await player.pause();
  }

  bool get isSpeaking => _isSpeaking.value;
  bool get isThinking => _isThinking.value;
  String get lastChatResponse => _lastChatResponse.value;
  set lastChatResponse(String value) {
    _lastChatResponse.value = value;
  }
}
