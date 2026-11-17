import 'package:drift/drift.dart';

// Local tables — docs/06-data-model.md. Money = INTEGER poisha. Instants =
// INTEGER epoch ms UTC (drift DateTime stored as unix ms, see
// AppDatabase options). Business dates = TEXT YYYY-MM-DD (Dhaka).
//
// Owner feature is noted on every table. Features never query another
// feature's tables directly; they go through that feature's public barrel.

// ── customers (feature: customers) ───────────────────────────────────────────
@DataClassName('CustomerRow')
class Customers extends Table {
  TextColumn get serverId => text()();
  TextColumn get erpCustomerId => text().nullable()();
  TextColumn get code => text()();
  TextColumn get nameBn => text()();
  TextColumn get nameEn => text().nullable()();
  TextColumn get phonesJson => text().withDefault(const Constant('[]'))();
  TextColumn get address => text().nullable()();
  TextColumn get areaId => text().nullable()();
  TextColumn get areaName => text().nullable()();
  RealColumn get lat => real().nullable()();
  RealColumn get lng => real().nullable()();
  TextColumn get locationStatus => text().withDefault(const Constant('ok'))();
  IntColumn get totalOutstandingPoisha => integer().withDefault(const Constant(0))();
  IntColumn get installmentPoisha => integer().nullable()();
  IntColumn get overduePoisha => integer().withDefault(const Constant(0))();
  TextColumn get nextDueDate => text().nullable()();
  IntColumn get daysOverdue => integer().withDefault(const Constant(0))();
  BoolColumn get dueToday => boolean().withDefault(const Constant(false))();
  BoolColumn get overdue => boolean().withDefault(const Constant(false))();
  BoolColumn get badSuggested => boolean().withDefault(const Constant(false))();
  TextColumn get badReasonJson => text().nullable()();
  TextColumn get tagState => text().withDefault(const Constant('none'))();
  TextColumn get tagSeverity => text().nullable()();
  TextColumn get tagReason => text().nullable()();
  DateTimeColumn get lastVisitAt => dateTime().nullable()();
  TextColumn get openPromiseId => text().nullable()();
  TextColumn get openPromiseDate => text().nullable()();
  IntColumn get openPromisePoisha => integer().nullable()();
  IntColumn get pendingFieldPoisha => integer().withDefault(const Constant(0))();
  TextColumn get assigneeId => text().nullable()();
  DateTimeColumn get erpFetchedAt => dateTime().nullable()();
  TextColumn get guarantorJson => text().nullable()();
  TextColumn get searchText => text().withDefault(const Constant(''))();
  IntColumn get version => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {serverId};
}

@DataClassName('PlanRow')
class Plans extends Table {
  TextColumn get erpPlanId => text()();
  TextColumn get customerId => text()();
  TextColumn get product => text()();
  TextColumn get startDate => text()();
  TextColumn get finalDueDate => text()();
  IntColumn get installmentCount => integer()();
  IntColumn get totalPayablePoisha => integer()();
  IntColumn get downPaymentPoisha => integer().withDefault(const Constant(0))();
  IntColumn get paidPoisha => integer()();
  IntColumn get outstandingPoisha => integer()();
  TextColumn get status => text()();
  BoolColumn get badSuggested => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {erpPlanId};
}

@DataClassName('ScheduleLineRow')
class ScheduleLines extends Table {
  TextColumn get erpPlanId => text()();
  IntColumn get seq => integer()();
  TextColumn get dueDate => text()();
  IntColumn get amountPoisha => integer()();
  IntColumn get paidPoisha => integer()();
  TextColumn get status => text()();
  BoolColumn get estimated => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {erpPlanId, seq};
}

@DataClassName('ErpPaymentRow')
class ErpPayments extends Table {
  TextColumn get erpPaymentId => text()();
  TextColumn get customerId => text()();
  TextColumn get planId => text().nullable()();
  TextColumn get date => text()();
  IntColumn get amountPoisha => integer()();
  TextColumn get method => text()();
  TextColumn get source => text()();
  TextColumn get receiptNo => text().nullable()();
  BoolColumn get reversed => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {erpPaymentId};
}

