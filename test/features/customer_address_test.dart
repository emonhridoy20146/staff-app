import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:staff_app/core/db/app_database.dart';
import 'package:staff_app/features/customers/src/domain/customer.dart';

/// Owner report 2026-11-23: the customer page showed the pin icon with no address beside it. A blank ERP address
/// now falls back to the ERP detailed address, then the area; with none the page says so (detailNoAddress).
void main() {
  Customer customer({String? address, String? detailed, String? area}) => Customer(CustomerRow(
        serverId: 'c1',
        code: 'c1',
        nameBn: 'ক',
        phonesJson: '[]',
        address: address,
        detailedAddress: detailed,
        areaName: area,
        locationStatus: 'ok',
        totalOutstandingPoisha: 0,
        overduePoisha: 0,
        daysOverdue: 0,
        dueToday: false,
        overdue: false,
        badSuggested: false,
        tagState: 'none',
        pendingFieldPoisha: 0,
        searchText: '',
        version: 0,
      ));

  test('the ERP address is shown, and the detailed one under it when different', () {
    final c = customer(address: 'চরকাজল, গলাচিপা', detailed: 'বাজারের পূর্ব পাশে');
    expect(c.address, 'চরকাজল, গলাচিপা');
    expect(c.detailedAddress, 'বাজারের পূর্ব পাশে');
  });

  test('a blank ERP address (the server sends "") falls back to the detailed address, shown once', () {
    final c = customer(address: '  ', detailed: 'বাজারের পূর্ব পাশে');
    expect(c.address, 'বাজারের পূর্ব পাশে');
    expect(c.detailedAddress, isNull);
  });

  test('no address and no detailed address: the area', () {
    expect(customer(address: '', area: 'গলাচিপা সদর').address, 'গলাচিপা সদর');
  });

  test('nothing known: null, so the page says "no address in the ERP"', () {
    expect(customer(address: '').address, isNull);
    expect(customer().address, isNull);
  });

  test('a detailed address equal to the address is not repeated', () {
    expect(customer(address: 'ক গ্রাম', detailed: ' ক গ্রাম ').detailedAddress, isNull);
  });

  // Keeps the import used when drift's Value is not needed above.
  test('companion still builds', () => expect(const CustomersCompanion(address: Value('x')).address.value, 'x'));
}
