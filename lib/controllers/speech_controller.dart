import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

class SpeechController extends GetxController {
  var backgroundColor = Colors.black12.obs;
  var textColor = Colors.white.obs;
  var isListening = false.obs;
  var errorMessage = ''.obs;

  stt.SpeechToText speech = stt.SpeechToText();
  FlutterTts flutterTts = FlutterTts();

  Timer? _noSpeechTimer;

  @override
  void onInit() {
    super.onInit();
    welcomeUser ();
  }

  void welcomeUser () async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(1);
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setVolume(0.5);
    await speak("Welcome User. Press the wavy button to say 'red' or 'blue' to change the background color");
  }

  void startListening() async {
    isListening.value = true;
    bool available = await speech.initialize();

    if (available) {
      _startNoSpeechTimer();
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

    recognizedWords = recognizedWords.toLowerCase();
    if (recognizedWords == "red") {
      backgroundColor.value = Colors.red;
      errorMessage.value = "";
      await speak("Here is the red screen");
    } else if (recognizedWords == "blue") {
      backgroundColor.value = Colors.blue;
      errorMessage.value = "";
      await speak("Here is the blue screen");
    } else {
      errorMessage.value = "Please say 'red' or 'blue'";
      await speak("Please say 'red' or 'blue'");
    }

    isListening.value = false;
  }

  Future<void> speak(String message) async {
    await flutterTts.speak(message);
  }

  void _startNoSpeechTimer() {
    _noSpeechTimer = Timer(const Duration(seconds: 4), () {
      _notifyNoSpeechDetected();
    });
  }

  void _cancelNoSpeechTimer() {
    _noSpeechTimer?.cancel();
  }

  @override
  void dispose() {
    _cancelNoSpeechTimer();
    speech.stop();
    flutterTts.stop(); // Stop TTS if it's currently speaking
    super.dispose();
  }

  void _notifyNoSpeechDetected() async {
    errorMessage.value = "Please press the button and speak";
    await speak("Please press the button and speak");
    stopListening();
  }
}