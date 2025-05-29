// web_fcm_setup.dart
import 'dart:html' as html;
import 'package:firebase_messaging/firebase_messaging.dart';

Future<void> setupFCM() async {
  final messaging = FirebaseMessaging.instance;

  if (html.Notification.supported) {
    final permission = await html.Notification.requestPermission();
    print('🔔 html.Notification permission: $permission');
    if (permission != 'granted') return;
  }

  try {
    final registration = await html.window.navigator.serviceWorker
        ?.register('/firebase-messaging-sw.js');
    print('✅ تم تسجيل Service Worker بنجاح: $registration');
  } catch (e) {
    print('❌ فشل تسجيل Service Worker: $e');
  }

  NotificationSettings settings = await messaging.requestPermission();
  print('🔐 Web FCM permission: ${settings.authorizationStatus}');

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('📩 إشعار Web (Foreground): ${message.notification?.title}');
    if (html.Notification.permission == 'granted' &&
        message.notification != null) {
      html.Notification(
        message.notification!.title ?? 'إشعار جديد',
        body: message.notification!.body ?? '',
        icon: message.notification!.android?.imageUrl ??
            '../assets/icon/app_icon.png',
      );
    }
  });
}
