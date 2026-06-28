import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seagoldjelly/game/behaviors/touch_response.dart';

void main() {
  group('TouchResponse.fleeTarget', () {
    final bounds = Vector2(400, 800);

    test('자극 반대 방향으로 도주 목표가 잡힌다', () {
      final fish = Vector2(200, 400);
      final stimulus = Vector2(150, 400); // 물고기 왼쪽 → 오른쪽으로 도망가야 함
      final flee = TouchResponse.fleeTarget(fish, stimulus, bounds);
      expect(flee.x, greaterThan(fish.x)); // 오른쪽(자극 반대)
    });

    test('도주 목표는 항상 경계(margin) 안으로 클램프된다', () {
      const margin = 24.0;
      // 구석에서 바깥으로 밀려도 경계 안에 있어야 함.
      final fish = Vector2(390, 790);
      final stimulus = Vector2(10, 10);
      final flee = TouchResponse.fleeTarget(fish, stimulus, bounds, margin: margin);
      expect(flee.x, inInclusiveRange(margin, bounds.x - margin));
      expect(flee.y, inInclusiveRange(margin, bounds.y - margin));
    });

    test('자극이 물고기와 같은 위치여도 NaN 없이 유효한 목표를 반환', () {
      final fish = Vector2(200, 400);
      final flee = TouchResponse.fleeTarget(fish, fish.clone(), bounds);
      expect(flee.x.isFinite, isTrue);
      expect(flee.y.isFinite, isTrue);
      expect(flee.x, inInclusiveRange(0, bounds.x));
      expect(flee.y, inInclusiveRange(0, bounds.y));
    });
  });
}
