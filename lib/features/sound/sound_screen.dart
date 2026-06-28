import 'package:flutter/material.dart';

/// 사운드 + 타이머 (§3, §6 Phase 1).
/// Phase 1: 루프 사운드 2~3종 + 수면 타이머 + 자동 페이드아웃.
/// 무료 1종 / 15분 제한(§7).
class SoundScreen extends StatelessWidget {
  const SoundScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      const Center(child: Text('사운드 + 타이머 (Phase 1)'));
}
