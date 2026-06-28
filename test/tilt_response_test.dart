import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seagoldjelly/game/behaviors/tilt_response.dart';

void main() {
  group('TiltResponse', () {
    // 중립 자세를 잡기 위해 보정 샘플 수만큼 같은 값을 먹인다.
    void calibrate(TiltResponse t, double ax, double ay) {
      for (var i = 0; i < TiltResponse.calibrationSamples; i++) {
        t.setFromAccelerometer(ax, ay, 0);
      }
    }

    test('보정 중에는 gravity가 0이다', () {
      final t = TiltResponse();
      t.setFromAccelerometer(0, 9.8, 0); // 첫 샘플
      expect(t.gravity.length, 0);
    });

    test('중립 자세 유지 시 쏠림이 거의 0', () {
      final t = TiltResponse();
      calibrate(t, 0, 9.8);
      for (var i = 0; i < 30; i++) {
        t.setFromAccelerometer(0, 9.8, 0); // 계속 중립
      }
      expect(t.gravity.length, lessThan(0.5));
    });

    test('오른쪽으로 기울이면 gravity.x가 양수로 수렴', () {
      final t = TiltResponse();
      calibrate(t, 0, 9.8);
      for (var i = 0; i < 60; i++) {
        t.setFromAccelerometer(2.0, 9.8, 0); // ax 증가 = 우측 기울기
      }
      expect(t.gravity.x, greaterThan(0));
      expect(t.gravity.y.abs(), lessThan(1.0)); // 좌우 기울기는 y에 거의 영향 없음
    });

    test('아무리 세게 기울여도 최대치를 넘지 않는다', () {
      final t = TiltResponse();
      calibrate(t, 0, 9.8);
      for (var i = 0; i < 100; i++) {
        t.setFromAccelerometer(100.0, 100.0, 0); // 극단값
      }
      expect(t.gravity.length, lessThanOrEqualTo(TiltResponse.maxMagnitude + 0.001));
    });

    test('recalibrate 후 gravity가 0으로 리셋', () {
      final t = TiltResponse();
      calibrate(t, 0, 9.8);
      for (var i = 0; i < 30; i++) {
        t.setFromAccelerometer(3.0, 9.8, 0);
      }
      expect(t.gravity.length, greaterThan(0));
      t.recalibrate();
      expect(t.gravity, Vector2.zero());
    });
  });
}
