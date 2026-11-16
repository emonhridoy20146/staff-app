// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Bengali Bangla (`bn`).
class AppLocalizationsBn extends AppLocalizations {
  AppLocalizationsBn([String locale = 'bn']) : super(locale);

  @override
  String get appName => 'হাওলাদার ফিল্ড';

  @override
  String get appTagline => 'মাঠের আদায় ও ভিজিট';

  @override
  String get navToday => 'আজ';

  @override
  String get navCustomers => 'গ্রাহক';

  @override
  String get navMap => 'ম্যাপ';

  @override
  String get navMe => 'আমি';

  @override
  String get actionCollect => 'আদায়';

  @override
  String get actionVisit => 'ভিজিট';

  @override
  String get actionPromise => 'প্রতিশ্রুতি';

  @override
  String get actionNote => 'নোট';

  @override
  String get actionCall => 'কল';

  @override
  String get actionNavigate => 'পথ দেখুন';

  @override
  String get actionDetails => 'বিস্তারিত';

  @override
  String get actionSave => 'সংরক্ষণ';

  @override
  String get actionCancel => 'বাতিল';

  @override
  String get actionContinue => 'এগিয়ে যান';

  @override
  String get actionBack => 'পেছনে';

  @override
  String get actionDone => 'শেষ';

  @override
  String get actionRetry => 'আবার চেষ্টা করুন';

  @override
  String get actionSyncNow => 'এখনই সিঙ্ক করুন';

  @override
  String get actionAccept => 'গ্রহণ';

  @override
  String get actionReject => 'প্রত্যাখ্যান';

  @override
  String get actionUndo => 'পূর্বাবস্থা';

  @override
  String get actionChange => 'পরিবর্তন';

  @override
  String get actionSeeAll => 'সব দেখুন';

  @override
  String get actionShareReceipt => 'রসিদ শেয়ার';

  @override
  String get actionNewPromise => 'নতুন প্রতিশ্রুতি';

  @override
  String get loginTitle => 'লগইন';

  @override
  String get loginSubtitle =>
      'ব্রাঞ্চ ম্যানেজারের দেওয়া ফোন নম্বর ও পাসওয়ার্ড দিন';

  @override
  String get loginPhone => 'ফোন নম্বর';

  @override
  String get loginPassword => 'পাসওয়ার্ড';

  @override
  String get loginButton => 'লগইন করুন';

  @override
  String get loginErrorInvalid => 'ফোন নম্বর বা পাসওয়ার্ড ভুল';

  @override
  String get loginErrorNetwork =>
      'ইন্টারনেট নেই। প্রথমবার লগইনে ইন্টারনেট লাগবে।';

  @override
  String get loginErrorLocked =>
      'অ্যাকাউন্ট বন্ধ। ব্রাঞ্চ ম্যানেজারের সাথে যোগাযোগ করুন।';

  @override
  String get loginDemoHint => 'ডেমো: 01712345678 / demo1234';

  @override
  String get showPassword => 'পাসওয়ার্ড দেখুন';

  @override
  String get hidePassword => 'পাসওয়ার্ড লুকান';

  @override
  String get changePasswordTitle => 'নতুন পাসওয়ার্ড দিন';

  @override
  String get changePasswordBody =>
      'নিরাপত্তার জন্য কাজ শুরুর আগে একটি নতুন পাসওয়ার্ড বেছে নিন।';

  @override
  String get changePasswordCurrent => 'বর্তমান পাসওয়ার্ড';

  @override
  String get changePasswordNew => 'নতুন পাসওয়ার্ড (কমপক্ষে ৮ অক্ষর)';

  @override
  String get changePasswordConfirm => 'নতুন পাসওয়ার্ড আবার দিন';

  @override
  String get changePasswordMismatch => 'দুটি পাসওয়ার্ড মেলেনি';

  @override
  String get changePasswordTooShort => 'কমপক্ষে ৮ অক্ষর দিন';

  @override
  String get changePasswordWrong => 'বর্তমান পাসওয়ার্ড ভুল';

  @override
  String get changePasswordOnline => 'পাসওয়ার্ড বদলাতে ইন্টারনেট লাগবে';

  @override
  String get pinSetupTitle => '৪ সংখ্যার পিন দিন';

  @override
  String get pinSetupBody =>
      'এই পিন দিয়ে দ্রুত অ্যাপ খুলবেন। পিন শুধু এই ফোনেই থাকে।';

  @override
  String get pinConfirmTitle => 'পিন আবার দিন';

  @override
  String get pinMismatch => 'পিন মেলেনি। আবার চেষ্টা করুন।';

  @override
  String get pinWeak => 'খুব সহজ পিন। ১২৩৪ বা ১১১১ দেবেন না।';

  @override
  String get pinUnlockTitle => 'পিন দিন';

  @override
  String pinUnlockGreeting(String name) {
    return 'আবার স্বাগতম, $name';
  }

  @override
  String pinWrong(int left) {
    return 'পিন ভুল। আর $left বার চেষ্টা করা যাবে।';
  }

  @override
  String get pinLockedOut =>
      'অনেকবার ভুল পিন। পাসওয়ার্ড দিয়ে লগইন করুন। আপনার সংরক্ষিত কাজ নিরাপদ আছে।';

