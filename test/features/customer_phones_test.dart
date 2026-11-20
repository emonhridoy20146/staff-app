import 'package:flutter_test/flutter_test.dart';
import 'package:staff_app/features/customers/src/domain/phones.dart';

/// FR-M-037 (master FR-CUS-016, contract 1.23.0): ERP numbers and numbers
/// added in the field. Fake numbers only.
void main() {
  group('stored list', () {
    test('rows written before 0.13.1 are plain strings: all ERP numbers, the first one main', () {
      final list = decodePhones('["01711000001","01911000002"]');
      expect(list.map((p) => (p.number, p.fromErp, p.primary)), [('01711000001', true, true), ('01911000002', true, false)]);
      expect(decodePhones('[]'), isEmpty);
      expect(decodePhones('not json'), isEmpty);
      expect(decodePhones('{"a":1}'), isEmpty);
    });

    test('added numbers keep their label and waiting mark through encode and decode', () {
      const list = [
        CustomerPhone(number: '01711000001', primary: true),
        CustomerPhone(number: '01811000004', fromErp: false, label: 'wife', pending: true),
        CustomerPhone(number: '01311000005', fromErp: false),
      ];
      final back = decodePhones(encodePhones(list));
      expect(back.map((p) => p.number), ['01711000001', '01811000004', '01311000005']);
      expect(back[0].primary, isTrue);
      expect((back[1].fromErp, back[1].label, back[1].pending), (false, 'wife', true));
      expect((back[2].fromErp, back[2].label, back[2].pending), (false, null, false));
      expect(phoneRoom(back), 3);
    });
  });

  group('from the server', () {
    test('phoneDetails says where each number came from', () {
      final list = phonesFromServer({
        'phone': '01711000001',
        'phones': ['01711000001', '01911000002', '01811000004'],
        'phoneDetails': [
          {'number': '01711000001', 'source': 'erp', 'primary': true},
          {'number': '01911000002', 'source': 'erp', 'primary': false},
          {'number': '01811000004', 'source': 'field', 'primary': false, 'label': 'wife'},
        ],
      });
      expect(list.map((p) => (p.number, p.fromErp, p.primary, p.label)), [
        ('01711000001', true, true, null),
        ('01911000002', true, false, null),
        ('01811000004', false, false, 'wife'),
      ]);
    });

    test('an older server sends only phone and phones: ERP numbers, no doubles', () {
      final list = phonesFromServer({'phone': '01711000001', 'phones': ['01711000001', '01911000002']});
      expect(list.map((p) => p.number), ['01711000001', '01911000002']);
      expect(list.every((p) => p.fromErp), isTrue);
      expect(list.first.primary, isTrue);
      expect(phonesFromServer(const {}), isEmpty);
    });

    test('a pull keeps a number typed here that the server does not have yet, and drops it once the server has it', () {
      const server = [CustomerPhone(number: '01711000001', primary: true)];
      const local = [
        CustomerPhone(number: '01711000001', primary: true),
        CustomerPhone(number: '01811000004', fromErp: false, pending: true),
        CustomerPhone(number: '01311000005', fromErp: false), // already confirmed once: the server list decides
      ];
      expect(keepPending(server, local).map((p) => p.number), ['01711000001', '01811000004']);
      const later = [CustomerPhone(number: '01711000001', primary: true), CustomerPhone(number: '01811000004', fromErp: false)];
      final merged = keepPending(later, local);
      expect(merged.map((p) => p.number), ['01711000001', '01811000004']);
      expect(merged.last.pending, isFalse);
    });
  });

  group('typing a number', () {
    test('the usual spellings become 01XXXXXXXXX', () {
      for (final v in ['01711000001', ' 017-1100 0001 ', '+8801711000001', '8801711000001', '1711000001', '০১৭১১০০০০০১']) {
        expect(normalizeMobile(v), '01711000001', reason: v);
      }
    });

    test('text, land lines and wrong lengths are refused', () {
      for (final v in ['', 'abc', '01211000001', '0171100000', '017110000011', '01711000001 wife', '02-9876543']) {
        expect(normalizeMobile(v), isNull, reason: v);
      }
    });

    test('the sheet rows: empty ignored, invalid, already there, typed twice', () {
      final r = checkPhoneDrafts(
        [
          (number: '', label: ''),
          (number: '0171', label: ''),
          (number: '01711000001', label: ''),
          (number: '01811000004', label: ' wife '),
          (number: '+8801811000004', label: ''),
          (number: '01311000005', label: ''),
        ],
        const [CustomerPhone(number: '01711000001', primary: true)],
      );
      expect(r.errors, [null, PhoneDraftError.invalid, PhoneDraftError.duplicate, null, PhoneDraftError.repeated, null]);
      expect(r.phones, [(number: '01811000004', label: 'wife'), (number: '01311000005', label: null)]);
      expect(r.hasError, isTrue);
    });
  });
}
