import 'dart:math';

import '../../time/clock.dart';
import '../api_models.dart';

/// Deterministic demo data shaped like `CustomerDetail` (openapi.yaml).
/// Used by the demo flavour and tests; never shipped in prod builds' data.
class DemoSeed {
  DemoSeed(this.today, {int seed = 42}) : _r = Random(seed);
  final String today;
  final Random _r;

  static const _people = [
    ['করিম উদ্দিন', 'Karim Uddin'],
    ['রহিমা বেগম', 'Rahima Begum'],
    ['মোঃ শফিকুল ইসলাম', 'Md. Shafiqul Islam'],
    ['নাসরিন আক্তার', 'Nasrin Akter'],
    ['আবুল কালাম', 'Abul Kalam'],
    ['ফাতেমা খাতুন', 'Fatema Khatun'],
    ['জাহাঙ্গীর আলম', 'Jahangir Alam'],
    ['শাহনাজ পারভীন', 'Shahnaz Parvin'],
    ['মোঃ রফিকুল হক', 'Md. Rafiqul Haque'],
    ['সালমা সুলতানা', 'Salma Sultana'],
    ['আব্দুল মান্নান', 'Abdul Mannan'],
    ['রোকসানা ইয়াসমিন', 'Roksana Yasmin'],
    ['মোঃ কামরুল হাসান', 'Md. Kamrul Hasan'],
    ['হাসিনা বানু', 'Hasina Banu'],
    ['দেলোয়ার হোসেন', 'Delwar Hossain'],
    ['মমতাজ বেগম', 'Momtaz Begum'],
    ['মোঃ আনোয়ার হোসেন', 'Md. Anwar Hossain'],
    ['শিরিন আক্তার', 'Shirin Akter'],
    ['বিপ্লব কুমার দাস', 'Biplob Kumar Das'],
    ['রাশেদা খানম', 'Rasheda Khanam'],
    ['মোঃ সাইফুল ইসলাম', 'Md. Saiful Islam'],
    ['পারভীন সুলতানা', 'Parvin Sultana'],
    ['আলমগীর কবির', 'Alamgir Kabir'],
    ['নূরজাহান বেগম', 'Nurjahan Begum'],
    ['মিজানুর রহমান', 'Mizanur Rahman'],
    ['শামীমা নাসরিন', 'Shamima Nasrin'],
    ['গোলাম মোস্তফা', 'Golam Mostofa'],
    ['লাইলী বেগম', 'Laily Begum'],
    ['সুমন চন্দ্র শীল', 'Sumon Chandra Shil'],
    ['আকলিমা খাতুন', 'Aklima Khatun'],
    ['হুমায়ুন কবির', 'Humayun Kabir'],
    ['তাসলিমা আক্তার', 'Taslima Akter'],
    ['মোঃ জসিম উদ্দিন', 'Md. Jasim Uddin'],
    ['কোহিনূর বেগম', 'Kohinur Begum'],
    ['ইকবাল হোসেন', 'Iqbal Hossain'],
    ['মাহমুদা আক্তার', 'Mahmuda Akter'],
  ];

  static const _areas = [
    ['area-01', 'নথুল্লাবাদ', 22.7115, 90.3480],
    ['area-02', 'রূপাতলী', 22.6870, 90.3530],
    ['area-03', 'কাশীপুর', 22.7230, 90.3330],
  ];

  static const _streets = ['বাজার রোড', 'স্কুল রোড', 'মসজিদ গলি', 'কলেজ রোড', 'ব্রিজ রোড', 'পুকুরপাড়'];

  static const _products = [
    ['ফ্রিজ ২৫২ লিটার', 4500000],
    ['এলইডি টিভি ৪৩"', 3800000],
    ['এলইডি টিভি ৩২"', 2200000],
    ['ওয়াশিং মেশিন ৭ কেজি', 3600000],
    ['এসি ১.৫ টন', 6800000],
    ['মোটরসাইকেল ১২৫ সিসি', 16500000],
    ['মাইক্রোওয়েভ ওভেন', 1450000],
    ['সিলিং ফ্যান (২টি)', 760000],
    ['স্মার্টফোন', 1850000],
  ];