  @override
  String get pinForgot => 'পিন ভুলে গেছেন? পাসওয়ার্ড দিয়ে লগইন';

  @override
  String get keypadBackspace => 'মুছুন';

  @override
  String get keypadClear => 'সব মুছুন';

  @override
  String get consentTitle => 'এই অ্যাপ কী রেকর্ড করে';

  @override
  String get consentIntro => 'কাজ শুরুর আগে এটি পড়ে নিন।';

  @override
  String get consentDutyOnly =>
      'লোকেশন শুধু ডিউটির সময় রেকর্ড হয় (কাজ শুরু থেকে কাজ শেষ পর্যন্ত)। ডিউটির বাইরে কখনো না।';

  @override
  String get consentWhy =>
      'এটি ম্যাপে ভিজিট দেখাতে, আদায় নিশ্চিত করতে ও রুট পরিকল্পনায় ব্যবহার হয়।';

  @override
  String get consentVisible =>
      'ট্র্যাকিং চালু থাকলে সবসময় একটি নোটিফিকেশন ও স্ট্যাটাস চিহ্ন দেখবেন।';

  @override
  String get consentPhotos =>
      'ছবি শুধু ক্যামেরা দিয়ে তোলা হয়, তারিখ, সময় ও স্থানসহ।';

  @override
  String get consentRetention => 'লোকেশনের তথ্য ৯০ দিন পরে মুছে ফেলা হয়।';

  @override
  String get consentAgree => 'আমি বুঝেছি ও সম্মত';

  @override
  String consentVersion(String version) {
    return 'গোপনীয়তা নীতি $version';
  }

  @override
  String get primerTitle => 'ফোনে এগুলোর অনুমতি দিন';

  @override
  String get primerBody => 'মাঠে কাজ করতে অ্যাপের কয়েকটি অনুমতি লাগবে।';

  @override
  String get primerLocation => 'লোকেশন';

  @override
  String get primerLocationBody =>
      'আদায় ও ভিজিটে আপনার অবস্থান যুক্ত করতে এবং ডিউটির সময় অবস্থান জানাতে। \"অ্যাপ ব্যবহারের সময়\" অনুমতিই যথেষ্ট: একটি নোটিফিকেশন দেখিয়ে স্ক্রিন বন্ধ থাকলেও ট্র্যাকিং চলে।';

  @override
  String get primerCamera => 'ক্যামেরা';

  @override
  String get primerCameraBody =>
      'ভিজিট ও জমা স্লিপের ছবির জন্য। গ্যালারি কখনো ব্যবহার হয় না।';

  @override
  String get primerNotifications => 'নোটিফিকেশন';

  @override
  String get primerNotificationsBody =>
      'প্রতিশ্রুতির রিমাইন্ডার ও ম্যানেজারের বার্তার জন্য।';

  @override
  String get primerBattery => 'ব্যাটারি অপটিমাইজেশন';

  @override
  String get primerBatteryBody =>
      'কিছু ফোন ব্যাকগ্রাউন্ডে অ্যাপ বন্ধ করে দেয়। ডিউটির সময় অ্যাপ চালু রাখার উপায় দেখিয়ে দেব।';

  @override
  String get primerAllow => 'অনুমতি দিন';

  @override
  String get primerAllowed => 'দেওয়া হয়েছে';

  @override
  String get primerLater => 'পরে';

  @override
  String get bootstrapTitle => 'আপনার গ্রাহকদের তথ্য আনা হচ্ছে';

  @override
  String get bootstrapBody =>
      'অফলাইনে কাজ করার জন্য আপনার গ্রাহকদের তথ্য ডাউনলোড হচ্ছে।';

  @override
  String get bootstrapFailed =>
      'ডাউনলোড হয়নি। ইন্টারনেট দেখে আবার চেষ্টা করুন।';

  @override
  String greetingMorning(String name) {
    return 'শুভ সকাল, $name';
  }

  @override
  String greetingAfternoon(String name) {
    return 'শুভ অপরাহ্ন, $name';
  }

  @override
  String greetingEvening(String name) {
    return 'শুভ সন্ধ্যা, $name';
  }

  @override
  String get syncSynced => 'সিঙ্ক হয়েছে';

  @override
  String get syncSyncing => 'সিঙ্ক হচ্ছে…';

  @override
  String syncQueued(String count) {
    return '$countটি অপেক্ষমাণ';
  }

  @override
  String syncProblems(String count) {
    return '$countটি সমস্যা';
  }

  @override
  String get syncOffline => 'অফলাইন';

  @override
  String get savedOnPhone => 'ফোনে সংরক্ষিত · সিঙ্ক হবে';

  @override
  String get reachedServer => 'সার্ভারে পৌঁছেছে';

  @override
  String get dutyOff => 'ডিউটির বাইরে';

  @override
  String get dutyOn => 'ডিউটিতে';

  @override
  String dutyOnSince(String time) {
    return 'ডিউটিতে · $time থেকে';
  }

  @override
  String get dutyOnBreak => 'বিরতিতে';

  @override
  String dutyBreakSince(String duration) {
    return 'বিরতিতে · $duration';
  }

  @override
  String get dutyTracking => 'ট্র্যাকিং চালু';

  @override
  String get dutyStartWork => 'কাজ শুরু';

  @override
  String get dutyEndWork => 'কাজ শেষ';

