import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../behaviors/tilt_response.dart';

/// 물 효과 — 가벼운 수준 (§3). 유체 시뮬레이션 아님(§8 금지).
///
/// 기울기(gravity)에 반응하는 최소 시각화:
///  - 수면 라인이 좌우 기울기에 따라 기울고, 앞뒤 기울기에 따라 살짝 오르내림.
///  - 수면 아래를 반투명 그라데이션으로 채워 '물'을 보이게.
///  - 거품 몇 개가 떠오르며 기울기 방향으로 밀린다.
///
/// 자체 size를 쓰지 않고 매 프레임 게임 크기를 읽는다(=화면 전체).
/// 성능: 도형 2개 + 거품 ~14개. 60fps 영향 미미(§1-2).
class WaterEffects extends Component {
  WaterEffects() : super(priority: -10); // 금붕어 뒤에 그린다.

  /// 게임에서 매 프레임 주입하는 기울기 중력 벡터. 평온 시 0.
  Vector2 gravity = Vector2.zero();

  final Random _rng = Random();
  final List<_Bubble> _bubbles = [];

  // 현재 화면 영역(게임 크기). update/render에서 갱신.
  Vector2 _area = Vector2.zero();

  // 물 본체 그라데이션 페인트 캐시(크기 바뀔 때만 재생성).
  Paint? _fillPaint;
  Vector2? _fillSize;

  /// 수면 기준 높이(화면 위에서의 비율). 금붕어 상단 한계 계산에도 쓰인다.
  static const double surfaceFrac = 0.16;

  /// 쏠림 정규화 기준 = 틸트 최대치(단일 출처 참조로 동기화 유지).
  static const double _gReference = TiltResponse.maxMagnitude;

  @override
  Future<void> onLoad() async {
    _area = findGame()?.size ?? Vector2(360, 640);
    for (var i = 0; i < 14; i++) {
      _bubbles.add(_spawnBubble(randomY: true));
    }
  }

  _Bubble _spawnBubble({bool randomY = false}) {
    final surfaceY = _area.y * surfaceFrac;
    return _Bubble(
      pos: Vector2(
        _rng.nextDouble() * _area.x,
        randomY
            ? surfaceY + _rng.nextDouble() * (_area.y - surfaceY)
            : _area.y - 4,
      ),
      radius: 1.5 + _rng.nextDouble() * 2.5,
      speed: 14 + _rng.nextDouble() * 26,
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    _area = findGame()?.size ?? _area;
    if (_area.x <= 0 || _area.y <= 0) return;

    final surfaceY = _area.y * surfaceFrac;
    for (var i = 0; i < _bubbles.length; i++) {
      final b = _bubbles[i];
      b.pos.y -= b.speed * dt; // 떠오름
      b.pos.x += gravity.x * dt * 0.7; // 기울기 방향으로 밀림
      if (b.pos.y < surfaceY || b.pos.x < 0 || b.pos.x > _area.x) {
        _bubbles[i] = _spawnBubble();
      }
    }
  }

  @override
  void render(Canvas canvas) {
    final w = _area.x;
    final h = _area.y;
    if (w <= 0 || h <= 0) return;

    final baseY = h * surfaceFrac;

    // 좌우 기울기 → 수면 경사. 앞뒤 기울기 → 수면 전체 높이 살짝 변동.
    final maxTilt = h * 0.12;
    final dy = (gravity.x / _gReference * maxTilt).clamp(-maxTilt, maxTilt);
    final lift =
        (gravity.y / _gReference * (h * 0.04)).clamp(-h * 0.04, h * 0.04);

    final leftY = baseY - dy + lift;
    final rightY = baseY + dy + lift;

    // 물 본체(수면 아래) 반투명 그라데이션.
    final body = Path()
      ..moveTo(0, leftY)
      ..lineTo(w, rightY)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(body, _bodyFill(w, h));

    // 수면 하이라이트 라인.
    canvas.drawLine(
      Offset(0, leftY),
      Offset(w, rightY),
      Paint()
        ..color = const Color(0x886FC3DF)
        ..strokeWidth = 2,
    );

    // 거품.
    final bubblePaint = Paint()..color = const Color(0x55BFE8F5);
    for (final b in _bubbles) {
      canvas.drawCircle(Offset(b.pos.x, b.pos.y), b.radius, bubblePaint);
    }
  }

  /// 크기 변동 시에만 그라데이션 셰이더를 재생성(매 프레임 할당 방지).
  Paint _bodyFill(double w, double h) {
    if (_fillPaint == null || _fillSize?.x != w || _fillSize?.y != h) {
      _fillPaint = Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0x3340A4C8), Color(0x66103A5E)],
        ).createShader(Rect.fromLTWH(0, 0, w, h));
      _fillSize = Vector2(w, h);
    }
    return _fillPaint!;
  }
}

class _Bubble {
  _Bubble({required this.pos, required this.radius, required this.speed});

  final Vector2 pos;
  final double radius;
  final double speed;
}
