# CLAUDE.md — 잠드는 어항 (Sleepy Aquarium) 개발 명세

이 문서는 Claude Code가 이 프로젝트를 작업할 때 참조하는 단일 진실 소스(Single Source of Truth)다.
작업 시작 전 반드시 이 문서의 "원칙"과 "현재 Phase"를 확인하고, 범위를 벗어나는 기능은 구현하지 말 것.

---

## 0. 프로젝트 한 줄 요약

애니메이션체 금붕어 1종을 **Flutter + Flame**으로 부드럽게 헤엄치게 만들고, 큐레이션된 사운드 + 호흡 유도 루틴으로 밤마다 재우는 **iOS 우선 구독 앱**.

---

## 1. 개발 원칙 (위반 금지)

1. **범위 엄수.** 아래 "Out of Scope (v1 금지)" 목록의 기능은 절대 구현하지 않는다. 요청이 모호하면 v1 범위로 좁혀 해석한다.
2. **성능 우선.** 목표는 모든 인터랙션에서 **60fps**. 애니메이션/물리 코드는 프레임 드랍을 항상 의식한다.
3. **생물은 데이터다.** 금붕어를 하드코딩하지 않는다. 종(species)의 헤엄 패턴·감정 반응·먹이 반응은 데이터/설정 객체로 분리한다. v2에서 해파리·바다달팽이를 "데이터 한 벌 추가"로 넣을 수 있어야 한다.
4. **단계적 빌드.** Phase 순서대로 진행한다. 현재 Phase를 끝내고 검증 기준을 통과하기 전엔 다음 Phase로 넘어가지 않는다.
5. **솔로 개발 친화.** 과도한 추상화·조기 최적화 금지. 단, (3)의 종 추상화만은 예외로 처음부터 지킨다.

---

## 2. 기술 스택

| 영역 | 선택 | 비고 |
|---|---|---|
| 언어/프레임워크 | Flutter (Dart) | 향후 Android 확장 대비 |
| 게임/렌더 레이어 | **Flame** (flame 패키지) | 유영·물리·터치 인터랙션 담당 |
| 타깃 플랫폼 | **iOS 우선** | Android는 v2 이후 검토 |
| 상태관리 | Riverpod 권장 (또는 Provider) | 솔로 개발이므로 단순하게 |
| 로컬 저장 | shared_preferences (간단한 상태) / Hive (구조적 데이터) | 금붕어 상태·설정 영속화 |
| 결제 | RevenueCat (purchases_flutter) | 구독 + 7일 무료체험. 직접 StoreKit 핸들링 지양 |
| 오디오 | flame_audio 또는 just_audio | 루프 사운드 + 페이드아웃 타이머 |
| 센서 | sensors_plus | 기울기(가속도계) 반응 |

> ⚠️ **기술 리스크 게이트:** Phase 0에서 Flutter+Flame이 목표 fps를 못 내면, iOS 단독이라는 점을 활용해 SpriteKit(네이티브 2D) 대안을 사람과 상의한다. 임의로 엔진을 바꾸지 말 것.

---

## 3. 권장 디렉토리 구조

```
lib/
  main.dart
  app.dart                      # 앱 루트, 라우팅, 테마
  core/
    constants.dart
    theme.dart
  data/
    models/
      species.dart              # 종 정의 (헤엄/감정/먹이 파라미터) ★핵심 추상화
      fish_state.dart           # 개체 상태 (이름, 기분, 마지막 방문 등)
      breathing_program.dart    # 호흡 프로그램 정의 (예: 4-7-8)
      sound_track.dart          # 사운드 메타데이터
    repositories/
      fish_repository.dart      # 금붕어 상태 영속화/로드
      settings_repository.dart
  game/                         # Flame 영역
    aquarium_game.dart          # FlameGame 본체
    components/
      fish_component.dart       # 종 데이터로 구동되는 개체 컴포넌트
      food_component.dart
      water_effects.dart        # 거품 등 (가벼운 수준)
    behaviors/
      swim_behavior.dart        # 헤엄 알고리즘 (종별 파라미터 주입)
      touch_response.dart
      tilt_response.dart
  features/
    aquarium/                   # 메인 화면 (게임 + 오버레이 UI)
    breathing/                  # 호흡 세션 화면/오버레이
    sound/                      # 사운드 + 타이머
    feeding/                    # 먹이 주기
    onboarding/
    settings/
    clock/                      # 시계·날짜 오버레이
    paywall/                    # 구독 화면
  services/
    audio_service.dart
    subscription_service.dart   # RevenueCat 래퍼
    sleep_timer_service.dart
```

