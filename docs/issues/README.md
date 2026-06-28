# 이슈 트래킹

솔로 개발 친화(§1-5)로 가볍게 운영하는 마크다운 기반 이슈 로그.
별도 툴 없이 Phase별 파일 하나로 관리한다.

## 파일 구조

```
docs/issues/
  README.md        # 이 문서 (규칙 + 전체 인덱스)
  phase-0.md       # Phase 0 이슈
  phase-1.md       # (생성 예정)
  ...
```

## 이슈 ID 규칙

`P{phase}-{번호}` — 예: `P0-001`, `P1-003`. 번호는 Phase 안에서 순차 증가, 재사용 금지.

## 상태(Status)

| 상태 | 의미 |
|---|---|
| `Open` | 미해결 |
| `In Progress` | 작업 중 |
| `Fixed` | 코드 수정 완료, 검증 대기 |
| `Verified` | 실기기/시뮬레이터에서 해결 확인 |
| `Won't Fix` | 의도적 보류 (사유 기록) |

## 심각도(Severity)

| 등급 | 기준 |
|---|---|
| `Critical` | 크래시 / 코어 루프 차단 |
| `High` | 핵심 기능 동작 불가 |
| `Medium` | 동작하나 품질·UX 저하 (DoD 위협) |
| `Low` | 사소한 폴리시 |

## 이슈 항목 템플릿

```md
### P0-00X — 제목
- **Status:** Open
- **Severity:** Medium
- **Area:** lib/path/to/file.dart
- **Spec:** §6 Phase 0 DoD
- **증상:** 무엇이 어떻게 보이는가
- **재현:** 어떤 상황에서
- **원인:** 근본 원인
- **제안 수정:** 어떻게 고칠지
- **로그:** YYYY-MM-DD 메모
```

## 전체 인덱스

| ID | Phase | 제목 | Severity | Status |
|---|---|---|---|---|
| [P0-001](./phase-0.md#p0-001--물고기-좌우-반전이-빠르게-깜빡임-facing-flicker) | 0 | 물고기 좌우 반전 깜빡임 | Medium | Verified |
