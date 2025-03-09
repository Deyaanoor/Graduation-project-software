import 'package:flutter/material.dart';

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: Color(0xFFFF9800),
  scaffoldBackgroundColor: Colors.white,
  textTheme: TextTheme(
    bodyLarge: TextStyle(color: Color(0xFF212121)),
    bodyMedium: TextStyle(color: Color(0xFF424242)),
  ),
  colorScheme: ColorScheme.light(
    primary: Color(0xFFFF9800),
    secondary: Color(0xFFFFB74D),
    background: Colors.white,
    onBackground: Color(0xFF212121),
    surface: Color(0xFFFFFFFF),
    onSurface: Color(0xFF212121),
  ),
);

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: Color(0xFFFF9800),
  scaffoldBackgroundColor: Color(0xFF121212),
  textTheme: TextTheme(
    bodyLarge: TextStyle(color: Color(0xFFE0E0E0)),
    bodyMedium: TextStyle(color: Color(0xFFBDBDBD)),
  ),
  colorScheme: ColorScheme.dark(
    primary: Color(0xFFFF9800),
    secondary: Color(0xFFFFB74D),
    background: Color(0xFF121212),
    onBackground: Color(0xFFE0E0E0),
    surface: Color(0xFF1E1E1E),
    onSurface: Color(0xFFE0E0E0),
  ),
);
