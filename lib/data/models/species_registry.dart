import 'package:flutter/painting.dart';

import 'species.dart';

/// v1 종 카탈로그 (§4, §7).
/// 새 종 추가 = 여기 한 줄. 헤엄 로직/컴포넌트는 건드리지 않는다.
class SpeciesRegistry {
  SpeciesRegistry._();

  static const Species goldfishWhite = Species(
    id: 'goldfish_white',
    displayName: '흰 금붕어',
    isPremium: false, // 무료 기본 (§7)
    swim: SwimProfile(
      style: SwimStyle.glide,
      baseSpeed: 38,
      turnRate: 1.5,
      wanderiness: 0.45,
    ),
    emotion: EmotionProfile(
      bodyColor: Color(0xFFF5EFE6),
      finColor: Color(0xFFE8D9C2),
      eyeColor: Color(0xFF2B2B2B),
    ),
    feeding: FeedingProfile(),
  );

  static const Species goldfishBlack = Species(
    id: 'goldfish_black',
    displayName: '검은 금붕어',
    isPremium: false, // §7 표상 '색 해금'은 구독이지만 v1엔 2종 모두 데이터 등록.
    swim: SwimProfile(
      style: SwimStyle.glide,
      baseSpeed: 34,
      turnRate: 1.4,
      wanderiness: 0.55,
    ),
    emotion: EmotionProfile(
      bodyColor: Color(0xFF2A2D34),
      finColor: Color(0xFF3D414A),
      eyeColor: Color(0xFFE0C060),
    ),
    feeding: FeedingProfile(),
  );

  static const List<Species> all = [goldfishWhite, goldfishBlack];

  static Species byId(String id) =>
      all.firstWhere((s) => s.id == id, orElse: () => goldfishWhite);
}