@DataClassName('LocationProposalRow')
class LocationProposals extends Table {
  TextColumn get clientId => text()();
  TextColumn get customerId => text()();
  RealColumn get lat => real()();
  RealColumn get lng => real()();
  RealColumn get accuracyM => real()();
  TextColumn get photoMediaClientId => text().nullable()();
  TextColumn get note => text().nullable()();
  TextColumn get status => text().withDefault(const Constant('pending'))();
  TextColumn get syncState => text().withDefault(const Constant('queued'))();

  /// Manager's reason when rejected (v3, contract 1.7.0).
  TextColumn get decisionReason => text().nullable()();

  /// v5 (contract 1.11.0): `gps` (the phone's own fix, before 0.8.0) or
  /// `map` (the point under the pin on the map; [accuracyM] is then 0).
  TextColumn get method => text().withDefault(const Constant('gps'))();

  /// v5: where the phone was when a `map` pin was picked (GeoFix JSON),
  /// sent as `deviceGeo` so the manager sees how far away the staff was.
  TextColumn get deviceGeoJson => text().nullable()();

  @override
  Set<Column> get primaryKey => {clientId};
}

// ── collections (feature: collections) ───────────────────────────────────────
@DataClassName('CollectionRow')
class Collections extends Table {
  TextColumn get clientId => text()();
  TextColumn get serverId => text().nullable()();
  TextColumn get customerId => text()();
  TextColumn get customerName => text()();
  TextColumn get customerCode => text()();
  TextColumn get erpPlanId => text().nullable()();
  IntColumn get amountPoisha => integer()();
  TextColumn get method => text()();
  TextColumn get transactionRef => text().nullable()();
  TextColumn get receiptNo => text().unique()();
  TextColumn get physicalReceiptNo => text().nullable()();
  TextColumn get payerName => text().nullable()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get recordedAt => dateTime()();
  DateTimeColumn get deviceTime => dateTime()();
  TextColumn get businessDate => text()();
  RealColumn get lat => real().nullable()();
  RealColumn get lng => real().nullable()();
  RealColumn get accuracyM => real().nullable()();
  BoolColumn get mock => boolean().withDefault(const Constant(false))();
  TextColumn get visitClientId => text().nullable()();
  TextColumn get photoMediaClientId => text().nullable()();

  /// queued | received | posting | posted | conflict | posting_failed |
  /// resolved_posted | resolved_refund | resolved_voided | voided | rejected
  TextColumn get status => text().withDefault(const Constant('queued'))();
  TextColumn get erpReceiptNo => text().nullable()();
  TextColumn get conflictCode => text().nullable()();
  TextColumn get conflictMessage => text().nullable()();
  TextColumn get resolutionText => text().nullable()();
  TextColumn get flagsJson => text().withDefault(const Constant('[]'))();
  TextColumn get syncState => text().withDefault(const Constant('queued'))();

  @override
  Set<Column> get primaryKey => {clientId};
}

@DataClassName('ReceiptBlockRow')
class ReceiptBlocks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get prefix => text()();
  TextColumn get businessDate => text()();
  IntColumn get fromSeq => integer()();
  IntColumn get toSeq => integer()();
  IntColumn get lastUsed => integer()();

  /// true for the device-reserved offline fallback series (`…-OFF{seq}`).
  BoolColumn get offline => boolean().withDefault(const Constant(false))();
}

// ── cash (feature: cash) ─────────────────────────────────────────────────────
@DataClassName('CashPositionRow')
class CashPositions extends Table {
  @override
  String get tableName => 'cash_position';
  IntColumn get id => integer().withDefault(const Constant(1))();
  IntColumn get serverOnHandPoisha => integer()();
  IntColumn get limitPoisha => integer()();
  IntColumn get pendingDepositsPoisha => integer().withDefault(const Constant(0))();
  DateTimeColumn get asOf => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('DepositRow')
class Deposits extends Table {
  TextColumn get clientId => text()();
  TextColumn get serverId => text().nullable()();
  IntColumn get amountPoisha => integer()();
  TextColumn get destination => text()();
  TextColumn get reference => text().nullable()();
  TextColumn get slipMediaClientId => text().nullable()();
  DateTimeColumn get depositedAt => dateTime()();
  TextColumn get status => text().withDefault(const Constant('pending'))();
  TextColumn get rejectReason => text().nullable()();
  TextColumn get syncState => text().withDefault(const Constant('queued'))();

