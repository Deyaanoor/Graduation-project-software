import 'dart:html' as html;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_provider/screens/Admin/Garage/apply_Request.dart';

import 'package:flutter_provider/screens/Admin/Garage/garage_page.dart';
import 'package:flutter_provider/screens/Owner/notifications/notifications_screen.dart';
import 'package:flutter_provider/screens/auth/forgotPassword.dart';
import 'package:flutter_provider/screens/Client/roboflow_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:flutter_provider/providers/language_provider.dart';

import 'package:flutter_provider/screens/Admin/Garage/theamDark_mode.dart';
import 'package:flutter_provider/screens/Technician/AttendancePage.dart';
import 'package:flutter_provider/screens/Technician/Home/home.dart';
import 'package:flutter_provider/screens/Technician/SparePartsPage.dart';
import 'package:flutter_provider/screens/Technician/reports/report.dart';
import 'package:flutter_provider/screens/Technician/settings/AccountSettingsPage.dart';
import 'package:flutter_provider/screens/Technician/settings/SettingsPage.dart';
import 'package:flutter_provider/screens/auth/logIn.dart';
import 'package:flutter_provider/screens/auth/signUp.dart';
import 'package:flutter_provider/screens/auth/welcomePage.dart';

// const firebaseConfig = FirebaseOptions(
//   apiKey: "AIzaSyAOinh9_tjJiKPaFEpephsFZsg2B7arPnE",
//   authDomain: "graduation-notifications.firebaseapp.com",
//   projectId: "graduation-notifications",
//   storageBucket: "graduation-notifications.appspot.com",
//   messagingSenderId: "551572470898",
//   appId: "1:551572470898:web:f7a8b6ea8ab00522e156eb",
// );

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   if (kIsWeb) {
//     await Firebase.initializeApp(options: firebaseConfig);
//   } else {
//     await Firebase.initializeApp();
//   }

//   await dotenv.load();

//   if (kIsWeb) {
//     await setupWebFCM();
//   }

//   runApp(const ProviderScope(child: MyApp()));
// }

// Future<void> setupWebFCM() async {
//   final messaging = FirebaseMessaging.instance;

//   // ✅ طلب إذن إشعارات عبر dart:html
//   if (html.Notification.supported) {
//     final permission = await html.Notification.requestPermission();
//     print('🔔 html.Notification permission: $permission');

//     if (permission != 'granted') {
//       print('❌ الإذن غير ممنوح من المستخدم.');
//       return;
//     }
//   }

//   // ✅ تسجيل Service Worker
//   try {
//     final registration = await html.window.navigator.serviceWorker
//         ?.register('/firebase-messaging-sw.js');
//     print('✅ تم تسجيل Service Worker بنجاح: $registration');
//   } catch (e) {
//     print('❌ فشل تسجيل Service Worker: $e');
//     return;
//   }

//   NotificationSettings settings = await messaging.requestPermission();
//   print('🔐 FirebaseMessaging permission: ${settings.authorizationStatus}');

//   FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//     print('📩 إشعار في المقدمة: ${message.notification?.title}');
//     if (html.Notification.permission == 'granted' &&
//         message.notification != null) {
//       html.Notification(
//         message.notification!.title ?? 'إشعار جديد',
//         body: message.notification!.body ?? '',
//         icon: message.notification!.android?.imageUrl ??
//             '../assets/icon/app_icon.png',
//       );
//     }
//   });
// }

const firebaseConfig = FirebaseOptions(
  apiKey: "AIzaSyAOinh9_tjJiKPaFEpephsFZsg2B7arPnE",
  authDomain: "graduation-notifications.firebaseapp.com",
  projectId: "graduation-notifications",
  storageBucket: "graduation-notifications.appspot.com",
  messagingSenderId: "551572470898",
  appId: "1:551572470898:web:f7a8b6ea8ab00522e156eb",
);

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("📩 إشعار بالخلفية (Mobile): ${message.notification?.title}");
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    await Firebase.initializeApp(options: firebaseConfig);
  } else {
    await Firebase.initializeApp();
  }

  await dotenv.load();

  if (kIsWeb) {
    await setupWebFCM();
  } else {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    setupMobileFCM();
  }

  runApp(const ProviderScope(child: MyApp()));
}

Future<void> setupWebFCM() async {
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

void setupMobileFCM() {
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('📥 إشعار Mobile (Foreground): ${message.notification?.title}');
    // أضف عرض Snackbar أو إشعار محلي إذا أردت
  });

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print(
        '📲 تم فتح التطبيق من إشعار (Mobile): ${message.notification?.title}');
    // أضف التنقل لصفحة معينة إذا لزم
  });
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final lang = ref.watch(languageProvider);
    final languageNotifier = ref.watch(languageProvider.notifier);
    final locale = Locale(languageNotifier.currentLanguageCode);

    return MaterialApp(
      title: lang['app_title'] ?? 'App',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: themeMode,
      debugShowCheckedModeBanner: false,
      locale: locale,
      builder: (context, child) => Directionality(
        textDirection: languageNotifier.textDirection,
        child: child!,
      ),
      home: const WelcomePage(),
      routes: {
        '/welcome': (context) => const WelcomePage(),
        '/login': (context) => LoginPage(),
        '/signup': (context) => SignUpPage(),
        '/Apply_Request': (context) => ApplyRequestPage(),
        '/home': (context) => Home(),
        '/report': (context) => ReportPage(),
        '/attendance': (context) => AttendanceSalaryPage(),
        '/SparePartsApp': (context) => SparePartsApp(),
        '/settings': (context) => SettingsPage(),
        '/profile': (context) => AccountSettingsPage(),
        '/garage': (context) => GaragePage(),
        '/notifications': (context) => const NotificationsPage(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/roboflow': (context) => const RoboflowScreen(),
      },
    );
  }
}
