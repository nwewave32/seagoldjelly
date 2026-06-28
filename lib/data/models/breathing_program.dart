/// 호흡 프로그램 정의 (§3, §6 Phase 1).
/// v1은 4-7-8 1종만 구현(무료). 구독 시 다양한 프로그램(§7).
enum BreathPhase { inhale, hold, exhale }

/// 가이드 문구. 의학적 효능 주장 금지(§9) — 차분한 안내 톤만.
extension BreathPhaseLabel on BreathPhase {
  String get label => switch (this) {
        BreathPhase.inhale => '들이쉬기',
        BreathPhase.hold => '멈추기',
        BreathPhase.exhale => '내쉬기',
      };
}

class BreathingProgram {
  const BreathingProgram({
    required this.id,
    required this.displayName,
    required this.inhale,
    required this.hold,
    required this.exhale,
    this.cycles = 4,
    this.isPremium = false,
  });

  final String id;
  final String displayName;
  final Duration inhale;
  final Duration hold;
  final Duration exhale;
  final int cycles;
  final bool isPremium;

  Duration get cycleDuration => inhale + hold + exhale;

  // 런타임 계산용 초 단위 헬퍼.
  double get inhaleSec => inhale.inMicroseconds / 1e6;
  double get holdSec => hold.inMicroseconds / 1e6;
  double get exhaleSec => exhale.inMicroseconds / 1e6;
  double get cycleSec => inhaleSec + holdSec + exhaleSec;

  /// 전체 세션 길이(초) = 한 사이클 × 사이클 수.
  double get totalSec => cycleSec * cycles;

  /// 4-7-8 (무료 기본). 초 단위.
  static const BreathingProgram fourSevenEight = BreathingProgram(
    id: '478',
    displayName: '4-7-8 호흡',
    inhale: Duration(seconds: 4),
    hold: Duration(seconds: 7),
    exhale: Duration(seconds: 8),
    cycles: 4,
    isPremium: false,
  );
}