  @override
  Set<Column> get primaryKey => {clientId};
}

@DataClassName('CashClosingRow')
class CashClosings extends Table {
  TextColumn get businessDate => text()();
  IntColumn get cashPoisha => integer()();
  IntColumn get mobilePoisha => integer()();
  IntColumn get depositedPoisha => integer()();
  IntColumn get onHandPoisha => integer()();
  DateTimeColumn get confirmedAt => dateTime()();
  TextColumn get syncState => text().withDefault(const Constant('queued'))();

  @override
  Set<Column> get primaryKey => {businessDate};
}

// ── visits / notes / promises / tags ─────────────────────────────────────────
@DataClassName('VisitRow')
class Visits extends Table {
  TextColumn get clientId => text()();
  TextColumn get serverId => text().nullable()();
  TextColumn get customerId => text()();
  TextColumn get userName => text().nullable()();
  DateTimeColumn get checkInAt => dateTime()();
  DateTimeColumn get checkOutAt => dateTime().nullable()();
  TextColumn get outcome => text()();
  RealColumn get lat => real().nullable()();
  RealColumn get lng => real().nullable()();
  RealColumn get accuracyM => real().nullable()();
  BoolColumn get mock => boolean().withDefault(const Constant(false))();
  IntColumn get distanceToPinM => integer().nullable()();
  TextColumn get photoMediaClientIdsJson => text().withDefault(const Constant('[]'))();
  TextColumn get note => text().nullable()();
  TextColumn get source => text().withDefault(const Constant('manual'))();
  TextColumn get syncState => text().withDefault(const Constant('queued'))();

  /// Recorder's user id from the server; null = recorded on this phone (v4).
  TextColumn get userId => text().nullable()();

  /// Co-work session the visit was made in (v4, contract 1.9.0). Set at save
  /// time by the recorder; cleared when the server could not confirm it
  /// (flag `cowork_invalid`).
  TextColumn get coWorkSessionId => text().nullable()();

  /// Partners (user ids, without the recorder): our estimate at save time,
  /// replaced by the server's `coWork.participantIds` on pull (v4).
  TextColumn get coWorkParticipantIdsJson => text().nullable()();

  @override
  Set<Column> get primaryKey => {clientId};
}

@DataClassName('NoteRow')
class Notes extends Table {
  TextColumn get clientId => text()();
  TextColumn get serverId => text().nullable()();
  TextColumn get customerId => text()();
  TextColumn get authorId => text().nullable()();
  TextColumn get authorName => text().nullable()();
  TextColumn get category => text().withDefault(const Constant('general'))();
  TextColumn get body => text().named('text')();
  TextColumn get voiceMediaClientId => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get editableUntil => dateTime().nullable()();
  TextColumn get syncState => text().withDefault(const Constant('queued'))();

  @override
  Set<Column> get primaryKey => {clientId};
}

@DataClassName('PromiseRow')
class Promises extends Table {
  TextColumn get clientId => text()();
  TextColumn get serverId => text().nullable()();
  TextColumn get customerId => text()();
  TextColumn get erpPlanId => text().nullable()();
  TextColumn get promisedDate => text()();
  IntColumn get promisedAmountPoisha => integer()();
  IntColumn get paidTowardsPoisha => integer().withDefault(const Constant(0))();
  TextColumn get status => text().withDefault(const Constant('open'))();
  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get syncState => text().withDefault(const Constant('queued'))();
  BoolColumn get reminderScheduled => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {clientId};
}

@DataClassName('TagEventRow')
class TagEvents extends Table {
  TextColumn get clientId => text()();
  TextColumn get customerId => text()();
  TextColumn get previousJson => text()();
  TextColumn get nextJson => text()();
  TextColumn get reasonCode => text()();
  TextColumn get reason => text()();
  DateTimeColumn get at => dateTime()();
  TextColumn get syncState => text().withDefault(const Constant('queued'))();

  @override
  Set<Column> get primaryKey => {clientId};
}

// ── attendance ───────────────────────────────────────────────────────────────
@DataClassName('AttendanceEventRow')
class AttendanceEvents extends Table {
  TextColumn get clientId => text()();

