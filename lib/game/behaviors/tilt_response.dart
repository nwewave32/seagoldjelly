import 'package:flame/components.dart';

/// 기울기(가속도계) 반응 (§6 Phase 0). 물/금붕어가 기울기에 반응.
/// Phase 0 본구현에서 sensors_plus 스트림을 구독해 gravity 벡터로 전달.
/// 여기선 자리표시 — 게임 측에서 setGravity로 주입할 수 있게만 열어둠.
class TiltResponse {
  Vector2 gravity = Vector2.zero();

  void setFromAccelerometer(double x, double y) {
    // 화면 좌표계로 매핑(아래가 +y). 계수는 Phase 0에서 튜닝.
    gravity = Vector2(-x, y) * 6.0;
  }
}
