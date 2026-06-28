import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../data/models/species.dart';
import '../behaviors/swim_behavior.dart';
import '../behaviors/touch_response.dart';

/// 종 데이터로 구동되는 개체 컴포넌트 (§3, §1-3 하드코딩 금지).
///
/// Phase 0 비주얼: 스프라이트 없이 "코드 도형"으로 그린 플레이스홀더 금붕어.
/// 몸통(타원) + 꼬리(삼각형) + 눈. 색은 EmotionProfile에서 가져온다.
/// 스프라이트 도입 시 render()만 교체하면 됨.
class FishComponent extends PositionComponent {
  FishComponent({
    required this.species,
    required Vector2 startPosition,
    this.mood = Mood.calm,
    this.debug = false, // P0-001 디버그 시각화. 원인 확인 후 false로.
  })  : _swim = SwimBehavior(profile: species.swim),
        super(
          position: startPosition,
          size: Vector2(56, 32),
          anchor: Anchor.center,
        );

  final Species species;
  Mood mood;
  final bool debug;

  /// 기울기 중력 벡터(게임에서 매 프레임 주입). 평온 시 0.
  Vector2 gravity = Vector2.zero();

  final SwimBehavior _swim;
  double _facing = 0; // 진행 방향(rad)
  bool _facingLeft = false; // 좌우 반전 상태 (히스테리시스로 유지)
  double _tailPhase = 0;

  // 디버그용 상태 (P0-001)
  bool _inDeadzone = false; // 이번 프레임 진행방향이 데드존(거의 수직)인가
  double _flipFlash = 0; // 좌우가 막 뒤집혔을 때 깜빡일 잔광 타이머
  int _flipCount = 0; // 누적 반전 횟수 (얼마나 자주 뒤집히는지)

  /// 좌우 반전을 갱신할 최소 수평 성분(|dir.x|). 이보다 작으면(거의 수직 이동)
  /// 직전 방향을 유지해 P0-001 깜빡임을 막는다.
  static const double _facingDeadzone = 0.15;

  late final Paint _bodyPaint = Paint()..color = species.emotion.bodyColor;
  late final Paint _finPaint = Paint()..color = species.emotion.finColor;
  late final Paint _eyePaint = Paint()..color = species.emotion.eyeColor;

  @override
  void update(double dt) {
    super.update(dt);
    _swim.speedFactor = species.emotion.speedFactor(mood);
    _swim.gravity = gravity; // 기울기 쏠림 주입
    // 게임 화면 영역 안에서 헤엄. 게임 크기를 경계로 사용.
    final bounds = findGame()?.size ?? Vector2(360, 640);
    _facing = _swim.update(dt, position, bounds);

    // 데드존 + 히스테리시스 (P0-001): 수평 성분이 충분히 클 때만 좌우 갱신.
    // 거의 수직으로 헤엄칠 땐 직전 _facingLeft를 그대로 유지해 깜빡임 제거.
    final horizontal = cos(_facing); // dir.x (정규화됨)
    _inDeadzone = horizontal.abs() <= _facingDeadzone;
    if (!_inDeadzone) {
      final next = horizontal < 0;
      if (next != _facingLeft) {
        _flipCount++;
        _flipFlash = 0.25; // 잔광 시작
      }
      _facingLeft = next;
    }

    if (_flipFlash > 0) _flipFlash -= dt;
    _tailPhase += dt * 8; // 꼬리 흔들림
  }

  /// 헤엄 가능 영역 설정(게임이 매 프레임 주입): 수면 아래 ~ 바텀 네비 위.
  void setSwimArea(double top, double bottom) {
    _swim.minY = top;
    _swim.maxY = bottom;
  }

  /// 짧은 탭: 탭 지점으로 호기심 있게 다가옴 (§6 Phase 0, C안).
  void onTouchApproach(Vector2 worldPoint) {
    final bounds = findGame()?.size ?? Vector2(360, 640);
    _swim.applyStimulus(
      target: _swim.clampToArea(worldPoint, bounds), // 물 밖/네비 아래로 못 감
      duration: TouchResponse.approachDuration,
      speedFactor: TouchResponse.approachSpeed,
    );
  }

  /// 길게 누름·드래그: 자극에서 놀라 흩어짐 (§6 Phase 0, C안).
  void onTouchScatter(Vector2 worldPoint) {
    final bounds = findGame()?.size ?? Vector2(360, 640);
    final flee = TouchResponse.fleeTarget(position, worldPoint, bounds);
    _swim.applyStimulus(
      target: _swim.clampToArea(flee, bounds), // 영역 안으로 제한
      duration: TouchResponse.fleeDuration,
      speedFactor: TouchResponse.fleeSpeed,
    );
  }

