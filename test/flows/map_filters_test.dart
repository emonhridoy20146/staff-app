import 'package:flutter_test/flutter_test.dart';
import 'package:staff_app/features/customers/customers.dart';
import 'package:staff_app/features/map/src/map_screen.dart';

import 'helpers.dart';

void main() {
  late Harness h;
  setUp(() => h = Harness());
  tearDown(() async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    await h.dispose();
  });

  test('map filters keep only matching customers (any of the selected), offline', () async {
    await h.signIn();
    h.api.offline = true;
    final all = await h.read(customerRepositoryProvider).watchAll().first;
    const today = '2026-11-15';
    expect(applyMapFilters(all, const {}, today), hasLength(all.length));

    final overdue = applyMapFilters(all, {CustomerFilter.overdue}, today);
    expect(overdue, isNotEmpty);
    expect(overdue.every((c) => c.row.daysOverdue > 0), isTrue);

    final due = applyMapFilters(all, {CustomerFilter.dueToday}, today);
    final either = applyMapFilters(all, {CustomerFilter.overdue, CustomerFilter.dueToday}, today);
    expect(either.map((c) => c.id).toSet(), {...overdue.map((c) => c.id), ...due.map((c) => c.id)});
  });

  test('list is nearest first, customers without a pin last', () async {
    await h.signIn();
    final all = await h.read(customerRepositoryProvider).watchAll().first;
    final pinned = all.where((c) => c.hasPin).toList();
    final unpinned = all.where((c) => !c.hasPin).toList();
    expect(pinned.length, greaterThan(2));
    expect(unpinned, isNotEmpty);
    final withD = [
      unpinned.first,
      pinned[0].withDistance(900),
      pinned[1].withDistance(120),
      pinned[2].withDistance(450),
    ];
    final sorted = byDistance(withD);
    expect(sorted.map((c) => c.distanceM), [120, 450, 900, null]);
    expect(sorted.last.hasPin, isFalse);
  });
}
