/// Customer phone numbers (FR-M-037, master FR-CUS-016, contract 1.23.0).
/// Pure rules, no I/O.
///
/// The ERP owns the numbers it sends; staff may add more in the app. Added
/// numbers are kept by field-api (never written to the ERP). On the phone the
/// list lives in `customers.phones_json`: an ERP number is a plain string (as
/// before 0.13.1), an added one is `{"n": number, "s": "f", "l": label,
/// "p": true}` where `p` marks one that is saved here but not yet on the server.
library;

import 'dart:convert';

class CustomerPhone {
  const CustomerPhone({required this.number, this.fromErp = true, this.primary = false, this.label, this.pending = false});
  final String number;

  /// Sent by the office system (false = added in the app or the admin panel).
  final bool fromErp;

  /// The first ERP number: the one the office uses.
  final bool primary;

  /// Whose number it is, as typed (added numbers only).
  final String? label;

  /// Added on this phone and still waiting to reach the server.
  final bool pending;

  Object toStored() => fromErp
      ? number
      : {'n': number, 's': 'f', if (label != null && label!.isNotEmpty) 'l': label, if (pending) 'p': true};
}

/// Most numbers that can be added to one customer, and in one go.
const maxExtraPhones = 5;

/// Reads `phones_json`. Rows written before 0.13.1 are plain strings: all ERP
/// numbers, the first one the main number.
List<CustomerPhone> decodePhones(String json) {
  final Object? raw;
  try {
    raw = jsonDecode(json);
  } on FormatException {
    return const [];
  }
  if (raw is! List) return const [];
  final out = <CustomerPhone>[];
  var erpSeen = false;
  for (final e in raw) {
    if (e is String && e.isNotEmpty) {
      out.add(CustomerPhone(number: e, primary: !erpSeen));
      erpSeen = true;
    } else if (e is Map && e['n'] is String) {
      out.add(CustomerPhone(number: e['n'] as String, fromErp: false, label: e['l'] as String?, pending: e['p'] == true));
    }
  }
  return out;
}

String encodePhones(List<CustomerPhone> phones) => jsonEncode([for (final p in phones) p.toStored()]);

/// The list a customer payload from the server describes. With `phoneDetails`
/// (1.23.0) each number says where it came from; an older server sends only
/// `phone` / `phones`, which are all ERP numbers.
List<CustomerPhone> phonesFromServer(Map<String, dynamic> d) {
  final details = d['phoneDetails'];
  if (details is List && details.isNotEmpty) {
    final out = <CustomerPhone>[];
    for (final e in details) {
      if (e is! Map || e['number'] is! String) continue;
      final erp = e['source'] != 'field';
      out.add(CustomerPhone(number: e['number'] as String, fromErp: erp, primary: erp && e['primary'] == true, label: erp ? null : e['label'] as String?));
    }
    return out;
  }
  final numbers = <String>{
    if (d['phone'] is String && (d['phone'] as String).isNotEmpty) d['phone'] as String,
    for (final p in (d['phones'] as List?) ?? const []) if (p is String && p.isNotEmpty) p,
  }.toList();
  return [for (var i = 0; i < numbers.length; i++) CustomerPhone(number: numbers[i], primary: i == 0)];
}

/// The server's list plus the numbers added on this phone that have not
/// reached the server yet, so a pull never makes a just-typed number vanish.
List<CustomerPhone> keepPending(List<CustomerPhone> server, List<CustomerPhone> local) {
  final have = {for (final p in server) p.number};
  return [...server, for (final p in local) if (p.pending && !have.contains(p.number)) p];
}

const _bnDigits = '০১২৩৪৫৬৭৮৯';
final _bdMobile = RegExp(r'^01[3-9]\d{8}$');

/// One Bangladeshi mobile number as `01XXXXXXXXX`, or null. Accepts Bangla
/// digits, spaces, dashes, brackets, `+880…`, `880…` and ten digits without the
/// leading zero. Same rule as field-api.
String? normalizeMobile(String input) {
  final b = StringBuffer();
  for (final r in input.trim().runes) {
    final ch = String.fromCharCode(r);
    final bn = _bnDigits.indexOf(ch);
    if (bn >= 0) {
      b.write(bn);
    } else if (r >= 0x30 && r <= 0x39) {
      b.write(ch);
    } else if (!' -()+.'.contains(ch)) {
      return null; // letters or other text: not a number
    }
  }
  var d = b.toString();
  if (d.length == 13 && d.startsWith('880')) {
    d = d.substring(2);
  } else if (d.length == 10 && RegExp(r'^1[3-9]').hasMatch(d)) {
    d = '0$d';
  }
  return _bdMobile.hasMatch(d) ? d : null;
}

enum PhoneDraftError { invalid, duplicate, repeated }

typedef PhoneDraft = ({String number, String label});
typedef PhoneToAdd = ({String number, String? label});

class DraftCheck {
  const DraftCheck(this.errors, this.phones);

  /// One entry per row: null = fine or empty.
  final List<PhoneDraftError?> errors;

  /// The valid numbers, normalized, in the order typed.
  final List<PhoneToAdd> phones;
  bool get hasError => errors.any((e) => e != null);
}

/// Checks the rows of the "add numbers" sheet. Empty rows are ignored.
/// `duplicate` = the customer already has the number; `repeated` = typed
/// twice in the sheet.
DraftCheck checkPhoneDrafts(List<PhoneDraft> drafts, List<CustomerPhone> existing) {
  final have = {for (final p in existing) p.number};
  final typed = <String>{};
  final phones = <PhoneToAdd>[];
  final errors = <PhoneDraftError?>[];
  for (final d in drafts) {
    if (d.number.trim().isEmpty) {
      errors.add(null);
      continue;
    }
    final n = normalizeMobile(d.number);
    if (n == null) {
      errors.add(PhoneDraftError.invalid);
    } else if (have.contains(n)) {
      errors.add(PhoneDraftError.duplicate);
    } else if (!typed.add(n)) {
      errors.add(PhoneDraftError.repeated);
    } else {
      final label = d.label.trim();
      phones.add((number: n, label: label.isEmpty ? null : label));
      errors.add(null);
    }
  }
  return DraftCheck(errors, phones);
}

/// How many more numbers can be added to this customer.
int phoneRoom(List<CustomerPhone> existing) => maxExtraPhones - existing.where((p) => !p.fromErp).length;