  @override
  String get dutyStartBreak => 'বিরতি শুরু';

  @override
  String get dutyEndBreak => 'বিরতি শেষ';

  @override
  String get dutyNotStarted => 'আজ এখনো কাজ শুরু করেননি';

  @override
  String dutyEnded(String time) {
    return '$time-এ কাজ শেষ হয়েছে';
  }

  @override
  String get todayCollected => 'আজকের আদায়';

  @override
  String todayOfTarget(String target) {
    return 'লক্ষ্য $target';
  }

  @override
  String get todayVisits => 'ভিজিট';

  @override
  String get todayCashOnHand => 'হাতে নগদ';

  @override
  String todayProblemsBanner(String count) {
    return '$countটি সমস্যা দেখুন';
  }

  @override
  String todayHandoverBanner(String name) {
    return '$name আপনাকে গ্রাহক হস্তান্তর করছেন';
  }

  @override
  String get todayPromisedSection => 'আজ প্রতিশ্রুতি';

  @override
  String get todayDueSection => 'আজ দেয়';

  @override
  String get todayOverdueSection => 'বকেয়া · কাছের আগে';

  @override
  String get todayAllDone => 'আজকের কাজ শেষ';

  @override
  String get todayAllDoneBody => 'আজকের কোনো প্রতিশ্রুতি বা দেয় বাকি নেই।';

  @override
  String todayCashWarning(String pct) {
    return 'হাতে নগদ সীমার $pct%। শীঘ্রই জমা দিন।';
  }

  @override
  String get customersTitle => 'গ্রাহক';

  @override
  String get customersSearch => 'নাম, ফোন বা কোড দিয়ে খুঁজুন';

  @override
  String get filterAll => 'সব';

  @override
  String get filterDueToday => 'আজ দেয়';

  @override
  String get filterOverdue => 'বকেয়া';

  @override
  String get filterPromisedToday => 'প্রতিশ্রুতি আজ';

  @override
  String get filterMine => 'আমার';

  @override
  String get filterBadSuggested => 'সম্ভাব্য খারাপ';

  @override
  String get filterTagged => 'চিহ্নিত';

  @override
  String get filterNoPin => 'পিন নেই';

  @override
  String get sortBy => 'সাজান';

  @override
  String get sortDistance => 'কাছের আগে';

  @override
  String get sortDaysOverdue => 'বেশি বকেয়া দিন';

  @override
  String get sortAmount => 'বেশি বকেয়া টাকা';

  @override
  String get sortName => 'নাম';

  @override
  String get customersEmpty => 'কোনো গ্রাহক মেলেনি';

  @override
  String get customersEmptyBody => 'অন্য ফিল্টার বা খোঁজ দিয়ে চেষ্টা করুন।';

  @override
  String customersCount(String count) {
    return '$count জন গ্রাহক';
  }

  @override
  String get statusOverdue => 'বকেয়া';

  @override
  String statusOverdueDays(String days) {
    return '$days দিন বকেয়া';
  }

  @override
  String get statusDueToday => 'আজ দেয়';

  @override
  String get statusPromised => 'প্রতিশ্রুতি';

  @override
  String get statusCurrent => 'নিয়মিত';

  @override
  String get statusPaid => 'পরিশোধিত';

  @override
  String get statusBadSuggested => 'সম্ভাব্য খারাপ';

  @override
  String get statusTagged => 'চিহ্নিত';

  @override
  String get statusPending => 'অপেক্ষমাণ';

  @override
  String get statusMock => 'নকল জিপিএস';

  @override
  String get statusQueued => 'ফোনে আছে';

  @override
  String get statusSent => 'ইআরপি-তে অপেক্ষমাণ';

  @override
  String get statusPosted => 'পোস্ট হয়েছে';

  @override
  String get statusConflict => 'ম্যানেজার দেখছেন';

  @override
  String get statusRejected => 'গৃহীত হয়নি';

  @override
  String get statusResolved => 'সমাধান হয়েছে';

  @override
  String get statusVoided => 'বাতিল';

  @override
  String get detailOutstanding => 'মোট বকেয়া';

  @override
  String detailAsOfErp(String time) {
    return 'ইআরপি অনুযায়ী · $time';
  }

  @override
  String detailPendingField(String amount) {
    return 'আপনার $amount ইআরপি-তে অপেক্ষমাণ';
  }

  @override
  String get detailPlans => 'প্ল্যান';

  @override
  String get detailInstallment => 'কিস্তি';

  @override
  String detailInstallments(String paid, String total) {
    return '$totalটির মধ্যে $paidটি পরিশোধ';
  }

  @override
  String detailFinalDue(String date) {
    return 'শেষ কিস্তি $date';
  }

  @override
  String get detailSchedule => 'কিস্তির তালিকা';

  @override
  String get detailTimeline => 'টাইমলাইন';

  @override
  String get detailNotes => 'নোট';

  @override
  String get detailVisits => 'ভিজিট';

  @override
  String get detailPromises => 'প্রতিশ্রুতি';

  @override
  String get detailGuarantor => 'জামিনদার';

  @override
  String get detailNoPin => 'এই গ্রাহকের ম্যাপ পিন নেই';

  @override
  String get detailBadSuggestion => 'সম্ভাব্য খারাপ গ্রাহক';

