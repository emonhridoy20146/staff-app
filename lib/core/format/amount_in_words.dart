import 'money.dart';

/// Amount in words, Bangla and English, using the South-Asian scale
/// (কোটি / লক্ষ / হাজার / শত; crore / lakh / thousand / hundred).
/// Used on the collection review step, receipts and TalkBack labels.
const _bnUnder100 = [
  'শূন্য', 'এক', 'দুই', 'তিন', 'চার', 'পাঁচ', 'ছয়', 'সাত', 'আট', 'নয়', //
  'দশ', 'এগারো', 'বারো', 'তেরো', 'চৌদ্দ', 'পনেরো', 'ষোলো', 'সতেরো', 'আঠারো', 'উনিশ',
  'বিশ', 'একুশ', 'বাইশ', 'তেইশ', 'চব্বিশ', 'পঁচিশ', 'ছাব্বিশ', 'সাতাশ', 'আটাশ', 'উনত্রিশ',
  'ত্রিশ', 'একত্রিশ', 'বত্রিশ', 'তেত্রিশ', 'চৌত্রিশ', 'পঁয়ত্রিশ', 'ছত্রিশ', 'সাঁইত্রিশ', 'আটত্রিশ', 'উনচল্লিশ',
  'চল্লিশ', 'একচল্লিশ', 'বিয়াল্লিশ', 'তেতাল্লিশ', 'চুয়াল্লিশ', 'পঁয়তাল্লিশ', 'ছেচল্লিশ', 'সাতচল্লিশ', 'আটচল্লিশ', 'উনপঞ্চাশ',
  'পঞ্চাশ', 'একান্ন', 'বায়ান্ন', 'তিপ্পান্ন', 'চুয়ান্ন', 'পঞ্চান্ন', 'ছাপ্পান্ন', 'সাতান্ন', 'আটান্ন', 'উনষাট',
  'ষাট', 'একষট্টি', 'বাষট্টি', 'তেষট্টি', 'চৌষট্টি', 'পঁয়ষট্টি', 'ছেষট্টি', 'সাতষট্টি', 'আটষট্টি', 'উনসত্তর',
  'সত্তর', 'একাত্তর', 'বাহাত্তর', 'তিয়াত্তর', 'চুয়াত্তর', 'পঁচাত্তর', 'ছিয়াত্তর', 'সাতাত্তর', 'আটাত্তর', 'উনআশি',
  'আশি', 'একাশি', 'বিরাশি', 'তিরাশি', 'চুরাশি', 'পঁচাশি', 'ছিয়াশি', 'সাতাশি', 'অষ্টাশি', 'উননব্বই',
  'নব্বই', 'একানব্বই', 'বিরানব্বই', 'তিরানব্বই', 'চুরানব্বই', 'পঁচানব্বই', 'ছিয়ানব্বই', 'সাতানব্বই', 'আটানব্বই', 'নিরানব্বই',
];

const _enOnes = [
  'zero', 'one', 'two', 'three', 'four', 'five', 'six', 'seven', 'eight', 'nine', //
  'ten', 'eleven', 'twelve', 'thirteen', 'fourteen', 'fifteen', 'sixteen', 'seventeen', 'eighteen', 'nineteen',
];
const _enTens = ['', '', 'twenty', 'thirty', 'forty', 'fifty', 'sixty', 'seventy', 'eighty', 'ninety'];

String _en99(int n) {
  if (n < 20) return _enOnes[n];
  final t = _enTens[n ~/ 10];
  return n % 10 == 0 ? t : '$t-${_enOnes[n % 10]}';
}

List<String> _scale(int n, String Function(int) under100, List<String> names) {
  // names: [crore, lakh, thousand, hundred]
  final parts = <String>[];
  var rest = n;
  final crore = rest ~/ 10000000;
  rest %= 10000000;
  if (crore > 0) {
    // crore count can exceed 99 — recurse.
    parts.addAll([..._scale(crore, under100, names), names[0]]);
  }
  final lakh = rest ~/ 100000;
  rest %= 100000;
  if (lakh > 0) parts.addAll([under100(lakh), names[1]]);
  final thousand = rest ~/ 1000;
  rest %= 1000;
  if (thousand > 0) parts.addAll([under100(thousand), names[2]]);
  final hundred = rest ~/ 100;
  rest %= 100;
  if (hundred > 0) parts.addAll([under100(hundred), names[3]]);
  if (rest > 0) parts.add(under100(rest));
  return parts;
}

String _bnInt(int n) => n == 0
    ? _bnUnder100[0]
    // Written Bangla joins the hundreds word: "পাঁচশত", not "পাঁচ শত".
    : _scale(n, (i) => _bnUnder100[i], const ['কোটি', 'লক্ষ', 'হাজার', 'শত']).join(' ').replaceAll(' শত', 'শত');

String _enInt(int n) =>
    n == 0 ? 'zero' : _scale(n, _en99, const ['crore', 'lakh', 'thousand', 'hundred']).join(' ');

/// "পাঁচ হাজার টাকা", "বারো লক্ষ পঞ্চাশ হাজার পাঁচশত টাকা পঞ্চাশ পয়সা".
String amountInWordsBn(Poisha poisha) {
  final taka = poisha.abs() ~/ 100;
  final p = poisha.abs() % 100;
  final b = StringBuffer('${_bnInt(taka)} টাকা');
  if (p > 0) b.write(' ${_bnUnder100[p]} পয়সা');
  return b.toString();
}

/// "Five thousand taka", "Twelve lakh fifty thousand five hundred taka".
String amountInWordsEn(Poisha poisha) {
  final taka = poisha.abs() ~/ 100;
  final p = poisha.abs() % 100;
  var s = '${_enInt(taka)} taka';
  if (p > 0) s = '$s and ${_en99(p)} poisha';
  return s[0].toUpperCase() + s.substring(1);
}

String amountInWords(Poisha poisha, String languageCode) =>
    languageCode == 'bn' ? amountInWordsBn(poisha) : amountInWordsEn(poisha);
