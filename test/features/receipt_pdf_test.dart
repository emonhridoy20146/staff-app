import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:staff_app/features/collections/src/domain/receipt_pdf.dart';

/// FR-M-055: the receipt as a one-page PDF.
void main() {
  // a 1×1 PNG
  final png = base64Decode('iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8DwHwAFBQIAX8jx0gAAAABJRU5ErkJggg==');

  test('is a PDF with one page named after the receipt', () async {
    final bytes = await receiptPdfBytes(png: png, widthPx: 1080, heightPx: 1620, receiptNo: 'BRL01-FS014-261121-0001');
    final text = latin1.decode(bytes);
    expect(text.startsWith('%PDF-'), isTrue);
    expect(RegExp(r'/Type\s*/Page[^s]').allMatches(text).length, 1);
    expect(text, contains('BRL01-FS014-261121-0001'));
  });
}
