import 'dart:async';

import 'package:flame/game.dart';
import 'package:flutter/widgets.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../data/models/species.dart';
import 'behaviors/tilt_response.dart';
import 'components/fish_component.dart';
import 'components/water_effects.dart';

/// FlameGame 본체 (§3). 어항 + 금붕어.
///
/// Phase 0: 종 데이터로 만든 금붕어 1마리 + 터치 반응(C안).
/// 입력은 화면 위젯의 GestureDetector(aquarium_screen)에서 받아
/// 아래 public 핸들러로 좌표를 넘긴다 — Flame 이벤트 시스템 우회로 가장 안정적.
///
/// 좌표계: 금붕어는 게임 루트(스크린 좌표, 논리픽셀)에 있고, GestureDetector의
/// localPosition도 동일 논리픽셀이라 그대로 매핑된다.
class AquariumGame extends FlameGame {
  AquariumGame({required this.species});

  final Species species;

  late FishComponent _fish;
  late WaterEffects _water;
  bool _ready = false;

  // 기울기(가속도계) 반응.
  final TiltResponse _tilt = TiltResponse();
  StreamSubscription<AccelerometerEvent>? _accelSub;

  /// 화면 위젯(aquarium_screen)에서 주입하는 바텀 네비 영역 높이(px).
  /// 금붕어가 그 아래로 못 내려가게 한다.
  double bottomUiInset = 0;

  @override
  Color backgroundColor() => const Color(0xFF0A1A2F);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    _water = WaterEffects();
    add(_water);

    _fish = FishComponent(
      species: species,
      startPosition: size / 2,
    );
    add(_fish);

    // 가속도계 구독(중력 포함). 시뮬레이터엔 센서가 없어 콜백이 안 와도
    // gravity는 0으로 유지되어 안전하다.
    _accelSub = accelerometerEventStream(
      samplingPeriod: SensorInterval.gameInterval, // 부드러운 틸트용 ~50Hz
    ).listen(
      (e) => _tilt.setFromAccelerometer(e.x, e.y, e.z),
      onError: (_) {}, // 센서 미지원 시 조용히 무시
      cancelOnError: false,
    );

    _ready = true;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_ready) {
      _fish.gravity = _tilt.gravity; // 금붕어 쏠림
      _water.gravity = _tilt.gravity; // 수면·거품 쏠림

      // 헤엄 영역: 수면 아래(+버퍼) ~ 바텀 네비 위.
      final h = size.y;
      final top = h * WaterEffects.surfaceFrac + 8;
      final bottom = h - bottomUiInset;
      _fish.setSwimArea(top, bottom > top ? bottom : h - _edgeFallback);
    }
  }

  static const double _edgeFallback = 80;

  @override
  void onRemove() {
    _accelSub?.cancel();
    super.onRemove();
  }

  /// 짧은 탭 → 그 지점으로 다가옴.
  void approachAt(Offset p) {
    if (_ready) _fish.onTouchApproach(Vector2(p.dx, p.dy));
  }

  /// 길게 누름·드래그 → 그 지점에서 흩어짐.
  void scatterAt(Offset p) {
    if (_ready) _fish.onTouchScatter(Vector2(p.dx, p.dy));
  }
}
