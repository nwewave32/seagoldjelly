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

  /// v1 무료 기본 트랙. assetPath는 just_audio 자산 키(pubspec assets/audio/).
  /// ⚠️ 라이선스 출처는 assets/audio/CREDITS.md에 기록할 것(§9).
  static const SoundTrack stillWaters = SoundTrack(
    id: 'still_waters',
    displayName: 'Beneath the Still Waters',
    assetPath: 'assets/audio/Beneath_The_Still_Waters.mp3',
    isPremium: false,
  );
}
