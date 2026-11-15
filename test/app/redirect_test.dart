import 'package:flutter_test/flutter_test.dart';
import 'package:staff_app/app/router.dart';
import 'package:staff_app/features/auth/auth.dart';

void main() {
  String? r(SessionStage s, String loc, {bool upgrade = false}) => redirectFor(stage: s, upgradeRequired: upgrade, location: loc);

  test('each gate stage forces its screen', () {
    expect(r(SessionStage.signedOut, '/today'), '/login');
    expect(r(SessionStage.locked, '/customers/c-1'), '/pin');
    expect(r(SessionStage.needsConsent, '/login'), '/consent');
    expect(r(SessionStage.signedOut, '/login'), isNull);
  });

  test('ready leaves gate screens for Today but keeps deep links', () {
    expect(r(SessionStage.ready, '/pin'), '/today');
    expect(r(SessionStage.ready, '/customers/c-1'), isNull);
  });

  test('426 upgrade wins once the session is known', () {
    expect(r(SessionStage.ready, '/today', upgrade: true), '/update');
    expect(r(SessionStage.loading, '/splash', upgrade: true), isNull);
  });
}
