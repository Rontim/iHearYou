import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

class SpeechController extends GetxController {
  var backgroundColor = Colors.black12.obs;
  var isListening = false.obs;
  var errorMessage = ''.obs;

  stt.SpeechToText speech = stt.SpeechToText();
  FlutterTts flutterTts = FlutterTts();

  Timer? _noSpeechTimer;

  @override
  void onInit() {
    super.onInit();
    welcomeUser();
  }

  void welcomeUser() async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(1);
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setVolume(0.5);
    await flutterTts.speak(
        "Welcome User. Press the wavy button to say 'red' or 'blue' to change the background color");
  }

  void startListening() async {
    isListening.value = true;
    bool available = await speech.initialize();

    _startNoSpeechTimer();
    if (available) {
      speech.listen(onResult: (result) {
        handleSpeechResult(result.recognizedWords);
      });
    } else {
      errorMessage.value = "Speech recognition not available";
      isListening.value = false;
    }
  }

  void stopListening() {
    _cancelNoSpeechTimer();
    speech.stop();
    isListening.value = false;
  }

  void handleSpeechResult(String recognizedWords) async {
    _cancelNoSpeechTimer();

    if (recognizedWords.isEmpty) {
      return;
    }
    if (recognizedWords.toLowerCase() == "red") {
      errorMessage.value = "";
      backgroundColor.value = Colors.red;
      isListening.value = false;
      await speak("Here is the red screen");
    } else if (recognizedWords.toLowerCase() == "blue") {
      errorMessage.value = "";
      backgroundColor.value = Colors.blue;
      isListening.value = false;
      await speak("Here is the blue screen");
    } else if (recognizedWords.toLowerCase() != "red" &&
        recognizedWords.toLowerCase() != "blue" &&
        recognizedWords.isNotEmpty) {
      errorMessage.value = "Please say 'red' or 'blue'";
      await speak("Please say 'red' or 'blue'");
    } else {
      errorMessage.value = "";
      backgroundColor.value = Colors.white;
    }

    isListening.value = false;
  }

  Future<void> speak(String message) async {
    await flutterTts.speak(message);
  }

  void _startNoSpeechTimer() {
    _noSpeechTimer =
        Timer(const Duration(seconds: 3), () => _notifyNoSpeechDetected());
  }

  void _cancelNoSpeechTimer() {
    _noSpeechTimer?.cancel();
  }

  @override
  void dispose() {
    speech.stop();
    super.dispose();
  }

  void _notifyNoSpeechDetected() async {
    errorMessage.value = "Please press the button and speak";
    await speak("Please press the button and speak");
    stopListening();
  }
}