  @override
  String detailBadSuggestionBody(String date, String amount) {
    return 'শেষ কিস্তির তারিখ $date পেরিয়ে গেছে, বকেয়া $amount। এটি শুধু একটি পরামর্শ।';
  }

  @override
  String detailTaggedBy(String name, String reason) {
    return '$name চিহ্নিত করেছেন: $reason';
  }

  @override
  String detailOpenPromise(String amount, String date) {
    return '$date-এ $amount দেওয়ার প্রতিশ্রুতি';
  }

  @override
  String get detailNothingYet => 'এখনো কিছু নেই';

  @override
  String get scheduleDue => 'দেয়';

  @override
  String get schedulePaid => 'পরিশোধ';

  @override
  String get scheduleOverdue => 'বকেয়া';

  @override
  String get scheduleUpcoming => 'আসন্ন';

  @override
  String get schedulePartial => 'আংশিক';

  @override
  String timelineErpPayment(String amount, String source) {
    return '$source-এ $amount জমা';
  }

  @override
  String get timelineOffice => 'অফিস';

  @override
  String get timelineField => 'মাঠ';

  @override
  String timelineCollection(String amount) {
    return '$amount আদায়';
  }

  @override
  String timelineVisit(String outcome) {
    return 'ভিজিট · $outcome';
  }

  @override
  String timelinePromise(String amount, String date) {
    return '$date-এর জন্য $amount প্রতিশ্রুতি';
  }

  @override
  String get collectTitle => 'কিস্তি আদায়';

  @override
  String get collectStepAmount => 'টাকা';

  @override
  String get collectStepMethod => 'মাধ্যম';

  @override
  String get collectStepReview => 'যাচাই';

  @override
  String collectChipInstallment(String amount) {
    return 'কিস্তি $amount';
  }

  @override
  String collectChipOverdue(String amount) {
    return 'বকেয়া $amount';
  }

  @override
  String collectChipPromise(String amount) {
    return 'প্রতিশ্রুতি $amount';
  }

  @override
  String get collectOverOutstanding =>
      'মোট বকেয়ার চেয়ে বেশি। এটি যাচাইয়ের জন্য চিহ্নিত হবে।';

  @override
  String get collectEnterAmount => 'টাকার পরিমাণ দিন';

  @override
  String get collectMethodCash => 'নগদ';

  @override
  String get collectMethodBkash => 'বিকাশ';

  @override
  String get collectMethodNagad => 'নগদ (Nagad)';

  @override
  String get collectMethodRocket => 'রকেট';

  @override
  String get collectMethodBank => 'ব্যাংক';

  @override
  String get collectMethodOther => 'অন্যান্য';

  @override
  String get collectTxnId => 'ট্রানজেকশন আইডি';

  @override
  String get collectTxnInvalid =>
      'ট্রানজেকশন আইডি দেখুন (অক্ষর ও সংখ্যা, ৮–২০টি)';

  @override
  String get collectPhysicalReceipt => 'কাগজের রসিদ নং (ঐচ্ছিক)';

  @override
  String get collectPayerName => 'যিনি দিলেন (গ্রাহক না হলে)';

  @override
  String get collectNote => 'নোট (ঐচ্ছিক)';

  @override
  String get collectReviewCustomer => 'গ্রাহক';

  @override
  String get collectReviewPlan => 'প্ল্যান';

  @override
  String get collectReviewAmount => 'টাকা';

  @override
  String get collectReviewMethod => 'মাধ্যম';

  @override
  String get collectReviewReceipt => 'রসিদ নং';

  @override
  String collectGpsAccurate(String meters) {
    return 'অবস্থান $meters মি নির্ভুল';
  }

  @override
  String get collectGpsSearching => 'অবস্থান খোঁজা হচ্ছে…';

  @override
  String get collectGpsNone =>
      'অবস্থান পাওয়া যায়নি। সংরক্ষণ হবে, চিহ্নিত থাকবে।';

  @override
  String get collectGpsMock => 'নকল লোকেশন ধরা পড়েছে। এটি চিহ্নিত থাকবে।';

  @override
  String get collectHoldToConfirm => 'নিশ্চিত করতে চেপে ধরুন';

  @override
  String get collectHoldHint => 'ধরে রাখুন…';

  @override
  String get collectSuccessTitle => 'আদায় সংরক্ষিত';

  @override
  String get collectCashLimitBlocked =>
      'হাতে নগদ সীমার বেশি। আরও আদায়ের আগে নগদ জমা দিন।';

  @override
  String get collectNoReceipts => 'রসিদ নম্বর শেষ। একবার ইন্টারনেটে যুক্ত হোন।';

  @override
  String get collectOfflineReceipt =>
      'অফলাইন রসিদ নম্বর ব্যবহার হয়েছে। এটি যাচাই হবে।';

  @override
  String get receiptTitle => 'মাঠ রসিদ';

  @override
  String get receiptPendingErp => 'ইআরপি-তে পোস্টের অপেক্ষায়';

  @override
  String get receiptCollector => 'আদায়কারী';

  @override
  String get receiptHotline => 'হটলাইন';

  @override
  String get visitTitle => 'ভিজিট চেক-ইন';

  @override
  String get visitOutcome => 'কী হলো?';

