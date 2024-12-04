import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ihearyou/controllers/speech_controller.dart';

class FAppBar extends StatelessWidget implements PreferredSizeWidget {
  const FAppBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final SpeechController controller = Get.find<SpeechController>();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('I Hear You'),
        centerTitle: true,
        backgroundColor: controller.backgroundColor.value,
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}