import 'package:flutter/material.dart';

class AppThemes {
  static final lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: Color(0xFF1565C0), // أزرق داكن
    scaffoldBackgroundColor: Color(0xFFF5F5F5), // رمادي فاتح جدًا
    colorScheme: ColorScheme.light(
      primary: Color(0xFF1565C0), // أزرق داكن
      secondary: Color(0xFFFF9800), // برتقالي
      surface: Color(0xFFFFFFFF), // أبيض
      onPrimary: Colors.white, // نص على الأزرار الزرقاء
      onSecondary: Colors.white, // نص على الأزرار البرتقالية
      onSurface: Color(0xFF222222), // لون النصوص الداكنة
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Color(0xFF1565C0),
      titleTextStyle: TextStyle(
          color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
      iconTheme: IconThemeData(color: Colors.white),
    ),
  );

  static final darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: Color(0xFF222222), // أسود داكن
    scaffoldBackgroundColor: Color(0xFF121212), // رمادي غامق
    colorScheme: ColorScheme.dark(
      primary: Color(0xFF222222), // أسود داكن
      secondary: Color(0xFFE53935), // أحمر
      surface: Color(0xFF121212), // رمادي غامق
      onPrimary: Colors.white, // نص على الأزرار السوداء
      onSecondary: Colors.white, // نص على الأزرار الحمراء
      onSurface: Color(0xFFF5F5F5), // لون النصوص الفاتحة
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Color(0xFF222222),
      titleTextStyle: TextStyle(
          color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
      iconTheme: IconThemeData(color: Colors.white),
    ),
  );
}
