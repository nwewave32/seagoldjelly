import 'dart:math';

import 'package:flame/components.dart';

/// 터치 반응 (§6 Phase 0).
/// C안: 짧은 탭 → 호기심에 다가옴 / 길게 누름·드래그 → 놀라서 흩어짐.
///
/// 제스처 분류는 입력 레이어(aquarium_game)에서, 여기서는 분류 결과를
/// "헤엄 자극(목표·지속·속도)"으로 변환하는 순수 로직만 담는다.
///
/// 튜닝값은 Phase 0 합의치. 추후 종마다 다르게 하려면 Species로 옮기면 됨
/// (생물은 데이터다, §1-3) — 지금은 단순화를 위해 상수로 둔다(§1-5).
class TouchResponse {
  TouchResponse._();

  // 짧은 탭 vs 길게 누름 구분은 Flutter GestureDetector가 담당한다
  // (onTapUp=다가옴 / onLongPressStart=흩어짐). 임계 시간은 Flutter 기본값.

  /// 다가옴: 탭 지점으로 향하는 시간/속도 배율.
  static const Duration approachDuration = Duration(seconds: 3);
  static const double approachSpeed = 1.8;

  /// 흩어짐: 자극에서 멀어지는 시간/속도 배율(더 짧고 빠르게).
  static const Duration fleeDuration = Duration(milliseconds: 1200);
  static const double fleeSpeed = 2.6;

  /// 흩어질 때 자극 반대 방향으로 도망갈 거리(px).
  static const double fleeDistance = 220;

  /// 자극(stimulus)에서 멀어지는 도주 목표점을 경계 안으로 클램프해 반환.
  static Vector2 fleeTarget(
    Vector2 fishPos,
    Vector2 stimulus,
    Vector2 bounds, {
    double margin = 24,
  }) {
    var dir = fishPos - stimulus;
    if (dir.length2 < 1e-6) {
      // 자극이 물고기 바로 위 → 임의 방향으로 흩어짐.
      final ang = Random().nextDouble() * 2 * pi;
      dir = Vector2(cos(ang), sin(ang));
    }
    dir.normalize();

    final raw = fishPos + dir * fleeDistance;
    return Vector2(
      raw.x.clamp(margin, bounds.x - margin),
      raw.y.clamp(margin, bounds.y - margin),
    );
  }
}
