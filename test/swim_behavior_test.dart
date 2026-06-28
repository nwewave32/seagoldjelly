import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seagoldjelly/data/models/species_registry.dart';
import 'package:seagoldjelly/game/behaviors/swim_behavior.dart';

void main() {
  group('SwimBehavior.clampToArea', () {
    final bounds = Vector2(400, 800);

    SwimBehavior make() {
      final s = SwimBehavior(profile: SpeciesRegistry.goldfishWhite.swim)
        ..minY = 120 // 수면 아래
        ..maxY = 700 // 바텀 네비 위
        ..sideInset = 24;
      return s;
    }

    test('영역 위(수면 위)·왼쪽 밖 점이 영역 안으로 당겨진다', () {
      final s = make();
      final p = s.clampToArea(Vector2(5, 10), bounds);
      expect(p.x, 24); // 좌측 inset
      expect(p.y, 120); // 수면(minY)
    });

    test('영역 아래(네비 아래)·오른쪽 밖 점이 영역 안으로 당겨진다', () {
      final s = make();
      final p = s.clampToArea(Vector2(395, 790), bounds);
      expect(p.x, 400 - 24);
      expect(p.y, 700); // maxY
    });

    test('이미 영역 안인 점은 그대로 둔다', () {
      final s = make();
      final p = s.clampToArea(Vector2(200, 400), bounds);
      expect(p.x, 200);
      expect(p.y, 400);
    });

    test('minY/maxY 미설정 시 화면 경계로 폴백(예외 없음)', () {
      final s = SwimBehavior(profile: SpeciesRegistry.goldfishWhite.swim);
      final p = s.clampToArea(Vector2(-50, -50), bounds);
      expect(p.x.isFinite, isTrue);
      expect(p.y.isFinite, isTrue);
      expect(p.x, greaterThanOrEqualTo(0));
      expect(p.y, greaterThanOrEqualTo(0));
    });
  });
}
