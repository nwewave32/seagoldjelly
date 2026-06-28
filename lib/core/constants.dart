/// 앱 전역 상수. 매직넘버는 가급적 여기로 모은다.
class AppConstants {
  AppConstants._();

  static const String appName = '잠드는 어항';

  /// 무료 게이팅 (§7)
  static const Duration freeTimerLimit = Duration(minutes: 15);

  /// Phase 0 성능 게이트 (§6)
  static const int targetFps = 60;

  /// 며칠 공백이면 '시무룩'으로 볼지 (Phase 2에서 사용, §6)
  static const Duration moodAbsenceThreshold = Duration(days: 3);
}
