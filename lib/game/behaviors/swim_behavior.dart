import 'dart:math';

import 'package:flame/components.dart';

import '../../data/models/species.dart';

/// 헤엄 알고리즘 (§3). 종별 SwimProfile을 주입받아 구동.
/// v1은 SwimStyle.glide만 구현(§4). 나머지 style은 Phase별로 추가.
///
/// ⚠️ Phase 0 범위: 여기 들어있는 건 "렌더가 도는지" 확인용 최소 wander.
/// 자연스러운 유영/경계 처리/속도 호흡 싱크는 Phase 0~1 본구현에서 정교화.
class SwimBehavior {
  SwimBehavior({required this.profile, Random? rng})
      : _rng = rng ?? Random();

  final SwimProfile profile;
  final Random _rng;

  Vector2 _target = Vector2.zero();
  bool _hasTarget = false;

  /// 속도 배율(기분/호흡 페이즈에서 주입). 1.0 = 평상시.
  double speedFactor = 1.0;

  /// 목표 도달 판정 반경(px). 이 안에 들면 도착으로 보고 즉시 새 목표 지정.
  static const double _arrivalRadius = 14.0;

  /// 디버그 시각화용: 현재 목표 지점(없으면 null).
  Vector2? get target => _hasTarget ? _target.clone() : null;

  void _pickTarget(Vector2 bounds) {
    final margin = 24.0;
    _target = Vector2(
      margin + _rng.nextDouble() * (bounds.x - margin * 2),
      margin + _rng.nextDouble() * (bounds.y - margin * 2),
    );
    _hasTarget = true;
  }

  /// position을 in-place로 갱신. facingRight는 향하는 방향(스프라이트 플립용).
  /// returns: 진행 방향 각도(rad).
  double update(double dt, Vector2 position, Vector2 bounds) {
    // 도착(반경 이내)하면 '즉시' 새 목표 지정. (P0-001: 확률 재선정 지연 제거)
    if (!_hasTarget || position.distanceTo(_target) < _arrivalRadius) {
      _pickTarget(bounds);
    } else if (_rng.nextDouble() < profile.wanderiness * dt * 0.5) {
      // 주행 중 가끔만 변덕스럽게 목표 변경 (wanderiness의 본래 의도, §4).
      _pickTarget(bounds);
    }

    final toTarget = _target - position;
    final dist = toTarget.length;
    final dir = toTarget.normalized();
    final speed = profile.baseSpeed * speedFactor;

    // 남은 거리 이상으로 못 가게 클램프 → 목표 오버슈트/진동 제거 (P0-001).
    final step = min(speed * dt, dist);
    position.add(dir * step);

    return atan2(dir.y, dir.x);
  }
}
