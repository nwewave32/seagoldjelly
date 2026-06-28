import 'package:flutter/material.dart';

/// 밤·수면용 어두운 톤 테마. (§4 폴리시에서 다듬음)
class AppTheme {
  AppTheme._();

  // 깊은 물색 계열. 자기 전 눈부심을 줄이는 어두운 팔레트.
  static const Color deepWater = Color(0xFF0A1A2F);
  static const Color midWater = Color(0xFF13334F);
  static const Color glow = Color(0xFF6FC3DF);

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: deepWater,
        colorScheme: const ColorScheme.dark(
          primary: glow,
          surface: midWater,
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.white70),
        ),
      );
}
