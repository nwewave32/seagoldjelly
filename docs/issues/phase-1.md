# Phase 1 이슈

코어 루프 단계(§6). DoD: 호흡 → 사운드+타이머 → 잠듦이 한 번에 끊김 없이 돈다.

| ID | 제목 | Severity | Status |
|---|---|---|---|
| P1-001 | 호흡 가이드 `_guide` late 미초기화 크래시(hot reload) | High | Verified |
| P1-002 | 사운드 무재생(iOS 오디오 세션 미설정 + 오류 삼킴) | High | Verified |
| P1-003 | 사운드가 너무 짧게 재생(수면 타이머 8s 데모) | Medium | Verified |
| P1-004 | 설계된 DI 계층 미배선(데드코드) + Consumer 위젯 ref 미사용 | Medium | Open |
| P1-005 | 호흡 세션 ↔ 수면 타이머 상호배제 없음 | Medium | Open |
| P1-006 | 금붕어 경계 ↔ UI 바 매직넘버 중복/결합 | Low~Medium | Open |
| P1-007 | 디버그 렌더링 코드가 프로덕션 경로에 상주 | Low | Open |
| P1-008 | 틸트 스무딩이 시간(dt)이 아닌 샘플 기준 | Low | Open(참고) |
| P1-009 | `FishComponent.mood` ↔ `FishState` 미연결 | Low | Open(Phase 2) |
| P1-010 | 연출 매직넘버 산재(버퍼 8, 거품 14, 가이드 비율 등) | Low | Open(Phase 4) |

---

## 해결됨 (Phase 1 진행 중 발생)

### P1-001 — 호흡 가이드 `_guide` late 미초기화 크래시
- **Status:** Verified · **Severity:** High
- **증상:** '호흡' 누르면 `LateInitializationError: _guide`로 멈춤.
- **원인:** `_guide`가 onLoad에서만 채워지는 `late` 필드. hot reload는 기존 인스턴스 onLoad를 재실행하지 않아 미초기화 상태에서 update가 접근.
- **수정:** `_water`/`_guide`를 선언과 동시에 `final ... = ...()`로 초기화, onLoad는 `add`만. (`aquarium_game.dart`)
- **교훈:** onLoad로만 채우는 late 필드는 hot reload와 충돌 → 선언 초기화 또는 `_ready` 가드.

### P1-002 — 사운드 무재생
- **Status:** Verified · **Severity:** High
- **원인:** (1) iOS 기본 오디오 세션이 무음 스위치를 따라 음소거, (2) `playLoop`의 `catch`가 로드 실패를 조용히 삼켜 원인 은폐.
- **수정:** `audio_session`으로 `AudioSessionConfiguration.music()`(playback) 설정(무음 스위치 무시·백그라운드 가능), 실패 시 `debugPrint` 로깅. (`audio_service.dart`)

### P1-003 — 사운드가 너무 짧게 재생
- **Status:** Verified · **Severity:** Medium
- **원인:** 데모용 수면 타이머 8s가 ~31s 트랙을 한 바퀴 돌기 전에 페이드아웃.
- **수정:** `kSleepTimerSeconds` 8s → 15분(§7 무료). 그동안 `LoopMode.one`로 끊김 없이 반복. (`aquarium_game.dart`)

---

## 리뷰 지적사항 (백로그)

