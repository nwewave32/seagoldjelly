import 'package:flutter/material.dart';

/// 구독 화면 (§3, §6 Phase 3, §9 컴플라이언스).
/// 필수 고지: 무료체험·자동갱신·해지방법(심사 필수). RevenueCat 권장 구현 따를 것.
/// ⚠️ 카피: 의학적 효능 주장 금지(§9).
class PaywallScreen extends StatelessWidget {
  const PaywallScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      const Center(child: Text('구독 (Phase 3) — 자동갱신/해지방법 고지 필수'));
}