  @override
  String get visitOutcomePaid => 'পরিশোধ করেছেন';

  @override
  String get visitOutcomePartial => 'আংশিক দিয়েছেন';

  @override
  String get visitOutcomePromised => 'প্রতিশ্রুতি দিয়েছেন';

  @override
  String get visitOutcomeNotHome => 'বাড়িতে নেই';

  @override
  String get visitOutcomeRefused => 'দিতে অস্বীকার';

  @override
  String get visitOutcomeShifted => 'ঠিকানা বদলেছেন';

  @override
  String get visitOutcomeDead => 'গ্রাহক মারা গেছেন';

  @override
  String get visitOutcomeReturn => 'পণ্য ফেরত দিতে চান';

  @override
  String get visitOutcomeOther => 'অন্যান্য';

  @override
  String get visitTakePhoto => 'ছবি তুলুন';

  @override
  String get visitRetake => 'আবার তুলুন';

  @override
  String get visitPhotoAdded => 'ছবি যুক্ত হয়েছে';

  @override
  String get visitCameraOnly => 'শুধু ক্যামেরা। গ্যালারি ব্যবহার করা যাবে না।';

  @override
  String get visitSaved => 'ভিজিট সংরক্ষিত';

  @override
  String visitFar(String distance) {
    return 'আপনি গ্রাহকের পিন থেকে $distance দূরে';
  }

  @override
  String get promiseTitle => 'টাকা দেওয়ার প্রতিশ্রুতি';

  @override
  String get promiseDate => 'তারিখ';

  @override
  String get promiseAmount => 'টাকা';

  @override
  String get promiseToday => 'আজ';

  @override
  String get promiseTomorrow => 'আগামীকাল';

  @override
  String get promiseIn3 => '৩ দিন পর';

  @override
  String get promiseIn7 => '৭ দিন পর';

  @override
  String get promisePickDate => 'তারিখ বাছুন';

  @override
  String get promiseReminder => 'সেদিন সকাল ৯টায় রিমাইন্ডার পাবেন।';

  @override
  String get promiseSaved => 'প্রতিশ্রুতি সংরক্ষিত';

  @override
  String get noteTitle => 'নোট লিখুন';

  @override
  String get noteHint => 'কী হলো লিখুন…';

  @override
  String get noteCategory => 'ধরন';

  @override
  String get noteCatGeneral => 'সাধারণ';

  @override
  String get noteCatAddress => 'ঠিকানা';

  @override
  String get noteCatFamily => 'পরিবার';

  @override
  String get noteCatPayment => 'পেমেন্ট';

  @override
  String get noteSaved => 'নোট সংরক্ষিত';

  @override
  String get tagTitle => 'খারাপ গ্রাহক হিসেবে চিহ্নিত করুন';

  @override
  String get untagTitle => 'চিহ্ন সরান';

  @override
  String get tagReason => 'কারণ';

  @override
  String get tagReasonLongOverdue => 'দীর্ঘদিন বকেয়া';

  @override
  String get tagReasonAbsconded => 'পলাতক';

  @override
  String get tagReasonRefuses => 'দিতে অস্বীকার';

  @override
  String get tagReasonOther => 'অন্যান্য';

  @override
  String get tagReasonHint => 'ব্যাখ্যা লিখুন (কমপক্ষে ১০ অক্ষর)';

  @override
  String get tagSaved => 'চিহ্ন সংরক্ষিত · ম্যানেজার দেখবেন';

  @override
  String get meTitle => 'আমি';

  @override
  String get meAttendance => 'হাজিরা';

  @override
  String get meCash => 'নগদ';

  @override
  String get meHandovers => 'হস্তান্তর';

  @override
  String get meSyncCentre => 'সিঙ্ক সেন্টার';

  @override
  String get meSettings => 'সেটিংস';

  @override
  String get meLogout => 'লগআউট';

  @override
  String meInToday(String time) {
    return '$time-এ শুরু';
  }

  @override
  String meBreakTotal(String duration) {
    return 'বিরতি $duration';
  }

  @override
  String meLate(String minutes) {
    return '$minutes মিনিট দেরি';
  }

  @override
  String get cashOnHand => 'হাতে আছে';

  @override
  String cashLimit(String amount) {
    return 'সীমা $amount';
  }

  @override
  String get cashDeposit => 'জমা রেকর্ড করুন';

  @override
  String get cashDepositTitle => 'নগদ জমা';

  @override
  String get cashDepositTo => 'কোথায় জমা';

  @override
  String get cashDestCashier => 'ব্রাঞ্চ ক্যাশিয়ার';

  @override
  String get cashDestBank => 'ব্যাংক';

  @override
  String get cashDestManager => 'ম্যানেজার';

  @override
  String get cashReference => 'রেফারেন্স / স্লিপ নং';

  @override
  String get cashDepositSaved => 'জমা সংরক্ষিত · যাচাইয়ের অপেক্ষায়';

  @override
  String get cashDeposits => 'জমা';

  @override
  String get cashNoDeposits => 'এখনো কোনো জমা নেই';

  @override
  String get cashTodayCash => 'আজ নগদ';

  @override
  String get cashTodayMobile => 'আজ মোবাইল';

  @override
  String get syncCentreTitle => 'সিঙ্ক সেন্টার';

