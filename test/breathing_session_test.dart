import 'package:flutter_test/flutter_test.dart';
import 'package:seagoldjelly/data/models/breathing_program.dart';
import 'package:seagoldjelly/features/breathing/breathing_session.dart';

void main() {
  const p = BreathingProgram.fourSevenEight; // 4-7-8, 4사이클

  // 시작 후 지정 시점(초)으로 진행시킨 세션을 만든다.
  BreathingSession at(double seconds) {
    final s = BreathingSession(p)..start();
    s.tick(seconds);
    return s;
  }

  group('BreathingProgram 4-7-8', () {
    test('초 단위 헬퍼와 전체 길이', () {
      expect(p.inhaleSec, 4);
      expect(p.holdSec, 7);
      expect(p.exhaleSec, 8);
      expect(p.cycleSec, 19);
      expect(p.totalSec, 76); // 19 × 4
    });

    test('페이즈 라벨', () {
      expect(BreathPhase.inhale.label, '들이쉬기');
      expect(BreathPhase.hold.label, '멈추기');
      expect(BreathPhase.exhale.label, '내쉬기');
    });
  });

  group('BreathingSession 페이즈/확장값', () {
    test('들숨 중반: progress·expansion 0.5', () {
      final st = at(2).state; // 들숨 4s 중 2s
      expect(st.phase, BreathPhase.inhale);
      expect(st.phaseProgress, closeTo(0.5, 1e-9));
      expect(st.expansion, closeTo(0.5, 1e-9)); // 확장 중
    });

    test('멈춤: expansion 1 유지', () {
      final st = at(4 + 3).state; // 들숨4 + 멈춤 3s째
      expect(st.phase, BreathPhase.hold);
      expect(st.expansion, 1);
    });

    test('날숨 중반: 수축으로 expansion 0.5', () {
      final st = at(4 + 7 + 4).state; // 날숨 8s 중 4s
      expect(st.phase, BreathPhase.exhale);
      expect(st.phaseProgress, closeTo(0.5, 1e-9));
      expect(st.expansion, closeTo(0.5, 1e-9)); // 수축 중
    });

    test('사이클 경계에서 다음 사이클 들숨으로', () {
      final st = at(19).state; // 두 번째 사이클 시작
      expect(st.cycleIndex, 1);
      expect(st.phase, BreathPhase.inhale);
    });
  });

  group('BreathingSession 진행/완료', () {
    test('완료되면 정지 + isComplete + 수축 끝(expansion 0)', () {
      final s = BreathingSession(p)..start();
      s.tick(80); // 총 76s 초과
      expect(s.isRunning, isFalse);
      expect(s.isComplete, isTrue);
      expect(s.progress, 1);
      final st = s.state;
      expect(st.phase, BreathPhase.exhale);
      expect(st.expansion, closeTo(0, 1e-9));
    });

    test('정지 상태에서는 tick이 진행되지 않는다', () {
      final s = BreathingSession(p); // start 안 함
      s.tick(5);
      expect(s.elapsedSec, 0);
    });
  });
}
