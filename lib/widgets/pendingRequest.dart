import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_provider/providers/auth/auth_provider.dart';

Future<void> showPendingRequestDialog(BuildContext context, String message,
    Map<String, dynamic> lang, WidgetRef ref) {
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;

  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 16,
      backgroundColor: theme.cardColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.hourglass_top_rounded,
                color: Colors.amber[800], size: 64),
            const SizedBox(height: 16),
            Text(
              lang['requestprocessTitle'] ?? 'طلبك قيد المعالجة',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.amber[900],
                letterSpacing: 1.2,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.grey[200] : Colors.grey[800],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.amber[900],
                    textStyle: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    ref.read(logoutProvider)();
                    Navigator.of(context).pop();
                  },
                  child: Text(lang['ok'] ?? 'حسناً'),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
