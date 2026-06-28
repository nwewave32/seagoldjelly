#!/usr/bin/env bash
# 잠드는 어항 — 플랫폼 스캐폴드 생성 스크립트
#
# 이 저장소에는 lib/ 소스, pubspec.yaml, 에셋만 들어있다.
# iOS/Android 플랫폼 폴더(ios/, android/)는 Flutter SDK가 생성해야 하므로
# 이 스크립트가 임시 디렉토리에 `flutter create`를 돌린 뒤,
# 플랫폼 폴더만 가져온다. (기존 lib/·pubspec.yaml은 절대 덮어쓰지 않음)
#
# 사용법:  bash setup.sh
set -euo pipefail

ORG="com.sleepyaquarium"
NAME="seagoldjelly"
HERE="$(cd "$(dirname "$0")" && pwd)"

if ! command -v flutter >/dev/null 2>&1; then
  echo "❌ flutter 명령을 찾을 수 없습니다. Flutter SDK를 먼저 설치하세요:"
  echo "   https://docs.flutter.dev/get-started/install/macos"
  exit 1
fi

echo "▶ Flutter 버전:"
flutter --version

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

echo "▶ 임시 디렉토리에 플랫폼 스캐폴드 생성..."
flutter create \
  --org "$ORG" \
  --project-name "$NAME" \
  --platforms=ios,android \
  "$TMP/scaffold" >/dev/null

echo "▶ 플랫폼 폴더만 저장소로 복사 (lib/·pubspec.yaml 보존)..."
for d in ios android .metadata; do
  if [ -e "$TMP/scaffold/$d" ]; then
    rm -rf "$HERE/$d"
    cp -R "$TMP/scaffold/$d" "$HERE/$d"
  fi
done

echo "▶ 의존성 설치..."
cd "$HERE"
flutter pub get

echo ""
echo "✅ 셋업 완료."
echo "   다음 명령으로 실행하세요:"
echo "     flutter run                 # 연결된 기기/시뮬레이터"
echo "     open ios/Runner.xcworkspace # Xcode에서 iOS 빌드"
echo ""
echo "ℹ️  Phase 0 fps 게이트: 실기기에서 60fps 확인 (flutter run 후 'P'로 perf overlay,"
echo "    또는 DevTools). 미달 시 임의로 엔진 바꾸지 말고 사람과 상의(§2 게이트)."