  @override
  String syncLastSuccess(String time) {
    return 'শেষ সিঙ্ক $time';
  }

  @override
  String get syncNever => 'এখনো সিঙ্ক হয়নি';

  @override
  String syncOldest(String time) {
    return 'সবচেয়ে পুরনো অপেক্ষমাণ: $time';
  }

  @override
  String get syncWaitingTitle => 'আপলোডের অপেক্ষায়';

  @override
  String get syncNothingWaiting => 'সব আপলোড হয়ে গেছে';

  @override
  String get syncProblemsTitle => 'সমস্যা';

  @override
  String get syncNoProblems => 'কোনো সমস্যা নেই';

  @override
  String get syncProblemManager => 'আপনার ম্যানেজারকে জানানো হয়েছে।';

  @override
  String get syncProblemMoneyHint =>
      'টাকার তথ্য কখনো মোছা হয় না। ম্যানেজারের সাথে যোগাযোগ করুন।';

  @override
  String get syncEntityCollection => 'আদায়';

  @override
  String get syncEntityVisit => 'ভিজিট';

  @override
  String get syncEntityNote => 'নোট';

  @override
  String get syncEntityPromise => 'প্রতিশ্রুতি';

  @override
  String get syncEntityDeposit => 'জমা';

  @override
  String get syncEntityAttendance => 'হাজিরা';

  @override
  String get syncEntityTag => 'চিহ্ন';

  @override
  String get syncEntityOther => 'অন্যান্য';

  @override
  String get syncDetails => 'বিস্তারিত';

  @override
  String get settingsTitle => 'সেটিংস';

  @override
  String get settingsLanguage => 'ভাষা';

  @override
  String get settingsDigits => 'সংখ্যা';

  @override
  String get settingsDigitsBn => 'বাংলা ১২৩';

  @override
  String get settingsDigitsEn => 'English 123';

  @override
  String get settingsTheme => 'থিম';

  @override
  String get settingsThemeSystem => 'ফোনের মতো';

  @override
  String get settingsThemeLight => 'আলো';

  @override
  String get settingsThemeDark => 'অন্ধকার';

  @override
  String get settingsHighContrast => 'হাই কনট্রাস্ট (রোদে পড়ার জন্য)';

  @override
  String get settingsPrivacy => 'গোপনীয়তা নীতি';

  @override
  String get settingsAbout => 'অ্যাপ সম্পর্কে';

  @override
  String settingsVersion(String version) {
    return 'সংস্করণ $version';
  }

  @override
  String get logoutTitle => 'লগআউট করবেন?';

  @override
  String logoutBlocked(String count) {
    return '$countটি তথ্য এখনো আপলোড হয়নি। আগে ইন্টারনেটে যুক্ত হয়ে সিঙ্ক করুন। কিছুই মোছা হবে না।';
  }

  @override
  String get logoutConfirm => 'এই ফোনের সব তথ্য মুছে যাবে।';

  @override
  String get handoverTitle => 'হস্তান্তর';

  @override
  String handoverFrom(String name) {
    return '$name-এর কাছ থেকে';
  }

  @override
  String get handoverCustomers => 'গ্রাহক';

  @override
  String get handoverOutstanding => 'বকেয়া';

  @override
  String get handoverOverdue => 'বকেয়াদার';

  @override
  String get handoverOpenPromises => 'চলমান প্রতিশ্রুতি';

  @override
  String handoverExpires(String time) {
    return '$time-এর মধ্যে জানান';
  }

  @override
  String get handoverNeedsInternet => 'গ্রহণ বা প্রত্যাখ্যানে ইন্টারনেট লাগবে';

  @override
  String get handoverAccepted => 'হস্তান্তর গ্রহণ করা হয়েছে';

  @override
  String get handoverRejected => 'হস্তান্তর প্রত্যাখ্যান করা হয়েছে';

  @override
  String get handoverNone => 'কোনো হস্তান্তর নেই';

  @override
  String get workInTitle => 'দিন শুরু করুন';

  @override
  String get workInBody => 'এখন থেকে কাজ শেষ পর্যন্ত আপনার লোকেশন রেকর্ড হবে।';

  @override
  String get workOutTitle => 'দিনের শেষ';

  @override
  String workOutUnsynced(String count) {
    return '$countটি তথ্য এখনো আপলোড হয়নি। ফোনে নিরাপদ আছে, ইন্টারনেট পেলে আপলোড হবে।';
  }

  @override
  String get workOutCollections => 'আদায়';

  @override
  String get workOutCash => 'নগদ';

  @override
  String get workOutMobile => 'মোবাইল';

  @override
  String get workOutVisits => 'ভিজিট';

  @override
  String get workOutPromises => 'নতুন প্রতিশ্রুতি';

  @override
  String get updateTitle => 'আপডেট প্রয়োজন';

  @override
  String get updateBody =>
      'নতুন সংস্করণ লাগবে। আপনার সংরক্ষিত কাজ ফোনেই থাকবে, আপডেটের পরে আপলোড হবে।';

  @override
  String get updateButton => 'আপডেট করুন';

  @override
  String get errorGeneric => 'কিছু একটা ভুল হয়েছে';

  @override
  String get errorNeedsInternet => 'ইন্টারনেট প্রয়োজন';

  @override
  String get offlineSaved => 'ইন্টারনেট নেই — ফোনে সংরক্ষিত';

