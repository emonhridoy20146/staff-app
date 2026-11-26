/// Local, offline customer search text (FR-CUS-002, FR-M-076). Pure, no I/O.
///
/// `customers.search_text` holds two lines:
///
///     <normalised words, single spaces>\n<the same with no spaces>
///
/// The second line lets a query typed with spaces ("01712 345678", "০১৭১২ ৩৪৫৬৭৮")
/// match a number stored without them, and a query typed without spaces match
/// a name or address with them. It is built once, when the row is written, so a
/// keystroke over ~3000 customers is only two `contains` per row and allocates
/// nothing per row. A query never holds a line break ([normalizeSearch] folds
/// all white space into single spaces), so no match can run across the two lines.
///
/// This lives in core because the drift migration that re-indexes old rows
/// (schema 19) builds the same text as the customer pull handler.
library;

/// Lower-case, Bangla digits → Latin, `- . , /` and other punctuation below
/// '0' dropped, white space folded into single spaces.
String normalizeSearch(String s) {
  final b = StringBuffer();
  for (final r in s.toLowerCase().runes) {
    final d = r - 0x09E6;
    if (d >= 0 && d <= 9) {
      b.writeCharCode(0x30 + d);
    } else if (r == 0x20 || r >= 0x30) {
      b.writeCharCode(r);
    } else if (r == 0x09 || r == 0x0A || r == 0x0D) {
      b.writeCharCode(0x20);
    }
  }
  return b.toString().replaceAll(RegExp(r'[\-\.,/]'), '').replaceAll(RegExp(r'\s+'), ' ').trim();
}

/// [normalizeSearch] with the spaces removed.
String compactSearch(String s) => normalizeSearch(s).replaceAll(' ', '');

/// The stored search text of a customer: names, code, every phone number
/// (ERP and added) and address, and every invoice number of the customer's
/// plans (all kinds, open or closed).
String customerSearchText({
  required String nameBn,
  String? nameEn,
  String? code,
  Iterable<String> phones = const [],
  String? address,
  Iterable<String> invoiceNos = const [],
}) =>
    _withCompact(normalizeSearch([nameBn, nameEn ?? '', code ?? '', ...phones, address ?? '', ...invoiceNos].join(' ')));

/// [existing] search text with [extra] words added (e.g. a phone number typed
/// on this phone before the next pull rebuilds the row).
String addToSearchText(String existing, String extra) {
  final nl = existing.indexOf('\n');
  final words = nl < 0 ? existing : existing.substring(0, nl);
  return _withCompact(normalizeSearch('$words $extra'));
}

String _withCompact(String words) => '$words\n${words.replaceAll(' ', '')}';

/// What the user typed, normalised once per query (not once per row).
class SearchQuery {
  SearchQuery(String typed)
      : words = normalizeSearch(typed),
        compact = compactSearch(typed);

  final String words;
  final String compact;

  bool get isEmpty => words.isEmpty;

  /// Whether a stored search text matches; an empty query matches everything.
  bool matches(String searchText) => words.isEmpty || searchText.contains(words) || searchText.contains(compact);
}
