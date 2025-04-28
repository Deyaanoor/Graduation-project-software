import 'package:flutter/material.dart';

class AIDesktopButton extends StatelessWidget {
  final VoidCallback onPressed;

  const AIDesktopButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent, // No solid color
        foregroundColor: Colors.white,
        elevation: 10,
        shadowColor: Colors.orange.withOpacity(0.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
        side: BorderSide(color: Colors.orange, width: 2),
      ),
      onPressed: onPressed,
      child: Ink(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFF6F00), Color(0xFFFFA000)], // Orange gradient
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Container(
          constraints: BoxConstraints(maxWidth: 200, maxHeight: 50),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.android,
                  color: Colors.white), // AI Icon (can be replaced)
              SizedBox(width: 10),
              Text(
                'AI تحليل',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