  @override
  String get demoBanner => 'ডেমো মোড · নমুনা তথ্য';

  @override
  String get required => 'আবশ্যক';

  @override
  String get actionTag => 'ট্যাগ';

  @override
  String get actionUntag => 'ট্যাগ সরান';

  @override
  String get tagSeverity => 'মাত্রা';

  @override
  String get tagSeverityWatch => 'নজরে রাখুন';

  @override
  String get tagSeverityBad => 'খারাপ';

  @override
  String get tagSeverityLegal => 'আইনি ব্যবস্থা';

  @override
  String get tagReasonBrokenPromise => 'বারবার কথা রাখেননি';

  @override
  String get tagReasonFraud => 'প্রতারণার সন্দেহ';

  @override
  String get tagReasonCleared => 'টাকা পরিশোধ করেছেন';

  @override
  String get tagReasonMistake => 'ভুল করে ট্যাগ হয়েছিল';

  @override
  String get tagReasonTooShort => 'কমপক্ষে ১০ অক্ষর লিখুন';

  @override
  String get untagSaved =>
      'ট্যাগ সরানোর অনুরোধ পাঠানো হয়েছে · ম্যানেজার দেখবেন';

  @override
  String get tagPendingReview => 'ম্যানেজারের অনুমোদনের অপেক্ষায়';

  @override
  String get promiseCancel => 'প্রতিশ্রুতি বাতিল';

  @override
  String get promiseCancelled => 'প্রতিশ্রুতি বাতিল হয়েছে';

  @override
  String get promiseNote => 'নোট (ঐচ্ছিক)';

  @override
  String promiseReplaces(String amount, String date) {
    return 'এটি $date তারিখের $amount প্রতিশ্রুতির জায়গা নেবে।';
  }

  @override
  String get promiseStatusOpen => 'চলমান';

  @override
  String get promiseStatusKept => 'কথা রেখেছেন';

  @override
  String get promiseStatusPartial => 'আংশিক রেখেছেন';

  @override
  String get promiseStatusBroken => 'কথা রাখেননি';

  @override
  String get promiseStatusCancelled => 'বাতিল';

  @override
  String get promiseStatusSuperseded => 'পরিবর্তিত';

  @override
  String reminderTitle(String name) {
    return 'আজ প্রতিশ্রুতি: $name';
  }

  @override
  String reminderBody(String amount) {
    return 'আজ $amount দেওয়ার কথা।';
  }

  @override
  String get handoverReasonHint => 'কেন ফেরত দিচ্ছেন? (কমপক্ষে ১০ অক্ষর)';

  @override
  String handoverReason(String reason) {
    return 'কারণ: $reason';
  }

  @override
  String get handoverStatusPending => 'আপনার উত্তরের অপেক্ষায়';

  @override
  String get handoverStatusAccepted => 'গ্রহণ করেছেন';

  @override
  String get handoverStatusRejected => 'ফেরত দিয়েছেন';

  @override
  String get handoverStatusOther => 'বন্ধ';

  @override
  String get handoverOpenConflicts => 'অমীমাংসিত সমস্যা';

  @override
  String syncProblemRejected(String reason) {
    return 'গ্রহণ করা হয়নি: $reason';
  }

  @override
  String syncProblemConflict(String reason) {
    return 'অফিসে যাচাই দরকার: $reason';
  }

  @override
  String syncWaitingSince(String count, String time) {
    return '$countটি · $time থেকে';
  }

  @override
  String get syncMediaTitle => 'ছবি বাকি';

  @override
  String syncMediaCount(String count) {
    return '$countটি ছবি';
  }

  @override
  String get syncRetryAll => 'সমস্যাগুলো আবার চেষ্টা করুন';

  @override
  String get syncBlockedUpgrade => 'সিঙ্ক চালু রাখতে অ্যাপ আপডেট করুন';

  @override
  String get settingsLanguageBn => 'বাংলা';

  @override
  String get settingsLanguageEn => 'English';

  @override
  String settingsDevice(String id) {
    return 'ডিভাইস $id';
  }

  @override
  String meStaffCode(String code) {
    return 'স্টাফ কোড $code';
  }

  @override
  String meBranch(String branch) {
    return '$branch শাখা';
  }

  @override
  String get logoutButton => 'সাইন আউট ও তথ্য মুছুন';

  @override
  String get mapNoPins => 'ম্যাপে কোনো গ্রাহকের পিন নেই';

  @override
  String get mapTilesOffline =>
      'ম্যাপের জন্য ইন্টারনেট দরকার · পিন দেখা যাচ্ছে';

  @override
  String get mapMyLocation => 'আমার অবস্থান';

  @override
  String mapPinsCount(String count) {
    return 'ম্যাপে $count জন';
  }

  @override
  String get mapAttribution => 'ম্যাপ তথ্য © OpenStreetMap';

  @override
  String get todayNotifications => 'নোটিফিকেশন';

  @override
  String get todayProgressTitle => 'আজকের অগ্রগতি';

  @override
  String get todayNoTarget => 'লক্ষ্য ঠিক করা নেই';

  @override
  String get todayCollectFab => 'আদায়';

  @override
  String todayMore(String count) {
    return 'আরও $count জন';
  }

