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
    // 바텀 네비(아이콘 줄) 영역 높이 = 세이프에어리어 + 패딩 + 아이콘/라벨.
    // 금붕어가 이 아래로 못 내려가게 게임에 전달.
    _game.bottomUiInset = MediaQuery.of(context).padding.bottom + 64;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            // 터치 입력은 여기서 받아 게임으로 전달 (Flame 이벤트 우회 → 가장 안정적).
            // 짧은 탭=다가옴 / 길게 누름·드래그=흩어짐 (C안).
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapUp: (d) => _game.approachAt(d.localPosition),
              onLongPressStart: (d) => _game.scatterAt(d.localPosition),
              onPanStart: (d) => _game.scatterAt(d.localPosition),
              child: GameWidget(game: _game),
            ),
          ),

          // 코어 루프 진입점(§5). 호흡만 연결됨, 나머지는 Phase별 구현.
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const _ActionPlaceholder(icon: Icons.set_meal, label: '먹이'),
                    _ActionPlaceholder(
                      icon: Icons.air,
                      label: '호흡',
                      onTap: () => _game.toggleBreathing(),
                    ),
                    const _ActionPlaceholder(
                        icon: Icons.music_note, label: '사운드'),
                    const _ActionPlaceholder(icon: Icons.settings, label: '설정'),
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
  const _ActionPlaceholder({
    required this.icon,
    required this.label,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final active = onTap != null;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: active ? Colors.white : Colors.white38),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: active ? Colors.white70 : Colors.white38,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
