import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../data/models/species.dart';
import 'components/fish_component.dart';
import 'components/water_effects.dart';

/// FlameGame 본체 (§3). 어항 + 금붕어.
///
/// Phase 0 셋업 수준: 종 데이터로 만든 금붕어 1마리를 띄워 렌더가 도는지 확인.
/// 터치/기울기/경계 정교화·fps 게이트 검증은 Phase 0 본구현에서.
class AquariumGame extends FlameGame {
  AquariumGame({required this.species});

  final Species species;

  late FishComponent _fish;

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
  }

  /// Phase 0: 화면 탭 시 금붕어가 그쪽으로 향하도록(자리표시).
  /// 본구현에서 TouchResponse와 연결.
  void onTapAt(Vector2 worldPoint) {
    // TODO(Phase 0): touch_response 결합.
  }
}
