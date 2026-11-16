import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_bn.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('bn'),
    Locale('en'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Howlader Field'**
  String get appName;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Field collection & visits'**
  String get appTagline;

  /// No description provided for @navToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get navToday;

  /// No description provided for @navCustomers.
  ///
  /// In en, this message translates to:
  /// **'Customers'**
  String get navCustomers;

  /// No description provided for @navMap.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get navMap;

  /// No description provided for @navMe.
  ///
  /// In en, this message translates to:
  /// **'Me'**
  String get navMe;

  /// No description provided for @actionCollect.
  ///
  /// In en, this message translates to:
  /// **'Collect'**
  String get actionCollect;

  /// No description provided for @actionVisit.
  ///
  /// In en, this message translates to:
  /// **'Visit'**
  String get actionVisit;

  /// No description provided for @actionPromise.
  ///
  /// In en, this message translates to:
  /// **'Promise'**
  String get actionPromise;

  /// No description provided for @actionNote.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get actionNote;

  /// No description provided for @actionCall.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get actionCall;

  /// No description provided for @actionNavigate.
  ///
  /// In en, this message translates to:
  /// **'Navigate'**
  String get actionNavigate;

  /// No description provided for @actionDetails.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get actionDetails;

  /// No description provided for @actionSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get actionSave;

  /// No description provided for @actionCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get actionCancel;

  /// No description provided for @actionContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get actionContinue;

  /// No description provided for @actionBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get actionBack;

  /// No description provided for @actionDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get actionDone;

  /// No description provided for @actionRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get actionRetry;

  /// No description provided for @actionSyncNow.
  ///
  /// In en, this message translates to:
  /// **'Sync now'**
  String get actionSyncNow;

  /// No description provided for @actionAccept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get actionAccept;

  /// No description provided for @actionReject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get actionReject;

  /// No description provided for @actionUndo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get actionUndo;

  /// No description provided for @actionChange.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get actionChange;

  /// No description provided for @actionSeeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get actionSeeAll;

  /// No description provided for @actionShareReceipt.
  ///
  /// In en, this message translates to:
  /// **'Share receipt'**
  String get actionShareReceipt;

  /// No description provided for @actionNewPromise.
  ///
  /// In en, this message translates to:
  /// **'New promise'**
  String get actionNewPromise;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Use the phone number and password from your branch manager'**
  String get loginSubtitle;

  /// No description provided for @loginPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get loginPhone;

  /// No description provided for @loginPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get loginPassword;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get loginButton;

  /// No description provided for @loginErrorInvalid.
  ///
  /// In en, this message translates to:
  /// **'Phone number or password is wrong'**
  String get loginErrorInvalid;

  /// No description provided for @loginErrorNetwork.
  ///
  /// In en, this message translates to:
  /// **'No internet. The first sign-in needs internet.'**
  String get loginErrorNetwork;

  /// No description provided for @loginErrorLocked.
  ///
  /// In en, this message translates to:
  /// **'Account locked. Contact your branch manager.'**
  String get loginErrorLocked;

  /// No description provided for @loginDemoHint.
  ///
  /// In en, this message translates to:
  /// **'Demo: 01712345678 / demo1234'**
  String get loginDemoHint;

  /// No description provided for @showPassword.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get showPassword;

  /// No description provided for @hidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get hidePassword;

  /// No description provided for @changePasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Set a new password'**
  String get changePasswordTitle;

  /// No description provided for @changePasswordBody.
  ///
  /// In en, this message translates to:
  /// **'For your security, choose a new password before you start.'**
  String get changePasswordBody;

  /// No description provided for @changePasswordCurrent.
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get changePasswordCurrent;

  /// No description provided for @changePasswordNew.
  ///
  /// In en, this message translates to:
  /// **'New password (at least 8 characters)'**
  String get changePasswordNew;

  /// No description provided for @changePasswordConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm new password'**
  String get changePasswordConfirm;

  /// No description provided for @changePasswordMismatch.
  ///
  /// In en, this message translates to:
  /// **'The two passwords do not match'**
  String get changePasswordMismatch;

  /// No description provided for @changePasswordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Use at least 8 characters'**
  String get changePasswordTooShort;

  /// No description provided for @changePasswordWrong.
  ///
  /// In en, this message translates to:
  /// **'Current password is wrong'**
  String get changePasswordWrong;

  /// No description provided for @changePasswordOnline.
  ///
  /// In en, this message translates to:
  /// **'Changing the password needs internet'**
  String get changePasswordOnline;

  /// No description provided for @pinSetupTitle.
  ///
  /// In en, this message translates to:
  /// **'Set a 4-digit PIN'**
  String get pinSetupTitle;

  /// No description provided for @pinSetupBody.
  ///
  /// In en, this message translates to:
  /// **'You will use this PIN to open the app quickly. It stays on this phone.'**
  String get pinSetupBody;

  /// No description provided for @pinConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the PIN again'**
  String get pinConfirmTitle;

  /// No description provided for @pinMismatch.
  ///
  /// In en, this message translates to:
  /// **'PINs did not match. Try again.'**
  String get pinMismatch;

  /// No description provided for @pinWeak.
  ///
  /// In en, this message translates to:
  /// **'Too easy to guess. Avoid 1234 or 1111.'**
  String get pinWeak;

  /// No description provided for @pinUnlockTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your PIN'**
  String get pinUnlockTitle;

  /// No description provided for @pinUnlockGreeting.
  ///
  /// In en, this message translates to:
  /// **'Welcome back, {name}'**
  String pinUnlockGreeting(String name);

  /// No description provided for @pinWrong.
  ///
  /// In en, this message translates to:
  /// **'Wrong PIN. {left} tries left.'**
  String pinWrong(int left);

  /// No description provided for @pinLockedOut.
  ///
  /// In en, this message translates to:
  /// **'Too many wrong PINs. Sign in with your password. Your saved work is safe.'**
  String get pinLockedOut;

  /// No description provided for @pinForgot.
  ///
  /// In en, this message translates to:
  /// **'Forgot PIN? Sign in with password'**
  String get pinForgot;

  /// No description provided for @keypadBackspace.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get keypadBackspace;

  /// No description provided for @keypadClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get keypadClear;

  /// No description provided for @consentTitle.
  ///
  /// In en, this message translates to:
  /// **'What this app records'**
  String get consentTitle;

  /// No description provided for @consentIntro.
  ///
  /// In en, this message translates to:
  /// **'Please read this before you start work.'**
  String get consentIntro;

  /// No description provided for @consentDutyOnly.
  ///
  /// In en, this message translates to:
  /// **'Location is recorded only while you are on duty (from work-in to work-out). Never outside duty hours.'**
  String get consentDutyOnly;

  /// No description provided for @consentWhy.
  ///
  /// In en, this message translates to:
  /// **'It is used to show visits on the map, confirm collections and plan routes.'**
  String get consentWhy;

  /// No description provided for @consentVisible.
  ///
  /// In en, this message translates to:
  /// **'When tracking is on you will always see a notification and a status chip.'**
  String get consentVisible;

  /// No description provided for @consentPhotos.
  ///
  /// In en, this message translates to:
  /// **'Photos are taken only with the camera, with date, time and place.'**
  String get consentPhotos;

  /// No description provided for @consentRetention.
  ///
  /// In en, this message translates to:
  /// **'Location points are deleted after 90 days.'**
  String get consentRetention;

  /// No description provided for @consentAgree.
  ///
  /// In en, this message translates to:
  /// **'I understand and agree'**
  String get consentAgree;

  /// No description provided for @consentVersion.
  ///
  /// In en, this message translates to:
  /// **'Privacy notice {version}'**
  String consentVersion(String version);

  /// No description provided for @primerTitle.
  ///
  /// In en, this message translates to:
  /// **'Allow these on your phone'**
  String get primerTitle;

  /// No description provided for @primerBody.
  ///
  /// In en, this message translates to:
  /// **'The app needs a few permissions to work in the field.'**
  String get primerBody;

  /// No description provided for @primerLocation.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get primerLocation;

  /// No description provided for @primerLocationBody.
  ///
  /// In en, this message translates to:
  /// **'To attach your position to collections and visits, and to share it while you are on duty. \"While using the app\" is enough: a visible notification keeps tracking on with the screen off.'**
  String get primerLocationBody;

  /// No description provided for @primerCamera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get primerCamera;

  /// No description provided for @primerCameraBody.
  ///
  /// In en, this message translates to:
  /// **'For visit and deposit-slip photos. The gallery is never used.'**
  String get primerCameraBody;

  /// No description provided for @primerNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get primerNotifications;

  /// No description provided for @primerNotificationsBody.
  ///
  /// In en, this message translates to:
  /// **'For promise reminders and messages from your manager.'**
  String get primerNotificationsBody;

  /// No description provided for @primerBattery.
  ///
  /// In en, this message translates to:
  /// **'Battery optimisation'**
  String get primerBattery;

  /// No description provided for @primerBatteryBody.
  ///
  /// In en, this message translates to:
  /// **'Some phones stop apps in the background. We will show you how to keep this app running during duty.'**
  String get primerBatteryBody;

  /// No description provided for @primerAllow.
  ///
  /// In en, this message translates to:
  /// **'Allow'**
  String get primerAllow;

  /// No description provided for @primerAllowed.
  ///
  /// In en, this message translates to:
  /// **'Allowed'**
  String get primerAllowed;

  /// No description provided for @primerLater.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get primerLater;

  /// No description provided for @bootstrapTitle.
  ///
  /// In en, this message translates to:
  /// **'Getting your customers'**
  String get bootstrapTitle;

  /// No description provided for @bootstrapBody.
  ///
  /// In en, this message translates to:
  /// **'Downloading your assigned customers so you can work offline.'**
  String get bootstrapBody;

  /// No description provided for @bootstrapFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not download. Check internet and try again.'**
  String get bootstrapFailed;

  /// No description provided for @greetingMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning, {name}'**
  String greetingMorning(String name);

  /// No description provided for @greetingAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon, {name}'**
  String greetingAfternoon(String name);

  /// No description provided for @greetingEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening, {name}'**
  String greetingEvening(String name);

  /// No description provided for @syncSynced.
  ///
  /// In en, this message translates to:
  /// **'Synced'**
  String get syncSynced;

  /// No description provided for @syncSyncing.
  ///
  /// In en, this message translates to:
  /// **'Syncing…'**
  String get syncSyncing;

  /// No description provided for @syncQueued.
  ///
  /// In en, this message translates to:
  /// **'{count} waiting'**
  String syncQueued(String count);

  /// No description provided for @syncProblems.
  ///
  /// In en, this message translates to:
  /// **'{count} problems'**
  String syncProblems(String count);

  /// No description provided for @syncOffline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get syncOffline;

  /// No description provided for @savedOnPhone.
  ///
  /// In en, this message translates to:
  /// **'Saved on phone · will sync'**
  String get savedOnPhone;

  /// No description provided for @reachedServer.
  ///
  /// In en, this message translates to:
  /// **'Reached the server'**
  String get reachedServer;

  /// No description provided for @dutyOff.
  ///
  /// In en, this message translates to:
  /// **'Off duty'**
  String get dutyOff;

  /// No description provided for @dutyOn.
  ///
  /// In en, this message translates to:
  /// **'On duty'**
  String get dutyOn;

  /// No description provided for @dutyOnSince.
  ///
  /// In en, this message translates to:
  /// **'On duty · since {time}'**
  String dutyOnSince(String time);

  /// No description provided for @dutyOnBreak.
  ///
  /// In en, this message translates to:
  /// **'On break'**
  String get dutyOnBreak;

  /// No description provided for @dutyBreakSince.
  ///
  /// In en, this message translates to:
  /// **'On break · {duration}'**
  String dutyBreakSince(String duration);

  /// No description provided for @dutyTracking.
  ///
  /// In en, this message translates to:
  /// **'Tracking on'**
  String get dutyTracking;

  /// No description provided for @dutyStartWork.
  ///
  /// In en, this message translates to:
  /// **'Start work'**
  String get dutyStartWork;

  /// No description provided for @dutyEndWork.
  ///
  /// In en, this message translates to:
  /// **'End work'**
  String get dutyEndWork;

  /// No description provided for @dutyStartBreak.
  ///
  /// In en, this message translates to:
  /// **'Start break'**
  String get dutyStartBreak;

  /// No description provided for @dutyEndBreak.
  ///
  /// In en, this message translates to:
  /// **'End break'**
  String get dutyEndBreak;

  /// No description provided for @dutyNotStarted.
  ///
  /// In en, this message translates to:
  /// **'You have not started work today'**
  String get dutyNotStarted;

  /// No description provided for @dutyEnded.
  ///
  /// In en, this message translates to:
  /// **'Work ended at {time}'**
  String dutyEnded(String time);

  /// No description provided for @todayCollected.
  ///
  /// In en, this message translates to:
  /// **'Collected today'**
  String get todayCollected;

  /// No description provided for @todayOfTarget.
  ///
  /// In en, this message translates to:
  /// **'of {target}'**
  String todayOfTarget(String target);

  /// No description provided for @todayVisits.
  ///
  /// In en, this message translates to:
  /// **'Visits'**
  String get todayVisits;

  /// No description provided for @todayCashOnHand.
  ///
  /// In en, this message translates to:
  /// **'Cash on hand'**
  String get todayCashOnHand;

  /// No description provided for @todayProblemsBanner.
  ///
  /// In en, this message translates to:
  /// **'{count} problems need your attention'**
  String todayProblemsBanner(String count);

  /// No description provided for @todayHandoverBanner.
  ///
  /// In en, this message translates to:
  /// **'{name} is handing customers to you'**
  String todayHandoverBanner(String name);

  /// No description provided for @todayPromisedSection.
  ///
  /// In en, this message translates to:
  /// **'Promised today'**
  String get todayPromisedSection;

  /// No description provided for @todayDueSection.
  ///
  /// In en, this message translates to:
  /// **'Due today'**
  String get todayDueSection;

  /// No description provided for @todayOverdueSection.
  ///
  /// In en, this message translates to:
  /// **'Overdue · nearest first'**
  String get todayOverdueSection;

  /// No description provided for @todayAllDone.
  ///
  /// In en, this message translates to:
  /// **'All caught up'**
  String get todayAllDone;

  /// No description provided for @todayAllDoneBody.
  ///
  /// In en, this message translates to:
  /// **'No promises or dues left for today.'**
  String get todayAllDoneBody;

  /// No description provided for @todayCashWarning.
  ///
  /// In en, this message translates to:
  /// **'Cash on hand is {pct}% of your limit. Please deposit soon.'**
  String todayCashWarning(String pct);

  /// No description provided for @customersTitle.
  ///
  /// In en, this message translates to:
  /// **'Customers'**
  String get customersTitle;

  /// No description provided for @customersSearch.
  ///
  /// In en, this message translates to:
  /// **'Search name, phone or code'**
  String get customersSearch;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @filterDueToday.
  ///
  /// In en, this message translates to:
  /// **'Due today'**
  String get filterDueToday;

  /// No description provided for @filterOverdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get filterOverdue;

  /// No description provided for @filterPromisedToday.
  ///
  /// In en, this message translates to:
  /// **'Promised today'**
  String get filterPromisedToday;

  /// No description provided for @filterMine.
  ///
  /// In en, this message translates to:
  /// **'Mine'**
  String get filterMine;

  /// No description provided for @filterBadSuggested.
  ///
  /// In en, this message translates to:
  /// **'Possibly bad'**
  String get filterBadSuggested;

  /// No description provided for @filterTagged.
  ///
  /// In en, this message translates to:
  /// **'Tagged'**
  String get filterTagged;

  /// No description provided for @filterNoPin.
  ///
  /// In en, this message translates to:
  /// **'No pin'**
  String get filterNoPin;

  /// No description provided for @sortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get sortBy;

  /// No description provided for @sortDistance.
  ///
  /// In en, this message translates to:
  /// **'Nearest'**
  String get sortDistance;

  /// No description provided for @sortDaysOverdue.
  ///
  /// In en, this message translates to:
  /// **'Most overdue'**
  String get sortDaysOverdue;

  /// No description provided for @sortAmount.
  ///
  /// In en, this message translates to:
  /// **'Highest balance'**
  String get sortAmount;

  /// No description provided for @sortName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get sortName;

  /// No description provided for @customersEmpty.
  ///
  /// In en, this message translates to:
  /// **'No customers match'**
  String get customersEmpty;

  /// No description provided for @customersEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Try another filter or search.'**
  String get customersEmptyBody;

  /// No description provided for @customersCount.
  ///
  /// In en, this message translates to:
  /// **'{count} customers'**
  String customersCount(String count);

  /// No description provided for @statusOverdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get statusOverdue;

  /// No description provided for @statusOverdueDays.
  ///
  /// In en, this message translates to:
  /// **'{days} days overdue'**
  String statusOverdueDays(String days);

  /// No description provided for @statusDueToday.
  ///
  /// In en, this message translates to:
  /// **'Due today'**
  String get statusDueToday;

  /// No description provided for @statusPromised.
  ///
  /// In en, this message translates to:
  /// **'Promised'**
  String get statusPromised;

  /// No description provided for @statusCurrent.
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get statusCurrent;

  /// No description provided for @statusPaid.
  ///
  /// In en, this message translates to:
  /// **'Paid up'**
  String get statusPaid;

  /// No description provided for @statusBadSuggested.
  ///
  /// In en, this message translates to:
  /// **'Possibly bad'**
  String get statusBadSuggested;

  /// No description provided for @statusTagged.
  ///
  /// In en, this message translates to:
  /// **'Tagged'**
  String get statusTagged;

  /// No description provided for @statusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get statusPending;

  /// No description provided for @statusMock.
  ///
  /// In en, this message translates to:
  /// **'Fake GPS'**
  String get statusMock;

  /// No description provided for @statusQueued.
  ///
  /// In en, this message translates to:
  /// **'On phone'**
  String get statusQueued;

  /// No description provided for @statusSent.
  ///
  /// In en, this message translates to:
  /// **'Waiting for ERP'**
  String get statusSent;

  /// No description provided for @statusPosted.
  ///
  /// In en, this message translates to:
  /// **'Posted'**
  String get statusPosted;

  /// No description provided for @statusConflict.
  ///
  /// In en, this message translates to:
  /// **'Manager is reviewing'**
  String get statusConflict;

  /// No description provided for @statusRejected.
  ///
  /// In en, this message translates to:
  /// **'Not accepted'**
  String get statusRejected;

  /// No description provided for @statusResolved.
  ///
  /// In en, this message translates to:
  /// **'Resolved'**
  String get statusResolved;

  /// No description provided for @statusVoided.
  ///
  /// In en, this message translates to:
  /// **'Voided'**
  String get statusVoided;

  /// No description provided for @detailOutstanding.
  ///
  /// In en, this message translates to:
  /// **'Total outstanding'**
  String get detailOutstanding;

  /// No description provided for @detailAsOfErp.
  ///
  /// In en, this message translates to:
  /// **'As per ERP · {time}'**
  String detailAsOfErp(String time);

  /// No description provided for @detailPendingField.
  ///
  /// In en, this message translates to:
  /// **'Your {amount} is waiting to post in ERP'**
  String detailPendingField(String amount);

  /// No description provided for @detailPlans.
  ///
  /// In en, this message translates to:
  /// **'Plans'**
  String get detailPlans;

  /// No description provided for @detailInstallment.
  ///
  /// In en, this message translates to:
  /// **'Installment'**
  String get detailInstallment;

  /// No description provided for @detailInstallments.
  ///
  /// In en, this message translates to:
  /// **'{paid} of {total} paid'**
  String detailInstallments(String paid, String total);

  /// No description provided for @detailFinalDue.
  ///
  /// In en, this message translates to:
  /// **'Final due {date}'**
  String detailFinalDue(String date);

  /// No description provided for @detailSchedule.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get detailSchedule;

  /// No description provided for @detailTimeline.
  ///
  /// In en, this message translates to:
  /// **'Timeline'**
  String get detailTimeline;

  /// No description provided for @detailNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get detailNotes;

  /// No description provided for @detailVisits.
  ///
  /// In en, this message translates to:
  /// **'Visits'**
  String get detailVisits;

  /// No description provided for @detailPromises.
  ///
  /// In en, this message translates to:
  /// **'Promises'**
  String get detailPromises;

  /// No description provided for @detailGuarantor.
  ///
  /// In en, this message translates to:
  /// **'Guarantor'**
  String get detailGuarantor;

  /// No description provided for @detailNoPin.
  ///
  /// In en, this message translates to:
  /// **'No map pin for this customer'**
  String get detailNoPin;

  /// No description provided for @detailBadSuggestion.
  ///
  /// In en, this message translates to:
  /// **'Possibly bad customer'**
  String get detailBadSuggestion;

  /// No description provided for @detailBadSuggestionBody.
  ///
  /// In en, this message translates to:
  /// **'Final due date passed on {date} with {amount} outstanding. This is only a suggestion.'**
  String detailBadSuggestionBody(String date, String amount);

  /// No description provided for @detailTaggedBy.
  ///
  /// In en, this message translates to:
  /// **'Tagged by {name}: {reason}'**
  String detailTaggedBy(String name, String reason);

  /// No description provided for @detailOpenPromise.
  ///
  /// In en, this message translates to:
  /// **'Promised {amount} on {date}'**
  String detailOpenPromise(String amount, String date);

  /// No description provided for @detailNothingYet.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet'**
  String get detailNothingYet;

  /// No description provided for @scheduleDue.
  ///
  /// In en, this message translates to:
  /// **'Due'**
  String get scheduleDue;

  /// No description provided for @schedulePaid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get schedulePaid;

  /// No description provided for @scheduleOverdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get scheduleOverdue;

  /// No description provided for @scheduleUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get scheduleUpcoming;

  /// No description provided for @schedulePartial.
  ///
  /// In en, this message translates to:
  /// **'Partly paid'**
  String get schedulePartial;

  /// No description provided for @timelineErpPayment.
  ///
  /// In en, this message translates to:
  /// **'Paid {amount} at {source}'**
  String timelineErpPayment(String amount, String source);

  /// No description provided for @timelineOffice.
  ///
  /// In en, this message translates to:
  /// **'office'**
  String get timelineOffice;

  /// No description provided for @timelineField.
  ///
  /// In en, this message translates to:
  /// **'field'**
  String get timelineField;

  /// No description provided for @timelineCollection.
  ///
  /// In en, this message translates to:
  /// **'Collected {amount}'**
  String timelineCollection(String amount);

  /// No description provided for @timelineVisit.
  ///
  /// In en, this message translates to:
  /// **'Visit · {outcome}'**
  String timelineVisit(String outcome);

  /// No description provided for @timelinePromise.
  ///
  /// In en, this message translates to:
  /// **'Promise {amount} for {date}'**
  String timelinePromise(String amount, String date);

  /// No description provided for @collectTitle.
  ///
  /// In en, this message translates to:
  /// **'Collect payment'**
  String get collectTitle;

  /// No description provided for @collectStepAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get collectStepAmount;

  /// No description provided for @collectStepMethod.
  ///
  /// In en, this message translates to:
  /// **'Method'**
  String get collectStepMethod;

  /// No description provided for @collectStepReview.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get collectStepReview;

  /// No description provided for @collectChipInstallment.
  ///
  /// In en, this message translates to:
  /// **'Installment {amount}'**
  String collectChipInstallment(String amount);

  /// No description provided for @collectChipOverdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue {amount}'**
  String collectChipOverdue(String amount);

  /// No description provided for @collectChipPromise.
  ///
  /// In en, this message translates to:
  /// **'Promise {amount}'**
  String collectChipPromise(String amount);

  /// No description provided for @collectOverOutstanding.
  ///
  /// In en, this message translates to:
  /// **'More than the outstanding balance. It will be flagged for review.'**
  String get collectOverOutstanding;

  /// No description provided for @collectEnterAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter amount'**
  String get collectEnterAmount;

  /// No description provided for @collectMethodCash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get collectMethodCash;

  /// No description provided for @collectMethodBkash.
  ///
  /// In en, this message translates to:
  /// **'bKash'**
  String get collectMethodBkash;

  /// No description provided for @collectMethodNagad.
  ///
  /// In en, this message translates to:
  /// **'Nagad'**
  String get collectMethodNagad;

  /// No description provided for @collectMethodRocket.
  ///
  /// In en, this message translates to:
  /// **'Rocket'**
  String get collectMethodRocket;

  /// No description provided for @collectMethodBank.
  ///
  /// In en, this message translates to:
  /// **'Bank'**
  String get collectMethodBank;

  /// No description provided for @collectMethodOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get collectMethodOther;

  /// No description provided for @collectTxnId.
  ///
  /// In en, this message translates to:
  /// **'Transaction ID'**
  String get collectTxnId;

  /// No description provided for @collectTxnInvalid.
  ///
  /// In en, this message translates to:
  /// **'Check the transaction ID (letters and numbers, 8–20)'**
  String get collectTxnInvalid;

  /// No description provided for @collectPhysicalReceipt.
  ///
  /// In en, this message translates to:
  /// **'Paper receipt no. (optional)'**
  String get collectPhysicalReceipt;

  /// No description provided for @collectPayerName.
  ///
  /// In en, this message translates to:
  /// **'Paid by (if not the customer)'**
  String get collectPayerName;

  /// No description provided for @collectNote.
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get collectNote;

  /// No description provided for @collectReviewCustomer.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get collectReviewCustomer;

  /// No description provided for @collectReviewPlan.
  ///
  /// In en, this message translates to:
  /// **'Plan'**
  String get collectReviewPlan;

  /// No description provided for @collectReviewAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get collectReviewAmount;

  /// No description provided for @collectReviewMethod.
  ///
  /// In en, this message translates to:
  /// **'Method'**
  String get collectReviewMethod;

  /// No description provided for @collectReviewReceipt.
  ///
  /// In en, this message translates to:
  /// **'Receipt no.'**
  String get collectReviewReceipt;

  /// No description provided for @collectGpsAccurate.
  ///
  /// In en, this message translates to:
  /// **'Location {meters} m accurate'**
  String collectGpsAccurate(String meters);

  /// No description provided for @collectGpsSearching.
  ///
  /// In en, this message translates to:
  /// **'Finding location…'**
  String get collectGpsSearching;

  /// No description provided for @collectGpsNone.
  ///
  /// In en, this message translates to:
  /// **'No location. It will be saved and flagged.'**
  String get collectGpsNone;

  /// No description provided for @collectGpsMock.
  ///
  /// In en, this message translates to:
  /// **'Fake location detected. It will be flagged.'**
  String get collectGpsMock;

  /// No description provided for @collectHoldToConfirm.
  ///
  /// In en, this message translates to:
  /// **'Hold to confirm'**
  String get collectHoldToConfirm;

  /// No description provided for @collectHoldHint.
  ///
  /// In en, this message translates to:
  /// **'Keep holding…'**
  String get collectHoldHint;

  /// No description provided for @collectSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Collection saved'**
  String get collectSuccessTitle;

  /// No description provided for @collectCashLimitBlocked.
  ///
  /// In en, this message translates to:
  /// **'Cash on hand is over your limit. Deposit cash before collecting more.'**
  String get collectCashLimitBlocked;

  /// No description provided for @collectNoReceipts.
  ///
  /// In en, this message translates to:
  /// **'No receipt numbers left. Connect to the internet once.'**
  String get collectNoReceipts;

  /// No description provided for @collectOfflineReceipt.
  ///
  /// In en, this message translates to:
  /// **'Offline receipt number used. It will be reviewed.'**
  String get collectOfflineReceipt;

  /// No description provided for @receiptTitle.
  ///
  /// In en, this message translates to:
  /// **'Field receipt'**
  String get receiptTitle;

  /// No description provided for @receiptPendingErp.
  ///
  /// In en, this message translates to:
  /// **'Waiting to post in ERP'**
  String get receiptPendingErp;

  /// No description provided for @receiptCollector.
  ///
  /// In en, this message translates to:
  /// **'Collected by'**
  String get receiptCollector;

  /// No description provided for @receiptHotline.
  ///
  /// In en, this message translates to:
  /// **'Hotline'**
  String get receiptHotline;

  /// No description provided for @visitTitle.
  ///
  /// In en, this message translates to:
  /// **'Visit check-in'**
  String get visitTitle;

  /// No description provided for @visitOutcome.
  ///
  /// In en, this message translates to:
  /// **'What happened?'**
  String get visitOutcome;

  /// No description provided for @visitOutcomePaid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get visitOutcomePaid;

  /// No description provided for @visitOutcomePartial.
  ///
  /// In en, this message translates to:
  /// **'Paid part'**
  String get visitOutcomePartial;

  /// No description provided for @visitOutcomePromised.
  ///
  /// In en, this message translates to:
  /// **'Promised'**
  String get visitOutcomePromised;

  /// No description provided for @visitOutcomeNotHome.
  ///
  /// In en, this message translates to:
  /// **'Not at home'**
  String get visitOutcomeNotHome;

  /// No description provided for @visitOutcomeRefused.
  ///
  /// In en, this message translates to:
  /// **'Refused'**
  String get visitOutcomeRefused;

  /// No description provided for @visitOutcomeShifted.
  ///
  /// In en, this message translates to:
  /// **'Moved address'**
  String get visitOutcomeShifted;

  /// No description provided for @visitOutcomeDead.
  ///
  /// In en, this message translates to:
  /// **'Customer died'**
  String get visitOutcomeDead;

  /// No description provided for @visitOutcomeReturn.
  ///
  /// In en, this message translates to:
  /// **'Wants to return product'**
  String get visitOutcomeReturn;

  /// No description provided for @visitOutcomeOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get visitOutcomeOther;

  /// No description provided for @visitTakePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take photo'**
  String get visitTakePhoto;

  /// No description provided for @visitRetake.
  ///
  /// In en, this message translates to:
  /// **'Retake'**
  String get visitRetake;

  /// No description provided for @visitPhotoAdded.
  ///
  /// In en, this message translates to:
  /// **'Photo added'**
  String get visitPhotoAdded;

  /// No description provided for @visitCameraOnly.
  ///
  /// In en, this message translates to:
  /// **'Camera only. The gallery cannot be used.'**
  String get visitCameraOnly;

  /// No description provided for @visitSaved.
  ///
  /// In en, this message translates to:
  /// **'Visit saved'**
  String get visitSaved;

  /// No description provided for @visitFar.
  ///
  /// In en, this message translates to:
  /// **'You are {distance} from the customer pin'**
  String visitFar(String distance);

  /// No description provided for @promiseTitle.
  ///
  /// In en, this message translates to:
  /// **'Promise to pay'**
  String get promiseTitle;

  /// No description provided for @promiseDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get promiseDate;

  /// No description provided for @promiseAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get promiseAmount;

  /// No description provided for @promiseToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get promiseToday;

  /// No description provided for @promiseTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get promiseTomorrow;

  /// No description provided for @promiseIn3.
  ///
  /// In en, this message translates to:
  /// **'In 3 days'**
  String get promiseIn3;

  /// No description provided for @promiseIn7.
  ///
  /// In en, this message translates to:
  /// **'In 7 days'**
  String get promiseIn7;

  /// No description provided for @promisePickDate.
  ///
  /// In en, this message translates to:
  /// **'Pick date'**
  String get promisePickDate;

  /// No description provided for @promiseReminder.
  ///
  /// In en, this message translates to:
  /// **'You will get a reminder at 9:00 AM that day.'**
  String get promiseReminder;

  /// No description provided for @promiseSaved.
  ///
  /// In en, this message translates to:
  /// **'Promise saved'**
  String get promiseSaved;

  /// No description provided for @noteTitle.
  ///
  /// In en, this message translates to:
  /// **'Add note'**
  String get noteTitle;

  /// No description provided for @noteHint.
  ///
  /// In en, this message translates to:
  /// **'Write what happened…'**
  String get noteHint;

  /// No description provided for @noteCategory.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get noteCategory;

  /// No description provided for @noteCatGeneral.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get noteCatGeneral;

  /// No description provided for @noteCatAddress.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get noteCatAddress;

  /// No description provided for @noteCatFamily.
  ///
  /// In en, this message translates to:
  /// **'Family'**
  String get noteCatFamily;

  /// No description provided for @noteCatPayment.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get noteCatPayment;

  /// No description provided for @noteSaved.
  ///
  /// In en, this message translates to:
  /// **'Note saved'**
  String get noteSaved;

  /// No description provided for @tagTitle.
  ///
  /// In en, this message translates to:
  /// **'Tag as bad customer'**
  String get tagTitle;

  /// No description provided for @untagTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove tag'**
  String get untagTitle;

  /// No description provided for @tagReason.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get tagReason;

  /// No description provided for @tagReasonLongOverdue.
  ///
  /// In en, this message translates to:
  /// **'Long overdue'**
  String get tagReasonLongOverdue;

  /// No description provided for @tagReasonAbsconded.
  ///
  /// In en, this message translates to:
  /// **'Absconded'**
  String get tagReasonAbsconded;

  /// No description provided for @tagReasonRefuses.
  ///
  /// In en, this message translates to:
  /// **'Refuses to pay'**
  String get tagReasonRefuses;

  /// No description provided for @tagReasonOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get tagReasonOther;

  /// No description provided for @tagReasonHint.
  ///
  /// In en, this message translates to:
  /// **'Explain (at least 10 characters)'**
  String get tagReasonHint;

  /// No description provided for @tagSaved.
  ///
  /// In en, this message translates to:
  /// **'Tag saved · manager will review'**
  String get tagSaved;

  /// No description provided for @meTitle.
  ///
  /// In en, this message translates to:
  /// **'Me'**
  String get meTitle;

  /// No description provided for @meAttendance.
  ///
  /// In en, this message translates to:
  /// **'Attendance'**
  String get meAttendance;

  /// No description provided for @meCash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get meCash;

  /// No description provided for @meHandovers.
  ///
  /// In en, this message translates to:
  /// **'Handovers'**
  String get meHandovers;

  /// No description provided for @meSyncCentre.
  ///
  /// In en, this message translates to:
  /// **'Sync centre'**
  String get meSyncCentre;

  /// No description provided for @meSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get meSettings;

  /// No description provided for @meLogout.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get meLogout;

  /// No description provided for @meInToday.
  ///
  /// In en, this message translates to:
  /// **'In {time}'**
  String meInToday(String time);

  /// No description provided for @meBreakTotal.
  ///
  /// In en, this message translates to:
  /// **'Break {duration}'**
  String meBreakTotal(String duration);

  /// No description provided for @meLate.
  ///
  /// In en, this message translates to:
  /// **'Late {minutes} min'**
  String meLate(String minutes);

  /// No description provided for @cashOnHand.
  ///
  /// In en, this message translates to:
  /// **'On hand'**
  String get cashOnHand;

  /// No description provided for @cashLimit.
  ///
  /// In en, this message translates to:
  /// **'Limit {amount}'**
  String cashLimit(String amount);

  /// No description provided for @cashDeposit.
  ///
  /// In en, this message translates to:
  /// **'Record deposit'**
  String get cashDeposit;

  /// No description provided for @cashDepositTitle.
  ///
  /// In en, this message translates to:
  /// **'Cash deposit'**
  String get cashDepositTitle;

  /// No description provided for @cashDepositTo.
  ///
  /// In en, this message translates to:
  /// **'Deposited to'**
  String get cashDepositTo;

  /// No description provided for @cashDestCashier.
  ///
  /// In en, this message translates to:
  /// **'Branch cashier'**
  String get cashDestCashier;

  /// No description provided for @cashDestBank.
  ///
  /// In en, this message translates to:
  /// **'Bank'**
  String get cashDestBank;

  /// No description provided for @cashDestManager.
  ///
  /// In en, this message translates to:
  /// **'Manager'**
  String get cashDestManager;

  /// No description provided for @cashReference.
  ///
  /// In en, this message translates to:
  /// **'Reference / slip no.'**
  String get cashReference;

  /// No description provided for @cashDepositSaved.
  ///
  /// In en, this message translates to:
  /// **'Deposit saved · waiting for verification'**
  String get cashDepositSaved;

  /// No description provided for @cashDeposits.
  ///
  /// In en, this message translates to:
  /// **'Deposits'**
  String get cashDeposits;

  /// No description provided for @cashNoDeposits.
  ///
  /// In en, this message translates to:
  /// **'No deposits yet'**
  String get cashNoDeposits;

  /// No description provided for @cashTodayCash.
  ///
  /// In en, this message translates to:
  /// **'Cash today'**
  String get cashTodayCash;

  /// No description provided for @cashTodayMobile.
  ///
  /// In en, this message translates to:
  /// **'Mobile today'**
  String get cashTodayMobile;

  /// No description provided for @syncCentreTitle.
  ///
  /// In en, this message translates to:
  /// **'Sync centre'**
  String get syncCentreTitle;

  /// No description provided for @syncLastSuccess.
  ///
  /// In en, this message translates to:
  /// **'Last synced {time}'**
  String syncLastSuccess(String time);

  /// No description provided for @syncNever.
  ///
  /// In en, this message translates to:
  /// **'Not synced yet'**
  String get syncNever;

  /// No description provided for @syncOldest.
  ///
  /// In en, this message translates to:
  /// **'Oldest waiting item: {time}'**
  String syncOldest(String time);

  /// No description provided for @syncWaitingTitle.
  ///
  /// In en, this message translates to:
  /// **'Waiting to upload'**
  String get syncWaitingTitle;

  /// No description provided for @syncNothingWaiting.
  ///
  /// In en, this message translates to:
  /// **'Everything is uploaded'**
  String get syncNothingWaiting;

  /// No description provided for @syncProblemsTitle.
  ///
  /// In en, this message translates to:
  /// **'Problems'**
  String get syncProblemsTitle;

  /// No description provided for @syncNoProblems.
  ///
  /// In en, this message translates to:
  /// **'No problems'**
  String get syncNoProblems;

  /// No description provided for @syncProblemManager.
  ///
  /// In en, this message translates to:
  /// **'Your manager has been notified.'**
  String get syncProblemManager;

  /// No description provided for @syncProblemMoneyHint.
  ///
  /// In en, this message translates to:
  /// **'Money items are never deleted. Contact your manager.'**
  String get syncProblemMoneyHint;

  /// No description provided for @syncEntityCollection.
  ///
  /// In en, this message translates to:
  /// **'Collections'**
  String get syncEntityCollection;

  /// No description provided for @syncEntityVisit.
  ///
  /// In en, this message translates to:
  /// **'Visits'**
  String get syncEntityVisit;

  /// No description provided for @syncEntityNote.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get syncEntityNote;

  /// No description provided for @syncEntityPromise.
  ///
  /// In en, this message translates to:
  /// **'Promises'**
  String get syncEntityPromise;

  /// No description provided for @syncEntityDeposit.
  ///
  /// In en, this message translates to:
  /// **'Deposits'**
  String get syncEntityDeposit;

  /// No description provided for @syncEntityAttendance.
  ///
  /// In en, this message translates to:
  /// **'Attendance'**
  String get syncEntityAttendance;

  /// No description provided for @syncEntityTag.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get syncEntityTag;

  /// No description provided for @syncEntityOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get syncEntityOther;

  /// No description provided for @syncDetails.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get syncDetails;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsDigits.
  ///
  /// In en, this message translates to:
  /// **'Numbers'**
  String get settingsDigits;

  /// No description provided for @settingsDigitsBn.
  ///
  /// In en, this message translates to:
  /// **'বাংলা ১২৩'**
  String get settingsDigitsBn;

  /// No description provided for @settingsDigitsEn.
  ///
  /// In en, this message translates to:
  /// **'English 123'**
  String get settingsDigitsEn;

  /// No description provided for @settingsTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTheme;

  /// No description provided for @settingsThemeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settingsThemeSystem;

  /// No description provided for @settingsThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsThemeDark;

  /// No description provided for @settingsHighContrast.
  ///
  /// In en, this message translates to:
  /// **'High contrast (for sunlight)'**
  String get settingsHighContrast;

  /// No description provided for @settingsPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy notice'**
  String get settingsPrivacy;

  /// No description provided for @settingsAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsAbout;

  /// No description provided for @settingsVersion.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String settingsVersion(String version);

  /// No description provided for @logoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign out?'**
  String get logoutTitle;

  /// No description provided for @logoutBlocked.
  ///
  /// In en, this message translates to:
  /// **'{count} items are not uploaded yet. Connect to the internet and sync first. Nothing will be deleted.'**
  String logoutBlocked(String count);

  /// No description provided for @logoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'All data on this phone will be removed.'**
  String get logoutConfirm;

  /// No description provided for @handoverTitle.
  ///
  /// In en, this message translates to:
  /// **'Handover'**
  String get handoverTitle;

  /// No description provided for @handoverFrom.
  ///
  /// In en, this message translates to:
  /// **'From {name}'**
  String handoverFrom(String name);

  /// No description provided for @handoverCustomers.
  ///
  /// In en, this message translates to:
  /// **'Customers'**
  String get handoverCustomers;

  /// No description provided for @handoverOutstanding.
  ///
  /// In en, this message translates to:
  /// **'Outstanding'**
  String get handoverOutstanding;

  /// No description provided for @handoverOverdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get handoverOverdue;

  /// No description provided for @handoverOpenPromises.
  ///
  /// In en, this message translates to:
  /// **'Open promises'**
  String get handoverOpenPromises;

  /// No description provided for @handoverExpires.
  ///
  /// In en, this message translates to:
  /// **'Respond by {time}'**
  String handoverExpires(String time);

  /// No description provided for @handoverNeedsInternet.
  ///
  /// In en, this message translates to:
  /// **'Internet is needed to accept or reject'**
  String get handoverNeedsInternet;

  /// No description provided for @handoverAccepted.
  ///
  /// In en, this message translates to:
  /// **'Handover accepted'**
  String get handoverAccepted;

  /// No description provided for @handoverRejected.
  ///
  /// In en, this message translates to:
  /// **'Handover rejected'**
  String get handoverRejected;

  /// No description provided for @handoverNone.
  ///
  /// In en, this message translates to:
  /// **'No handovers'**
  String get handoverNone;

  /// No description provided for @workInTitle.
  ///
  /// In en, this message translates to:
  /// **'Start your day'**
  String get workInTitle;

  /// No description provided for @workInBody.
  ///
  /// In en, this message translates to:
  /// **'Your location is recorded from now until you end work.'**
  String get workInBody;

  /// No description provided for @workOutTitle.
  ///
  /// In en, this message translates to:
  /// **'End of day'**
  String get workOutTitle;

  /// No description provided for @workOutUnsynced.
  ///
  /// In en, this message translates to:
  /// **'{count} items not uploaded yet. They are safe on your phone and will upload when online.'**
  String workOutUnsynced(String count);

  /// No description provided for @workOutCollections.
  ///
  /// In en, this message translates to:
  /// **'Collections'**
  String get workOutCollections;

  /// No description provided for @workOutCash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get workOutCash;

  /// No description provided for @workOutMobile.
  ///
  /// In en, this message translates to:
  /// **'Mobile'**
  String get workOutMobile;

  /// No description provided for @workOutVisits.
  ///
  /// In en, this message translates to:
  /// **'Visits'**
  String get workOutVisits;

  /// No description provided for @workOutPromises.
  ///
  /// In en, this message translates to:
  /// **'Promises made'**
  String get workOutPromises;

  /// No description provided for @updateTitle.
  ///
  /// In en, this message translates to:
  /// **'Update required'**
  String get updateTitle;

  /// No description provided for @updateBody.
  ///
  /// In en, this message translates to:
  /// **'A newer version is needed. Your saved work stays on the phone and will upload after the update.'**
  String get updateBody;

  /// No description provided for @updateButton.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get updateButton;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get errorGeneric;

  /// No description provided for @errorNeedsInternet.
  ///
  /// In en, this message translates to:
  /// **'Internet required'**
  String get errorNeedsInternet;

  /// No description provided for @offlineSaved.
  ///
  /// In en, this message translates to:
  /// **'No internet — saved on phone'**
  String get offlineSaved;

  /// No description provided for @demoBanner.
  ///
  /// In en, this message translates to:
  /// **'Demo mode · sample data'**
  String get demoBanner;

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// No description provided for @actionTag.
  ///
  /// In en, this message translates to:
  /// **'Tag'**
  String get actionTag;

  /// No description provided for @actionUntag.
  ///
  /// In en, this message translates to:
  /// **'Remove tag'**
  String get actionUntag;

  /// No description provided for @tagSeverity.
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get tagSeverity;

  /// No description provided for @tagSeverityWatch.
  ///
  /// In en, this message translates to:
  /// **'Watch'**
  String get tagSeverityWatch;

  /// No description provided for @tagSeverityBad.
  ///
  /// In en, this message translates to:
  /// **'Bad'**
  String get tagSeverityBad;

  /// No description provided for @tagSeverityLegal.
  ///
  /// In en, this message translates to:
  /// **'Legal action'**
  String get tagSeverityLegal;

  /// No description provided for @tagReasonBrokenPromise.
  ///
  /// In en, this message translates to:
  /// **'Broke promises again and again'**
  String get tagReasonBrokenPromise;

  /// No description provided for @tagReasonFraud.
  ///
  /// In en, this message translates to:
  /// **'Fraud suspected'**
  String get tagReasonFraud;

  /// No description provided for @tagReasonCleared.
  ///
  /// In en, this message translates to:
  /// **'Has paid up'**
  String get tagReasonCleared;

  /// No description provided for @tagReasonMistake.
  ///
  /// In en, this message translates to:
  /// **'Tagged by mistake'**
  String get tagReasonMistake;

  /// No description provided for @tagReasonTooShort.
  ///
  /// In en, this message translates to:
  /// **'Write at least 10 characters'**
  String get tagReasonTooShort;

  /// No description provided for @untagSaved.
  ///
  /// In en, this message translates to:
  /// **'Tag removal sent · manager will review'**
  String get untagSaved;

  /// No description provided for @tagPendingReview.
  ///
  /// In en, this message translates to:
  /// **'Waiting for manager review'**
  String get tagPendingReview;

  /// No description provided for @promiseCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel promise'**
  String get promiseCancel;

  /// No description provided for @promiseCancelled.
  ///
  /// In en, this message translates to:
  /// **'Promise cancelled'**
  String get promiseCancelled;

  /// No description provided for @promiseNote.
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get promiseNote;

  /// No description provided for @promiseReplaces.
  ///
  /// In en, this message translates to:
  /// **'This replaces the current promise of {amount} on {date}.'**
  String promiseReplaces(String amount, String date);

  /// No description provided for @promiseStatusOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get promiseStatusOpen;

  /// No description provided for @promiseStatusKept.
  ///
  /// In en, this message translates to:
  /// **'Kept'**
  String get promiseStatusKept;

  /// No description provided for @promiseStatusPartial.
  ///
  /// In en, this message translates to:
  /// **'Partly kept'**
  String get promiseStatusPartial;

  /// No description provided for @promiseStatusBroken.
  ///
  /// In en, this message translates to:
  /// **'Broken'**
  String get promiseStatusBroken;

  /// No description provided for @promiseStatusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get promiseStatusCancelled;

  /// No description provided for @promiseStatusSuperseded.
  ///
  /// In en, this message translates to:
  /// **'Replaced'**
  String get promiseStatusSuperseded;

  /// No description provided for @reminderTitle.
  ///
  /// In en, this message translates to:
  /// **'Promise today: {name}'**
  String reminderTitle(String name);

  /// No description provided for @reminderBody.
  ///
  /// In en, this message translates to:
  /// **'{amount} promised for today.'**
  String reminderBody(String amount);

  /// No description provided for @handoverReasonHint.
  ///
  /// In en, this message translates to:
  /// **'Why are you rejecting? (at least 10 characters)'**
  String get handoverReasonHint;

  /// No description provided for @handoverReason.
  ///
  /// In en, this message translates to:
  /// **'Reason: {reason}'**
  String handoverReason(String reason);

  /// No description provided for @handoverStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Waiting for you'**
  String get handoverStatusPending;

  /// No description provided for @handoverStatusAccepted.
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get handoverStatusAccepted;

  /// No description provided for @handoverStatusRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get handoverStatusRejected;

  /// No description provided for @handoverStatusOther.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get handoverStatusOther;

  /// No description provided for @handoverOpenConflicts.
  ///
  /// In en, this message translates to:
  /// **'Open problems'**
  String get handoverOpenConflicts;

  /// No description provided for @syncProblemRejected.
  ///
  /// In en, this message translates to:
  /// **'Not accepted: {reason}'**
  String syncProblemRejected(String reason);

  /// No description provided for @syncProblemConflict.
  ///
  /// In en, this message translates to:
  /// **'Needs office check: {reason}'**
  String syncProblemConflict(String reason);

  /// No description provided for @syncWaitingSince.
  ///
  /// In en, this message translates to:
  /// **'{count} items · since {time}'**
  String syncWaitingSince(String count, String time);

  /// No description provided for @syncMediaTitle.
  ///
  /// In en, this message translates to:
  /// **'Photos waiting'**
  String get syncMediaTitle;

  /// No description provided for @syncMediaCount.
  ///
  /// In en, this message translates to:
  /// **'{count} photos'**
  String syncMediaCount(String count);

  /// No description provided for @syncRetryAll.
  ///
  /// In en, this message translates to:
  /// **'Retry problems'**
  String get syncRetryAll;

  /// No description provided for @syncBlockedUpgrade.
  ///
  /// In en, this message translates to:
  /// **'Update the app to continue syncing'**
  String get syncBlockedUpgrade;

  /// No description provided for @settingsLanguageBn.
  ///
  /// In en, this message translates to:
  /// **'বাংলা'**
  String get settingsLanguageBn;

  /// No description provided for @settingsLanguageEn.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get settingsLanguageEn;

  /// No description provided for @settingsDevice.
  ///
  /// In en, this message translates to:
  /// **'Device {id}'**
  String settingsDevice(String id);

  /// No description provided for @meStaffCode.
  ///
  /// In en, this message translates to:
  /// **'Staff code {code}'**
  String meStaffCode(String code);

  /// No description provided for @meBranch.
  ///
  /// In en, this message translates to:
  /// **'{branch} branch'**
  String meBranch(String branch);

  /// No description provided for @logoutButton.
  ///
  /// In en, this message translates to:
  /// **'Sign out and remove data'**
  String get logoutButton;

  /// No description provided for @mapNoPins.
  ///
  /// In en, this message translates to:
  /// **'No customers with a map pin'**
  String get mapNoPins;

  /// No description provided for @mapTilesOffline.
  ///
  /// In en, this message translates to:
  /// **'Map needs internet · pins still shown'**
  String get mapTilesOffline;

  /// No description provided for @mapMyLocation.
  ///
  /// In en, this message translates to:
  /// **'My location'**
  String get mapMyLocation;

  /// No description provided for @mapPinsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} on map'**
  String mapPinsCount(String count);

  /// No description provided for @mapAttribution.
  ///
  /// In en, this message translates to:
  /// **'Map data © OpenStreetMap contributors'**
  String get mapAttribution;

  /// No description provided for @todayNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get todayNotifications;

  /// No description provided for @todayProgressTitle.
  ///
  /// In en, this message translates to:
  /// **'Today\'s progress'**
  String get todayProgressTitle;

  /// No description provided for @todayNoTarget.
  ///
  /// In en, this message translates to:
  /// **'No target set'**
  String get todayNoTarget;

  /// No description provided for @todayCollectFab.
  ///
  /// In en, this message translates to:
  /// **'Collect'**
  String get todayCollectFab;

  /// No description provided for @todayMore.
  ///
  /// In en, this message translates to:
  /// **'{count} more'**
  String todayMore(String count);

  /// No description provided for @todayReceiptsLow.
  ///
  /// In en, this message translates to:
  /// **'Only {count} receipt numbers left. Connect to get more.'**
  String todayReceiptsLow(String count);

  /// No description provided for @actionMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get actionMore;

  /// No description provided for @callHowWasIt.
  ///
  /// In en, this message translates to:
  /// **'How did the call go?'**
  String get callHowWasIt;

  /// No description provided for @callConnected.
  ///
  /// In en, this message translates to:
  /// **'Talked'**
  String get callConnected;

  /// No description provided for @callNoAnswer.
  ///
  /// In en, this message translates to:
  /// **'No answer'**
  String get callNoAnswer;

  /// No description provided for @callBusy.
  ///
  /// In en, this message translates to:
  /// **'Busy'**
  String get callBusy;

  /// No description provided for @callSwitchedOff.
  ///
  /// In en, this message translates to:
  /// **'Phone off'**
  String get callSwitchedOff;

  /// No description provided for @callWrongNumber.
  ///
  /// In en, this message translates to:
  /// **'Wrong number'**
  String get callWrongNumber;

  /// No description provided for @callUnknown.
  ///
  /// In en, this message translates to:
  /// **'Called'**
  String get callUnknown;

  /// No description provided for @callSaved.
  ///
  /// In en, this message translates to:
  /// **'Call saved'**
  String get callSaved;

  /// No description provided for @timelineCall.
  ///
  /// In en, this message translates to:
  /// **'Call · {outcome}'**
  String timelineCall(String outcome);

  /// No description provided for @trackingNotificationTitle.
  ///
  /// In en, this message translates to:
  /// **'On duty · location shared'**
  String get trackingNotificationTitle;

  /// No description provided for @trackingNotificationText.
  ///
  /// In en, this message translates to:
  /// **'Stops when you end work.'**
  String get trackingNotificationText;

  /// No description provided for @trackingTitle.
  ///
  /// In en, this message translates to:
  /// **'Location tracking'**
  String get trackingTitle;

  /// No description provided for @trackingOn.
  ///
  /// In en, this message translates to:
  /// **'On · {provider}'**
  String trackingOn(String provider);

  /// No description provided for @trackingOff.
  ///
  /// In en, this message translates to:
  /// **'Off (only while on duty)'**
  String get trackingOff;

  /// No description provided for @trackingProviderFree.
  ///
  /// In en, this message translates to:
  /// **'standard'**
  String get trackingProviderFree;

  /// No description provided for @trackingProviderPaid.
  ///
  /// In en, this message translates to:
  /// **'premium'**
  String get trackingProviderPaid;

  /// No description provided for @trackingFallback.
  ///
  /// In en, this message translates to:
  /// **'Premium tracking is not in this app version; using standard.'**
  String get trackingFallback;

  /// No description provided for @trackingLastPoint.
  ///
  /// In en, this message translates to:
  /// **'Last point {time}'**
  String trackingLastPoint(String time);

  /// No description provided for @trackingPending.
  ///
  /// In en, this message translates to:
  /// **'{count} points waiting'**
  String trackingPending(String count);

  /// No description provided for @visitSuggestTitle.
  ///
  /// In en, this message translates to:
  /// **'Near {name}?'**
  String visitSuggestTitle(String name);

  /// No description provided for @visitSuggestBody.
  ///
  /// In en, this message translates to:
  /// **'You have been here {minutes} min. Record a visit?'**
  String visitSuggestBody(String minutes);

  /// No description provided for @visitSuggestNo.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get visitSuggestNo;

  /// No description provided for @visitSuggestYes.
  ///
  /// In en, this message translates to:
  /// **'Record visit'**
  String get visitSuggestYes;

  /// No description provided for @actionSetLocation.
  ///
  /// In en, this message translates to:
  /// **'Set location'**
  String get actionSetLocation;

  /// No description provided for @actionCorrectLocation.
  ///
  /// In en, this message translates to:
  /// **'Correct location'**
  String get actionCorrectLocation;

  /// No description provided for @pinIntro.
  ///
  /// In en, this message translates to:
  /// **'Stand at the customer\'s door. Your phone\'s GPS position is sent as the new pin, and a manager approves it.'**
  String get pinIntro;

  /// No description provided for @pinAccuracyWeak.
  ///
  /// In en, this message translates to:
  /// **'GPS is off by {meters} m. It must be {limit} m or better: step into the open and wait a moment.'**
  String pinAccuracyWeak(String meters, String limit);

  /// No description provided for @pinOutside.
  ///
  /// In en, this message translates to:
  /// **'This position is outside Bangladesh.'**
  String get pinOutside;

  /// No description provided for @pinRetry.
  ///
  /// In en, this message translates to:
  /// **'Check GPS again'**
  String get pinRetry;

  /// No description provided for @pinPhotoNeeded.
  ///
  /// In en, this message translates to:
  /// **'Take a photo of the house or shop'**
  String get pinPhotoNeeded;

  /// No description provided for @pinNoteHint.
  ///
  /// In en, this message translates to:
  /// **'Landmark, gate colour, floor…'**
  String get pinNoteHint;

  /// No description provided for @pinSubmit.
  ///
  /// In en, this message translates to:
  /// **'Send for approval'**
  String get pinSubmit;

  /// No description provided for @pinSent.
  ///
  /// In en, this message translates to:
  /// **'Sent. The pin changes after a manager approves it.'**
  String get pinSent;

  /// No description provided for @pinPending.
  ///
  /// In en, this message translates to:
  /// **'New location sent · waiting for manager approval'**
  String get pinPending;

  /// No description provided for @pinFailed.
  ///
  /// In en, this message translates to:
  /// **'The server refused this location. Try again from the door with good GPS.'**
  String get pinFailed;

  /// No description provided for @pinDistanceFromOld.
  ///
  /// In en, this message translates to:
  /// **'{distance} from the current pin'**
  String pinDistanceFromOld(String distance);

  /// No description provided for @mapNoPinCount.
  ///
  /// In en, this message translates to:
  /// **'{count} without location'**
  String mapNoPinCount(String count);

  /// No description provided for @mapNoPinTitle.
  ///
  /// In en, this message translates to:
  /// **'Customers without location'**
  String get mapNoPinTitle;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['bn', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'bn':
      return AppLocalizationsBn();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
