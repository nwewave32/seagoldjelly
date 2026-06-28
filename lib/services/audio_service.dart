/// 오디오 서비스 (§3). 루프 재생 + 페이드아웃.
/// Phase 0: 인터페이스만. Phase 1에서 just_audio로 구현.
abstract class AudioService {
  Future<void> playLoop(String assetPath, {double volume});
  Future<void> fadeOutAndStop(Duration over);
  Future<void> stop();
}

/// Phase 0 no-op 구현. 사운드 자산 도입 전까지 안전하게 호출 가능.
class NoopAudioService implements AudioService {
  @override
  Future<void> playLoop(String assetPath, {double volume = 1.0}) async {}

  @override
  Future<void> fadeOutAndStop(Duration over) async {}

  @override
  Future<void> stop() async {}
}
