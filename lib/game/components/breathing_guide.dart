import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// 호흡 시각 가이드 (§6 Phase 1).
/// expansion(0~1)에 따라 크기가 변하는 미니멀한 원 — 들숨에 커지고 날숨에 작아진다.
/// 사용자가 이 원에 맞춰 호흡을 따라가게 한다.
///
/// 자체 size를 쓰지 않고 매 프레임 게임 크기를 읽는다(WaterEffects와 동일 패턴).
class BreathingGuide extends Component {
  BreathingGuide() : super(priority: 50); // 금붕어/물 위에 그린다.

  /// 0~1. 게임이 호흡 세션 상태로 매 프레임 갱신.
  double expansion = 0;

  /// 호흡 세션 중에만 표시.
  bool visible = false;

  Vector2 _area = Vector2.zero();

  @override
  void update(double dt) {
    super.update(dt);
    _area = findGame()?.size ?? _area;
  }

  @override
  void render(Canvas canvas) {
    if (!visible) return;
    final w = _area.x;
    final h = _area.y;
    if (w <= 0 || h <= 0) return;

    final center = Offset(w / 2, h * 0.42); // 화면 중앙 약간 위
    final minR = w * 0.12;
    final maxR = w * 0.32;
    final r = minR + (maxR - minR) * expansion.clamp(0.0, 1.0);

    // 옅은 채움 + 외곽 링.
    canvas.drawCircle(center, r, Paint()..color = const Color(0x1A6FC3DF));
    canvas.drawCircle(
      center,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = const Color(0x886FC3DF),
    );
  }
}
