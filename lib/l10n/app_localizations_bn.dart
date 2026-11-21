// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Bengali Bangla (`bn`).
class AppLocalizationsBn extends AppLocalizations {
  AppLocalizationsBn([String locale = 'bn']) : super(locale);

  @override
  String get appName => 'হাওলাদার ইলেকট্রনিক্স';

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
  String get networkOnline => 'অনলাইন';

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
  String get filterPaidThisMonth => 'এ মাসে দিয়েছে';

  @override
  String get filterNotPaidThisMonth => 'এ মাসে দেয়নি';

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
  String get customersReload => 'গ্রাহক আবার লোড করুন';

  @override
  String customersLoadingCount(String count) {
    return 'গ্রাহক লোড হচ্ছে… ($count জন)';
  }

  @override
  String get customersLoading => 'আপনার ব্রাঞ্চের গ্রাহক লোড হচ্ছে…';

  @override
  String get customersLoadingBody =>
      'প্রথমবার এক মিনিট লাগতে পারে। ইন্টারনেট চালু রাখুন।';

  @override
  String get customersNone => 'এই ফোনে এখনও কোনো গ্রাহক নেই';

  @override
  String get customersNoneBody =>
      'ব্রাঞ্চের গ্রাহক আনতে নিচে টানুন বা আবার লোড চাপুন।';

  @override
  String get customersLoadFailed => 'গ্রাহক লোড করা যায়নি';

  @override
  String customersLoadFailedBody(String code) {
    return 'ইন্টারনেট দেখে নিচে টানুন বা আবার লোড চাপুন। কোড: $code';
  }

  @override
  String customersCount(String count) {
    return '$count জন গ্রাহক';
  }

  @override
  String get statusOverdue => 'বকেয়া';

