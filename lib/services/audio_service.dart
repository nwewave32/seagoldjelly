import 'dart:async';

import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

/// 오디오 서비스 (§3). 루프 재생 + 페이드아웃.
abstract class AudioService {
  Future<void> playLoop(String assetPath, {double volume});
  Future<void> fadeOutAndStop(Duration over);
  Future<void> stop();
  Future<void> dispose();
}

/// no-op 구현. 테스트/사운드 비활성 환경에서 안전하게 호출 가능.
class NoopAudioService implements AudioService {
  @override
  Future<void> playLoop(String assetPath, {double volume = 1.0}) async {}

  @override
  Future<void> fadeOutAndStop(Duration over) async {}

  @override
  Future<void> stop() async {}

  @override
  Future<void> dispose() async {}
}

/// just_audio 기반 구현 (§2). 끊김 없는 루프 + 부드러운 페이드아웃.
class JustAudioService implements AudioService {
  final AudioPlayer _player = AudioPlayer();
  Timer? _fadeTimer;
  double _baseVolume = 1.0;
  bool _sessionReady = false;

  /// iOS 무음 스위치를 무시하고 재생되도록 playback 카테고리로 설정(1회).
  Future<void> _ensureSession() async {
    if (_sessionReady) return;
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());
    _sessionReady = true;
  }

  @override
  Future<void> playLoop(String assetPath, {double volume = 1.0}) async {
    _fadeTimer?.cancel();
    _baseVolume = volume;
    try {
      await _ensureSession();
      await _player.setAsset(assetPath);
      await _player.setLoopMode(LoopMode.one); // 끊김 없는 단일 트랙 루프
      await _player.setVolume(volume);
      await _player.play();
    } catch (e, st) {
      // 자산 누락·디코드 실패 등. 앱 흐름은 보호하되 원인은 콘솔에 남긴다.
      debugPrint('AudioService.playLoop 실패: $e\n$st');
    }
  }

  @override
  Future<void> fadeOutAndStop(Duration over) async {
    _fadeTimer?.cancel();
    const stepMs = 80;
    final steps = (over.inMilliseconds / stepMs).ceil().clamp(1, 100000);
    final start = _player.volume;
    var i = 0;
    _fadeTimer = Timer.periodic(const Duration(milliseconds: stepMs), (t) async {
      i++;
      final v = start * (1 - i / steps);
      await _player.setVolume(v.clamp(0.0, 1.0));
      if (i >= steps) {
        t.cancel();
        await _player.stop();
      }
    });
  }

  @override
  Future<void> stop() async {
    _fadeTimer?.cancel();
    await _player.setVolume(_baseVolume); // 다음 재생 위해 볼륨 복원
    await _player.stop();
  }

  @override
  Future<void> dispose() async {
    _fadeTimer?.cancel();
    await _player.dispose();
  }
}
