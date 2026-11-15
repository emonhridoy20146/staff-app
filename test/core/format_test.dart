import 'package:flutter_test/flutter_test.dart';
import 'package:staff_app/core/format/amount_in_words.dart';
import 'package:staff_app/core/format/digits.dart';
import 'package:staff_app/core/format/money.dart';

void main() {
  group('money', () {
    test('groups the South Asian way', () {
      expect(groupSouthAsian(0), '0');
      expect(groupSouthAsian(999), '999');
      expect(groupSouthAsian(1000), '1,000');
      expect(groupSouthAsian(100000), '1,00,000');
      expect(groupSouthAsian(12345678), '1,23,45,678');
    });

    test('formats poisha with Bangla digits by default', () {
      expect(formatMoney(150000), '৳১,৫০০');
      expect(formatMoney(150050), '৳১,৫০০.৫০');
      expect(formatMoney(612500000, digits: DigitStyle.latin), '৳61,25,000');
      expect(formatMoney(-5000, digits: DigitStyle.latin), '-৳50');
    });

    test('parses keypad input in either digit set to poisha', () {
      expect(parseMoneyInput('1500'), 150000);
      expect(parseMoneyInput('১৫০০'), 150000);
      expect(parseMoneyInput('1,500.5'), 150050);
      expect(parseMoneyInput(''), isNull);
    });
  });

  group('amount in words', () {
    test('Bangla uses lakh / crore', () {
      expect(amountInWordsBn(150000), contains('এক হাজার পাঁচশত'));
      expect(amountInWordsBn(250000000), contains('পঁচিশ লক্ষ'));
    });
    test('English uses lakh / crore', () {
      expect(amountInWordsEn(150000).toLowerCase(), contains('one thousand five hundred'));
      expect(amountInWordsEn(1000000000).toLowerCase(), contains('one crore'));
    });
  });

  test('digits convert both ways', () {
    expect(toBanglaDigits('2026-11-15'), '২০২৬-১১-১৫');
    expect(localizeDigits('42', DigitStyle.latin), '42');
  });
}
