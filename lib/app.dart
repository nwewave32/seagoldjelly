import 'package:flutter/material.dart';

import 'core/constants.dart';
import 'core/theme.dart';
import 'features/aquarium/aquarium_screen.dart';

/// fps 측정용 성능 오버레이 토글. profile 모드에선 `P` 핫키가 없어 코드로 켠다.
/// 측정이 끝나면 false로 되돌릴 것.
const bool kShowPerfOverlay = false;

/// 앱 루트 — 라우팅·테마 (§3).
/// Phase 0: 어항 화면 단일 진입. 온보딩/페이월 라우팅은 Phase 3에서.
class SeagoldjellyApp extends StatelessWidget {
  const SeagoldjellyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      showPerformanceOverlay: kShowPerfOverlay,
      theme: AppTheme.dark,
      home: const AquariumScreen(),
    );
  }
}