  /// work_in | break_start | break_end | work_out
  TextColumn get type => text()();
  DateTimeColumn get at => dateTime()();
  DateTimeColumn get deviceTime => dateTime()();
  TextColumn get businessDate => text()();
  RealColumn get lat => real().nullable()();
  RealColumn get lng => real().nullable()();
  RealColumn get accuracyM => real().nullable()();
  BoolColumn get mock => boolean().withDefault(const Constant(false))();
  TextColumn get selfieMediaClientId => text().nullable()();
  TextColumn get syncState => text().withDefault(const Constant('queued'))();

  @override
  Set<Column> get primaryKey => {clientId};
}

@DataClassName('AttendanceDayRow')
class AttendanceDays extends Table {
  @override
  String get tableName => 'attendance_day';
  TextColumn get businessDate => text()();
  TextColumn get status => text()();
  DateTimeColumn get firstIn => dateTime().nullable()();
  DateTimeColumn get lastOut => dateTime().nullable()();
  IntColumn get breakMin => integer().withDefault(const Constant(0))();
  IntColumn get lateMin => integer().withDefault(const Constant(0))();
  TextColumn get breaksJson => text().withDefault(const Constant('[]'))();

  @override
  Set<Column> get primaryKey => {businessDate};
}

// ── handovers ────────────────────────────────────────────────────────────────
@DataClassName('HandoverRow')
class Handovers extends Table {
  TextColumn get serverId => text()();
  TextColumn get fromUserName => text()();
  TextColumn get toUserId => text()();
  TextColumn get summaryJson => text()();
  TextColumn get reason => text().nullable()();
  TextColumn get status => text()();
  DateTimeColumn get expiresAt => dateTime().nullable()();

  /// incoming | outgoing
  TextColumn get role => text()();

  @override
  Set<Column> get primaryKey => {serverId};
}

// ── media (core/media) ───────────────────────────────────────────────────────
@DataClassName('MediaQueueRow')
class MediaQueue extends Table {
  @override
  String get tableName => 'media_queue';
  TextColumn get clientId => text()();
  TextColumn get kind => text()();
  TextColumn get localPath => text()();
  TextColumn get sha256 => text()();
  IntColumn get sizeBytes => integer()();
  DateTimeColumn get capturedAt => dateTime()();
  TextColumn get ownerEntity => text()();
  TextColumn get ownerClientId => text()();
  TextColumn get serverMediaId => text().nullable()();
  TextColumn get state => text().withDefault(const Constant('pending'))();
  IntColumn get attempts => integer().withDefault(const Constant(0))();
  DateTimeColumn get nextAttemptAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {clientId};
}

// ── sync (core/sync) ─────────────────────────────────────────────────────────
@DataClassName('OutboxRow')
class Outbox extends Table {
  @override
  String get tableName => 'outbox';
  TextColumn get mutationId => text()();
  TextColumn get entity => text()();
  TextColumn get op => text()();
  TextColumn get payloadJson => text()();
  TextColumn get dependsOnJson => text().withDefault(const Constant('[]'))();
  DateTimeColumn get createdAt => dateTime()();

  /// pending | sending | done | failed — never deleted while pending/failed.
  TextColumn get state => text().withDefault(const Constant('pending'))();
  IntColumn get attempts => integer().withDefault(const Constant(0))();
  DateTimeColumn get nextAttemptAt => dateTime().nullable()();
  TextColumn get lastError => text().nullable()();
  TextColumn get result => text().nullable()();
  DateTimeColumn get doneAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {mutationId};
}

@DataClassName('IdMapRow')
class IdMap extends Table {
  @override
  String get tableName => 'id_map';
  TextColumn get clientId => text()();
  TextColumn get entity => text()();
  TextColumn get serverId => text()();

