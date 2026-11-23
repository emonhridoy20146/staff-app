// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Howlader Electronics';

  @override
  String get appTagline => 'Field collection & visits';

  @override
  String get navToday => 'Today';

  @override
  String get navCustomers => 'Customers';

  @override
  String get navMap => 'Map';

  @override
  String get navMe => 'Me';

  @override
  String get actionCollect => 'Collect';

  @override
  String get actionVisit => 'Visit';

  @override
  String get actionPromise => 'Promise';

  @override
  String get actionNote => 'Note';

  @override
  String get actionCall => 'Call';

  @override
  String get actionNavigate => 'Navigate';

  @override
  String get actionDetails => 'Details';

  @override
  String get actionSave => 'Save';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionContinue => 'Continue';

  @override
  String get actionBack => 'Back';

  @override
  String get actionDone => 'Done';

  @override
  String get actionRetry => 'Try again';

  @override
  String get actionSyncNow => 'Sync now';

  @override
  String get actionAccept => 'Accept';

  @override
  String get actionReject => 'Reject';

  @override
  String get actionUndo => 'Undo';

  @override
  String get actionChange => 'Change';

  @override
  String get actionSeeAll => 'See all';

  @override
  String get actionReceiptPdf => 'Receipt as PDF (print or save)';

  @override
  String get actionShareReceipt => 'Share receipt';

  @override
  String get actionNewPromise => 'New promise';

  @override
  String get loginTitle => 'Sign in';

  @override
  String get loginSubtitle =>
      'Use the phone number and password from your branch manager';

  @override
  String get loginPhone => 'Phone number';

  @override
  String get loginPassword => 'Password';

  @override
  String get loginButton => 'Sign in';

  @override
  String get loginErrorInvalid => 'Phone number or password is wrong';

  @override
  String get loginErrorNetwork =>
      'No internet. The first sign-in needs internet.';

  @override
  String get loginErrorLocked => 'Account locked. Contact your branch manager.';

  @override
  String get loginDemoHint => 'Demo: 01712345678 / demo1234';

  @override
  String get showPassword => 'Show password';

  @override
  String get hidePassword => 'Hide password';

  @override
  String get changePasswordTitle => 'Set a new password';

  @override
  String get changePasswordBody =>
      'For your security, choose a new password before you start.';

  @override
  String get changePasswordCurrent => 'Current password';

  @override
  String get changePasswordNew => 'New password (at least 8 characters)';

  @override
  String get changePasswordConfirm => 'Confirm new password';

  @override
  String get changePasswordMismatch => 'The two passwords do not match';

  @override
  String get changePasswordTooShort => 'Use at least 8 characters';

  @override
  String get changePasswordWrong => 'Current password is wrong';

  @override
  String get changePasswordOnline => 'Changing the password needs internet';

  @override
  String get pinSetupTitle => 'Set a 4-digit PIN';

  @override
  String get pinSetupBody =>
      'You will use this PIN to open the app quickly. It stays on this phone.';

  @override
  String get pinConfirmTitle => 'Enter the PIN again';

  @override
  String get pinMismatch => 'PINs did not match. Try again.';

  @override
  String get pinWeak => 'Too easy to guess. Avoid 1234 or 1111.';

  @override
  String get pinUnlockTitle => 'Enter your PIN';

  @override
  String get pinChecking => 'Checking your PIN and signing you in…';

  @override
  String pinUnlockGreeting(String name) {
    return 'Welcome back, $name';
  }

  @override
  String pinWrong(int left) {
    return 'Wrong PIN. $left tries left.';
  }

  @override
  String get pinLockedOut =>
      'Too many wrong PINs. Sign in with your password. Your saved work is safe.';

  @override
  String get pinForgot => 'Forgot PIN? Sign in with password';

  @override
  String get keypadBackspace => 'Delete';

  @override
  String get keypadClear => 'Clear';

  @override
  String get consentTitle => 'What this app records';

  @override
  String get consentIntro => 'Please read this before you start work.';

  @override
  String get consentDutyOnly =>
      'Location is recorded only while you are on duty (from work-in to work-out). Never outside duty hours.';

  @override
  String get consentWhy =>
      'It is used to show visits on the map, confirm collections and plan routes.';

  @override
  String get consentVisible =>
      'When tracking is on you will always see a notification and a status chip.';

  @override
  String get consentPhotos =>
      'Photos are taken only with the camera, with date, time and place.';

  @override
  String get consentRetention => 'Location points are deleted after 90 days.';

  @override
  String get consentAgree => 'I understand and agree';

  @override
  String consentVersion(String version) {
    return 'Privacy notice $version';
  }

  @override
  String get primerTitle => 'Allow these on your phone';

  @override
  String get primerBody =>
      'The app needs a few permissions to work in the field.';

  @override
  String get primerLocation => 'Location';

  @override
  String get primerLocationBody =>
      'To attach your position to collections and visits, and to share it while you are on duty. \"While using the app\" is enough: a visible notification keeps tracking on with the screen off.';

  @override
  String get primerCamera => 'Camera';

  @override
  String get primerCameraBody =>
      'For visit and deposit-slip photos. The gallery is never used.';

  @override
  String get primerNotifications => 'Notifications';

  @override
  String get primerNotificationsBody =>
      'For promise reminders and messages from your manager.';

  @override
  String get primerBattery => 'Battery optimisation';

  @override
  String get primerBatteryBody =>
      'Some phones stop apps in the background. We will show you how to keep this app running during duty.';

  @override
  String get primerAllow => 'Allow';

  @override
  String get primerAllowed => 'Allowed';

  @override
  String get primerLater => 'Later';

  @override
  String get bootstrapTitle => 'Getting your customers';

  @override
  String get bootstrapBody =>
      'Downloading your assigned customers so you can work offline.';

  @override
  String get bootstrapFailed =>
      'Could not download. Check internet and try again.';

  @override
  String greetingMorning(String name) {
    return 'Good morning, $name';
  }

  @override
  String greetingAfternoon(String name) {
    return 'Good afternoon, $name';
  }

  @override
  String greetingEvening(String name) {
    return 'Good evening, $name';
  }

  @override
  String get syncSynced => 'Synced';

  @override
  String get syncSyncing => 'Syncing…';

  @override
  String syncQueued(String count) {
    return '$count waiting';
  }

  @override
  String syncProblems(String count) {
    return '$count problems';
  }

  @override
  String get syncOffline => 'Offline';

  @override
  String get networkOnline => 'Online';

  @override
  String get savedOnPhone => 'Saved on phone · will sync';

  @override
  String get reachedServer => 'Reached the server';

  @override
  String get dutyOff => 'Off duty';

  @override
  String get dutyOn => 'On duty';

  @override
  String dutyOnSince(String time) {
    return 'On duty · since $time';
  }

  @override
  String get dutyOnBreak => 'On break';

  @override
  String dutyBreakSince(String duration) {
    return 'On break · $duration';
  }

  @override
  String get dutyTracking => 'Tracking on';

  @override
  String get dutyStartWork => 'Start work';

  @override
  String get dutyEndWork => 'End work';

  @override
  String get dutyStartBreak => 'Start break';

  @override
  String get dutyEndBreak => 'End break';

  @override
  String get dutyDetails => 'Today\'s duty details';

  @override
  String get expandShow => 'Details';

  @override
  String get expandHide => 'Hide';

  @override
  String get todayCollectedDetails => 'Today\'s collection details';

  @override
  String get dutyRowShift => 'Office time';

  @override
  String get dutyRowIn => 'Attendance';

  @override
  String get dutyRowBreak => 'Break';

  @override
  String get dutyRowOut => 'Work end';

  @override
  String get dutyRowOvertime => 'Overtime';

  @override
  String get dutyOnTime => 'On time';

  @override
  String get dutyNotYet => 'Not yet';

  @override
  String dutyBreakOf(String taken, String limit) {
    return '$taken of $limit';
  }

  @override
  String get dutyOfficeOver => 'Office time is over. You can end work now.';

  @override
  String get dutyEndBreakFirst =>
      'End your break first, then you can end work.';

  @override
  String get dutyNotStarted => 'You have not started work today';

  @override
  String dutyEnded(String time) {
    return 'Work ended at $time';
  }

  @override
  String get todayCollected => 'Collected today';

  @override
  String todayOfTarget(String target) {
    return 'of $target';
  }

  @override
  String get todayVisits => 'Visits';

  @override
  String get todayCashOnHand => 'Cash on hand';

  @override
  String todayProblemsBanner(String count) {
    return '$count problems need your attention';
  }

  @override
  String todayHandoverBanner(String name) {
    return '$name is handing customers to you';
  }

  @override
  String get todayPromisedSection => 'Promised today';

  @override
  String get todayDueSection => 'Due today';

  @override
  String get todayOverdueSection => 'Overdue · nearest first';

  @override
  String get todayAllDone => 'All caught up';

  @override
  String get todayAllDoneBody => 'No promises or dues left for today.';

  @override
  String todayCashWarning(String pct) {
    return 'Cash on hand is $pct% of your limit. Please deposit soon.';
  }

  @override
  String get customersTitle => 'Customers';

  @override
  String get customersSearch => 'Search name, phone or code';

  @override
  String get filterAll => 'All';

  @override
  String get filterDueToday => 'Due today';

  @override
  String get filterOverdue => 'Overdue';

  @override
  String get filterPromisedToday => 'Promised today';

  @override
  String get filterMine => 'Mine';

  @override
  String get filterBadSuggested => 'Possibly bad';

  @override
  String get filterTagged => 'Tagged';

  @override
  String get filterNoPin => 'No pin';

  @override
  String get filterPaidThisMonth => 'Paid this month';

  @override
  String get filterNotPaidThisMonth => 'Not paid this month';

  @override
  String get sortBy => 'Sort';

  @override
  String get sortDistance => 'Nearest';

  @override
  String get sortDaysOverdue => 'Most overdue';

  @override
  String get sortAmount => 'Highest balance';

  @override
  String get sortName => 'Name';

  @override
  String get customersEmpty => 'No customers match';

  @override
  String get customersEmptyBody => 'Try another filter or search.';

  @override
  String get customersReload => 'Reload customers';

  @override
  String customersLoadingCount(String count) {
    return 'Loading customers… ($count so far)';
  }

  @override
  String get customersLoading => 'Loading your branch\'s customers…';

  @override
  String get customersLoadingBody =>
      'The first load can take a minute. Keep the internet on.';

  @override
  String get customersNone => 'No customers on this phone yet';

  @override
  String get customersNoneBody =>
      'Pull down or tap Reload to load your branch\'s customers.';

  @override
  String get customersLoadFailed => 'Couldn\'t load customers';

  @override
  String customersLoadFailedBody(String code) {
    return 'Check the internet, then pull down or tap Reload. Code: $code';
  }

  @override
  String customersCount(String count) {
    return '$count customers';
  }

  @override
  String get statusOverdue => 'Overdue';

  @override
  String statusOverdueDays(String days) {
    return '$days overdue';
  }

  @override
  String get statusDueToday => 'Due today';

  @override
  String get statusPromised => 'Promised';

  @override
  String get statusCurrent => 'Current';

  @override
  String get statusPaid => 'Paid up';

  @override
  String get statusBadSuggested => 'Possibly bad';

  @override
  String get statusTagged => 'Tagged';

  @override
  String get statusPending => 'Pending';

  @override
  String get statusMock => 'Fake GPS';

  @override
  String get statusQueued => 'On phone';

  @override
  String get statusSent => 'Waiting for ERP';

  @override
  String get statusPosted => 'Posted';

  @override
  String get statusConflict => 'Manager is reviewing';

  @override
  String get statusRejected => 'Not accepted';

  @override
  String get statusDeleted => 'Deleted by office';

  @override
  String get statusResolved => 'Resolved';

  @override
  String get statusVoided => 'Voided';

  @override
  String get statusVoidedByOffice => 'Voided by office';

  @override
  String get statusDeletedByYou => 'Deleted by you';

  @override
  String collectionVoidedBy(String name) {
    return 'by $name';
  }

  @override
  String get detailOutstanding => 'Total outstanding';

  @override
  String detailAsOfErp(String time) {
    return 'As per ERP · $time';
  }

  @override
  String detailPendingField(String amount) {
    return 'Your $amount is waiting to post in ERP';
  }

  @override
  String get detailPlans => 'Plans';

  @override
  String get detailInstallment => 'Installment';

  @override
  String detailInstallments(String paid, String total) {
    return '$paid of $total paid';
  }

  @override
  String detailFinalDue(String date) {
    return 'Final due $date';
  }

  @override
  String get detailSchedule => 'Schedule';

  @override
  String get detailTimeline => 'Timeline';

  @override
  String get detailNotes => 'Notes';

  @override
  String get detailVisits => 'Visits';

  @override
  String get detailPromises => 'Promises';

  @override
  String get detailGuarantor => 'Guarantor';

  @override
  String get detailNoPin => 'No map pin for this customer';

  @override
  String get detailBadSuggestion => 'Possibly bad customer';

  @override
  String detailBadSuggestionBody(String date, String amount) {
    return 'Final due date passed on $date with $amount outstanding. This is only a suggestion.';
  }

  @override
  String detailTaggedBy(String name, String reason) {
    return 'Tagged by $name: $reason';
  }

  @override
  String detailOpenPromise(String amount, String date) {
    return 'Promised $amount on $date';
  }

  @override
  String get detailNothingYet => 'Nothing here yet';

  @override
  String get scheduleDue => 'Due';

  @override
  String get schedulePaid => 'Paid';

  @override
  String get scheduleOverdue => 'Overdue';

  @override
  String get scheduleUpcoming => 'Upcoming';

  @override
  String get schedulePartial => 'Partly paid';

  @override
  String timelineErpPayment(String amount, String source) {
    return 'Paid $amount at $source';
  }

  @override
  String get timelineOffice => 'office';

  @override
  String get timelineField => 'field';

  @override
  String timelineCollection(String amount) {
    return 'Collected $amount';
  }

  @override
  String timelineVisit(String outcome) {
    return 'Visit · $outcome';
  }

  @override
  String timelinePromise(String amount, String date) {
    return 'Promise $amount for $date';
  }

  @override
  String get collectTitle => 'Collect payment';

  @override
  String get collectStepAmount => 'Amount';

  @override
  String get collectStepMethod => 'Method';

  @override
  String get collectStepReview => 'Review';

  @override
  String collectChipInstallment(String amount) {
    return 'Installment $amount';
  }

  @override
  String collectChipOverdue(String amount) {
    return 'Overdue $amount';
  }

  @override
  String collectChipPromise(String amount) {
    return 'Promise $amount';
  }

  @override
  String get collectOverOutstanding =>
      'More than the outstanding balance. It will be flagged for review.';

  @override
  String get collectEnterAmount => 'Enter amount';

  @override
  String get collectMethodCash => 'Cash';

  @override
  String get collectMethodBkash => 'bKash';

  @override
  String get collectMethodNagad => 'Nagad';

  @override
  String get collectMethodRocket => 'Rocket';

  @override
  String get collectMethodBank => 'Bank';

  @override
  String get collectMethodOther => 'Other';

  @override
  String get collectTxnId => 'Transaction ID';

  @override
  String get collectTxnInvalid =>
      'Check the transaction ID (letters and numbers, 8–20)';

  @override
  String get collectPhysicalReceipt => 'Paper receipt no. (optional)';

  @override
  String get collectPayerName => 'Paid by (if not the customer)';

  @override
  String get collectNote => 'Note (optional)';

  @override
  String get collectReviewCustomer => 'Customer';

  @override
  String get collectReviewPlan => 'Plan';

  @override
  String get collectReviewAmount => 'Amount';

  @override
  String get collectReviewMethod => 'Method';

  @override
  String get collectReviewReceipt => 'Receipt no.';

  @override
  String collectGpsAccurate(String meters) {
    return 'Location $meters m accurate';
  }

  @override
  String get collectGpsSearching => 'Finding location…';

  @override
  String get collectGpsNone => 'No location. It will be saved and flagged.';

  @override
  String get collectGpsMock => 'Fake location detected. It will be flagged.';

  @override
  String get collectHoldToConfirm => 'Hold to confirm';

  @override
  String get collectHoldHint => 'Keep holding…';

  @override
  String get collectSuccessTitle => 'Collection saved';

  @override
  String get collectCashLimitBlocked =>
      'Cash on hand is over your limit. Deposit cash before collecting more.';

  @override
  String get collectNoReceipts =>
      'No receipt numbers left. Connect to the internet once.';

  @override
  String get collectOfflineReceipt =>
      'Offline receipt number used. It will be reviewed.';

  @override
  String get receiptTitle => 'Field receipt';

  @override
  String get receiptPendingErp => 'Waiting to post in ERP';

  @override
  String get receiptCollector => 'Collected by';

  @override
  String get receiptHotline => 'Hotline';

  @override
  String get visitTitle => 'Visit check-in';

  @override
  String get visitOutcome => 'What happened?';

  @override
  String get visitOutcomePaid => 'Paid';

  @override
  String get visitOutcomePartial => 'Paid part';

  @override
  String get visitOutcomePromised => 'Promised';

  @override
  String get visitOutcomeNotHome => 'Not at home';

  @override
  String get visitOutcomeRefused => 'Refused';

  @override
  String get visitOutcomeShifted => 'Moved address';

  @override
  String get visitOutcomeDead => 'Customer died';

  @override
  String get visitOutcomeRunaway => 'Runaway';

  @override
  String get visitOutcomeReturn => 'Wants to return product';

  @override
  String get visitOutcomeOther => 'Other';

  @override
  String get visitTakePhoto => 'Take photo';

  @override
  String get visitRetake => 'Retake';

  @override
  String get visitPhotoAdded => 'Photo added';

  @override
  String get visitCameraOnly => 'Camera only. The gallery cannot be used.';

  @override
  String get visitSaved => 'Visit saved';

  @override
  String visitFar(String distance) {
    return 'You are $distance from the customer pin';
  }

  @override
  String get promiseTitle => 'Promise to pay';

  @override
  String get promiseDate => 'Date';

  @override
  String get promiseAmount => 'Amount';

  @override
  String get promiseToday => 'Today';

  @override
  String get promiseTomorrow => 'Tomorrow';

  @override
  String get promiseIn3 => 'In 3 days';

  @override
  String get promiseIn7 => 'In 7 days';

  @override
  String get promisePickDate => 'Pick date';

  @override
  String get promiseReminder => 'You will get a reminder at 9:00 AM that day.';

  @override
  String get promiseSaved => 'Promise saved';

  @override
  String get noteTitle => 'Add note';

  @override
  String get noteHint => 'Write what happened…';

  @override
  String get noteCategory => 'Type';

  @override
  String get noteCatGeneral => 'General';

  @override
  String get noteCatAddress => 'Address';

  @override
  String get noteCatFamily => 'Family';

  @override
  String get noteCatPayment => 'Payment';

  @override
  String get noteSaved => 'Note saved';

  @override
  String get tagTitle => 'Tag as bad customer';

  @override
  String get untagTitle => 'Remove tag';

  @override
  String get tagReason => 'Reason';

  @override
  String get tagReasonLongOverdue => 'Long overdue';

  @override
  String get tagReasonAbsconded => 'Absconded';

  @override
  String get tagReasonRefuses => 'Refuses to pay';

  @override
  String get tagReasonOther => 'Other';

  @override
  String get tagReasonHint => 'Explain (at least 10 characters)';

  @override
  String get tagSaved => 'Tag saved · manager will review';

  @override
  String get meTitle => 'Me';

  @override
  String get meAttendance => 'Attendance';

  @override
  String get meCash => 'Cash';

  @override
  String get meHandovers => 'Handovers';

  @override
  String get meSyncCentre => 'Sync centre';

  @override
  String get meSettings => 'Settings';

  @override
  String get meLogout => 'Sign out';

  @override
  String meInToday(String time) {
    return 'In $time';
  }

  @override
  String meBreakTotal(String duration) {
    return 'Break $duration';
  }

  @override
  String meLate(String minutes) {
    return 'Late $minutes';
  }

  @override
  String get cashOnHand => 'On hand';

  @override
  String cashLimit(String amount) {
    return 'Limit $amount';
  }

  @override
  String get cashDeposit => 'Deposit everything';

  @override
  String get cashDepositTitle => 'Deposit everything in hand';

  @override
  String get cashDepositTo => 'Deposited to';

  @override
  String get cashDestCashier => 'Branch cashier';

  @override
  String get cashDestBank => 'Bank';

  @override
  String get cashDestManager => 'Manager';

  @override
  String get cashReference => 'Reference / slip no.';

  @override
  String get cashDepositSaved => 'Deposited · it goes to the ERP';

  @override
  String get cashDeposits => 'Deposits';

  @override
  String get cashNoDeposits => 'No deposits yet';

  @override
  String get cashTodayCash => 'Cash today';

  @override
  String get cashTodayMobile => 'Mobile today';

  @override
  String get syncCentreTitle => 'Sync centre';

  @override
  String syncLastSuccess(String time) {
    return 'Last synced $time';
  }

  @override
  String get syncNever => 'Not synced yet';

  @override
  String syncOldest(String time) {
    return 'Oldest waiting item: $time';
  }

  @override
  String get syncWaitingTitle => 'Waiting to upload';

  @override
  String get syncNothingWaiting => 'Everything is uploaded';

  @override
  String get syncProblemsTitle => 'Problems';

  @override
  String get syncNoProblems => 'No problems';

  @override
  String get syncProblemManager => 'Your manager has been notified.';

  @override
  String get syncProblemMoneyHint =>
      'Money items are never deleted. Contact your manager.';

  @override
  String get syncEntityCollection => 'Collections';

  @override
  String get syncEntityVisit => 'Visits';

  @override
  String get syncEntityNote => 'Notes';

  @override
  String get syncEntityPromise => 'Promises';

  @override
  String get syncEntityDeposit => 'Deposits';

  @override
  String get syncEntityAttendance => 'Attendance';

  @override
  String get syncEntityTag => 'Tags';

  @override
  String get syncEntityOther => 'Other';

  @override
  String get syncDetails => 'Details';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsDigits => 'Numbers';

  @override
  String get settingsDigitsBn => 'বাংলা ১২৩';

  @override
  String get settingsDigitsEn => 'English 123';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get settingsThemeSystem => 'System';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsHighContrast => 'High contrast (for sunlight)';

  @override
  String get settingsPrivacy => 'Privacy notice';

  @override
  String get settingsAbout => 'About';

  @override
  String settingsVersion(String version) {
    return 'Version $version';
  }

  @override
  String get logoutTitle => 'Sign out?';

  @override
  String logoutBlocked(String count) {
    return '$count items are not uploaded yet. Connect to the internet and sync first. Nothing will be deleted.';
  }

  @override
  String get logoutConfirm => 'All data on this phone will be removed.';

  @override
  String get handoverTitle => 'Handover';

  @override
  String handoverFrom(String name) {
    return 'From $name';
  }

  @override
  String get handoverCustomers => 'Customers';

  @override
  String get handoverOutstanding => 'Outstanding';

  @override
  String get handoverOverdue => 'Overdue';

  @override
  String get handoverOpenPromises => 'Open promises';

  @override
  String handoverExpires(String time) {
    return 'Respond by $time';
  }

  @override
  String get handoverNeedsInternet => 'Internet is needed to accept or reject';

  @override
  String get handoverAccepted => 'Handover accepted';

  @override
  String get handoverRejected => 'Handover rejected';

  @override
  String get handoverNone => 'No handovers';

  @override
  String get workInTitle => 'Start your day';

  @override
  String get workInBody =>
      'Your location is recorded from now until you end work.';

  @override
  String get workOutTitle => 'End of day';

  @override
  String workOutUnsynced(String count) {
    return '$count items not uploaded yet. They are safe on your phone and will upload when online.';
  }

  @override
  String get workOutCollections => 'Collections';

  @override
  String get workOutCash => 'Cash';

  @override
  String get workOutMobile => 'Mobile';

  @override
  String get workOutVisits => 'Visits';

  @override
  String get workOutPromises => 'Promises made';

  @override
  String get attHubTitle => 'Attendance';

  @override
  String get attHubHistory => 'Attendance history';

  @override
  String get attHubWorkTime => 'Work time';

  @override
  String attHubLateWarning(String minutes) {
    return 'Late by $minutes';
  }

  @override
  String attHubOverBreak(String minutes) {
    return 'Break over by $minutes';
  }

  @override
  String attHubOvertime(String minutes) {
    return 'Overtime $minutes';
  }

  @override
  String attHubOffDayWork(String minutes) {
    return 'Worked on a day off: $minutes';
  }

  @override
  String get attHubAbsenceStreak =>
      'Counts as an absent day (every 2 late days = 1)';

  @override
  String attHubLateMonth(String late, String absent) {
    return 'Late on $late days this month · counted as $absent absent';
  }

  @override
  String get attHubNoHistory => 'No attendance history yet';

  @override
  String get attHubStatusOnDuty => 'On duty';

  @override
  String get attHubStatusOnBreak => 'On break';

  @override
  String get attHubStatusOffDuty => 'Clocked out';

  @override
  String get attHubStatusNotStarted => 'Not started';

  @override
  String attHubOut(String time) {
    return 'Out at $time';
  }

  @override
  String get todayWorkBtn => 'Today\'s work';

  @override
  String get performanceBtn => 'Performance';

  @override
  String get attendanceBtn => 'Attendance';

  @override
  String get updateTitle => 'Update required';

  @override
  String get updateBody =>
      'A newer version is needed. Your saved work stays on the phone and will upload after the update.';

  @override
  String get updateButton => 'Update';

  @override
  String get errorGeneric => 'Something went wrong';

  @override
  String get errorNeedsInternet => 'Internet required';

  @override
  String get offlineSaved => 'No internet — saved on phone';

  @override
  String get demoBanner => 'Demo mode · sample data';

  @override
  String get required => 'Required';

  @override
  String get actionTag => 'Tag';

  @override
  String get actionUntag => 'Remove tag';

  @override
  String get tagSeverity => 'Level';

  @override
  String get tagSeverityWatch => 'Watch';

  @override
  String get tagSeverityBad => 'Bad';

  @override
  String get tagSeverityLegal => 'Legal action';

  @override
  String get tagReasonBrokenPromise => 'Broke promises again and again';

  @override
  String get tagReasonFraud => 'Fraud suspected';

  @override
  String get tagReasonCleared => 'Has paid up';

  @override
  String get tagReasonMistake => 'Tagged by mistake';

  @override
  String get tagReasonTooShort => 'Write at least 10 characters';

  @override
  String get untagSaved => 'Tag removal sent · manager will review';

  @override
  String get tagPendingReview => 'Waiting for manager review';

  @override
  String get promiseCancel => 'Cancel promise';

  @override
  String get promiseCancelled => 'Promise cancelled';

  @override
  String get promiseNote => 'Note (optional)';

  @override
  String promiseReplaces(String amount, String date) {
    return 'This replaces the current promise of $amount on $date.';
  }

  @override
  String get promiseStatusOpen => 'Open';

  @override
  String get promiseStatusKept => 'Kept';

  @override
  String get promiseStatusPartial => 'Partly kept';

  @override
  String get promiseStatusBroken => 'Broken';

  @override
  String get promiseStatusCancelled => 'Cancelled';

  @override
  String get promiseStatusSuperseded => 'Replaced';

  @override
  String reminderTitle(String name) {
    return 'Promise today: $name';
  }

  @override
  String reminderBody(String amount) {
    return '$amount promised for today.';
  }

  @override
  String get handoverReasonHint =>
      'Why are you rejecting? (at least 10 characters)';

  @override
  String handoverReason(String reason) {
    return 'Reason: $reason';
  }

  @override
  String get handoverStatusPending => 'Waiting for you';

  @override
  String get handoverStatusAccepted => 'Accepted';

  @override
  String get handoverStatusRejected => 'Rejected';

  @override
  String get handoverStatusOther => 'Closed';

  @override
  String get handoverOpenConflicts => 'Open problems';

  @override
  String syncProblemRejected(String reason) {
    return 'Not accepted: $reason';
  }

  @override
  String syncProblemConflict(String reason) {
    return 'Needs office check: $reason';
  }

  @override
  String syncWaitingSince(String count, String time) {
    return '$count items · since $time';
  }

  @override
  String get syncMediaTitle => 'Photos waiting';

  @override
  String syncMediaCount(String count) {
    return '$count photos';
  }

  @override
  String get syncRetryAll => 'Retry problems';

  @override
  String get syncBlockedUpgrade => 'Update the app to continue syncing';

  @override
  String get settingsLanguageBn => 'বাংলা';

  @override
  String get settingsLanguageEn => 'English';

  @override
  String settingsDevice(String id) {
    return 'Device $id';
  }

  @override
  String meStaffCode(String code) {
    return 'Staff code $code';
  }

  @override
  String meBranch(String branch) {
    return '$branch branch';
  }

  @override
  String get logoutButton => 'Sign out and remove data';

  @override
  String get mapNoPins => 'No customers with a map pin';

  @override
  String get mapTilesOffline => 'Map needs internet · pins still shown';

  @override
  String get mapMyLocation => 'My location';

  @override
  String mapPinsCount(String count) {
    return '$count on map';
  }

  @override
  String get mapAttribution => 'Map data © OpenStreetMap contributors';

  @override
  String get todayNotifications => 'Notifications';

  @override
  String get todayProgressTitle => 'Today\'s progress';

  @override
  String get todayNoTarget => 'No target set';

  @override
  String todayMore(String count) {
    return '$count more';
  }

  @override
  String todayReceiptsLow(String count) {
    return 'Only $count receipt numbers left. Connect to get more.';
  }

  @override
  String get actionMore => 'More';

  @override
  String get callHowWasIt => 'How did the call go?';

  @override
  String get callConnected => 'Talked';

  @override
  String get callNoAnswer => 'No answer';

  @override
  String get callBusy => 'Busy';

  @override
  String get callSwitchedOff => 'Phone off';

  @override
  String get callWrongNumber => 'Wrong number';

  @override
  String get callUnknown => 'Called';

  @override
  String get callSaved => 'Call saved';

  @override
  String timelineCall(String outcome) {
    return 'Call · $outcome';
  }

  @override
  String get trackingNotificationTitle => 'On duty · location shared';

  @override
  String get trackingNotificationText => 'Stops when you end work.';

  @override
  String get trackingTitle => 'Location tracking';

  @override
  String trackingOn(String provider) {
    return 'On · $provider';
  }

  @override
  String get trackingOff => 'Off (only while on duty)';

  @override
  String get trackingProviderFree => 'standard';

  @override
  String get trackingProviderPaid => 'premium';

  @override
  String get trackingFallback =>
      'Premium tracking is not in this app version; using standard.';

  @override
  String trackingLastPoint(String time) {
    return 'Last point $time';
  }

  @override
  String trackingPending(String count) {
    return '$count points waiting';
  }

  @override
  String get oemGuideTitle => 'Battery & Background Settings';

  @override
  String get oemGuideSubtitle =>
      'Some phones stop GPS when the screen turns off. Follow the steps for your phone brand to keep tracking on while on duty.';

  @override
  String get oemGuideDone => 'Got it';

  @override
  String get oemGuideXiaomiName => 'Xiaomi / Redmi / POCO (MIUI)';

  @override
  String get oemGuideXiaomiStep1 =>
      'Settings → Apps → Manage apps → [this app] → Battery saver → No restrictions';

  @override
  String get oemGuideXiaomiStep2 =>
      'Settings → Apps → Manage apps → [this app] → Autostart → turn ON';

  @override
  String get oemGuideXiaomiStep3 =>
      'Settings → Battery & performance → App battery saver → find this app → No restrictions';

  @override
  String get oemGuideSamsungName => 'Samsung (One UI)';

  @override
  String get oemGuideSamsungStep1 =>
      'Settings → Apps → [this app] → Battery → Unrestricted';

  @override
  String get oemGuideSamsungStep2 =>
      'Settings → Device care → Battery → App power management → Sleeping apps → remove this app';

  @override
  String get oemGuideSamsungStep3 =>
      'Settings → Apps → [this app] → Mobile data → Allow background data usage';

  @override
  String get oemGuideOppoName => 'Oppo / Realme (ColorOS)';

  @override
  String get oemGuideOppoStep1 =>
      'Settings → Battery → App power saving → find this app → turn OFF';

  @override
  String get oemGuideOppoStep2 =>
      'Settings → Apps → [this app] → Battery usage → Allow background activity';

  @override
  String get oemGuideOppoStep3 =>
      'Settings → Battery → More → App quick freeze → exclude this app';

  @override
  String get oemGuideVivoName => 'Vivo (Funtouch OS)';

  @override
  String get oemGuideVivoStep1 =>
      'Settings → Battery → Background app power management → turn OFF for this app';

  @override
  String get oemGuideVivoStep2 =>
      'iManager → App Management → [this app] → Background run → Allow';

  @override
  String get oemGuideVivoStep3 =>
      'Settings → Apps → [this app] → Battery → Unrestricted';

  @override
  String get oemGuideHuaweiName => 'Huawei / Honor (EMUI / MagicUI)';

  @override
  String get oemGuideHuaweiStep1 =>
      'Phone Manager → Launch manager → find this app → Manage manually';

  @override
  String get oemGuideHuaweiStep2 =>
      'Turn on Auto-launch, Secondary launch, and Run in background';

  @override
  String get oemGuideHuaweiStep3 =>
      'Settings → Battery → App launch → find this app → Manage manually → allow all three';

  @override
  String get oemGuideOneplusName => 'OnePlus / Nothing (OxygenOS)';

  @override
  String get oemGuideOneplusStep1 =>
      'Settings → Apps → [this app] → Battery → Allow background activity';

  @override
  String get oemGuideOneplusStep2 =>
      'Settings → Battery → Battery optimization → All apps → [this app] → Don\'t optimize';

  @override
  String get oemGuideOtherName => 'Other Android phones';

  @override
  String get oemGuideOtherStep1 =>
      'Settings → Apps → [this app] → Battery → Unrestricted (or Don\'t optimize)';

  @override
  String get oemGuideOtherStep2 =>
      'Settings → Battery → Battery optimization → find this app → Don\'t optimize';

  @override
  String visitSuggestTitle(String name) {
    return 'Near $name?';
  }

  @override
  String visitSuggestBody(String minutes) {
    return 'You have been here $minutes. Record a visit?';
  }

  @override
  String get visitSuggestNo => 'Not now';

  @override
  String get visitSuggestYes => 'Record visit';

  @override
  String get actionSetLocation => 'Set location';

  @override
  String get actionCorrectLocation => 'Correct location';

  @override
  String get pinIntro =>
      'Move the map until the pin sits on the customer\'s door. Tap a spot to bring it under the pin.';

  @override
  String get pinOutside => 'This position is outside Bangladesh.';

  @override
  String get pinNoteHint => 'Landmark, gate colour, floor…';

  @override
  String get pinSubmit => 'Send for approval';

  @override
  String get pinSent => 'Sent. The pin changes after a manager approves it.';

  @override
  String get pinPending => 'New location sent · waiting for manager approval';

  @override
  String get pinFailed =>
      'The server refused this location. Open the map and send it again.';

  @override
  String pinDistanceFromOld(String distance) {
    return '$distance from the current pin';
  }

  @override
  String get pinMapLabel =>
      'Map. Drag it to put the pin on the customer\'s door.';

  @override
  String get pinAt => 'Pin at';

  @override
  String pinPhoneDistance(String distance) {
    return 'You are $distance from the pin';
  }

  @override
  String pinPhoneFar(String distance) {
    return 'You are $distance from the pin. Check it is the right house: the manager sees this distance.';
  }

  @override
  String get pinPhoneUnknown => 'Your own location is not known yet.';

  @override
  String get pinPhoneMock =>
      'Your phone reports a fake location, so a manager checks this pin.';

  @override
  String get pinWillApply =>
      'This customer has no location yet: the pin is set as soon as it is sent.';

  @override
  String get pinWillApplyApprover =>
      'You can approve pins: the pin is set as soon as it is sent.';

  @override
  String get pinNeedsManager =>
      'A manager checks the new pin before it changes.';

  @override
  String get pinPhotoOptional => 'Photo of the house or shop (optional)';

  @override
  String get pinSubmitApply => 'Set pin';

  @override
  String get pinSentApplied => 'Saved. The pin is set as soon as it is sent.';

  @override
  String get pinApplyWhenSent =>
      'New location saved · it is set as soon as it is sent';

  @override
  String get pinTypeCoords => 'Type or paste coordinates';

  @override
  String get pinTypeCoordsHelp =>
      'For example 22.70123, 90.37011, or a map link';

  @override
  String get pinTypeCoordsError => 'Could not read these coordinates.';

  @override
  String get pinGo => 'Go';

  @override
  String mapNoPinCount(String count) {
    return '$count without location';
  }

  @override
  String get mapNoPinTitle => 'Customers without location';

  @override
  String pinRejected(String reason) {
    return 'Location not approved: $reason. Tap to send a new one.';
  }

  @override
  String get attendanceSelfieNeeded =>
      'Attendance needs a photo of you. Tap again and take the photo.';

  @override
  String get attendanceSelfieHint =>
      'The front camera opens to take your photo. Camera only.';

  @override
  String get mapViewMap => 'Map';

  @override
  String get mapViewList => 'List';

  @override
  String get mapFilterClear => 'Clear';

  @override
  String get mapListEmpty => 'No customers match these filters';

  @override
  String get mapListNoFix =>
      'No GPS yet · distances appear when the phone finds you';

  @override
  String get coworkTitle => 'Co-work';

  @override
  String coworkInviteFrom(String name) {
    return '$name wants to work with you today';
  }

  @override
  String coworkWith(String names) {
    return 'With: $names';
  }

  @override
  String get coworkActiveTitle => 'Working together today';

  @override
  String coworkYou(String name) {
    return '$name (you)';
  }

  @override
  String get coworkWaiting => 'Waiting';

  @override
  String get coworkNoPartnerYet =>
      'Visits count as co-work once someone accepts';

  @override
  String coworkVisitsToday(String n) {
    return '$n co-work visits';
  }

  @override
  String get coworkAdd => 'Ask more';

  @override
  String get coworkLeave => 'Leave group';

  @override
  String get coworkLeaveConfirm =>
      'After you leave, your next visits count as single visits. Earlier co-work visits stay as they are.';

  @override
  String get coworkLeaveEndsConfirm =>
      'Only two of you are in the group, so it ends when you leave. Earlier co-work visits stay as they are.';

  @override
  String get coworkCancelRequest => 'Cancel request';

  @override
  String get coworkCancelConfirm =>
      'Nobody has accepted yet. The request is withdrawn for everyone you asked.';

  @override
  String get coworkCancelled => 'Request cancelled';

  @override
  String get coworkStartTitle => 'Work with a colleague';

  @override
  String get coworkStartBody => 'Visits made together count for everyone';

  @override
  String get coworkNeedsInternet => 'Sending and answering need internet';

  @override
  String get coworkInviteSection => 'Whom to ask?';

  @override
  String coworkSeatsLeft(String n) {
    return 'You can ask $n more';
  }

  @override
  String get coworkFull => 'The group is full';

  @override
  String get coworkOnDuty => 'On duty';

  @override
  String get coworkOffDuty => 'Not on duty';

  @override
  String get coworkInOtherGroup => 'In another group';

  @override
  String get coworkInThisGroup => 'In this group';

  @override
  String get coworkNoteHint => 'e.g. which area you will cover';

  @override
  String coworkSend(String n) {
    return 'Send request ($n)';
  }

  @override
  String get coworkSent => 'Request sent';

  @override
  String get coworkJoined => 'You joined the group';

  @override
  String get coworkDeclined => 'You declined';

  @override
  String get coworkLeft => 'You left the group';

  @override
  String get coworkOffline => 'No internet. Try again when connected.';

  @override
  String get coworkErrAlreadyIn =>
      'You are already in another group today. Leave it first.';

  @override
  String get coworkErrEnded => 'This group has ended';

  @override
  String get coworkErrNotInvited => 'This invitation is no longer open';

  @override
  String get coworkErrTooMany => 'The group has reached its member limit';

  @override
  String get coworkErrInvitee => 'This colleague can\'t be asked';

  @override
  String get coworkNoColleagues => 'No colleagues in your branch to ask';

  @override
  String get coworkVisitToggle => 'Co-work visit';

  @override
  String coworkVisitWith(String names) {
    return 'With $names · counts for everyone';
  }

  @override
  String get coworkVisitSingle => 'Off: a single visit, yours only';

  @override
  String get coworkBadge => 'Co-work';

  @override
  String timelineCoworkWith(String names) {
    return 'with $names';
  }

  @override
  String timelineRecordedBy(String name) {
    return 'recorded by $name';
  }

  @override
  String todayVisitsJoint(String n) {
    return '$n co-work';
  }

  @override
  String get coworkAsked => 'Asked';

  @override
  String get todayTargetMet => 'Target met';

  @override
  String get todayTargetPersonal => 'My target';

  @override
  String get todayOffDay => 'Day off, no target today';

  @override
  String get todayVisitTarget => 'Visit target';

  @override
  String todayVisitTargetOf(String done, String target) {
    return '$done / $target';
  }

  @override
  String get perfTitle => 'My performance';

  @override
  String get perfMeSubtitle => 'This month\'s collections, visits, target';

  @override
  String get perfPrevMonth => 'Previous month';

  @override
  String get perfNextMonth => 'Next month';

  @override
  String perfCachedAt(String time) {
    return 'No internet. Showing figures from $time.';
  }

  @override
  String get perfCollected => 'Collected this month';

  @override
  String perfTargetToDate(String toDate, String month) {
    return 'Target to date $toDate · whole month $month';
  }

  @override
  String get perfPosted => 'Posted in ERP';

  @override
  String get perfPendingErp => 'Pending in ERP';

  @override
  String get perfVisitCredit => 'Visit credit (against target to date)';

  @override
  String get perfSoloVisits => 'Single visits';

  @override
  String get perfCoWorkVisits => 'Co-work visits';

  @override
  String get perfPromisesKept => 'Promises kept';

  @override
  String perfOf(String a, String b) {
    return '$a/$b';
  }

  @override
  String get perfPresentDays => 'Days present';

  @override
  String get perfLateDays => 'Late days';

  @override
  String perfRank(String rank, String of) {
    return 'Your place in the branch: $rank of $of';
  }

  @override
  String get perfRankBy => 'By collections · see leaderboard';

  @override
  String get perfDaily => 'Collections by day';

  @override
  String get perfLegendCollected => 'Collected';

  @override
  String get perfLegendMet => 'Target met';

  @override
  String get perfLegendTarget => 'Target';

  @override
  String perfDailySemantics(String total) {
    return 'Daily collections chart for this month, total $total';
  }

  @override
  String get reportOffline => 'Needs internet. Try again when connected.';

  @override
  String get leaderboardTitle => 'Leaderboard';

  @override
  String get leaderboardHidden => 'The leaderboard is off';

  @override
  String get leaderboardHiddenBody =>
      'It shows here when the office turns it on';

  @override
  String get leaderToday => 'Today';

  @override
  String get leaderMonth => 'This month';

  @override
  String get leaderMetricCollected => 'Collected';

  @override
  String get leaderMetricVisits => 'Visit credit';

  @override
  String get leaderMetricPromises => 'Promises kept';

  @override
  String get leaderMetricTarget => 'Target achieved';

  @override
  String get leaderNotRanked => 'Not ranked (too few days present)';

  @override
  String get leaderNotRankedMe =>
      'You have too few days present in this period to be ranked';

  @override
  String get leaderFootnote =>
      'Collected counts money taken in the field (posted and pending in ERP). Co-work visits add to everyone\'s credit.';

  @override
  String get noticesTitle => 'Notices';

  @override
  String get noticeTitle => 'Notice';

  @override
  String get noticesEmpty => 'No notices';

  @override
  String get noticesEmptyBody => 'Notices from the office show here';

  @override
  String get noticeRead => 'Read';

  @override
  String get noticeMustRead => 'Confirm reading';

  @override
  String get noticeUnread => 'New';

  @override
  String noticeFrom(String name) {
    return 'From $name';
  }

  @override
  String get noticeMarkRead => 'I have read it';

  @override
  String get noticeThanks => 'Thanks, the office will see it';

  @override
  String noticeReadAt(String time) {
    return 'Read at $time';
  }

  @override
  String noticeReadQueued(String time) {
    return 'Read at $time · reaches the office when online';
  }

  @override
  String get noticeReadFailed =>
      'Could not be sent to the office. See the sync centre.';

  @override
  String todayNoticeOne(String title) {
    return 'New notice: $title';
  }

  @override
  String todayNoticeMany(String n) {
    return '$n notices to read and confirm';
  }

  @override
  String noticesUnreadCount(String n) {
    return '$n new';
  }

  @override
  String get noticesAllRead => 'All read';

  @override
  String get leaveTitle => 'Leave';

  @override
  String get leaveMeSubtitle => 'Ask for leave and see the answer';

  @override
  String get leaveNew => 'Ask for leave';

  @override
  String get leaveTypeCasual => 'Casual';

  @override
  String get leaveTypeSick => 'Sick';

  @override
  String get leaveTypeOther => 'Other';

  @override
  String get leavePending => 'Pending';

  @override
  String get leaveApproved => 'Approved';

  @override
  String get leaveRejected => 'Not approved';

  @override
  String get leaveCancelled => 'Withdrawn';

  @override
  String get leaveCancelDone => 'Request withdrawn';

  @override
  String leaveDays(String n) {
    return '$n days';
  }

  @override
  String leaveTotalDays(String n) {
    return '$n days in total';
  }

  @override
  String leaveAskedAt(String time) {
    return 'Asked $time';
  }

  @override
  String leaveManagerSaid(String reason) {
    return 'Manager: $reason';
  }

  @override
  String get leaveCancelAction => 'Withdraw';

  @override
  String get leaveCancelTitle => 'Withdraw this request?';

  @override
  String leaveCancelBody(String from, String to) {
    return 'The request for $from – $to will be withdrawn. You can ask again if needed.';
  }

  @override
  String get leaveCancelConfirm => 'Yes, withdraw';

  @override
  String get leaveEmpty => 'No leave requests';

  @override
  String get leaveEmptyBody => 'Tap the button below to ask';

  @override
  String leaveCachedAt(String time) {
    return 'Offline · showing what the phone had at $time';
  }

  @override
  String get leaveNeedsInternet => 'Needs internet. Try again when connected.';

  @override
  String get leaveType => 'Type of leave';

  @override
  String get leaveFrom => 'From';

  @override
  String get leaveTo => 'To';

  @override
  String get leaveReason => 'Reason (optional)';

  @override
  String get leaveReasonHint => 'e.g. sister\'s wedding';

  @override
  String get leaveOnlineNote =>
      'Sending needs internet. The manager\'s answer shows here.';

  @override
  String get leaveSend => 'Send request';

  @override
  String get leaveSent => 'Request sent';

  @override
  String get leaveErrToBeforeFrom => 'The end date cannot be before the start';

  @override
  String get leaveErrTooLong => 'At most 31 days in one request';

  @override
  String get leaveErrOverlaps =>
      'You already have a request for some of these days';

  @override
  String get leaveErrDecided => 'The manager has already decided';

  @override
  String get calendarTitle => 'Holidays and shift';

  @override
  String get calendarMeSubtitle => 'Holidays, weekly off and duty hours';

  @override
  String get calendarMyShift => 'My shift';

  @override
  String get calendarDefaultShift => 'Branch default shift';

  @override
  String calendarShiftHours(String start, String end) {
    return '$start – $end';
  }

  @override
  String calendarWeeklyOff(String days) {
    return 'Weekly off: $days';
  }

  @override
  String get calendarNoWeeklyOff => 'No weekly off';

  @override
  String calendarLateGrace(String grace, String brk) {
    return 'Late after $grace · break $brk';
  }

  @override
  String get calendarMyLeave => 'My approved leave';

  @override
  String get calendarHolidays => 'Holidays';

  @override
  String get calendarNoHolidays => 'No holidays entered for this year';

  @override
  String get calendarNoHolidaysBody =>
      'They show here once the office adds them';

  @override
  String get calendarNational => 'National';

  @override
  String get calendarBranch => 'Branch';

  @override
  String get weekdaySun => 'Sunday';

  @override
  String get weekdayMon => 'Monday';

  @override
  String get weekdayTue => 'Tuesday';

  @override
  String get weekdayWed => 'Wednesday';

  @override
  String get weekdayThu => 'Thursday';

  @override
  String get weekdayFri => 'Friday';

  @override
  String get weekdaySat => 'Saturday';

  @override
  String timelineGuarantorCall(String outcome) {
    return 'Guarantor call · $outcome';
  }

  @override
  String get guarantorNoName => 'No name';

  @override
  String get guarantorCall => 'Call the guarantor';

  @override
  String get guarantorCallShort => 'Call';

  @override
  String get guarantorNoPhone => 'No phone number';

  @override
  String get planCreditSale => 'Credit sale';

  @override
  String planPayBy(String date) {
    return 'Pay by $date';
  }

  @override
  String get planReturned => 'Returned in the ERP · not collectable';

  @override
  String get planCancelled => 'Cancelled in the ERP · not collectable';

  @override
  String get planFreqMonthly => 'Monthly';

  @override
  String get planFreqWeekly => 'Weekly';

  @override
  String get planFreqDaily => 'Daily';

  @override
  String planFreqEveryNDays(String n) {
    return 'Every $n days';
  }

  @override
  String get planFreqCustom => 'Custom dates';

  @override
  String get planProducts => 'Products';

  @override
  String planSerials(String list) {
    return 'Serial: $list';
  }

  @override
  String get planGuarantor => 'Guarantor for this plan';

  @override
  String planWrittenOff(String amount) {
    return 'Written off $amount';
  }

  @override
  String scheduleLateFee(String amount) {
    return 'incl. late fee $amount';
  }

  @override
  String scheduleLinePaidOn(String date) {
    return 'Paid on $date';
  }

  @override
  String scheduleDaysLate(String days) {
    return '$days days late';
  }

  @override
  String get scheduleMissed => 'Missed';

  @override
  String scheduleLinePayments(String seq) {
    return 'Payments for installment $seq';
  }

  @override
  String scheduleReceiptNo(String no) {
    return 'Receipt $no';
  }

  @override
  String schedulePaidOf(String paid, String left) {
    return 'Paid $paid · left $left';
  }

  @override
  String get planTotal => 'Invoice total';

  @override
  String get planPaidSoFar => 'Paid so far';

  @override
  String get planLeft => 'Outstanding';

  @override
  String planRemainingInstallments(String n) {
    return '$n remaining';
  }

  @override
  String get phoneErpPrimary => 'ERP';

  @override
  String get phoneAdded => 'Added';

  @override
  String get phoneAddNumber => 'Add number';

  @override
  String get phoneAddTitle => 'Add phone numbers';

  @override
  String get phoneAddHint =>
      'You can add several numbers at once. The ERP number stays as it is.';

  @override
  String phoneNumberN(String n) {
    return 'Number $n';
  }

  @override
  String get phoneWhose => 'Whose number';

  @override
  String get phoneWhoseHint => 'wife, shop, son';

  @override
  String phoneDropRow(String n) {
    return 'Drop number $n';
  }

  @override
  String get phoneAnother => 'Another number';

  @override
  String get phoneErrInvalid =>
      'Enter a Bangladesh mobile number (01XXXXXXXXX)';

  @override
  String get phoneErrDuplicate => 'The customer already has this number';

  @override
  String get phoneErrRepeated => 'This number is typed twice';

  @override
  String get phoneErrEmpty => 'Type at least one number';

  @override
  String get phoneKeptHere =>
      'These numbers stay in the field system. They are not sent to the ERP.';

  @override
  String get phoneSave => 'Save numbers';

  @override
  String phoneSavedN(String n) {
    return 'Numbers added: $n';
  }

  @override
  String get phonePending => 'Waiting to be sent to the server';

  @override
  String get phoneRemove => 'Remove number';

  @override
  String get phoneRemoveTitle => 'Remove this number?';

  @override
  String phoneRemoveBody(String number) {
    return '$number will be removed from the customer. Only numbers added in the field can be removed; the office\'s numbers stay.';
  }

  @override
  String get phoneRemoved => 'Number removed';

  @override
  String get phoneRemoveOffline =>
      'Internet is needed to remove a number. Try again when online.';

  @override
  String get phoneRemoveNotAllowed => 'This number cannot be removed.';

  @override
  String get receiptView => 'Receipt';

  @override
  String get receiptOpenCustomer => 'Open customer';

  @override
  String get receiptNotOnPhone => 'This receipt is not on this phone';

  @override
  String get cashInHandOpen => 'Which collections is this cash from?';

  @override
  String get cashInHandTitle => 'Cash on hand, by collection';

  @override
  String cashInHandInvoice(String no) {
    return 'Invoice $no';
  }

  @override
  String cashInHandPartOf(String amount) {
    return 'left of $amount';
  }

  @override
  String cashInHandPendingDeposits(String amount) {
    return '$amount handed in by earlier deposits';
  }

  @override
  String get cashInHandUnsent =>
      'Some money on this phone has not reached the server yet; it is not in this list.';

  @override
  String get cashInHandEmpty => 'No cash on hand.';

  @override
  String cashInHandMore(String n) {
    return '$n older collections are not listed; the total above includes them.';
  }

  @override
  String get cashInHandHow =>
      'A deposit hands in all the cash and every mobile or bank collection you hold at once, and they then go to the ERP. Until you deposit, each line can be changed or deleted; after it, nothing can. Tap a line to open the customer.';

  @override
  String get cashActionEdit => 'Change';

  @override
  String get cashActionDelete => 'Delete';

  @override
  String get cashEditTitle => 'Change this collection';

  @override
  String get cashEditAmount => 'Amount (৳)';

  @override
  String get cashEditNote => 'Note';

  @override
  String get cashEditPayer => 'Paid by';

  @override
  String get cashEditSave => 'Save';

  @override
  String get cashDeleteTitle => 'Delete this collection?';

  @override
  String cashDeleteBody(String amount, String customer) {
    return '$amount from $customer will be removed from your cash in hand. The receipt number stays used and the line stays in the history as deleted.';
  }

  @override
  String get cashDeleteReason => 'Reason (optional)';

  @override
  String get cashDeleteConfirm => 'Delete';

  @override
  String get cashActionDone => 'Done';

  @override
  String get cashActionOffline =>
      'This needs internet. Try again when you are online.';

  @override
  String get cashActionCovered =>
      'This collection is already deposited, so it cannot be changed or deleted.';

  @override
  String get cashActionNotEditable =>
      'This collection is already with the ERP and cannot be changed here. Ask the office.';

  @override
  String get cashActionPosted =>
      'This collection is already posted to the ERP. Ask the office.';

  @override
  String get cashActionBusy =>
      'It is being sent to the ERP right now. Try again in a minute.';

  @override
  String get cashActionNotAllowed => 'You cannot change this collection.';

  @override
  String get cashActionFailed => 'Could not do it. Try again.';

  @override
  String collectionEditedWas(String amount) {
    return 'edited · was $amount';
  }

  @override
  String get collectionDeletedTag => 'deleted';

  @override
  String get cashInHandOffline => 'This list needs the internet';

  @override
  String get boardTabCollection => 'Collection board';

  @override
  String get boardTabBranch => 'Branch ranking';

  @override
  String get boardAllTime => 'All time';

  @override
  String boardMyRank(String rank, String of, String amount) {
    return 'You are $rank of $of · verified $amount';
  }

  @override
  String get boardNotRankedMe =>
      'Nothing of yours is verified in this period yet.';

  @override
  String boardCount(String n) {
    return '$n collections';
  }

  @override
  String get boardRoleManager => 'Manager';

  @override
  String get boardRoleAdmin => 'Admin';

  @override
  String get boardRoleOffice => 'Office';

  @override
  String get boardNoPosted => 'Nothing verified yet';

  @override
  String get boardEmpty =>
      'Nobody has a verified collection in this period yet.';

  @override
  String get boardFootnoteAll =>
      'Only collections the ERP has accepted are counted; money still waiting for the ERP is not. Every branch is on this board.';

  @override
  String get boardFootnoteBranch =>
      'Only collections the ERP has accepted are counted; money still waiting for the ERP is not. This board shows your branch.';

  @override
  String get boardCrown => 'First place';

  @override
  String get alertsTitle => 'Notifications';

  @override
  String get alertsEmptyTitle => 'Nothing is waiting for you';

  @override
  String get alertsEmptyBody =>
      'Promises due today, new tasks, co-work requests and notices from the office show here.';

  @override
  String alertPromiseToday(String amount) {
    return 'Promised $amount for today';
  }

  @override
  String alertNewTask(String title) {
    return 'New task: $title';
  }

  @override
  String alertCoworkInvite(String name) {
    return '$name asks you to work together';
  }

  @override
  String get alertNoticeUnread => 'Notice from the office, not read yet';

  @override
  String get alertNoticeMustRead =>
      'Notice from the office: please confirm you read it';

  @override
  String get alertHandoverWaiting => 'Handover waiting for your answer';

  @override
  String get filterAllBranches => 'All branches';

  @override
  String get farTitle => 'Far from the customer\'s pin';

  @override
  String farBody(String distance) {
    return 'You are $distance from the customer\'s pin. You can still record it; the office will see the distance.';
  }

  @override
  String get farConfirm => 'Record anyway';

  @override
  String get attTilePending => 'Not given yet';

  @override
  String get attTileDone => 'Given';

  @override
  String get perfWorkHistory => 'Work of each day';

  @override
  String get workPosted => 'Posted in ERP';

  @override
  String get workPromises => 'Promises';

  @override
  String get workEmptyTitle => 'No work recorded on this day';

  @override
  String get workTabMine => 'My work';

  @override
  String get workTabTeam => 'Other staff';

  @override
  String get teamEmptyTitle => 'No work by other staff on this day';

  @override
  String get teamEmptyBody =>
      'Visits, promises, collections and pins of your branch colleagues show here with their names.';

  @override
  String get alertsTeamSection => 'Other staff today';

  @override
  String get alertsTeamMore => 'See all';

  @override
  String get workEmptyBody =>
      'Visits, collections, promises, notes, pins, calls and finished tasks show here.';

  @override
  String get workPrevDay => 'Previous day';

  @override
  String get workNextDay => 'Next day';

  @override
  String get workPin => 'Map pin sent';

  @override
  String workTaskDone(String title) {
    return 'Reported done: $title';
  }

  @override
  String get marksVisitToday => 'Visited today';

  @override
  String get marksVisitMonth => 'Visited this month';

  @override
  String get marksVisitNone => 'Not visited this month';

  @override
  String get marksPaid => 'Money in the ERP this month';

  @override
  String get marksPending => 'Collected, pending in ERP';

  @override
  String get marksPaidNone => 'Nothing paid this month';

  @override
  String get marksPromiseOpen => 'Has an open promise';

  @override
  String get marksPromiseNone => 'No open promise';

  @override
  String get marksPinSet => 'Map pin set';

  @override
  String get marksPinMissing => 'No map pin';

  @override
  String get monthTitle => 'This month';

  @override
  String monthLastVisit(String date) {
    return 'Last visit $date';
  }

  @override
  String monthPaid(String amount) {
    return 'In the ERP: $amount';
  }

  @override
  String monthPending(String amount) {
    return 'Pending in ERP: $amount';
  }

  @override
  String monthPromise(String date) {
    return 'Promise on $date';
  }

  @override
  String monthInvoices(String total, String open) {
    return 'Invoices: $total · with a balance: $open';
  }

  @override
  String planRolledHidden(String n) {
    return '$n unpaid installments were moved to a later one in the ERP and are hidden';
  }

  @override
  String get detailDirections => 'Directions';

  @override
  String get detailNoAddress => 'No address in the ERP';

  @override
  String erpRiskBadge(String grade) {
    return 'ERP grade $grade';
  }

  @override
  String get erpRiskLow => 'low risk';

  @override
  String get erpRiskMedium => 'medium risk';

  @override
  String get erpRiskHigh => 'high risk';

  @override
  String timelineCollector(String name) {
    return 'by $name';
  }

  @override
  String timelineVisitBy(String name) {
    return 'visited by $name';
  }

  @override
  String timelinePromiseBy(String name) {
    return 'promise taken by $name';
  }

  @override
  String timelinePinBy(String name) {
    return 'pin set by $name';
  }

  @override
  String get timelinePinSet => 'Customer pin set';

  @override
  String get timelinePinPending =>
      'Customer pin proposed · waiting for approval';

  @override
  String get timelinePinRejected => 'Customer pin not approved';

  @override
  String get timelineAdvance => 'advance';

  @override
  String get timelineRemoved => 'removed in the ERP';

  @override
  String get collectSameDayWarning =>
      'This invoice already has a payment today. The ERP takes one a day, so the office may need to decide on this one.';

  @override
  String get customerAssignedToMe => 'Your customer';

  @override
  String get customerUnassigned => 'Not assigned to anyone';

  @override
  String customerAssignedTo(String name) {
    return '$name\'s customer';
  }

  @override
  String customerBranch(String branch) {
    return '$branch branch';
  }

  @override
  String get tasksTitle => 'My tasks';

  @override
  String get taskTitle => 'Task';

  @override
  String get tasksEmpty => 'No tasks';

  @override
  String get tasksEmptyBody => 'Tasks the office gives you show here';

  @override
  String get tasksSectionActive => 'To do';

  @override
  String get tasksSectionWaiting => 'Waiting for the office';

  @override
  String get tasksSectionClosed => 'Finished';

  @override
  String get taskStatusOpen => 'To do';

  @override
  String get taskStatusQueued => 'Will be sent';

  @override
  String get taskStatusWaiting => 'Office is checking';

  @override
  String get taskStatusResolved => 'Done';

  @override
  String get taskStatusCancelled => 'Cancelled';

  @override
  String get taskStatusOverdue => 'Overdue';

  @override
  String get taskNew => 'New';

  @override
  String taskDue(String date) {
    return 'Due $date';
  }

  @override
  String get taskNoDue => 'No due date';

  @override
  String taskFrom(String name) {
    return 'From $name';
  }

  @override
  String get taskNoteNone => 'No note';

  @override
  String get taskMarkDone => 'The work is done';

  @override
  String get taskDoneTitle => 'Tell the office it is done';

  @override
  String get taskDoneBody => 'The office checks it and then marks it resolved.';

  @override
  String get taskDoneNoteHint => 'What did you do? (optional)';

  @override
  String get taskDoneSend => 'Send to the office';

  @override
  String get taskDoneSent => 'Saved. The office will check it';

  @override
  String taskQueuedBanner(String time) {
    return 'Saved on this phone at $time. It goes to the office when there is a network.';
  }

  @override
  String taskWaitingBanner(String time) {
    return 'Sent at $time. The office will check it.';
  }

  @override
  String taskResolvedBanner(String time) {
    return 'The office marked it done at $time';
  }

  @override
  String get taskCancelledBanner => 'The office cancelled this task';

  @override
  String taskRejectedBanner(String reason) {
    return 'The office sent it back: $reason';
  }

  @override
  String get taskFailedBanner =>
      'Your last request was not accepted. You can send it again.';

  @override
  String get taskMyNote => 'Your note';

  @override
  String get taskOfficeNote => 'Office note';

  @override
  String get taskDetails => 'Details';

  @override
  String get taskHistory => 'History';

  @override
  String get taskEventCreated => 'Task given';

  @override
  String get taskEventEdited => 'Changed';

  @override
  String get taskEventResolveRequested => 'Marked as done';

  @override
  String get taskEventVerified => 'Office verified';

  @override
  String get taskEventRejected => 'Sent back';

  @override
  String get taskEventCancelled => 'Cancelled';

  @override
  String todayTasksOverdue(String n) {
    return 'Overdue tasks: $n';
  }

  @override
  String todayTasksNew(String n) {
    return 'New tasks from the office: $n';
  }

  @override
  String todayTasksOpen(String n) {
    return 'Tasks to do: $n';
  }

  @override
  String tasksOpenCount(String n) {
    return '$n to do';
  }

  @override
  String get tasksNothingOpen => 'Nothing to do';

  @override
  String get exitAppTitle => 'Close the app?';

  @override
  String get exitAppBody =>
      'Work that is not sent yet stays safe on this phone.';

  @override
  String get exitAppStay => 'Stay';

  @override
  String get exitAppConfirm => 'Close the app';

  @override
  String visitAlreadyToday(String time, String count) {
    return 'This customer was already visited $count time(s) today (last at $time). You can still record another visit.';
  }

  @override
  String get primerRequired => 'All permissions are needed to use this app';

  @override
  String get primerDeniedLocation =>
      'Location is required so your manager can track your field work. Tap to allow.';

  @override
  String get primerDeniedCamera =>
      'Camera is required for visit photos and selfies. Tap to allow.';

  @override
  String get primerDeniedNotifications =>
      'Notifications are needed for reminders and messages. Tap to allow.';

  @override
  String get primerDeniedBattery =>
      'Battery optimisation must be turned off so tracking keeps running. Tap to allow.';

  @override
  String get primerOpenSettings => 'Open settings';

  @override
  String get primerDeniedForever =>
      'You blocked this permission. Open phone settings to allow it.';

  @override
  String get locationGateTitle => 'Turn on location';

  @override
  String get locationGateBody =>
      'Location must be on to use this app. Your manager needs to see where you are during work hours.';

  @override
  String get locationGatePermission => 'Allow location permission';

  @override
  String get locationGateService => 'Turn on GPS / location';

  @override
  String get locationGateOpenSettings => 'Open location settings';

  @override
  String get locationGateRetry => 'Check again';

  @override
  String get attendanceNeedsLocation =>
      'Location is required to record attendance. Turn on GPS and try again.';

  @override
  String get locationGateBackground =>
      'Allow \"All the time\" location so tracking works even when the screen is off.';

  @override
  String get locationGateBackgroundSettings => 'Open permission settings';

  @override
  String get gpsStatusOn => 'GPS is on';

  @override
  String get gpsStatusOff => 'GPS is off';

  @override
  String get gpsStatusMock => 'Fake GPS detected!';

  @override
  String get gpsTurnOn => 'Turn on GPS';

  @override
  String get gpsMockWarning =>
      'Fake/mock location is not allowed. Disable mock locations to continue.';

  @override
  String get gpsRequiredForAttendance =>
      'GPS must be turned on to record attendance.';

  @override
  String get gpsRequiredForBreak =>
      'GPS must be turned on to start or end break.';

  @override
  String get gpsRequiredForWorkOut => 'GPS must be turned on to end work.';

  @override
  String get statusDeposited => 'Deposited';

  @override
  String get statusDepositFailed => 'Not deposited';

  @override
  String get cashDepositCash => 'Cash (all you hold)';

  @override
  String get cashDepositNonCash => 'Mobile / bank';

  @override
  String cashDepositNonCashCount(String count) {
    return '$count collections';
  }

  @override
  String cashDepositTotalCount(String count) {
    return '$count collections in all';
  }

  @override
  String get cashDepositAllHint =>
      'No part deposits: all the cash you hold and every mobile or bank collection go together, and then go to the ERP.';

  @override
  String get cashDepositNothing => 'Nothing in hand to deposit.';

  @override
  String get cashDepositSubmit => 'Deposit';

  @override
  String get cashDepositConfirmTitle => 'Confirm the deposit';

  @override
  String cashDepositConfirmOnline(String cash, String nonCash, String count) {
    return 'Depositing $cash cash and $nonCash mobile/bank ($count collections) sends them to the ERP as payments right away when online. After the deposit they cannot be changed or deleted.';
  }

  @override
  String cashDepositConfirmOffline(String cash, String nonCash, String count) {
    return 'There is no internet now. Depositing $cash cash and $nonCash mobile/bank ($count collections) sends them to the ERP as payments as soon as the phone is online. After the deposit they cannot be changed or deleted.';
  }

  @override
  String get cashDepositChanged =>
      'The money in hand just changed. Check it and deposit again.';

  @override
  String cashDepositLine(String count, String amount) {
    return '$count collections · mobile/bank $amount';
  }

  @override
  String get cashDepositWaitingLock =>
      'A deposit is still waiting to be sent, so nothing in hand can be changed or deleted now.';

  @override
  String get cashSlipTitle => 'Bank deposit slip';

  @override
  String get cashSlipNeeded =>
      'A bank deposit needs a photo of the deposit slip. Camera only.';

  @override
  String get cashSlipTake => 'Take a photo of the slip';

  @override
  String get cashSlipRetake => 'Retake';

  @override
  String get cashSlipUploading =>
      'The deposit is sent once its slip photo is uploaded.';

  @override
  String get cashInHandNonCashTitle =>
      'Mobile / bank collections (go with the deposit)';

  @override
  String get cashInHandNotSent =>
      'Not sent yet; it can be changed once it is sent';

  @override
  String get depositFailedMustBeAll =>
      'Not deposited: the server says you hold more cash than this deposit (something changed meanwhile). A deposit must take all of it.';

  @override
  String get depositFailedExceeds =>
      'Not deposited: the server says you hold less cash than this deposit (a collection was left out or changed).';

  @override
  String get depositFailedNothing =>
      'Not deposited: there was nothing in hand to deposit.';

  @override
  String get depositFailedSlip =>
      'Not deposited: the server got no slip photo for this bank deposit. Deposit again and take a photo of the slip, or deposit to the branch cashier or the manager.';

  @override
  String get depositFailedChanged =>
      'Not deposited: a collection was changed or cancelled while it was being deposited.';

  @override
  String depositFailedOther(String code) {
    return 'Not deposited ($code).';
  }

  @override
  String get depositFailedBack =>
      'The collections are back in your hand and can be changed. Deposit again.';

  @override
  String get depositAgain => 'Deposit again';

  @override
  String get collectWhichInvoice => 'Which invoice';

  @override
  String collectInvoiceCount(String count) {
    return '$count open invoices for this customer — pick the right one';
  }

  @override
  String get customerRefresh => 'Reload from server';

  @override
  String get customerRefreshDone => 'Updated from the server';

  @override
  String get customerRefreshOffline =>
      'Needs internet. Showing the data saved on this phone.';

  @override
  String get customerRefreshBusy => 'The ERP is busy. Try again in a minute.';

  @override
  String get customerRefreshNotFound =>
      'The server no longer has this customer for you. The data on this phone is kept.';

  @override
  String get customerRefreshDenied =>
      'You don\'t have permission to reload this customer.';

  @override
  String customerRefreshFailed(String code) {
    return 'Couldn\'t reload. Showing the saved data. Code: $code';
  }

  @override
  String get placeIconShop => 'Shop';

  @override
  String get placeIconMarket => 'Market';

  @override
  String get placeIconMosque => 'Mosque';

  @override
  String get placeIconSchool => 'School';

  @override
  String get placeIconBank => 'Bank';

  @override
  String get placeIconHospital => 'Hospital';

  @override
  String get placeIconBusStop => 'Bus stop';

  @override
  String get placeIconOffice => 'Office';

  @override
  String get placeIconLandmark => 'Landmark';

  @override
  String get placeIconOther => 'Other';

  @override
  String get placeNewTitle => 'New place on the map';

  @override
  String get placeEditTitle => 'Change this place';

  @override
  String get placeNewHint =>
      'Everyone in your branch sees the name next to the marker.';

  @override
  String get placeName => 'Name';

  @override
  String get placeNameHint => 'e.g. Karim Store';

  @override
  String get placeNameRequired => 'Write a name';

  @override
  String get placeKind => 'Kind of place';

  @override
  String get placeNote => 'Note (optional)';

  @override
  String get placeNoteHint => 'e.g. Blue gate, next to the tea stall';

  @override
  String get placeAdd => 'Add to the map';

  @override
  String get placeSave => 'Save';

  @override
  String placeSavedNew(String name) {
    return '$name is on the map';
  }

  @override
  String get placeSaved => 'Saved';

  @override
  String get placeGone => 'This place is no longer on the map.';

  @override
  String get placeAddedByMe => 'You added this place';

  @override
  String placeAddedBy(String name) {
    return 'Added by $name';
  }

  @override
  String get placeWaitingToSend =>
      'Saved on the phone; it is sent when there is internet.';

  @override
  String get placeMoveQueued =>
      'Your move request is saved and is sent when there is internet. The marker stays until the office approves.';

  @override
  String placeMovePending(String name) {
    return '$name asked to move it; waiting for the office.';
  }

  @override
  String get placeMoveApproved => 'The office moved it as asked.';

  @override
  String placeMoveRejected(String reason) {
    return 'The office did not move it: $reason';
  }

  @override
  String get placeEdit => 'Edit';

  @override
  String get placeRequestMove => 'Ask to move';

  @override
  String placeUpdatedAt(String at) {
    return 'Last change $at';
  }

  @override
  String get placeErrMovePending => 'Someone else already asked to move it.';

  @override
  String get placeErrMoveTooShort =>
      'The new point is almost the same as the old one.';

  @override
  String get placeErrOutside => 'This point is outside Bangladesh.';

  @override
  String get placeErrNotOwner =>
      'Only the person who added it or the office can change it.';

  @override
  String get placeErrGeneric => 'The server did not accept this change.';

  @override
  String placeMoveTitle(String name) {
    return 'Move $name';
  }

  @override
  String get placeMoveHint =>
      'Move the map until the pin sits on the right spot.';

  @override
  String placeMoveDistance(String n) {
    return '$n m from where it is now';
  }

  @override
  String get placeMoveReason => 'Why? (optional)';

  @override
  String get placeMoveSent =>
      'Sent to the office. The marker moves when they approve.';

  @override
  String get placeMoveDragFirst => 'Move the map first';

  @override
  String get placeMoveSend => 'Send to the office';

  @override
  String get placeMoveNow => 'Move';

  @override
  String get placeMoveNowHint =>
      'Move the map until the pin sits on the right spot. The marker moves as soon as you save, even without internet.';

  @override
  String get placeMoveNowSave => 'Move here';

  @override
  String get placeMovedNow =>
      'Moved. It is sent to the server when there is internet.';

  @override
  String get syncEntityPlace => 'Map place';

  @override
  String placeProblem(String name, String reason) {
    return '$name: $reason';
  }

  @override
  String get placeProblemMoveBack =>
      'The move was refused, so the marker is back where the server has it.';

  @override
  String get placeErrMoveNeedsManage =>
      'Only the office can move a place directly.';

  @override
  String get filterInstallment => 'Installment';

  @override
  String get filterCredit => 'Credit sale';

  @override
  String get kindInstallment => 'Installment';

  @override
  String get kindCredit => 'Credit';

  @override
  String kindInstallmentCount(String n) {
    return '$n installment';
  }

  @override
  String kindCreditCount(String n) {
    return '$n credit';
  }

  @override
  String kindLabelA11y(String kinds) {
    return 'Open invoices: $kinds';
  }

  @override
  String monthVisitWho(String name) {
    return 'Visit: $name';
  }

  @override
  String get monthToday => 'today';

  @override
  String monthPaidAmount(String amount) {
    return 'Paid: $amount';
  }

  @override
  String monthPromiseAmount(String amount) {
    return 'Promise: $amount';
  }

  @override
  String promisedBy(String name) {
    return 'Promised by $name';
  }

  @override
  String get kindCash => 'Cash';

  @override
  String kindCashCount(String n) {
    return '$n cash';
  }

  @override
  String get planCashSale => 'Cash sale';

  @override
  String get monthOffice => 'office';

  @override
  String monthMore(String n) {
    return '+$n';
  }

  @override
  String get mediaQueueHint =>
      'Photos go to the server on their own, separately from the other work. Nothing is deleted from this phone until the server has the photo.';

  @override
  String get mediaKindSelfie => 'Attendance photo';

  @override
  String get mediaKindVisit => 'Visit photo';

  @override
  String get mediaKindSlip => 'Deposit slip';

  @override
  String get mediaKindPin => 'Map pin photo';

  @override
  String get mediaKindOther => 'Photo';

  @override
  String get mediaStateWaiting => 'Waiting to upload';

  @override
  String mediaStateFailed(String reason) {
    return 'Not uploaded yet: $reason';
  }

  @override
  String mediaNextTry(String tries, String time) {
    return 'Tried $tries times · tries again at $time';
  }

  @override
  String get mediaRetryAll => 'Upload all now';

  @override
  String get mediaReasonNetwork => 'no connection to the server';

  @override
  String get mediaReasonTimeout => 'the network was too slow';

  @override
  String get mediaReasonMissing => 'the photo file is no longer on this phone';

  @override
  String get mediaReasonDeleted =>
      'the office deleted this photo on the server';

  @override
  String get mediaReasonInvalid =>
      'the server did not accept the photo\'s details';

  @override
  String get mediaReasonSignature =>
      'the upload link was refused or had expired';

  @override
  String get mediaReasonNotUploaded => 'the server did not receive the photo';

  @override
  String get mediaReasonServer => 'the server is not answering right now';

  @override
  String mediaReasonCode(String code) {
    return 'the server answered $code';
  }

  @override
  String mediaStepPresign(String reason) {
    return '$reason (getting the upload link)';
  }

  @override
  String mediaStepUpload(String reason) {
    return '$reason (sending the photo)';
  }

  @override
  String mediaStepConfirm(String reason) {
    return '$reason (confirming)';
  }

  @override
  String get attNotRequired =>
      'Your account does not give attendance. There is nothing to do here.';

  @override
  String get leaderboardMeSubtitle => 'Who collected the most this month';

  @override
  String get promiseFollowUpAction => 'New promise (follow-up)';

  @override
  String promiseFollowUpOf(String amount, String date) {
    return 'Follow-up of the broken promise of $amount for $date';
  }

  @override
  String promiseAttempt(String n) {
    return 'Attempt $n';
  }

  @override
  String get todayBrokenTitle => 'Broken promises to follow up';

  @override
  String todayBrokenRow(String amount, String date) {
    return '$amount · was due $date';
  }

  @override
  String get prospectsTitle => 'Possible customers';

  @override
  String get prospectsMeSubtitle =>
      'People who may buy: note them, the office follows up';

  @override
  String get prospectAdd => 'Add';

  @override
  String get prospectsEmpty => 'No possible customers yet';

  @override
  String get prospectsEmptyBody =>
      'Met someone who may buy? Add them here, even without internet.';

  @override
  String get prospectStatusNew => 'New';

  @override
  String get prospectStatusContacted => 'Contacted';

  @override
  String get prospectStatusConverted => 'Became a customer';

  @override
  String get prospectStatusClosed => 'Closed';

  @override
  String get prospectByMe => 'you';

  @override
  String prospectAddedBy(String name, String time) {
    return 'Added by $name · $time';
  }

  @override
  String get prospectHasLocation => 'Location saved';

  @override
  String get prospectWaiting => 'Waiting to be sent';

  @override
  String prospectRefused(String code) {
    return 'Not accepted by the server: $code';
  }

  @override
  String get prospectEdit => 'Change';

  @override
  String get prospectNewTitle => 'New possible customer';

  @override
  String get prospectEditTitle => 'Change possible customer';

  @override
  String get prospectName => 'Name';

  @override
  String get prospectPhone => 'Mobile number';

  @override
  String get prospectPhoneMore => 'Another mobile number (optional)';

  @override
  String get prospectAddPhone => 'Add a number';

  @override
  String get prospectAddress => 'Address (optional)';

  @override
  String get prospectNote => 'Note (optional)';

  @override
  String get prospectLocation => 'Save where I am now';

  @override
  String get prospectLocationHint => 'Only if you are with the person now';

  @override
  String get prospectLocationOffDuty =>
      'Location is used only while you are on duty';

  @override
  String get prospectSaved =>
      'Saved. It goes to the office when there is internet.';

  @override
  String get prospectOfflineHint =>
      'Works without internet. You can change it until the office acts on it.';

  @override
  String get prospectErrName => 'Write a name';

  @override
  String get prospectErrNameLong => 'The name is too long (at most 80 letters)';

  @override
  String get prospectErrPhone => 'Write at least one mobile number';

  @override
  String get prospectErrPhoneInvalid =>
      'A mobile number is not valid (01XXXXXXXXX)';

  @override
  String get prospectErrPhoneRepeated => 'The same number is written twice';

  @override
  String get prospectErrAddressLong =>
      'The address is too long (at most 200 letters)';

  @override
  String get prospectErrNoteLong =>
      'The note is too long (at most 500 letters)';

  @override
  String get prospectErrNotEditable => 'This one can no longer be changed';

  @override
  String get prospectRefusedNotNew =>
      'Your change was not saved: the office had already acted on it';

  @override
  String get prospectRefusedNotOwner =>
      'Only the person who added it can change it';

  @override
  String get prospectRefusedInvalid =>
      'The server did not accept the name or a number';
}
