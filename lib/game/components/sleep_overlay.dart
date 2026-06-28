import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// 잠듦 연출용 화면 어두워짐 (§5, §6 Phase 1).
/// opacity 0(깨어있음) → 1(잠듦)로 게임이 매 프레임 주입. 최상단 레이어.
class SleepOverlay extends Component {
  SleepOverlay() : super(priority: 1000); // 모든 것 위에.

  /// 0~1. 어두워지는 정도.
  double opacity = 0;

  Vector2 _area = Vector2.zero();

  @override
  void update(double dt) {
    super.update(dt);
    _area = findGame()?.size ?? _area;
  }

  @override
  void render(Canvas canvas) {
    if (opacity <= 0) return;
    final o = opacity.clamp(0.0, 1.0);
    canvas.drawRect(
      Rect.fromLTWH(0, 0, _area.x, _area.y),
      Paint()..color = Color.fromRGBO(2, 6, 16, o), // 거의 검정(아주 어두운 물색)
    );
  }
}
