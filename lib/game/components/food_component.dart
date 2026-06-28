import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// 먹이 컴포넌트 (§3, §6 Phase 2). Phase 0/1에선 미사용.
/// 떨어지는 먹이 자리표시 — 도형으로 렌더.
class FoodComponent extends PositionComponent {
  FoodComponent({required Vector2 position})
      : super(position: position, size: Vector2.all(8), anchor: Anchor.center);

  final Paint _paint = Paint()..color = const Color(0xFFB5651D);

  @override
  void render(Canvas canvas) {
    canvas.drawCircle(Offset(size.x / 2, size.y / 2), size.x / 2, _paint);
  }

  // TODO(Phase 2): 중력 낙하 + 금붕어 FeedingProfile 반응.
}
