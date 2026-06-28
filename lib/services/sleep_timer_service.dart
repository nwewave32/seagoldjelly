import 'dart:async';

/// 수면 타이머 (§3, §6 Phase 1). 설정 시간 후 페이드아웃 콜백 트리거.
/// 무료는 15분 제한(§7) — 게이팅은 호출부에서 적용.
class SleepTimerService {
  Timer? _timer;

  bool get isRunning => _timer?.isActive ?? false;

  void start(Duration duration, {required void Function() onComplete}) {
    cancel();
    _timer = Timer(duration, () {
      _timer = null;
      onComplete();
    });
  }

  void cancel() {
    _timer?.cancel();
    _timer = null;
  }

  void dispose() => cancel();
}
