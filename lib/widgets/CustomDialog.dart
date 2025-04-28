import 'package:flutter/material.dart';

enum MessageType { success, warning, error }

class CustomDialogPage extends StatelessWidget {
  final MessageType type;
  final String title;
  final String content;
  final String buttonText;

  const CustomDialogPage({
    super.key,
    required this.type,
    required this.title,
    required this.content,
    this.buttonText = 'موافق',
  });

  static void show({
    required BuildContext context,
    required MessageType type,
    required String title,
    required String content,
    String buttonText = 'موافق',
  }) {
    showDialog(
      context: context,
      builder: (context) => CustomDialogPage(
        type: type,
        title: title,
        content: content,
        buttonText: buttonText,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    late Color color;
    late IconData icon;

    switch (type) {
      case MessageType.success:
        color = Colors.green.shade800;
        icon = Icons.check_circle;
        break;
      case MessageType.warning:
        color = Colors.orange.shade800;
        icon = Icons.warning_amber_rounded;
        break;
      case MessageType.error:
        color = Colors.red.shade800;
        icon = Icons.error_outline;
        break;
    }

    return AlertDialog(
      icon: Icon(icon, size: 40, color: color),
      iconColor: color.withOpacity(0.2),
      title: Text(
        title,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 22,
        ),
      ),
      content: Text(
        content,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 18),
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(
            foregroundColor: color,
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
            textStyle: const TextStyle(fontSize: 16),
          ),
          child: Text(buttonText),
        ),
      ],
    );
  }
}
