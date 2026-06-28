import '../../data/models/breathing_program.dart';

/// 한 시점의 호흡 상태(가이드/금붕어 싱크가 소비하는 값).
class BreathState {
  const BreathState({
    required this.phase,
    required this.phaseProgress,
    required this.expansion,
    required this.cycleIndex,
    required this.isComplete,
  });

  /// 현재 페이즈(들숨/멈춤/날숨).
  final BreathPhase phase;

  /// 현재 페이즈 내 진행도 0..1.
  final double phaseProgress;

  /// 가이드 크기 0..1 — 들숨 0→1(확장), 멈춤 1(유지), 날숨 1→0(수축).
  /// 시각 가이드의 원 크기·금붕어 속도 싱크에 그대로 쓰면 된다.
  final double expansion;

  /// 0-based 사이클 번호.
  final int cycleIndex;

  /// 세션 전체 완료 여부.
  final bool isComplete;
}

/// 호흡 세션 런타임 (§6 Phase 1).
/// 프로그램(예: 4-7-8)을 받아 tick(dt)으로 시간을 진행시키며 현재 상태를 계산한다.
/// Flutter/Flame 의존이 없는 순수 로직 → 게임·UI 양쪽에서 쓰고 테스트도 쉽다.
class BreathingSession {
  BreathingSession(this.program);

  final BreathingProgram program;

  double _elapsed = 0; // 세션 시작부터 누적 시간(초)
  bool _running = false;

  bool get isRunning => _running;
  double get elapsedSec => _elapsed;

  /// 세션 전체 진행도 0..1.
  double get progress {
    final total = program.totalSec;
    if (total <= 0) return 1;
    return (_elapsed / total).clamp(0.0, 1.0);
  }

  bool get isComplete => _elapsed >= program.totalSec;

  void start() => _running = true;
  void pause() => _running = false;

  void reset() {
    _elapsed = 0;
    _running = false;
  }

  /// dt(초)만큼 진행. 완료되면 자동 정지.
  void tick(double dt) {
    if (!_running) return;
    _elapsed += dt;
    if (_elapsed >= program.totalSec) {
      _elapsed = program.totalSec;
      _running = false;
    }
  }

  /// 현재 호흡 상태 계산.
  BreathState get state {
    final cycleSec = program.cycleSec;
    if (cycleSec <= 0) {
      return const BreathState(
        phase: BreathPhase.inhale,
        phaseProgress: 1,
        expansion: 0,
        cycleIndex: 0,
        isComplete: true,
      );
    }

    final complete = isComplete;
    // 완료 시 마지막 상태(수축 끝)에서 정지.
    final t = complete ? program.totalSec : _elapsed;
    final cycleIndex = complete
        ? program.cycles - 1
        : (t ~/ cycleSec).clamp(0, program.cycles - 1);

    var inCycle = t - cycleIndex * cycleSec; // 현재 사이클 내 경과(초)
    if (inCycle >= cycleSec) inCycle = cycleSec; // 완료 보정

    final inhale = program.inhaleSec;
    final hold = program.holdSec;

    if (inCycle < inhale) {
      final p = inhale <= 0 ? 1.0 : inCycle / inhale;
      return BreathState(
        phase: BreathPhase.inhale,
        phaseProgress: p,
        expansion: p, // 0→1 확장
        cycleIndex: cycleIndex,
        isComplete: complete,
      );
    }
    if (inCycle < inhale + hold) {
      final p = hold <= 0 ? 1.0 : (inCycle - inhale) / hold;
      return BreathState(
        phase: BreathPhase.hold,
        phaseProgress: p,
        expansion: 1, // 유지
        cycleIndex: cycleIndex,
        isComplete: complete,
      );
    }
    final exhale = program.exhaleSec;
    final p = exhale <= 0 ? 1.0 : (inCycle - inhale - hold) / exhale;
    return BreathState(
      phase: BreathPhase.exhale,
      phaseProgress: p.clamp(0.0, 1.0),
      expansion: (1 - p).clamp(0.0, 1.0), // 1→0 수축
      cycleIndex: cycleIndex,
      isComplete: complete,
    );
  }
}
