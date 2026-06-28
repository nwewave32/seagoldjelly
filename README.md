# 잠드는 어항 (Sleepy Aquarium)

애니메이션체 금붕어 1종을 **Flutter + Flame**으로 부드럽게 헤엄치게 만들고, 큐레이션된 사운드 + 호흡 유도 루틴으로 밤마다 재우는 **iOS 우선 구독 앱**.

> 작업 전 반드시 [`CLAUDE.md`](./CLAUDE.md)의 "원칙"과 "현재 Phase"를 확인할 것. 이 README는 셋업 안내이고, 단일 진실 소스는 `CLAUDE.md`다.

## 현재 상태

**Phase 0 셋업 완료** — 프로젝트 구조·종 추상화·코드 도형 금붕어 부팅까지.
헤엄 알고리즘 정교화·터치/기울기·fps 게이트 검증은 Phase 0 본구현에서 진행.

## 셋업

요구: macOS + [Flutter SDK](https://docs.flutter.dev/get-started/install/macos) (3.22+) + Xcode.

```bash
bash setup.sh      # ios/·android/ 플랫폼 폴더 생성 + flutter pub get
flutter run        # 시뮬레이터/실기기에서 실행
```

`setup.sh`는 임시 디렉토리에서 `flutter create`를 돌려 **플랫폼 폴더만** 가져오므로,
`lib/`와 `pubspec.yaml`은 덮어쓰지 않는다.

> `ios/`·`android/` 플랫폼 폴더는 저장소에 커밋한다(표준 Flutter 관행). 빌드 산출물
> (`build/`, `.dart_tool/`, `ios/Pods/` 등)만 `.gitignore`로 제외. 플랫폼 폴더가 없는
> 새 환경이라면 `bash setup.sh`로 재생성할 수 있다.

## 구조 (§3)

```
lib/
  main.dart / app.dart          # 진입점, 테마
  core/                         # constants, theme
  data/
    models/                     # ★ species.dart = 핵심 종 추상화
    repositories/               # 상태 영속화 (Phase 0: 인메모리)
  game/                         # Flame 영역
    aquarium_game.dart          # FlameGame 본체
    components/fish_component.dart  # 코드 도형 금붕어 (스프라이트 교체 지점)
    behaviors/                  # swim/touch/tilt
  features/                     # 화면별 (aquarium만 동작, 나머지 Phase별 자리표시)
  services/                     # audio/subscription/sleep_timer (Phase 0: stub)
```

## 설계 핵심 — 종은 데이터다 (§1-3, §4)

금붕어를 하드코딩하지 않는다. 모든 개체는 `data/models/species.dart`의 `Species`를 참조한다.
새 종 추가 = `species_registry.dart`에 한 벌 등록. v2 해파리·바다달팽이도 같은 방식.
v1은 `goldfish_white`/`goldfish_black` 2종, 헤엄은 `SwimStyle.glide`만 구현.

## Phase 0 DoD (§6)

실기기에서 **60fps 유지** + "예쁘게 헤엄친다" 주관 합격.
미달 시 임의로 엔진 바꾸지 말고 SpriteKit 대안을 사람과 상의(§2 게이트).

## 범위 주의 (§8)

여러 마리·다른 생물·수면 추적·성장 트리·유체 시뮬레이션 등은 **v1 금지**.
단, 종 추상화 구조는 v1부터 유지한다.

## 컴플라이언스 (§9)

- 오디오는 라이선스 클린 소스만, 출처를 `assets/audio/CREDITS.md`에 기록.
- 구독: 무료체험·자동갱신·해지방법 고지 UI 필수(심사).
- 카피: 의학적 효능 주장 금지("힐링/이완" OK, "불면증 치료" NG).
