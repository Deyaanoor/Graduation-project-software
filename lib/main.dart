import 'package:flutter/material.dart';
import 'package:flutter_provider/screens/Admin/Garage/garage_page.dart';
import 'package:flutter_provider/screens/Owner/notifications/notifications_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:flutter_provider/providers/language_provider.dart';
import 'package:flutter_provider/screens/Admin/Garage/theamDark_mode.dart';
import 'package:flutter_provider/screens/Technician/settings/AccountSettingsPage.dart';
import 'package:flutter_provider/screens/auth/logIn.dart';
import 'package:flutter_provider/screens/auth/signUp.dart';
import 'package:flutter_provider/screens/auth/welcomePage.dart';
import 'package:flutter_provider/screens/Technician/Home/home.dart';
import 'package:flutter_provider/screens/Technician/reports/report.dart';
import 'package:flutter_provider/screens/Technician/AttendancePage.dart';
import 'package:flutter_provider/screens/Technician/SparePartsPage.dart';
import 'package:flutter_provider/screens/Technician/settings/SettingsPage.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("📩 (خلفية) الرسالة وصلت: ${message.notification?.title}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: "assets/.env");
  await Firebase.initializeApp(
    options: FirebaseOptions(
        apiKey: "AIzaSyAOinh9_tjJiKPaFEpephsFZsg2B7arPnE",
        authDomain: "graduation-notifications.firebaseapp.com",
        projectId: "graduation-notifications",
        storageBucket: "graduation-notifications.firebasestorage.app",
        messagingSenderId: "551572470898",
        appId: "1:551572470898:web:497522afe95d673be156eb"),
  );

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
    _initNotifications();
  }

  void _initNotifications() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // عرض التوكن
    String? token = await messaging.getToken();
    print("✅ FCM Token: $token");

    // عند استقبال رسالة أثناء تشغيل التطبيق
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("💬 رسالة أثناء التشغيل: ${message.notification?.title}");
    });

    // عند فتح التطبيق من الإشعار
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("🚀 تم فتح التطبيق من الإشعار");
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final lang = ref.watch(languageProvider);
    final languageNotifier = ref.watch(languageProvider.notifier);

    final locale = Locale(languageNotifier.currentLanguageCode);

    return MaterialApp(
      title: lang['app_title']!,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: themeMode,
      debugShowCheckedModeBanner: false,
      locale: locale,
      builder: (context, child) => Directionality(
        textDirection: languageNotifier.textDirection,
        child: child!,
      ),
      home: WelcomePage(),
      routes: {
        '/welcome': (context) => WelcomePage(),
        '/login': (context) => LoginPage(),
        '/signup': (context) => SignUpPage(),
        '/home': (context) => Home(),
        '/report': (context) => ReportPage(),
        '/attendance': (context) => AttendanceSalaryPage(),
        '/SparePartsApp': (context) => SparePartsApp(),
        '/settings': (context) => SettingsPage(),
        '/profile': (context) => AccountSettingsPage(),
        '/garage': (context) => GaragePage(),
        '/notifications': (context) => NotificationsPage(),
      },
    );
  }
}
