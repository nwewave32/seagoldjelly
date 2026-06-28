import '../models/fish_state.dart';
import '../models/species_registry.dart';

/// 금붕어 상태 영속화/로드 (§3).
/// Phase 0: 메모리 기본값만. Phase 2에서 Hive 연동.
abstract class FishRepository {
  Future<FishState> load();
  Future<void> save(FishState state);
}

/// Phase 0용 인메모리 구현. 앱 재시작 시 초기화됨.
class InMemoryFishRepository implements FishRepository {
  FishState _state = FishState(speciesId: SpeciesRegistry.goldfishWhite.id);

  @override
  Future<FishState> load() async => _state;

  @override
  Future<void> save(FishState state) async => _state = state;
}
