/// 설정 영속화 (§3). Phase 0: 기본값만. Phase 4에서 shared_preferences 연동.
class AppSettings {
  const AppSettings({
    this.waterVolume = 0.7,
    this.bubbleVolume = 0.4,
    this.timerMinutes = 15, // 무료 기본 한도 (§7)
    this.showClock = true,
    this.brightness = 0.6,
  });

  final double waterVolume;
  final double bubbleVolume;
  final int timerMinutes;
  final bool showClock;
  final double brightness;
}

abstract class SettingsRepository {
  Future<AppSettings> load();
  Future<void> save(AppSettings settings);
}

class InMemorySettingsRepository implements SettingsRepository {
  AppSettings _settings = const AppSettings();

  @override
  Future<AppSettings> load() async => _settings;

  @override
  Future<void> save(AppSettings settings) async => _settings = settings;
}