  @override
  void render(Canvas canvas) {
    final w = size.x;
    final h = size.y;

    canvas.save();
    canvas.translate(w / 2, h / 2);

    // 진행 방향이 왼쪽이면 좌우 반전(머리가 진행 방향을 향하게).
    // 갱신은 update()의 데드존 로직에서만 일어남 (P0-001).
    if (_facingLeft) canvas.scale(-1, 1);

    // 꼬리 (삼각형, 좌측). 흔들림으로 살아있는 느낌.
    final wag = sin(_tailPhase) * 4;
    final tail = Path()
      ..moveTo(-w * 0.30, 0)
      ..lineTo(-w * 0.50, -h * 0.32 + wag)
      ..lineTo(-w * 0.50, h * 0.32 + wag)
      ..close();
    canvas.drawPath(tail, _finPaint);

    // 위 지느러미 살짝.
    final topFin = Path()
      ..moveTo(0, -h * 0.30)
      ..lineTo(-w * 0.10, -h * 0.52)
      ..lineTo(w * 0.14, -h * 0.30)
      ..close();
    canvas.drawPath(topFin, _finPaint);

    // 몸통 (타원).
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: w * 0.72, height: h * 0.78),
      _bodyPaint,
    );

    // 눈 (머리쪽, 우측).
    canvas.drawCircle(Offset(w * 0.22, -h * 0.06), h * 0.10, _eyePaint);

    canvas.restore();

    if (debug) _renderDebug(canvas);
  }

  /// P0-001 디버그 시각화. 물고기 위에 겹쳐 그린다(좌우 반전 영향 안 받음).
  ///  - 빨간 웨지 = 데드존(거의 수직 콘). 이 안의 진행방향만 좌우 갱신을 막음.
  ///  - 진행방향 선: 데드존 밖=초록(좌우 갱신됨) / 안=노랑(유지).
  ///  - 흰 원 + 선 = 현재 목표 지점. 도달 부근에서 선이 급격히 진동하면
  ///    그게 깜빡임의 진짜 원인(목표 오버슈트로 방향 반전).
  ///  - 빨간 잔광 원 = 방금 좌우가 뒤집힌 순간. flips 숫자는 누적 반전 횟수.
  void _renderDebug(Canvas canvas) {
    final center = Offset(size.x / 2, size.y / 2);
    const r = 90.0;

    // 1) 데드존 경계선 (수직 콘). arcToPoint 대신 직선 4개로 콘을 표시.
    //    이 좁은 콘 안의 진행방향만 좌우 갱신을 막는다 → 콘이 좁다는 걸 눈으로 확인.
    final beta = (pi / 2) - acos(_facingDeadzone);
    final dzPaint = Paint()
      ..color = const Color(0x66FF3B30)
      ..strokeWidth = 1.5;
    for (final centerAngle in [pi / 2, -pi / 2]) {
      for (final s in [-1.0, 1.0]) {
        final a = centerAngle + s * beta;
        canvas.drawLine(
          center,
          center + Offset(cos(a) * r, sin(a) * r),
          dzPaint,
        );
      }
    }

    // 2) 진행방향 선: 데드존 밖=초록(좌우 갱신됨) / 안=노랑(유지).
    final headPaint = Paint()
      ..color = _inDeadzone ? const Color(0xFFFFCC00) : const Color(0xFF34C759)
      ..strokeWidth = 3;
    final headEnd = center + Offset(cos(_facing) * r, sin(_facing) * r);
    canvas.drawLine(center, headEnd, headPaint);
    canvas.drawCircle(headEnd, 3, headPaint);

    // 3) 목표 지점 (월드 좌표 → 로컬). 도달 부근에서 이 선이 진동하면 원인 확정.
    final t = _swim.target;
    if (t != null) {
      final rel = center + Offset(t.x - position.x, t.y - position.y);
      canvas.drawLine(
        center,
        rel,
        Paint()
          ..color = const Color(0xCCFFFFFF)
          ..strokeWidth = 1,
      );
      canvas.drawCircle(rel, 4, Paint()..color = const Color(0xFFFFFFFF));
    }

    // 4) 방금 뒤집힘 잔광.
    if (_flipFlash > 0) {
      canvas.drawCircle(
        center,
        16,
        Paint()
          ..color = Color.fromRGBO(255, 0, 0, (_flipFlash * 3).clamp(0.0, 1.0)),
      );
    }

    // 5) 누적 반전 횟수: TextPainter 대신 막대(폭 ∝ flips, 0~50px).
    //    막대가 길수록 그 개체가 자주 뒤집힌다는 뜻.
    final n = _flipCount.clamp(0, 50).toDouble();
    canvas.drawRect(
      Rect.fromLTWH(center.dx - 25, center.dy - r - 8, n, 3),
      Paint()..color = const Color(0xFFFF9500),
    );

    // 6) 기울기 중력 방향(시안). 실기기에서 좌우/상하 부호 튜닝용.
    if (gravity.length2 > 0) {
      final gEnd = center + Offset(gravity.x, gravity.y);
      canvas.drawLine(
        center,
        gEnd,
        Paint()
          ..color = const Color(0xFF00E5FF)
          ..strokeWidth = 3,
      );
      canvas.drawCircle(gEnd, 3, Paint()..color = const Color(0xFF00E5FF));
    }
  }
}
