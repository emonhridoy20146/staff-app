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
  /// **'Howlader Electronics'**
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

  /// No description provided for @actionReceiptPdf.
  ///
  /// In en, this message translates to:
  /// **'Receipt as PDF (print or save)'**
  String get actionReceiptPdf;

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
  /// **'Too many wrong passwords. Try again after {time}.'**
  String loginErrorLocked(String time);

  /// No description provided for @loginErrorLockedNoTime.
  ///
  /// In en, this message translates to:
  /// **'Too many wrong passwords. Try again a little later.'**
  String get loginErrorLockedNoTime;

  /// No description provided for @loginErrorLockedIp.
  ///
  /// In en, this message translates to:
  /// **'Too many wrong attempts from this network. Try again after {time}.'**
  String loginErrorLockedIp(String time);

  /// No description provided for @loginErrorLockedIpNoTime.
  ///
  /// In en, this message translates to:
  /// **'Too many wrong attempts from this network. Try again a little later.'**
  String get loginErrorLockedIpNoTime;

  /// No description provided for @loginDeviceRequestId.
  ///
  /// In en, this message translates to:
  /// **'Request number: {id}'**
  String loginDeviceRequestId(String id);

  /// No description provided for @loginDeviceNotApproved.
  ///
  /// In en, this message translates to:
  /// **'This phone is new. An approval request has been sent to the office. Sign in again once your manager approves it.'**
  String get loginDeviceNotApproved;

  /// No description provided for @loginRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get loginRetry;

  /// No description provided for @loginErrorOtherUserUnsynced.
  ///
  /// In en, this message translates to:
  /// **'This phone still has data from the previous user that hasn\'t been sent to the office. Ask that user to sign in on this phone and send everything, then sign in again.'**
  String get loginErrorOtherUserUnsynced;

  /// No description provided for @loginErrorForbidden.
  ///
  /// In en, this message translates to:
  /// **'Can\'t sign in (code: {code}). Tell your branch manager this code.'**
  String loginErrorForbidden(String code);

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

  /// No description provided for @pinChecking.
  ///
  /// In en, this message translates to:
  /// **'Checking your PIN and signing you in…'**
  String get pinChecking;

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

  /// No description provided for @networkOnline.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get networkOnline;

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

  /// No description provided for @dutyDetails.
  ///
  /// In en, this message translates to:
  /// **'Today\'s duty details'**
  String get dutyDetails;

  /// No description provided for @expandShow.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get expandShow;

  /// No description provided for @expandHide.
  ///
  /// In en, this message translates to:
  /// **'Hide'**
  String get expandHide;

  /// No description provided for @todayCollectedDetails.
  ///
  /// In en, this message translates to:
  /// **'Today\'s collection details'**
  String get todayCollectedDetails;

  /// No description provided for @dutyRowShift.
  ///
  /// In en, this message translates to:
  /// **'Office time'**
  String get dutyRowShift;

  /// No description provided for @dutyRowIn.
  ///
  /// In en, this message translates to:
  /// **'Attendance'**
  String get dutyRowIn;

  /// No description provided for @dutyRowBreak.
  ///
  /// In en, this message translates to:
  /// **'Break'**
  String get dutyRowBreak;

  /// No description provided for @dutyRowOut.
  ///
  /// In en, this message translates to:
  /// **'Work end'**
  String get dutyRowOut;

  /// No description provided for @dutyRowOvertime.
  ///
  /// In en, this message translates to:
  /// **'Overtime'**
  String get dutyRowOvertime;

  /// No description provided for @dutyOnTime.
  ///
  /// In en, this message translates to:
  /// **'On time'**
  String get dutyOnTime;

  /// No description provided for @dutyNotYet.
  ///
  /// In en, this message translates to:
  /// **'Not yet'**
  String get dutyNotYet;

  /// No description provided for @dutyBreakOf.
  ///
  /// In en, this message translates to:
  /// **'{taken} of {limit}'**
  String dutyBreakOf(String taken, String limit);

  /// No description provided for @dutyOfficeOver.
  ///
  /// In en, this message translates to:
  /// **'Office time is over. You can end work now.'**
  String get dutyOfficeOver;

  /// No description provided for @dutyEndBreakFirst.
  ///
  /// In en, this message translates to:
  /// **'End your break first, then you can end work.'**
  String get dutyEndBreakFirst;

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
  /// **'Name, code, mobile or invoice no.'**
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

  /// No description provided for @filterPaidThisMonth.
  ///
  /// In en, this message translates to:
  /// **'Paid this month'**
  String get filterPaidThisMonth;

  /// No description provided for @filterNotPaidThisMonth.
  ///
  /// In en, this message translates to:
  /// **'Not paid this month'**
  String get filterNotPaidThisMonth;

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

  /// No description provided for @customersReload.
  ///
  /// In en, this message translates to:
  /// **'Reload customers'**
  String get customersReload;

  /// No description provided for @customersLoadingCount.
  ///
  /// In en, this message translates to:
  /// **'Loading customers… ({count} so far)'**
  String customersLoadingCount(String count);

  /// No description provided for @customersLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading your branch\'s customers…'**
  String get customersLoading;

  /// No description provided for @customersLoadingBody.
  ///
  /// In en, this message translates to:
  /// **'The first load can take a minute. Keep the internet on.'**
  String get customersLoadingBody;

  /// No description provided for @customersNone.
  ///
  /// In en, this message translates to:
  /// **'No customers on this phone yet'**
  String get customersNone;

  /// No description provided for @customersNoneBody.
  ///
  /// In en, this message translates to:
  /// **'Pull down or tap Reload to load your branch\'s customers.'**
  String get customersNoneBody;

  /// No description provided for @customersLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load customers'**
  String get customersLoadFailed;

  /// No description provided for @customersLoadFailedBody.
  ///
  /// In en, this message translates to:
  /// **'Check the internet, then pull down or tap Reload. Code: {code}'**
  String customersLoadFailedBody(String code);

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
  /// **'{days} overdue'**
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

  /// No description provided for @statusDeleted.
  ///
  /// In en, this message translates to:
  /// **'Deleted by office'**
  String get statusDeleted;

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

  /// No description provided for @statusVoidedByOffice.
  ///
  /// In en, this message translates to:
  /// **'Voided by office'**
  String get statusVoidedByOffice;

  /// No description provided for @statusDeletedByYou.
  ///
  /// In en, this message translates to:
  /// **'Deleted by you'**
  String get statusDeletedByYou;

  /// No description provided for @collectionVoidedBy.
  ///
  /// In en, this message translates to:
  /// **'by {name}'**
  String collectionVoidedBy(String name);

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

  /// No description provided for @visitOutcomeRunaway.
  ///
  /// In en, this message translates to:
  /// **'Runaway'**
  String get visitOutcomeRunaway;

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
  /// **'Late {minutes}'**
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
  /// **'Deposit everything'**
  String get cashDeposit;

  /// No description provided for @cashDepositTitle.
  ///
  /// In en, this message translates to:
  /// **'Deposit everything in hand'**
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
  /// **'Deposited · it goes to the ERP'**
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

  /// No description provided for @attHubTitle.
  ///
  /// In en, this message translates to:
  /// **'Attendance'**
  String get attHubTitle;

  /// No description provided for @attHubHistory.
  ///
  /// In en, this message translates to:
  /// **'Attendance history'**
  String get attHubHistory;

  /// No description provided for @attHubWorkTime.
  ///
  /// In en, this message translates to:
  /// **'Work time'**
  String get attHubWorkTime;

  /// No description provided for @attHubLateWarning.
  ///
  /// In en, this message translates to:
  /// **'Late by {minutes}'**
  String attHubLateWarning(String minutes);

  /// No description provided for @attHubOverBreak.
  ///
  /// In en, this message translates to:
  /// **'Break over by {minutes}'**
  String attHubOverBreak(String minutes);

  /// No description provided for @attHubOvertime.
  ///
  /// In en, this message translates to:
  /// **'Overtime {minutes}'**
  String attHubOvertime(String minutes);

  /// No description provided for @attHubOffDayWork.
  ///
  /// In en, this message translates to:
  /// **'Worked on a day off: {minutes}'**
  String attHubOffDayWork(String minutes);

  /// No description provided for @attHubAbsenceStreak.
  ///
  /// In en, this message translates to:
  /// **'Counts as an absent day (every 2 late days = 1)'**
  String get attHubAbsenceStreak;

  /// No description provided for @attHubLateMonth.
  ///
  /// In en, this message translates to:
  /// **'Late on {late} days this month · counted as {absent} absent'**
  String attHubLateMonth(String late, String absent);

  /// No description provided for @attHubNoHistory.
  ///
  /// In en, this message translates to:
  /// **'No attendance history yet'**
  String get attHubNoHistory;

  /// No description provided for @attHubStatusOnDuty.
  ///
  /// In en, this message translates to:
  /// **'On duty'**
  String get attHubStatusOnDuty;

  /// No description provided for @attHubStatusOnBreak.
  ///
  /// In en, this message translates to:
  /// **'On break'**
  String get attHubStatusOnBreak;

  /// No description provided for @attHubStatusOffDuty.
  ///
  /// In en, this message translates to:
  /// **'Clocked out'**
  String get attHubStatusOffDuty;

  /// No description provided for @attHubStatusNotStarted.
  ///
  /// In en, this message translates to:
  /// **'Not started'**
  String get attHubStatusNotStarted;

  /// No description provided for @attHubOut.
  ///
  /// In en, this message translates to:
  /// **'Out at {time}'**
  String attHubOut(String time);

  /// No description provided for @todayWorkBtn.
  ///
  /// In en, this message translates to:
  /// **'Today\'s work'**
  String get todayWorkBtn;

  /// No description provided for @performanceBtn.
  ///
  /// In en, this message translates to:
  /// **'Performance'**
  String get performanceBtn;

  /// No description provided for @attendanceBtn.
  ///
  /// In en, this message translates to:
  /// **'Attendance'**
  String get attendanceBtn;

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

  /// No description provided for @oemGuideTitle.
  ///
  /// In en, this message translates to:
  /// **'Battery & Background Settings'**
  String get oemGuideTitle;

  /// No description provided for @oemGuideSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Some phones stop GPS when the screen turns off. Follow the steps for your phone brand to keep tracking on while on duty.'**
  String get oemGuideSubtitle;

  /// No description provided for @oemGuideDone.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get oemGuideDone;

  /// No description provided for @oemGuideXiaomiName.
  ///
  /// In en, this message translates to:
  /// **'Xiaomi / Redmi / POCO (MIUI)'**
  String get oemGuideXiaomiName;

  /// No description provided for @oemGuideXiaomiStep1.
  ///
  /// In en, this message translates to:
  /// **'Settings → Apps → Manage apps → [this app] → Battery saver → No restrictions'**
  String get oemGuideXiaomiStep1;

  /// No description provided for @oemGuideXiaomiStep2.
  ///
  /// In en, this message translates to:
  /// **'Settings → Apps → Manage apps → [this app] → Autostart → turn ON'**
  String get oemGuideXiaomiStep2;

  /// No description provided for @oemGuideXiaomiStep3.
  ///
  /// In en, this message translates to:
  /// **'Settings → Battery & performance → App battery saver → find this app → No restrictions'**
  String get oemGuideXiaomiStep3;

  /// No description provided for @oemGuideSamsungName.
  ///
  /// In en, this message translates to:
  /// **'Samsung (One UI)'**
  String get oemGuideSamsungName;

  /// No description provided for @oemGuideSamsungStep1.
  ///
  /// In en, this message translates to:
  /// **'Settings → Apps → [this app] → Battery → Unrestricted'**
  String get oemGuideSamsungStep1;

  /// No description provided for @oemGuideSamsungStep2.
  ///
  /// In en, this message translates to:
  /// **'Settings → Device care → Battery → App power management → Sleeping apps → remove this app'**
  String get oemGuideSamsungStep2;

  /// No description provided for @oemGuideSamsungStep3.
  ///
  /// In en, this message translates to:
  /// **'Settings → Apps → [this app] → Mobile data → Allow background data usage'**
  String get oemGuideSamsungStep3;

  /// No description provided for @oemGuideOppoName.
  ///
  /// In en, this message translates to:
  /// **'Oppo / Realme (ColorOS)'**
  String get oemGuideOppoName;

  /// No description provided for @oemGuideOppoStep1.
  ///
  /// In en, this message translates to:
  /// **'Settings → Battery → App power saving → find this app → turn OFF'**
  String get oemGuideOppoStep1;

  /// No description provided for @oemGuideOppoStep2.
  ///
  /// In en, this message translates to:
  /// **'Settings → Apps → [this app] → Battery usage → Allow background activity'**
  String get oemGuideOppoStep2;

  /// No description provided for @oemGuideOppoStep3.
  ///
  /// In en, this message translates to:
  /// **'Settings → Battery → More → App quick freeze → exclude this app'**
  String get oemGuideOppoStep3;

  /// No description provided for @oemGuideVivoName.
  ///
  /// In en, this message translates to:
  /// **'Vivo (Funtouch OS)'**
  String get oemGuideVivoName;

  /// No description provided for @oemGuideVivoStep1.
  ///
  /// In en, this message translates to:
  /// **'Settings → Battery → Background app power management → turn OFF for this app'**
  String get oemGuideVivoStep1;

  /// No description provided for @oemGuideVivoStep2.
  ///
  /// In en, this message translates to:
  /// **'iManager → App Management → [this app] → Background run → Allow'**
  String get oemGuideVivoStep2;

  /// No description provided for @oemGuideVivoStep3.
  ///
  /// In en, this message translates to:
  /// **'Settings → Apps → [this app] → Battery → Unrestricted'**
  String get oemGuideVivoStep3;

  /// No description provided for @oemGuideHuaweiName.
  ///
  /// In en, this message translates to:
  /// **'Huawei / Honor (EMUI / MagicUI)'**
  String get oemGuideHuaweiName;

  /// No description provided for @oemGuideHuaweiStep1.
  ///
  /// In en, this message translates to:
  /// **'Phone Manager → Launch manager → find this app → Manage manually'**
  String get oemGuideHuaweiStep1;

  /// No description provided for @oemGuideHuaweiStep2.
  ///
  /// In en, this message translates to:
  /// **'Turn on Auto-launch, Secondary launch, and Run in background'**
  String get oemGuideHuaweiStep2;

  /// No description provided for @oemGuideHuaweiStep3.
  ///
  /// In en, this message translates to:
  /// **'Settings → Battery → App launch → find this app → Manage manually → allow all three'**
  String get oemGuideHuaweiStep3;

  /// No description provided for @oemGuideOneplusName.
  ///
  /// In en, this message translates to:
  /// **'OnePlus / Nothing (OxygenOS)'**
  String get oemGuideOneplusName;

  /// No description provided for @oemGuideOneplusStep1.
  ///
  /// In en, this message translates to:
  /// **'Settings → Apps → [this app] → Battery → Allow background activity'**
  String get oemGuideOneplusStep1;

  /// No description provided for @oemGuideOneplusStep2.
  ///
  /// In en, this message translates to:
  /// **'Settings → Battery → Battery optimization → All apps → [this app] → Don\'t optimize'**
  String get oemGuideOneplusStep2;

  /// No description provided for @oemGuideOtherName.
  ///
  /// In en, this message translates to:
  /// **'Other Android phones'**
  String get oemGuideOtherName;

  /// No description provided for @oemGuideOtherStep1.
  ///
  /// In en, this message translates to:
  /// **'Settings → Apps → [this app] → Battery → Unrestricted (or Don\'t optimize)'**
  String get oemGuideOtherStep1;

  /// No description provided for @oemGuideOtherStep2.
  ///
  /// In en, this message translates to:
  /// **'Settings → Battery → Battery optimization → find this app → Don\'t optimize'**
  String get oemGuideOtherStep2;

  /// No description provided for @visitSuggestTitle.
  ///
  /// In en, this message translates to:
  /// **'Near {name}?'**
  String visitSuggestTitle(String name);

  /// No description provided for @visitSuggestBody.
  ///
  /// In en, this message translates to:
  /// **'You have been here {minutes}. Record a visit?'**
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
  /// **'Move the map until the pin sits on the customer\'s door. Tap a spot to bring it under the pin.'**
  String get pinIntro;

  /// No description provided for @pinOutside.
  ///
  /// In en, this message translates to:
  /// **'This position is outside Bangladesh.'**
  String get pinOutside;

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
  /// **'The server refused this location. Open the map and send it again.'**
  String get pinFailed;

  /// No description provided for @pinDistanceFromOld.
  ///
  /// In en, this message translates to:
  /// **'{distance} from the current pin'**
  String pinDistanceFromOld(String distance);

  /// No description provided for @pinMapLabel.
  ///
  /// In en, this message translates to:
  /// **'Map. Drag it to put the pin on the customer\'s door.'**
  String get pinMapLabel;

  /// No description provided for @pinAt.
  ///
  /// In en, this message translates to:
  /// **'Pin at'**
  String get pinAt;

  /// No description provided for @pinPhoneDistance.
  ///
  /// In en, this message translates to:
  /// **'You are {distance} from the pin'**
  String pinPhoneDistance(String distance);

  /// No description provided for @pinPhoneFar.
  ///
  /// In en, this message translates to:
  /// **'You are {distance} from the pin. Check it is the right house: the manager sees this distance.'**
  String pinPhoneFar(String distance);

  /// No description provided for @pinPhoneUnknown.
  ///
  /// In en, this message translates to:
  /// **'Your own location is not known yet.'**
  String get pinPhoneUnknown;

  /// No description provided for @pinPhoneMock.
  ///
  /// In en, this message translates to:
  /// **'Your phone reports a fake location, so a manager checks this pin.'**
  String get pinPhoneMock;

  /// No description provided for @pinWillApply.
  ///
  /// In en, this message translates to:
  /// **'This customer has no location yet: the pin is set as soon as it is sent.'**
  String get pinWillApply;

  /// No description provided for @pinWillApplyApprover.
  ///
  /// In en, this message translates to:
  /// **'You can approve pins: the pin is set as soon as it is sent.'**
  String get pinWillApplyApprover;

  /// No description provided for @pinNeedsManager.
  ///
  /// In en, this message translates to:
  /// **'A manager checks the new pin before it changes.'**
  String get pinNeedsManager;

  /// No description provided for @pinPhotoOptional.
  ///
  /// In en, this message translates to:
  /// **'Photo of the house or shop (optional)'**
  String get pinPhotoOptional;

  /// No description provided for @pinSubmitApply.
  ///
  /// In en, this message translates to:
  /// **'Set pin'**
  String get pinSubmitApply;

  /// No description provided for @pinSentApplied.
  ///
  /// In en, this message translates to:
  /// **'Saved. The pin is set as soon as it is sent.'**
  String get pinSentApplied;

  /// No description provided for @pinApplyWhenSent.
  ///
  /// In en, this message translates to:
  /// **'New location saved · it is set as soon as it is sent'**
  String get pinApplyWhenSent;

  /// No description provided for @pinTypeCoords.
  ///
  /// In en, this message translates to:
  /// **'Type or paste coordinates'**
  String get pinTypeCoords;

  /// No description provided for @pinTypeCoordsHelp.
  ///
  /// In en, this message translates to:
  /// **'For example 22.70123, 90.37011, or a map link'**
  String get pinTypeCoordsHelp;

  /// No description provided for @pinTypeCoordsError.
  ///
  /// In en, this message translates to:
  /// **'Could not read these coordinates.'**
  String get pinTypeCoordsError;

  /// No description provided for @pinGo.
  ///
  /// In en, this message translates to:
  /// **'Go'**
  String get pinGo;

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

  /// No description provided for @pinRejected.
  ///
  /// In en, this message translates to:
  /// **'Location not approved: {reason}. Tap to send a new one.'**
  String pinRejected(String reason);

  /// No description provided for @attendanceSelfieNeeded.
  ///
  /// In en, this message translates to:
  /// **'Attendance needs a photo of you. Tap again and take the photo.'**
  String get attendanceSelfieNeeded;

  /// No description provided for @attendanceSelfieHint.
  ///
  /// In en, this message translates to:
  /// **'The front camera opens to take your photo. Camera only.'**
  String get attendanceSelfieHint;

  /// No description provided for @mapViewMap.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get mapViewMap;

  /// No description provided for @mapViewList.
  ///
  /// In en, this message translates to:
  /// **'List'**
  String get mapViewList;

  /// No description provided for @mapFilterClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get mapFilterClear;

  /// No description provided for @mapListEmpty.
  ///
  /// In en, this message translates to:
  /// **'No customers match these filters'**
  String get mapListEmpty;

  /// No description provided for @mapListNoFix.
  ///
  /// In en, this message translates to:
  /// **'No GPS yet · distances appear when the phone finds you'**
  String get mapListNoFix;

  /// No description provided for @coworkTitle.
  ///
  /// In en, this message translates to:
  /// **'Co-work'**
  String get coworkTitle;

  /// No description provided for @coworkInviteFrom.
  ///
  /// In en, this message translates to:
  /// **'{name} wants to work with you today'**
  String coworkInviteFrom(String name);

  /// No description provided for @coworkWith.
  ///
  /// In en, this message translates to:
  /// **'With: {names}'**
  String coworkWith(String names);

  /// No description provided for @coworkActiveTitle.
  ///
  /// In en, this message translates to:
  /// **'Working together today'**
  String get coworkActiveTitle;

  /// No description provided for @coworkYou.
  ///
  /// In en, this message translates to:
  /// **'{name} (you)'**
  String coworkYou(String name);

  /// No description provided for @coworkWaiting.
  ///
  /// In en, this message translates to:
  /// **'Waiting'**
  String get coworkWaiting;

  /// No description provided for @coworkNoPartnerYet.
  ///
  /// In en, this message translates to:
  /// **'Visits count as co-work once someone accepts'**
  String get coworkNoPartnerYet;

  /// No description provided for @coworkVisitsToday.
  ///
  /// In en, this message translates to:
  /// **'{n} co-work visits'**
  String coworkVisitsToday(String n);

  /// No description provided for @coworkAdd.
  ///
  /// In en, this message translates to:
  /// **'Ask more'**
  String get coworkAdd;

  /// No description provided for @coworkLeave.
  ///
  /// In en, this message translates to:
  /// **'Leave group'**
  String get coworkLeave;

  /// No description provided for @coworkLeaveConfirm.
  ///
  /// In en, this message translates to:
  /// **'After you leave, your next visits count as single visits. Earlier co-work visits stay as they are.'**
  String get coworkLeaveConfirm;

  /// No description provided for @coworkLeaveEndsConfirm.
  ///
  /// In en, this message translates to:
  /// **'Only two of you are in the group, so it ends when you leave. Earlier co-work visits stay as they are.'**
  String get coworkLeaveEndsConfirm;

  /// No description provided for @coworkCancelRequest.
  ///
  /// In en, this message translates to:
  /// **'Cancel request'**
  String get coworkCancelRequest;

  /// No description provided for @coworkCancelConfirm.
  ///
  /// In en, this message translates to:
  /// **'Nobody has accepted yet. The request is withdrawn for everyone you asked.'**
  String get coworkCancelConfirm;

  /// No description provided for @coworkCancelled.
  ///
  /// In en, this message translates to:
  /// **'Request cancelled'**
  String get coworkCancelled;

  /// No description provided for @coworkStartTitle.
  ///
  /// In en, this message translates to:
  /// **'Work with a colleague'**
  String get coworkStartTitle;

  /// No description provided for @coworkStartBody.
  ///
  /// In en, this message translates to:
  /// **'Visits made together count for everyone'**
  String get coworkStartBody;

  /// No description provided for @coworkNeedsInternet.
  ///
  /// In en, this message translates to:
  /// **'Sending and answering need internet'**
  String get coworkNeedsInternet;

  /// No description provided for @coworkInviteSection.
  ///
  /// In en, this message translates to:
  /// **'Whom to ask?'**
  String get coworkInviteSection;

  /// No description provided for @coworkSeatsLeft.
  ///
  /// In en, this message translates to:
  /// **'You can ask {n} more'**
  String coworkSeatsLeft(String n);

  /// No description provided for @coworkFull.
  ///
  /// In en, this message translates to:
  /// **'The group is full'**
  String get coworkFull;

  /// No description provided for @coworkOnDuty.
  ///
  /// In en, this message translates to:
  /// **'On duty'**
  String get coworkOnDuty;

  /// No description provided for @coworkOffDuty.
  ///
  /// In en, this message translates to:
  /// **'Not on duty'**
  String get coworkOffDuty;

  /// No description provided for @coworkInOtherGroup.
  ///
  /// In en, this message translates to:
  /// **'In another group'**
  String get coworkInOtherGroup;

  /// No description provided for @coworkInThisGroup.
  ///
  /// In en, this message translates to:
  /// **'In this group'**
  String get coworkInThisGroup;

  /// No description provided for @coworkNoteHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. which area you will cover'**
  String get coworkNoteHint;

  /// No description provided for @coworkSend.
  ///
  /// In en, this message translates to:
  /// **'Send request ({n})'**
  String coworkSend(String n);

  /// No description provided for @coworkSent.
  ///
  /// In en, this message translates to:
  /// **'Request sent'**
  String get coworkSent;

  /// No description provided for @coworkJoined.
  ///
  /// In en, this message translates to:
  /// **'You joined the group'**
  String get coworkJoined;

  /// No description provided for @coworkDeclined.
  ///
  /// In en, this message translates to:
  /// **'You declined'**
  String get coworkDeclined;

  /// No description provided for @coworkLeft.
  ///
  /// In en, this message translates to:
  /// **'You left the group'**
  String get coworkLeft;

  /// No description provided for @coworkOffline.
  ///
  /// In en, this message translates to:
  /// **'No internet. Try again when connected.'**
  String get coworkOffline;

  /// No description provided for @coworkErrAlreadyIn.
  ///
  /// In en, this message translates to:
  /// **'You are already in another group today. Leave it first.'**
  String get coworkErrAlreadyIn;

  /// No description provided for @coworkErrEnded.
  ///
  /// In en, this message translates to:
  /// **'This group has ended'**
  String get coworkErrEnded;

  /// No description provided for @coworkErrNotInvited.
  ///
  /// In en, this message translates to:
  /// **'This invitation is no longer open'**
  String get coworkErrNotInvited;

  /// No description provided for @coworkErrTooMany.
  ///
  /// In en, this message translates to:
  /// **'The group has reached its member limit'**
  String get coworkErrTooMany;

  /// No description provided for @coworkErrInvitee.
  ///
  /// In en, this message translates to:
  /// **'This colleague can\'t be asked'**
  String get coworkErrInvitee;

  /// No description provided for @coworkNoColleagues.
  ///
  /// In en, this message translates to:
  /// **'No colleagues in your branch to ask'**
  String get coworkNoColleagues;

  /// No description provided for @coworkVisitToggle.
  ///
  /// In en, this message translates to:
  /// **'Co-work visit'**
  String get coworkVisitToggle;

  /// No description provided for @coworkVisitWith.
  ///
  /// In en, this message translates to:
  /// **'With {names} · counts for everyone'**
  String coworkVisitWith(String names);

  /// No description provided for @coworkVisitSingle.
  ///
  /// In en, this message translates to:
  /// **'Off: a single visit, yours only'**
  String get coworkVisitSingle;

  /// No description provided for @coworkBadge.
  ///
  /// In en, this message translates to:
  /// **'Co-work'**
  String get coworkBadge;

  /// No description provided for @timelineCoworkWith.
  ///
  /// In en, this message translates to:
  /// **'with {names}'**
  String timelineCoworkWith(String names);

  /// No description provided for @timelineRecordedBy.
  ///
  /// In en, this message translates to:
  /// **'recorded by {name}'**
  String timelineRecordedBy(String name);

  /// No description provided for @todayVisitsJoint.
  ///
  /// In en, this message translates to:
  /// **'{n} co-work'**
  String todayVisitsJoint(String n);

  /// No description provided for @coworkAsked.
  ///
  /// In en, this message translates to:
  /// **'Asked'**
  String get coworkAsked;

  /// No description provided for @todayTargetMet.
  ///
  /// In en, this message translates to:
  /// **'Target met'**
  String get todayTargetMet;

  /// No description provided for @todayTargetPersonal.
  ///
  /// In en, this message translates to:
  /// **'My target'**
  String get todayTargetPersonal;

  /// No description provided for @todayOffDay.
  ///
  /// In en, this message translates to:
  /// **'Day off, no target today'**
  String get todayOffDay;

  /// No description provided for @todayVisitTarget.
  ///
  /// In en, this message translates to:
  /// **'Visit target'**
  String get todayVisitTarget;

  /// No description provided for @todayVisitTargetOf.
  ///
  /// In en, this message translates to:
  /// **'{done} / {target}'**
  String todayVisitTargetOf(String done, String target);

  /// No description provided for @perfTitle.
  ///
  /// In en, this message translates to:
  /// **'My performance'**
  String get perfTitle;

  /// No description provided for @perfMeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'This month\'s collections, visits, target'**
  String get perfMeSubtitle;

  /// No description provided for @perfPrevMonth.
  ///
  /// In en, this message translates to:
  /// **'Previous month'**
  String get perfPrevMonth;

  /// No description provided for @perfNextMonth.
  ///
  /// In en, this message translates to:
  /// **'Next month'**
  String get perfNextMonth;

  /// No description provided for @perfCachedAt.
  ///
  /// In en, this message translates to:
  /// **'No internet. Showing figures from {time}.'**
  String perfCachedAt(String time);

  /// No description provided for @perfCollected.
  ///
  /// In en, this message translates to:
  /// **'Collected this month'**
  String get perfCollected;

  /// No description provided for @perfTargetToDate.
  ///
  /// In en, this message translates to:
  /// **'Target to date {toDate} · whole month {month}'**
  String perfTargetToDate(String toDate, String month);

  /// No description provided for @perfPosted.
  ///
  /// In en, this message translates to:
  /// **'Posted in ERP'**
  String get perfPosted;

  /// No description provided for @perfPendingErp.
  ///
  /// In en, this message translates to:
  /// **'Pending in ERP'**
  String get perfPendingErp;

  /// No description provided for @perfVisitCredit.
  ///
  /// In en, this message translates to:
  /// **'Visit credit (against target to date)'**
  String get perfVisitCredit;

  /// No description provided for @perfSoloVisits.
  ///
  /// In en, this message translates to:
  /// **'Single visits'**
  String get perfSoloVisits;

  /// No description provided for @perfCoWorkVisits.
  ///
  /// In en, this message translates to:
  /// **'Co-work visits'**
  String get perfCoWorkVisits;

  /// No description provided for @perfPromisesKept.
  ///
  /// In en, this message translates to:
  /// **'Promises kept'**
  String get perfPromisesKept;

  /// No description provided for @perfOf.
  ///
  /// In en, this message translates to:
  /// **'{a}/{b}'**
  String perfOf(String a, String b);

  /// No description provided for @perfPresentDays.
  ///
  /// In en, this message translates to:
  /// **'Days present'**
  String get perfPresentDays;

  /// No description provided for @perfLateDays.
  ///
  /// In en, this message translates to:
  /// **'Late days'**
  String get perfLateDays;

  /// No description provided for @perfRank.
  ///
  /// In en, this message translates to:
  /// **'Your place in the branch: {rank} of {of}'**
  String perfRank(String rank, String of);

  /// No description provided for @perfRankBy.
  ///
  /// In en, this message translates to:
  /// **'By collections · see leaderboard'**
  String get perfRankBy;

  /// No description provided for @perfDaily.
  ///
  /// In en, this message translates to:
  /// **'Collections by day'**
  String get perfDaily;

  /// No description provided for @perfLegendCollected.
  ///
  /// In en, this message translates to:
  /// **'Collected'**
  String get perfLegendCollected;

  /// No description provided for @perfLegendMet.
  ///
  /// In en, this message translates to:
  /// **'Target met'**
  String get perfLegendMet;

  /// No description provided for @perfLegendTarget.
  ///
  /// In en, this message translates to:
  /// **'Target'**
  String get perfLegendTarget;

  /// No description provided for @perfDailySemantics.
  ///
  /// In en, this message translates to:
  /// **'Daily collections chart for this month, total {total}'**
  String perfDailySemantics(String total);

  /// No description provided for @reportOffline.
  ///
  /// In en, this message translates to:
  /// **'Needs internet. Try again when connected.'**
  String get reportOffline;

  /// No description provided for @leaderboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Leaderboard'**
  String get leaderboardTitle;

  /// No description provided for @leaderboardHidden.
  ///
  /// In en, this message translates to:
  /// **'The leaderboard is off'**
  String get leaderboardHidden;

  /// No description provided for @leaderboardHiddenBody.
  ///
  /// In en, this message translates to:
  /// **'It shows here when the office turns it on'**
  String get leaderboardHiddenBody;

  /// No description provided for @leaderToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get leaderToday;

  /// No description provided for @leaderMonth.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get leaderMonth;

  /// No description provided for @leaderMetricCollected.
  ///
  /// In en, this message translates to:
  /// **'Collected'**
  String get leaderMetricCollected;

  /// No description provided for @leaderMetricVisits.
  ///
  /// In en, this message translates to:
  /// **'Visit credit'**
  String get leaderMetricVisits;

  /// No description provided for @leaderMetricPromises.
  ///
  /// In en, this message translates to:
  /// **'Promises kept'**
  String get leaderMetricPromises;

  /// No description provided for @leaderMetricTarget.
  ///
  /// In en, this message translates to:
  /// **'Target achieved'**
  String get leaderMetricTarget;

  /// No description provided for @leaderNotRanked.
  ///
  /// In en, this message translates to:
  /// **'Not ranked (too few days present)'**
  String get leaderNotRanked;

  /// No description provided for @leaderNotRankedMe.
  ///
  /// In en, this message translates to:
  /// **'You have too few days present in this period to be ranked'**
  String get leaderNotRankedMe;

  /// No description provided for @leaderFootnote.
  ///
  /// In en, this message translates to:
  /// **'Collected counts money taken in the field (posted and pending in ERP). Co-work visits add to everyone\'s credit.'**
  String get leaderFootnote;

  /// No description provided for @noticesTitle.
  ///
  /// In en, this message translates to:
  /// **'Notices'**
  String get noticesTitle;

  /// No description provided for @noticeTitle.
  ///
  /// In en, this message translates to:
  /// **'Notice'**
  String get noticeTitle;

  /// No description provided for @noticesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No notices'**
  String get noticesEmpty;

  /// No description provided for @noticesEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Notices from the office show here'**
  String get noticesEmptyBody;

  /// No description provided for @noticeRead.
  ///
  /// In en, this message translates to:
  /// **'Read'**
  String get noticeRead;

  /// No description provided for @noticeMustRead.
  ///
  /// In en, this message translates to:
  /// **'Confirm reading'**
  String get noticeMustRead;

  /// No description provided for @noticeUnread.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get noticeUnread;

  /// No description provided for @noticeFrom.
  ///
  /// In en, this message translates to:
  /// **'From {name}'**
  String noticeFrom(String name);

  /// No description provided for @noticeMarkRead.
  ///
  /// In en, this message translates to:
  /// **'I have read it'**
  String get noticeMarkRead;

  /// No description provided for @noticeThanks.
  ///
  /// In en, this message translates to:
  /// **'Thanks, the office will see it'**
  String get noticeThanks;

  /// No description provided for @noticeReadAt.
  ///
  /// In en, this message translates to:
  /// **'Read at {time}'**
  String noticeReadAt(String time);

  /// No description provided for @noticeReadQueued.
  ///
  /// In en, this message translates to:
  /// **'Read at {time} · reaches the office when online'**
  String noticeReadQueued(String time);

  /// No description provided for @noticeReadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not be sent to the office. See the sync centre.'**
  String get noticeReadFailed;

  /// No description provided for @todayNoticeOne.
  ///
  /// In en, this message translates to:
  /// **'New notice: {title}'**
  String todayNoticeOne(String title);

  /// No description provided for @todayNoticeMany.
  ///
  /// In en, this message translates to:
  /// **'{n} notices to read and confirm'**
  String todayNoticeMany(String n);

  /// No description provided for @noticesUnreadCount.
  ///
  /// In en, this message translates to:
  /// **'{n} new'**
  String noticesUnreadCount(String n);

  /// No description provided for @noticesAllRead.
  ///
  /// In en, this message translates to:
  /// **'All read'**
  String get noticesAllRead;

  /// No description provided for @leaveTitle.
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get leaveTitle;

  /// No description provided for @leaveMeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Ask for leave and see the answer'**
  String get leaveMeSubtitle;

  /// No description provided for @leaveNew.
  ///
  /// In en, this message translates to:
  /// **'Ask for leave'**
  String get leaveNew;

  /// No description provided for @leaveTypeCasual.
  ///
  /// In en, this message translates to:
  /// **'Casual'**
  String get leaveTypeCasual;

  /// No description provided for @leaveTypeSick.
  ///
  /// In en, this message translates to:
  /// **'Sick'**
  String get leaveTypeSick;

  /// No description provided for @leaveTypeOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get leaveTypeOther;

  /// No description provided for @leavePending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get leavePending;

  /// No description provided for @leaveApproved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get leaveApproved;

  /// No description provided for @leaveRejected.
  ///
  /// In en, this message translates to:
  /// **'Not approved'**
  String get leaveRejected;

  /// No description provided for @leaveCancelled.
  ///
  /// In en, this message translates to:
  /// **'Withdrawn'**
  String get leaveCancelled;

  /// No description provided for @leaveCancelDone.
  ///
  /// In en, this message translates to:
  /// **'Request withdrawn'**
  String get leaveCancelDone;

  /// No description provided for @leaveDays.
  ///
  /// In en, this message translates to:
  /// **'{n} days'**
  String leaveDays(String n);

  /// No description provided for @leaveTotalDays.
  ///
  /// In en, this message translates to:
  /// **'{n} days in total'**
  String leaveTotalDays(String n);

  /// No description provided for @leaveAskedAt.
  ///
  /// In en, this message translates to:
  /// **'Asked {time}'**
  String leaveAskedAt(String time);

  /// No description provided for @leaveManagerSaid.
  ///
  /// In en, this message translates to:
  /// **'Manager: {reason}'**
  String leaveManagerSaid(String reason);

  /// No description provided for @leaveCancelAction.
  ///
  /// In en, this message translates to:
  /// **'Withdraw'**
  String get leaveCancelAction;

  /// No description provided for @leaveCancelTitle.
  ///
  /// In en, this message translates to:
  /// **'Withdraw this request?'**
  String get leaveCancelTitle;

  /// No description provided for @leaveCancelBody.
  ///
  /// In en, this message translates to:
  /// **'The request for {from} – {to} will be withdrawn. You can ask again if needed.'**
  String leaveCancelBody(String from, String to);

  /// No description provided for @leaveCancelConfirm.
  ///
  /// In en, this message translates to:
  /// **'Yes, withdraw'**
  String get leaveCancelConfirm;

  /// No description provided for @leaveEmpty.
  ///
  /// In en, this message translates to:
  /// **'No leave requests'**
  String get leaveEmpty;

  /// No description provided for @leaveEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Tap the button below to ask'**
  String get leaveEmptyBody;

  /// No description provided for @leaveCachedAt.
  ///
  /// In en, this message translates to:
  /// **'Offline · showing what the phone had at {time}'**
  String leaveCachedAt(String time);

  /// No description provided for @leaveNeedsInternet.
  ///
  /// In en, this message translates to:
  /// **'Needs internet. Try again when connected.'**
  String get leaveNeedsInternet;

  /// No description provided for @leaveType.
  ///
  /// In en, this message translates to:
  /// **'Type of leave'**
  String get leaveType;

  /// No description provided for @leaveFrom.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get leaveFrom;

  /// No description provided for @leaveTo.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get leaveTo;

  /// No description provided for @leaveReason.
  ///
  /// In en, this message translates to:
  /// **'Reason (optional)'**
  String get leaveReason;

  /// No description provided for @leaveReasonHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. sister\'s wedding'**
  String get leaveReasonHint;

  /// No description provided for @leaveOnlineNote.
  ///
  /// In en, this message translates to:
  /// **'Sending needs internet. The manager\'s answer shows here.'**
  String get leaveOnlineNote;

  /// No description provided for @leaveSend.
  ///
  /// In en, this message translates to:
  /// **'Send request'**
  String get leaveSend;

  /// No description provided for @leaveSent.
  ///
  /// In en, this message translates to:
  /// **'Request sent'**
  String get leaveSent;

  /// No description provided for @leaveErrToBeforeFrom.
  ///
  /// In en, this message translates to:
  /// **'The end date cannot be before the start'**
  String get leaveErrToBeforeFrom;

  /// No description provided for @leaveErrTooLong.
  ///
  /// In en, this message translates to:
  /// **'At most 31 days in one request'**
  String get leaveErrTooLong;

  /// No description provided for @leaveErrOverlaps.
  ///
  /// In en, this message translates to:
  /// **'You already have a request for some of these days'**
  String get leaveErrOverlaps;

  /// No description provided for @leaveErrDecided.
  ///
  /// In en, this message translates to:
  /// **'The manager has already decided'**
  String get leaveErrDecided;

  /// No description provided for @calendarTitle.
  ///
  /// In en, this message translates to:
  /// **'Holidays and shift'**
  String get calendarTitle;

  /// No description provided for @calendarMeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Holidays, weekly off and duty hours'**
  String get calendarMeSubtitle;

  /// No description provided for @calendarMyShift.
  ///
  /// In en, this message translates to:
  /// **'My shift'**
  String get calendarMyShift;

  /// No description provided for @calendarDefaultShift.
  ///
  /// In en, this message translates to:
  /// **'Branch default shift'**
  String get calendarDefaultShift;

  /// No description provided for @calendarShiftHours.
  ///
  /// In en, this message translates to:
  /// **'{start} – {end}'**
  String calendarShiftHours(String start, String end);

  /// No description provided for @calendarWeeklyOff.
  ///
  /// In en, this message translates to:
  /// **'Weekly off: {days}'**
  String calendarWeeklyOff(String days);

  /// No description provided for @calendarNoWeeklyOff.
  ///
  /// In en, this message translates to:
  /// **'No weekly off'**
  String get calendarNoWeeklyOff;

  /// No description provided for @calendarLateGrace.
  ///
  /// In en, this message translates to:
  /// **'Late after {grace} · break {brk}'**
  String calendarLateGrace(String grace, String brk);

  /// No description provided for @calendarMyLeave.
  ///
  /// In en, this message translates to:
  /// **'My approved leave'**
  String get calendarMyLeave;

  /// No description provided for @calendarHolidays.
  ///
  /// In en, this message translates to:
  /// **'Holidays'**
  String get calendarHolidays;

  /// No description provided for @calendarNoHolidays.
  ///
  /// In en, this message translates to:
  /// **'No holidays entered for this year'**
  String get calendarNoHolidays;

  /// No description provided for @calendarNoHolidaysBody.
  ///
  /// In en, this message translates to:
  /// **'They show here once the office adds them'**
  String get calendarNoHolidaysBody;

  /// No description provided for @calendarNational.
  ///
  /// In en, this message translates to:
  /// **'National'**
  String get calendarNational;

  /// No description provided for @calendarBranch.
  ///
  /// In en, this message translates to:
  /// **'Branch'**
  String get calendarBranch;

  /// No description provided for @weekdaySun.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get weekdaySun;

  /// No description provided for @weekdayMon.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get weekdayMon;

  /// No description provided for @weekdayTue.
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get weekdayTue;

  /// No description provided for @weekdayWed.
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get weekdayWed;

  /// No description provided for @weekdayThu.
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get weekdayThu;

  /// No description provided for @weekdayFri.
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get weekdayFri;

  /// No description provided for @weekdaySat.
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get weekdaySat;

  /// No description provided for @timelineGuarantorCall.
  ///
  /// In en, this message translates to:
  /// **'Guarantor call · {outcome}'**
  String timelineGuarantorCall(String outcome);

  /// No description provided for @guarantorNoName.
  ///
  /// In en, this message translates to:
  /// **'No name'**
  String get guarantorNoName;

  /// No description provided for @guarantorCall.
  ///
  /// In en, this message translates to:
  /// **'Call the guarantor'**
  String get guarantorCall;

  /// No description provided for @guarantorCallShort.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get guarantorCallShort;

  /// No description provided for @guarantorNoPhone.
  ///
  /// In en, this message translates to:
  /// **'No phone number'**
  String get guarantorNoPhone;

  /// No description provided for @planCreditSale.
  ///
  /// In en, this message translates to:
  /// **'Credit sale'**
  String get planCreditSale;

  /// No description provided for @planPayBy.
  ///
  /// In en, this message translates to:
  /// **'Pay by {date}'**
  String planPayBy(String date);

  /// No description provided for @planReturned.
  ///
  /// In en, this message translates to:
  /// **'Returned in the ERP · not collectable'**
  String get planReturned;

  /// No description provided for @planCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled in the ERP · not collectable'**
  String get planCancelled;

  /// No description provided for @planFreqMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get planFreqMonthly;

  /// No description provided for @planFreqWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get planFreqWeekly;

  /// No description provided for @planFreqDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get planFreqDaily;

  /// No description provided for @planFreqEveryNDays.
  ///
  /// In en, this message translates to:
  /// **'Every {n} days'**
  String planFreqEveryNDays(String n);

  /// No description provided for @planFreqCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom dates'**
  String get planFreqCustom;

  /// No description provided for @planProducts.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get planProducts;

  /// No description provided for @planSerials.
  ///
  /// In en, this message translates to:
  /// **'Serial: {list}'**
  String planSerials(String list);

  /// No description provided for @planGuarantor.
  ///
  /// In en, this message translates to:
  /// **'Guarantor for this plan'**
  String get planGuarantor;

  /// No description provided for @planWrittenOff.
  ///
  /// In en, this message translates to:
  /// **'Written off {amount}'**
  String planWrittenOff(String amount);

  /// No description provided for @scheduleLateFee.
  ///
  /// In en, this message translates to:
  /// **'incl. late fee {amount}'**
  String scheduleLateFee(String amount);

  /// No description provided for @scheduleLinePaidOn.
  ///
  /// In en, this message translates to:
  /// **'Paid on {date}'**
  String scheduleLinePaidOn(String date);

  /// No description provided for @scheduleDaysLate.
  ///
  /// In en, this message translates to:
  /// **'{days} days late'**
  String scheduleDaysLate(String days);

  /// No description provided for @scheduleMissed.
  ///
  /// In en, this message translates to:
  /// **'Missed'**
  String get scheduleMissed;

  /// No description provided for @scheduleLinePayments.
  ///
  /// In en, this message translates to:
  /// **'Payments for installment {seq}'**
  String scheduleLinePayments(String seq);

  /// No description provided for @scheduleReceiptNo.
  ///
  /// In en, this message translates to:
  /// **'Receipt {no}'**
  String scheduleReceiptNo(String no);

  /// No description provided for @schedulePaidOf.
  ///
  /// In en, this message translates to:
  /// **'Paid {paid} · left {left}'**
  String schedulePaidOf(String paid, String left);

  /// No description provided for @planTotal.
  ///
  /// In en, this message translates to:
  /// **'Invoice total'**
  String get planTotal;

  /// No description provided for @planPaidSoFar.
  ///
  /// In en, this message translates to:
  /// **'Paid so far'**
  String get planPaidSoFar;

  /// No description provided for @planLeft.
  ///
  /// In en, this message translates to:
  /// **'Outstanding'**
  String get planLeft;

  /// No description provided for @planRemainingInstallments.
  ///
  /// In en, this message translates to:
  /// **'{n} remaining'**
  String planRemainingInstallments(String n);

  /// No description provided for @phoneErpPrimary.
  ///
  /// In en, this message translates to:
  /// **'ERP'**
  String get phoneErpPrimary;

  /// No description provided for @phoneAdded.
  ///
  /// In en, this message translates to:
  /// **'Added'**
  String get phoneAdded;

  /// No description provided for @phoneAddNumber.
  ///
  /// In en, this message translates to:
  /// **'Add number'**
  String get phoneAddNumber;

  /// No description provided for @phoneAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Add phone numbers'**
  String get phoneAddTitle;

  /// No description provided for @phoneAddHint.
  ///
  /// In en, this message translates to:
  /// **'You can add several numbers at once. The ERP number stays as it is.'**
  String get phoneAddHint;

  /// No description provided for @phoneNumberN.
  ///
  /// In en, this message translates to:
  /// **'Number {n}'**
  String phoneNumberN(String n);

  /// No description provided for @phoneWhose.
  ///
  /// In en, this message translates to:
  /// **'Whose number'**
  String get phoneWhose;

  /// No description provided for @phoneWhoseHint.
  ///
  /// In en, this message translates to:
  /// **'wife, shop, son'**
  String get phoneWhoseHint;

  /// No description provided for @phoneDropRow.
  ///
  /// In en, this message translates to:
  /// **'Drop number {n}'**
  String phoneDropRow(String n);

  /// No description provided for @phoneAnother.
  ///
  /// In en, this message translates to:
  /// **'Another number'**
  String get phoneAnother;

  /// No description provided for @phoneErrInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a Bangladesh mobile number (01XXXXXXXXX)'**
  String get phoneErrInvalid;

  /// No description provided for @phoneErrDuplicate.
  ///
  /// In en, this message translates to:
  /// **'The customer already has this number'**
  String get phoneErrDuplicate;

  /// No description provided for @phoneErrRepeated.
  ///
  /// In en, this message translates to:
  /// **'This number is typed twice'**
  String get phoneErrRepeated;

  /// No description provided for @phoneErrEmpty.
  ///
  /// In en, this message translates to:
  /// **'Type at least one number'**
  String get phoneErrEmpty;

  /// No description provided for @phoneKeptHere.
  ///
  /// In en, this message translates to:
  /// **'These numbers stay in the field system. They are not sent to the ERP.'**
  String get phoneKeptHere;

  /// No description provided for @phoneSave.
  ///
  /// In en, this message translates to:
  /// **'Save numbers'**
  String get phoneSave;

  /// No description provided for @phoneSavedN.
  ///
  /// In en, this message translates to:
  /// **'Numbers added: {n}'**
  String phoneSavedN(String n);

  /// No description provided for @phonePending.
  ///
  /// In en, this message translates to:
  /// **'Waiting to be sent to the server'**
  String get phonePending;

  /// No description provided for @phoneRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove number'**
  String get phoneRemove;

  /// No description provided for @phoneRemoveTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove this number?'**
  String get phoneRemoveTitle;

  /// No description provided for @phoneRemoveBody.
  ///
  /// In en, this message translates to:
  /// **'{number} will be removed from the customer. Only numbers added in the field can be removed; the office\'s numbers stay.'**
  String phoneRemoveBody(String number);

  /// No description provided for @phoneRemoved.
  ///
  /// In en, this message translates to:
  /// **'Number removed'**
  String get phoneRemoved;

  /// No description provided for @phoneRemoveOffline.
  ///
  /// In en, this message translates to:
  /// **'Internet is needed to remove a number. Try again when online.'**
  String get phoneRemoveOffline;

  /// No description provided for @phoneRemoveNotAllowed.
  ///
  /// In en, this message translates to:
  /// **'This number cannot be removed.'**
  String get phoneRemoveNotAllowed;

  /// No description provided for @receiptView.
  ///
  /// In en, this message translates to:
  /// **'Receipt'**
  String get receiptView;

  /// No description provided for @receiptOpenCustomer.
  ///
  /// In en, this message translates to:
  /// **'Open customer'**
  String get receiptOpenCustomer;

  /// No description provided for @receiptNotOnPhone.
  ///
  /// In en, this message translates to:
  /// **'This receipt is not on this phone'**
  String get receiptNotOnPhone;

  /// No description provided for @cashInHandOpen.
  ///
  /// In en, this message translates to:
  /// **'Which collections is this cash from?'**
  String get cashInHandOpen;

  /// No description provided for @cashInHandTitle.
  ///
  /// In en, this message translates to:
  /// **'Cash on hand, by collection'**
  String get cashInHandTitle;

  /// No description provided for @cashInHandInvoice.
  ///
  /// In en, this message translates to:
  /// **'Invoice {no}'**
  String cashInHandInvoice(String no);

  /// No description provided for @cashInHandPartOf.
  ///
  /// In en, this message translates to:
  /// **'left of {amount}'**
  String cashInHandPartOf(String amount);

  /// No description provided for @cashInHandPendingDeposits.
  ///
  /// In en, this message translates to:
  /// **'{amount} handed in by earlier deposits'**
  String cashInHandPendingDeposits(String amount);

  /// No description provided for @cashInHandUnsent.
  ///
  /// In en, this message translates to:
  /// **'Some money on this phone has not reached the server yet; it is not in this list.'**
  String get cashInHandUnsent;

  /// No description provided for @cashInHandEmpty.
  ///
  /// In en, this message translates to:
  /// **'No cash on hand.'**
  String get cashInHandEmpty;

  /// No description provided for @cashInHandMore.
  ///
  /// In en, this message translates to:
  /// **'{n} older collections are not listed; the total above includes them.'**
  String cashInHandMore(String n);

  /// No description provided for @cashInHandHow.
  ///
  /// In en, this message translates to:
  /// **'A deposit hands in all the cash and every mobile or bank collection you hold at once, and they then go to the ERP. Until you deposit, each line can be changed or deleted; after it, nothing can. Tap a line to open the customer.'**
  String get cashInHandHow;

  /// No description provided for @cashActionEdit.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get cashActionEdit;

  /// No description provided for @cashActionDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get cashActionDelete;

  /// No description provided for @cashEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Change this collection'**
  String get cashEditTitle;

  /// No description provided for @cashEditAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount (৳)'**
  String get cashEditAmount;

  /// No description provided for @cashEditNote.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get cashEditNote;

  /// No description provided for @cashEditPayer.
  ///
  /// In en, this message translates to:
  /// **'Paid by'**
  String get cashEditPayer;

  /// No description provided for @cashEditSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get cashEditSave;

  /// No description provided for @cashDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this collection?'**
  String get cashDeleteTitle;

  /// No description provided for @cashDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'{amount} from {customer} will be removed from your cash in hand. The receipt number stays used and the line stays in the history as deleted.'**
  String cashDeleteBody(String amount, String customer);

  /// No description provided for @cashDeleteReason.
  ///
  /// In en, this message translates to:
  /// **'Reason (optional)'**
  String get cashDeleteReason;

  /// No description provided for @cashDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get cashDeleteConfirm;

  /// No description provided for @cashActionDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get cashActionDone;

  /// No description provided for @cashActionOffline.
  ///
  /// In en, this message translates to:
  /// **'This needs internet. Try again when you are online.'**
  String get cashActionOffline;

  /// No description provided for @cashActionCovered.
  ///
  /// In en, this message translates to:
  /// **'This collection is already deposited, so it cannot be changed or deleted.'**
  String get cashActionCovered;

  /// No description provided for @cashActionNotEditable.
  ///
  /// In en, this message translates to:
  /// **'This collection is already with the ERP and cannot be changed here. Ask the office.'**
  String get cashActionNotEditable;

  /// No description provided for @cashActionPosted.
  ///
  /// In en, this message translates to:
  /// **'This collection is already posted to the ERP. Ask the office.'**
  String get cashActionPosted;

  /// No description provided for @cashActionBusy.
  ///
  /// In en, this message translates to:
  /// **'It is being sent to the ERP right now. Try again in a minute.'**
  String get cashActionBusy;

  /// No description provided for @cashActionNotAllowed.
  ///
  /// In en, this message translates to:
  /// **'You cannot change this collection.'**
  String get cashActionNotAllowed;

  /// No description provided for @cashActionFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not do it. Try again.'**
  String get cashActionFailed;

  /// No description provided for @collectionEditedWas.
  ///
  /// In en, this message translates to:
  /// **'edited · was {amount}'**
  String collectionEditedWas(String amount);

  /// No description provided for @collectionDeletedTag.
  ///
  /// In en, this message translates to:
  /// **'deleted'**
  String get collectionDeletedTag;

  /// No description provided for @cashInHandOffline.
  ///
  /// In en, this message translates to:
  /// **'This list needs the internet'**
  String get cashInHandOffline;

  /// No description provided for @boardTabCollection.
  ///
  /// In en, this message translates to:
  /// **'Collection board'**
  String get boardTabCollection;

  /// No description provided for @boardTabBranch.
  ///
  /// In en, this message translates to:
  /// **'Branch ranking'**
  String get boardTabBranch;

  /// No description provided for @boardAllTime.
  ///
  /// In en, this message translates to:
  /// **'All time'**
  String get boardAllTime;

  /// No description provided for @boardMyRank.
  ///
  /// In en, this message translates to:
  /// **'You are {rank} of {of} · verified {amount}'**
  String boardMyRank(String rank, String of, String amount);

  /// No description provided for @boardNotRankedMe.
  ///
  /// In en, this message translates to:
  /// **'Nothing of yours is verified in this period yet.'**
  String get boardNotRankedMe;

  /// No description provided for @boardCount.
  ///
  /// In en, this message translates to:
  /// **'{n} collections'**
  String boardCount(String n);

  /// No description provided for @boardRoleManager.
  ///
  /// In en, this message translates to:
  /// **'Manager'**
  String get boardRoleManager;

  /// No description provided for @boardRoleAdmin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get boardRoleAdmin;

  /// No description provided for @boardRoleOffice.
  ///
  /// In en, this message translates to:
  /// **'Office'**
  String get boardRoleOffice;

  /// No description provided for @boardNoPosted.
  ///
  /// In en, this message translates to:
  /// **'Nothing verified yet'**
  String get boardNoPosted;

  /// No description provided for @boardEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nobody has a verified collection in this period yet.'**
  String get boardEmpty;

  /// No description provided for @boardFootnoteAll.
  ///
  /// In en, this message translates to:
  /// **'Only collections the ERP has accepted are counted; money still waiting for the ERP is not. Every branch is on this board.'**
  String get boardFootnoteAll;

  /// No description provided for @boardFootnoteBranch.
  ///
  /// In en, this message translates to:
  /// **'Only collections the ERP has accepted are counted; money still waiting for the ERP is not. This board shows your branch.'**
  String get boardFootnoteBranch;

  /// No description provided for @boardCrown.
  ///
  /// In en, this message translates to:
  /// **'First place'**
  String get boardCrown;

  /// No description provided for @alertsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get alertsTitle;

  /// No description provided for @alertsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing is waiting for you'**
  String get alertsEmptyTitle;

  /// No description provided for @alertsEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Promises due today, new tasks, co-work requests and notices from the office show here.'**
  String get alertsEmptyBody;

  /// No description provided for @alertPromiseToday.
  ///
  /// In en, this message translates to:
  /// **'Promised {amount} for today'**
  String alertPromiseToday(String amount);

  /// No description provided for @alertNewTask.
  ///
  /// In en, this message translates to:
  /// **'New task: {title}'**
  String alertNewTask(String title);

  /// No description provided for @alertCoworkInvite.
  ///
  /// In en, this message translates to:
  /// **'{name} asks you to work together'**
  String alertCoworkInvite(String name);

  /// No description provided for @alertNoticeUnread.
  ///
  /// In en, this message translates to:
  /// **'Notice from the office, not read yet'**
  String get alertNoticeUnread;

  /// No description provided for @alertNoticeMustRead.
  ///
  /// In en, this message translates to:
  /// **'Notice from the office: please confirm you read it'**
  String get alertNoticeMustRead;

  /// No description provided for @alertHandoverWaiting.
  ///
  /// In en, this message translates to:
  /// **'Handover waiting for your answer'**
  String get alertHandoverWaiting;

  /// No description provided for @filterAllBranches.
  ///
  /// In en, this message translates to:
  /// **'All branches'**
  String get filterAllBranches;

  /// No description provided for @farTitle.
  ///
  /// In en, this message translates to:
  /// **'Far from the customer\'s pin'**
  String get farTitle;

  /// No description provided for @farBody.
  ///
  /// In en, this message translates to:
  /// **'You are {distance} from the customer\'s pin. You can still record it; the office will see the distance.'**
  String farBody(String distance);

  /// No description provided for @farConfirm.
  ///
  /// In en, this message translates to:
  /// **'Record anyway'**
  String get farConfirm;

  /// No description provided for @attTilePending.
  ///
  /// In en, this message translates to:
  /// **'Not given yet'**
  String get attTilePending;

  /// No description provided for @attTileDone.
  ///
  /// In en, this message translates to:
  /// **'Given'**
  String get attTileDone;

  /// No description provided for @perfWorkHistory.
  ///
  /// In en, this message translates to:
  /// **'Work of each day'**
  String get perfWorkHistory;

  /// No description provided for @workPosted.
  ///
  /// In en, this message translates to:
  /// **'Posted in ERP'**
  String get workPosted;

  /// No description provided for @workPromises.
  ///
  /// In en, this message translates to:
  /// **'Promises'**
  String get workPromises;

  /// No description provided for @workEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No work recorded on this day'**
  String get workEmptyTitle;

  /// No description provided for @workTabMine.
  ///
  /// In en, this message translates to:
  /// **'My work'**
  String get workTabMine;

  /// No description provided for @workTabTeam.
  ///
  /// In en, this message translates to:
  /// **'Other staff'**
  String get workTabTeam;

  /// No description provided for @teamEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No work by other staff on this day'**
  String get teamEmptyTitle;

  /// No description provided for @teamEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Visits, promises, collections and pins of your branch colleagues show here with their names.'**
  String get teamEmptyBody;

  /// No description provided for @alertsTeamSection.
  ///
  /// In en, this message translates to:
  /// **'Other staff today'**
  String get alertsTeamSection;

  /// No description provided for @alertsTeamMore.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get alertsTeamMore;

  /// No description provided for @workEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Visits, collections, promises, notes, pins, calls and finished tasks show here.'**
  String get workEmptyBody;

  /// No description provided for @workPrevDay.
  ///
  /// In en, this message translates to:
  /// **'Previous day'**
  String get workPrevDay;

  /// No description provided for @workNextDay.
  ///
  /// In en, this message translates to:
  /// **'Next day'**
  String get workNextDay;

  /// No description provided for @workPin.
  ///
  /// In en, this message translates to:
  /// **'Map pin sent'**
  String get workPin;

  /// No description provided for @workTaskDone.
  ///
  /// In en, this message translates to:
  /// **'Reported done: {title}'**
  String workTaskDone(String title);

  /// No description provided for @marksVisitToday.
  ///
  /// In en, this message translates to:
  /// **'Visited today'**
  String get marksVisitToday;

  /// No description provided for @marksVisitMonth.
  ///
  /// In en, this message translates to:
  /// **'Visited this month'**
  String get marksVisitMonth;

  /// No description provided for @marksVisitNone.
  ///
  /// In en, this message translates to:
  /// **'Not visited this month'**
  String get marksVisitNone;

  /// No description provided for @marksPaid.
  ///
  /// In en, this message translates to:
  /// **'Money in the ERP this month'**
  String get marksPaid;

  /// No description provided for @marksPending.
  ///
  /// In en, this message translates to:
  /// **'Collected, pending in ERP'**
  String get marksPending;

  /// No description provided for @marksPaidNone.
  ///
  /// In en, this message translates to:
  /// **'Nothing paid this month'**
  String get marksPaidNone;

  /// No description provided for @marksPromiseOpen.
  ///
  /// In en, this message translates to:
  /// **'Has an open promise'**
  String get marksPromiseOpen;

  /// No description provided for @marksPromiseNone.
  ///
  /// In en, this message translates to:
  /// **'No open promise'**
  String get marksPromiseNone;

  /// No description provided for @marksPinSet.
  ///
  /// In en, this message translates to:
  /// **'Map pin set'**
  String get marksPinSet;

  /// No description provided for @marksPinMissing.
  ///
  /// In en, this message translates to:
  /// **'No map pin'**
  String get marksPinMissing;

  /// No description provided for @monthTitle.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get monthTitle;

  /// No description provided for @monthLastVisit.
  ///
  /// In en, this message translates to:
  /// **'Last visit {date}'**
  String monthLastVisit(String date);

  /// No description provided for @monthPaid.
  ///
  /// In en, this message translates to:
  /// **'In the ERP: {amount}'**
  String monthPaid(String amount);

  /// No description provided for @monthPending.
  ///
  /// In en, this message translates to:
  /// **'Pending in ERP: {amount}'**
  String monthPending(String amount);

  /// No description provided for @monthPromise.
  ///
  /// In en, this message translates to:
  /// **'Promise on {date}'**
  String monthPromise(String date);

  /// No description provided for @monthInvoices.
  ///
  /// In en, this message translates to:
  /// **'Invoices: {total} · with a balance: {open}'**
  String monthInvoices(String total, String open);

  /// No description provided for @planRolledHidden.
  ///
  /// In en, this message translates to:
  /// **'{n} unpaid installments were moved to a later one in the ERP and are hidden'**
  String planRolledHidden(String n);

  /// No description provided for @detailDirections.
  ///
  /// In en, this message translates to:
  /// **'Directions'**
  String get detailDirections;

  /// No description provided for @detailNoAddress.
  ///
  /// In en, this message translates to:
  /// **'No address in the ERP'**
  String get detailNoAddress;

  /// No description provided for @erpRiskBadge.
  ///
  /// In en, this message translates to:
  /// **'ERP grade {grade}'**
  String erpRiskBadge(String grade);

  /// No description provided for @erpRiskLow.
  ///
  /// In en, this message translates to:
  /// **'low risk'**
  String get erpRiskLow;

  /// No description provided for @erpRiskMedium.
  ///
  /// In en, this message translates to:
  /// **'medium risk'**
  String get erpRiskMedium;

  /// No description provided for @erpRiskHigh.
  ///
  /// In en, this message translates to:
  /// **'high risk'**
  String get erpRiskHigh;

  /// No description provided for @timelineCollector.
  ///
  /// In en, this message translates to:
  /// **'by {name}'**
  String timelineCollector(String name);

  /// No description provided for @timelineVisitBy.
  ///
  /// In en, this message translates to:
  /// **'visited by {name}'**
  String timelineVisitBy(String name);

  /// No description provided for @timelinePromiseBy.
  ///
  /// In en, this message translates to:
  /// **'promise taken by {name}'**
  String timelinePromiseBy(String name);

  /// No description provided for @timelinePinBy.
  ///
  /// In en, this message translates to:
  /// **'pin set by {name}'**
  String timelinePinBy(String name);

  /// No description provided for @timelinePinSet.
  ///
  /// In en, this message translates to:
  /// **'Customer pin set'**
  String get timelinePinSet;

  /// No description provided for @timelinePinPending.
  ///
  /// In en, this message translates to:
  /// **'Customer pin proposed · waiting for approval'**
  String get timelinePinPending;

  /// No description provided for @timelinePinRejected.
  ///
  /// In en, this message translates to:
  /// **'Customer pin not approved'**
  String get timelinePinRejected;

  /// No description provided for @timelineAdvance.
  ///
  /// In en, this message translates to:
  /// **'advance'**
  String get timelineAdvance;

  /// No description provided for @timelineRemoved.
  ///
  /// In en, this message translates to:
  /// **'removed in the ERP'**
  String get timelineRemoved;

  /// No description provided for @collectSameDayWarning.
  ///
  /// In en, this message translates to:
  /// **'This invoice already has a payment today. The ERP takes one a day, so the office may need to decide on this one.'**
  String get collectSameDayWarning;

  /// No description provided for @customerAssignedToMe.
  ///
  /// In en, this message translates to:
  /// **'Your customer'**
  String get customerAssignedToMe;

  /// No description provided for @customerUnassigned.
  ///
  /// In en, this message translates to:
  /// **'Not assigned to anyone'**
  String get customerUnassigned;

  /// No description provided for @customerAssignedTo.
  ///
  /// In en, this message translates to:
  /// **'{name}\'s customer'**
  String customerAssignedTo(String name);

  /// No description provided for @customerBranch.
  ///
  /// In en, this message translates to:
  /// **'{branch} branch'**
  String customerBranch(String branch);

  /// No description provided for @tasksTitle.
  ///
  /// In en, this message translates to:
  /// **'My tasks'**
  String get tasksTitle;

  /// No description provided for @taskTitle.
  ///
  /// In en, this message translates to:
  /// **'Task'**
  String get taskTitle;

  /// No description provided for @tasksEmpty.
  ///
  /// In en, this message translates to:
  /// **'No tasks'**
  String get tasksEmpty;

  /// No description provided for @tasksEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Tasks the office gives you show here'**
  String get tasksEmptyBody;

  /// No description provided for @tasksSectionActive.
  ///
  /// In en, this message translates to:
  /// **'To do'**
  String get tasksSectionActive;

  /// No description provided for @tasksSectionWaiting.
  ///
  /// In en, this message translates to:
  /// **'Waiting for the office'**
  String get tasksSectionWaiting;

  /// No description provided for @tasksSectionClosed.
  ///
  /// In en, this message translates to:
  /// **'Finished'**
  String get tasksSectionClosed;

  /// No description provided for @taskStatusOpen.
  ///
  /// In en, this message translates to:
  /// **'To do'**
  String get taskStatusOpen;

  /// No description provided for @taskStatusQueued.
  ///
  /// In en, this message translates to:
  /// **'Will be sent'**
  String get taskStatusQueued;

  /// No description provided for @taskStatusWaiting.
  ///
  /// In en, this message translates to:
  /// **'Office is checking'**
  String get taskStatusWaiting;

  /// No description provided for @taskStatusResolved.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get taskStatusResolved;

  /// No description provided for @taskStatusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get taskStatusCancelled;

  /// No description provided for @taskStatusOverdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get taskStatusOverdue;

  /// No description provided for @taskNew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get taskNew;

  /// No description provided for @taskDue.
  ///
  /// In en, this message translates to:
  /// **'Due {date}'**
  String taskDue(String date);

  /// No description provided for @taskNoDue.
  ///
  /// In en, this message translates to:
  /// **'No due date'**
  String get taskNoDue;

  /// No description provided for @taskFrom.
  ///
  /// In en, this message translates to:
  /// **'From {name}'**
  String taskFrom(String name);

  /// No description provided for @taskNoteNone.
  ///
  /// In en, this message translates to:
  /// **'No note'**
  String get taskNoteNone;

  /// No description provided for @taskMarkDone.
  ///
  /// In en, this message translates to:
  /// **'The work is done'**
  String get taskMarkDone;

  /// No description provided for @taskDoneTitle.
  ///
  /// In en, this message translates to:
  /// **'Tell the office it is done'**
  String get taskDoneTitle;

  /// No description provided for @taskDoneBody.
  ///
  /// In en, this message translates to:
  /// **'The office checks it and then marks it resolved.'**
  String get taskDoneBody;

  /// No description provided for @taskDoneNoteHint.
  ///
  /// In en, this message translates to:
  /// **'What did you do? (optional)'**
  String get taskDoneNoteHint;

  /// No description provided for @taskDoneSend.
  ///
  /// In en, this message translates to:
  /// **'Send to the office'**
  String get taskDoneSend;

  /// No description provided for @taskDoneSent.
  ///
  /// In en, this message translates to:
  /// **'Saved. The office will check it'**
  String get taskDoneSent;

  /// No description provided for @taskQueuedBanner.
  ///
  /// In en, this message translates to:
  /// **'Saved on this phone at {time}. It goes to the office when there is a network.'**
  String taskQueuedBanner(String time);

  /// No description provided for @taskWaitingBanner.
  ///
  /// In en, this message translates to:
  /// **'Sent at {time}. The office will check it.'**
  String taskWaitingBanner(String time);

  /// No description provided for @taskResolvedBanner.
  ///
  /// In en, this message translates to:
  /// **'The office marked it done at {time}'**
  String taskResolvedBanner(String time);

  /// No description provided for @taskCancelledBanner.
  ///
  /// In en, this message translates to:
  /// **'The office cancelled this task'**
  String get taskCancelledBanner;

  /// No description provided for @taskRejectedBanner.
  ///
  /// In en, this message translates to:
  /// **'The office sent it back: {reason}'**
  String taskRejectedBanner(String reason);

  /// No description provided for @taskFailedBanner.
  ///
  /// In en, this message translates to:
  /// **'Your last request was not accepted. You can send it again.'**
  String get taskFailedBanner;

  /// No description provided for @taskMyNote.
  ///
  /// In en, this message translates to:
  /// **'Your note'**
  String get taskMyNote;

  /// No description provided for @taskOfficeNote.
  ///
  /// In en, this message translates to:
  /// **'Office note'**
  String get taskOfficeNote;

  /// No description provided for @taskDetails.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get taskDetails;

  /// No description provided for @taskHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get taskHistory;

  /// No description provided for @taskEventCreated.
  ///
  /// In en, this message translates to:
  /// **'Task given'**
  String get taskEventCreated;

  /// No description provided for @taskEventEdited.
  ///
  /// In en, this message translates to:
  /// **'Changed'**
  String get taskEventEdited;

  /// No description provided for @taskEventResolveRequested.
  ///
  /// In en, this message translates to:
  /// **'Marked as done'**
  String get taskEventResolveRequested;

  /// No description provided for @taskEventVerified.
  ///
  /// In en, this message translates to:
  /// **'Office verified'**
  String get taskEventVerified;

  /// No description provided for @taskEventRejected.
  ///
  /// In en, this message translates to:
  /// **'Sent back'**
  String get taskEventRejected;

  /// No description provided for @taskEventCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get taskEventCancelled;

  /// No description provided for @todayTasksOverdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue tasks: {n}'**
  String todayTasksOverdue(String n);

  /// No description provided for @todayTasksNew.
  ///
  /// In en, this message translates to:
  /// **'New tasks from the office: {n}'**
  String todayTasksNew(String n);

  /// No description provided for @todayTasksOpen.
  ///
  /// In en, this message translates to:
  /// **'Tasks to do: {n}'**
  String todayTasksOpen(String n);

  /// No description provided for @tasksOpenCount.
  ///
  /// In en, this message translates to:
  /// **'{n} to do'**
  String tasksOpenCount(String n);

  /// No description provided for @tasksNothingOpen.
  ///
  /// In en, this message translates to:
  /// **'Nothing to do'**
  String get tasksNothingOpen;

  /// No description provided for @exitAppTitle.
  ///
  /// In en, this message translates to:
  /// **'Close the app?'**
  String get exitAppTitle;

  /// No description provided for @exitAppBody.
  ///
  /// In en, this message translates to:
  /// **'Work that is not sent yet stays safe on this phone.'**
  String get exitAppBody;

  /// No description provided for @exitAppStay.
  ///
  /// In en, this message translates to:
  /// **'Stay'**
  String get exitAppStay;

  /// No description provided for @exitAppConfirm.
  ///
  /// In en, this message translates to:
  /// **'Close the app'**
  String get exitAppConfirm;

  /// No description provided for @visitAlreadyToday.
  ///
  /// In en, this message translates to:
  /// **'This customer was already visited {count} time(s) today (last at {time}). You can still record another visit.'**
  String visitAlreadyToday(String time, String count);

  /// No description provided for @primerRequired.
  ///
  /// In en, this message translates to:
  /// **'All permissions are needed to use this app'**
  String get primerRequired;

  /// No description provided for @primerDeniedLocation.
  ///
  /// In en, this message translates to:
  /// **'Location is required so your manager can track your field work. Tap to allow.'**
  String get primerDeniedLocation;

  /// No description provided for @primerDeniedCamera.
  ///
  /// In en, this message translates to:
  /// **'Camera is required for visit photos and selfies. Tap to allow.'**
  String get primerDeniedCamera;

  /// No description provided for @primerDeniedNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications are needed for reminders and messages. Tap to allow.'**
  String get primerDeniedNotifications;

  /// No description provided for @primerDeniedBattery.
  ///
  /// In en, this message translates to:
  /// **'Battery optimisation must be turned off so tracking keeps running. Tap to allow.'**
  String get primerDeniedBattery;

  /// No description provided for @primerOpenSettings.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get primerOpenSettings;

  /// No description provided for @primerDeniedForever.
  ///
  /// In en, this message translates to:
  /// **'You blocked this permission. Open phone settings to allow it.'**
  String get primerDeniedForever;

  /// No description provided for @locationGateTitle.
  ///
  /// In en, this message translates to:
  /// **'Turn on location'**
  String get locationGateTitle;

  /// No description provided for @locationGateBody.
  ///
  /// In en, this message translates to:
  /// **'Location must be on to use this app. Your manager needs to see where you are during work hours.'**
  String get locationGateBody;

  /// No description provided for @locationGatePermission.
  ///
  /// In en, this message translates to:
  /// **'Allow location permission'**
  String get locationGatePermission;

  /// No description provided for @locationGateService.
  ///
  /// In en, this message translates to:
  /// **'Turn on GPS / location'**
  String get locationGateService;

  /// No description provided for @locationGateOpenSettings.
  ///
  /// In en, this message translates to:
  /// **'Open location settings'**
  String get locationGateOpenSettings;

  /// No description provided for @locationGateRetry.
  ///
  /// In en, this message translates to:
  /// **'Check again'**
  String get locationGateRetry;

  /// No description provided for @attendanceNeedsLocation.
  ///
  /// In en, this message translates to:
  /// **'Location is required to record attendance. Turn on GPS and try again.'**
  String get attendanceNeedsLocation;

  /// No description provided for @locationGateBackground.
  ///
  /// In en, this message translates to:
  /// **'Allow \"All the time\" location so tracking works even when the screen is off.'**
  String get locationGateBackground;

  /// No description provided for @locationGateBackgroundSettings.
  ///
  /// In en, this message translates to:
  /// **'Open permission settings'**
  String get locationGateBackgroundSettings;

  /// No description provided for @gpsStatusOn.
  ///
  /// In en, this message translates to:
  /// **'GPS is on'**
  String get gpsStatusOn;

  /// No description provided for @gpsStatusOff.
  ///
  /// In en, this message translates to:
  /// **'GPS is off'**
  String get gpsStatusOff;

  /// No description provided for @gpsStatusMock.
  ///
  /// In en, this message translates to:
  /// **'Fake GPS detected!'**
  String get gpsStatusMock;

  /// No description provided for @gpsTurnOn.
  ///
  /// In en, this message translates to:
  /// **'Turn on GPS'**
  String get gpsTurnOn;

  /// No description provided for @gpsMockWarning.
  ///
  /// In en, this message translates to:
  /// **'Fake/mock location is not allowed. Disable mock locations to continue.'**
  String get gpsMockWarning;

  /// No description provided for @gpsRequiredForAttendance.
  ///
  /// In en, this message translates to:
  /// **'GPS must be turned on to record attendance.'**
  String get gpsRequiredForAttendance;

  /// No description provided for @gpsRequiredForBreak.
  ///
  /// In en, this message translates to:
  /// **'GPS must be turned on to start or end break.'**
  String get gpsRequiredForBreak;

  /// No description provided for @gpsRequiredForWorkOut.
  ///
  /// In en, this message translates to:
  /// **'GPS must be turned on to end work.'**
  String get gpsRequiredForWorkOut;

  /// No description provided for @statusDeposited.
  ///
  /// In en, this message translates to:
  /// **'Deposited'**
  String get statusDeposited;

  /// No description provided for @statusDepositFailed.
  ///
  /// In en, this message translates to:
  /// **'Not deposited'**
  String get statusDepositFailed;

  /// No description provided for @cashDepositCash.
  ///
  /// In en, this message translates to:
  /// **'Cash (all you hold)'**
  String get cashDepositCash;

  /// No description provided for @cashDepositNonCash.
  ///
  /// In en, this message translates to:
  /// **'Mobile / bank'**
  String get cashDepositNonCash;

  /// No description provided for @cashDepositNonCashCount.
  ///
  /// In en, this message translates to:
  /// **'{count} collections'**
  String cashDepositNonCashCount(String count);

  /// No description provided for @cashDepositTotalCount.
  ///
  /// In en, this message translates to:
  /// **'{count} collections in all'**
  String cashDepositTotalCount(String count);

  /// No description provided for @cashDepositAllHint.
  ///
  /// In en, this message translates to:
  /// **'No part deposits: all the cash you hold and every mobile or bank collection go together, and then go to the ERP.'**
  String get cashDepositAllHint;

  /// No description provided for @cashDepositNothing.
  ///
  /// In en, this message translates to:
  /// **'Nothing in hand to deposit.'**
  String get cashDepositNothing;

  /// No description provided for @cashDepositSubmit.
  ///
  /// In en, this message translates to:
  /// **'Deposit'**
  String get cashDepositSubmit;

  /// No description provided for @cashDepositConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm the deposit'**
  String get cashDepositConfirmTitle;

  /// No description provided for @cashDepositConfirmOnline.
  ///
  /// In en, this message translates to:
  /// **'Depositing {cash} cash and {nonCash} mobile/bank ({count} collections) sends them to the ERP as payments right away when online. After the deposit they cannot be changed or deleted.'**
  String cashDepositConfirmOnline(String cash, String nonCash, String count);

  /// No description provided for @cashDepositConfirmOffline.
  ///
  /// In en, this message translates to:
  /// **'There is no internet now. Depositing {cash} cash and {nonCash} mobile/bank ({count} collections) sends them to the ERP as payments as soon as the phone is online. After the deposit they cannot be changed or deleted.'**
  String cashDepositConfirmOffline(String cash, String nonCash, String count);

  /// No description provided for @cashDepositChanged.
  ///
  /// In en, this message translates to:
  /// **'The money in hand just changed. Check it and deposit again.'**
  String get cashDepositChanged;

  /// No description provided for @cashDepositLine.
  ///
  /// In en, this message translates to:
  /// **'{count} collections · mobile/bank {amount}'**
  String cashDepositLine(String count, String amount);

  /// No description provided for @cashDepositWaitingLock.
  ///
  /// In en, this message translates to:
  /// **'A deposit is still waiting to be sent, so nothing in hand can be changed or deleted now.'**
  String get cashDepositWaitingLock;

  /// No description provided for @cashSlipTitle.
  ///
  /// In en, this message translates to:
  /// **'Bank deposit slip'**
  String get cashSlipTitle;

  /// No description provided for @cashSlipNeeded.
  ///
  /// In en, this message translates to:
  /// **'A bank deposit needs a photo of the deposit slip. Camera only.'**
  String get cashSlipNeeded;

  /// No description provided for @cashSlipTake.
  ///
  /// In en, this message translates to:
  /// **'Take a photo of the slip'**
  String get cashSlipTake;

  /// No description provided for @cashSlipRetake.
  ///
  /// In en, this message translates to:
  /// **'Retake'**
  String get cashSlipRetake;

  /// No description provided for @cashSlipUploading.
  ///
  /// In en, this message translates to:
  /// **'The deposit is sent once its slip photo is uploaded.'**
  String get cashSlipUploading;

  /// No description provided for @cashInHandNonCashTitle.
  ///
  /// In en, this message translates to:
  /// **'Mobile / bank collections (go with the deposit)'**
  String get cashInHandNonCashTitle;

  /// No description provided for @cashInHandNotSent.
  ///
  /// In en, this message translates to:
  /// **'Not sent yet; it can be changed once it is sent'**
  String get cashInHandNotSent;

  /// No description provided for @depositFailedMustBeAll.
  ///
  /// In en, this message translates to:
  /// **'Not deposited: the server says you hold more cash than this deposit (something changed meanwhile). A deposit must take all of it.'**
  String get depositFailedMustBeAll;

  /// No description provided for @depositFailedExceeds.
  ///
  /// In en, this message translates to:
  /// **'Not deposited: the server says you hold less cash than this deposit (a collection was left out or changed).'**
  String get depositFailedExceeds;

  /// No description provided for @depositFailedNothing.
  ///
  /// In en, this message translates to:
  /// **'Not deposited: there was nothing in hand to deposit.'**
  String get depositFailedNothing;

  /// No description provided for @depositFailedSlip.
  ///
  /// In en, this message translates to:
  /// **'Not deposited: the server got no slip photo for this bank deposit. Deposit again and take a photo of the slip, or deposit to the branch cashier or the manager.'**
  String get depositFailedSlip;

  /// No description provided for @depositFailedChanged.
  ///
  /// In en, this message translates to:
  /// **'Not deposited: a collection was changed or cancelled while it was being deposited.'**
  String get depositFailedChanged;

  /// No description provided for @depositFailedOther.
  ///
  /// In en, this message translates to:
  /// **'Not deposited ({code}).'**
  String depositFailedOther(String code);

  /// No description provided for @depositFailedBack.
  ///
  /// In en, this message translates to:
  /// **'The collections are back in your hand and can be changed. Deposit again.'**
  String get depositFailedBack;

  /// No description provided for @depositAgain.
  ///
  /// In en, this message translates to:
  /// **'Deposit again'**
  String get depositAgain;

  /// No description provided for @collectWhichInvoice.
  ///
  /// In en, this message translates to:
  /// **'Which invoice'**
  String get collectWhichInvoice;

  /// No description provided for @collectInvoiceCount.
  ///
  /// In en, this message translates to:
  /// **'{count} open invoices for this customer — pick the right one'**
  String collectInvoiceCount(String count);

  /// No description provided for @customerRefresh.
  ///
  /// In en, this message translates to:
  /// **'Reload from server'**
  String get customerRefresh;

  /// No description provided for @customerRefreshDone.
  ///
  /// In en, this message translates to:
  /// **'Updated from the server'**
  String get customerRefreshDone;

  /// No description provided for @customerRefreshOffline.
  ///
  /// In en, this message translates to:
  /// **'Needs internet. Showing the data saved on this phone.'**
  String get customerRefreshOffline;

  /// No description provided for @customerRefreshBusy.
  ///
  /// In en, this message translates to:
  /// **'The ERP is busy. Try again in a minute.'**
  String get customerRefreshBusy;

  /// No description provided for @customerRefreshNotFound.
  ///
  /// In en, this message translates to:
  /// **'The server no longer has this customer for you. The data on this phone is kept.'**
  String get customerRefreshNotFound;

  /// No description provided for @customerRefreshDenied.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have permission to reload this customer.'**
  String get customerRefreshDenied;

  /// No description provided for @customerRefreshFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t reload. Showing the saved data. Code: {code}'**
  String customerRefreshFailed(String code);

  /// No description provided for @placeIconShop.
  ///
  /// In en, this message translates to:
  /// **'Shop'**
  String get placeIconShop;

  /// No description provided for @placeIconMarket.
  ///
  /// In en, this message translates to:
  /// **'Market'**
  String get placeIconMarket;

  /// No description provided for @placeIconMosque.
  ///
  /// In en, this message translates to:
  /// **'Mosque'**
  String get placeIconMosque;

  /// No description provided for @placeIconSchool.
  ///
  /// In en, this message translates to:
  /// **'School'**
  String get placeIconSchool;

  /// No description provided for @placeIconBank.
  ///
  /// In en, this message translates to:
  /// **'Bank'**
  String get placeIconBank;

  /// No description provided for @placeIconHospital.
  ///
  /// In en, this message translates to:
  /// **'Hospital'**
  String get placeIconHospital;

  /// No description provided for @placeIconBusStop.
  ///
  /// In en, this message translates to:
  /// **'Bus stop'**
  String get placeIconBusStop;

  /// No description provided for @placeIconOffice.
  ///
  /// In en, this message translates to:
  /// **'Office'**
  String get placeIconOffice;

  /// No description provided for @placeIconLandmark.
  ///
  /// In en, this message translates to:
  /// **'Landmark'**
  String get placeIconLandmark;

  /// No description provided for @placeIconOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get placeIconOther;

  /// No description provided for @placeNewTitle.
  ///
  /// In en, this message translates to:
  /// **'New place on the map'**
  String get placeNewTitle;

  /// No description provided for @placeEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Change this place'**
  String get placeEditTitle;

  /// No description provided for @placeNewHint.
  ///
  /// In en, this message translates to:
  /// **'Everyone in your branch sees the name next to the marker.'**
  String get placeNewHint;

  /// No description provided for @placeName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get placeName;

  /// No description provided for @placeNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Karim Store'**
  String get placeNameHint;

  /// No description provided for @placeNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Write a name'**
  String get placeNameRequired;

  /// No description provided for @placeKind.
  ///
  /// In en, this message translates to:
  /// **'Kind of place'**
  String get placeKind;

  /// No description provided for @placeNote.
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get placeNote;

  /// No description provided for @placeNoteHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Blue gate, next to the tea stall'**
  String get placeNoteHint;

  /// No description provided for @placeAdd.
  ///
  /// In en, this message translates to:
  /// **'Add to the map'**
  String get placeAdd;

  /// No description provided for @placeSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get placeSave;

  /// No description provided for @placeSavedNew.
  ///
  /// In en, this message translates to:
  /// **'{name} is on the map'**
  String placeSavedNew(String name);

  /// No description provided for @placeSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get placeSaved;

  /// No description provided for @placeGone.
  ///
  /// In en, this message translates to:
  /// **'This place is no longer on the map.'**
  String get placeGone;

  /// No description provided for @placeAddedByMe.
  ///
  /// In en, this message translates to:
  /// **'You added this place'**
  String get placeAddedByMe;

  /// No description provided for @placeAddedBy.
  ///
  /// In en, this message translates to:
  /// **'Added by {name}'**
  String placeAddedBy(String name);

  /// No description provided for @placeWaitingToSend.
  ///
  /// In en, this message translates to:
  /// **'Saved on the phone; it is sent when there is internet.'**
  String get placeWaitingToSend;

  /// No description provided for @placeMoveQueued.
  ///
  /// In en, this message translates to:
  /// **'Your move request is saved and is sent when there is internet. The marker stays until the office approves.'**
  String get placeMoveQueued;

  /// No description provided for @placeMovePending.
  ///
  /// In en, this message translates to:
  /// **'{name} asked to move it; waiting for the office.'**
  String placeMovePending(String name);

  /// No description provided for @placeMoveApproved.
  ///
  /// In en, this message translates to:
  /// **'The office moved it as asked.'**
  String get placeMoveApproved;

  /// No description provided for @placeMoveRejected.
  ///
  /// In en, this message translates to:
  /// **'The office did not move it: {reason}'**
  String placeMoveRejected(String reason);

  /// No description provided for @placeEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get placeEdit;

  /// No description provided for @placeRequestMove.
  ///
  /// In en, this message translates to:
  /// **'Ask to move'**
  String get placeRequestMove;

  /// No description provided for @placeUpdatedAt.
  ///
  /// In en, this message translates to:
  /// **'Last change {at}'**
  String placeUpdatedAt(String at);

  /// No description provided for @placeErrMovePending.
  ///
  /// In en, this message translates to:
  /// **'Someone else already asked to move it.'**
  String get placeErrMovePending;

  /// No description provided for @placeErrMoveTooShort.
  ///
  /// In en, this message translates to:
  /// **'The new point is almost the same as the old one.'**
  String get placeErrMoveTooShort;

  /// No description provided for @placeErrOutside.
  ///
  /// In en, this message translates to:
  /// **'This point is outside Bangladesh.'**
  String get placeErrOutside;

  /// No description provided for @placeErrNotOwner.
  ///
  /// In en, this message translates to:
  /// **'Only the person who added it or the office can change it.'**
  String get placeErrNotOwner;

  /// No description provided for @placeErrGeneric.
  ///
  /// In en, this message translates to:
  /// **'The server did not accept this change.'**
  String get placeErrGeneric;

  /// No description provided for @placeMoveTitle.
  ///
  /// In en, this message translates to:
  /// **'Move {name}'**
  String placeMoveTitle(String name);

  /// No description provided for @placeMoveHint.
  ///
  /// In en, this message translates to:
  /// **'Move the map until the pin sits on the right spot.'**
  String get placeMoveHint;

  /// No description provided for @placeMoveDistance.
  ///
  /// In en, this message translates to:
  /// **'{n} m from where it is now'**
  String placeMoveDistance(String n);

  /// No description provided for @placeMoveReason.
  ///
  /// In en, this message translates to:
  /// **'Why? (optional)'**
  String get placeMoveReason;

  /// No description provided for @placeMoveSent.
  ///
  /// In en, this message translates to:
  /// **'Sent to the office. The marker moves when they approve.'**
  String get placeMoveSent;

  /// No description provided for @placeMoveDragFirst.
  ///
  /// In en, this message translates to:
  /// **'Move the map first'**
  String get placeMoveDragFirst;

  /// No description provided for @placeMoveSend.
  ///
  /// In en, this message translates to:
  /// **'Send to the office'**
  String get placeMoveSend;

  /// No description provided for @placeMoveNow.
  ///
  /// In en, this message translates to:
  /// **'Move'**
  String get placeMoveNow;

  /// No description provided for @placeMoveNowHint.
  ///
  /// In en, this message translates to:
  /// **'Move the map until the pin sits on the right spot. The marker moves as soon as you save, even without internet.'**
  String get placeMoveNowHint;

  /// No description provided for @placeMoveNowSave.
  ///
  /// In en, this message translates to:
  /// **'Move here'**
  String get placeMoveNowSave;

  /// No description provided for @placeMovedNow.
  ///
  /// In en, this message translates to:
  /// **'Moved. It is sent to the server when there is internet.'**
  String get placeMovedNow;

  /// No description provided for @syncEntityPlace.
  ///
  /// In en, this message translates to:
  /// **'Map place'**
  String get syncEntityPlace;

  /// No description provided for @placeProblem.
  ///
  /// In en, this message translates to:
  /// **'{name}: {reason}'**
  String placeProblem(String name, String reason);

  /// No description provided for @placeProblemMoveBack.
  ///
  /// In en, this message translates to:
  /// **'The move was refused, so the marker is back where the server has it.'**
  String get placeProblemMoveBack;

  /// No description provided for @placeErrMoveNeedsManage.
  ///
  /// In en, this message translates to:
  /// **'Only the office can move a place directly.'**
  String get placeErrMoveNeedsManage;

  /// No description provided for @filterInstallment.
  ///
  /// In en, this message translates to:
  /// **'Installment'**
  String get filterInstallment;

  /// No description provided for @filterCredit.
  ///
  /// In en, this message translates to:
  /// **'Credit sale'**
  String get filterCredit;

  /// No description provided for @kindInstallment.
  ///
  /// In en, this message translates to:
  /// **'Installment'**
  String get kindInstallment;

  /// No description provided for @kindCredit.
  ///
  /// In en, this message translates to:
  /// **'Credit'**
  String get kindCredit;

  /// No description provided for @kindInstallmentCount.
  ///
  /// In en, this message translates to:
  /// **'{n} installment'**
  String kindInstallmentCount(String n);

  /// No description provided for @kindCreditCount.
  ///
  /// In en, this message translates to:
  /// **'{n} credit'**
  String kindCreditCount(String n);

  /// No description provided for @kindLabelA11y.
  ///
  /// In en, this message translates to:
  /// **'Open invoices: {kinds}'**
  String kindLabelA11y(String kinds);

  /// No description provided for @monthVisitWho.
  ///
  /// In en, this message translates to:
  /// **'Visit: {name}'**
  String monthVisitWho(String name);

  /// No description provided for @monthToday.
  ///
  /// In en, this message translates to:
  /// **'today'**
  String get monthToday;

  /// No description provided for @monthPaidAmount.
  ///
  /// In en, this message translates to:
  /// **'Paid: {amount}'**
  String monthPaidAmount(String amount);

  /// No description provided for @monthPromiseAmount.
  ///
  /// In en, this message translates to:
  /// **'Promise: {amount}'**
  String monthPromiseAmount(String amount);

  /// No description provided for @promisedBy.
  ///
  /// In en, this message translates to:
  /// **'Promised by {name}'**
  String promisedBy(String name);

  /// No description provided for @kindCash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get kindCash;

  /// No description provided for @kindCashCount.
  ///
  /// In en, this message translates to:
  /// **'{n} cash'**
  String kindCashCount(String n);

  /// No description provided for @planCashSale.
  ///
  /// In en, this message translates to:
  /// **'Cash sale'**
  String get planCashSale;

  /// No description provided for @monthOffice.
  ///
  /// In en, this message translates to:
  /// **'office'**
  String get monthOffice;

  /// No description provided for @monthMore.
  ///
  /// In en, this message translates to:
  /// **'+{n}'**
  String monthMore(String n);

  /// No description provided for @mediaQueueHint.
  ///
  /// In en, this message translates to:
  /// **'Photos go to the server on their own, separately from the other work. Nothing is deleted from this phone until the server has the photo.'**
  String get mediaQueueHint;

  /// No description provided for @mediaKindSelfie.
  ///
  /// In en, this message translates to:
  /// **'Attendance photo'**
  String get mediaKindSelfie;

  /// No description provided for @mediaKindVisit.
  ///
  /// In en, this message translates to:
  /// **'Visit photo'**
  String get mediaKindVisit;

  /// No description provided for @mediaKindSlip.
  ///
  /// In en, this message translates to:
  /// **'Deposit slip'**
  String get mediaKindSlip;

  /// No description provided for @mediaKindPin.
  ///
  /// In en, this message translates to:
  /// **'Map pin photo'**
  String get mediaKindPin;

  /// No description provided for @mediaKindOther.
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get mediaKindOther;

  /// No description provided for @mediaStateWaiting.
  ///
  /// In en, this message translates to:
  /// **'Waiting to upload'**
  String get mediaStateWaiting;

  /// No description provided for @mediaStateFailed.
  ///
  /// In en, this message translates to:
  /// **'Not uploaded yet: {reason}'**
  String mediaStateFailed(String reason);

  /// No description provided for @mediaNextTry.
  ///
  /// In en, this message translates to:
  /// **'Tried {tries} times · tries again at {time}'**
  String mediaNextTry(String tries, String time);

  /// No description provided for @mediaRetryAll.
  ///
  /// In en, this message translates to:
  /// **'Upload all now'**
  String get mediaRetryAll;

  /// No description provided for @mediaReasonNetwork.
  ///
  /// In en, this message translates to:
  /// **'no connection to the server'**
  String get mediaReasonNetwork;

  /// No description provided for @mediaReasonTimeout.
  ///
  /// In en, this message translates to:
  /// **'the network was too slow'**
  String get mediaReasonTimeout;

  /// No description provided for @mediaReasonMissing.
  ///
  /// In en, this message translates to:
  /// **'the photo file is no longer on this phone'**
  String get mediaReasonMissing;

  /// No description provided for @mediaReasonDeleted.
  ///
  /// In en, this message translates to:
  /// **'the office deleted this photo on the server'**
  String get mediaReasonDeleted;

  /// No description provided for @mediaReasonInvalid.
  ///
  /// In en, this message translates to:
  /// **'the server did not accept the photo\'s details'**
  String get mediaReasonInvalid;

  /// No description provided for @mediaReasonSignature.
  ///
  /// In en, this message translates to:
  /// **'the upload link was refused or had expired'**
  String get mediaReasonSignature;

  /// No description provided for @mediaReasonNotUploaded.
  ///
  /// In en, this message translates to:
  /// **'the server did not receive the photo'**
  String get mediaReasonNotUploaded;

  /// No description provided for @mediaReasonServer.
  ///
  /// In en, this message translates to:
  /// **'the server is not answering right now'**
  String get mediaReasonServer;

  /// No description provided for @mediaReasonCode.
  ///
  /// In en, this message translates to:
  /// **'the server answered {code}'**
  String mediaReasonCode(String code);

  /// No description provided for @mediaStepPresign.
  ///
  /// In en, this message translates to:
  /// **'{reason} (getting the upload link)'**
  String mediaStepPresign(String reason);

  /// No description provided for @mediaStepUpload.
  ///
  /// In en, this message translates to:
  /// **'{reason} (sending the photo)'**
  String mediaStepUpload(String reason);

  /// No description provided for @mediaStepConfirm.
  ///
  /// In en, this message translates to:
  /// **'{reason} (confirming)'**
  String mediaStepConfirm(String reason);

  /// No description provided for @attNotRequired.
  ///
  /// In en, this message translates to:
  /// **'Your account does not give attendance. There is nothing to do here.'**
  String get attNotRequired;

  /// No description provided for @leaderboardMeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Who collected the most this month'**
  String get leaderboardMeSubtitle;

  /// No description provided for @promiseFollowUpAction.
  ///
  /// In en, this message translates to:
  /// **'New promise (follow-up)'**
  String get promiseFollowUpAction;

  /// No description provided for @promiseFollowUpOf.
  ///
  /// In en, this message translates to:
  /// **'Follow-up of the broken promise of {amount} for {date}'**
  String promiseFollowUpOf(String amount, String date);

  /// No description provided for @promiseAttempt.
  ///
  /// In en, this message translates to:
  /// **'Attempt {n}'**
  String promiseAttempt(String n);

  /// No description provided for @todayBrokenTitle.
  ///
  /// In en, this message translates to:
  /// **'Broken promises to follow up'**
  String get todayBrokenTitle;

  /// No description provided for @todayBrokenRow.
  ///
  /// In en, this message translates to:
  /// **'{amount} · was due {date}'**
  String todayBrokenRow(String amount, String date);

  /// No description provided for @prospectsTitle.
  ///
  /// In en, this message translates to:
  /// **'Possible customers'**
  String get prospectsTitle;

  /// No description provided for @prospectsMeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'People who may buy: note them, the office follows up'**
  String get prospectsMeSubtitle;

  /// No description provided for @prospectAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get prospectAdd;

  /// No description provided for @prospectsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No possible customers yet'**
  String get prospectsEmpty;

  /// No description provided for @prospectsEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Met someone who may buy? Add them here, even without internet.'**
  String get prospectsEmptyBody;

  /// No description provided for @prospectStatusNew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get prospectStatusNew;

  /// No description provided for @prospectStatusContacted.
  ///
  /// In en, this message translates to:
  /// **'Contacted'**
  String get prospectStatusContacted;

  /// No description provided for @prospectStatusConverted.
  ///
  /// In en, this message translates to:
  /// **'Became a customer'**
  String get prospectStatusConverted;

  /// No description provided for @prospectStatusClosed.
  ///
  /// In en, this message translates to:
  /// **'Dropped'**
  String get prospectStatusClosed;

  /// No description provided for @prospectByMe.
  ///
  /// In en, this message translates to:
  /// **'you'**
  String get prospectByMe;

  /// No description provided for @prospectAddedBy.
  ///
  /// In en, this message translates to:
  /// **'Added by {name} · {time}'**
  String prospectAddedBy(String name, String time);

  /// No description provided for @prospectHasLocation.
  ///
  /// In en, this message translates to:
  /// **'Location saved'**
  String get prospectHasLocation;

  /// No description provided for @prospectWaiting.
  ///
  /// In en, this message translates to:
  /// **'Waiting to be sent'**
  String get prospectWaiting;

  /// No description provided for @prospectRefused.
  ///
  /// In en, this message translates to:
  /// **'Not accepted by the server: {code}'**
  String prospectRefused(String code);

  /// No description provided for @prospectEdit.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get prospectEdit;

  /// No description provided for @prospectNewTitle.
  ///
  /// In en, this message translates to:
  /// **'New possible customer'**
  String get prospectNewTitle;

  /// No description provided for @prospectEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Change possible customer'**
  String get prospectEditTitle;

  /// No description provided for @prospectName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get prospectName;

  /// No description provided for @prospectPhone.
  ///
  /// In en, this message translates to:
  /// **'Mobile number'**
  String get prospectPhone;

  /// No description provided for @prospectPhoneMore.
  ///
  /// In en, this message translates to:
  /// **'Another mobile number (optional)'**
  String get prospectPhoneMore;

  /// No description provided for @prospectAddPhone.
  ///
  /// In en, this message translates to:
  /// **'Add a number'**
  String get prospectAddPhone;

  /// No description provided for @prospectAddress.
  ///
  /// In en, this message translates to:
  /// **'Address (optional)'**
  String get prospectAddress;

  /// No description provided for @prospectNote.
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get prospectNote;

  /// No description provided for @prospectLocation.
  ///
  /// In en, this message translates to:
  /// **'Save where I am now'**
  String get prospectLocation;

  /// No description provided for @prospectLocationHint.
  ///
  /// In en, this message translates to:
  /// **'Only if you are with the person now'**
  String get prospectLocationHint;

  /// No description provided for @prospectLocationOffDuty.
  ///
  /// In en, this message translates to:
  /// **'Location is used only while you are on duty'**
  String get prospectLocationOffDuty;

  /// No description provided for @prospectSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved. It goes to the office when there is internet.'**
  String get prospectSaved;

  /// No description provided for @prospectOfflineHint.
  ///
  /// In en, this message translates to:
  /// **'Works without internet. You can change it until it is sent.'**
  String get prospectOfflineHint;

  /// No description provided for @prospectErrName.
  ///
  /// In en, this message translates to:
  /// **'Write a name'**
  String get prospectErrName;

  /// No description provided for @prospectErrNameLong.
  ///
  /// In en, this message translates to:
  /// **'The name is too long (at most 120 letters)'**
  String get prospectErrNameLong;

  /// No description provided for @prospectErrPhone.
  ///
  /// In en, this message translates to:
  /// **'Write at least one mobile number'**
  String get prospectErrPhone;

  /// No description provided for @prospectErrPhoneInvalid.
  ///
  /// In en, this message translates to:
  /// **'A mobile number is not valid (01XXXXXXXXX)'**
  String get prospectErrPhoneInvalid;

  /// No description provided for @prospectErrPhoneRepeated.
  ///
  /// In en, this message translates to:
  /// **'The same number is written twice'**
  String get prospectErrPhoneRepeated;

  /// No description provided for @prospectErrAddressLong.
  ///
  /// In en, this message translates to:
  /// **'The address is too long (at most 500 letters)'**
  String get prospectErrAddressLong;

  /// No description provided for @prospectErrNoteLong.
  ///
  /// In en, this message translates to:
  /// **'The note is too long (at most 1000 letters)'**
  String get prospectErrNoteLong;

  /// No description provided for @prospectErrNotEditable.
  ///
  /// In en, this message translates to:
  /// **'It has been sent; only the office can change it now'**
  String get prospectErrNotEditable;

  /// No description provided for @prospectRefusedInvalid.
  ///
  /// In en, this message translates to:
  /// **'The server did not accept the name or a number'**
  String get prospectRefusedInvalid;

  /// No description provided for @prospectRefusedNotAllowed.
  ///
  /// In en, this message translates to:
  /// **'Your account may not add possible customers'**
  String get prospectRefusedNotAllowed;

  /// No description provided for @requestsTitle.
  ///
  /// In en, this message translates to:
  /// **'My requests'**
  String get requestsTitle;

  /// No description provided for @requestsMeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Report, inform or ask the office'**
  String get requestsMeSubtitle;

  /// No description provided for @requestNew.
  ///
  /// In en, this message translates to:
  /// **'New request'**
  String get requestNew;

  /// No description provided for @requestNewTitle.
  ///
  /// In en, this message translates to:
  /// **'New request or report'**
  String get requestNewTitle;

  /// No description provided for @requestDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Request'**
  String get requestDetailTitle;

  /// No description provided for @requestTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'What kind'**
  String get requestTypeLabel;

  /// No description provided for @requestTypeRequest.
  ///
  /// In en, this message translates to:
  /// **'Request'**
  String get requestTypeRequest;

  /// No description provided for @requestTypeReport.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get requestTypeReport;

  /// No description provided for @requestTypeInform.
  ///
  /// In en, this message translates to:
  /// **'Information'**
  String get requestTypeInform;

  /// No description provided for @requestTypeComplaint.
  ///
  /// In en, this message translates to:
  /// **'Complaint'**
  String get requestTypeComplaint;

  /// No description provided for @requestSendTo.
  ///
  /// In en, this message translates to:
  /// **'Send to'**
  String get requestSendTo;

  /// No description provided for @requestToAreaManager.
  ///
  /// In en, this message translates to:
  /// **'To the area manager'**
  String get requestToAreaManager;

  /// No description provided for @requestToAreaManagerHint.
  ///
  /// In en, this message translates to:
  /// **'Regular matters'**
  String get requestToAreaManagerHint;

  /// No description provided for @requestToSuperAdmin.
  ///
  /// In en, this message translates to:
  /// **'To the super admin — very important'**
  String get requestToSuperAdmin;

  /// No description provided for @requestToSuperAdminHint.
  ///
  /// In en, this message translates to:
  /// **'Only for very important matters'**
  String get requestToSuperAdminHint;

  /// No description provided for @requestPriorityNormalShort.
  ///
  /// In en, this message translates to:
  /// **'Area manager'**
  String get requestPriorityNormalShort;

  /// No description provided for @requestPriorityImportantShort.
  ///
  /// In en, this message translates to:
  /// **'Super admin · very important'**
  String get requestPriorityImportantShort;

  /// No description provided for @requestTitleField.
  ///
  /// In en, this message translates to:
  /// **'Subject'**
  String get requestTitleField;

  /// No description provided for @requestDetailsField.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get requestDetailsField;

  /// No description provided for @requestCustomer.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get requestCustomer;

  /// No description provided for @requestCustomerRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove the customer'**
  String get requestCustomerRemove;

  /// No description provided for @requestCustomerAction.
  ///
  /// In en, this message translates to:
  /// **'Tell the office'**
  String get requestCustomerAction;

  /// No description provided for @requestPhotos.
  ///
  /// In en, this message translates to:
  /// **'Photos (optional, at most {max})'**
  String requestPhotos(String max);

  /// No description provided for @requestPhotosShort.
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get requestPhotosShort;

  /// No description provided for @requestAddPhoto.
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get requestAddPhoto;

  /// No description provided for @requestRemovePhoto.
  ///
  /// In en, this message translates to:
  /// **'Remove photo'**
  String get requestRemovePhoto;

  /// No description provided for @requestSend.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get requestSend;

  /// No description provided for @requestSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved. It goes to the office when online.'**
  String get requestSaved;

  /// No description provided for @requestOfflineHint.
  ///
  /// In en, this message translates to:
  /// **'Works without internet: it is kept on the phone and goes by itself when online.'**
  String get requestOfflineHint;

  /// No description provided for @requestErrTitle.
  ///
  /// In en, this message translates to:
  /// **'Write a subject'**
  String get requestErrTitle;

  /// No description provided for @requestErrTitleLong.
  ///
  /// In en, this message translates to:
  /// **'The subject is too long (at most 160 letters)'**
  String get requestErrTitleLong;

  /// No description provided for @requestErrDetails.
  ///
  /// In en, this message translates to:
  /// **'Write the details'**
  String get requestErrDetails;

  /// No description provided for @requestErrDetailsLong.
  ///
  /// In en, this message translates to:
  /// **'The details are too long (at most 4000 letters)'**
  String get requestErrDetailsLong;

  /// No description provided for @requestErrPhotos.
  ///
  /// In en, this message translates to:
  /// **'At most 5 photos'**
  String get requestErrPhotos;

  /// No description provided for @requestErrComment.
  ///
  /// In en, this message translates to:
  /// **'Write a comment'**
  String get requestErrComment;

  /// No description provided for @requestErrCommentLong.
  ///
  /// In en, this message translates to:
  /// **'The comment is too long (at most 2000 letters)'**
  String get requestErrCommentLong;

  /// No description provided for @requestErrNotOpen.
  ///
  /// In en, this message translates to:
  /// **'This request takes no more comments'**
  String get requestErrNotOpen;

  /// No description provided for @requestRefused.
  ///
  /// In en, this message translates to:
  /// **'The server did not accept it: {code}'**
  String requestRefused(String code);

  /// No description provided for @requestRefusedInvalid.
  ///
  /// In en, this message translates to:
  /// **'The server did not accept the subject or details'**
  String get requestRefusedInvalid;

  /// No description provided for @requestRefusedNotAllowed.
  ///
  /// In en, this message translates to:
  /// **'Your account may not send requests'**
  String get requestRefusedNotAllowed;

  /// No description provided for @requestFilterOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get requestFilterOpen;

  /// No description provided for @requestFilterResolved.
  ///
  /// In en, this message translates to:
  /// **'Resolved'**
  String get requestFilterResolved;

  /// No description provided for @requestsAssignedToMe.
  ///
  /// In en, this message translates to:
  /// **'Assigned to me'**
  String get requestsAssignedToMe;

  /// No description provided for @requestsMine.
  ///
  /// In en, this message translates to:
  /// **'Sent by me'**
  String get requestsMine;

  /// No description provided for @requestsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No requests'**
  String get requestsEmpty;

  /// No description provided for @requestsEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Tap \"New request\" to tell or ask the office something'**
  String get requestsEmptyBody;

  /// No description provided for @requestStatusOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get requestStatusOpen;

  /// No description provided for @requestStatusForwarded.
  ///
  /// In en, this message translates to:
  /// **'Forwarded'**
  String get requestStatusForwarded;

  /// No description provided for @requestStatusAssigned.
  ///
  /// In en, this message translates to:
  /// **'Assigned'**
  String get requestStatusAssigned;

  /// No description provided for @requestStatusInProgress.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get requestStatusInProgress;

  /// No description provided for @requestStatusResolved.
  ///
  /// In en, this message translates to:
  /// **'Resolved'**
  String get requestStatusResolved;

  /// No description provided for @requestStatusClosed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get requestStatusClosed;

  /// No description provided for @requestStatusReopened.
  ///
  /// In en, this message translates to:
  /// **'Reopened'**
  String get requestStatusReopened;

  /// No description provided for @requestStatusQueued.
  ///
  /// In en, this message translates to:
  /// **'Waiting to send'**
  String get requestStatusQueued;

  /// No description provided for @requestStatusRefused.
  ///
  /// In en, this message translates to:
  /// **'Not accepted'**
  String get requestStatusRefused;

  /// No description provided for @requestFrom.
  ///
  /// In en, this message translates to:
  /// **'From {name}'**
  String requestFrom(String name);

  /// No description provided for @requestNewsMark.
  ///
  /// In en, this message translates to:
  /// **'New update'**
  String get requestNewsMark;

  /// No description provided for @requestHolder.
  ///
  /// In en, this message translates to:
  /// **'Now with'**
  String get requestHolder;

  /// No description provided for @requestSentBy.
  ///
  /// In en, this message translates to:
  /// **'Sent by'**
  String get requestSentBy;

  /// No description provided for @requestCreatedAt.
  ///
  /// In en, this message translates to:
  /// **'Sent at'**
  String get requestCreatedAt;

  /// No description provided for @requestPhotosWaiting.
  ///
  /// In en, this message translates to:
  /// **'Waiting for the photos to upload; then it is sent'**
  String get requestPhotosWaiting;

  /// No description provided for @requestTimeline.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get requestTimeline;

  /// No description provided for @requestByMe.
  ///
  /// In en, this message translates to:
  /// **'Me'**
  String get requestByMe;

  /// No description provided for @requestEventCreated.
  ///
  /// In en, this message translates to:
  /// **'Sent'**
  String get requestEventCreated;

  /// No description provided for @requestEventForwarded.
  ///
  /// In en, this message translates to:
  /// **'Forwarded to {name}'**
  String requestEventForwarded(String name);

  /// No description provided for @requestEventForwardedNoName.
  ///
  /// In en, this message translates to:
  /// **'Forwarded'**
  String get requestEventForwardedNoName;

  /// No description provided for @requestEventAssigned.
  ///
  /// In en, this message translates to:
  /// **'Assigned to {name}'**
  String requestEventAssigned(String name);

  /// No description provided for @requestEventAssignedNoName.
  ///
  /// In en, this message translates to:
  /// **'Assigned'**
  String get requestEventAssignedNoName;

  /// No description provided for @requestEventComment.
  ///
  /// In en, this message translates to:
  /// **'Comment'**
  String get requestEventComment;

  /// No description provided for @requestEventResolved.
  ///
  /// In en, this message translates to:
  /// **'Resolved'**
  String get requestEventResolved;

  /// No description provided for @requestEventReopened.
  ///
  /// In en, this message translates to:
  /// **'Reopened'**
  String get requestEventReopened;

  /// No description provided for @requestCommentHint.
  ///
  /// In en, this message translates to:
  /// **'Write a comment'**
  String get requestCommentHint;

  /// No description provided for @requestCommentSend.
  ///
  /// In en, this message translates to:
  /// **'Send comment'**
  String get requestCommentSend;

  /// No description provided for @requestCommentSaved.
  ///
  /// In en, this message translates to:
  /// **'Comment saved. It goes when online.'**
  String get requestCommentSaved;

  /// No description provided for @requestCommentPending.
  ///
  /// In en, this message translates to:
  /// **'Waiting to send'**
  String get requestCommentPending;

  /// No description provided for @requestCommentFailed.
  ///
  /// In en, this message translates to:
  /// **'The server did not accept this comment'**
  String get requestCommentFailed;

  /// No description provided for @requestClosedNoComment.
  ///
  /// In en, this message translates to:
  /// **'This is closed. Reopen it to comment.'**
  String get requestClosedNoComment;

  /// No description provided for @alertRequestChanged.
  ///
  /// In en, this message translates to:
  /// **'Update on your request: {title}'**
  String alertRequestChanged(String title);

  /// No description provided for @alertRequestAssigned.
  ///
  /// In en, this message translates to:
  /// **'Assigned to you: {title}'**
  String alertRequestAssigned(String title);

  /// No description provided for @alertRequestResolved.
  ///
  /// In en, this message translates to:
  /// **'Resolved: {title}'**
  String alertRequestResolved(String title);

  /// No description provided for @alertRequestComment.
  ///
  /// In en, this message translates to:
  /// **'New comment: {title}'**
  String alertRequestComment(String title);

  /// No description provided for @requestQueueAreaManager.
  ///
  /// In en, this message translates to:
  /// **'Area manager'**
  String get requestQueueAreaManager;

  /// No description provided for @requestQueueSuperAdmin.
  ///
  /// In en, this message translates to:
  /// **'Super admin'**
  String get requestQueueSuperAdmin;

  /// No description provided for @requestEventStatusChanged.
  ///
  /// In en, this message translates to:
  /// **'Status changed: {status}'**
  String requestEventStatusChanged(String status);

  /// No description provided for @requestEventClosed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get requestEventClosed;

  /// No description provided for @requestResolution.
  ///
  /// In en, this message translates to:
  /// **'Resolution'**
  String get requestResolution;

  /// No description provided for @requestReopen.
  ///
  /// In en, this message translates to:
  /// **'Reopen'**
  String get requestReopen;

  /// No description provided for @requestReopenTitle.
  ///
  /// In en, this message translates to:
  /// **'Reopen this request?'**
  String get requestReopenTitle;

  /// No description provided for @requestReopenBody.
  ///
  /// In en, this message translates to:
  /// **'Say why you reopen it. This needs the internet.'**
  String get requestReopenBody;

  /// No description provided for @requestReopenNoteHint.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get requestReopenNoteHint;

  /// No description provided for @requestReopenDone.
  ///
  /// In en, this message translates to:
  /// **'Reopened'**
  String get requestReopenDone;

  /// No description provided for @requestReopenOffline.
  ///
  /// In en, this message translates to:
  /// **'No internet. Try again when online.'**
  String get requestReopenOffline;

  /// No description provided for @requestReopenFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not reopen: {code}'**
  String requestReopenFailed(String code);

  /// No description provided for @requestErrNote.
  ///
  /// In en, this message translates to:
  /// **'Write the reason'**
  String get requestErrNote;

  /// No description provided for @requestErrNoteLong.
  ///
  /// In en, this message translates to:
  /// **'The reason is too long (at most 1000 letters)'**
  String get requestErrNoteLong;
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
