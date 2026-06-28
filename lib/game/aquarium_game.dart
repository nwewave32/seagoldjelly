import 'dart:async';

import 'package:flame/game.dart';
import 'package:flutter/widgets.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../data/models/breathing_program.dart';
import '../data/models/species.dart';
import '../features/breathing/breathing_session.dart';
import 'behaviors/tilt_response.dart';
import 'components/breathing_guide.dart';
import 'components/fish_component.dart';
import 'components/sleep_overlay.dart';
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

  late FishComponent _fish; // size가 필요해 onLoad에서 생성
  // hot reload 시에도 안전하도록 선언과 동시에 초기화(late 미초기화 방지).
  final WaterEffects _water = WaterEffects();
  final BreathingGuide _guide = BreathingGuide();
  final SleepOverlay _sleepOverlay = SleepOverlay();
  bool _ready = false;

  // 수면 타이머 + 잠듦 연출(§5, §6 Phase 1).
  double? _sleepTimerRemaining; // 남은 초. null이면 미작동.
  bool _sleeping = false; // 잠듦 램프 진행 중.
  double _sleepProgress = 0; // 0 깨어있음 ~ 1 잠듦.

  /// 데모용 수면 타이머 길이(초). 설정 연동은 Phase 4(§4), 무료 15분 제한 §7.
  static const double kSleepTimerSeconds = 8;
  static const double _sleepRampSeconds = 4; // 잠드는 연출 길이.

  bool get isSleepActive => _sleeping || _sleepTimerRemaining != null;

  // 호흡 세션(§6 Phase 1). null이면 비활성.
  BreathingSession? _breath;
  bool get isBreathing => _breath?.isRunning ?? false;

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

    add(_water);

    _fish = FishComponent(
      species: species,
      startPosition: size / 2,
    );
    add(_fish);

    add(_guide);
    add(_sleepOverlay);

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

      // 호흡 세션: 진행 → 금붕어 속도·가이드 싱크. 완료 시 정지.
      final b = _breath;
      if (b != null) {
        if (b.isRunning) {
          b.tick(dt);
          final st = b.state;
          _fish.breathFactor = 0.35 + 0.65 * st.expansion; // 들숨↑ 날숨↓
          _guide
            ..visible = true
            ..expansion = st.expansion;
        }
        if (b.isComplete) stopBreathing();
      }

      _updateSleep(dt);
    }
  }

  /// 수면 타이머 카운트다운 + 잠듦 연출(화면 어두워짐 + 금붕어 느려짐).
  void _updateSleep(double dt) {
    final remaining = _sleepTimerRemaining;
    if (remaining != null) {
      final next = remaining - dt;
      if (next <= 0) {
        _sleepTimerRemaining = null;
        _sleeping = true;
        // TODO(사운드): audioService.fadeOutAndStop(_sleepRampSeconds) 연결.
      } else {
        _sleepTimerRemaining = next;
      }
    }

    if (_sleeping && _sleepProgress < 1) {
      _sleepProgress = (_sleepProgress + dt / _sleepRampSeconds).clamp(0.0, 1.0);
    }

    _fish.sleepFactor = 1 - 0.9 * _sleepProgress; // 잠들수록 거의 멈춤
    _sleepOverlay.opacity = 0.92 * _sleepProgress; // 화면 어두워짐
  }

  static const double _edgeFallback = 80;

  /// 하단 '수면' 버튼: 작동 중이면 깨우고, 아니면 타이머 시작.
  void toggleSleepTimer() =>
      isSleepActive ? wake() : startSleepTimer(kSleepTimerSeconds);

  void startSleepTimer(double seconds) {
    _sleepTimerRemaining = seconds;
    _sleeping = false;
  }

  /// 타이머 없이 즉시 잠듦(예: 호흡 세션 완료 후 연결 가능).
  void sleepNow() {
    _sleepTimerRemaining = null;
    _sleeping = true;
  }

  void wake() {
    _sleepTimerRemaining = null;
    _sleeping = false;
    _sleepProgress = 0;
    _fish.sleepFactor = 1.0;
    _sleepOverlay.opacity = 0;
  }

  /// 하단 '호흡' 버튼에서 호출. 켜져 있으면 끄고, 아니면 시작.
  void toggleBreathing() => isBreathing ? stopBreathing() : startBreathing();

  void startBreathing() {
    _breath = BreathingSession(BreathingProgram.fourSevenEight)..start();
  }

  void stopBreathing() {
    _breath = null;
    _fish.breathFactor = 1.0;
    _guide.visible = false;
  }

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
