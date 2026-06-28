import 'package:flame/components.dart';

/// 터치 반응 (§6 Phase 0). 손가락 쪽으로 다가오거나 흩어지는 반응.
/// Phase 0 본구현에서 swim_behavior와 결합. 여기선 인터페이스 자리표시.
class TouchResponse {
  TouchResponse({this.attract = true, this.strength = 1.0});

  /// true=다가옴, false=흩어짐.
  final bool attract;
  final double strength;

  /// TODO(Phase 0): tapPoint 기준 가속도/목표 갱신 계산.
  Vector2 influence(Vector2 fishPos, Vector2 tapPoint) => Vector2.zero();
}