### P1-004 — DI 계층 미배선(데드코드) + Consumer 위젯 ref 미사용
- **Status:** Open · **Severity:** Medium · **Area:** repositories/*, services/*, `aquarium_screen.dart`, `aquarium_game.dart`
- **내용:** `FishRepository`/`SettingsRepository`/`AudioService`/`SubscriptionService`와 stub/no-op이 만들어졌지만 어디서도 인스턴스화·주입되지 않음(데드코드). `AquariumScreen`은 `ConsumerStatefulWidget`인데 `ref` 미사용(Riverpod import만).
- **권장:**
  1. `AquariumGame`에 서비스 생성자 주입(`AquariumGame({required this.species, required this.audio})`)으로 사운드/저장 배선을 한 번에 연결.
  2. 당장 `ref` 안 쓰면 `ConsumerStatefulWidget` → `StatefulWidget`로 단순화(§1-5 조기 추상화 금지).
- **비고:** 현재 `AquariumGame`이 `JustAudioService`를 내부에서 직접 생성 중 — 주입으로 바꾸면 테스트/교체 용이.

### P1-005 — 호흡 세션 ↔ 수면 타이머 상호배제 없음
- **Status:** Open · **Severity:** Medium · **Area:** `aquarium_game.dart`
- **내용:** `toggleBreathing()`/`toggleSleepTimer()`가 독립적이라 동시 작동 가능. 속도 배율은 `breathFactor * sleepFactor`로 수학적으론 안전하나, "가이드 원이 떠 있는데 화면이 어두워지는" 연출 충돌 가능.
- **권장:** §5 순차 흐름(호흡 → 사운드+타이머 → 잠듦)에 맞춰 한쪽 시작 시 다른 쪽 정리하는 가드. Phase 1 마무리 권장.

### P1-006 — 금붕어 경계 ↔ UI 바 매직넘버 중복/결합
- **Status:** Open · **Severity:** Low~Medium · **Area:** `aquarium_screen.dart`, `aquarium_game.dart`, `water_effects.dart`
- **내용:** `padding.bottom + 64`(screen), `_edgeFallback = 80`(game), 수면 상한 `surfaceFrac + 8` 버퍼가 각자 흩어짐. 액션바 높이가 바뀌면 64가 어긋나 금붕어가 바 뒤로/위로 샐 수 있음.
- **권장:** 액션바 높이를 상수화하거나 실제 위젯 높이(LayoutBuilder)로 산출. `bottomUiInset`은 값이 바뀔 때만 갱신(현재 build마다 대입, 기능엔 무해).

### P1-007 — 디버그 렌더링 코드가 프로덕션 경로에 상주
- **Status:** Open · **Severity:** Low · **Area:** `fish_component.dart`
- **내용:** `_renderDebug`(~75줄)와 추적 필드(`_flipCount`/`_flipFlash`/`_inDeadzone`)가 `debug=false`여도 update에서 매 프레임 계산(렌더만 가드). 비용은 무시 수준.
- **권장:** P0-001이 데드존+히스테리시스로 정착됐으니, Phase 2 비주얼 교체(스프라이트) 때 함께 제거. CLAUDE.md render 교체 지점과 동일.

### P1-008 — 틸트 스무딩이 시간(dt)이 아닌 샘플 기준
- **Status:** Open(참고) · **Severity:** Low · **Area:** `tilt_response.dart`
- **내용:** `gravity += (target-gravity)*smoothing`는 샘플당 보간. 현재 `SensorInterval.gameInterval(~50Hz 고정)`이라 사실상 일정하나, 샘플레이트가 흔들리면 반응 속도가 달라짐.
- **권장:** 엄밀히는 `1 - exp(-dt/tau)` 형태. 차분한 앱 특성상 현재로도 충분(참고만).

### P1-009 — `FishComponent.mood` ↔ `FishState` 미연결
- **Status:** Open(Phase 2) · **Severity:** Low · **Area:** `fish_component.dart`, `fish_state.dart`
- **내용:** `mood`가 생성자 기본값 `Mood.calm` 고정, `FishState.moodAt()`(테스트 완비)와 미연결.
- **비고:** Phase 2에서 `species_registry + fish_repository + mood` 배선을 한 번에. (정상 — 아직 Phase 2 미진입)

### P1-010 — 연출 매직넘버 산재
- **Status:** Open(Phase 4) · **Severity:** Low
- **내용:** 수면 상한 버퍼 `8`(`aquarium_game.dart`), 거품 수 `14`(`water_effects.dart`), 가이드 비율 `0.42/0.12/0.32`(`breathing_guide.dart`) 등 연출 매직넘버가 흩어짐.
- **권장:** Phase 4 폴리시에서 한곳으로 모아 상수화(튜닝 용이, §4 의도와 일치).