  String _date(int offsetDays) {
    final d = parseBusinessDate(today).add(Duration(days: offsetDays));
    return '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  /// Returns customer detail payloads (contract `CustomerDetail`).
  List<Json> customers({String assigneeId = 'u-fs-014', String assigneeName = 'রাকিব হাসান'}) {
    final out = <Json>[];
    for (var i = 0; i < _people.length; i++) {
      final p = _people[i];
      final area = _areas[i % _areas.length];
      final prod = _products[_r.nextInt(_products.length)];
      final months = const [3, 5, 6, 8, 10, 12, 18][_r.nextInt(7)];
      final total = (prod[1] as int);
      final down = (total * 0.2).round() ~/ 10000 * 10000;
      final financed = total - down;
      final inst = (financed / months).ceil() ~/ 100 * 100;
      final id = 'c-${(1001 + i)}';
      final code = 'BRL-${(1001 + i)}';

      // Scenario mix so every badge and filter has examples.
      // 0-4 promised today · 5-11 due today · 12-25 overdue (some past final
      // due date → bad suggestion) · rest current/paid.
      int startOffset;
      int paidCount;
      if (i < 5) {
        startOffset = -30 * (2 + _r.nextInt(3));
        paidCount = (-startOffset ~/ 30) - 1;
      } else if (i < 12) {
        startOffset = -30 * (1 + _r.nextInt(4));
        paidCount = (-startOffset ~/ 30);
      } else if (i < 26) {
        startOffset = -30 * (months + (i % 3 == 0 ? 2 : -1)) - _r.nextInt(20);
        paidCount = max(0, (-startOffset ~/ 30) - 1 - _r.nextInt(3));
      } else {
        startOffset = -30 * (1 + _r.nextInt(4)) + 10;
        paidCount = max(0, (-startOffset ~/ 30) + 1);
      }
      if (i < 12) paidCount = min(paidCount, months - 1);
      final schedule = <Json>[];
      var paid = down;
      var overdueAmt = 0;
      String? nextDue;
      for (var s = 1; s <= months; s++) {
        final due = i >= 5 && i < 12
            ? _date(-30 * (paidCount - s + 1))
            : _date(startOffset + 30 * s);
        final amount = s == months ? financed - inst * (months - 1) : inst;
        final isPaid = s <= paidCount;
        final dueDiff = daysBetween(today, due);
        if (isPaid) paid += amount;
        final status = isPaid
            ? 'paid'
            : dueDiff < 0
                ? 'overdue'
                : dueDiff == 0
                    ? 'due'
                    : 'upcoming';
        if (status == 'overdue') overdueAmt += amount;
        if (!isPaid && nextDue == null) nextDue = due;
        schedule.add({
          'seq': s,
          'dueDate': due,
          'amountPoisha': amount,
          'paidPoisha': isPaid ? amount : 0,
          'status': status,
          'estimated': false,
        });
      }
      final finalDue = schedule.last['dueDate'] as String;
      final outstanding = total - paid;
      final daysOver = schedule
          .where((l) => l['status'] == 'overdue')
          .map((l) => -daysBetween(today, l['dueDate'] as String))
          .fold<int>(0, max);
      final badSuggested = daysBetween(today, finalDue) < 0 && outstanding > 0;
      final badges = <String>[
        if (i < 5) 'promised_today',
        if (schedule.any((l) => l['status'] == 'due')) 'due_today',
        if (overdueAmt > 0) 'overdue',
        if (badSuggested) 'bad_suggested',
        if (i == 14) 'tagged_bad',
        if (overdueAmt == 0 && outstanding > 0 && !schedule.any((l) => l['status'] == 'due')) 'current',
        if (outstanding <= 0) 'paid_up',
      ];
      final lat = (area[2] as double) + (_r.nextDouble() - 0.5) * 0.018;
      final lng = (area[3] as double) + (_r.nextDouble() - 0.5) * 0.018;
      final hasPin = i != 9 && i != 21;
      final planId = 'P-${2400 + i}';
      final payments = <Json>[
        for (var s = 1; s <= min(paidCount, 4); s++)
          {
            'erpPaymentId': 'ep-$i-$s',
            'date': _date(startOffset + 30 * (paidCount - s + 1) - 2),
            'amountPoisha': inst,
            'method': s.isEven ? 'bkash' : 'cash',
            'source': s.isEven ? 'field' : 'office',
            'receiptNo': 'R-${88000 + i * 10 + s}',
            'reversed': false,
          },
      ];
      out.add({
        'id': id,
        'erpCustomerId': 'erp-${5000 + i}',
        'code': code,
        'name': {'bn': p[0], 'en': p[1]},
        'phone': '017${(10000000 + _r.nextInt(89999999)).toString()}',
        'phones': ['017${(10000000 + _r.nextInt(89999999)).toString()}'],
        'address': '${_r.nextInt(120) + 1}, ${_streets[_r.nextInt(_streets.length)]}, ${area[1]}, বরিশাল',
        'areaId': area[0],
        'areaName': area[1],
        'location': {'lat': hasPin ? lat : null, 'lng': hasPin ? lng : null, 'status': hasPin ? 'ok' : 'missing', 'source': 'erp'},
        'totalOutstandingPoisha': max(0, outstanding),
        'installmentPoisha': inst,
        'overduePoisha': overdueAmt,
        'nextDueDate': nextDue,
        'daysOverdue': daysOver,
        'badges': badges,
        'tag': i == 14
            ? {'state': 'tagged', 'severity': 'bad', 'reasonCode': 'long_overdue', 'reason': '৬ মাস কোনো কিস্তি দেননি', 'setBy': 'ম্যানেজার', 'setAt': '${_date(-12)}T05:00:00Z'}
            : {'state': 'none'},
        'openPromise': i < 5
            ? {
                'id': 'pr-$i',
                'clientId': 'pr-$i',
                'customerId': id,
                'erpPlanId': planId,
                'promisedDate': today,
                'promisedAmountPoisha': (inst ~/ 2) ~/ 10000 * 10000 + 50000,
                'status': 'open',
                'paidTowardsPoisha': 0,
                'createdAt': '${_date(-3)}T06:30:00Z',
              }
            : null,
        'lastVisitAt': i % 4 == 0 ? '${_date(-(i % 9) - 1)}T07:15:00Z' : null,
        'pendingFieldPoisha': 0,
        'assignee': {'id': assigneeId, 'name': assigneeName},
        'erpFetchedAt': '${today}T04:42:00Z',
        'guarantor': {'name': _people[(i + 7) % _people.length][0], 'phone': '018${(10000000 + _r.nextInt(89999999))}'},
        'plans': [
          {
            'erpPlanId': planId,
            'product': prod[0],
            'startDate': _date(startOffset),
            'finalDueDate': finalDue,
            'installmentCount': months,
            'totalPayablePoisha': total,
            'downPaymentPoisha': down,
            'paidPoisha': paid,
            'outstandingPoisha': max(0, outstanding),
            'status': outstanding <= 0 ? 'completed' : 'active',
            'badSuggested': badSuggested,
            'schedule': schedule,
          },
        ],
        'payments': payments,
        'pendingCollections': <Json>[],
        'badSuggestion': badSuggested
            ? {
                'erpPlanId': planId,
                'finalDueDate': finalDue,
                'outstandingPoisha': outstanding,
                'text': {'bn': 'শেষ কিস্তির তারিখ পেরিয়ে গেছে, বকেয়া আছে', 'en': 'Final due date passed with balance outstanding'},
              }
            : null,
        'recentNotes': i % 3 == 0
            ? [
                {
                  'id': 'n-$i',
                  'clientId': 'n-$i',
                  'customerId': id,
                  'author': {'id': assigneeId, 'name': assigneeName},
                  'category': 'general',
                  'text': const [
                    'দোকানে পাওয়া যায় সকাল ১০টার পরে।',
                    'ছেলে বিদেশে থাকে, মাসের ১০ তারিখের পরে টাকা আসে।',
                    'বাড়ির পেছনের গলি দিয়ে যেতে হয়।',
                  ][i % 3 == 0 ? (i ~/ 3) % 3 : 0],
                  'createdAt': '${_date(-(i % 6) - 2)}T08:10:00Z',
                },
              ]
            : <Json>[],
        'lastVisit': null,
        'version': 1,
      });
    }
    return out;
  }
}
