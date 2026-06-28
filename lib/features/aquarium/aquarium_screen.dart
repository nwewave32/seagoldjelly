import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/species_registry.dart';
import '../../game/aquarium_game.dart';

/// 메인 화면 (§3). Flame 게임 + 오버레이 UI.
/// Phase 0 셋업: 금붕어 헤엄 + (자리표시) 하단 액션바.
class AquariumScreen extends ConsumerStatefulWidget {
  const AquariumScreen({super.key});

  @override
  ConsumerState<AquariumScreen> createState() => _AquariumScreenState();
}

class _AquariumScreenState extends ConsumerState<AquariumScreen> {
  late final AquariumGame _game;

  @override
  void initState() {
    super.initState();
    // 종은 데이터에서 선택(§1-3). v1 무료 기본 = 흰 금붕어.
    _game = AquariumGame(species: SpeciesRegistry.goldfishWhite);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: GameWidget(game: _game)),

          // 자리표시 오버레이: 코어 루프 진입점(§5). 각 화면은 Phase별 구현.
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: const [
                    _ActionPlaceholder(icon: Icons.set_meal, label: '먹이'),
                    _ActionPlaceholder(icon: Icons.air, label: '호흡'),
                    _ActionPlaceholder(icon: Icons.music_note, label: '사운드'),
                    _ActionPlaceholder(icon: Icons.settings, label: '설정'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionPlaceholder extends StatelessWidget {
  const _ActionPlaceholder({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white70),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
      ],
    );
  }
}