  @override
  String todayReceiptsLow(String count) {
    return 'মাত্র $countটি রসিদ নম্বর বাকি। আরও পেতে ইন্টারনেটে যুক্ত হোন।';
  }

  @override
  String get actionMore => 'আরও';

  @override
  String get callHowWasIt => 'কল কেমন হলো?';

  @override
  String get callConnected => 'কথা হয়েছে';

  @override
  String get callNoAnswer => 'ধরেননি';

  @override
  String get callBusy => 'ব্যস্ত';

  @override
  String get callSwitchedOff => 'ফোন বন্ধ';

  @override
  String get callWrongNumber => 'ভুল নম্বর';

  @override
  String get callUnknown => 'কল করা হয়েছে';

  @override
  String get callSaved => 'কল সংরক্ষিত';

  @override
  String timelineCall(String outcome) {
    return 'কল · $outcome';
  }

  @override
  String get trackingNotificationTitle => 'ডিউটিতে · অবস্থান শেয়ার হচ্ছে';

  @override
  String get trackingNotificationText => 'কাজ শেষ করলে বন্ধ হবে।';

  @override
  String get trackingTitle => 'লোকেশন ট্র্যাকিং';

  @override
  String trackingOn(String provider) {
    return 'চালু · $provider';
  }

  @override
  String get trackingOff => 'বন্ধ (শুধু ডিউটির সময় চলে)';

  @override
  String get trackingProviderFree => 'স্ট্যান্ডার্ড';

  @override
  String get trackingProviderPaid => 'প্রিমিয়াম';

  @override
  String get trackingFallback =>
      'এই অ্যাপ ভার্সনে প্রিমিয়াম ট্র্যাকিং নেই; স্ট্যান্ডার্ড চলছে।';

  @override
  String trackingLastPoint(String time) {
    return 'শেষ অবস্থান $time';
  }

  @override
  String trackingPending(String count) {
    return '$countটি অবস্থান অপেক্ষায়';
  }

  @override
  String visitSuggestTitle(String name) {
    return '$name-এর কাছে আছেন?';
  }

  @override
  String visitSuggestBody(String minutes) {
    return '$minutes মিনিট ধরে এখানে আছেন। ভিজিট রেকর্ড করবেন?';
  }

  @override
  String get visitSuggestNo => 'এখন না';

  @override
  String get visitSuggestYes => 'ভিজিট লিখুন';

  @override
  String get actionSetLocation => 'লোকেশন দিন';

  @override
  String get actionCorrectLocation => 'লোকেশন ঠিক করুন';

  @override
  String get pinIntro =>
      'কাস্টমারের দরজায় দাঁড়ান। ফোনের GPS অবস্থানটাই নতুন পিন হিসেবে যাবে, ম্যানেজার অনুমোদন দেবেন।';

  @override
  String pinAccuracyWeak(String meters, String limit) {
    return 'GPS-এ $meters মিটার গরমিল। $limit মিটার বা কম লাগবে: খোলা জায়গায় দাঁড়িয়ে একটু অপেক্ষা করুন।';
  }

  @override
  String get pinOutside => 'এই অবস্থানটা বাংলাদেশের বাইরে।';

  @override
  String get pinRetry => 'আবার GPS দেখুন';

  @override
  String get pinPhotoNeeded => 'বাড়ি বা দোকানের একটা ছবি তুলুন';

  @override
  String get pinNoteHint => 'চিহ্ন, গেটের রং, তলা…';

  @override
  String get pinSubmit => 'অনুমোদনের জন্য পাঠান';

  @override
  String get pinSent => 'পাঠানো হয়েছে। ম্যানেজার অনুমোদন দিলে পিন বদলাবে।';

  @override
  String get pinPending =>
      'নতুন লোকেশন পাঠানো হয়েছে · ম্যানেজারের অনুমোদনের অপেক্ষায়';

  @override
  String get pinFailed =>
      'সার্ভার এই লোকেশন নেয়নি। ভালো GPS নিয়ে দরজা থেকে আবার চেষ্টা করুন।';

  @override
  String pinDistanceFromOld(String distance) {
    return 'বর্তমান পিন থেকে $distance';
  }

  @override
  String mapNoPinCount(String count) {
    return '$count জনের লোকেশন নেই';
  }

  @override
  String get mapNoPinTitle => 'লোকেশন নেই এমন কাস্টমার';

  @override
  String pinRejected(String reason) {
    return 'লোকেশন অনুমোদন হয়নি: $reason। নতুন করে পাঠাতে চাপুন।';
  }

  @override
  String get attendanceSelfieNeeded =>
      'হাজিরার জন্য আপনার ছবি লাগবে। আবার চাপুন আর ছবি তুলুন।';

  @override
  String get attendanceSelfieHint =>
      'আপনার ছবি তুলতে সামনের ক্যামেরা খুলবে। শুধু ক্যামেরা।';

  @override
  String get mapViewMap => 'ম্যাপ';

  @override
  String get mapViewList => 'লিস্ট';

  @override
  String get mapFilterClear => 'মুছুন';

  @override
  String get mapListEmpty => 'এই ফিল্টারে কোনো কাস্টমার নেই';

  @override
  String get mapListNoFix => 'এখনো GPS পাওয়া যায়নি · পেলে দূরত্ব দেখাবে';
}
