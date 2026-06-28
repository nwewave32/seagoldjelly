import 'package:flutter/material.dart';

/// 호흡 세션 화면/오버레이 (§3, §6 Phase 1).
/// Phase 1: 4-7-8 싱크 + 확장/수축 시각 가이드 + 금붕어 헤엄 속도 싱크.
/// Phase 0에선 자리표시.
class BreathingScreen extends StatelessWidget {
  const BreathingScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      const Center(child: Text('호흡 세션 (Phase 1)'));
}
