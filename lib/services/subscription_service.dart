/// RevenueCat 래퍼 (§3, §6 Phase 3). 구독 + 7일 무료체험.
/// 직접 StoreKit 핸들링 지양(§2). Phase 3에서 purchases_flutter 연동.
///
/// Phase 0: 항상 무료 사용자로 동작하는 stub. 게이팅 로직 개발/테스트용.
abstract class SubscriptionService {
  Future<bool> isSubscribed();

  /// 구독 화면에서 호출. Phase 3에서 RevenueCat purchase 흐름 연결.
  Future<bool> purchase(String packageId);

  /// 자동갱신·해지방법 고지(§9 심사 필수)는 Paywall UI에서 처리.
  Future<void> restore();
}

class FreeTierStubSubscriptionService implements SubscriptionService {
  @override
  Future<bool> isSubscribed() async => false;

  @override
  Future<bool> purchase(String packageId) async => false;

  @override
  Future<void> restore() async {}
}
