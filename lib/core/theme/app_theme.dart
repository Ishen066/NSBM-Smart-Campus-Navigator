
import 'package:flutter/material.dart';

class AppTheme {
  static const Color navy = Color(0xFF071B35);
  static const Color green = Color(0xFF087F5B);
  static const Color skyBlue = Color(0xFF38BDF8);
  static const Color background = Color(0xFFF4F7FB);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: green,
        primary: green,
        secondary: skyBlue,
        surface: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        foregroundColor: navy,
        elevation: 0,
        centerTitle: false,
      ),
      fontFamily: 'Roboto',
    );
  }
}