---

## 4. 핵심 데이터 모델 (★ 종 추상화)

가장 중요한 설계. 종을 데이터로 다루기 위한 최소 형태 예시(가이드일 뿐, 구현 시 조정 가능):

```dart
// species.dart
class Species {
  final String id;                 // 'goldfish_white', 'goldfish_black'
  final String displayName;
  final SwimProfile swim;          // 헤엄 방식 파라미터
  final EmotionProfile emotion;    // 기분 표현 방식
  final FeedingProfile feeding;
  final bool isPremium;            // 무료/구독 게이팅
}

// 헤엄 방식: 금붕어=유영, (v2)해파리=부유·박동, 바다달팽이=바닥 활주
// → enum SwimStyle { glide, drift, pulse, crawl } 같은 식으로 확장 대비
class SwimProfile {
  final SwimStyle style;
  final double baseSpeed;
  final double turnRate;
  final double wanderiness;        // 변덕스럽게 움직이는 정도
}

class EmotionProfile {
  // 기분 상태(반가움/평온/시무룩)를 애니메이션 파라미터로 매핑
  // 애니메이션체이므로 눈/색/움직임으로 감정 표현 가능
}
```

> v1에는 `goldfish_white`(무료), `goldfish_black`(무료) 2종만 데이터로 등록.
> 헤엄 알고리즘은 `SwimStyle.glide` 하나만 구현하면 됨. 나머지 style은 enum만 정의해두고 v2에서 구현.

---

## 5. 코어 루프 (구현 목표 흐름)

```
앱 실행 → 어항 화면 (금붕어 헤엄 중, 기분 반영)
  → [먹이 주기] 탭 → 먹이 떨어뜨림, 금붕어 반응
  → [호흡 세션 시작] → 금붕어 헤엄 속도가 4-7-8 호흡에 싱크 + 시각 가이드
  → [사운드 + 타이머] → 사운드 재생, 설정 시간 후 자동 페이드아웃
  → 금붕어 잠듦 연출 → 화면 어두워짐
```

---

## 6. Phase별 작업 (순서대로 진행)

각 Phase는 "완료 기준(DoD)"을 통과해야 다음으로 넘어간다.

### Phase 0 — 기술 검증 (최우선, 1~2주)
**목표:** 이 앱이 기술적으로 가능한지 증명.
- [ ] Flutter + Flame 프로젝트 셋업, iOS 빌드/실행 확인
- [ ] 금붕어 1마리가 화면에서 자연스럽게 헤엄 (wander 알고리즘, 화면 경계 처리)
- [ ] 터치 시 금붕어가 손가락 쪽으로 다가오거나 흩어지는 반응
- [ ] 기울기(가속도계)에 따라 물/금붕어가 반응
- [ ] 기기에서 fps 측정 (devtools / overlay)
- **DoD:** 실기기에서 **60fps 유지** + "예쁘게 헤엄친다"는 주관적 합격. ❌ 미달 시 사람과 엔진 대안 상의.

### Phase 1 — 코어 루프
**목표:** "자기 전에 켜고 싶은가"를 본인이 매일 써보며 검증.
- [ ] 호흡 프로그램 데이터 모델 + 4-7-8 1종 구현
- [ ] 호흡 세션 중 금붕어 헤엄 속도가 호흡 페이즈(들숨/멈춤/날숨)에 싱크
- [ ] 호흡 시각 가이드 (확장/수축 같은 미니멀한 연출)
- [ ] 사운드 2~3종 재생 (루프, 끊김 없는 처리)
- [ ] 수면 타이머 + 종료 시 자동 페이드아웃
- **DoD:** 코어 루프 전체가 한 번에 끊김 없이 돌아간다.

