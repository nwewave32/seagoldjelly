import 'package:flutter/material.dart';

import 'core/constants.dart';
import 'core/theme.dart';
import 'features/aquarium/aquarium_screen.dart';

/// 앱 루트 — 라우팅·테마 (§3).
/// Phase 0: 어항 화면 단일 진입. 온보딩/페이월 라우팅은 Phase 3에서.
class SeagoldjellyApp extends StatelessWidget {
  const SeagoldjellyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const AquariumScreen(),
    );
  }
}
