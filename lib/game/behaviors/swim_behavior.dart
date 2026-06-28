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

  /// 마지막 진행 방향(rad). 목표에 거의 도달해 방향이 불안정할 때 유지용.
  double _lastHeading = 0;

  // ── 외부 자극(터치 등) override ───────────────────────────────
  // 자극이 걸리면 wander를 잠시 무시하고 지정 목표로 향한다(속도 배율 적용).
  Vector2? _overrideTarget;
  double _overrideTimer = 0;
  double _overrideSpeedFactor = 1;

  bool get isStimulated => _overrideTarget != null;

  /// 터치 반응 등에서 호출. 지정 목표로 [duration] 동안 [speedFactor] 배속 이동.
  void applyStimulus({
    required Vector2 target,
    required Duration duration,
    required double speedFactor,
  }) {
    _overrideTarget = target.clone();
    _overrideTimer = duration.inMilliseconds / 1000.0;
    _overrideSpeedFactor = speedFactor;
  }

  /// 디버그 시각화용: 현재 목표 지점(없으면 null).
  Vector2? get target =>
      _overrideTarget ?? (_hasTarget ? _target.clone() : null);

  void _pickTarget(Vector2 bounds) {
    const margin = 24.0;
    _target = Vector2(
      margin + _rng.nextDouble() * (bounds.x - margin * 2),
      margin + _rng.nextDouble() * (bounds.y - margin * 2),
    );
    _hasTarget = true;
  }

  /// position을 in-place로 갱신. facingRight는 향하는 방향(스프라이트 플립용).
  /// returns: 진행 방향 각도(rad).
  double update(double dt, Vector2 position, Vector2 bounds) {
    var speedMul = speedFactor;

    final override = _overrideTarget;
    if (override != null) {
      // 외부 자극(터치) 중: 목표를 자극 지점으로 '고정'(도착 전엔 안 바뀜).
      _overrideTimer -= dt;
      final arrived = position.distanceTo(override) < _arrivalRadius;
      if (arrived || _overrideTimer <= 0) {
        // 도착(또는 안전 타임아웃) → 즉시 종료하고 바로 새 wander 목표.
        // 멈춤 없이 평상 헤엄으로 자연 복귀.
        _overrideTarget = null;
        _pickTarget(bounds);
      } else {
        _target = override;
        _hasTarget = true;
        speedMul = speedFactor * _overrideSpeedFactor; // 이동 중엔 배속
      }
    } else {
      // 평상시 wander. 도착하면 즉시 재선정 (P0-001).
      if (!_hasTarget || position.distanceTo(_target) < _arrivalRadius) {
        _pickTarget(bounds);
      } else if (_rng.nextDouble() < profile.wanderiness * dt * 0.5) {
        // 주행 중 가끔만 변덕스럽게 목표 변경 (wanderiness의 본래 의도, §4).
        _pickTarget(bounds);
      }
    }

    final toTarget = _target - position;
    final dist = toTarget.length;
    final speed = profile.baseSpeed * speedMul;

    // 목표에 거의 도달하면 방향이 불안정 → 이동/방향 갱신 생략, 직전 방향 유지.
    if (dist > 0.01) {
      final dir = toTarget / dist; // normalized (NaN 방지: dist>0 보장)
      final step = min(speed * dt, dist); // 오버슈트 클램프 (P0-001)
      position.add(dir * step);
      _lastHeading = atan2(dir.y, dir.x);
    }

    return _lastHeading;
  }
}