  @override
  String statusOverdueDays(String days) {
    return '$days বকেয়া';
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
    return '$minutes দেরি';
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
  String get attHubTitle => 'উপস্থিতি';

  @override
  String get attHubHistory => 'উপস্থিতির ইতিহাস';

  @override
  String get attHubWorkTime => 'কাজের সময়';

  @override
  String attHubLateWarning(String minutes) {
    return '$minutes দেরি';
  }

  @override
  String get attHubAbsenceStreak =>
      'অনুপস্থিতি হিসেবে গণ্য (প্রতি ২ দিন দেরিতে ১ দিন)';

  @override
  String attHubLateMonth(String late, String absent) {
    return 'এ মাসে দেরি $late দিন · অনুপস্থিতি ধরা হবে $absent দিন';
  }

  @override
  String get attHubNoHistory => 'এখনো কোনো ইতিহাস নেই';

  @override
  String get attHubStatusOnDuty => 'কর্মরত';

  @override
  String get attHubStatusOnBreak => 'বিরতিতে';

  @override
  String get attHubStatusOffDuty => 'কাজ শেষ';

  @override
  String get attHubStatusNotStarted => 'শুরু হয়নি';

  @override
  String attHubOut(String time) {
    return '$time-এ শেষ';
  }

  @override
  String get todayWorkBtn => 'আজকের কাজ';

  @override
  String get performanceBtn => 'পারফরম্যান্স';

  @override
  String get attendanceBtn => 'উপস্থিতি';

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
  String get oemGuideTitle => 'ব্যাটারি ও ব্যাকগ্রাউন্ড সেটিংস';
  @override
  String get oemGuideSubtitle => 'কিছু ফোন স্ক্রিন বন্ধ হলে GPS বন্ধ করে দেয়। ডিউটিতে ট্র্যাকিং চালু রাখতে আপনার ফোন ব্র্যান্ড অনুযায়ী নিচের ধাপগুলো অনুসরণ করুন।';
  @override
  String get oemGuideDone => 'বুঝেছি';
  @override
  String get oemGuideXiaomiName => 'Xiaomi / Redmi / POCO (MIUI)';
  @override
  String get oemGuideXiaomiStep1 => 'সেটিংস → Apps → Manage apps → [এই অ্যাপ] → Battery saver → No restrictions';
  @override
  String get oemGuideXiaomiStep2 => 'সেটিংস → Apps → Manage apps → [এই অ্যাপ] → Autostart → চালু করুন';
  @override
  String get oemGuideXiaomiStep3 => 'সেটিংস → Battery & performance → App battery saver → এই অ্যাপ খুঁজুন → No restrictions';
  @override
  String get oemGuideSamsungName => 'Samsung (One UI)';
  @override
  String get oemGuideSamsungStep1 => 'সেটিংস → Apps → [এই অ্যাপ] → Battery → Unrestricted';
  @override
  String get oemGuideSamsungStep2 => 'সেটিংস → Device care → Battery → App power management → Sleeping apps → এই অ্যাপ সরান';
  @override
  String get oemGuideSamsungStep3 => 'সেটিংস → Apps → [এই অ্যাপ] → Mobile data → Allow background data usage';
  @override
  String get oemGuideOppoName => 'Oppo / Realme (ColorOS)';
  @override
  String get oemGuideOppoStep1 => 'সেটিংস → Battery → App power saving → এই অ্যাপ → বন্ধ করুন';
  @override
  String get oemGuideOppoStep2 => 'সেটিংস → Apps → [এই অ্যাপ] → Battery usage → Allow background activity';
  @override
  String get oemGuideOppoStep3 => 'সেটিংস → Battery → More → App quick freeze → এই অ্যাপ বাদ দিন';
  @override
  String get oemGuideVivoName => 'Vivo (Funtouch OS)';
  @override
  String get oemGuideVivoStep1 => 'সেটিংস → Battery → Background app power management → এই অ্যাপ বন্ধ করুন';
  @override
  String get oemGuideVivoStep2 => 'iManager → App Management → [এই অ্যাপ] → Background run → Allow';
  @override
  String get oemGuideVivoStep3 => 'সেটিংস → Apps → [এই অ্যাপ] → Battery → Unrestricted';
  @override
  String get oemGuideHuaweiName => 'Huawei / Honor (EMUI / MagicUI)';
  @override
  String get oemGuideHuaweiStep1 => 'Phone Manager → Launch manager → এই অ্যাপ খুঁজুন → Manage manually';
  @override
  String get oemGuideHuaweiStep2 => 'Auto-launch, Secondary launch এবং Run in background চালু করুন';
  @override
  String get oemGuideHuaweiStep3 => 'সেটিংস → Battery → App launch → এই অ্যাপ → Manage manually → তিনটিই Allow করুন';
  @override
  String get oemGuideOneplusName => 'OnePlus / Nothing (OxygenOS)';
  @override
  String get oemGuideOneplusStep1 => 'সেটিংস → Apps → [এই অ্যাপ] → Battery → Allow background activity';
  @override
  String get oemGuideOneplusStep2 => 'সেটিংস → Battery → Battery optimization → All apps → [এই অ্যাপ] → Don\'t optimize';
  @override
  String get oemGuideOtherName => 'অন্যান্য Android ফোন';
  @override
  String get oemGuideOtherStep1 => 'সেটিংস → Apps → [এই অ্যাপ] → Battery → Unrestricted বা Don\'t optimize';
  @override
  String get oemGuideOtherStep2 => 'সেটিংস → Battery → Battery optimization → এই অ্যাপ খুঁজুন → Don\'t optimize';

  @override
  String visitSuggestTitle(String name) {
    return '$name-এর কাছে আছেন?';
  }

  @override
  String visitSuggestBody(String minutes) {
    return '$minutes ধরে এখানে আছেন। ভিজিট রেকর্ড করবেন?';
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
      'ম্যাপ সরিয়ে পিনটা কাস্টমারের দরজার উপর আনুন। কোনো জায়গায় চাপ দিলে সেটা পিনের নিচে চলে আসবে।';

  @override
  String get pinOutside => 'এই অবস্থানটা বাংলাদেশের বাইরে।';

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
  String get pinFailed => 'সার্ভার এই লোকেশন নেয়নি। ম্যাপ খুলে আবার পাঠান।';

  @override
  String pinDistanceFromOld(String distance) {
    return 'বর্তমান পিন থেকে $distance';
  }

  @override
  String get pinMapLabel =>
      'ম্যাপ। টেনে সরিয়ে পিনটা কাস্টমারের দরজার উপর আনুন।';

  @override
  String get pinAt => 'পিনের অবস্থান';

  @override
  String pinPhoneDistance(String distance) {
    return 'আপনি পিন থেকে $distance দূরে';
  }

  @override
  String pinPhoneFar(String distance) {
    return 'আপনি পিন থেকে $distance দূরে। ঠিক বাড়ি কিনা দেখে নিন: ম্যানেজার এই দূরত্ব দেখবেন।';
  }

  @override
  String get pinPhoneUnknown => 'আপনার নিজের অবস্থান এখনো জানা যায়নি।';

  @override
  String get pinPhoneMock =>
      'ফোনে নকল লোকেশন দেখাচ্ছে, তাই এই পিন ম্যানেজার দেখে নেবেন।';

  @override
  String get pinWillApply =>
      'এই কাস্টমারের লোকেশন নেই: পাঠানোর সাথে সাথে পিন বসে যাবে।';

  @override
  String get pinNeedsManager => 'নতুন পিন বসার আগে ম্যানেজার দেখে নেবেন।';

  @override
  String get pinPhotoOptional => 'বাড়ি বা দোকানের ছবি (ঐচ্ছিক)';

  @override
  String get pinSubmitApply => 'পিন বসান';

  @override
  String get pinSentApplied => 'সেভ হয়েছে। পাঠানোর সাথে সাথে পিন বসে যাবে।';

  @override
  String get pinApplyWhenSent =>
      'নতুন লোকেশন সেভ হয়েছে · পাঠানোর সাথে সাথে বসবে';

  @override
  String get pinTypeCoords => 'কো-অর্ডিনেট লিখুন বা পেস্ট করুন';

  @override
  String get pinTypeCoordsHelp => 'যেমন 22.70123, 90.37011, বা ম্যাপের লিংক';

  @override
  String get pinTypeCoordsError => 'এই কো-অর্ডিনেট পড়া যায়নি।';

  @override
  String get pinGo => 'যান';

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

  @override
  String get coworkTitle => 'কো-ওয়ার্ক';

  @override
  String coworkInviteFrom(String name) {
    return '$name আজ আপনার সাথে একসাথে কাজ করতে চান';
  }

  @override
  String coworkWith(String names) {
    return 'সাথে: $names';
  }

  @override
  String get coworkActiveTitle => 'আজ একসাথে কাজ';

  @override
  String coworkYou(String name) {
    return '$name (আপনি)';
  }

  @override
  String get coworkWaiting => 'উত্তরের অপেক্ষায়';

  @override
  String get coworkNoPartnerYet =>
      'কেউ রাজি হলে তবেই ভিজিট কো-ওয়ার্ক হিসেবে গণ্য হবে';

  @override
  String coworkVisitsToday(String n) {
    return 'কো-ওয়ার্ক ভিজিট $n';
  }

  @override
  String get coworkAdd => 'আরও ডাকুন';

  @override
  String get coworkLeave => 'গ্রুপ ছাড়ুন';

  @override
  String get coworkLeaveConfirm =>
      'গ্রুপ ছাড়লে এরপরের ভিজিট আপনার একক ভিজিট হিসেবে গণ্য হবে। আগের কো-ওয়ার্ক ভিজিট আগের মতোই থাকবে।';

  @override
  String get coworkStartTitle => 'সহকর্মীর সাথে কাজ করুন';

  @override
  String get coworkStartBody => 'একসাথে দেওয়া ভিজিট সবার হিসাবে যোগ হয়';

  @override
  String get coworkNeedsInternet => 'পাঠাতে ও উত্তর দিতে ইন্টারনেট লাগবে';

  @override
  String get coworkInviteSection => 'কাকে ডাকবেন?';

  @override
  String coworkSeatsLeft(String n) {
    return 'আরও $n জনকে ডাকা যাবে';
  }

  @override
  String get coworkFull => 'গ্রুপ পূর্ণ, আর কাউকে ডাকা যাবে না';

  @override
  String get coworkOnDuty => 'ডিউটিতে আছেন';

  @override
  String get coworkOffDuty => 'ডিউটিতে নেই';

  @override
  String get coworkInOtherGroup => 'অন্য গ্রুপে আছেন';

  @override
  String get coworkInThisGroup => 'এই গ্রুপে আছেন';

  @override
  String get coworkNoteHint => 'যেমন: কোন এলাকায় যাবেন';

  @override
  String coworkSend(String n) {
    return 'অনুরোধ পাঠান ($n)';
  }

  @override
  String get coworkSent => 'অনুরোধ পাঠানো হয়েছে';

  @override
  String get coworkJoined => 'গ্রুপে যোগ দিয়েছেন';

  @override
  String get coworkDeclined => 'অনুরোধ ফিরিয়ে দিয়েছেন';

  @override
  String get coworkLeft => 'গ্রুপ ছেড়েছেন';

  @override
  String get coworkOffline => 'ইন্টারনেট নেই। সংযোগ পেলে আবার চেষ্টা করুন।';

  @override
  String get coworkErrAlreadyIn =>
      'আপনি আজ অন্য একটি গ্রুপে আছেন। আগে সেটি ছাড়ুন।';

  @override
  String get coworkErrEnded => 'এই গ্রুপ আর চালু নেই';

  @override
  String get coworkErrNotInvited => 'এই অনুরোধ আর চালু নেই';

  @override
  String get coworkErrTooMany => 'গ্রুপে সর্বোচ্চ সদস্য হয়ে গেছে';

  @override
  String get coworkErrInvitee => 'এই সহকর্মীকে ডাকা যাবে না';

  @override
  String get coworkNoColleagues => 'আপনার শাখায় ডাকার মতো কেউ নেই';

  @override
  String get coworkVisitToggle => 'কো-ওয়ার্ক ভিজিট';

  @override
  String coworkVisitWith(String names) {
    return '$names-এর সাথে · সবার হিসাবে যোগ হবে';
  }

  @override
  String get coworkVisitSingle => 'বন্ধ: শুধু আপনার একক ভিজিট';

  @override
  String get coworkBadge => 'কো-ওয়ার্ক';

  @override
  String timelineCoworkWith(String names) {
    return 'সাথে $names';
  }

  @override
  String timelineRecordedBy(String name) {
    return 'লিখেছেন $name';
  }

  @override
  String todayVisitsJoint(String n) {
    return 'কো-ওয়ার্ক $n';
  }

  @override
  String get coworkAsked => 'ডাকা হয়েছে';

  @override
  String get todayTargetMet => 'টার্গেট পূরণ';

  @override
  String get todayTargetPersonal => 'আমার টার্গেট';

  @override
  String get todayOffDay => 'আজ ছুটির দিন, টার্গেট নেই';

  @override
  String get todayVisitTarget => 'ভিজিট টার্গেট';

  @override
  String todayVisitTargetOf(String done, String target) {
    return '$done / $target';
  }

  @override
  String get perfTitle => 'আমার পারফরম্যান্স';

  @override
  String get perfMeSubtitle => 'এই মাসের আদায়, ভিজিট, টার্গেট';

  @override
  String get perfPrevMonth => 'আগের মাস';

  @override
  String get perfNextMonth => 'পরের মাস';

  @override
  String perfCachedAt(String time) {
    return 'ইন্টারনেট নেই। $time-এর হিসাব দেখানো হচ্ছে।';
  }

  @override
  String get perfCollected => 'এই মাসে আদায়';

  @override
  String perfTargetToDate(String toDate, String month) {
    return 'আজ পর্যন্ত লক্ষ্য $toDate · পুরো মাসে $month';
  }

  @override
  String get perfPosted => 'ইআরপি-তে জমা';

  @override
  String get perfPendingErp => 'ইআরপি-তে অপেক্ষমাণ';

  @override
  String get perfVisitCredit => 'ভিজিট ক্রেডিট (আজ পর্যন্ত লক্ষ্যের তুলনায়)';

  @override
  String get perfSoloVisits => 'একক ভিজিট';

  @override
  String get perfCoWorkVisits => 'কো-ওয়ার্ক ভিজিট';

  @override
  String get perfPromisesKept => 'প্রতিশ্রুতি রক্ষা';

  @override
  String perfOf(String a, String b) {
    return '$a/$b';
  }

  @override
  String get perfPresentDays => 'উপস্থিত দিন';

  @override
  String get perfLateDays => 'দেরিতে আসা';

  @override
  String perfRank(String rank, String of) {
    return 'শাখায় আপনার অবস্থান $rank / $of';
  }

  @override
  String get perfRankBy => 'আদায়ের হিসাবে · লিডারবোর্ড দেখুন';

  @override
  String get perfDaily => 'দিনভিত্তিক আদায়';

  @override
  String get perfLegendCollected => 'আদায়';

  @override
  String get perfLegendMet => 'লক্ষ্য পূরণ';

  @override
  String get perfLegendTarget => 'লক্ষ্য';

  @override
  String perfDailySemantics(String total) {
    return 'এই মাসে দিনভিত্তিক আদায়ের চার্ট, মোট $total';
  }

  @override
  String get reportOffline => 'ইন্টারনেট লাগবে। সংযোগ পেলে আবার চেষ্টা করুন।';

  @override
  String get leaderboardTitle => 'লিডারবোর্ড';

  @override
  String get leaderboardHidden => 'লিডারবোর্ড এখন বন্ধ';

  @override
  String get leaderboardHiddenBody => 'অফিস চালু করলে এখানে দেখা যাবে';

  @override
  String get leaderToday => 'আজ';

  @override
  String get leaderMonth => 'এই মাস';

  @override
  String get leaderMetricCollected => 'আদায়';

  @override
  String get leaderMetricVisits => 'ভিজিট ক্রেডিট';

  @override
  String get leaderMetricPromises => 'প্রতিশ্রুতি রক্ষা';

  @override
  String get leaderMetricTarget => 'টার্গেট অর্জন';

  @override
  String get leaderNotRanked => 'র‍্যাঙ্কে নেই (উপস্থিতি কম)';

  @override
  String get leaderNotRankedMe =>
      'এই সময়ে আপনার উপস্থিতি কম, তাই র‍্যাঙ্ক নেই';

  @override
  String get leaderFootnote =>
      'আদায় ধরা হয় মাঠে নেওয়া টাকা (ইআরপি-তে জমা ও অপেক্ষমাণ)। কো-ওয়ার্ক ভিজিট সবার ক্রেডিটে যোগ হয়।';

  @override
  String get noticesTitle => 'নোটিশ';

  @override
  String get noticeTitle => 'নোটিশ';

  @override
  String get noticesEmpty => 'কোনো নোটিশ নেই';

  @override
  String get noticesEmptyBody => 'অফিস থেকে নোটিশ এলে এখানে দেখাবে';

  @override
  String get noticeRead => 'পড়েছি';

  @override
  String get noticeMustRead => 'পড়ে নিশ্চিত করুন';

  @override
  String get noticeUnread => 'নতুন';

  @override
  String noticeFrom(String name) {
    return '$name পাঠিয়েছেন';
  }

  @override
  String get noticeMarkRead => 'পড়েছি';

  @override
  String get noticeThanks => 'ধন্যবাদ, অফিস জানতে পারবে';

  @override
  String noticeReadAt(String time) {
    return '$time-এ পড়েছেন';
  }

  @override
  String noticeReadQueued(String time) {
    return '$time-এ পড়েছেন · নেট পেলে অফিসে যাবে';
  }

  @override
  String get noticeReadFailed => 'অফিসে পাঠানো যায়নি। সিঙ্ক কেন্দ্রে দেখুন।';

  @override
  String todayNoticeOne(String title) {
    return 'নতুন নোটিশ: $title';
  }

  @override
  String todayNoticeMany(String n) {
    return '$nটি নোটিশ পড়ে নিশ্চিত করতে হবে';
  }

  @override
  String noticesUnreadCount(String n) {
    return '$nটি নতুন';
  }

  @override
  String get noticesAllRead => 'সব পড়া হয়েছে';

  @override
  String get leaveTitle => 'ছুটি';

  @override
  String get leaveMeSubtitle => 'আবেদন করুন ও অবস্থা দেখুন';

  @override
  String get leaveNew => 'ছুটির আবেদন';

  @override
  String get leaveTypeCasual => 'নৈমিত্তিক';

  @override
  String get leaveTypeSick => 'অসুস্থতা';

  @override
  String get leaveTypeOther => 'অন্যান্য';

  @override
  String get leavePending => 'অপেক্ষমাণ';

  @override
  String get leaveApproved => 'অনুমোদিত';

  @override
  String get leaveRejected => 'অনুমোদিত হয়নি';

  @override
  String get leaveCancelled => 'বাতিল';

  @override
  String get leaveCancelDone => 'আবেদন বাতিল হয়েছে';

  @override
  String leaveDays(String n) {
    return '$n দিন';
  }

  @override
  String leaveTotalDays(String n) {
    return 'মোট $n দিন';
  }

  @override
  String leaveAskedAt(String time) {
    return 'আবেদন $time';
  }

  @override
  String leaveManagerSaid(String reason) {
    return 'ম্যানেজার: $reason';
  }

  @override
  String get leaveCancelAction => 'বাতিল করুন';

  @override
  String get leaveCancelTitle => 'আবেদন বাতিল করবেন?';

  @override
  String leaveCancelBody(String from, String to) {
    return '$from – $to এর আবেদন বাতিল হবে। দরকার হলে নতুন করে আবেদন করতে পারবেন।';
  }

  @override
  String get leaveCancelConfirm => 'হ্যাঁ, বাতিল';

  @override
  String get leaveEmpty => 'কোনো ছুটির আবেদন নেই';

  @override
  String get leaveEmptyBody => 'নিচের বোতাম চেপে আবেদন করুন';

  @override
  String leaveCachedAt(String time) {
    return 'ইন্টারনেট নেই · $time এর তথ্য দেখাচ্ছে';
  }

  @override
  String get leaveNeedsInternet =>
      'ইন্টারনেট লাগবে। সংযোগ পেলে আবার চেষ্টা করুন।';

  @override
  String get leaveType => 'ছুটির ধরন';

  @override
  String get leaveFrom => 'যেদিন থেকে';

  @override
  String get leaveTo => 'যেদিন পর্যন্ত';

  @override
  String get leaveReason => 'কারণ (ঐচ্ছিক)';

  @override
  String get leaveReasonHint => 'যেমন: বোনের বিয়ে';

  @override
  String get leaveOnlineNote =>
      'আবেদন পাঠাতে ইন্টারনেট লাগবে। ম্যানেজার সিদ্ধান্ত দিলে এখানে দেখাবে।';

  @override
  String get leaveSend => 'আবেদন পাঠান';

  @override
  String get leaveSent => 'আবেদন পাঠানো হয়েছে';

  @override
  String get leaveErrToBeforeFrom => 'শেষের তারিখ শুরুর আগে হতে পারে না';

  @override
  String get leaveErrTooLong => 'একবারে সর্বোচ্চ ৩১ দিনের আবেদন করা যায়';

  @override
  String get leaveErrOverlaps => 'এই দিনগুলোর জন্য আগেই একটি আবেদন আছে';

  @override
  String get leaveErrDecided => 'ম্যানেজার আগেই সিদ্ধান্ত দিয়েছেন';

  @override
  String get calendarTitle => 'ছুটির দিন ও শিফট';

  @override
  String get calendarMeSubtitle => 'সরকারি ছুটি, সাপ্তাহিক ছুটি ও ডিউটির সময়';

  @override
  String get calendarMyShift => 'আমার শিফট';

  @override
  String get calendarDefaultShift => 'শাখার সাধারণ শিফট';

  @override
  String calendarShiftHours(String start, String end) {
    return '$start – $end';
  }

  @override
  String calendarWeeklyOff(String days) {
    return 'সাপ্তাহিক ছুটি: $days';
  }

  @override
  String get calendarNoWeeklyOff => 'সাপ্তাহিক ছুটি নেই';

  @override
  String calendarLateGrace(String grace, String brk) {
    return '$grace পর্যন্ত দেরি ধরা হয় না · বিরতি $brk';
  }

  @override
  String get calendarMyLeave => 'আমার অনুমোদিত ছুটি';

  @override
  String get calendarHolidays => 'ছুটির দিন';

  @override
  String get calendarNoHolidays => 'এই বছরের ছুটির দিন দেওয়া হয়নি';

  @override
  String get calendarNoHolidaysBody => 'অফিস যোগ করলে এখানে দেখাবে';

  @override
  String get calendarNational => 'জাতীয়';

  @override
  String get calendarBranch => 'শাখা';

  @override
  String get weekdaySun => 'রবিবার';

  @override
  String get weekdayMon => 'সোমবার';

  @override
  String get weekdayTue => 'মঙ্গলবার';

  @override
  String get weekdayWed => 'বুধবার';

  @override
  String get weekdayThu => 'বৃহস্পতিবার';

  @override
  String get weekdayFri => 'শুক্রবার';

  @override
  String get weekdaySat => 'শনিবার';

  @override
  String timelineGuarantorCall(String outcome) {
    return 'জামিনদারকে কল · $outcome';
  }

  @override
  String get guarantorNoName => 'নাম নেই';

  @override
  String get guarantorCall => 'জামিনদারকে কল করুন';

  @override
  String get guarantorCallShort => 'কল';

  @override
  String get guarantorNoPhone => 'ফোন নম্বর নেই';

  @override
  String get planCreditSale => 'বাকিতে বিক্রি';

  @override
  String planPayBy(String date) {
    return '$date এর মধ্যে পরিশোধ';
  }

  @override
  String get planReturned => 'ইআরপি-তে ফেরত · আদায়যোগ্য নয়';

  @override
  String get planCancelled => 'ইআরপি-তে বাতিল · আদায়যোগ্য নয়';

  @override
  String get planFreqMonthly => 'মাসিক';

  @override
  String get planFreqWeekly => 'সাপ্তাহিক';

  @override
  String get planFreqDaily => 'দৈনিক';

  @override
  String planFreqEveryNDays(String n) {
    return 'প্রতি $n দিনে';
  }

  @override
  String get planFreqCustom => 'নির্দিষ্ট তারিখে';

  @override
  String get planProducts => 'পণ্য';

  @override
  String planSerials(String list) {
    return 'সিরিয়াল: $list';
  }

  @override
  String get planGuarantor => 'এই কিস্তির জামিনদার';

  @override
  String planWrittenOff(String amount) {
    return 'মওকুফ $amount';
  }

  @override
  String scheduleLateFee(String amount) {
    return 'বিলম্ব ফি $amount সহ';
  }

  @override
  String schedulePaidOf(String paid, String left) {
    return 'পরিশোধ $paid · বাকি $left';
  }

  @override
  String get planTotal => 'ইনভয়েস মোট';

  @override
  String get planPaidSoFar => 'মোট পরিশোধ';

  @override
  String get planLeft => 'বকেয়া';

  @override
  String planRemainingInstallments(String n) {
    return '$nটি বাকি';
  }

  @override
  String get phoneErpPrimary => 'ইআরপি';

  @override
  String get phoneAdded => 'যোগকৃত';

  @override
  String get phoneAddNumber => 'নম্বর যোগ করুন';

  @override
  String get phoneAddTitle => 'ফোন নম্বর যোগ করুন';

  @override
  String get phoneAddHint => 'একসাথে কয়েকটি নম্বর দিতে পারেন। ERP-র নম্বর আগের মতোই থাকবে।';

  @override
  String phoneNumberN(String n) {
    return 'নম্বর $n';
  }

  @override
  String get phoneWhose => 'কার নম্বর';

  @override
  String get phoneWhoseHint => 'স্ত্রী, দোকান, ছেলে';

  @override
  String phoneDropRow(String n) {
    return 'নম্বর $n বাদ দিন';
  }

  @override
  String get phoneAnother => 'আরেকটি নম্বর';

  @override
  String get phoneErrInvalid => 'বাংলাদেশের মোবাইল নম্বর দিন (01XXXXXXXXX)';

  @override
  String get phoneErrDuplicate => 'এই নম্বরটি গ্রাহকের আগে থেকেই আছে';

  @override
  String get phoneErrRepeated => 'এই নম্বরটি দুইবার লেখা হয়েছে';

  @override
  String get phoneErrEmpty => 'অন্তত একটি নম্বর লিখুন';

  @override
  String get phoneKeptHere => 'এই নম্বরগুলো ফিল্ড সিস্টেমে থাকে; ERP-তে পাঠানো হয় না।';

  @override
  String get phoneSave => 'নম্বর সংরক্ষণ';

  @override
  String phoneSavedN(String n) {
    return '$nটি নম্বর যোগ হয়েছে';
  }

  @override
  String get phonePending => 'সার্ভারে পাঠানোর অপেক্ষায়';

  @override
  String get receiptView => 'রসিদ';

  @override
  String get receiptOpenCustomer => 'গ্রাহক খুলুন';

  @override
  String get receiptNotOnPhone => 'এই রসিদ এই ফোনে নেই';

  @override
  String get cashInHandOpen => 'কোন আদায়ের টাকা হাতে আছে';

  @override
  String get cashInHandTitle => 'হাতে থাকা নগদের হিসাব';

  @override
  String cashInHandInvoice(String no) {
    return 'ইনভয়েস ${no}';
  }

  @override
  String cashInHandPartOf(String amount) {
    return 'মোট ${amount}-এর বাকি';
  }

  @override
  String cashInHandPendingDeposits(String amount) {
    return '${amount} জমা দেওয়া হয়েছে, যাচাই বাকি';
  }

  @override
  String get cashInHandUnsent => 'এই ফোনের কিছু টাকা এখনো সার্ভারে পৌঁছায়নি; সেগুলো এই তালিকায় নেই।';

  @override
  String get cashInHandEmpty => 'হাতে কোনো নগদ নেই।';

  @override
  String cashInHandMore(String n) {
    return 'আরও ${n}টি পুরনো আদায় তালিকায় নেই; ওপরের মোটে ধরা আছে।';
  }

  @override
  String get cashInHandHow => 'জমা দিলে আপনার সবচেয়ে পুরনো আদায় আগে মেটানো ধরা হয়, তাই হাতে থাকা নগদ মানে আপনার সবচেয়ে নতুন আদায়গুলো। গ্রাহক খুলতে লাইনে চাপ দিন।';

  @override
  String get cashInHandOffline => 'এই তালিকার জন্য ইন্টারনেট লাগবে';

  @override
  String get boardTabCollection => 'আদায় বোর্ড';

  @override
  String get boardTabBranch => 'শাখার র‍্যাঙ্ক';

  @override
  String get boardAllTime => 'সর্বকালের';

  @override
  String boardMyRank(String rank, String of, String amount) {
    return 'আপনি $rank / $of · যাচাই হওয়া আদায় $amount';
  }

  @override
  String get boardNotRankedMe => 'এই সময়ে আপনার কোনো আদায় এখনো যাচাই হয়নি।';

  @override
  String boardCount(String n) {
    return '$nটি আদায়';
  }

  @override
  String get boardRoleManager => 'ম্যানেজার';

  @override
  String get boardRoleAdmin => 'অ্যাডমিন';

  @override
  String get boardRoleOffice => 'অফিস';

  @override
  String get boardNoPosted => 'এখনো কিছু যাচাই হয়নি';

  @override
  String get boardEmpty => 'এই সময়ে কারও যাচাই হওয়া আদায় নেই।';

  @override
  String get boardFootnoteAll => 'শুধু ইআরপি-তে গৃহীত আদায় গোনা হয়; ইআরপি-র অপেক্ষায় থাকা টাকা নয়। সব শাখা এই বোর্ডে আছে।';

  @override
  String get boardFootnoteBranch => 'শুধু ইআরপি-তে গৃহীত আদায় গোনা হয়; ইআরপি-র অপেক্ষায় থাকা টাকা নয়। এই বোর্ডে শুধু আপনার শাখা।';

  @override
  String get boardCrown => 'প্রথম স্থান';

  @override
  String get alertsTitle => 'নোটিফিকেশন';

  @override
  String get alertsEmptyTitle => 'আপনার জন্য কিছু অপেক্ষায় নেই';

  @override
  String get alertsEmptyBody => 'আজকের প্রতিশ্রুতি, নতুন কাজ, যৌথ কাজের অনুরোধ ও অফিসের নোটিশ এখানে দেখা যাবে।';

  @override
  String alertPromiseToday(String amount) {
    return 'আজ $amount দেওয়ার প্রতিশ্রুতি';
  }

  @override
  String alertNewTask(String title) {
    return 'নতুন কাজ: $title';
  }

  @override
  String alertCoworkInvite(String name) {
    return '$name যৌথ কাজের অনুরোধ করেছেন';
  }

  @override
  String get alertNoticeUnread => 'অফিসের নোটিশ, এখনো পড়া হয়নি';

  @override
  String get alertNoticeMustRead => 'অফিসের নোটিশ: পড়ে নিশ্চিত করুন';

  @override
  String get alertHandoverWaiting => 'হ্যান্ডওভার আপনার উত্তরের অপেক্ষায়';

  @override
  String get filterAllBranches => 'সব শাখা';

  @override
  String get farTitle => 'গ্রাহকের পিন থেকে দূরে';

  @override
  String farBody(String distance) {
    return 'আপনি গ্রাহকের পিন থেকে $distance দূরে আছেন। তবুও রেকর্ড করা যাবে; অফিস দূরত্বটি দেখতে পাবে।';
  }

  @override
  String get farConfirm => 'তবুও রেকর্ড করুন';

  @override
  String get attTilePending => 'হাজিরা বাকি';

  @override
  String get attTileDone => 'হাজিরা হয়েছে';

  @override
  String get perfWorkHistory => 'দিন অনুযায়ী কাজের ইতিহাস';

  @override
  String get workPosted => 'ERP-তে পোস্ট';

  @override
  String get workPromises => 'প্রতিশ্রুতি';

  @override
  String get workEmptyTitle => 'এই দিনে কোনো কাজ রেকর্ড নেই';

  @override
  String get workEmptyBody => 'ভিজিট, আদায়, প্রতিশ্রুতি, নোট, পিন, কল ও শেষ করা কাজ এখানে দেখা যাবে।';

  @override
  String get workPrevDay => 'আগের দিন';

  @override
  String get workNextDay => 'পরের দিন';

  @override
  String get workPin => 'ম্যাপ পিন পাঠানো হয়েছে';

  @override
  String workTaskDone(String title) {
    return 'কাজ শেষ জানানো হয়েছে: $title';
  }

  @override
  String get marksVisitToday => 'আজ ভিজিট হয়েছে';

  @override
  String get marksVisitMonth => 'এ মাসে ভিজিট হয়েছে';

  @override
  String get marksVisitNone => 'এ মাসে ভিজিট হয়নি';

  @override
  String get marksPaid => 'এ মাসে ERP-তে টাকা জমা হয়েছে';

  @override
  String get marksPending => 'আদায় হয়েছে, ERP-তে অপেক্ষমাণ';

  @override
  String get marksPaidNone => 'এ মাসে টাকা জমা হয়নি';

  @override
  String get marksPromiseOpen => 'প্রতিশ্রুতি আছে';

  @override
  String get marksPromiseNone => 'প্রতিশ্রুতি নেই';

  @override
  String get marksPinSet => 'ম্যাপে পিন আছে';

  @override
  String get marksPinMissing => 'ম্যাপে পিন নেই';

  @override
  String get monthTitle => 'এ মাসে';

  @override
  String monthLastVisit(String date) {
    return 'সর্বশেষ ভিজিট $date';
  }

  @override
  String monthPaid(String amount) {
    return 'ERP-তে জমা $amount';
  }

  @override
  String monthPending(String amount) {
    return 'ERP-তে অপেক্ষমাণ $amount';
  }

  @override
  String monthPromise(String date) {
    return 'প্রতিশ্রুতি $date';
  }

  @override
  String monthInvoices(String total, String open) {
    return 'ইনভয়েস $totalটি · বাকি আছে $openটি';
  }

  @override
  String planRolledHidden(String n) {
    return 'ইআরপি-তে $nটি অপরিশোধিত কিস্তি পরের কিস্তিতে সরানো হয়েছে, তাই দেখানো হচ্ছে না';
  }

  @override
  String get detailDirections => 'যাওয়ার পথ';

  @override
  String erpRiskBadge(String grade) {
    return 'ইআরপি গ্রেড $grade';
  }

  @override
  String get erpRiskLow => 'কম ঝুঁকি';

  @override
  String get erpRiskMedium => 'মাঝারি ঝুঁকি';

  @override
  String get erpRiskHigh => 'বেশি ঝুঁকি';

  @override
  String timelineCollector(String name) {
    return 'আদায়: $name';
  }

  @override
  String get timelineAdvance => 'অগ্রিম';

  @override
  String get timelineRemoved => 'ইআরপি থেকে মুছে ফেলা';

  @override
  String get collectSameDayWarning =>
      'এই ইনভয়েসে আজ আগেই একটি পেমেন্ট আছে। ইআরপি দিনে একটিই নেয়, তাই অফিসকে সিদ্ধান্ত নিতে হতে পারে।';

  @override
  String get customerAssignedToMe => 'আপনার গ্রাহক';

  @override
  String get customerUnassigned => 'কাউকে বরাদ্দ নেই';

  @override
  String customerAssignedTo(String name) {
    return '$name-এর গ্রাহক';
  }

  @override
  String customerBranch(String branch) {
    return '$branch শাখা';
  }

  @override
  String get tasksTitle => 'আমার কাজ';

  @override
  String get taskTitle => 'কাজ';

  @override
  String get tasksEmpty => 'কোনো কাজ নেই';

  @override
  String get tasksEmptyBody => 'অফিস আপনাকে কাজ দিলে এখানে দেখা যাবে';

  @override
  String get tasksSectionActive => 'করতে হবে';

  @override
  String get tasksSectionWaiting => 'অফিসের যাচাইয়ের অপেক্ষায়';

  @override
  String get tasksSectionClosed => 'শেষ হয়েছে';

  @override
  String get taskStatusOpen => 'করতে হবে';

  @override
  String get taskStatusQueued => 'পাঠানো বাকি';

  @override
  String get taskStatusWaiting => 'অফিস দেখছে';

  @override
  String get taskStatusResolved => 'সম্পন্ন';

  @override
  String get taskStatusCancelled => 'বাতিল';

  @override
  String get taskStatusOverdue => 'সময় পেরিয়েছে';

  @override
  String get taskNew => 'নতুন';

  @override
  String taskDue(String date) {
    return 'শেষ তারিখ $date';
  }

  @override
  String get taskNoDue => 'শেষ তারিখ নেই';

  @override
  String taskFrom(String name) {
    return 'পাঠিয়েছেন $name';
  }

  @override
  String get taskNoteNone => 'কোনো নোট নেই';

  @override
  String get taskMarkDone => 'কাজ হয়েছে';

  @override
  String get taskDoneTitle => 'অফিসকে জানান কাজ হয়েছে';

  @override
  String get taskDoneBody => 'অফিস যাচাই করে তারপর কাজটি সম্পন্ন করবে।';

  @override
  String get taskDoneNoteHint => 'কী করেছেন? (ঐচ্ছিক)';

  @override
  String get taskDoneSend => 'অফিসকে পাঠান';

  @override
  String get taskDoneSent => 'সেভ হয়েছে, অফিস যাচাই করবে';

  @override
  String taskQueuedBanner(String time) {
    return '$time এ ফোনে সেভ হয়েছে। নেটওয়ার্ক পেলে অফিসে যাবে।';
  }

  @override
  String taskWaitingBanner(String time) {
    return '$time এ পাঠানো হয়েছে। অফিস যাচাই করবে।';
  }

  @override
  String taskResolvedBanner(String time) {
    return 'অফিস $time এ সম্পন্ন করেছে';
  }

  @override
  String get taskCancelledBanner => 'অফিস কাজটি বাতিল করেছে';

  @override
  String taskRejectedBanner(String reason) {
    return 'অফিস ফেরত দিয়েছে: $reason';
  }

  @override
  String get taskFailedBanner =>
      'আপনার আগের অনুরোধ নেওয়া হয়নি। আবার পাঠাতে পারেন।';

  @override
  String get taskMyNote => 'আপনার নোট';

  @override
  String get taskOfficeNote => 'অফিসের নোট';

  @override
  String get taskDetails => 'বিবরণ';

  @override
  String get taskHistory => 'ইতিহাস';

  @override
  String get taskEventCreated => 'কাজ দেওয়া হয়েছে';

  @override
  String get taskEventEdited => 'পরিবর্তন করা হয়েছে';

  @override
  String get taskEventResolveRequested => 'কাজ হয়েছে জানানো হয়েছে';

  @override
  String get taskEventVerified => 'অফিস যাচাই করেছে';

  @override
  String get taskEventRejected => 'ফেরত দেওয়া হয়েছে';

  @override
  String get taskEventCancelled => 'বাতিল করা হয়েছে';

  @override
  String todayTasksOverdue(String n) {
    return 'সময় পেরিয়ে যাওয়া কাজ: $nটি';
  }

  @override
  String todayTasksNew(String n) {
    return 'অফিস থেকে নতুন কাজ: $nটি';
  }

  @override
  String todayTasksOpen(String n) {
    return 'করতে হবে এমন কাজ: $nটি';
  }

  @override
  String tasksOpenCount(String n) {
    return '$nটি বাকি';
  }

  @override
  String get tasksNothingOpen => 'কোনো কাজ বাকি নেই';

  @override
  String get exitAppTitle => 'অ্যাপ বন্ধ করবেন?';

  @override
  String get exitAppBody =>
      'যে কাজ এখনো পাঠানো হয়নি তা এই ফোনে নিরাপদে থাকবে।';

  @override
  String get exitAppStay => 'থাকুন';

  @override
  String get exitAppConfirm => 'অ্যাপ বন্ধ করুন';

  @override
  String visitAlreadyToday(String time, String count) {
    return 'এই গ্রাহককে আজ আগেই $count বার ভিজিট করা হয়েছে (শেষ $time)। আবার ভিজিট রাখা যাবে।';
  }

  @override
  String get primerRequired => 'এই অ্যাপ ব্যবহার করতে সব অনুমতি দেওয়া আবশ্যক';

  @override
  String get primerDeniedLocation =>
      'আপনার ম্যানেজার মাঠের কাজ ট্র্যাক করতে লোকেশন দরকার। অনুমতি দিন।';

  @override
  String get primerDeniedCamera =>
      'ভিজিটের ছবি ও সেলফির জন্য ক্যামেরা অনুমতি দরকার। অনুমতি দিন।';

  @override
  String get primerDeniedNotifications =>
      'রিমাইন্ডার ও বার্তার জন্য নোটিফিকেশন অনুমতি দরকার। অনুমতি দিন।';

  @override
  String get primerDeniedBattery =>
      'ট্র্যাকিং চালু রাখতে ব্যাটারি অপটিমাইজেশন বন্ধ করতে হবে। অনুমতি দিন।';

  @override
  String get primerOpenSettings => 'সেটিংস খুলুন';

  @override
  String get primerDeniedForever =>
      'আপনি এই অনুমতি ব্লক করেছেন। ফোনের সেটিংস থেকে অনুমতি দিন।';

  @override
  String get locationGateTitle => 'লোকেশন চালু করুন';

  @override
  String get locationGateBody =>
      'এই অ্যাপ ব্যবহার করতে লোকেশন চালু থাকতে হবে। কাজের সময় আপনার ম্যানেজারের দেখা দরকার আপনি কোথায়।';

  @override
  String get locationGatePermission => 'লোকেশন অনুমতি দিন';

  @override
  String get locationGateService => 'GPS / লোকেশন চালু করুন';

  @override
  String get locationGateOpenSettings => 'লোকেশন সেটিংস খুলুন';

  @override
  String get locationGateRetry => 'আবার দেখুন';

  @override
  String get attendanceNeedsLocation =>
      'হাজিরার জন্য লোকেশন আবশ্যক। GPS চালু করে আবার চেষ্টা করুন।';

  @override
  String get locationGateBackground =>
      'ট্র্যাকিং স্ক্রিন বন্ধ থাকলেও চলতে \"সবসময়\" লোকেশন অনুমতি দিন।';

  @override
  String get locationGateBackgroundSettings => 'অনুমতি সেটিংস খুলুন';

  @override
  String get gpsStatusOn => 'GPS চালু আছে';

  @override
  String get gpsStatusOff => 'GPS বন্ধ আছে';

  @override
  String get gpsStatusMock => 'ভুয়া GPS শনাক্ত হয়েছে!';

  @override
  String get gpsTurnOn => 'GPS চালু করুন';

  @override
  String get gpsMockWarning =>
      'ভুয়া/মক লোকেশন অনুমোদিত নয়। মক লোকেশন বন্ধ করে আবার চেষ্টা করুন।';

  @override
  String get gpsRequiredForAttendance => 'হাজিরা দিতে GPS চালু থাকতে হবে।';

  @override
  String get gpsRequiredForBreak =>
      'বিরতি শুরু বা শেষ করতে GPS চালু থাকতে হবে।';

  @override
  String get gpsRequiredForWorkOut => 'কাজ শেষ করতে GPS চালু থাকতে হবে।';
}
