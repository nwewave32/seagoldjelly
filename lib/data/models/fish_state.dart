import 'species.dart';

/// 개체 상태 (§3). 이름·기분·마지막 방문 등. Phase 2에서 Hive로 영속화.
class FishState {
  const FishState({
    required this.speciesId,
    this.name,
    this.lastVisitedAt,
  });

  final String speciesId;
  final String? name;
  final DateTime? lastVisitedAt;

  /// 마지막 방문 공백 기준으로 기분 계산 (§6 Phase 2).
  /// Phase 0/1에선 calm 고정으로 충분.
  Mood moodAt(DateTime now, {Duration absenceThreshold = const Duration(days: 3)}) {
    final last = lastVisitedAt;
    if (last == null) return Mood.calm;
    final gap = now.difference(last);
    if (gap >= absenceThreshold) return Mood.gloomy;
    if (gap <= const Duration(hours: 18)) return Mood.happy;
    return Mood.calm;
  }

  FishState copyWith({String? name, DateTime? lastVisitedAt}) => FishState(
        speciesId: speciesId,
        name: name ?? this.name,
        lastVisitedAt: lastVisitedAt ?? this.lastVisitedAt,
      );
}