### Phase 2 — 애착
- [ ] 금붕어 이름 짓기 + 영속화
- [ ] 상태 변화: 마지막 방문 시각 기반으로 기분 계산 (며칠 공백 → 시무룩 / 꾸준 → 반가움)
- [ ] 기분이 헤엄·표정 애니메이션에 반영 (EmotionProfile 활용)
- [ ] 먹이 주기 + 금붕어 반응
- **DoD:** 며칠 안 켜다 다시 켰을 때 금붕어 반응이 눈에 띄게 다르다.

### Phase 3 — 수익화
- [ ] RevenueCat 연동, 구독 상품(월/연) + 7일 무료체험 설정
- [ ] Paywall 화면
- [ ] 무료/구독 게이팅 (아래 §7 표대로)
- [ ] 온보딩 (왜 자기 전에 쓰는지 1~3 스텝)
- **DoD:** 무료체험 시작 → 구독 전환 → 게이팅 해제 흐름이 동작. 자동갱신·해지방법 고지 화면 포함(심사 필수).

### Phase 4 — 폴리시
- [ ] 설정: 음량(물소리/거품), 타이머 길이, 밝기
- [ ] 시계·날짜 오버레이 (위치/크기/표시여부)
- [ ] 사운드·연출 다듬기, 빈 상태/엣지 케이스 처리
- **DoD:** 출시 수준 완성도.

### Phase 5 — 베타 → 출시
- [ ] TestFlight 클로즈드 베타
- [ ] 1~2주 실사용 피드백 반영
- [ ] App Store 메타데이터/스크린샷/심사 대응
- **DoD:** 심사 통과 + 매일 돌아오는지 확인.

---

## 7. 무료 / 구독 게이팅 (구현 기준)

| 항목 | 무료 | 구독 |
|---|---|---|
| 금붕어 | 1마리, 기본 색 (goldfish_white) | 색·종류 해금 (goldfish_black 등) |
| 호흡 | 1종 (4-7-8) | 다양한 프로그램 |
| 사운드 | 1종 | 전체 라이브러리 |
| 타이머 | 15분 제한 | 무제한 |
| 상태/애착 | 기본 | 풍부한 반응·성장 (+v2 수면 기록) |

원칙: 무료도 코어 루프 한 사이클은 온전히 돌아가야 한다. 게이팅은 "더 깊이/오래 쓰면 구독"으로 건다.

---

## 8. Out of Scope (v1 금지 — 구현하지 말 것)

다음은 명시적으로 v1에서 제외. 요청받아도 구현 전에 사람에게 "v1 범위 밖"임을 알릴 것.

- ❌ 여러 마리 동시 표시 (최대 6마리) → v2
- ❌ 다른 생물: 해파리, 바다달팽이 → v2 ("이번 달 새 친구" 운영). **단, 종 추상화 구조는 v1부터 유지**
- ❌ 수면 추적/기록 → v2
- ❌ 성장 트리, 다양한 코스튬, 어항 풀 커스터마이징 → v2+
- ❌ 유체 시뮬레이션, 코스틱스, 실사화 비주얼 → v3~4
- ❌ 자동 회전 시점, 고급 카메라 모드 등 부가 시점 옵션 → 보류

---

## 9. 컴플라이언스 메모 (코드/카피에 영향)

- **구독 심사:** 무료체험·자동갱신·해지방법 고지 UI 필수. RevenueCat 권장 구현 따를 것.
- **저작권:** 모든 오디오는 라이선스 클린한 소스만 사용. 출처를 `assets/audio/CREDITS.md`에 기록.
- **마케팅 카피:** 의학적 효능 주장 금지. "힐링/이완/잠들기 좋은" OK / "불면증 치료/수면장애 개선" 등 효능 주장 NG. 앱 내 문구·스토어 설명 모두 적용.

---

## 10. 작업 시작 시 체크리스트 (Claude Code용)

새 작업을 받으면:
1. 이 요청이 **현재 Phase 범위** 안인가? 밖이면 사람에게 확인.
2. §8 Out of Scope에 해당하지 않는가?
3. 생물 관련이면 §3 종 추상화(data/models/species.dart)를 거치는가?
4. 성능에 영향 주는 애니메이션/물리인가? 그렇다면 60fps 고려.
5. 결제·구독·고지 화면이면 §9 컴플라이언스 확인.