  @override
  Set<Column> get primaryKey => {clientId};
}

@DataClassName('SyncMetaRow')
class SyncMeta extends Table {
  @override
  String get tableName => 'sync_state';
  IntColumn get id => integer().withDefault(const Constant(1))();
  TextColumn get pullCursor => text().nullable()();
  DateTimeColumn get lastPullAt => dateTime().nullable()();
  DateTimeColumn get lastPushAt => dateTime().nullable()();
  DateTimeColumn get lastSuccessAt => dateTime().nullable()();
  IntColumn get serverOffsetMs => integer().withDefault(const Constant(0))();
  BoolColumn get bootstrapDone => boolean().withDefault(const Constant(false))();
  TextColumn get lastError => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

// ── contact attempts (FR-M-014, contract 1.2.0) ───────────────────────────────
@DataClassName('ContactAttemptRow')
class ContactAttempts extends Table {
  TextColumn get clientId => text()();
  TextColumn get serverId => text().nullable()();
  TextColumn get customerId => text()();

  /// call | sms | whatsapp
  TextColumn get channel => text()();

  /// Index into the customer's phones — never the number itself.
  IntColumn get phoneIndex => integer().nullable()();

  /// customer | guarantor (schema 6, contract 1.12.0).
  TextColumn get target => text().withDefault(const Constant('customer'))();
  DateTimeColumn get at => dateTime()();

  /// connected | no_answer | busy | switched_off | wrong_number | sent
  TextColumn get outcome => text().nullable()();
  TextColumn get note => text().nullable()();
  TextColumn get syncState => text().withDefault(const Constant('queued'))();

  @override
  Set<Column> get primaryKey => {clientId};
}

// ── co-work (feature: cowork, contract 1.9.0) ─────────────────────────────────
/// A co-work session I am invited to or a member of (pull entity
/// `cowork_session`). Server-owned: changed only by online calls and pull.
@DataClassName('CoworkSessionRow')
class CoworkSessions extends Table {
  @override
  String get tableName => 'cowork_sessions';
  TextColumn get id => text()();
  TextColumn get businessDate => text()();

  /// open | ended
  TextColumn get status => text()();
  TextColumn get createdBy => text()();
  TextColumn get note => text().nullable()();

  /// CoworkMember[] as JSON (userId, name, status, invitedBy, invitedAt, respondedAt, leftAt).
  TextColumn get membersJson => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get endedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

// ── location (P2) ────────────────────────────────────────────────────────────
@DataClassName('LocationPointRow')
class LocationQueue extends Table {
  @override
  String get tableName => 'location_queue';
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get t => dateTime()();
  RealColumn get lat => real()();
  RealColumn get lng => real()();
  RealColumn get acc => real()();
  RealColumn get spd => real().nullable()();
  RealColumn get hdg => real().nullable()();
  RealColumn get alt => real().nullable()();
  TextColumn get act => text().nullable()();
  RealColumn get bat => real().nullable()();
  BoolColumn get chg => boolean().nullable()();
  BoolColumn get mock => boolean().withDefault(const Constant(false))();
}

// ── notices (broadcasts, schema 6, contract 1.12.0) ──────────────────────────
/// Notices from the office (`broadcast` sync entity). "Read" is tapped on
/// the phone and sent as the `broadcast_ack` mutation, so it works offline.
@DataClassName('BroadcastRow')
class Broadcasts extends Table {
  TextColumn get serverId => text()();
  TextColumn get titleBn => text()();
  TextColumn get titleEn => text().nullable()();
  TextColumn get bodyBn => text()();
  TextColumn get bodyEn => text().nullable()();
  BoolColumn get requireAck => boolean().withDefault(const Constant(false))();
  TextColumn get senderName => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  /// When I tapped "read" (or the server's time once it knows).
  DateTimeColumn get ackedAt => dateTime().nullable()();

  /// none | queued | synced | failed
  TextColumn get ackState => text().withDefault(const Constant('none'))();
  TextColumn get ackMutationId => text().nullable()();

  @override
  Set<Column> get primaryKey => {serverId};
}

// ── notifications / settings ─────────────────────────────────────────────────
@DataClassName('NotificationRow')
class Notifications extends Table {
  TextColumn get serverId => text()();
  TextColumn get type => text()();
  TextColumn get title => text()();
  TextColumn get body => text()();
  TextColumn get dataJson => text().withDefault(const Constant('{}'))();
  DateTimeColumn get readAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {serverId};
}

@DataClassName('KvRow')
class KvSettings extends Table {
  TextColumn get key => text()();
  TextColumn get valueJson => text()();

  @override
  Set<Column> get primaryKey => {key};
}
