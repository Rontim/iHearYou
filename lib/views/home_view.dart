import 'dart:ui';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../controllers/speech_controller.dart';

class HomeView extends StatelessWidget {
  final SpeechController speechController = Get.put(SpeechController());
  final AudioPlayer audioPlayer = AudioPlayer();

  HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:  Stack(
          children: [
            _buildBackground(),
            _buildContent(),
            _buildAppBar(context),
          ],
        ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Positioned(
      top: kToolbarHeight,
      left: 12,
      width: MediaQuery.of(context).size.width,
      child: Text(
        'I Hear You',
        style: Theme.of(context).textTheme.headlineMedium!.copyWith(color: Colors.white),
      ),
    );
  }

  Widget _buildBackground() {
    return Obx(
      () => AnimatedContainer(
        duration: const Duration(seconds: 1),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              speechController.backgroundColor.value,
              Colors.black,
            ],
          ),
        ),
        child: CustomPaint(
          painter: WavePainter(color: speechController.backgroundColor.value),
          child: Container(),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildAssistantButton(),
          const SizedBox(height: 20),
          _buildListeningText(), // Add Listening text
          const SizedBox(height: 20),
          _buildErrorMessage(),
        ],
      ),
    );
  }

  Widget _buildListeningText() {
    return Obx(
          () {
        if (speechController.isListening.value) {
          return const Text(
            'Listening...',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          );
        }
        return const SizedBox.shrink(); // Return an empty widget if not listening
      },
    );
  }

  Widget _buildErrorMessage() {
    return Obx(
          () {
        if (speechController.errorMessage.isNotEmpty) {
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.8),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              speechController.errorMessage.value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w400,
              ),
            ),
          );
        }
        return const SizedBox.shrink(); // Return an empty widget if there's no error message
      },
    );
  }

  Widget _buildAssistantButton() {
    return Stack(
      alignment: Alignment.center,
      children: [
        _buildButtonBackground(),
        Obx(
          () => SpinKitWave(
            color: speechController.isListening.value ? Colors.blueAccent : Colors.grey,
            size: 50.0,
          ),
        ),
        GestureDetector(
          onTap: () {
            _playTone();
            speechController.startListening();
          },
          child: Container(
            height: 150,
            width: 150,
            decoration: const BoxDecoration(
              color: Colors.transparent,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }


  Widget _buildButtonBackground() {
    return Container(
      height: 150,
      width: 150,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(75),
        gradient: RadialGradient(
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
          stops: const [0.6, 1],
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(75),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(75),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1.5,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _playTone() async {
    await audioPlayer.play(AssetSource('sounds/tone.wav'));
  }
}

class WavePainter extends CustomPainter {
  final Color color;

  WavePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()..color = color.withOpacity(0.2);
    Path path = Path();

    path.moveTo(0, size.height * 0.75);
    path.quadraticBezierTo(
        size.width * 0.25, size.height * 0.60, size.width * 0.5, size.height * 0.75);
    path.quadraticBezierTo(size.width * 0.75, size.height * 0.90, size.width, size.height * 0.75);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
