import 'package:flutter/material.dart';

/// 온보딩 (§3, §6 Phase 3). 왜 자기 전에 쓰는지 1~3 스텝.
/// ⚠️ 카피: 의학적 효능 주장 금지(§9). "힐링/이완/잠들기 좋은" OK.
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      const Center(child: Text('온보딩 (Phase 3)'));
}
