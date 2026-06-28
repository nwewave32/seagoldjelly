import 'package:flutter_test/flutter_test.dart';
import 'package:seagoldjelly/data/models/fish_state.dart';
import 'package:seagoldjelly/data/models/species.dart';
import 'package:seagoldjelly/data/models/species_registry.dart';

void main() {
  group('SpeciesRegistry', () {
    test('v1엔 금붕어 2종이 데이터로 등록된다 (§4)', () {
      expect(SpeciesRegistry.all.length, 2);
      expect(
        SpeciesRegistry.all.map((s) => s.id),
        containsAll(['goldfish_white', 'goldfish_black']),
      );
    });

    test('v1 종은 모두 glide 헤엄만 사용한다 (§4)', () {
      for (final s in SpeciesRegistry.all) {
        expect(s.swim.style, SwimStyle.glide);
      }
    });

    test('byId는 알 수 없는 id에 기본 종을 돌려준다', () {
      expect(SpeciesRegistry.byId('nope').id, SpeciesRegistry.goldfishWhite.id);
    });
  });

  group('FishState.moodAt', () {
    final base = DateTime(2026, 6, 28, 22, 0);

    test('3일 이상 공백이면 시무룩 (§6 Phase 2)', () {
      final s = FishState(
        speciesId: 'goldfish_white',
        lastVisitedAt: base.subtract(const Duration(days: 4)),
      );
      expect(s.moodAt(base), Mood.gloomy);
    });

    test('최근 방문이면 반가움', () {
      final s = FishState(
        speciesId: 'goldfish_white',
        lastVisitedAt: base.subtract(const Duration(hours: 2)),
      );
      expect(s.moodAt(base), Mood.happy);
    });

    test('방문 기록 없으면 평온', () {
      const s = FishState(speciesId: 'goldfish_white');
      expect(s.moodAt(base), Mood.calm);
    });
  });
}
