import 'package:flutter/material.dart';
import 'package:flutter_provider/providers/language_provider.dart';
import 'package:flutter_provider/providers/theamDark_mode.dart';
import 'package:flutter_provider/screens/Technician/settings/AccountSettingsPage.dart';
import 'package:flutter_provider/screens/Technician/settings/ContactInfoPage.dart';
import 'package:flutter_provider/screens/auth/logIn.dart';
import 'package:flutter_provider/screens/auth/signUp.dart';
import 'package:flutter_provider/screens/auth/welcomePage.dart';
import 'package:flutter_provider/screens/Technician/Home/home.dart';
import 'package:flutter_provider/screens/Technician/reports/report.dart';
import 'package:flutter_provider/screens/Technician/AttendancePage.dart';
import 'package:flutter_provider/screens/Technician/SparePartsPage.dart';
import 'package:flutter_provider/screens/Technician/settings/SettingsPage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: "assets/.env");
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final lang = ref.watch(languageProvider);
    final languageNotifier = ref.watch(languageProvider.notifier);

    return MaterialApp(
      title: lang['app_title']!,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: themeMode,
      debugShowCheckedModeBanner: false,
      locale: Locale(languageNotifier.currentLanguageCode),
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
      },
    );
  }
}
