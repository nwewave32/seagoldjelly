import 'package:flame/game.dart';
import 'package:flutter/widgets.dart';

import '../data/models/species.dart';
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
  bool _ready = false;

  @override
  Color backgroundColor() => const Color(0xFF0A1A2F);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    add(WaterEffects());

    _fish = FishComponent(
      species: species,
      startPosition: size / 2,
    );
    add(_fish);

    _ready = true;
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
