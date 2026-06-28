/// 사운드 메타데이터 (§3, §6 Phase 1).
/// 무료 1종 / 구독 전체 라이브러리 (§7). 오디오 출처는 CREDITS.md 기록(§9).
class SoundTrack {
  const SoundTrack({
    required this.id,
    required this.displayName,
    required this.assetPath,
    this.isPremium = false,
  });

  final String id;
  final String displayName;

  /// assets/audio/ 기준 경로. Phase 1에서 실제 파일 추가.
  final String assetPath;
  final bool isPremium;

  // NOTE: 실제 파일은 라이선스 확보 후 추가(§9). 아래는 자리표시 정의.
  static const SoundTrack waterLoop = SoundTrack(
    id: 'water_loop',
    displayName: '잔잔한 물소리',
    assetPath: 'audio/water_loop.mp3',
    isPremium: false,
  );
}
