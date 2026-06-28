import 'package:flame/components.dart';

/// 기울기(가속도계) 반응 (§6 Phase 0).
/// 가속도계 값을 화면 좌표계 중력 벡터로 변환한다(+x 오른쪽, +y 아래).
///
/// "물이 든 쟁반" 모델: 시작 시점의 자세를 중립(baseline)으로 잡고,
/// 거기서 기울인 만큼만 쏠림이 생긴다. 그래서 폰을 어떻게 들고 시작하든
/// 그 자세가 평온 상태가 되고, 기울이면 그쪽으로 흐른다.
///
/// 차분한 앱 톤을 위해 저역통과(smoothing)로 손떨림·센서 노이즈를 완화한다.
/// 센서가 없으면(시뮬레이터) 콜백이 안 와서 gravity는 0으로 유지 → 안전.
class TiltResponse {
  /// 현재 적용할 중력 벡터(px/s 단위 느낌). 평온 시 0.
  Vector2 gravity = Vector2.zero();

  /// 가속도계 → px/s 환산 게인. 실기기에서 느낌 보고 조절.
  static const double gain = 8.0;

  /// 쏠림 최대 세기(px/s). 너무 격해지지 않게 캡.
  static const double maxMagnitude = 90.0;

  /// 저역통과 계수(0~1). 클수록 빠르게 따라가고, 작을수록 차분/느리다.
  static const double smoothing = 0.15;

  /// 중립 보정에 평균낼 초기 샘플 수(첫 한 샘플 튐 방지).
  static const int calibrationSamples = 10;

  Vector2 _baseline = Vector2.zero();
  Vector2? _baselineSum;
  int _baselineCount = 0;
  bool _calibrated = false;

  /// 가속도계 한 샘플 주입. ax/ay/az는 m/s²(중력 포함).
  void setFromAccelerometer(double ax, double ay, double az) {
    // 화면 좌표 매핑. 실기기에서 좌우/상하가 반대로 느껴지면
    // 아래 ax/ay 앞 부호만 뒤집어 튜닝하면 된다.
    final cur = Vector2(ax, -ay);

    // 초기 몇 샘플을 평균내 중립 자세로 보정(움직이는 중 켜져도 안정).
    if (!_calibrated) {
      (_baselineSum ??= Vector2.zero()).add(cur);
      _baselineCount++;
      if (_baselineCount >= calibrationSamples) {
        _baseline = _baselineSum! / _baselineCount.toDouble();
        _calibrated = true;
      }
      return; // 보정 중엔 gravity 0 유지
    }

    var targetG = (cur - _baseline) * gain; // 중립에서 기울인 만큼만
    final mag = targetG.length;
    if (mag > maxMagnitude) {
      targetG = targetG * (maxMagnitude / mag);
    }

    // 저역통과: 노이즈/손떨림 완화 → 차분한 반응.
    gravity = gravity + (targetG - gravity) * smoothing;
  }

  /// 현재 자세를 다시 중립으로(예: 설정에서 '수평 보정'). Phase 4에서 노출 가능.
  void recalibrate() {
    _calibrated = false;
    _baselineSum = null;
    _baselineCount = 0;
    gravity = Vector2.zero();
  }
}
