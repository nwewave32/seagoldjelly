import 'package:flutter/painting.dart';

/// ★ 핵심 추상화 (§3, §4)
/// 생물은 데이터다. 종의 헤엄/감정/먹이 반응을 데이터로 분리해, v2에서
/// 해파리·바다달팽이를 "데이터 한 벌 추가"로 넣을 수 있게 한다.
///
/// v1: goldfish_white(무료), goldfish_black(무료) 2종만 등록.
/// 헤엄 알고리즘은 SwimStyle.glide 하나만 구현. 나머지 style은 enum만 정의.

/// 헤엄 방식. 금붕어=유영(glide), (v2)해파리=박동(pulse)·부유(drift),
/// 바다달팽이=바닥 활주(crawl).
enum SwimStyle { glide, drift, pulse, crawl }

/// 기분 상태. 마지막 방문 시각 기반으로 계산(Phase 2, §6).
enum Mood { happy, calm, gloomy }

/// 헤엄 파라미터. swim_behavior.dart가 이 값을 주입받아 구동한다.
class SwimProfile {
  const SwimProfile({
    this.style = SwimStyle.glide,
    this.baseSpeed = 40,
    this.turnRate = 1.6,
    this.wanderiness = 0.5,
  });

  final SwimStyle style;

  /// 평상시 이동 속도 (logical px/s). 호흡 세션에서 페이즈별로 스케일됨(Phase 1).
  final double baseSpeed;

  /// 방향 전환 민첩도 (rad/s 상한 느낌). 클수록 빠르게 꺾는다.
  final double turnRate;

  /// 변덕스럽게 움직이는 정도 0~1. 클수록 목적지를 자주 바꾼다.
  final double wanderiness;
}

/// 기분을 비주얼 파라미터로 매핑. 애니메이션체이므로 색/속도 배율로 감정 표현.
/// Phase 2에서 눈/표정까지 확장.
class EmotionProfile {
  const EmotionProfile({
    this.bodyColor = const Color(0xFFFFB347),
    this.finColor = const Color(0xFFFF8C2B),
    this.eyeColor = const Color(0xFF1A1A1A),
    this.speedByMood = const {
      Mood.happy: 1.25,
      Mood.calm: 1.0,
      Mood.gloomy: 0.7,
    },
  });

  final Color bodyColor;
  final Color finColor;
  final Color eyeColor;

  /// 기분에 따른 헤엄 속도 배율.
  final Map<Mood, double> speedByMood;

  double speedFactor(Mood mood) => speedByMood[mood] ?? 1.0;
}

/// 먹이 반응 파라미터 (Phase 2, §6 먹이 주기).
class FeedingProfile {
  const FeedingProfile({
    this.approachSpeedFactor = 1.8,
    this.interestRadius = 140,
  });

  /// 먹이를 향해 다가갈 때 속도 배율.
  final double approachSpeedFactor;

  /// 먹이에 반응을 시작하는 거리(logical px).
  final double interestRadius;
}

/// 종 정의. 하드코딩 금지(§1-3) — 모든 개체는 Species를 참조한다.
class Species {
  const Species({
    required this.id,
    required this.displayName,
    required this.swim,
    required this.emotion,
    required this.feeding,
    this.isPremium = false,
  });

  final String id; // 'goldfish_white', 'goldfish_black'
  final String displayName;
  final SwimProfile swim;
  final EmotionProfile emotion;
  final FeedingProfile feeding;

  /// 무료/구독 게이팅 (§7).
  final bool isPremium;
}
