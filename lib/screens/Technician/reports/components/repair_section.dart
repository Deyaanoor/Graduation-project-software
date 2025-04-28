import 'package:flutter/material.dart';
import 'voice_button_design.dart';

class RepairSection extends StatelessWidget {
  final TextEditingController controller;
  final bool isListening;
  final VoidCallback onVoicePressed;
  final String hint;
  final String voiceLabel;
  final String title;

  const RepairSection({
    super.key,
    required this.controller,
    required this.isListening,
    required this.onVoicePressed,
    required this.hint,
    required this.voiceLabel,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.deepOrange,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.orange, width: 2),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                TextField(
                  controller: controller,
                  maxLines: 5,
                  style: TextStyle(
                    color: Colors.black,
                  ),
                  decoration: InputDecoration(
                    hintText: hint,
                    border: InputBorder.none,
                  ),
                ),
                const SizedBox(height: 10),
                VoiceButtonDesign(
                  isRecording: isListening,
                  onPressed: onVoicePressed,
                  label: voiceLabel,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
