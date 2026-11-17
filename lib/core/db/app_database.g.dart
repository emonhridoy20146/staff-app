// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $CustomersTable extends Customers
    with TableInfo<$CustomersTable, CustomerRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CustomersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _serverIdMeta = const VerificationMeta(
    'serverId',
  );
  @override
  late final GeneratedColumn<String> serverId = GeneratedColumn<String>(
    'server_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _erpCustomerIdMeta = const VerificationMeta(
    'erpCustomerId',
  );
  @override
  late final GeneratedColumn<String> erpCustomerId = GeneratedColumn<String>(
    'erp_customer_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameBnMeta = const VerificationMeta('nameBn');
  @override
  late final GeneratedColumn<String> nameBn = GeneratedColumn<String>(
    'name_bn',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameEnMeta = const VerificationMeta('nameEn');
  @override
  late final GeneratedColumn<String> nameEn = GeneratedColumn<String>(
    'name_en',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _phonesJsonMeta = const VerificationMeta(
    'phonesJson',
  );
  @override
  late final GeneratedColumn<String> phonesJson = GeneratedColumn<String>(
    'phones_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _addressMeta = const VerificationMeta(
    'address',
  );
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
    'address',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _areaIdMeta = const VerificationMeta('areaId');
  @override
  late final GeneratedColumn<String> areaId = GeneratedColumn<String>(
    'area_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _areaNameMeta = const VerificationMeta(
    'areaName',
  );
  @override
  late final GeneratedColumn<String> areaName = GeneratedColumn<String>(
    'area_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _latMeta = const VerificationMeta('lat');
  @override
  late final GeneratedColumn<double> lat = GeneratedColumn<double>(
    'lat',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lngMeta = const VerificationMeta('lng');
  @override
  late final GeneratedColumn<double> lng = GeneratedColumn<double>(
    'lng',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _locationStatusMeta = const VerificationMeta(
    'locationStatus',
  );
  @override
  late final GeneratedColumn<String> locationStatus = GeneratedColumn<String>(
    'location_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('ok'),
  );
  static const VerificationMeta _totalOutstandingPoishaMeta =
      const VerificationMeta('totalOutstandingPoisha');
  @override
  late final GeneratedColumn<int> totalOutstandingPoisha = GeneratedColumn<int>(
    'total_outstanding_poisha',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _installmentPoishaMeta = const VerificationMeta(
    'installmentPoisha',
  );
  @override
  late final GeneratedColumn<int> installmentPoisha = GeneratedColumn<int>(
    'installment_poisha',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _overduePoishaMeta = const VerificationMeta(
    'overduePoisha',
  );
  @override
  late final GeneratedColumn<int> overduePoisha = GeneratedColumn<int>(
    'overdue_poisha',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _nextDueDateMeta = const VerificationMeta(
    'nextDueDate',
  );
  @override
  late final GeneratedColumn<String> nextDueDate = GeneratedColumn<String>(
    'next_due_date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _daysOverdueMeta = const VerificationMeta(
    'daysOverdue',
  );
  @override
  late final GeneratedColumn<int> daysOverdue = GeneratedColumn<int>(
    'days_overdue',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _dueTodayMeta = const VerificationMeta(
    'dueToday',
  );
  @override
  late final GeneratedColumn<bool> dueToday = GeneratedColumn<bool>(
    'due_today',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("due_today" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _overdueMeta = const VerificationMeta(
    'overdue',
  );
  @override
  late final GeneratedColumn<bool> overdue = GeneratedColumn<bool>(
    'overdue',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("overdue" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _badSuggestedMeta = const VerificationMeta(
    'badSuggested',
  );
  @override
  late final GeneratedColumn<bool> badSuggested = GeneratedColumn<bool>(
    'bad_suggested',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("bad_suggested" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _badReasonJsonMeta = const VerificationMeta(
    'badReasonJson',
  );
  @override
  late final GeneratedColumn<String> badReasonJson = GeneratedColumn<String>(
    'bad_reason_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tagStateMeta = const VerificationMeta(
    'tagState',
  );
  @override
  late final GeneratedColumn<String> tagState = GeneratedColumn<String>(
    'tag_state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('none'),
  );
  static const VerificationMeta _tagSeverityMeta = const VerificationMeta(
    'tagSeverity',
  );
  @override
  late final GeneratedColumn<String> tagSeverity = GeneratedColumn<String>(
    'tag_severity',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tagReasonMeta = const VerificationMeta(
    'tagReason',
  );
  @override
  late final GeneratedColumn<String> tagReason = GeneratedColumn<String>(
    'tag_reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastVisitAtMeta = const VerificationMeta(
    'lastVisitAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastVisitAt = GeneratedColumn<DateTime>(
    'last_visit_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _openPromiseIdMeta = const VerificationMeta(
    'openPromiseId',
  );
  @override
  late final GeneratedColumn<String> openPromiseId = GeneratedColumn<String>(
    'open_promise_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _openPromiseDateMeta = const VerificationMeta(
    'openPromiseDate',
  );
  @override
  late final GeneratedColumn<String> openPromiseDate = GeneratedColumn<String>(
    'open_promise_date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _openPromisePoishaMeta = const VerificationMeta(
    'openPromisePoisha',
  );
  @override
  late final GeneratedColumn<int> openPromisePoisha = GeneratedColumn<int>(
    'open_promise_poisha',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pendingFieldPoishaMeta =
      const VerificationMeta('pendingFieldPoisha');
  @override
  late final GeneratedColumn<int> pendingFieldPoisha = GeneratedColumn<int>(
    'pending_field_poisha',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _assigneeIdMeta = const VerificationMeta(
    'assigneeId',
  );
  @override
  late final GeneratedColumn<String> assigneeId = GeneratedColumn<String>(
    'assignee_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _erpFetchedAtMeta = const VerificationMeta(
    'erpFetchedAt',
  );
  @override
  late final GeneratedColumn<DateTime> erpFetchedAt = GeneratedColumn<DateTime>(
    'erp_fetched_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _guarantorJsonMeta = const VerificationMeta(
    'guarantorJson',
  );
  @override
  late final GeneratedColumn<String> guarantorJson = GeneratedColumn<String>(
    'guarantor_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _searchTextMeta = const VerificationMeta(
    'searchText',
  );
  @override
  late final GeneratedColumn<String> searchText = GeneratedColumn<String>(
    'search_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    serverId,
    erpCustomerId,
    code,
    nameBn,
    nameEn,
    phonesJson,
    address,
    areaId,
    areaName,
    lat,
    lng,
    locationStatus,
    totalOutstandingPoisha,
    installmentPoisha,
    overduePoisha,
    nextDueDate,
    daysOverdue,
    dueToday,
    overdue,
    badSuggested,
    badReasonJson,
    tagState,
    tagSeverity,
    tagReason,
    lastVisitAt,
    openPromiseId,
    openPromiseDate,
    openPromisePoisha,
    pendingFieldPoisha,
    assigneeId,
    erpFetchedAt,
    guarantorJson,
    searchText,
    version,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'customers';
  @override
  VerificationContext validateIntegrity(
    Insertable<CustomerRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('server_id')) {
      context.handle(
        _serverIdMeta,
        serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta),
      );
    } else if (isInserting) {
      context.missing(_serverIdMeta);
    }
    if (data.containsKey('erp_customer_id')) {
      context.handle(
        _erpCustomerIdMeta,
        erpCustomerId.isAcceptableOrUnknown(
          data['erp_customer_id']!,
          _erpCustomerIdMeta,
        ),
      );
    }
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('name_bn')) {
      context.handle(
        _nameBnMeta,
        nameBn.isAcceptableOrUnknown(data['name_bn']!, _nameBnMeta),
      );
    } else if (isInserting) {
      context.missing(_nameBnMeta);
    }
    if (data.containsKey('name_en')) {
      context.handle(
        _nameEnMeta,
        nameEn.isAcceptableOrUnknown(data['name_en']!, _nameEnMeta),
      );
    }
    if (data.containsKey('phones_json')) {
      context.handle(
        _phonesJsonMeta,
        phonesJson.isAcceptableOrUnknown(data['phones_json']!, _phonesJsonMeta),
      );
    }
    if (data.containsKey('address')) {
      context.handle(
        _addressMeta,
        address.isAcceptableOrUnknown(data['address']!, _addressMeta),
      );
    }
    if (data.containsKey('area_id')) {
      context.handle(
        _areaIdMeta,
        areaId.isAcceptableOrUnknown(data['area_id']!, _areaIdMeta),
      );
    }
    if (data.containsKey('area_name')) {
      context.handle(
        _areaNameMeta,
        areaName.isAcceptableOrUnknown(data['area_name']!, _areaNameMeta),
      );
    }
    if (data.containsKey('lat')) {
      context.handle(
        _latMeta,
        lat.isAcceptableOrUnknown(data['lat']!, _latMeta),
      );
    }
    if (data.containsKey('lng')) {
      context.handle(
        _lngMeta,
        lng.isAcceptableOrUnknown(data['lng']!, _lngMeta),
      );
    }
    if (data.containsKey('location_status')) {
      context.handle(
        _locationStatusMeta,
        locationStatus.isAcceptableOrUnknown(
          data['location_status']!,
          _locationStatusMeta,
        ),
      );
    }
    if (data.containsKey('total_outstanding_poisha')) {
      context.handle(
        _totalOutstandingPoishaMeta,
        totalOutstandingPoisha.isAcceptableOrUnknown(
          data['total_outstanding_poisha']!,
          _totalOutstandingPoishaMeta,
        ),
      );
    }
    if (data.containsKey('installment_poisha')) {
      context.handle(
        _installmentPoishaMeta,
        installmentPoisha.isAcceptableOrUnknown(
          data['installment_poisha']!,
          _installmentPoishaMeta,
        ),
      );
    }
    if (data.containsKey('overdue_poisha')) {
      context.handle(
        _overduePoishaMeta,
        overduePoisha.isAcceptableOrUnknown(
          data['overdue_poisha']!,
          _overduePoishaMeta,
        ),
      );
    }
    if (data.containsKey('next_due_date')) {
      context.handle(
        _nextDueDateMeta,
        nextDueDate.isAcceptableOrUnknown(
          data['next_due_date']!,
          _nextDueDateMeta,
        ),
      );
    }
    if (data.containsKey('days_overdue')) {
      context.handle(
        _daysOverdueMeta,
        daysOverdue.isAcceptableOrUnknown(
          data['days_overdue']!,
          _daysOverdueMeta,
        ),
      );
    }
    if (data.containsKey('due_today')) {
      context.handle(
        _dueTodayMeta,
        dueToday.isAcceptableOrUnknown(data['due_today']!, _dueTodayMeta),
      );
    }
    if (data.containsKey('overdue')) {
      context.handle(
        _overdueMeta,
        overdue.isAcceptableOrUnknown(data['overdue']!, _overdueMeta),
      );
    }
    if (data.containsKey('bad_suggested')) {
      context.handle(
        _badSuggestedMeta,
        badSuggested.isAcceptableOrUnknown(
          data['bad_suggested']!,
          _badSuggestedMeta,
        ),
      );
    }
    if (data.containsKey('bad_reason_json')) {
      context.handle(
        _badReasonJsonMeta,
        badReasonJson.isAcceptableOrUnknown(
          data['bad_reason_json']!,
          _badReasonJsonMeta,
        ),
      );
    }
    if (data.containsKey('tag_state')) {
      context.handle(
        _tagStateMeta,
        tagState.isAcceptableOrUnknown(data['tag_state']!, _tagStateMeta),
      );
    }
    if (data.containsKey('tag_severity')) {
      context.handle(
        _tagSeverityMeta,
        tagSeverity.isAcceptableOrUnknown(
          data['tag_severity']!,
          _tagSeverityMeta,
        ),
      );
    }
    if (data.containsKey('tag_reason')) {
      context.handle(
        _tagReasonMeta,
        tagReason.isAcceptableOrUnknown(data['tag_reason']!, _tagReasonMeta),
      );
    }
    if (data.containsKey('last_visit_at')) {
      context.handle(
        _lastVisitAtMeta,
        lastVisitAt.isAcceptableOrUnknown(
          data['last_visit_at']!,
          _lastVisitAtMeta,
        ),
      );
    }
    if (data.containsKey('open_promise_id')) {
      context.handle(
        _openPromiseIdMeta,
        openPromiseId.isAcceptableOrUnknown(
          data['open_promise_id']!,
          _openPromiseIdMeta,
        ),
      );
    }
    if (data.containsKey('open_promise_date')) {
      context.handle(
        _openPromiseDateMeta,
        openPromiseDate.isAcceptableOrUnknown(
          data['open_promise_date']!,
          _openPromiseDateMeta,
        ),
      );
    }
    if (data.containsKey('open_promise_poisha')) {
      context.handle(
        _openPromisePoishaMeta,
        openPromisePoisha.isAcceptableOrUnknown(
          data['open_promise_poisha']!,
          _openPromisePoishaMeta,
        ),
      );
    }
    if (data.containsKey('pending_field_poisha')) {
      context.handle(
        _pendingFieldPoishaMeta,
        pendingFieldPoisha.isAcceptableOrUnknown(
          data['pending_field_poisha']!,
          _pendingFieldPoishaMeta,
        ),
      );
    }
    if (data.containsKey('assignee_id')) {
      context.handle(
        _assigneeIdMeta,
        assigneeId.isAcceptableOrUnknown(data['assignee_id']!, _assigneeIdMeta),
      );
    }
    if (data.containsKey('erp_fetched_at')) {
      context.handle(
        _erpFetchedAtMeta,
        erpFetchedAt.isAcceptableOrUnknown(
          data['erp_fetched_at']!,
          _erpFetchedAtMeta,
        ),
      );
    }
    if (data.containsKey('guarantor_json')) {
      context.handle(
        _guarantorJsonMeta,
        guarantorJson.isAcceptableOrUnknown(
          data['guarantor_json']!,
          _guarantorJsonMeta,
        ),
      );
    }
    if (data.containsKey('search_text')) {
      context.handle(
        _searchTextMeta,
        searchText.isAcceptableOrUnknown(data['search_text']!, _searchTextMeta),
      );
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {serverId};
  @override
  CustomerRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CustomerRow(
      serverId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}server_id'],
      )!,
      erpCustomerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}erp_customer_id'],
      ),
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      )!,
      nameBn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_bn'],
      )!,
      nameEn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_en'],
      ),
      phonesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phones_json'],
      )!,
      address: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address'],
      ),
      areaId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}area_id'],
      ),
      areaName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}area_name'],
      ),
      lat: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}lat'],
      ),
      lng: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}lng'],
      ),
      locationStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location_status'],
      )!,
      totalOutstandingPoisha: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_outstanding_poisha'],
      )!,
      installmentPoisha: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}installment_poisha'],
      ),
      overduePoisha: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}overdue_poisha'],
      )!,
      nextDueDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}next_due_date'],
      ),
      daysOverdue: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}days_overdue'],
      )!,
      dueToday: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}due_today'],
      )!,
      overdue: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}overdue'],
      )!,
      badSuggested: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}bad_suggested'],
      )!,
      badReasonJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bad_reason_json'],
      ),
      tagState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tag_state'],
      )!,
      tagSeverity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tag_severity'],
      ),
      tagReason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tag_reason'],
      ),
      lastVisitAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_visit_at'],
      ),
      openPromiseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}open_promise_id'],
      ),
      openPromiseDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}open_promise_date'],
      ),
      openPromisePoisha: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}open_promise_poisha'],
      ),
      pendingFieldPoisha: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pending_field_poisha'],
      )!,
      assigneeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}assignee_id'],
      ),
      erpFetchedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}erp_fetched_at'],
      ),
      guarantorJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}guarantor_json'],
      ),
      searchText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}search_text'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
    );
  }

  @override
  $CustomersTable createAlias(String alias) {
    return $CustomersTable(attachedDatabase, alias);
  }
}

class CustomerRow extends DataClass implements Insertable<CustomerRow> {
  final String serverId;
  final String? erpCustomerId;
  final String code;
  final String nameBn;
  final String? nameEn;
  final String phonesJson;
  final String? address;
  final String? areaId;
  final String? areaName;
  final double? lat;
  final double? lng;
  final String locationStatus;
  final int totalOutstandingPoisha;
  final int? installmentPoisha;
  final int overduePoisha;
  final String? nextDueDate;
  final int daysOverdue;
  final bool dueToday;
  final bool overdue;
  final bool badSuggested;
  final String? badReasonJson;
  final String tagState;
  final String? tagSeverity;
  final String? tagReason;
  final DateTime? lastVisitAt;
  final String? openPromiseId;
  final String? openPromiseDate;
  final int? openPromisePoisha;
  final int pendingFieldPoisha;
  final String? assigneeId;
  final DateTime? erpFetchedAt;
  final String? guarantorJson;
  final String searchText;
  final int version;
  const CustomerRow({
    required this.serverId,
    this.erpCustomerId,
    required this.code,
    required this.nameBn,
    this.nameEn,
    required this.phonesJson,
    this.address,
    this.areaId,
    this.areaName,
    this.lat,
    this.lng,
    required this.locationStatus,
    required this.totalOutstandingPoisha,
    this.installmentPoisha,
    required this.overduePoisha,
    this.nextDueDate,
    required this.daysOverdue,
    required this.dueToday,
    required this.overdue,
    required this.badSuggested,
    this.badReasonJson,
    required this.tagState,
    this.tagSeverity,
    this.tagReason,
    this.lastVisitAt,
    this.openPromiseId,
    this.openPromiseDate,
    this.openPromisePoisha,
    required this.pendingFieldPoisha,
    this.assigneeId,
    this.erpFetchedAt,
    this.guarantorJson,
    required this.searchText,
    required this.version,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['server_id'] = Variable<String>(serverId);
    if (!nullToAbsent || erpCustomerId != null) {
      map['erp_customer_id'] = Variable<String>(erpCustomerId);
    }
    map['code'] = Variable<String>(code);
    map['name_bn'] = Variable<String>(nameBn);
    if (!nullToAbsent || nameEn != null) {
      map['name_en'] = Variable<String>(nameEn);
    }
    map['phones_json'] = Variable<String>(phonesJson);
    if (!nullToAbsent || address != null) {
      map['address'] = Variable<String>(address);
    }
    if (!nullToAbsent || areaId != null) {
      map['area_id'] = Variable<String>(areaId);
    }
    if (!nullToAbsent || areaName != null) {
      map['area_name'] = Variable<String>(areaName);
    }
    if (!nullToAbsent || lat != null) {
      map['lat'] = Variable<double>(lat);
    }
    if (!nullToAbsent || lng != null) {
      map['lng'] = Variable<double>(lng);
    }
    map['location_status'] = Variable<String>(locationStatus);
    map['total_outstanding_poisha'] = Variable<int>(totalOutstandingPoisha);
    if (!nullToAbsent || installmentPoisha != null) {
      map['installment_poisha'] = Variable<int>(installmentPoisha);
    }
    map['overdue_poisha'] = Variable<int>(overduePoisha);
    if (!nullToAbsent || nextDueDate != null) {
      map['next_due_date'] = Variable<String>(nextDueDate);
    }
    map['days_overdue'] = Variable<int>(daysOverdue);
    map['due_today'] = Variable<bool>(dueToday);
    map['overdue'] = Variable<bool>(overdue);
    map['bad_suggested'] = Variable<bool>(badSuggested);
    if (!nullToAbsent || badReasonJson != null) {
      map['bad_reason_json'] = Variable<String>(badReasonJson);
    }
    map['tag_state'] = Variable<String>(tagState);
    if (!nullToAbsent || tagSeverity != null) {
      map['tag_severity'] = Variable<String>(tagSeverity);
    }
    if (!nullToAbsent || tagReason != null) {
      map['tag_reason'] = Variable<String>(tagReason);
    }
    if (!nullToAbsent || lastVisitAt != null) {
      map['last_visit_at'] = Variable<DateTime>(lastVisitAt);
    }
    if (!nullToAbsent || openPromiseId != null) {
      map['open_promise_id'] = Variable<String>(openPromiseId);
    }
    if (!nullToAbsent || openPromiseDate != null) {
      map['open_promise_date'] = Variable<String>(openPromiseDate);
    }
    if (!nullToAbsent || openPromisePoisha != null) {
      map['open_promise_poisha'] = Variable<int>(openPromisePoisha);
    }
    map['pending_field_poisha'] = Variable<int>(pendingFieldPoisha);
    if (!nullToAbsent || assigneeId != null) {
      map['assignee_id'] = Variable<String>(assigneeId);
    }
    if (!nullToAbsent || erpFetchedAt != null) {
      map['erp_fetched_at'] = Variable<DateTime>(erpFetchedAt);
    }
    if (!nullToAbsent || guarantorJson != null) {
      map['guarantor_json'] = Variable<String>(guarantorJson);
    }
    map['search_text'] = Variable<String>(searchText);
    map['version'] = Variable<int>(version);
    return map;
  }

  CustomersCompanion toCompanion(bool nullToAbsent) {
    return CustomersCompanion(
      serverId: Value(serverId),
      erpCustomerId: erpCustomerId == null && nullToAbsent
          ? const Value.absent()
          : Value(erpCustomerId),
      code: Value(code),
      nameBn: Value(nameBn),
      nameEn: nameEn == null && nullToAbsent
          ? const Value.absent()
          : Value(nameEn),
      phonesJson: Value(phonesJson),
      address: address == null && nullToAbsent
          ? const Value.absent()
          : Value(address),
      areaId: areaId == null && nullToAbsent
          ? const Value.absent()
          : Value(areaId),
      areaName: areaName == null && nullToAbsent
          ? const Value.absent()
          : Value(areaName),
      lat: lat == null && nullToAbsent ? const Value.absent() : Value(lat),
      lng: lng == null && nullToAbsent ? const Value.absent() : Value(lng),
      locationStatus: Value(locationStatus),
      totalOutstandingPoisha: Value(totalOutstandingPoisha),
      installmentPoisha: installmentPoisha == null && nullToAbsent
          ? const Value.absent()
          : Value(installmentPoisha),
      overduePoisha: Value(overduePoisha),
      nextDueDate: nextDueDate == null && nullToAbsent
          ? const Value.absent()
          : Value(nextDueDate),
      daysOverdue: Value(daysOverdue),
      dueToday: Value(dueToday),
      overdue: Value(overdue),
      badSuggested: Value(badSuggested),
      badReasonJson: badReasonJson == null && nullToAbsent
          ? const Value.absent()
          : Value(badReasonJson),
      tagState: Value(tagState),
      tagSeverity: tagSeverity == null && nullToAbsent
          ? const Value.absent()
          : Value(tagSeverity),
      tagReason: tagReason == null && nullToAbsent
          ? const Value.absent()
          : Value(tagReason),
      lastVisitAt: lastVisitAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastVisitAt),
      openPromiseId: openPromiseId == null && nullToAbsent
          ? const Value.absent()
          : Value(openPromiseId),
      openPromiseDate: openPromiseDate == null && nullToAbsent
          ? const Value.absent()
          : Value(openPromiseDate),
      openPromisePoisha: openPromisePoisha == null && nullToAbsent
          ? const Value.absent()
          : Value(openPromisePoisha),
      pendingFieldPoisha: Value(pendingFieldPoisha),
      assigneeId: assigneeId == null && nullToAbsent
          ? const Value.absent()
          : Value(assigneeId),
      erpFetchedAt: erpFetchedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(erpFetchedAt),
      guarantorJson: guarantorJson == null && nullToAbsent
          ? const Value.absent()
          : Value(guarantorJson),
      searchText: Value(searchText),
      version: Value(version),
    );
  }

  factory CustomerRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CustomerRow(
      serverId: serializer.fromJson<String>(json['serverId']),
      erpCustomerId: serializer.fromJson<String?>(json['erpCustomerId']),
      code: serializer.fromJson<String>(json['code']),
      nameBn: serializer.fromJson<String>(json['nameBn']),
      nameEn: serializer.fromJson<String?>(json['nameEn']),
      phonesJson: serializer.fromJson<String>(json['phonesJson']),
      address: serializer.fromJson<String?>(json['address']),
      areaId: serializer.fromJson<String?>(json['areaId']),
      areaName: serializer.fromJson<String?>(json['areaName']),
      lat: serializer.fromJson<double?>(json['lat']),
      lng: serializer.fromJson<double?>(json['lng']),
      locationStatus: serializer.fromJson<String>(json['locationStatus']),
      totalOutstandingPoisha: serializer.fromJson<int>(
        json['totalOutstandingPoisha'],
      ),
      installmentPoisha: serializer.fromJson<int?>(json['installmentPoisha']),
      overduePoisha: serializer.fromJson<int>(json['overduePoisha']),
      nextDueDate: serializer.fromJson<String?>(json['nextDueDate']),
      daysOverdue: serializer.fromJson<int>(json['daysOverdue']),
      dueToday: serializer.fromJson<bool>(json['dueToday']),
      overdue: serializer.fromJson<bool>(json['overdue']),
      badSuggested: serializer.fromJson<bool>(json['badSuggested']),
      badReasonJson: serializer.fromJson<String?>(json['badReasonJson']),
      tagState: serializer.fromJson<String>(json['tagState']),
      tagSeverity: serializer.fromJson<String?>(json['tagSeverity']),
      tagReason: serializer.fromJson<String?>(json['tagReason']),
      lastVisitAt: serializer.fromJson<DateTime?>(json['lastVisitAt']),
      openPromiseId: serializer.fromJson<String?>(json['openPromiseId']),
      openPromiseDate: serializer.fromJson<String?>(json['openPromiseDate']),
      openPromisePoisha: serializer.fromJson<int?>(json['openPromisePoisha']),
      pendingFieldPoisha: serializer.fromJson<int>(json['pendingFieldPoisha']),
      assigneeId: serializer.fromJson<String?>(json['assigneeId']),
      erpFetchedAt: serializer.fromJson<DateTime?>(json['erpFetchedAt']),
      guarantorJson: serializer.fromJson<String?>(json['guarantorJson']),
      searchText: serializer.fromJson<String>(json['searchText']),
      version: serializer.fromJson<int>(json['version']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'serverId': serializer.toJson<String>(serverId),
      'erpCustomerId': serializer.toJson<String?>(erpCustomerId),
      'code': serializer.toJson<String>(code),
      'nameBn': serializer.toJson<String>(nameBn),
      'nameEn': serializer.toJson<String?>(nameEn),
      'phonesJson': serializer.toJson<String>(phonesJson),
      'address': serializer.toJson<String?>(address),
      'areaId': serializer.toJson<String?>(areaId),
      'areaName': serializer.toJson<String?>(areaName),
      'lat': serializer.toJson<double?>(lat),
      'lng': serializer.toJson<double?>(lng),
      'locationStatus': serializer.toJson<String>(locationStatus),
      'totalOutstandingPoisha': serializer.toJson<int>(totalOutstandingPoisha),
      'installmentPoisha': serializer.toJson<int?>(installmentPoisha),
      'overduePoisha': serializer.toJson<int>(overduePoisha),
      'nextDueDate': serializer.toJson<String?>(nextDueDate),
      'daysOverdue': serializer.toJson<int>(daysOverdue),
      'dueToday': serializer.toJson<bool>(dueToday),
      'overdue': serializer.toJson<bool>(overdue),
      'badSuggested': serializer.toJson<bool>(badSuggested),
      'badReasonJson': serializer.toJson<String?>(badReasonJson),
      'tagState': serializer.toJson<String>(tagState),
      'tagSeverity': serializer.toJson<String?>(tagSeverity),
      'tagReason': serializer.toJson<String?>(tagReason),
      'lastVisitAt': serializer.toJson<DateTime?>(lastVisitAt),
      'openPromiseId': serializer.toJson<String?>(openPromiseId),
      'openPromiseDate': serializer.toJson<String?>(openPromiseDate),
      'openPromisePoisha': serializer.toJson<int?>(openPromisePoisha),
      'pendingFieldPoisha': serializer.toJson<int>(pendingFieldPoisha),
      'assigneeId': serializer.toJson<String?>(assigneeId),
      'erpFetchedAt': serializer.toJson<DateTime?>(erpFetchedAt),
      'guarantorJson': serializer.toJson<String?>(guarantorJson),
      'searchText': serializer.toJson<String>(searchText),
      'version': serializer.toJson<int>(version),
    };
  }

  CustomerRow copyWith({
    String? serverId,
    Value<String?> erpCustomerId = const Value.absent(),
    String? code,
    String? nameBn,
    Value<String?> nameEn = const Value.absent(),
    String? phonesJson,
    Value<String?> address = const Value.absent(),
    Value<String?> areaId = const Value.absent(),
    Value<String?> areaName = const Value.absent(),
    Value<double?> lat = const Value.absent(),
    Value<double?> lng = const Value.absent(),
    String? locationStatus,
    int? totalOutstandingPoisha,
    Value<int?> installmentPoisha = const Value.absent(),
    int? overduePoisha,
    Value<String?> nextDueDate = const Value.absent(),
    int? daysOverdue,
    bool? dueToday,
    bool? overdue,
    bool? badSuggested,
    Value<String?> badReasonJson = const Value.absent(),
    String? tagState,
    Value<String?> tagSeverity = const Value.absent(),
    Value<String?> tagReason = const Value.absent(),
    Value<DateTime?> lastVisitAt = const Value.absent(),
    Value<String?> openPromiseId = const Value.absent(),
    Value<String?> openPromiseDate = const Value.absent(),
    Value<int?> openPromisePoisha = const Value.absent(),
    int? pendingFieldPoisha,
    Value<String?> assigneeId = const Value.absent(),
    Value<DateTime?> erpFetchedAt = const Value.absent(),
    Value<String?> guarantorJson = const Value.absent(),
    String? searchText,
    int? version,
  }) => CustomerRow(
    serverId: serverId ?? this.serverId,
    erpCustomerId: erpCustomerId.present
        ? erpCustomerId.value
        : this.erpCustomerId,
    code: code ?? this.code,
    nameBn: nameBn ?? this.nameBn,
    nameEn: nameEn.present ? nameEn.value : this.nameEn,
    phonesJson: phonesJson ?? this.phonesJson,
    address: address.present ? address.value : this.address,
    areaId: areaId.present ? areaId.value : this.areaId,
    areaName: areaName.present ? areaName.value : this.areaName,
    lat: lat.present ? lat.value : this.lat,
    lng: lng.present ? lng.value : this.lng,
    locationStatus: locationStatus ?? this.locationStatus,
    totalOutstandingPoisha:
        totalOutstandingPoisha ?? this.totalOutstandingPoisha,
    installmentPoisha: installmentPoisha.present
        ? installmentPoisha.value
        : this.installmentPoisha,
    overduePoisha: overduePoisha ?? this.overduePoisha,
    nextDueDate: nextDueDate.present ? nextDueDate.value : this.nextDueDate,
    daysOverdue: daysOverdue ?? this.daysOverdue,
    dueToday: dueToday ?? this.dueToday,
    overdue: overdue ?? this.overdue,
    badSuggested: badSuggested ?? this.badSuggested,
    badReasonJson: badReasonJson.present
        ? badReasonJson.value
        : this.badReasonJson,
    tagState: tagState ?? this.tagState,
    tagSeverity: tagSeverity.present ? tagSeverity.value : this.tagSeverity,
    tagReason: tagReason.present ? tagReason.value : this.tagReason,
    lastVisitAt: lastVisitAt.present ? lastVisitAt.value : this.lastVisitAt,
    openPromiseId: openPromiseId.present
        ? openPromiseId.value
        : this.openPromiseId,
    openPromiseDate: openPromiseDate.present
        ? openPromiseDate.value
        : this.openPromiseDate,
    openPromisePoisha: openPromisePoisha.present
        ? openPromisePoisha.value
        : this.openPromisePoisha,
    pendingFieldPoisha: pendingFieldPoisha ?? this.pendingFieldPoisha,
    assigneeId: assigneeId.present ? assigneeId.value : this.assigneeId,
    erpFetchedAt: erpFetchedAt.present ? erpFetchedAt.value : this.erpFetchedAt,
    guarantorJson: guarantorJson.present
        ? guarantorJson.value
        : this.guarantorJson,
    searchText: searchText ?? this.searchText,
    version: version ?? this.version,
  );
  CustomerRow copyWithCompanion(CustomersCompanion data) {
    return CustomerRow(
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      erpCustomerId: data.erpCustomerId.present
          ? data.erpCustomerId.value
          : this.erpCustomerId,
      code: data.code.present ? data.code.value : this.code,
      nameBn: data.nameBn.present ? data.nameBn.value : this.nameBn,
      nameEn: data.nameEn.present ? data.nameEn.value : this.nameEn,
      phonesJson: data.phonesJson.present
          ? data.phonesJson.value
          : this.phonesJson,
      address: data.address.present ? data.address.value : this.address,
      areaId: data.areaId.present ? data.areaId.value : this.areaId,
      areaName: data.areaName.present ? data.areaName.value : this.areaName,
      lat: data.lat.present ? data.lat.value : this.lat,
      lng: data.lng.present ? data.lng.value : this.lng,
      locationStatus: data.locationStatus.present
          ? data.locationStatus.value
          : this.locationStatus,
      totalOutstandingPoisha: data.totalOutstandingPoisha.present
          ? data.totalOutstandingPoisha.value
          : this.totalOutstandingPoisha,
      installmentPoisha: data.installmentPoisha.present
          ? data.installmentPoisha.value
          : this.installmentPoisha,
      overduePoisha: data.overduePoisha.present
          ? data.overduePoisha.value
          : this.overduePoisha,
      nextDueDate: data.nextDueDate.present
          ? data.nextDueDate.value
          : this.nextDueDate,
      daysOverdue: data.daysOverdue.present
          ? data.daysOverdue.value
          : this.daysOverdue,
      dueToday: data.dueToday.present ? data.dueToday.value : this.dueToday,
      overdue: data.overdue.present ? data.overdue.value : this.overdue,
      badSuggested: data.badSuggested.present
          ? data.badSuggested.value
          : this.badSuggested,
      badReasonJson: data.badReasonJson.present
          ? data.badReasonJson.value
          : this.badReasonJson,
      tagState: data.tagState.present ? data.tagState.value : this.tagState,
      tagSeverity: data.tagSeverity.present
          ? data.tagSeverity.value
          : this.tagSeverity,
      tagReason: data.tagReason.present ? data.tagReason.value : this.tagReason,
      lastVisitAt: data.lastVisitAt.present
          ? data.lastVisitAt.value
          : this.lastVisitAt,
      openPromiseId: data.openPromiseId.present
          ? data.openPromiseId.value
          : this.openPromiseId,
      openPromiseDate: data.openPromiseDate.present
          ? data.openPromiseDate.value
          : this.openPromiseDate,
      openPromisePoisha: data.openPromisePoisha.present
          ? data.openPromisePoisha.value
          : this.openPromisePoisha,
      pendingFieldPoisha: data.pendingFieldPoisha.present
          ? data.pendingFieldPoisha.value
          : this.pendingFieldPoisha,
      assigneeId: data.assigneeId.present
          ? data.assigneeId.value
          : this.assigneeId,
      erpFetchedAt: data.erpFetchedAt.present
          ? data.erpFetchedAt.value
          : this.erpFetchedAt,
      guarantorJson: data.guarantorJson.present
          ? data.guarantorJson.value
          : this.guarantorJson,
      searchText: data.searchText.present
          ? data.searchText.value
          : this.searchText,
      version: data.version.present ? data.version.value : this.version,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CustomerRow(')
          ..write('serverId: $serverId, ')
          ..write('erpCustomerId: $erpCustomerId, ')
          ..write('code: $code, ')
          ..write('nameBn: $nameBn, ')
          ..write('nameEn: $nameEn, ')
          ..write('phonesJson: $phonesJson, ')
          ..write('address: $address, ')
          ..write('areaId: $areaId, ')
          ..write('areaName: $areaName, ')
          ..write('lat: $lat, ')
          ..write('lng: $lng, ')
          ..write('locationStatus: $locationStatus, ')
          ..write('totalOutstandingPoisha: $totalOutstandingPoisha, ')
          ..write('installmentPoisha: $installmentPoisha, ')
          ..write('overduePoisha: $overduePoisha, ')
          ..write('nextDueDate: $nextDueDate, ')
          ..write('daysOverdue: $daysOverdue, ')
          ..write('dueToday: $dueToday, ')
          ..write('overdue: $overdue, ')
          ..write('badSuggested: $badSuggested, ')
          ..write('badReasonJson: $badReasonJson, ')
          ..write('tagState: $tagState, ')
          ..write('tagSeverity: $tagSeverity, ')
          ..write('tagReason: $tagReason, ')
          ..write('lastVisitAt: $lastVisitAt, ')
          ..write('openPromiseId: $openPromiseId, ')
          ..write('openPromiseDate: $openPromiseDate, ')
          ..write('openPromisePoisha: $openPromisePoisha, ')
          ..write('pendingFieldPoisha: $pendingFieldPoisha, ')
          ..write('assigneeId: $assigneeId, ')
          ..write('erpFetchedAt: $erpFetchedAt, ')
          ..write('guarantorJson: $guarantorJson, ')
          ..write('searchText: $searchText, ')
          ..write('version: $version')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    serverId,
    erpCustomerId,
    code,
    nameBn,
    nameEn,
    phonesJson,
    address,
    areaId,
    areaName,
    lat,
    lng,
    locationStatus,
    totalOutstandingPoisha,
    installmentPoisha,
    overduePoisha,
    nextDueDate,
    daysOverdue,
    dueToday,
    overdue,
    badSuggested,
    badReasonJson,
    tagState,
    tagSeverity,
    tagReason,
    lastVisitAt,
    openPromiseId,
    openPromiseDate,
    openPromisePoisha,
    pendingFieldPoisha,
    assigneeId,
    erpFetchedAt,
    guarantorJson,
    searchText,
    version,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CustomerRow &&
          other.serverId == this.serverId &&
          other.erpCustomerId == this.erpCustomerId &&
          other.code == this.code &&
          other.nameBn == this.nameBn &&
          other.nameEn == this.nameEn &&
          other.phonesJson == this.phonesJson &&
          other.address == this.address &&
          other.areaId == this.areaId &&
          other.areaName == this.areaName &&
          other.lat == this.lat &&
          other.lng == this.lng &&
          other.locationStatus == this.locationStatus &&
          other.totalOutstandingPoisha == this.totalOutstandingPoisha &&
          other.installmentPoisha == this.installmentPoisha &&
          other.overduePoisha == this.overduePoisha &&
          other.nextDueDate == this.nextDueDate &&
          other.daysOverdue == this.daysOverdue &&
          other.dueToday == this.dueToday &&
          other.overdue == this.overdue &&
          other.badSuggested == this.badSuggested &&
          other.badReasonJson == this.badReasonJson &&
          other.tagState == this.tagState &&
          other.tagSeverity == this.tagSeverity &&
          other.tagReason == this.tagReason &&
          other.lastVisitAt == this.lastVisitAt &&
          other.openPromiseId == this.openPromiseId &&
          other.openPromiseDate == this.openPromiseDate &&
          other.openPromisePoisha == this.openPromisePoisha &&
          other.pendingFieldPoisha == this.pendingFieldPoisha &&
          other.assigneeId == this.assigneeId &&
          other.erpFetchedAt == this.erpFetchedAt &&
          other.guarantorJson == this.guarantorJson &&
          other.searchText == this.searchText &&
          other.version == this.version);
}

class CustomersCompanion extends UpdateCompanion<CustomerRow> {
  final Value<String> serverId;
  final Value<String?> erpCustomerId;
  final Value<String> code;
  final Value<String> nameBn;
  final Value<String?> nameEn;
  final Value<String> phonesJson;
  final Value<String?> address;
  final Value<String?> areaId;
  final Value<String?> areaName;
  final Value<double?> lat;
  final Value<double?> lng;
  final Value<String> locationStatus;
  final Value<int> totalOutstandingPoisha;
  final Value<int?> installmentPoisha;
  final Value<int> overduePoisha;
  final Value<String?> nextDueDate;
  final Value<int> daysOverdue;
  final Value<bool> dueToday;
  final Value<bool> overdue;
  final Value<bool> badSuggested;
  final Value<String?> badReasonJson;
  final Value<String> tagState;
  final Value<String?> tagSeverity;
  final Value<String?> tagReason;
  final Value<DateTime?> lastVisitAt;
  final Value<String?> openPromiseId;
  final Value<String?> openPromiseDate;
  final Value<int?> openPromisePoisha;
  final Value<int> pendingFieldPoisha;
  final Value<String?> assigneeId;
  final Value<DateTime?> erpFetchedAt;
  final Value<String?> guarantorJson;
  final Value<String> searchText;
  final Value<int> version;
  final Value<int> rowid;
  const CustomersCompanion({
    this.serverId = const Value.absent(),
    this.erpCustomerId = const Value.absent(),
    this.code = const Value.absent(),
    this.nameBn = const Value.absent(),
    this.nameEn = const Value.absent(),
    this.phonesJson = const Value.absent(),
    this.address = const Value.absent(),
    this.areaId = const Value.absent(),
    this.areaName = const Value.absent(),
    this.lat = const Value.absent(),
    this.lng = const Value.absent(),
    this.locationStatus = const Value.absent(),
    this.totalOutstandingPoisha = const Value.absent(),
    this.installmentPoisha = const Value.absent(),
    this.overduePoisha = const Value.absent(),
    this.nextDueDate = const Value.absent(),
    this.daysOverdue = const Value.absent(),
    this.dueToday = const Value.absent(),
    this.overdue = const Value.absent(),
    this.badSuggested = const Value.absent(),
    this.badReasonJson = const Value.absent(),
    this.tagState = const Value.absent(),
    this.tagSeverity = const Value.absent(),
    this.tagReason = const Value.absent(),
    this.lastVisitAt = const Value.absent(),
    this.openPromiseId = const Value.absent(),
    this.openPromiseDate = const Value.absent(),
    this.openPromisePoisha = const Value.absent(),
    this.pendingFieldPoisha = const Value.absent(),
    this.assigneeId = const Value.absent(),
    this.erpFetchedAt = const Value.absent(),
    this.guarantorJson = const Value.absent(),
    this.searchText = const Value.absent(),
    this.version = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CustomersCompanion.insert({
    required String serverId,
    this.erpCustomerId = const Value.absent(),
    required String code,
    required String nameBn,
    this.nameEn = const Value.absent(),
    this.phonesJson = const Value.absent(),
    this.address = const Value.absent(),
    this.areaId = const Value.absent(),
    this.areaName = const Value.absent(),
    this.lat = const Value.absent(),
    this.lng = const Value.absent(),
    this.locationStatus = const Value.absent(),
    this.totalOutstandingPoisha = const Value.absent(),
    this.installmentPoisha = const Value.absent(),
    this.overduePoisha = const Value.absent(),
    this.nextDueDate = const Value.absent(),
    this.daysOverdue = const Value.absent(),
    this.dueToday = const Value.absent(),
    this.overdue = const Value.absent(),
    this.badSuggested = const Value.absent(),
    this.badReasonJson = const Value.absent(),
    this.tagState = const Value.absent(),
    this.tagSeverity = const Value.absent(),
    this.tagReason = const Value.absent(),
    this.lastVisitAt = const Value.absent(),
    this.openPromiseId = const Value.absent(),
    this.openPromiseDate = const Value.absent(),
    this.openPromisePoisha = const Value.absent(),
    this.pendingFieldPoisha = const Value.absent(),
    this.assigneeId = const Value.absent(),
    this.erpFetchedAt = const Value.absent(),
    this.guarantorJson = const Value.absent(),
    this.searchText = const Value.absent(),
    this.version = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : serverId = Value(serverId),
       code = Value(code),
       nameBn = Value(nameBn);
  static Insertable<CustomerRow> custom({
    Expression<String>? serverId,
    Expression<String>? erpCustomerId,
    Expression<String>? code,
    Expression<String>? nameBn,
    Expression<String>? nameEn,
    Expression<String>? phonesJson,
    Expression<String>? address,
    Expression<String>? areaId,
    Expression<String>? areaName,
    Expression<double>? lat,
    Expression<double>? lng,
    Expression<String>? locationStatus,
    Expression<int>? totalOutstandingPoisha,
    Expression<int>? installmentPoisha,
    Expression<int>? overduePoisha,
    Expression<String>? nextDueDate,
    Expression<int>? daysOverdue,
    Expression<bool>? dueToday,
    Expression<bool>? overdue,
    Expression<bool>? badSuggested,
    Expression<String>? badReasonJson,
    Expression<String>? tagState,
    Expression<String>? tagSeverity,
    Expression<String>? tagReason,
    Expression<DateTime>? lastVisitAt,
    Expression<String>? openPromiseId,
    Expression<String>? openPromiseDate,
    Expression<int>? openPromisePoisha,
    Expression<int>? pendingFieldPoisha,
    Expression<String>? assigneeId,
    Expression<DateTime>? erpFetchedAt,
    Expression<String>? guarantorJson,
    Expression<String>? searchText,
    Expression<int>? version,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (serverId != null) 'server_id': serverId,
      if (erpCustomerId != null) 'erp_customer_id': erpCustomerId,
      if (code != null) 'code': code,
      if (nameBn != null) 'name_bn': nameBn,
      if (nameEn != null) 'name_en': nameEn,
      if (phonesJson != null) 'phones_json': phonesJson,
      if (address != null) 'address': address,
      if (areaId != null) 'area_id': areaId,
      if (areaName != null) 'area_name': areaName,
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
      if (locationStatus != null) 'location_status': locationStatus,
      if (totalOutstandingPoisha != null)
        'total_outstanding_poisha': totalOutstandingPoisha,
      if (installmentPoisha != null) 'installment_poisha': installmentPoisha,
      if (overduePoisha != null) 'overdue_poisha': overduePoisha,
      if (nextDueDate != null) 'next_due_date': nextDueDate,
      if (daysOverdue != null) 'days_overdue': daysOverdue,
      if (dueToday != null) 'due_today': dueToday,
      if (overdue != null) 'overdue': overdue,
      if (badSuggested != null) 'bad_suggested': badSuggested,
      if (badReasonJson != null) 'bad_reason_json': badReasonJson,
      if (tagState != null) 'tag_state': tagState,
      if (tagSeverity != null) 'tag_severity': tagSeverity,
      if (tagReason != null) 'tag_reason': tagReason,
      if (lastVisitAt != null) 'last_visit_at': lastVisitAt,
      if (openPromiseId != null) 'open_promise_id': openPromiseId,
      if (openPromiseDate != null) 'open_promise_date': openPromiseDate,
      if (openPromisePoisha != null) 'open_promise_poisha': openPromisePoisha,
      if (pendingFieldPoisha != null)
        'pending_field_poisha': pendingFieldPoisha,
      if (assigneeId != null) 'assignee_id': assigneeId,
      if (erpFetchedAt != null) 'erp_fetched_at': erpFetchedAt,
      if (guarantorJson != null) 'guarantor_json': guarantorJson,
      if (searchText != null) 'search_text': searchText,
      if (version != null) 'version': version,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CustomersCompanion copyWith({
    Value<String>? serverId,
    Value<String?>? erpCustomerId,
    Value<String>? code,
    Value<String>? nameBn,
    Value<String?>? nameEn,
    Value<String>? phonesJson,
    Value<String?>? address,
    Value<String?>? areaId,
    Value<String?>? areaName,
    Value<double?>? lat,
    Value<double?>? lng,
    Value<String>? locationStatus,
    Value<int>? totalOutstandingPoisha,
    Value<int?>? installmentPoisha,
    Value<int>? overduePoisha,
    Value<String?>? nextDueDate,
    Value<int>? daysOverdue,
    Value<bool>? dueToday,
    Value<bool>? overdue,
    Value<bool>? badSuggested,
    Value<String?>? badReasonJson,
    Value<String>? tagState,
    Value<String?>? tagSeverity,
    Value<String?>? tagReason,
    Value<DateTime?>? lastVisitAt,
    Value<String?>? openPromiseId,
    Value<String?>? openPromiseDate,
    Value<int?>? openPromisePoisha,
    Value<int>? pendingFieldPoisha,
    Value<String?>? assigneeId,
    Value<DateTime?>? erpFetchedAt,
    Value<String?>? guarantorJson,
    Value<String>? searchText,
    Value<int>? version,
    Value<int>? rowid,
  }) {
    return CustomersCompanion(
      serverId: serverId ?? this.serverId,
      erpCustomerId: erpCustomerId ?? this.erpCustomerId,
      code: code ?? this.code,
      nameBn: nameBn ?? this.nameBn,
      nameEn: nameEn ?? this.nameEn,
      phonesJson: phonesJson ?? this.phonesJson,
      address: address ?? this.address,
      areaId: areaId ?? this.areaId,
      areaName: areaName ?? this.areaName,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      locationStatus: locationStatus ?? this.locationStatus,
      totalOutstandingPoisha:
          totalOutstandingPoisha ?? this.totalOutstandingPoisha,
      installmentPoisha: installmentPoisha ?? this.installmentPoisha,
      overduePoisha: overduePoisha ?? this.overduePoisha,
      nextDueDate: nextDueDate ?? this.nextDueDate,
      daysOverdue: daysOverdue ?? this.daysOverdue,
      dueToday: dueToday ?? this.dueToday,
      overdue: overdue ?? this.overdue,
      badSuggested: badSuggested ?? this.badSuggested,
      badReasonJson: badReasonJson ?? this.badReasonJson,
      tagState: tagState ?? this.tagState,
      tagSeverity: tagSeverity ?? this.tagSeverity,
      tagReason: tagReason ?? this.tagReason,
      lastVisitAt: lastVisitAt ?? this.lastVisitAt,
      openPromiseId: openPromiseId ?? this.openPromiseId,
      openPromiseDate: openPromiseDate ?? this.openPromiseDate,
      openPromisePoisha: openPromisePoisha ?? this.openPromisePoisha,
      pendingFieldPoisha: pendingFieldPoisha ?? this.pendingFieldPoisha,
      assigneeId: assigneeId ?? this.assigneeId,
      erpFetchedAt: erpFetchedAt ?? this.erpFetchedAt,
      guarantorJson: guarantorJson ?? this.guarantorJson,
      searchText: searchText ?? this.searchText,
      version: version ?? this.version,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (serverId.present) {
      map['server_id'] = Variable<String>(serverId.value);
    }
    if (erpCustomerId.present) {
      map['erp_customer_id'] = Variable<String>(erpCustomerId.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (nameBn.present) {
      map['name_bn'] = Variable<String>(nameBn.value);
    }
    if (nameEn.present) {
      map['name_en'] = Variable<String>(nameEn.value);
    }
    if (phonesJson.present) {
      map['phones_json'] = Variable<String>(phonesJson.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (areaId.present) {
      map['area_id'] = Variable<String>(areaId.value);
    }
    if (areaName.present) {
      map['area_name'] = Variable<String>(areaName.value);
    }
    if (lat.present) {
      map['lat'] = Variable<double>(lat.value);
    }
    if (lng.present) {
      map['lng'] = Variable<double>(lng.value);
    }
    if (locationStatus.present) {
      map['location_status'] = Variable<String>(locationStatus.value);
    }
    if (totalOutstandingPoisha.present) {
      map['total_outstanding_poisha'] = Variable<int>(
        totalOutstandingPoisha.value,
      );
    }
    if (installmentPoisha.present) {
      map['installment_poisha'] = Variable<int>(installmentPoisha.value);
    }
    if (overduePoisha.present) {
      map['overdue_poisha'] = Variable<int>(overduePoisha.value);
    }
    if (nextDueDate.present) {
      map['next_due_date'] = Variable<String>(nextDueDate.value);
    }
    if (daysOverdue.present) {
      map['days_overdue'] = Variable<int>(daysOverdue.value);
    }
    if (dueToday.present) {
      map['due_today'] = Variable<bool>(dueToday.value);
    }
    if (overdue.present) {
      map['overdue'] = Variable<bool>(overdue.value);
    }
    if (badSuggested.present) {
      map['bad_suggested'] = Variable<bool>(badSuggested.value);
    }
    if (badReasonJson.present) {
      map['bad_reason_json'] = Variable<String>(badReasonJson.value);
    }
    if (tagState.present) {
      map['tag_state'] = Variable<String>(tagState.value);
    }
    if (tagSeverity.present) {
      map['tag_severity'] = Variable<String>(tagSeverity.value);
    }
    if (tagReason.present) {
      map['tag_reason'] = Variable<String>(tagReason.value);
    }
    if (lastVisitAt.present) {
      map['last_visit_at'] = Variable<DateTime>(lastVisitAt.value);
    }
    if (openPromiseId.present) {
      map['open_promise_id'] = Variable<String>(openPromiseId.value);
    }
    if (openPromiseDate.present) {
      map['open_promise_date'] = Variable<String>(openPromiseDate.value);
    }
    if (openPromisePoisha.present) {
      map['open_promise_poisha'] = Variable<int>(openPromisePoisha.value);
    }
    if (pendingFieldPoisha.present) {
      map['pending_field_poisha'] = Variable<int>(pendingFieldPoisha.value);
    }
    if (assigneeId.present) {
      map['assignee_id'] = Variable<String>(assigneeId.value);
    }
    if (erpFetchedAt.present) {
      map['erp_fetched_at'] = Variable<DateTime>(erpFetchedAt.value);
    }
    if (guarantorJson.present) {
      map['guarantor_json'] = Variable<String>(guarantorJson.value);
    }
    if (searchText.present) {
      map['search_text'] = Variable<String>(searchText.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CustomersCompanion(')
          ..write('serverId: $serverId, ')
          ..write('erpCustomerId: $erpCustomerId, ')
          ..write('code: $code, ')
          ..write('nameBn: $nameBn, ')
          ..write('nameEn: $nameEn, ')
          ..write('phonesJson: $phonesJson, ')
          ..write('address: $address, ')
          ..write('areaId: $areaId, ')
          ..write('areaName: $areaName, ')
          ..write('lat: $lat, ')
          ..write('lng: $lng, ')
          ..write('locationStatus: $locationStatus, ')
          ..write('totalOutstandingPoisha: $totalOutstandingPoisha, ')
          ..write('installmentPoisha: $installmentPoisha, ')
          ..write('overduePoisha: $overduePoisha, ')
          ..write('nextDueDate: $nextDueDate, ')
          ..write('daysOverdue: $daysOverdue, ')
          ..write('dueToday: $dueToday, ')
          ..write('overdue: $overdue, ')
          ..write('badSuggested: $badSuggested, ')
          ..write('badReasonJson: $badReasonJson, ')
          ..write('tagState: $tagState, ')
          ..write('tagSeverity: $tagSeverity, ')
          ..write('tagReason: $tagReason, ')
          ..write('lastVisitAt: $lastVisitAt, ')
          ..write('openPromiseId: $openPromiseId, ')
          ..write('openPromiseDate: $openPromiseDate, ')
          ..write('openPromisePoisha: $openPromisePoisha, ')
          ..write('pendingFieldPoisha: $pendingFieldPoisha, ')
          ..write('assigneeId: $assigneeId, ')
          ..write('erpFetchedAt: $erpFetchedAt, ')
          ..write('guarantorJson: $guarantorJson, ')
          ..write('searchText: $searchText, ')
          ..write('version: $version, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlansTable extends Plans with TableInfo<$PlansTable, PlanRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlansTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _erpPlanIdMeta = const VerificationMeta(
    'erpPlanId',
  );
  @override
  late final GeneratedColumn<String> erpPlanId = GeneratedColumn<String>(
    'erp_plan_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _customerIdMeta = const VerificationMeta(
    'customerId',
  );
  @override
  late final GeneratedColumn<String> customerId = GeneratedColumn<String>(
    'customer_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _productMeta = const VerificationMeta(
    'product',
  );
  @override
  late final GeneratedColumn<String> product = GeneratedColumn<String>(
    'product',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startDateMeta = const VerificationMeta(
    'startDate',
  );
  @override
  late final GeneratedColumn<String> startDate = GeneratedColumn<String>(
    'start_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _finalDueDateMeta = const VerificationMeta(
    'finalDueDate',
  );
  @override
  late final GeneratedColumn<String> finalDueDate = GeneratedColumn<String>(
    'final_due_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _installmentCountMeta = const VerificationMeta(
    'installmentCount',
  );
  @override
  late final GeneratedColumn<int> installmentCount = GeneratedColumn<int>(
    'installment_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalPayablePoishaMeta =
      const VerificationMeta('totalPayablePoisha');
  @override
  late final GeneratedColumn<int> totalPayablePoisha = GeneratedColumn<int>(
    'total_payable_poisha',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _downPaymentPoishaMeta = const VerificationMeta(
    'downPaymentPoisha',
  );
  @override
  late final GeneratedColumn<int> downPaymentPoisha = GeneratedColumn<int>(
    'down_payment_poisha',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _paidPoishaMeta = const VerificationMeta(
    'paidPoisha',
  );
  @override
  late final GeneratedColumn<int> paidPoisha = GeneratedColumn<int>(
    'paid_poisha',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _outstandingPoishaMeta = const VerificationMeta(
    'outstandingPoisha',
  );
  @override
  late final GeneratedColumn<int> outstandingPoisha = GeneratedColumn<int>(
    'outstanding_poisha',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _badSuggestedMeta = const VerificationMeta(
    'badSuggested',
  );
  @override
  late final GeneratedColumn<bool> badSuggested = GeneratedColumn<bool>(
    'bad_suggested',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("bad_suggested" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    erpPlanId,
    customerId,
    product,
    startDate,
    finalDueDate,
    installmentCount,
    totalPayablePoisha,
    downPaymentPoisha,
    paidPoisha,
    outstandingPoisha,
    status,
    badSuggested,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'plans';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlanRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('erp_plan_id')) {
      context.handle(
        _erpPlanIdMeta,
        erpPlanId.isAcceptableOrUnknown(data['erp_plan_id']!, _erpPlanIdMeta),
      );
    } else if (isInserting) {
      context.missing(_erpPlanIdMeta);
    }
    if (data.containsKey('customer_id')) {
      context.handle(
        _customerIdMeta,
        customerId.isAcceptableOrUnknown(data['customer_id']!, _customerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_customerIdMeta);
    }
    if (data.containsKey('product')) {
      context.handle(
        _productMeta,
        product.isAcceptableOrUnknown(data['product']!, _productMeta),
      );
    } else if (isInserting) {
      context.missing(_productMeta);
    }
    if (data.containsKey('start_date')) {
      context.handle(
        _startDateMeta,
        startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta),
      );
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    if (data.containsKey('final_due_date')) {
      context.handle(
        _finalDueDateMeta,
        finalDueDate.isAcceptableOrUnknown(
          data['final_due_date']!,
          _finalDueDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_finalDueDateMeta);
    }
    if (data.containsKey('installment_count')) {
      context.handle(
        _installmentCountMeta,
        installmentCount.isAcceptableOrUnknown(
          data['installment_count']!,
          _installmentCountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_installmentCountMeta);
    }
    if (data.containsKey('total_payable_poisha')) {
      context.handle(
        _totalPayablePoishaMeta,
        totalPayablePoisha.isAcceptableOrUnknown(
          data['total_payable_poisha']!,
          _totalPayablePoishaMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_totalPayablePoishaMeta);
    }
    if (data.containsKey('down_payment_poisha')) {
      context.handle(
        _downPaymentPoishaMeta,
        downPaymentPoisha.isAcceptableOrUnknown(
          data['down_payment_poisha']!,
          _downPaymentPoishaMeta,
        ),
      );
    }
    if (data.containsKey('paid_poisha')) {
      context.handle(
        _paidPoishaMeta,
        paidPoisha.isAcceptableOrUnknown(data['paid_poisha']!, _paidPoishaMeta),
      );
    } else if (isInserting) {
      context.missing(_paidPoishaMeta);
    }
    if (data.containsKey('outstanding_poisha')) {
      context.handle(
        _outstandingPoishaMeta,
        outstandingPoisha.isAcceptableOrUnknown(
          data['outstanding_poisha']!,
          _outstandingPoishaMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_outstandingPoishaMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('bad_suggested')) {
      context.handle(
        _badSuggestedMeta,
        badSuggested.isAcceptableOrUnknown(
          data['bad_suggested']!,
          _badSuggestedMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {erpPlanId};
  @override
  PlanRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlanRow(
      erpPlanId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}erp_plan_id'],
      )!,
      customerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}customer_id'],
      )!,
      product: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product'],
      )!,
      startDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}start_date'],
      )!,
      finalDueDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}final_due_date'],
      )!,
      installmentCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}installment_count'],
      )!,
      totalPayablePoisha: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_payable_poisha'],
      )!,
      downPaymentPoisha: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}down_payment_poisha'],
      )!,
      paidPoisha: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}paid_poisha'],
      )!,
      outstandingPoisha: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}outstanding_poisha'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      badSuggested: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}bad_suggested'],
      )!,
    );
  }

  @override
  $PlansTable createAlias(String alias) {
    return $PlansTable(attachedDatabase, alias);
  }
}

class PlanRow extends DataClass implements Insertable<PlanRow> {
  final String erpPlanId;
  final String customerId;
  final String product;
  final String startDate;
  final String finalDueDate;
  final int installmentCount;
  final int totalPayablePoisha;
  final int downPaymentPoisha;
  final int paidPoisha;
  final int outstandingPoisha;
  final String status;
  final bool badSuggested;
  const PlanRow({
    required this.erpPlanId,
    required this.customerId,
    required this.product,
    required this.startDate,
    required this.finalDueDate,
    required this.installmentCount,
    required this.totalPayablePoisha,
    required this.downPaymentPoisha,
    required this.paidPoisha,
    required this.outstandingPoisha,
    required this.status,
    required this.badSuggested,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['erp_plan_id'] = Variable<String>(erpPlanId);
    map['customer_id'] = Variable<String>(customerId);
    map['product'] = Variable<String>(product);
    map['start_date'] = Variable<String>(startDate);
    map['final_due_date'] = Variable<String>(finalDueDate);
    map['installment_count'] = Variable<int>(installmentCount);
    map['total_payable_poisha'] = Variable<int>(totalPayablePoisha);
    map['down_payment_poisha'] = Variable<int>(downPaymentPoisha);
    map['paid_poisha'] = Variable<int>(paidPoisha);
    map['outstanding_poisha'] = Variable<int>(outstandingPoisha);
    map['status'] = Variable<String>(status);
    map['bad_suggested'] = Variable<bool>(badSuggested);
    return map;
  }

  PlansCompanion toCompanion(bool nullToAbsent) {
    return PlansCompanion(
      erpPlanId: Value(erpPlanId),
      customerId: Value(customerId),
      product: Value(product),
      startDate: Value(startDate),
      finalDueDate: Value(finalDueDate),
      installmentCount: Value(installmentCount),
      totalPayablePoisha: Value(totalPayablePoisha),
      downPaymentPoisha: Value(downPaymentPoisha),
      paidPoisha: Value(paidPoisha),
      outstandingPoisha: Value(outstandingPoisha),
      status: Value(status),
      badSuggested: Value(badSuggested),
    );
  }

  factory PlanRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlanRow(
      erpPlanId: serializer.fromJson<String>(json['erpPlanId']),
      customerId: serializer.fromJson<String>(json['customerId']),
      product: serializer.fromJson<String>(json['product']),
      startDate: serializer.fromJson<String>(json['startDate']),
      finalDueDate: serializer.fromJson<String>(json['finalDueDate']),
      installmentCount: serializer.fromJson<int>(json['installmentCount']),
      totalPayablePoisha: serializer.fromJson<int>(json['totalPayablePoisha']),
      downPaymentPoisha: serializer.fromJson<int>(json['downPaymentPoisha']),
      paidPoisha: serializer.fromJson<int>(json['paidPoisha']),
      outstandingPoisha: serializer.fromJson<int>(json['outstandingPoisha']),
      status: serializer.fromJson<String>(json['status']),
      badSuggested: serializer.fromJson<bool>(json['badSuggested']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'erpPlanId': serializer.toJson<String>(erpPlanId),
      'customerId': serializer.toJson<String>(customerId),
      'product': serializer.toJson<String>(product),
      'startDate': serializer.toJson<String>(startDate),
      'finalDueDate': serializer.toJson<String>(finalDueDate),
      'installmentCount': serializer.toJson<int>(installmentCount),
      'totalPayablePoisha': serializer.toJson<int>(totalPayablePoisha),
      'downPaymentPoisha': serializer.toJson<int>(downPaymentPoisha),
      'paidPoisha': serializer.toJson<int>(paidPoisha),
      'outstandingPoisha': serializer.toJson<int>(outstandingPoisha),
      'status': serializer.toJson<String>(status),
      'badSuggested': serializer.toJson<bool>(badSuggested),
    };
  }

  PlanRow copyWith({
    String? erpPlanId,
    String? customerId,
    String? product,
    String? startDate,
    String? finalDueDate,
    int? installmentCount,
    int? totalPayablePoisha,
    int? downPaymentPoisha,
    int? paidPoisha,
    int? outstandingPoisha,
    String? status,
    bool? badSuggested,
  }) => PlanRow(
    erpPlanId: erpPlanId ?? this.erpPlanId,
    customerId: customerId ?? this.customerId,
    product: product ?? this.product,
    startDate: startDate ?? this.startDate,
    finalDueDate: finalDueDate ?? this.finalDueDate,
    installmentCount: installmentCount ?? this.installmentCount,
    totalPayablePoisha: totalPayablePoisha ?? this.totalPayablePoisha,
    downPaymentPoisha: downPaymentPoisha ?? this.downPaymentPoisha,
    paidPoisha: paidPoisha ?? this.paidPoisha,
    outstandingPoisha: outstandingPoisha ?? this.outstandingPoisha,
    status: status ?? this.status,
    badSuggested: badSuggested ?? this.badSuggested,
  );
  PlanRow copyWithCompanion(PlansCompanion data) {
    return PlanRow(
      erpPlanId: data.erpPlanId.present ? data.erpPlanId.value : this.erpPlanId,
      customerId: data.customerId.present
          ? data.customerId.value
          : this.customerId,
      product: data.product.present ? data.product.value : this.product,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      finalDueDate: data.finalDueDate.present
          ? data.finalDueDate.value
          : this.finalDueDate,
      installmentCount: data.installmentCount.present
          ? data.installmentCount.value
          : this.installmentCount,
      totalPayablePoisha: data.totalPayablePoisha.present
          ? data.totalPayablePoisha.value
          : this.totalPayablePoisha,
      downPaymentPoisha: data.downPaymentPoisha.present
          ? data.downPaymentPoisha.value
          : this.downPaymentPoisha,
      paidPoisha: data.paidPoisha.present
          ? data.paidPoisha.value
          : this.paidPoisha,
      outstandingPoisha: data.outstandingPoisha.present
          ? data.outstandingPoisha.value
          : this.outstandingPoisha,
      status: data.status.present ? data.status.value : this.status,
      badSuggested: data.badSuggested.present
          ? data.badSuggested.value
          : this.badSuggested,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlanRow(')
          ..write('erpPlanId: $erpPlanId, ')
          ..write('customerId: $customerId, ')
          ..write('product: $product, ')
          ..write('startDate: $startDate, ')
          ..write('finalDueDate: $finalDueDate, ')
          ..write('installmentCount: $installmentCount, ')
          ..write('totalPayablePoisha: $totalPayablePoisha, ')
          ..write('downPaymentPoisha: $downPaymentPoisha, ')
          ..write('paidPoisha: $paidPoisha, ')
          ..write('outstandingPoisha: $outstandingPoisha, ')
          ..write('status: $status, ')
          ..write('badSuggested: $badSuggested')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    erpPlanId,
    customerId,
    product,
    startDate,
    finalDueDate,
    installmentCount,
    totalPayablePoisha,
    downPaymentPoisha,
    paidPoisha,
    outstandingPoisha,
    status,
    badSuggested,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlanRow &&
          other.erpPlanId == this.erpPlanId &&
          other.customerId == this.customerId &&
          other.product == this.product &&
          other.startDate == this.startDate &&
          other.finalDueDate == this.finalDueDate &&
          other.installmentCount == this.installmentCount &&
          other.totalPayablePoisha == this.totalPayablePoisha &&
          other.downPaymentPoisha == this.downPaymentPoisha &&
          other.paidPoisha == this.paidPoisha &&
          other.outstandingPoisha == this.outstandingPoisha &&
          other.status == this.status &&
          other.badSuggested == this.badSuggested);
}

class PlansCompanion extends UpdateCompanion<PlanRow> {
  final Value<String> erpPlanId;
  final Value<String> customerId;
  final Value<String> product;
  final Value<String> startDate;
  final Value<String> finalDueDate;
  final Value<int> installmentCount;
  final Value<int> totalPayablePoisha;
  final Value<int> downPaymentPoisha;
  final Value<int> paidPoisha;
  final Value<int> outstandingPoisha;
  final Value<String> status;
  final Value<bool> badSuggested;
  final Value<int> rowid;
  const PlansCompanion({
    this.erpPlanId = const Value.absent(),
    this.customerId = const Value.absent(),
    this.product = const Value.absent(),
    this.startDate = const Value.absent(),
    this.finalDueDate = const Value.absent(),
    this.installmentCount = const Value.absent(),
    this.totalPayablePoisha = const Value.absent(),
    this.downPaymentPoisha = const Value.absent(),
    this.paidPoisha = const Value.absent(),
    this.outstandingPoisha = const Value.absent(),
    this.status = const Value.absent(),
    this.badSuggested = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlansCompanion.insert({
    required String erpPlanId,
    required String customerId,
    required String product,
    required String startDate,
    required String finalDueDate,
    required int installmentCount,
    required int totalPayablePoisha,
    this.downPaymentPoisha = const Value.absent(),
    required int paidPoisha,
    required int outstandingPoisha,
    required String status,
    this.badSuggested = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : erpPlanId = Value(erpPlanId),
       customerId = Value(customerId),
       product = Value(product),
       startDate = Value(startDate),
       finalDueDate = Value(finalDueDate),
       installmentCount = Value(installmentCount),
       totalPayablePoisha = Value(totalPayablePoisha),
       paidPoisha = Value(paidPoisha),
       outstandingPoisha = Value(outstandingPoisha),
       status = Value(status);
  static Insertable<PlanRow> custom({
    Expression<String>? erpPlanId,
    Expression<String>? customerId,
    Expression<String>? product,
    Expression<String>? startDate,
    Expression<String>? finalDueDate,
    Expression<int>? installmentCount,
    Expression<int>? totalPayablePoisha,
    Expression<int>? downPaymentPoisha,
    Expression<int>? paidPoisha,
    Expression<int>? outstandingPoisha,
    Expression<String>? status,
    Expression<bool>? badSuggested,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (erpPlanId != null) 'erp_plan_id': erpPlanId,
      if (customerId != null) 'customer_id': customerId,
      if (product != null) 'product': product,
      if (startDate != null) 'start_date': startDate,
      if (finalDueDate != null) 'final_due_date': finalDueDate,
      if (installmentCount != null) 'installment_count': installmentCount,
      if (totalPayablePoisha != null)
        'total_payable_poisha': totalPayablePoisha,
      if (downPaymentPoisha != null) 'down_payment_poisha': downPaymentPoisha,
      if (paidPoisha != null) 'paid_poisha': paidPoisha,
      if (outstandingPoisha != null) 'outstanding_poisha': outstandingPoisha,
      if (status != null) 'status': status,
      if (badSuggested != null) 'bad_suggested': badSuggested,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlansCompanion copyWith({
    Value<String>? erpPlanId,
    Value<String>? customerId,
    Value<String>? product,
    Value<String>? startDate,
    Value<String>? finalDueDate,
    Value<int>? installmentCount,
    Value<int>? totalPayablePoisha,
    Value<int>? downPaymentPoisha,
    Value<int>? paidPoisha,
    Value<int>? outstandingPoisha,
    Value<String>? status,
    Value<bool>? badSuggested,
    Value<int>? rowid,
  }) {
    return PlansCompanion(
      erpPlanId: erpPlanId ?? this.erpPlanId,
      customerId: customerId ?? this.customerId,
      product: product ?? this.product,
      startDate: startDate ?? this.startDate,
      finalDueDate: finalDueDate ?? this.finalDueDate,
      installmentCount: installmentCount ?? this.installmentCount,
      totalPayablePoisha: totalPayablePoisha ?? this.totalPayablePoisha,
      downPaymentPoisha: downPaymentPoisha ?? this.downPaymentPoisha,
      paidPoisha: paidPoisha ?? this.paidPoisha,
      outstandingPoisha: outstandingPoisha ?? this.outstandingPoisha,
      status: status ?? this.status,
      badSuggested: badSuggested ?? this.badSuggested,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (erpPlanId.present) {
      map['erp_plan_id'] = Variable<String>(erpPlanId.value);
    }
    if (customerId.present) {
      map['customer_id'] = Variable<String>(customerId.value);
    }
    if (product.present) {
      map['product'] = Variable<String>(product.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<String>(startDate.value);
    }
    if (finalDueDate.present) {
      map['final_due_date'] = Variable<String>(finalDueDate.value);
    }
    if (installmentCount.present) {
      map['installment_count'] = Variable<int>(installmentCount.value);
    }
    if (totalPayablePoisha.present) {
      map['total_payable_poisha'] = Variable<int>(totalPayablePoisha.value);
    }
    if (downPaymentPoisha.present) {
      map['down_payment_poisha'] = Variable<int>(downPaymentPoisha.value);
    }
    if (paidPoisha.present) {
      map['paid_poisha'] = Variable<int>(paidPoisha.value);
    }
    if (outstandingPoisha.present) {
      map['outstanding_poisha'] = Variable<int>(outstandingPoisha.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (badSuggested.present) {
      map['bad_suggested'] = Variable<bool>(badSuggested.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlansCompanion(')
          ..write('erpPlanId: $erpPlanId, ')
          ..write('customerId: $customerId, ')
          ..write('product: $product, ')
          ..write('startDate: $startDate, ')
          ..write('finalDueDate: $finalDueDate, ')
          ..write('installmentCount: $installmentCount, ')
          ..write('totalPayablePoisha: $totalPayablePoisha, ')
          ..write('downPaymentPoisha: $downPaymentPoisha, ')
          ..write('paidPoisha: $paidPoisha, ')
          ..write('outstandingPoisha: $outstandingPoisha, ')
          ..write('status: $status, ')
          ..write('badSuggested: $badSuggested, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ScheduleLinesTable extends ScheduleLines
    with TableInfo<$ScheduleLinesTable, ScheduleLineRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ScheduleLinesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _erpPlanIdMeta = const VerificationMeta(
    'erpPlanId',
  );
  @override
  late final GeneratedColumn<String> erpPlanId = GeneratedColumn<String>(
    'erp_plan_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _seqMeta = const VerificationMeta('seq');
  @override
  late final GeneratedColumn<int> seq = GeneratedColumn<int>(
    'seq',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dueDateMeta = const VerificationMeta(
    'dueDate',
  );
  @override
  late final GeneratedColumn<String> dueDate = GeneratedColumn<String>(
    'due_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountPoishaMeta = const VerificationMeta(
    'amountPoisha',
  );
  @override
  late final GeneratedColumn<int> amountPoisha = GeneratedColumn<int>(
    'amount_poisha',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _paidPoishaMeta = const VerificationMeta(
    'paidPoisha',
  );
  @override
  late final GeneratedColumn<int> paidPoisha = GeneratedColumn<int>(
    'paid_poisha',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _estimatedMeta = const VerificationMeta(
    'estimated',
  );
  @override
  late final GeneratedColumn<bool> estimated = GeneratedColumn<bool>(
    'estimated',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("estimated" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    erpPlanId,
    seq,
    dueDate,
    amountPoisha,
    paidPoisha,
    status,
    estimated,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'schedule_lines';
  @override
  VerificationContext validateIntegrity(
    Insertable<ScheduleLineRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('erp_plan_id')) {
      context.handle(
        _erpPlanIdMeta,
        erpPlanId.isAcceptableOrUnknown(data['erp_plan_id']!, _erpPlanIdMeta),
      );
    } else if (isInserting) {
      context.missing(_erpPlanIdMeta);
    }
    if (data.containsKey('seq')) {
      context.handle(
        _seqMeta,
        seq.isAcceptableOrUnknown(data['seq']!, _seqMeta),
      );
    } else if (isInserting) {
      context.missing(_seqMeta);
    }
    if (data.containsKey('due_date')) {
      context.handle(
        _dueDateMeta,
        dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta),
      );
    } else if (isInserting) {
      context.missing(_dueDateMeta);
    }
    if (data.containsKey('amount_poisha')) {
      context.handle(
        _amountPoishaMeta,
        amountPoisha.isAcceptableOrUnknown(
          data['amount_poisha']!,
          _amountPoishaMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountPoishaMeta);
    }
    if (data.containsKey('paid_poisha')) {
      context.handle(
        _paidPoishaMeta,
        paidPoisha.isAcceptableOrUnknown(data['paid_poisha']!, _paidPoishaMeta),
      );
    } else if (isInserting) {
      context.missing(_paidPoishaMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('estimated')) {
      context.handle(
        _estimatedMeta,
        estimated.isAcceptableOrUnknown(data['estimated']!, _estimatedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {erpPlanId, seq};
  @override
  ScheduleLineRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ScheduleLineRow(
      erpPlanId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}erp_plan_id'],
      )!,
      seq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}seq'],
      )!,
      dueDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}due_date'],
      )!,
      amountPoisha: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_poisha'],
      )!,
      paidPoisha: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}paid_poisha'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      estimated: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}estimated'],
      )!,
    );
  }

  @override
  $ScheduleLinesTable createAlias(String alias) {
    return $ScheduleLinesTable(attachedDatabase, alias);
  }
}

class ScheduleLineRow extends DataClass implements Insertable<ScheduleLineRow> {
  final String erpPlanId;
  final int seq;
  final String dueDate;
  final int amountPoisha;
  final int paidPoisha;
  final String status;
  final bool estimated;
  const ScheduleLineRow({
    required this.erpPlanId,
    required this.seq,
    required this.dueDate,
    required this.amountPoisha,
    required this.paidPoisha,
    required this.status,
    required this.estimated,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['erp_plan_id'] = Variable<String>(erpPlanId);
    map['seq'] = Variable<int>(seq);
    map['due_date'] = Variable<String>(dueDate);
    map['amount_poisha'] = Variable<int>(amountPoisha);
    map['paid_poisha'] = Variable<int>(paidPoisha);
    map['status'] = Variable<String>(status);
    map['estimated'] = Variable<bool>(estimated);
    return map;
  }

  ScheduleLinesCompanion toCompanion(bool nullToAbsent) {
    return ScheduleLinesCompanion(
      erpPlanId: Value(erpPlanId),
      seq: Value(seq),
      dueDate: Value(dueDate),
      amountPoisha: Value(amountPoisha),
      paidPoisha: Value(paidPoisha),
      status: Value(status),
      estimated: Value(estimated),
    );
  }

  factory ScheduleLineRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ScheduleLineRow(
      erpPlanId: serializer.fromJson<String>(json['erpPlanId']),
      seq: serializer.fromJson<int>(json['seq']),
      dueDate: serializer.fromJson<String>(json['dueDate']),
      amountPoisha: serializer.fromJson<int>(json['amountPoisha']),
      paidPoisha: serializer.fromJson<int>(json['paidPoisha']),
      status: serializer.fromJson<String>(json['status']),
      estimated: serializer.fromJson<bool>(json['estimated']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'erpPlanId': serializer.toJson<String>(erpPlanId),
      'seq': serializer.toJson<int>(seq),
      'dueDate': serializer.toJson<String>(dueDate),
      'amountPoisha': serializer.toJson<int>(amountPoisha),
      'paidPoisha': serializer.toJson<int>(paidPoisha),
      'status': serializer.toJson<String>(status),
      'estimated': serializer.toJson<bool>(estimated),
    };
  }

  ScheduleLineRow copyWith({
    String? erpPlanId,
    int? seq,
    String? dueDate,
    int? amountPoisha,
    int? paidPoisha,
    String? status,
    bool? estimated,
  }) => ScheduleLineRow(
    erpPlanId: erpPlanId ?? this.erpPlanId,
    seq: seq ?? this.seq,
    dueDate: dueDate ?? this.dueDate,
    amountPoisha: amountPoisha ?? this.amountPoisha,
    paidPoisha: paidPoisha ?? this.paidPoisha,
    status: status ?? this.status,
    estimated: estimated ?? this.estimated,
  );
  ScheduleLineRow copyWithCompanion(ScheduleLinesCompanion data) {
    return ScheduleLineRow(
      erpPlanId: data.erpPlanId.present ? data.erpPlanId.value : this.erpPlanId,
      seq: data.seq.present ? data.seq.value : this.seq,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      amountPoisha: data.amountPoisha.present
          ? data.amountPoisha.value
          : this.amountPoisha,
      paidPoisha: data.paidPoisha.present
          ? data.paidPoisha.value
          : this.paidPoisha,
      status: data.status.present ? data.status.value : this.status,
      estimated: data.estimated.present ? data.estimated.value : this.estimated,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ScheduleLineRow(')
          ..write('erpPlanId: $erpPlanId, ')
          ..write('seq: $seq, ')
          ..write('dueDate: $dueDate, ')
          ..write('amountPoisha: $amountPoisha, ')
          ..write('paidPoisha: $paidPoisha, ')
          ..write('status: $status, ')
          ..write('estimated: $estimated')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    erpPlanId,
    seq,
    dueDate,
    amountPoisha,
    paidPoisha,
    status,
    estimated,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ScheduleLineRow &&
          other.erpPlanId == this.erpPlanId &&
          other.seq == this.seq &&
          other.dueDate == this.dueDate &&
          other.amountPoisha == this.amountPoisha &&
          other.paidPoisha == this.paidPoisha &&
          other.status == this.status &&
          other.estimated == this.estimated);
}

class ScheduleLinesCompanion extends UpdateCompanion<ScheduleLineRow> {
  final Value<String> erpPlanId;
  final Value<int> seq;
  final Value<String> dueDate;
  final Value<int> amountPoisha;
  final Value<int> paidPoisha;
  final Value<String> status;
  final Value<bool> estimated;
  final Value<int> rowid;
  const ScheduleLinesCompanion({
    this.erpPlanId = const Value.absent(),
    this.seq = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.amountPoisha = const Value.absent(),
    this.paidPoisha = const Value.absent(),
    this.status = const Value.absent(),
    this.estimated = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ScheduleLinesCompanion.insert({
    required String erpPlanId,
    required int seq,
    required String dueDate,
    required int amountPoisha,
    required int paidPoisha,
    required String status,
    this.estimated = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : erpPlanId = Value(erpPlanId),
       seq = Value(seq),
       dueDate = Value(dueDate),
       amountPoisha = Value(amountPoisha),
       paidPoisha = Value(paidPoisha),
       status = Value(status);
  static Insertable<ScheduleLineRow> custom({
    Expression<String>? erpPlanId,
    Expression<int>? seq,
    Expression<String>? dueDate,
    Expression<int>? amountPoisha,
    Expression<int>? paidPoisha,
    Expression<String>? status,
    Expression<bool>? estimated,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (erpPlanId != null) 'erp_plan_id': erpPlanId,
      if (seq != null) 'seq': seq,
      if (dueDate != null) 'due_date': dueDate,
      if (amountPoisha != null) 'amount_poisha': amountPoisha,
      if (paidPoisha != null) 'paid_poisha': paidPoisha,
      if (status != null) 'status': status,
      if (estimated != null) 'estimated': estimated,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ScheduleLinesCompanion copyWith({
    Value<String>? erpPlanId,
    Value<int>? seq,
    Value<String>? dueDate,
    Value<int>? amountPoisha,
    Value<int>? paidPoisha,
    Value<String>? status,
    Value<bool>? estimated,
    Value<int>? rowid,
  }) {
    return ScheduleLinesCompanion(
      erpPlanId: erpPlanId ?? this.erpPlanId,
      seq: seq ?? this.seq,
      dueDate: dueDate ?? this.dueDate,
      amountPoisha: amountPoisha ?? this.amountPoisha,
      paidPoisha: paidPoisha ?? this.paidPoisha,
      status: status ?? this.status,
      estimated: estimated ?? this.estimated,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (erpPlanId.present) {
      map['erp_plan_id'] = Variable<String>(erpPlanId.value);
    }
    if (seq.present) {
      map['seq'] = Variable<int>(seq.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<String>(dueDate.value);
    }
    if (amountPoisha.present) {
      map['amount_poisha'] = Variable<int>(amountPoisha.value);
    }
    if (paidPoisha.present) {
      map['paid_poisha'] = Variable<int>(paidPoisha.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (estimated.present) {
      map['estimated'] = Variable<bool>(estimated.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ScheduleLinesCompanion(')
          ..write('erpPlanId: $erpPlanId, ')
          ..write('seq: $seq, ')
          ..write('dueDate: $dueDate, ')
          ..write('amountPoisha: $amountPoisha, ')
          ..write('paidPoisha: $paidPoisha, ')
          ..write('status: $status, ')
          ..write('estimated: $estimated, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ErpPaymentsTable extends ErpPayments
    with TableInfo<$ErpPaymentsTable, ErpPaymentRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ErpPaymentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _erpPaymentIdMeta = const VerificationMeta(
    'erpPaymentId',
  );
  @override
  late final GeneratedColumn<String> erpPaymentId = GeneratedColumn<String>(
    'erp_payment_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _customerIdMeta = const VerificationMeta(
    'customerId',
  );
  @override
  late final GeneratedColumn<String> customerId = GeneratedColumn<String>(
    'customer_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _planIdMeta = const VerificationMeta('planId');
  @override
  late final GeneratedColumn<String> planId = GeneratedColumn<String>(
    'plan_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountPoishaMeta = const VerificationMeta(
    'amountPoisha',
  );
  @override
  late final GeneratedColumn<int> amountPoisha = GeneratedColumn<int>(
    'amount_poisha',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _methodMeta = const VerificationMeta('method');
  @override
  late final GeneratedColumn<String> method = GeneratedColumn<String>(
    'method',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _receiptNoMeta = const VerificationMeta(
    'receiptNo',
  );
  @override
  late final GeneratedColumn<String> receiptNo = GeneratedColumn<String>(
    'receipt_no',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reversedMeta = const VerificationMeta(
    'reversed',
  );
  @override
  late final GeneratedColumn<bool> reversed = GeneratedColumn<bool>(
    'reversed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("reversed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    erpPaymentId,
    customerId,
    planId,
    date,
    amountPoisha,
    method,
    source,
    receiptNo,
    reversed,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'erp_payments';
  @override
  VerificationContext validateIntegrity(
    Insertable<ErpPaymentRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('erp_payment_id')) {
      context.handle(
        _erpPaymentIdMeta,
        erpPaymentId.isAcceptableOrUnknown(
          data['erp_payment_id']!,
          _erpPaymentIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_erpPaymentIdMeta);
    }
    if (data.containsKey('customer_id')) {
      context.handle(
        _customerIdMeta,
        customerId.isAcceptableOrUnknown(data['customer_id']!, _customerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_customerIdMeta);
    }
    if (data.containsKey('plan_id')) {
      context.handle(
        _planIdMeta,
        planId.isAcceptableOrUnknown(data['plan_id']!, _planIdMeta),
      );
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('amount_poisha')) {
      context.handle(
        _amountPoishaMeta,
        amountPoisha.isAcceptableOrUnknown(
          data['amount_poisha']!,
          _amountPoishaMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountPoishaMeta);
    }
    if (data.containsKey('method')) {
      context.handle(
        _methodMeta,
        method.isAcceptableOrUnknown(data['method']!, _methodMeta),
      );
    } else if (isInserting) {
      context.missing(_methodMeta);
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('receipt_no')) {
      context.handle(
        _receiptNoMeta,
        receiptNo.isAcceptableOrUnknown(data['receipt_no']!, _receiptNoMeta),
      );
    }
    if (data.containsKey('reversed')) {
      context.handle(
        _reversedMeta,
        reversed.isAcceptableOrUnknown(data['reversed']!, _reversedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {erpPaymentId};
  @override
  ErpPaymentRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ErpPaymentRow(
      erpPaymentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}erp_payment_id'],
      )!,
      customerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}customer_id'],
      )!,
      planId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}plan_id'],
      ),
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      )!,
      amountPoisha: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_poisha'],
      )!,
      method: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}method'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      receiptNo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}receipt_no'],
      ),
      reversed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}reversed'],
      )!,
    );
  }

  @override
  $ErpPaymentsTable createAlias(String alias) {
    return $ErpPaymentsTable(attachedDatabase, alias);
  }
}

class ErpPaymentRow extends DataClass implements Insertable<ErpPaymentRow> {
  final String erpPaymentId;
  final String customerId;
  final String? planId;
  final String date;
  final int amountPoisha;
  final String method;
  final String source;
  final String? receiptNo;
  final bool reversed;
  const ErpPaymentRow({
    required this.erpPaymentId,
    required this.customerId,
    this.planId,
    required this.date,
    required this.amountPoisha,
    required this.method,
    required this.source,
    this.receiptNo,
    required this.reversed,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['erp_payment_id'] = Variable<String>(erpPaymentId);
    map['customer_id'] = Variable<String>(customerId);
    if (!nullToAbsent || planId != null) {
      map['plan_id'] = Variable<String>(planId);
    }
    map['date'] = Variable<String>(date);
    map['amount_poisha'] = Variable<int>(amountPoisha);
    map['method'] = Variable<String>(method);
    map['source'] = Variable<String>(source);
    if (!nullToAbsent || receiptNo != null) {
      map['receipt_no'] = Variable<String>(receiptNo);
    }
    map['reversed'] = Variable<bool>(reversed);
    return map;
  }

  ErpPaymentsCompanion toCompanion(bool nullToAbsent) {
    return ErpPaymentsCompanion(
      erpPaymentId: Value(erpPaymentId),
      customerId: Value(customerId),
      planId: planId == null && nullToAbsent
          ? const Value.absent()
          : Value(planId),
      date: Value(date),
      amountPoisha: Value(amountPoisha),
      method: Value(method),
      source: Value(source),
      receiptNo: receiptNo == null && nullToAbsent
          ? const Value.absent()
          : Value(receiptNo),
      reversed: Value(reversed),
    );
  }

  factory ErpPaymentRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ErpPaymentRow(
      erpPaymentId: serializer.fromJson<String>(json['erpPaymentId']),
      customerId: serializer.fromJson<String>(json['customerId']),
      planId: serializer.fromJson<String?>(json['planId']),
      date: serializer.fromJson<String>(json['date']),
      amountPoisha: serializer.fromJson<int>(json['amountPoisha']),
      method: serializer.fromJson<String>(json['method']),
      source: serializer.fromJson<String>(json['source']),
      receiptNo: serializer.fromJson<String?>(json['receiptNo']),
      reversed: serializer.fromJson<bool>(json['reversed']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'erpPaymentId': serializer.toJson<String>(erpPaymentId),
      'customerId': serializer.toJson<String>(customerId),
      'planId': serializer.toJson<String?>(planId),
      'date': serializer.toJson<String>(date),
      'amountPoisha': serializer.toJson<int>(amountPoisha),
      'method': serializer.toJson<String>(method),
      'source': serializer.toJson<String>(source),
      'receiptNo': serializer.toJson<String?>(receiptNo),
      'reversed': serializer.toJson<bool>(reversed),
    };
  }

  ErpPaymentRow copyWith({
    String? erpPaymentId,
    String? customerId,
    Value<String?> planId = const Value.absent(),
    String? date,
    int? amountPoisha,
    String? method,
    String? source,
    Value<String?> receiptNo = const Value.absent(),
    bool? reversed,
  }) => ErpPaymentRow(
    erpPaymentId: erpPaymentId ?? this.erpPaymentId,
    customerId: customerId ?? this.customerId,
    planId: planId.present ? planId.value : this.planId,
    date: date ?? this.date,
    amountPoisha: amountPoisha ?? this.amountPoisha,
    method: method ?? this.method,
    source: source ?? this.source,
    receiptNo: receiptNo.present ? receiptNo.value : this.receiptNo,
    reversed: reversed ?? this.reversed,
  );
  ErpPaymentRow copyWithCompanion(ErpPaymentsCompanion data) {
    return ErpPaymentRow(
      erpPaymentId: data.erpPaymentId.present
          ? data.erpPaymentId.value
          : this.erpPaymentId,
      customerId: data.customerId.present
          ? data.customerId.value
          : this.customerId,
      planId: data.planId.present ? data.planId.value : this.planId,
      date: data.date.present ? data.date.value : this.date,
      amountPoisha: data.amountPoisha.present
          ? data.amountPoisha.value
          : this.amountPoisha,
      method: data.method.present ? data.method.value : this.method,
      source: data.source.present ? data.source.value : this.source,
      receiptNo: data.receiptNo.present ? data.receiptNo.value : this.receiptNo,
      reversed: data.reversed.present ? data.reversed.value : this.reversed,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ErpPaymentRow(')
          ..write('erpPaymentId: $erpPaymentId, ')
          ..write('customerId: $customerId, ')
          ..write('planId: $planId, ')
          ..write('date: $date, ')
          ..write('amountPoisha: $amountPoisha, ')
          ..write('method: $method, ')
          ..write('source: $source, ')
          ..write('receiptNo: $receiptNo, ')
          ..write('reversed: $reversed')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    erpPaymentId,
    customerId,
    planId,
    date,
    amountPoisha,
    method,
    source,
    receiptNo,
    reversed,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ErpPaymentRow &&
          other.erpPaymentId == this.erpPaymentId &&
          other.customerId == this.customerId &&
          other.planId == this.planId &&
          other.date == this.date &&
          other.amountPoisha == this.amountPoisha &&
          other.method == this.method &&
          other.source == this.source &&
          other.receiptNo == this.receiptNo &&
          other.reversed == this.reversed);
}

class ErpPaymentsCompanion extends UpdateCompanion<ErpPaymentRow> {
  final Value<String> erpPaymentId;
  final Value<String> customerId;
  final Value<String?> planId;
  final Value<String> date;
  final Value<int> amountPoisha;
  final Value<String> method;
  final Value<String> source;
  final Value<String?> receiptNo;
  final Value<bool> reversed;
  final Value<int> rowid;
  const ErpPaymentsCompanion({
    this.erpPaymentId = const Value.absent(),
    this.customerId = const Value.absent(),
    this.planId = const Value.absent(),
    this.date = const Value.absent(),
    this.amountPoisha = const Value.absent(),
    this.method = const Value.absent(),
    this.source = const Value.absent(),
    this.receiptNo = const Value.absent(),
    this.reversed = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ErpPaymentsCompanion.insert({
    required String erpPaymentId,
    required String customerId,
    this.planId = const Value.absent(),
    required String date,
    required int amountPoisha,
    required String method,
    required String source,
    this.receiptNo = const Value.absent(),
    this.reversed = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : erpPaymentId = Value(erpPaymentId),
       customerId = Value(customerId),
       date = Value(date),
       amountPoisha = Value(amountPoisha),
       method = Value(method),
       source = Value(source);
  static Insertable<ErpPaymentRow> custom({
    Expression<String>? erpPaymentId,
    Expression<String>? customerId,
    Expression<String>? planId,
    Expression<String>? date,
    Expression<int>? amountPoisha,
    Expression<String>? method,
    Expression<String>? source,
    Expression<String>? receiptNo,
    Expression<bool>? reversed,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (erpPaymentId != null) 'erp_payment_id': erpPaymentId,
      if (customerId != null) 'customer_id': customerId,
      if (planId != null) 'plan_id': planId,
      if (date != null) 'date': date,
      if (amountPoisha != null) 'amount_poisha': amountPoisha,
      if (method != null) 'method': method,
      if (source != null) 'source': source,
      if (receiptNo != null) 'receipt_no': receiptNo,
      if (reversed != null) 'reversed': reversed,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ErpPaymentsCompanion copyWith({
    Value<String>? erpPaymentId,
    Value<String>? customerId,
    Value<String?>? planId,
    Value<String>? date,
    Value<int>? amountPoisha,
    Value<String>? method,
    Value<String>? source,
    Value<String?>? receiptNo,
    Value<bool>? reversed,
    Value<int>? rowid,
  }) {
    return ErpPaymentsCompanion(
      erpPaymentId: erpPaymentId ?? this.erpPaymentId,
      customerId: customerId ?? this.customerId,
      planId: planId ?? this.planId,
      date: date ?? this.date,
      amountPoisha: amountPoisha ?? this.amountPoisha,
      method: method ?? this.method,
      source: source ?? this.source,
      receiptNo: receiptNo ?? this.receiptNo,
      reversed: reversed ?? this.reversed,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (erpPaymentId.present) {
      map['erp_payment_id'] = Variable<String>(erpPaymentId.value);
    }
    if (customerId.present) {
      map['customer_id'] = Variable<String>(customerId.value);
    }
    if (planId.present) {
      map['plan_id'] = Variable<String>(planId.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (amountPoisha.present) {
      map['amount_poisha'] = Variable<int>(amountPoisha.value);
    }
    if (method.present) {
      map['method'] = Variable<String>(method.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (receiptNo.present) {
      map['receipt_no'] = Variable<String>(receiptNo.value);
    }
    if (reversed.present) {
      map['reversed'] = Variable<bool>(reversed.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ErpPaymentsCompanion(')
          ..write('erpPaymentId: $erpPaymentId, ')
          ..write('customerId: $customerId, ')
          ..write('planId: $planId, ')
          ..write('date: $date, ')
          ..write('amountPoisha: $amountPoisha, ')
          ..write('method: $method, ')
          ..write('source: $source, ')
          ..write('receiptNo: $receiptNo, ')
          ..write('reversed: $reversed, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocationProposalsTable extends LocationProposals
    with TableInfo<$LocationProposalsTable, LocationProposalRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocationProposalsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _clientIdMeta = const VerificationMeta(
    'clientId',
  );
  @override
  late final GeneratedColumn<String> clientId = GeneratedColumn<String>(
    'client_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _customerIdMeta = const VerificationMeta(
    'customerId',
  );
  @override
  late final GeneratedColumn<String> customerId = GeneratedColumn<String>(
    'customer_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _latMeta = const VerificationMeta('lat');
  @override
  late final GeneratedColumn<double> lat = GeneratedColumn<double>(
    'lat',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lngMeta = const VerificationMeta('lng');
  @override
  late final GeneratedColumn<double> lng = GeneratedColumn<double>(
    'lng',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accuracyMMeta = const VerificationMeta(
    'accuracyM',
  );
  @override
  late final GeneratedColumn<double> accuracyM = GeneratedColumn<double>(
    'accuracy_m',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _photoMediaClientIdMeta =
      const VerificationMeta('photoMediaClientId');
  @override
  late final GeneratedColumn<String> photoMediaClientId =
      GeneratedColumn<String>(
        'photo_media_client_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _syncStateMeta = const VerificationMeta(
    'syncState',
  );
  @override
  late final GeneratedColumn<String> syncState = GeneratedColumn<String>(
    'sync_state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('queued'),
  );
  static const VerificationMeta _decisionReasonMeta = const VerificationMeta(
    'decisionReason',
  );
  @override
  late final GeneratedColumn<String> decisionReason = GeneratedColumn<String>(
    'decision_reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _methodMeta = const VerificationMeta('method');
  @override
  late final GeneratedColumn<String> method = GeneratedColumn<String>(
    'method',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('gps'),
  );
  static const VerificationMeta _deviceGeoJsonMeta = const VerificationMeta(
    'deviceGeoJson',
  );
  @override
  late final GeneratedColumn<String> deviceGeoJson = GeneratedColumn<String>(
    'device_geo_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    clientId,
    customerId,
    lat,
    lng,
    accuracyM,
    photoMediaClientId,
    note,
    status,
    syncState,
    decisionReason,
    method,
    deviceGeoJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'location_proposals';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocationProposalRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('client_id')) {
      context.handle(
        _clientIdMeta,
        clientId.isAcceptableOrUnknown(data['client_id']!, _clientIdMeta),
      );
    } else if (isInserting) {
      context.missing(_clientIdMeta);
    }
    if (data.containsKey('customer_id')) {
      context.handle(
        _customerIdMeta,
        customerId.isAcceptableOrUnknown(data['customer_id']!, _customerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_customerIdMeta);
    }
    if (data.containsKey('lat')) {
      context.handle(
        _latMeta,
        lat.isAcceptableOrUnknown(data['lat']!, _latMeta),
      );
    } else if (isInserting) {
      context.missing(_latMeta);
    }
    if (data.containsKey('lng')) {
      context.handle(
        _lngMeta,
        lng.isAcceptableOrUnknown(data['lng']!, _lngMeta),
      );
    } else if (isInserting) {
      context.missing(_lngMeta);
    }
    if (data.containsKey('accuracy_m')) {
      context.handle(
        _accuracyMMeta,
        accuracyM.isAcceptableOrUnknown(data['accuracy_m']!, _accuracyMMeta),
      );
    } else if (isInserting) {
      context.missing(_accuracyMMeta);
    }
    if (data.containsKey('photo_media_client_id')) {
      context.handle(
        _photoMediaClientIdMeta,
        photoMediaClientId.isAcceptableOrUnknown(
          data['photo_media_client_id']!,
          _photoMediaClientIdMeta,
        ),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('sync_state')) {
      context.handle(
        _syncStateMeta,
        syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta),
      );
    }
    if (data.containsKey('decision_reason')) {
      context.handle(
        _decisionReasonMeta,
        decisionReason.isAcceptableOrUnknown(
          data['decision_reason']!,
          _decisionReasonMeta,
        ),
      );
    }
    if (data.containsKey('method')) {
      context.handle(
        _methodMeta,
        method.isAcceptableOrUnknown(data['method']!, _methodMeta),
      );
    }
    if (data.containsKey('device_geo_json')) {
      context.handle(
        _deviceGeoJsonMeta,
        deviceGeoJson.isAcceptableOrUnknown(
          data['device_geo_json']!,
          _deviceGeoJsonMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {clientId};
  @override
  LocationProposalRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocationProposalRow(
      clientId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}client_id'],
      )!,
      customerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}customer_id'],
      )!,
      lat: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}lat'],
      )!,
      lng: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}lng'],
      )!,
      accuracyM: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}accuracy_m'],
      )!,
      photoMediaClientId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}photo_media_client_id'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      syncState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_state'],
      )!,
      decisionReason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}decision_reason'],
      ),
      method: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}method'],
      )!,
      deviceGeoJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_geo_json'],
      ),
    );
  }

  @override
  $LocationProposalsTable createAlias(String alias) {
    return $LocationProposalsTable(attachedDatabase, alias);
  }
}

class LocationProposalRow extends DataClass
    implements Insertable<LocationProposalRow> {
  final String clientId;
  final String customerId;
  final double lat;
  final double lng;
  final double accuracyM;
  final String? photoMediaClientId;
  final String? note;
  final String status;
  final String syncState;

  /// Manager's reason when rejected (v3, contract 1.7.0).
  final String? decisionReason;

  /// v5 (contract 1.11.0): `gps` (the phone's own fix, before 0.8.0) or
  /// `map` (the point under the pin on the map; [accuracyM] is then 0).
  final String method;

  /// v5: where the phone was when a `map` pin was picked (GeoFix JSON),
  /// sent as `deviceGeo` so the manager sees how far away the staff was.
  final String? deviceGeoJson;
  const LocationProposalRow({
    required this.clientId,
    required this.customerId,
    required this.lat,
    required this.lng,
    required this.accuracyM,
    this.photoMediaClientId,
    this.note,
    required this.status,
    required this.syncState,
    this.decisionReason,
    required this.method,
    this.deviceGeoJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['client_id'] = Variable<String>(clientId);
    map['customer_id'] = Variable<String>(customerId);
    map['lat'] = Variable<double>(lat);
    map['lng'] = Variable<double>(lng);
    map['accuracy_m'] = Variable<double>(accuracyM);
    if (!nullToAbsent || photoMediaClientId != null) {
      map['photo_media_client_id'] = Variable<String>(photoMediaClientId);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['status'] = Variable<String>(status);
    map['sync_state'] = Variable<String>(syncState);
    if (!nullToAbsent || decisionReason != null) {
      map['decision_reason'] = Variable<String>(decisionReason);
    }
    map['method'] = Variable<String>(method);
    if (!nullToAbsent || deviceGeoJson != null) {
      map['device_geo_json'] = Variable<String>(deviceGeoJson);
    }
    return map;
  }

  LocationProposalsCompanion toCompanion(bool nullToAbsent) {
    return LocationProposalsCompanion(
      clientId: Value(clientId),
      customerId: Value(customerId),
      lat: Value(lat),
      lng: Value(lng),
      accuracyM: Value(accuracyM),
      photoMediaClientId: photoMediaClientId == null && nullToAbsent
          ? const Value.absent()
          : Value(photoMediaClientId),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      status: Value(status),
      syncState: Value(syncState),
      decisionReason: decisionReason == null && nullToAbsent
          ? const Value.absent()
          : Value(decisionReason),
      method: Value(method),
      deviceGeoJson: deviceGeoJson == null && nullToAbsent
          ? const Value.absent()
          : Value(deviceGeoJson),
    );
  }

  factory LocationProposalRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocationProposalRow(
      clientId: serializer.fromJson<String>(json['clientId']),
      customerId: serializer.fromJson<String>(json['customerId']),
      lat: serializer.fromJson<double>(json['lat']),
      lng: serializer.fromJson<double>(json['lng']),
      accuracyM: serializer.fromJson<double>(json['accuracyM']),
      photoMediaClientId: serializer.fromJson<String?>(
        json['photoMediaClientId'],
      ),
      note: serializer.fromJson<String?>(json['note']),
      status: serializer.fromJson<String>(json['status']),
      syncState: serializer.fromJson<String>(json['syncState']),
      decisionReason: serializer.fromJson<String?>(json['decisionReason']),
      method: serializer.fromJson<String>(json['method']),
      deviceGeoJson: serializer.fromJson<String?>(json['deviceGeoJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'clientId': serializer.toJson<String>(clientId),
      'customerId': serializer.toJson<String>(customerId),
      'lat': serializer.toJson<double>(lat),
      'lng': serializer.toJson<double>(lng),
      'accuracyM': serializer.toJson<double>(accuracyM),
      'photoMediaClientId': serializer.toJson<String?>(photoMediaClientId),
      'note': serializer.toJson<String?>(note),
      'status': serializer.toJson<String>(status),
      'syncState': serializer.toJson<String>(syncState),
      'decisionReason': serializer.toJson<String?>(decisionReason),
      'method': serializer.toJson<String>(method),
      'deviceGeoJson': serializer.toJson<String?>(deviceGeoJson),
    };
  }

  LocationProposalRow copyWith({
    String? clientId,
    String? customerId,
    double? lat,
    double? lng,
    double? accuracyM,
    Value<String?> photoMediaClientId = const Value.absent(),
    Value<String?> note = const Value.absent(),
    String? status,
    String? syncState,
    Value<String?> decisionReason = const Value.absent(),
    String? method,
    Value<String?> deviceGeoJson = const Value.absent(),
  }) => LocationProposalRow(
    clientId: clientId ?? this.clientId,
    customerId: customerId ?? this.customerId,
    lat: lat ?? this.lat,
    lng: lng ?? this.lng,
    accuracyM: accuracyM ?? this.accuracyM,
    photoMediaClientId: photoMediaClientId.present
        ? photoMediaClientId.value
        : this.photoMediaClientId,
    note: note.present ? note.value : this.note,
    status: status ?? this.status,
    syncState: syncState ?? this.syncState,
    decisionReason: decisionReason.present
        ? decisionReason.value
        : this.decisionReason,
    method: method ?? this.method,
    deviceGeoJson: deviceGeoJson.present
        ? deviceGeoJson.value
        : this.deviceGeoJson,
  );
  LocationProposalRow copyWithCompanion(LocationProposalsCompanion data) {
    return LocationProposalRow(
      clientId: data.clientId.present ? data.clientId.value : this.clientId,
      customerId: data.customerId.present
          ? data.customerId.value
          : this.customerId,
      lat: data.lat.present ? data.lat.value : this.lat,
      lng: data.lng.present ? data.lng.value : this.lng,
      accuracyM: data.accuracyM.present ? data.accuracyM.value : this.accuracyM,
      photoMediaClientId: data.photoMediaClientId.present
          ? data.photoMediaClientId.value
          : this.photoMediaClientId,
      note: data.note.present ? data.note.value : this.note,
      status: data.status.present ? data.status.value : this.status,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
      decisionReason: data.decisionReason.present
          ? data.decisionReason.value
          : this.decisionReason,
      method: data.method.present ? data.method.value : this.method,
      deviceGeoJson: data.deviceGeoJson.present
          ? data.deviceGeoJson.value
          : this.deviceGeoJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocationProposalRow(')
          ..write('clientId: $clientId, ')
          ..write('customerId: $customerId, ')
          ..write('lat: $lat, ')
          ..write('lng: $lng, ')
          ..write('accuracyM: $accuracyM, ')
          ..write('photoMediaClientId: $photoMediaClientId, ')
          ..write('note: $note, ')
          ..write('status: $status, ')
          ..write('syncState: $syncState, ')
          ..write('decisionReason: $decisionReason, ')
          ..write('method: $method, ')
          ..write('deviceGeoJson: $deviceGeoJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    clientId,
    customerId,
    lat,
    lng,
    accuracyM,
    photoMediaClientId,
    note,
    status,
    syncState,
    decisionReason,
    method,
    deviceGeoJson,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocationProposalRow &&
          other.clientId == this.clientId &&
          other.customerId == this.customerId &&
          other.lat == this.lat &&
          other.lng == this.lng &&
          other.accuracyM == this.accuracyM &&
          other.photoMediaClientId == this.photoMediaClientId &&
          other.note == this.note &&
          other.status == this.status &&
          other.syncState == this.syncState &&
          other.decisionReason == this.decisionReason &&
          other.method == this.method &&
          other.deviceGeoJson == this.deviceGeoJson);
}

class LocationProposalsCompanion extends UpdateCompanion<LocationProposalRow> {
  final Value<String> clientId;
  final Value<String> customerId;
  final Value<double> lat;
  final Value<double> lng;
  final Value<double> accuracyM;
  final Value<String?> photoMediaClientId;
  final Value<String?> note;
  final Value<String> status;
  final Value<String> syncState;
  final Value<String?> decisionReason;
  final Value<String> method;
  final Value<String?> deviceGeoJson;
  final Value<int> rowid;
  const LocationProposalsCompanion({
    this.clientId = const Value.absent(),
    this.customerId = const Value.absent(),
    this.lat = const Value.absent(),
    this.lng = const Value.absent(),
    this.accuracyM = const Value.absent(),
    this.photoMediaClientId = const Value.absent(),
    this.note = const Value.absent(),
    this.status = const Value.absent(),
    this.syncState = const Value.absent(),
    this.decisionReason = const Value.absent(),
    this.method = const Value.absent(),
    this.deviceGeoJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocationProposalsCompanion.insert({
    required String clientId,
    required String customerId,
    required double lat,
    required double lng,
    required double accuracyM,
    this.photoMediaClientId = const Value.absent(),
    this.note = const Value.absent(),
    this.status = const Value.absent(),
    this.syncState = const Value.absent(),
    this.decisionReason = const Value.absent(),
    this.method = const Value.absent(),
    this.deviceGeoJson = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : clientId = Value(clientId),
       customerId = Value(customerId),
       lat = Value(lat),
       lng = Value(lng),
       accuracyM = Value(accuracyM);
  static Insertable<LocationProposalRow> custom({
    Expression<String>? clientId,
    Expression<String>? customerId,
    Expression<double>? lat,
    Expression<double>? lng,
    Expression<double>? accuracyM,
    Expression<String>? photoMediaClientId,
    Expression<String>? note,
    Expression<String>? status,
    Expression<String>? syncState,
    Expression<String>? decisionReason,
    Expression<String>? method,
    Expression<String>? deviceGeoJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (clientId != null) 'client_id': clientId,
      if (customerId != null) 'customer_id': customerId,
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
      if (accuracyM != null) 'accuracy_m': accuracyM,
      if (photoMediaClientId != null)
        'photo_media_client_id': photoMediaClientId,
      if (note != null) 'note': note,
      if (status != null) 'status': status,
      if (syncState != null) 'sync_state': syncState,
      if (decisionReason != null) 'decision_reason': decisionReason,
      if (method != null) 'method': method,
      if (deviceGeoJson != null) 'device_geo_json': deviceGeoJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocationProposalsCompanion copyWith({
    Value<String>? clientId,
    Value<String>? customerId,
    Value<double>? lat,
    Value<double>? lng,
    Value<double>? accuracyM,
    Value<String?>? photoMediaClientId,
    Value<String?>? note,
    Value<String>? status,
    Value<String>? syncState,
    Value<String?>? decisionReason,
    Value<String>? method,
    Value<String?>? deviceGeoJson,
    Value<int>? rowid,
  }) {
    return LocationProposalsCompanion(
      clientId: clientId ?? this.clientId,
      customerId: customerId ?? this.customerId,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      accuracyM: accuracyM ?? this.accuracyM,
      photoMediaClientId: photoMediaClientId ?? this.photoMediaClientId,
      note: note ?? this.note,
      status: status ?? this.status,
      syncState: syncState ?? this.syncState,
      decisionReason: decisionReason ?? this.decisionReason,
      method: method ?? this.method,
      deviceGeoJson: deviceGeoJson ?? this.deviceGeoJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (clientId.present) {
      map['client_id'] = Variable<String>(clientId.value);
    }
    if (customerId.present) {
      map['customer_id'] = Variable<String>(customerId.value);
    }
    if (lat.present) {
      map['lat'] = Variable<double>(lat.value);
    }
    if (lng.present) {
      map['lng'] = Variable<double>(lng.value);
    }
    if (accuracyM.present) {
      map['accuracy_m'] = Variable<double>(accuracyM.value);
    }
    if (photoMediaClientId.present) {
      map['photo_media_client_id'] = Variable<String>(photoMediaClientId.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(syncState.value);
    }
    if (decisionReason.present) {
      map['decision_reason'] = Variable<String>(decisionReason.value);
    }
    if (method.present) {
      map['method'] = Variable<String>(method.value);
    }
    if (deviceGeoJson.present) {
      map['device_geo_json'] = Variable<String>(deviceGeoJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocationProposalsCompanion(')
          ..write('clientId: $clientId, ')
          ..write('customerId: $customerId, ')
          ..write('lat: $lat, ')
          ..write('lng: $lng, ')
          ..write('accuracyM: $accuracyM, ')
          ..write('photoMediaClientId: $photoMediaClientId, ')
          ..write('note: $note, ')
          ..write('status: $status, ')
          ..write('syncState: $syncState, ')
          ..write('decisionReason: $decisionReason, ')
          ..write('method: $method, ')
          ..write('deviceGeoJson: $deviceGeoJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CollectionsTable extends Collections
    with TableInfo<$CollectionsTable, CollectionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CollectionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _clientIdMeta = const VerificationMeta(
    'clientId',
  );
  @override
  late final GeneratedColumn<String> clientId = GeneratedColumn<String>(
    'client_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _serverIdMeta = const VerificationMeta(
    'serverId',
  );
  @override
  late final GeneratedColumn<String> serverId = GeneratedColumn<String>(
    'server_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _customerIdMeta = const VerificationMeta(
    'customerId',
  );
  @override
  late final GeneratedColumn<String> customerId = GeneratedColumn<String>(
    'customer_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _customerNameMeta = const VerificationMeta(
    'customerName',
  );
  @override
  late final GeneratedColumn<String> customerName = GeneratedColumn<String>(
    'customer_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _customerCodeMeta = const VerificationMeta(
    'customerCode',
  );
  @override
  late final GeneratedColumn<String> customerCode = GeneratedColumn<String>(
    'customer_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _erpPlanIdMeta = const VerificationMeta(
    'erpPlanId',
  );
  @override
  late final GeneratedColumn<String> erpPlanId = GeneratedColumn<String>(
    'erp_plan_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _amountPoishaMeta = const VerificationMeta(
    'amountPoisha',
  );
  @override
  late final GeneratedColumn<int> amountPoisha = GeneratedColumn<int>(
    'amount_poisha',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _methodMeta = const VerificationMeta('method');
  @override
  late final GeneratedColumn<String> method = GeneratedColumn<String>(
    'method',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _transactionRefMeta = const VerificationMeta(
    'transactionRef',
  );
  @override
  late final GeneratedColumn<String> transactionRef = GeneratedColumn<String>(
    'transaction_ref',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _receiptNoMeta = const VerificationMeta(
    'receiptNo',
  );
  @override
  late final GeneratedColumn<String> receiptNo = GeneratedColumn<String>(
    'receipt_no',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _physicalReceiptNoMeta = const VerificationMeta(
    'physicalReceiptNo',
  );
  @override
  late final GeneratedColumn<String> physicalReceiptNo =
      GeneratedColumn<String>(
        'physical_receipt_no',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _payerNameMeta = const VerificationMeta(
    'payerName',
  );
  @override
  late final GeneratedColumn<String> payerName = GeneratedColumn<String>(
    'payer_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _recordedAtMeta = const VerificationMeta(
    'recordedAt',
  );
  @override
  late final GeneratedColumn<DateTime> recordedAt = GeneratedColumn<DateTime>(
    'recorded_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deviceTimeMeta = const VerificationMeta(
    'deviceTime',
  );
  @override
  late final GeneratedColumn<DateTime> deviceTime = GeneratedColumn<DateTime>(
    'device_time',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _businessDateMeta = const VerificationMeta(
    'businessDate',
  );
  @override
  late final GeneratedColumn<String> businessDate = GeneratedColumn<String>(
    'business_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _latMeta = const VerificationMeta('lat');
  @override
  late final GeneratedColumn<double> lat = GeneratedColumn<double>(
    'lat',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lngMeta = const VerificationMeta('lng');
  @override
  late final GeneratedColumn<double> lng = GeneratedColumn<double>(
    'lng',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _accuracyMMeta = const VerificationMeta(
    'accuracyM',
  );
  @override
  late final GeneratedColumn<double> accuracyM = GeneratedColumn<double>(
    'accuracy_m',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _mockMeta = const VerificationMeta('mock');
  @override
  late final GeneratedColumn<bool> mock = GeneratedColumn<bool>(
    'mock',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("mock" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _visitClientIdMeta = const VerificationMeta(
    'visitClientId',
  );
  @override
  late final GeneratedColumn<String> visitClientId = GeneratedColumn<String>(
    'visit_client_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _photoMediaClientIdMeta =
      const VerificationMeta('photoMediaClientId');
  @override
  late final GeneratedColumn<String> photoMediaClientId =
      GeneratedColumn<String>(
        'photo_media_client_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('queued'),
  );
  static const VerificationMeta _erpReceiptNoMeta = const VerificationMeta(
    'erpReceiptNo',
  );
  @override
  late final GeneratedColumn<String> erpReceiptNo = GeneratedColumn<String>(
    'erp_receipt_no',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _conflictCodeMeta = const VerificationMeta(
    'conflictCode',
  );
  @override
  late final GeneratedColumn<String> conflictCode = GeneratedColumn<String>(
    'conflict_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _conflictMessageMeta = const VerificationMeta(
    'conflictMessage',
  );
  @override
  late final GeneratedColumn<String> conflictMessage = GeneratedColumn<String>(
    'conflict_message',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _resolutionTextMeta = const VerificationMeta(
    'resolutionText',
  );
  @override
  late final GeneratedColumn<String> resolutionText = GeneratedColumn<String>(
    'resolution_text',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _flagsJsonMeta = const VerificationMeta(
    'flagsJson',
  );
  @override
  late final GeneratedColumn<String> flagsJson = GeneratedColumn<String>(
    'flags_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _syncStateMeta = const VerificationMeta(
    'syncState',
  );
  @override
  late final GeneratedColumn<String> syncState = GeneratedColumn<String>(
    'sync_state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('queued'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    clientId,
    serverId,
    customerId,
    customerName,
    customerCode,
    erpPlanId,
    amountPoisha,
    method,
    transactionRef,
    receiptNo,
    physicalReceiptNo,
    payerName,
    note,
    recordedAt,
    deviceTime,
    businessDate,
    lat,
    lng,
    accuracyM,
    mock,
    visitClientId,
    photoMediaClientId,
    status,
    erpReceiptNo,
    conflictCode,
    conflictMessage,
    resolutionText,
    flagsJson,
    syncState,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'collections';
  @override
  VerificationContext validateIntegrity(
    Insertable<CollectionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('client_id')) {
      context.handle(
        _clientIdMeta,
        clientId.isAcceptableOrUnknown(data['client_id']!, _clientIdMeta),
      );
    } else if (isInserting) {
      context.missing(_clientIdMeta);
    }
    if (data.containsKey('server_id')) {
      context.handle(
        _serverIdMeta,
        serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta),
      );
    }
    if (data.containsKey('customer_id')) {
      context.handle(
        _customerIdMeta,
        customerId.isAcceptableOrUnknown(data['customer_id']!, _customerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_customerIdMeta);
    }
    if (data.containsKey('customer_name')) {
      context.handle(
        _customerNameMeta,
        customerName.isAcceptableOrUnknown(
          data['customer_name']!,
          _customerNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_customerNameMeta);
    }
    if (data.containsKey('customer_code')) {
      context.handle(
        _customerCodeMeta,
        customerCode.isAcceptableOrUnknown(
          data['customer_code']!,
          _customerCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_customerCodeMeta);
    }
    if (data.containsKey('erp_plan_id')) {
      context.handle(
        _erpPlanIdMeta,
        erpPlanId.isAcceptableOrUnknown(data['erp_plan_id']!, _erpPlanIdMeta),
      );
    }
    if (data.containsKey('amount_poisha')) {
      context.handle(
        _amountPoishaMeta,
        amountPoisha.isAcceptableOrUnknown(
          data['amount_poisha']!,
          _amountPoishaMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountPoishaMeta);
    }
    if (data.containsKey('method')) {
      context.handle(
        _methodMeta,
        method.isAcceptableOrUnknown(data['method']!, _methodMeta),
      );
    } else if (isInserting) {
      context.missing(_methodMeta);
    }
    if (data.containsKey('transaction_ref')) {
      context.handle(
        _transactionRefMeta,
        transactionRef.isAcceptableOrUnknown(
          data['transaction_ref']!,
          _transactionRefMeta,
        ),
      );
    }
    if (data.containsKey('receipt_no')) {
      context.handle(
        _receiptNoMeta,
        receiptNo.isAcceptableOrUnknown(data['receipt_no']!, _receiptNoMeta),
      );
    } else if (isInserting) {
      context.missing(_receiptNoMeta);
    }
    if (data.containsKey('physical_receipt_no')) {
      context.handle(
        _physicalReceiptNoMeta,
        physicalReceiptNo.isAcceptableOrUnknown(
          data['physical_receipt_no']!,
          _physicalReceiptNoMeta,
        ),
      );
    }
    if (data.containsKey('payer_name')) {
      context.handle(
        _payerNameMeta,
        payerName.isAcceptableOrUnknown(data['payer_name']!, _payerNameMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('recorded_at')) {
      context.handle(
        _recordedAtMeta,
        recordedAt.isAcceptableOrUnknown(data['recorded_at']!, _recordedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_recordedAtMeta);
    }
    if (data.containsKey('device_time')) {
      context.handle(
        _deviceTimeMeta,
        deviceTime.isAcceptableOrUnknown(data['device_time']!, _deviceTimeMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceTimeMeta);
    }
    if (data.containsKey('business_date')) {
      context.handle(
        _businessDateMeta,
        businessDate.isAcceptableOrUnknown(
          data['business_date']!,
          _businessDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_businessDateMeta);
    }
    if (data.containsKey('lat')) {
      context.handle(
        _latMeta,
        lat.isAcceptableOrUnknown(data['lat']!, _latMeta),
      );
    }
    if (data.containsKey('lng')) {
      context.handle(
        _lngMeta,
        lng.isAcceptableOrUnknown(data['lng']!, _lngMeta),
      );
    }
    if (data.containsKey('accuracy_m')) {
      context.handle(
        _accuracyMMeta,
        accuracyM.isAcceptableOrUnknown(data['accuracy_m']!, _accuracyMMeta),
      );
    }
    if (data.containsKey('mock')) {
      context.handle(
        _mockMeta,
        mock.isAcceptableOrUnknown(data['mock']!, _mockMeta),
      );
    }
    if (data.containsKey('visit_client_id')) {
      context.handle(
        _visitClientIdMeta,
        visitClientId.isAcceptableOrUnknown(
          data['visit_client_id']!,
          _visitClientIdMeta,
        ),
      );
    }
    if (data.containsKey('photo_media_client_id')) {
      context.handle(
        _photoMediaClientIdMeta,
        photoMediaClientId.isAcceptableOrUnknown(
          data['photo_media_client_id']!,
          _photoMediaClientIdMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('erp_receipt_no')) {
      context.handle(
        _erpReceiptNoMeta,
        erpReceiptNo.isAcceptableOrUnknown(
          data['erp_receipt_no']!,
          _erpReceiptNoMeta,
        ),
      );
    }
    if (data.containsKey('conflict_code')) {
      context.handle(
        _conflictCodeMeta,
        conflictCode.isAcceptableOrUnknown(
          data['conflict_code']!,
          _conflictCodeMeta,
        ),
      );
    }
    if (data.containsKey('conflict_message')) {
      context.handle(
        _conflictMessageMeta,
        conflictMessage.isAcceptableOrUnknown(
          data['conflict_message']!,
          _conflictMessageMeta,
        ),
      );
    }
    if (data.containsKey('resolution_text')) {
      context.handle(
        _resolutionTextMeta,
        resolutionText.isAcceptableOrUnknown(
          data['resolution_text']!,
          _resolutionTextMeta,
        ),
      );
    }
    if (data.containsKey('flags_json')) {
      context.handle(
        _flagsJsonMeta,
        flagsJson.isAcceptableOrUnknown(data['flags_json']!, _flagsJsonMeta),
      );
    }
    if (data.containsKey('sync_state')) {
      context.handle(
        _syncStateMeta,
        syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {clientId};
  @override
  CollectionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CollectionRow(
      clientId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}client_id'],
      )!,
      serverId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}server_id'],
      ),
      customerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}customer_id'],
      )!,
      customerName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}customer_name'],
      )!,
      customerCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}customer_code'],
      )!,
      erpPlanId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}erp_plan_id'],
      ),
      amountPoisha: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_poisha'],
      )!,
      method: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}method'],
      )!,
      transactionRef: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transaction_ref'],
      ),
      receiptNo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}receipt_no'],
      )!,
      physicalReceiptNo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}physical_receipt_no'],
      ),
      payerName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payer_name'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      recordedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}recorded_at'],
      )!,
      deviceTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}device_time'],
      )!,
      businessDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}business_date'],
      )!,
      lat: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}lat'],
      ),
      lng: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}lng'],
      ),
      accuracyM: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}accuracy_m'],
      ),
      mock: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}mock'],
      )!,
      visitClientId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}visit_client_id'],
      ),
      photoMediaClientId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}photo_media_client_id'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      erpReceiptNo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}erp_receipt_no'],
      ),
      conflictCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}conflict_code'],
      ),
      conflictMessage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}conflict_message'],
      ),
      resolutionText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}resolution_text'],
      ),
      flagsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}flags_json'],
      )!,
      syncState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_state'],
      )!,
    );
  }

  @override
  $CollectionsTable createAlias(String alias) {
    return $CollectionsTable(attachedDatabase, alias);
  }
}

class CollectionRow extends DataClass implements Insertable<CollectionRow> {
  final String clientId;
  final String? serverId;
  final String customerId;
  final String customerName;
  final String customerCode;
  final String? erpPlanId;
  final int amountPoisha;
  final String method;
  final String? transactionRef;
  final String receiptNo;
  final String? physicalReceiptNo;
  final String? payerName;
  final String? note;
  final DateTime recordedAt;
  final DateTime deviceTime;
  final String businessDate;
  final double? lat;
  final double? lng;
  final double? accuracyM;
  final bool mock;
  final String? visitClientId;
  final String? photoMediaClientId;

  /// queued | received | posting | posted | conflict | posting_failed |
  /// resolved_posted | resolved_refund | resolved_voided | voided | rejected
  final String status;
  final String? erpReceiptNo;
  final String? conflictCode;
  final String? conflictMessage;
  final String? resolutionText;
  final String flagsJson;
  final String syncState;
  const CollectionRow({
    required this.clientId,
    this.serverId,
    required this.customerId,
    required this.customerName,
    required this.customerCode,
    this.erpPlanId,
    required this.amountPoisha,
    required this.method,
    this.transactionRef,
    required this.receiptNo,
    this.physicalReceiptNo,
    this.payerName,
    this.note,
    required this.recordedAt,
    required this.deviceTime,
    required this.businessDate,
    this.lat,
    this.lng,
    this.accuracyM,
    required this.mock,
    this.visitClientId,
    this.photoMediaClientId,
    required this.status,
    this.erpReceiptNo,
    this.conflictCode,
    this.conflictMessage,
    this.resolutionText,
    required this.flagsJson,
    required this.syncState,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['client_id'] = Variable<String>(clientId);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<String>(serverId);
    }
    map['customer_id'] = Variable<String>(customerId);
    map['customer_name'] = Variable<String>(customerName);
    map['customer_code'] = Variable<String>(customerCode);
    if (!nullToAbsent || erpPlanId != null) {
      map['erp_plan_id'] = Variable<String>(erpPlanId);
    }
    map['amount_poisha'] = Variable<int>(amountPoisha);
    map['method'] = Variable<String>(method);
    if (!nullToAbsent || transactionRef != null) {
      map['transaction_ref'] = Variable<String>(transactionRef);
    }
    map['receipt_no'] = Variable<String>(receiptNo);
    if (!nullToAbsent || physicalReceiptNo != null) {
      map['physical_receipt_no'] = Variable<String>(physicalReceiptNo);
    }
    if (!nullToAbsent || payerName != null) {
      map['payer_name'] = Variable<String>(payerName);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['recorded_at'] = Variable<DateTime>(recordedAt);
    map['device_time'] = Variable<DateTime>(deviceTime);
    map['business_date'] = Variable<String>(businessDate);
    if (!nullToAbsent || lat != null) {
      map['lat'] = Variable<double>(lat);
    }
    if (!nullToAbsent || lng != null) {
      map['lng'] = Variable<double>(lng);
    }
    if (!nullToAbsent || accuracyM != null) {
      map['accuracy_m'] = Variable<double>(accuracyM);
    }
    map['mock'] = Variable<bool>(mock);
    if (!nullToAbsent || visitClientId != null) {
      map['visit_client_id'] = Variable<String>(visitClientId);
    }
    if (!nullToAbsent || photoMediaClientId != null) {
      map['photo_media_client_id'] = Variable<String>(photoMediaClientId);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || erpReceiptNo != null) {
      map['erp_receipt_no'] = Variable<String>(erpReceiptNo);
    }
    if (!nullToAbsent || conflictCode != null) {
      map['conflict_code'] = Variable<String>(conflictCode);
    }
    if (!nullToAbsent || conflictMessage != null) {
      map['conflict_message'] = Variable<String>(conflictMessage);
    }
    if (!nullToAbsent || resolutionText != null) {
      map['resolution_text'] = Variable<String>(resolutionText);
    }
    map['flags_json'] = Variable<String>(flagsJson);
    map['sync_state'] = Variable<String>(syncState);
    return map;
  }

  CollectionsCompanion toCompanion(bool nullToAbsent) {
    return CollectionsCompanion(
      clientId: Value(clientId),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      customerId: Value(customerId),
      customerName: Value(customerName),
      customerCode: Value(customerCode),
      erpPlanId: erpPlanId == null && nullToAbsent
          ? const Value.absent()
          : Value(erpPlanId),
      amountPoisha: Value(amountPoisha),
      method: Value(method),
      transactionRef: transactionRef == null && nullToAbsent
          ? const Value.absent()
          : Value(transactionRef),
      receiptNo: Value(receiptNo),
      physicalReceiptNo: physicalReceiptNo == null && nullToAbsent
          ? const Value.absent()
          : Value(physicalReceiptNo),
      payerName: payerName == null && nullToAbsent
          ? const Value.absent()
          : Value(payerName),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      recordedAt: Value(recordedAt),
      deviceTime: Value(deviceTime),
      businessDate: Value(businessDate),
      lat: lat == null && nullToAbsent ? const Value.absent() : Value(lat),
      lng: lng == null && nullToAbsent ? const Value.absent() : Value(lng),
      accuracyM: accuracyM == null && nullToAbsent
          ? const Value.absent()
          : Value(accuracyM),
      mock: Value(mock),
      visitClientId: visitClientId == null && nullToAbsent
          ? const Value.absent()
          : Value(visitClientId),
      photoMediaClientId: photoMediaClientId == null && nullToAbsent
          ? const Value.absent()
          : Value(photoMediaClientId),
      status: Value(status),
      erpReceiptNo: erpReceiptNo == null && nullToAbsent
          ? const Value.absent()
          : Value(erpReceiptNo),
      conflictCode: conflictCode == null && nullToAbsent
          ? const Value.absent()
          : Value(conflictCode),
      conflictMessage: conflictMessage == null && nullToAbsent
          ? const Value.absent()
          : Value(conflictMessage),
      resolutionText: resolutionText == null && nullToAbsent
          ? const Value.absent()
          : Value(resolutionText),
      flagsJson: Value(flagsJson),
      syncState: Value(syncState),
    );
  }

  factory CollectionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CollectionRow(
      clientId: serializer.fromJson<String>(json['clientId']),
      serverId: serializer.fromJson<String?>(json['serverId']),
      customerId: serializer.fromJson<String>(json['customerId']),
      customerName: serializer.fromJson<String>(json['customerName']),
      customerCode: serializer.fromJson<String>(json['customerCode']),
      erpPlanId: serializer.fromJson<String?>(json['erpPlanId']),
      amountPoisha: serializer.fromJson<int>(json['amountPoisha']),
      method: serializer.fromJson<String>(json['method']),
      transactionRef: serializer.fromJson<String?>(json['transactionRef']),
      receiptNo: serializer.fromJson<String>(json['receiptNo']),
      physicalReceiptNo: serializer.fromJson<String?>(
        json['physicalReceiptNo'],
      ),
      payerName: serializer.fromJson<String?>(json['payerName']),
      note: serializer.fromJson<String?>(json['note']),
      recordedAt: serializer.fromJson<DateTime>(json['recordedAt']),
      deviceTime: serializer.fromJson<DateTime>(json['deviceTime']),
      businessDate: serializer.fromJson<String>(json['businessDate']),
      lat: serializer.fromJson<double?>(json['lat']),
      lng: serializer.fromJson<double?>(json['lng']),
      accuracyM: serializer.fromJson<double?>(json['accuracyM']),
      mock: serializer.fromJson<bool>(json['mock']),
      visitClientId: serializer.fromJson<String?>(json['visitClientId']),
      photoMediaClientId: serializer.fromJson<String?>(
        json['photoMediaClientId'],
      ),
      status: serializer.fromJson<String>(json['status']),
      erpReceiptNo: serializer.fromJson<String?>(json['erpReceiptNo']),
      conflictCode: serializer.fromJson<String?>(json['conflictCode']),
      conflictMessage: serializer.fromJson<String?>(json['conflictMessage']),
      resolutionText: serializer.fromJson<String?>(json['resolutionText']),
      flagsJson: serializer.fromJson<String>(json['flagsJson']),
      syncState: serializer.fromJson<String>(json['syncState']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'clientId': serializer.toJson<String>(clientId),
      'serverId': serializer.toJson<String?>(serverId),
      'customerId': serializer.toJson<String>(customerId),
      'customerName': serializer.toJson<String>(customerName),
      'customerCode': serializer.toJson<String>(customerCode),
      'erpPlanId': serializer.toJson<String?>(erpPlanId),
      'amountPoisha': serializer.toJson<int>(amountPoisha),
      'method': serializer.toJson<String>(method),
      'transactionRef': serializer.toJson<String?>(transactionRef),
      'receiptNo': serializer.toJson<String>(receiptNo),
      'physicalReceiptNo': serializer.toJson<String?>(physicalReceiptNo),
      'payerName': serializer.toJson<String?>(payerName),
      'note': serializer.toJson<String?>(note),
      'recordedAt': serializer.toJson<DateTime>(recordedAt),
      'deviceTime': serializer.toJson<DateTime>(deviceTime),
      'businessDate': serializer.toJson<String>(businessDate),
      'lat': serializer.toJson<double?>(lat),
      'lng': serializer.toJson<double?>(lng),
      'accuracyM': serializer.toJson<double?>(accuracyM),
      'mock': serializer.toJson<bool>(mock),
      'visitClientId': serializer.toJson<String?>(visitClientId),
      'photoMediaClientId': serializer.toJson<String?>(photoMediaClientId),
      'status': serializer.toJson<String>(status),
      'erpReceiptNo': serializer.toJson<String?>(erpReceiptNo),
      'conflictCode': serializer.toJson<String?>(conflictCode),
      'conflictMessage': serializer.toJson<String?>(conflictMessage),
      'resolutionText': serializer.toJson<String?>(resolutionText),
      'flagsJson': serializer.toJson<String>(flagsJson),
      'syncState': serializer.toJson<String>(syncState),
    };
  }

  CollectionRow copyWith({
    String? clientId,
    Value<String?> serverId = const Value.absent(),
    String? customerId,
    String? customerName,
    String? customerCode,
    Value<String?> erpPlanId = const Value.absent(),
    int? amountPoisha,
    String? method,
    Value<String?> transactionRef = const Value.absent(),
    String? receiptNo,
    Value<String?> physicalReceiptNo = const Value.absent(),
    Value<String?> payerName = const Value.absent(),
    Value<String?> note = const Value.absent(),
    DateTime? recordedAt,
    DateTime? deviceTime,
    String? businessDate,
    Value<double?> lat = const Value.absent(),
    Value<double?> lng = const Value.absent(),
    Value<double?> accuracyM = const Value.absent(),
    bool? mock,
    Value<String?> visitClientId = const Value.absent(),
    Value<String?> photoMediaClientId = const Value.absent(),
    String? status,
    Value<String?> erpReceiptNo = const Value.absent(),
    Value<String?> conflictCode = const Value.absent(),
    Value<String?> conflictMessage = const Value.absent(),
    Value<String?> resolutionText = const Value.absent(),
    String? flagsJson,
    String? syncState,
  }) => CollectionRow(
    clientId: clientId ?? this.clientId,
    serverId: serverId.present ? serverId.value : this.serverId,
    customerId: customerId ?? this.customerId,
    customerName: customerName ?? this.customerName,
    customerCode: customerCode ?? this.customerCode,
    erpPlanId: erpPlanId.present ? erpPlanId.value : this.erpPlanId,
    amountPoisha: amountPoisha ?? this.amountPoisha,
    method: method ?? this.method,
    transactionRef: transactionRef.present
        ? transactionRef.value
        : this.transactionRef,
    receiptNo: receiptNo ?? this.receiptNo,
    physicalReceiptNo: physicalReceiptNo.present
        ? physicalReceiptNo.value
        : this.physicalReceiptNo,
    payerName: payerName.present ? payerName.value : this.payerName,
    note: note.present ? note.value : this.note,
    recordedAt: recordedAt ?? this.recordedAt,
    deviceTime: deviceTime ?? this.deviceTime,
    businessDate: businessDate ?? this.businessDate,
    lat: lat.present ? lat.value : this.lat,
    lng: lng.present ? lng.value : this.lng,
    accuracyM: accuracyM.present ? accuracyM.value : this.accuracyM,
    mock: mock ?? this.mock,
    visitClientId: visitClientId.present
        ? visitClientId.value
        : this.visitClientId,
    photoMediaClientId: photoMediaClientId.present
        ? photoMediaClientId.value
        : this.photoMediaClientId,
    status: status ?? this.status,
    erpReceiptNo: erpReceiptNo.present ? erpReceiptNo.value : this.erpReceiptNo,
    conflictCode: conflictCode.present ? conflictCode.value : this.conflictCode,
    conflictMessage: conflictMessage.present
        ? conflictMessage.value
        : this.conflictMessage,
    resolutionText: resolutionText.present
        ? resolutionText.value
        : this.resolutionText,
    flagsJson: flagsJson ?? this.flagsJson,
    syncState: syncState ?? this.syncState,
  );
  CollectionRow copyWithCompanion(CollectionsCompanion data) {
    return CollectionRow(
      clientId: data.clientId.present ? data.clientId.value : this.clientId,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      customerId: data.customerId.present
          ? data.customerId.value
          : this.customerId,
      customerName: data.customerName.present
          ? data.customerName.value
          : this.customerName,
      customerCode: data.customerCode.present
          ? data.customerCode.value
          : this.customerCode,
      erpPlanId: data.erpPlanId.present ? data.erpPlanId.value : this.erpPlanId,
      amountPoisha: data.amountPoisha.present
          ? data.amountPoisha.value
          : this.amountPoisha,
      method: data.method.present ? data.method.value : this.method,
      transactionRef: data.transactionRef.present
          ? data.transactionRef.value
          : this.transactionRef,
      receiptNo: data.receiptNo.present ? data.receiptNo.value : this.receiptNo,
      physicalReceiptNo: data.physicalReceiptNo.present
          ? data.physicalReceiptNo.value
          : this.physicalReceiptNo,
      payerName: data.payerName.present ? data.payerName.value : this.payerName,
      note: data.note.present ? data.note.value : this.note,
      recordedAt: data.recordedAt.present
          ? data.recordedAt.value
          : this.recordedAt,
      deviceTime: data.deviceTime.present
          ? data.deviceTime.value
          : this.deviceTime,
      businessDate: data.businessDate.present
          ? data.businessDate.value
          : this.businessDate,
      lat: data.lat.present ? data.lat.value : this.lat,
      lng: data.lng.present ? data.lng.value : this.lng,
      accuracyM: data.accuracyM.present ? data.accuracyM.value : this.accuracyM,
      mock: data.mock.present ? data.mock.value : this.mock,
      visitClientId: data.visitClientId.present
          ? data.visitClientId.value
          : this.visitClientId,
      photoMediaClientId: data.photoMediaClientId.present
          ? data.photoMediaClientId.value
          : this.photoMediaClientId,
      status: data.status.present ? data.status.value : this.status,
      erpReceiptNo: data.erpReceiptNo.present
          ? data.erpReceiptNo.value
          : this.erpReceiptNo,
      conflictCode: data.conflictCode.present
          ? data.conflictCode.value
          : this.conflictCode,
      conflictMessage: data.conflictMessage.present
          ? data.conflictMessage.value
          : this.conflictMessage,
      resolutionText: data.resolutionText.present
          ? data.resolutionText.value
          : this.resolutionText,
      flagsJson: data.flagsJson.present ? data.flagsJson.value : this.flagsJson,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CollectionRow(')
          ..write('clientId: $clientId, ')
          ..write('serverId: $serverId, ')
          ..write('customerId: $customerId, ')
          ..write('customerName: $customerName, ')
          ..write('customerCode: $customerCode, ')
          ..write('erpPlanId: $erpPlanId, ')
          ..write('amountPoisha: $amountPoisha, ')
          ..write('method: $method, ')
          ..write('transactionRef: $transactionRef, ')
          ..write('receiptNo: $receiptNo, ')
          ..write('physicalReceiptNo: $physicalReceiptNo, ')
          ..write('payerName: $payerName, ')
          ..write('note: $note, ')
          ..write('recordedAt: $recordedAt, ')
          ..write('deviceTime: $deviceTime, ')
          ..write('businessDate: $businessDate, ')
          ..write('lat: $lat, ')
          ..write('lng: $lng, ')
          ..write('accuracyM: $accuracyM, ')
          ..write('mock: $mock, ')
          ..write('visitClientId: $visitClientId, ')
          ..write('photoMediaClientId: $photoMediaClientId, ')
          ..write('status: $status, ')
          ..write('erpReceiptNo: $erpReceiptNo, ')
          ..write('conflictCode: $conflictCode, ')
          ..write('conflictMessage: $conflictMessage, ')
          ..write('resolutionText: $resolutionText, ')
          ..write('flagsJson: $flagsJson, ')
          ..write('syncState: $syncState')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    clientId,
    serverId,
    customerId,
    customerName,
    customerCode,
    erpPlanId,
    amountPoisha,
    method,
    transactionRef,
    receiptNo,
    physicalReceiptNo,
    payerName,
    note,
    recordedAt,
    deviceTime,
    businessDate,
    lat,
    lng,
    accuracyM,
    mock,
    visitClientId,
    photoMediaClientId,
    status,
    erpReceiptNo,
    conflictCode,
    conflictMessage,
    resolutionText,
    flagsJson,
    syncState,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CollectionRow &&
          other.clientId == this.clientId &&
          other.serverId == this.serverId &&
          other.customerId == this.customerId &&
          other.customerName == this.customerName &&
          other.customerCode == this.customerCode &&
          other.erpPlanId == this.erpPlanId &&
          other.amountPoisha == this.amountPoisha &&
          other.method == this.method &&
          other.transactionRef == this.transactionRef &&
          other.receiptNo == this.receiptNo &&
          other.physicalReceiptNo == this.physicalReceiptNo &&
          other.payerName == this.payerName &&
          other.note == this.note &&
          other.recordedAt == this.recordedAt &&
          other.deviceTime == this.deviceTime &&
          other.businessDate == this.businessDate &&
          other.lat == this.lat &&
          other.lng == this.lng &&
          other.accuracyM == this.accuracyM &&
          other.mock == this.mock &&
          other.visitClientId == this.visitClientId &&
          other.photoMediaClientId == this.photoMediaClientId &&
          other.status == this.status &&
          other.erpReceiptNo == this.erpReceiptNo &&
          other.conflictCode == this.conflictCode &&
          other.conflictMessage == this.conflictMessage &&
          other.resolutionText == this.resolutionText &&
          other.flagsJson == this.flagsJson &&
          other.syncState == this.syncState);
}

class CollectionsCompanion extends UpdateCompanion<CollectionRow> {
  final Value<String> clientId;
  final Value<String?> serverId;
  final Value<String> customerId;
  final Value<String> customerName;
  final Value<String> customerCode;
  final Value<String?> erpPlanId;
  final Value<int> amountPoisha;
  final Value<String> method;
  final Value<String?> transactionRef;
  final Value<String> receiptNo;
  final Value<String?> physicalReceiptNo;
  final Value<String?> payerName;
  final Value<String?> note;
  final Value<DateTime> recordedAt;
  final Value<DateTime> deviceTime;
  final Value<String> businessDate;
  final Value<double?> lat;
  final Value<double?> lng;
  final Value<double?> accuracyM;
  final Value<bool> mock;
  final Value<String?> visitClientId;
  final Value<String?> photoMediaClientId;
  final Value<String> status;
  final Value<String?> erpReceiptNo;
  final Value<String?> conflictCode;
  final Value<String?> conflictMessage;
  final Value<String?> resolutionText;
  final Value<String> flagsJson;
  final Value<String> syncState;
  final Value<int> rowid;
  const CollectionsCompanion({
    this.clientId = const Value.absent(),
    this.serverId = const Value.absent(),
    this.customerId = const Value.absent(),
    this.customerName = const Value.absent(),
    this.customerCode = const Value.absent(),
    this.erpPlanId = const Value.absent(),
    this.amountPoisha = const Value.absent(),
    this.method = const Value.absent(),
    this.transactionRef = const Value.absent(),
    this.receiptNo = const Value.absent(),
    this.physicalReceiptNo = const Value.absent(),
    this.payerName = const Value.absent(),
    this.note = const Value.absent(),
    this.recordedAt = const Value.absent(),
    this.deviceTime = const Value.absent(),
    this.businessDate = const Value.absent(),
    this.lat = const Value.absent(),
    this.lng = const Value.absent(),
    this.accuracyM = const Value.absent(),
    this.mock = const Value.absent(),
    this.visitClientId = const Value.absent(),
    this.photoMediaClientId = const Value.absent(),
    this.status = const Value.absent(),
    this.erpReceiptNo = const Value.absent(),
    this.conflictCode = const Value.absent(),
    this.conflictMessage = const Value.absent(),
    this.resolutionText = const Value.absent(),
    this.flagsJson = const Value.absent(),
    this.syncState = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CollectionsCompanion.insert({
    required String clientId,
    this.serverId = const Value.absent(),
    required String customerId,
    required String customerName,
    required String customerCode,
    this.erpPlanId = const Value.absent(),
    required int amountPoisha,
    required String method,
    this.transactionRef = const Value.absent(),
    required String receiptNo,
    this.physicalReceiptNo = const Value.absent(),
    this.payerName = const Value.absent(),
    this.note = const Value.absent(),
    required DateTime recordedAt,
    required DateTime deviceTime,
    required String businessDate,
    this.lat = const Value.absent(),
    this.lng = const Value.absent(),
    this.accuracyM = const Value.absent(),
    this.mock = const Value.absent(),
    this.visitClientId = const Value.absent(),
    this.photoMediaClientId = const Value.absent(),
    this.status = const Value.absent(),
    this.erpReceiptNo = const Value.absent(),
    this.conflictCode = const Value.absent(),
    this.conflictMessage = const Value.absent(),
    this.resolutionText = const Value.absent(),
    this.flagsJson = const Value.absent(),
    this.syncState = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : clientId = Value(clientId),
       customerId = Value(customerId),
       customerName = Value(customerName),
       customerCode = Value(customerCode),
       amountPoisha = Value(amountPoisha),
       method = Value(method),
       receiptNo = Value(receiptNo),
       recordedAt = Value(recordedAt),
       deviceTime = Value(deviceTime),
       businessDate = Value(businessDate);
  static Insertable<CollectionRow> custom({
    Expression<String>? clientId,
    Expression<String>? serverId,
    Expression<String>? customerId,
    Expression<String>? customerName,
    Expression<String>? customerCode,
    Expression<String>? erpPlanId,
    Expression<int>? amountPoisha,
    Expression<String>? method,
    Expression<String>? transactionRef,
    Expression<String>? receiptNo,
    Expression<String>? physicalReceiptNo,
    Expression<String>? payerName,
    Expression<String>? note,
    Expression<DateTime>? recordedAt,
    Expression<DateTime>? deviceTime,
    Expression<String>? businessDate,
    Expression<double>? lat,
    Expression<double>? lng,
    Expression<double>? accuracyM,
    Expression<bool>? mock,
    Expression<String>? visitClientId,
    Expression<String>? photoMediaClientId,
    Expression<String>? status,
    Expression<String>? erpReceiptNo,
    Expression<String>? conflictCode,
    Expression<String>? conflictMessage,
    Expression<String>? resolutionText,
    Expression<String>? flagsJson,
    Expression<String>? syncState,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (clientId != null) 'client_id': clientId,
      if (serverId != null) 'server_id': serverId,
      if (customerId != null) 'customer_id': customerId,
      if (customerName != null) 'customer_name': customerName,
      if (customerCode != null) 'customer_code': customerCode,
      if (erpPlanId != null) 'erp_plan_id': erpPlanId,
      if (amountPoisha != null) 'amount_poisha': amountPoisha,
      if (method != null) 'method': method,
      if (transactionRef != null) 'transaction_ref': transactionRef,
      if (receiptNo != null) 'receipt_no': receiptNo,
      if (physicalReceiptNo != null) 'physical_receipt_no': physicalReceiptNo,
      if (payerName != null) 'payer_name': payerName,
      if (note != null) 'note': note,
      if (recordedAt != null) 'recorded_at': recordedAt,
      if (deviceTime != null) 'device_time': deviceTime,
      if (businessDate != null) 'business_date': businessDate,
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
      if (accuracyM != null) 'accuracy_m': accuracyM,
      if (mock != null) 'mock': mock,
      if (visitClientId != null) 'visit_client_id': visitClientId,
      if (photoMediaClientId != null)
        'photo_media_client_id': photoMediaClientId,
      if (status != null) 'status': status,
      if (erpReceiptNo != null) 'erp_receipt_no': erpReceiptNo,
      if (conflictCode != null) 'conflict_code': conflictCode,
      if (conflictMessage != null) 'conflict_message': conflictMessage,
      if (resolutionText != null) 'resolution_text': resolutionText,
      if (flagsJson != null) 'flags_json': flagsJson,
      if (syncState != null) 'sync_state': syncState,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CollectionsCompanion copyWith({
    Value<String>? clientId,
    Value<String?>? serverId,
    Value<String>? customerId,
    Value<String>? customerName,
    Value<String>? customerCode,
    Value<String?>? erpPlanId,
    Value<int>? amountPoisha,
    Value<String>? method,
    Value<String?>? transactionRef,
    Value<String>? receiptNo,
    Value<String?>? physicalReceiptNo,
    Value<String?>? payerName,
    Value<String?>? note,
    Value<DateTime>? recordedAt,
    Value<DateTime>? deviceTime,
    Value<String>? businessDate,
    Value<double?>? lat,
    Value<double?>? lng,
    Value<double?>? accuracyM,
    Value<bool>? mock,
    Value<String?>? visitClientId,
    Value<String?>? photoMediaClientId,
    Value<String>? status,
    Value<String?>? erpReceiptNo,
    Value<String?>? conflictCode,
    Value<String?>? conflictMessage,
    Value<String?>? resolutionText,
    Value<String>? flagsJson,
    Value<String>? syncState,
    Value<int>? rowid,
  }) {
    return CollectionsCompanion(
      clientId: clientId ?? this.clientId,
      serverId: serverId ?? this.serverId,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerCode: customerCode ?? this.customerCode,
      erpPlanId: erpPlanId ?? this.erpPlanId,
      amountPoisha: amountPoisha ?? this.amountPoisha,
      method: method ?? this.method,
      transactionRef: transactionRef ?? this.transactionRef,
      receiptNo: receiptNo ?? this.receiptNo,
      physicalReceiptNo: physicalReceiptNo ?? this.physicalReceiptNo,
      payerName: payerName ?? this.payerName,
      note: note ?? this.note,
      recordedAt: recordedAt ?? this.recordedAt,
      deviceTime: deviceTime ?? this.deviceTime,
      businessDate: businessDate ?? this.businessDate,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      accuracyM: accuracyM ?? this.accuracyM,
      mock: mock ?? this.mock,
      visitClientId: visitClientId ?? this.visitClientId,
      photoMediaClientId: photoMediaClientId ?? this.photoMediaClientId,
      status: status ?? this.status,
      erpReceiptNo: erpReceiptNo ?? this.erpReceiptNo,
      conflictCode: conflictCode ?? this.conflictCode,
      conflictMessage: conflictMessage ?? this.conflictMessage,
      resolutionText: resolutionText ?? this.resolutionText,
      flagsJson: flagsJson ?? this.flagsJson,
      syncState: syncState ?? this.syncState,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (clientId.present) {
      map['client_id'] = Variable<String>(clientId.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<String>(serverId.value);
    }
    if (customerId.present) {
      map['customer_id'] = Variable<String>(customerId.value);
    }
    if (customerName.present) {
      map['customer_name'] = Variable<String>(customerName.value);
    }
    if (customerCode.present) {
      map['customer_code'] = Variable<String>(customerCode.value);
    }
    if (erpPlanId.present) {
      map['erp_plan_id'] = Variable<String>(erpPlanId.value);
    }
    if (amountPoisha.present) {
      map['amount_poisha'] = Variable<int>(amountPoisha.value);
    }
    if (method.present) {
      map['method'] = Variable<String>(method.value);
    }
    if (transactionRef.present) {
      map['transaction_ref'] = Variable<String>(transactionRef.value);
    }
    if (receiptNo.present) {
      map['receipt_no'] = Variable<String>(receiptNo.value);
    }
    if (physicalReceiptNo.present) {
      map['physical_receipt_no'] = Variable<String>(physicalReceiptNo.value);
    }
    if (payerName.present) {
      map['payer_name'] = Variable<String>(payerName.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (recordedAt.present) {
      map['recorded_at'] = Variable<DateTime>(recordedAt.value);
    }
    if (deviceTime.present) {
      map['device_time'] = Variable<DateTime>(deviceTime.value);
    }
    if (businessDate.present) {
      map['business_date'] = Variable<String>(businessDate.value);
    }
    if (lat.present) {
      map['lat'] = Variable<double>(lat.value);
    }
    if (lng.present) {
      map['lng'] = Variable<double>(lng.value);
    }
    if (accuracyM.present) {
      map['accuracy_m'] = Variable<double>(accuracyM.value);
    }
    if (mock.present) {
      map['mock'] = Variable<bool>(mock.value);
    }
    if (visitClientId.present) {
      map['visit_client_id'] = Variable<String>(visitClientId.value);
    }
    if (photoMediaClientId.present) {
      map['photo_media_client_id'] = Variable<String>(photoMediaClientId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (erpReceiptNo.present) {
      map['erp_receipt_no'] = Variable<String>(erpReceiptNo.value);
    }
    if (conflictCode.present) {
      map['conflict_code'] = Variable<String>(conflictCode.value);
    }
    if (conflictMessage.present) {
      map['conflict_message'] = Variable<String>(conflictMessage.value);
    }
    if (resolutionText.present) {
      map['resolution_text'] = Variable<String>(resolutionText.value);
    }
    if (flagsJson.present) {
      map['flags_json'] = Variable<String>(flagsJson.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(syncState.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CollectionsCompanion(')
          ..write('clientId: $clientId, ')
          ..write('serverId: $serverId, ')
          ..write('customerId: $customerId, ')
          ..write('customerName: $customerName, ')
          ..write('customerCode: $customerCode, ')
          ..write('erpPlanId: $erpPlanId, ')
          ..write('amountPoisha: $amountPoisha, ')
          ..write('method: $method, ')
          ..write('transactionRef: $transactionRef, ')
          ..write('receiptNo: $receiptNo, ')
          ..write('physicalReceiptNo: $physicalReceiptNo, ')
          ..write('payerName: $payerName, ')
          ..write('note: $note, ')
          ..write('recordedAt: $recordedAt, ')
          ..write('deviceTime: $deviceTime, ')
          ..write('businessDate: $businessDate, ')
          ..write('lat: $lat, ')
          ..write('lng: $lng, ')
          ..write('accuracyM: $accuracyM, ')
          ..write('mock: $mock, ')
          ..write('visitClientId: $visitClientId, ')
          ..write('photoMediaClientId: $photoMediaClientId, ')
          ..write('status: $status, ')
          ..write('erpReceiptNo: $erpReceiptNo, ')
          ..write('conflictCode: $conflictCode, ')
          ..write('conflictMessage: $conflictMessage, ')
          ..write('resolutionText: $resolutionText, ')
          ..write('flagsJson: $flagsJson, ')
          ..write('syncState: $syncState, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReceiptBlocksTable extends ReceiptBlocks
    with TableInfo<$ReceiptBlocksTable, ReceiptBlockRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReceiptBlocksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _prefixMeta = const VerificationMeta('prefix');
  @override
  late final GeneratedColumn<String> prefix = GeneratedColumn<String>(
    'prefix',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _businessDateMeta = const VerificationMeta(
    'businessDate',
  );
  @override
  late final GeneratedColumn<String> businessDate = GeneratedColumn<String>(
    'business_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fromSeqMeta = const VerificationMeta(
    'fromSeq',
  );
  @override
  late final GeneratedColumn<int> fromSeq = GeneratedColumn<int>(
    'from_seq',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _toSeqMeta = const VerificationMeta('toSeq');
  @override
  late final GeneratedColumn<int> toSeq = GeneratedColumn<int>(
    'to_seq',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastUsedMeta = const VerificationMeta(
    'lastUsed',
  );
  @override
  late final GeneratedColumn<int> lastUsed = GeneratedColumn<int>(
    'last_used',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _offlineMeta = const VerificationMeta(
    'offline',
  );
  @override
  late final GeneratedColumn<bool> offline = GeneratedColumn<bool>(
    'offline',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("offline" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    prefix,
    businessDate,
    fromSeq,
    toSeq,
    lastUsed,
    offline,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'receipt_blocks';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReceiptBlockRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('prefix')) {
      context.handle(
        _prefixMeta,
        prefix.isAcceptableOrUnknown(data['prefix']!, _prefixMeta),
      );
    } else if (isInserting) {
      context.missing(_prefixMeta);
    }
    if (data.containsKey('business_date')) {
      context.handle(
        _businessDateMeta,
        businessDate.isAcceptableOrUnknown(
          data['business_date']!,
          _businessDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_businessDateMeta);
    }
    if (data.containsKey('from_seq')) {
      context.handle(
        _fromSeqMeta,
        fromSeq.isAcceptableOrUnknown(data['from_seq']!, _fromSeqMeta),
      );
    } else if (isInserting) {
      context.missing(_fromSeqMeta);
    }
    if (data.containsKey('to_seq')) {
      context.handle(
        _toSeqMeta,
        toSeq.isAcceptableOrUnknown(data['to_seq']!, _toSeqMeta),
      );
    } else if (isInserting) {
      context.missing(_toSeqMeta);
    }
    if (data.containsKey('last_used')) {
      context.handle(
        _lastUsedMeta,
        lastUsed.isAcceptableOrUnknown(data['last_used']!, _lastUsedMeta),
      );
    } else if (isInserting) {
      context.missing(_lastUsedMeta);
    }
    if (data.containsKey('offline')) {
      context.handle(
        _offlineMeta,
        offline.isAcceptableOrUnknown(data['offline']!, _offlineMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReceiptBlockRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReceiptBlockRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      prefix: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}prefix'],
      )!,
      businessDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}business_date'],
      )!,
      fromSeq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}from_seq'],
      )!,
      toSeq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}to_seq'],
      )!,
      lastUsed: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_used'],
      )!,
      offline: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}offline'],
      )!,
    );
  }

  @override
  $ReceiptBlocksTable createAlias(String alias) {
    return $ReceiptBlocksTable(attachedDatabase, alias);
  }
}

class ReceiptBlockRow extends DataClass implements Insertable<ReceiptBlockRow> {
  final int id;
  final String prefix;
  final String businessDate;
  final int fromSeq;
  final int toSeq;
  final int lastUsed;

  /// true for the device-reserved offline fallback series (`…-OFF{seq}`).
  final bool offline;
  const ReceiptBlockRow({
    required this.id,
    required this.prefix,
    required this.businessDate,
    required this.fromSeq,
    required this.toSeq,
    required this.lastUsed,
    required this.offline,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['prefix'] = Variable<String>(prefix);
    map['business_date'] = Variable<String>(businessDate);
    map['from_seq'] = Variable<int>(fromSeq);
    map['to_seq'] = Variable<int>(toSeq);
    map['last_used'] = Variable<int>(lastUsed);
    map['offline'] = Variable<bool>(offline);
    return map;
  }

  ReceiptBlocksCompanion toCompanion(bool nullToAbsent) {
    return ReceiptBlocksCompanion(
      id: Value(id),
      prefix: Value(prefix),
      businessDate: Value(businessDate),
      fromSeq: Value(fromSeq),
      toSeq: Value(toSeq),
      lastUsed: Value(lastUsed),
      offline: Value(offline),
    );
  }

  factory ReceiptBlockRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReceiptBlockRow(
      id: serializer.fromJson<int>(json['id']),
      prefix: serializer.fromJson<String>(json['prefix']),
      businessDate: serializer.fromJson<String>(json['businessDate']),
      fromSeq: serializer.fromJson<int>(json['fromSeq']),
      toSeq: serializer.fromJson<int>(json['toSeq']),
      lastUsed: serializer.fromJson<int>(json['lastUsed']),
      offline: serializer.fromJson<bool>(json['offline']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'prefix': serializer.toJson<String>(prefix),
      'businessDate': serializer.toJson<String>(businessDate),
      'fromSeq': serializer.toJson<int>(fromSeq),
      'toSeq': serializer.toJson<int>(toSeq),
      'lastUsed': serializer.toJson<int>(lastUsed),
      'offline': serializer.toJson<bool>(offline),
    };
  }

  ReceiptBlockRow copyWith({
    int? id,
    String? prefix,
    String? businessDate,
    int? fromSeq,
    int? toSeq,
    int? lastUsed,
    bool? offline,
  }) => ReceiptBlockRow(
    id: id ?? this.id,
    prefix: prefix ?? this.prefix,
    businessDate: businessDate ?? this.businessDate,
    fromSeq: fromSeq ?? this.fromSeq,
    toSeq: toSeq ?? this.toSeq,
    lastUsed: lastUsed ?? this.lastUsed,
    offline: offline ?? this.offline,
  );
  ReceiptBlockRow copyWithCompanion(ReceiptBlocksCompanion data) {
    return ReceiptBlockRow(
      id: data.id.present ? data.id.value : this.id,
      prefix: data.prefix.present ? data.prefix.value : this.prefix,
      businessDate: data.businessDate.present
          ? data.businessDate.value
          : this.businessDate,
      fromSeq: data.fromSeq.present ? data.fromSeq.value : this.fromSeq,
      toSeq: data.toSeq.present ? data.toSeq.value : this.toSeq,
      lastUsed: data.lastUsed.present ? data.lastUsed.value : this.lastUsed,
      offline: data.offline.present ? data.offline.value : this.offline,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReceiptBlockRow(')
          ..write('id: $id, ')
          ..write('prefix: $prefix, ')
          ..write('businessDate: $businessDate, ')
          ..write('fromSeq: $fromSeq, ')
          ..write('toSeq: $toSeq, ')
          ..write('lastUsed: $lastUsed, ')
          ..write('offline: $offline')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, prefix, businessDate, fromSeq, toSeq, lastUsed, offline);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReceiptBlockRow &&
          other.id == this.id &&
          other.prefix == this.prefix &&
          other.businessDate == this.businessDate &&
          other.fromSeq == this.fromSeq &&
          other.toSeq == this.toSeq &&
          other.lastUsed == this.lastUsed &&
          other.offline == this.offline);
}

class ReceiptBlocksCompanion extends UpdateCompanion<ReceiptBlockRow> {
  final Value<int> id;
  final Value<String> prefix;
  final Value<String> businessDate;
  final Value<int> fromSeq;
  final Value<int> toSeq;
  final Value<int> lastUsed;
  final Value<bool> offline;
  const ReceiptBlocksCompanion({
    this.id = const Value.absent(),
    this.prefix = const Value.absent(),
    this.businessDate = const Value.absent(),
    this.fromSeq = const Value.absent(),
    this.toSeq = const Value.absent(),
    this.lastUsed = const Value.absent(),
    this.offline = const Value.absent(),
  });
  ReceiptBlocksCompanion.insert({
    this.id = const Value.absent(),
    required String prefix,
    required String businessDate,
    required int fromSeq,
    required int toSeq,
    required int lastUsed,
    this.offline = const Value.absent(),
  }) : prefix = Value(prefix),
       businessDate = Value(businessDate),
       fromSeq = Value(fromSeq),
       toSeq = Value(toSeq),
       lastUsed = Value(lastUsed);
  static Insertable<ReceiptBlockRow> custom({
    Expression<int>? id,
    Expression<String>? prefix,
    Expression<String>? businessDate,
    Expression<int>? fromSeq,
    Expression<int>? toSeq,
    Expression<int>? lastUsed,
    Expression<bool>? offline,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (prefix != null) 'prefix': prefix,
      if (businessDate != null) 'business_date': businessDate,
      if (fromSeq != null) 'from_seq': fromSeq,
      if (toSeq != null) 'to_seq': toSeq,
      if (lastUsed != null) 'last_used': lastUsed,
      if (offline != null) 'offline': offline,
    });
  }

  ReceiptBlocksCompanion copyWith({
    Value<int>? id,
    Value<String>? prefix,
    Value<String>? businessDate,
    Value<int>? fromSeq,
    Value<int>? toSeq,
    Value<int>? lastUsed,
    Value<bool>? offline,
  }) {
    return ReceiptBlocksCompanion(
      id: id ?? this.id,
      prefix: prefix ?? this.prefix,
      businessDate: businessDate ?? this.businessDate,
      fromSeq: fromSeq ?? this.fromSeq,
      toSeq: toSeq ?? this.toSeq,
      lastUsed: lastUsed ?? this.lastUsed,
      offline: offline ?? this.offline,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (prefix.present) {
      map['prefix'] = Variable<String>(prefix.value);
    }
    if (businessDate.present) {
      map['business_date'] = Variable<String>(businessDate.value);
    }
    if (fromSeq.present) {
      map['from_seq'] = Variable<int>(fromSeq.value);
    }
    if (toSeq.present) {
      map['to_seq'] = Variable<int>(toSeq.value);
    }
    if (lastUsed.present) {
      map['last_used'] = Variable<int>(lastUsed.value);
    }
    if (offline.present) {
      map['offline'] = Variable<bool>(offline.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReceiptBlocksCompanion(')
          ..write('id: $id, ')
          ..write('prefix: $prefix, ')
          ..write('businessDate: $businessDate, ')
          ..write('fromSeq: $fromSeq, ')
          ..write('toSeq: $toSeq, ')
          ..write('lastUsed: $lastUsed, ')
          ..write('offline: $offline')
          ..write(')'))
        .toString();
  }
}

class $CashPositionsTable extends CashPositions
    with TableInfo<$CashPositionsTable, CashPositionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CashPositionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _serverOnHandPoishaMeta =
      const VerificationMeta('serverOnHandPoisha');
  @override
  late final GeneratedColumn<int> serverOnHandPoisha = GeneratedColumn<int>(
    'server_on_hand_poisha',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _limitPoishaMeta = const VerificationMeta(
    'limitPoisha',
  );
  @override
  late final GeneratedColumn<int> limitPoisha = GeneratedColumn<int>(
    'limit_poisha',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pendingDepositsPoishaMeta =
      const VerificationMeta('pendingDepositsPoisha');
  @override
  late final GeneratedColumn<int> pendingDepositsPoisha = GeneratedColumn<int>(
    'pending_deposits_poisha',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _asOfMeta = const VerificationMeta('asOf');
  @override
  late final GeneratedColumn<DateTime> asOf = GeneratedColumn<DateTime>(
    'as_of',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    serverOnHandPoisha,
    limitPoisha,
    pendingDepositsPoisha,
    asOf,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cash_position';
  @override
  VerificationContext validateIntegrity(
    Insertable<CashPositionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('server_on_hand_poisha')) {
      context.handle(
        _serverOnHandPoishaMeta,
        serverOnHandPoisha.isAcceptableOrUnknown(
          data['server_on_hand_poisha']!,
          _serverOnHandPoishaMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_serverOnHandPoishaMeta);
    }
    if (data.containsKey('limit_poisha')) {
      context.handle(
        _limitPoishaMeta,
        limitPoisha.isAcceptableOrUnknown(
          data['limit_poisha']!,
          _limitPoishaMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_limitPoishaMeta);
    }
    if (data.containsKey('pending_deposits_poisha')) {
      context.handle(
        _pendingDepositsPoishaMeta,
        pendingDepositsPoisha.isAcceptableOrUnknown(
          data['pending_deposits_poisha']!,
          _pendingDepositsPoishaMeta,
        ),
      );
    }
    if (data.containsKey('as_of')) {
      context.handle(
        _asOfMeta,
        asOf.isAcceptableOrUnknown(data['as_of']!, _asOfMeta),
      );
    } else if (isInserting) {
      context.missing(_asOfMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CashPositionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CashPositionRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      serverOnHandPoisha: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_on_hand_poisha'],
      )!,
      limitPoisha: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}limit_poisha'],
      )!,
      pendingDepositsPoisha: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pending_deposits_poisha'],
      )!,
      asOf: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}as_of'],
      )!,
    );
  }

  @override
  $CashPositionsTable createAlias(String alias) {
    return $CashPositionsTable(attachedDatabase, alias);
  }
}

class CashPositionRow extends DataClass implements Insertable<CashPositionRow> {
  final int id;
  final int serverOnHandPoisha;
  final int limitPoisha;
  final int pendingDepositsPoisha;
  final DateTime asOf;
  const CashPositionRow({
    required this.id,
    required this.serverOnHandPoisha,
    required this.limitPoisha,
    required this.pendingDepositsPoisha,
    required this.asOf,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['server_on_hand_poisha'] = Variable<int>(serverOnHandPoisha);
    map['limit_poisha'] = Variable<int>(limitPoisha);
    map['pending_deposits_poisha'] = Variable<int>(pendingDepositsPoisha);
    map['as_of'] = Variable<DateTime>(asOf);
    return map;
  }

  CashPositionsCompanion toCompanion(bool nullToAbsent) {
    return CashPositionsCompanion(
      id: Value(id),
      serverOnHandPoisha: Value(serverOnHandPoisha),
      limitPoisha: Value(limitPoisha),
      pendingDepositsPoisha: Value(pendingDepositsPoisha),
      asOf: Value(asOf),
    );
  }

  factory CashPositionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CashPositionRow(
      id: serializer.fromJson<int>(json['id']),
      serverOnHandPoisha: serializer.fromJson<int>(json['serverOnHandPoisha']),
      limitPoisha: serializer.fromJson<int>(json['limitPoisha']),
      pendingDepositsPoisha: serializer.fromJson<int>(
        json['pendingDepositsPoisha'],
      ),
      asOf: serializer.fromJson<DateTime>(json['asOf']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'serverOnHandPoisha': serializer.toJson<int>(serverOnHandPoisha),
      'limitPoisha': serializer.toJson<int>(limitPoisha),
      'pendingDepositsPoisha': serializer.toJson<int>(pendingDepositsPoisha),
      'asOf': serializer.toJson<DateTime>(asOf),
    };
  }

  CashPositionRow copyWith({
    int? id,
    int? serverOnHandPoisha,
    int? limitPoisha,
    int? pendingDepositsPoisha,
    DateTime? asOf,
  }) => CashPositionRow(
    id: id ?? this.id,
    serverOnHandPoisha: serverOnHandPoisha ?? this.serverOnHandPoisha,
    limitPoisha: limitPoisha ?? this.limitPoisha,
    pendingDepositsPoisha: pendingDepositsPoisha ?? this.pendingDepositsPoisha,
    asOf: asOf ?? this.asOf,
  );
  CashPositionRow copyWithCompanion(CashPositionsCompanion data) {
    return CashPositionRow(
      id: data.id.present ? data.id.value : this.id,
      serverOnHandPoisha: data.serverOnHandPoisha.present
          ? data.serverOnHandPoisha.value
          : this.serverOnHandPoisha,
      limitPoisha: data.limitPoisha.present
          ? data.limitPoisha.value
          : this.limitPoisha,
      pendingDepositsPoisha: data.pendingDepositsPoisha.present
          ? data.pendingDepositsPoisha.value
          : this.pendingDepositsPoisha,
      asOf: data.asOf.present ? data.asOf.value : this.asOf,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CashPositionRow(')
          ..write('id: $id, ')
          ..write('serverOnHandPoisha: $serverOnHandPoisha, ')
          ..write('limitPoisha: $limitPoisha, ')
          ..write('pendingDepositsPoisha: $pendingDepositsPoisha, ')
          ..write('asOf: $asOf')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    serverOnHandPoisha,
    limitPoisha,
    pendingDepositsPoisha,
    asOf,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CashPositionRow &&
          other.id == this.id &&
          other.serverOnHandPoisha == this.serverOnHandPoisha &&
          other.limitPoisha == this.limitPoisha &&
          other.pendingDepositsPoisha == this.pendingDepositsPoisha &&
          other.asOf == this.asOf);
}

class CashPositionsCompanion extends UpdateCompanion<CashPositionRow> {
  final Value<int> id;
  final Value<int> serverOnHandPoisha;
  final Value<int> limitPoisha;
  final Value<int> pendingDepositsPoisha;
  final Value<DateTime> asOf;
  const CashPositionsCompanion({
    this.id = const Value.absent(),
    this.serverOnHandPoisha = const Value.absent(),
    this.limitPoisha = const Value.absent(),
    this.pendingDepositsPoisha = const Value.absent(),
    this.asOf = const Value.absent(),
  });
  CashPositionsCompanion.insert({
    this.id = const Value.absent(),
    required int serverOnHandPoisha,
    required int limitPoisha,
    this.pendingDepositsPoisha = const Value.absent(),
    required DateTime asOf,
  }) : serverOnHandPoisha = Value(serverOnHandPoisha),
       limitPoisha = Value(limitPoisha),
       asOf = Value(asOf);
  static Insertable<CashPositionRow> custom({
    Expression<int>? id,
    Expression<int>? serverOnHandPoisha,
    Expression<int>? limitPoisha,
    Expression<int>? pendingDepositsPoisha,
    Expression<DateTime>? asOf,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (serverOnHandPoisha != null)
        'server_on_hand_poisha': serverOnHandPoisha,
      if (limitPoisha != null) 'limit_poisha': limitPoisha,
      if (pendingDepositsPoisha != null)
        'pending_deposits_poisha': pendingDepositsPoisha,
      if (asOf != null) 'as_of': asOf,
    });
  }

  CashPositionsCompanion copyWith({
    Value<int>? id,
    Value<int>? serverOnHandPoisha,
    Value<int>? limitPoisha,
    Value<int>? pendingDepositsPoisha,
    Value<DateTime>? asOf,
  }) {
    return CashPositionsCompanion(
      id: id ?? this.id,
      serverOnHandPoisha: serverOnHandPoisha ?? this.serverOnHandPoisha,
      limitPoisha: limitPoisha ?? this.limitPoisha,
      pendingDepositsPoisha:
          pendingDepositsPoisha ?? this.pendingDepositsPoisha,
      asOf: asOf ?? this.asOf,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (serverOnHandPoisha.present) {
      map['server_on_hand_poisha'] = Variable<int>(serverOnHandPoisha.value);
    }
    if (limitPoisha.present) {
      map['limit_poisha'] = Variable<int>(limitPoisha.value);
    }
    if (pendingDepositsPoisha.present) {
      map['pending_deposits_poisha'] = Variable<int>(
        pendingDepositsPoisha.value,
      );
    }
    if (asOf.present) {
      map['as_of'] = Variable<DateTime>(asOf.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CashPositionsCompanion(')
          ..write('id: $id, ')
          ..write('serverOnHandPoisha: $serverOnHandPoisha, ')
          ..write('limitPoisha: $limitPoisha, ')
          ..write('pendingDepositsPoisha: $pendingDepositsPoisha, ')
          ..write('asOf: $asOf')
          ..write(')'))
        .toString();
  }
}

class $DepositsTable extends Deposits
    with TableInfo<$DepositsTable, DepositRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DepositsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _clientIdMeta = const VerificationMeta(
    'clientId',
  );
  @override
  late final GeneratedColumn<String> clientId = GeneratedColumn<String>(
    'client_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _serverIdMeta = const VerificationMeta(
    'serverId',
  );
  @override
  late final GeneratedColumn<String> serverId = GeneratedColumn<String>(
    'server_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _amountPoishaMeta = const VerificationMeta(
    'amountPoisha',
  );
  @override
  late final GeneratedColumn<int> amountPoisha = GeneratedColumn<int>(
    'amount_poisha',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _destinationMeta = const VerificationMeta(
    'destination',
  );
  @override
  late final GeneratedColumn<String> destination = GeneratedColumn<String>(
    'destination',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _referenceMeta = const VerificationMeta(
    'reference',
  );
  @override
  late final GeneratedColumn<String> reference = GeneratedColumn<String>(
    'reference',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _slipMediaClientIdMeta = const VerificationMeta(
    'slipMediaClientId',
  );
  @override
  late final GeneratedColumn<String> slipMediaClientId =
      GeneratedColumn<String>(
        'slip_media_client_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _depositedAtMeta = const VerificationMeta(
    'depositedAt',
  );
  @override
  late final GeneratedColumn<DateTime> depositedAt = GeneratedColumn<DateTime>(
    'deposited_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _rejectReasonMeta = const VerificationMeta(
    'rejectReason',
  );
  @override
  late final GeneratedColumn<String> rejectReason = GeneratedColumn<String>(
    'reject_reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncStateMeta = const VerificationMeta(
    'syncState',
  );
  @override
  late final GeneratedColumn<String> syncState = GeneratedColumn<String>(
    'sync_state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('queued'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    clientId,
    serverId,
    amountPoisha,
    destination,
    reference,
    slipMediaClientId,
    depositedAt,
    status,
    rejectReason,
    syncState,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'deposits';
  @override
  VerificationContext validateIntegrity(
    Insertable<DepositRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('client_id')) {
      context.handle(
        _clientIdMeta,
        clientId.isAcceptableOrUnknown(data['client_id']!, _clientIdMeta),
      );
    } else if (isInserting) {
      context.missing(_clientIdMeta);
    }
    if (data.containsKey('server_id')) {
      context.handle(
        _serverIdMeta,
        serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta),
      );
    }
    if (data.containsKey('amount_poisha')) {
      context.handle(
        _amountPoishaMeta,
        amountPoisha.isAcceptableOrUnknown(
          data['amount_poisha']!,
          _amountPoishaMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountPoishaMeta);
    }
    if (data.containsKey('destination')) {
      context.handle(
        _destinationMeta,
        destination.isAcceptableOrUnknown(
          data['destination']!,
          _destinationMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_destinationMeta);
    }
    if (data.containsKey('reference')) {
      context.handle(
        _referenceMeta,
        reference.isAcceptableOrUnknown(data['reference']!, _referenceMeta),
      );
    }
    if (data.containsKey('slip_media_client_id')) {
      context.handle(
        _slipMediaClientIdMeta,
        slipMediaClientId.isAcceptableOrUnknown(
          data['slip_media_client_id']!,
          _slipMediaClientIdMeta,
        ),
      );
    }
    if (data.containsKey('deposited_at')) {
      context.handle(
        _depositedAtMeta,
        depositedAt.isAcceptableOrUnknown(
          data['deposited_at']!,
          _depositedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_depositedAtMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('reject_reason')) {
      context.handle(
        _rejectReasonMeta,
        rejectReason.isAcceptableOrUnknown(
          data['reject_reason']!,
          _rejectReasonMeta,
        ),
      );
    }
    if (data.containsKey('sync_state')) {
      context.handle(
        _syncStateMeta,
        syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {clientId};
  @override
  DepositRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DepositRow(
      clientId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}client_id'],
      )!,
      serverId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}server_id'],
      ),
      amountPoisha: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_poisha'],
      )!,
      destination: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}destination'],
      )!,
      reference: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reference'],
      ),
      slipMediaClientId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}slip_media_client_id'],
      ),
      depositedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deposited_at'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      rejectReason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reject_reason'],
      ),
      syncState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_state'],
      )!,
    );
  }

  @override
  $DepositsTable createAlias(String alias) {
    return $DepositsTable(attachedDatabase, alias);
  }
}

class DepositRow extends DataClass implements Insertable<DepositRow> {
  final String clientId;
  final String? serverId;
  final int amountPoisha;
  final String destination;
  final String? reference;
  final String? slipMediaClientId;
  final DateTime depositedAt;
  final String status;
  final String? rejectReason;
  final String syncState;
  const DepositRow({
    required this.clientId,
    this.serverId,
    required this.amountPoisha,
    required this.destination,
    this.reference,
    this.slipMediaClientId,
    required this.depositedAt,
    required this.status,
    this.rejectReason,
    required this.syncState,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['client_id'] = Variable<String>(clientId);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<String>(serverId);
    }
    map['amount_poisha'] = Variable<int>(amountPoisha);
    map['destination'] = Variable<String>(destination);
    if (!nullToAbsent || reference != null) {
      map['reference'] = Variable<String>(reference);
    }
    if (!nullToAbsent || slipMediaClientId != null) {
      map['slip_media_client_id'] = Variable<String>(slipMediaClientId);
    }
    map['deposited_at'] = Variable<DateTime>(depositedAt);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || rejectReason != null) {
      map['reject_reason'] = Variable<String>(rejectReason);
    }
    map['sync_state'] = Variable<String>(syncState);
    return map;
  }

  DepositsCompanion toCompanion(bool nullToAbsent) {
    return DepositsCompanion(
      clientId: Value(clientId),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      amountPoisha: Value(amountPoisha),
      destination: Value(destination),
      reference: reference == null && nullToAbsent
          ? const Value.absent()
          : Value(reference),
      slipMediaClientId: slipMediaClientId == null && nullToAbsent
          ? const Value.absent()
          : Value(slipMediaClientId),
      depositedAt: Value(depositedAt),
      status: Value(status),
      rejectReason: rejectReason == null && nullToAbsent
          ? const Value.absent()
          : Value(rejectReason),
      syncState: Value(syncState),
    );
  }

  factory DepositRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DepositRow(
      clientId: serializer.fromJson<String>(json['clientId']),
      serverId: serializer.fromJson<String?>(json['serverId']),
      amountPoisha: serializer.fromJson<int>(json['amountPoisha']),
      destination: serializer.fromJson<String>(json['destination']),
      reference: serializer.fromJson<String?>(json['reference']),
      slipMediaClientId: serializer.fromJson<String?>(
        json['slipMediaClientId'],
      ),
      depositedAt: serializer.fromJson<DateTime>(json['depositedAt']),
      status: serializer.fromJson<String>(json['status']),
      rejectReason: serializer.fromJson<String?>(json['rejectReason']),
      syncState: serializer.fromJson<String>(json['syncState']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'clientId': serializer.toJson<String>(clientId),
      'serverId': serializer.toJson<String?>(serverId),
      'amountPoisha': serializer.toJson<int>(amountPoisha),
      'destination': serializer.toJson<String>(destination),
      'reference': serializer.toJson<String?>(reference),
      'slipMediaClientId': serializer.toJson<String?>(slipMediaClientId),
      'depositedAt': serializer.toJson<DateTime>(depositedAt),
      'status': serializer.toJson<String>(status),
      'rejectReason': serializer.toJson<String?>(rejectReason),
      'syncState': serializer.toJson<String>(syncState),
    };
  }

  DepositRow copyWith({
    String? clientId,
    Value<String?> serverId = const Value.absent(),
    int? amountPoisha,
    String? destination,
    Value<String?> reference = const Value.absent(),
    Value<String?> slipMediaClientId = const Value.absent(),
    DateTime? depositedAt,
    String? status,
    Value<String?> rejectReason = const Value.absent(),
    String? syncState,
  }) => DepositRow(
    clientId: clientId ?? this.clientId,
    serverId: serverId.present ? serverId.value : this.serverId,
    amountPoisha: amountPoisha ?? this.amountPoisha,
    destination: destination ?? this.destination,
    reference: reference.present ? reference.value : this.reference,
    slipMediaClientId: slipMediaClientId.present
        ? slipMediaClientId.value
        : this.slipMediaClientId,
    depositedAt: depositedAt ?? this.depositedAt,
    status: status ?? this.status,
    rejectReason: rejectReason.present ? rejectReason.value : this.rejectReason,
    syncState: syncState ?? this.syncState,
  );
  DepositRow copyWithCompanion(DepositsCompanion data) {
    return DepositRow(
      clientId: data.clientId.present ? data.clientId.value : this.clientId,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      amountPoisha: data.amountPoisha.present
          ? data.amountPoisha.value
          : this.amountPoisha,
      destination: data.destination.present
          ? data.destination.value
          : this.destination,
      reference: data.reference.present ? data.reference.value : this.reference,
      slipMediaClientId: data.slipMediaClientId.present
          ? data.slipMediaClientId.value
          : this.slipMediaClientId,
      depositedAt: data.depositedAt.present
          ? data.depositedAt.value
          : this.depositedAt,
      status: data.status.present ? data.status.value : this.status,
      rejectReason: data.rejectReason.present
          ? data.rejectReason.value
          : this.rejectReason,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DepositRow(')
          ..write('clientId: $clientId, ')
          ..write('serverId: $serverId, ')
          ..write('amountPoisha: $amountPoisha, ')
          ..write('destination: $destination, ')
          ..write('reference: $reference, ')
          ..write('slipMediaClientId: $slipMediaClientId, ')
          ..write('depositedAt: $depositedAt, ')
          ..write('status: $status, ')
          ..write('rejectReason: $rejectReason, ')
          ..write('syncState: $syncState')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    clientId,
    serverId,
    amountPoisha,
    destination,
    reference,
    slipMediaClientId,
    depositedAt,
    status,
    rejectReason,
    syncState,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DepositRow &&
          other.clientId == this.clientId &&
          other.serverId == this.serverId &&
          other.amountPoisha == this.amountPoisha &&
          other.destination == this.destination &&
          other.reference == this.reference &&
          other.slipMediaClientId == this.slipMediaClientId &&
          other.depositedAt == this.depositedAt &&
          other.status == this.status &&
          other.rejectReason == this.rejectReason &&
          other.syncState == this.syncState);
}

class DepositsCompanion extends UpdateCompanion<DepositRow> {
  final Value<String> clientId;
  final Value<String?> serverId;
  final Value<int> amountPoisha;
  final Value<String> destination;
  final Value<String?> reference;
  final Value<String?> slipMediaClientId;
  final Value<DateTime> depositedAt;
  final Value<String> status;
  final Value<String?> rejectReason;
  final Value<String> syncState;
  final Value<int> rowid;
  const DepositsCompanion({
    this.clientId = const Value.absent(),
    this.serverId = const Value.absent(),
    this.amountPoisha = const Value.absent(),
    this.destination = const Value.absent(),
    this.reference = const Value.absent(),
    this.slipMediaClientId = const Value.absent(),
    this.depositedAt = const Value.absent(),
    this.status = const Value.absent(),
    this.rejectReason = const Value.absent(),
    this.syncState = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DepositsCompanion.insert({
    required String clientId,
    this.serverId = const Value.absent(),
    required int amountPoisha,
    required String destination,
    this.reference = const Value.absent(),
    this.slipMediaClientId = const Value.absent(),
    required DateTime depositedAt,
    this.status = const Value.absent(),
    this.rejectReason = const Value.absent(),
    this.syncState = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : clientId = Value(clientId),
       amountPoisha = Value(amountPoisha),
       destination = Value(destination),
       depositedAt = Value(depositedAt);
  static Insertable<DepositRow> custom({
    Expression<String>? clientId,
    Expression<String>? serverId,
    Expression<int>? amountPoisha,
    Expression<String>? destination,
    Expression<String>? reference,
    Expression<String>? slipMediaClientId,
    Expression<DateTime>? depositedAt,
    Expression<String>? status,
    Expression<String>? rejectReason,
    Expression<String>? syncState,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (clientId != null) 'client_id': clientId,
      if (serverId != null) 'server_id': serverId,
      if (amountPoisha != null) 'amount_poisha': amountPoisha,
      if (destination != null) 'destination': destination,
      if (reference != null) 'reference': reference,
      if (slipMediaClientId != null) 'slip_media_client_id': slipMediaClientId,
      if (depositedAt != null) 'deposited_at': depositedAt,
      if (status != null) 'status': status,
      if (rejectReason != null) 'reject_reason': rejectReason,
      if (syncState != null) 'sync_state': syncState,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DepositsCompanion copyWith({
    Value<String>? clientId,
    Value<String?>? serverId,
    Value<int>? amountPoisha,
    Value<String>? destination,
    Value<String?>? reference,
    Value<String?>? slipMediaClientId,
    Value<DateTime>? depositedAt,
    Value<String>? status,
    Value<String?>? rejectReason,
    Value<String>? syncState,
    Value<int>? rowid,
  }) {
    return DepositsCompanion(
      clientId: clientId ?? this.clientId,
      serverId: serverId ?? this.serverId,
      amountPoisha: amountPoisha ?? this.amountPoisha,
      destination: destination ?? this.destination,
      reference: reference ?? this.reference,
      slipMediaClientId: slipMediaClientId ?? this.slipMediaClientId,
      depositedAt: depositedAt ?? this.depositedAt,
      status: status ?? this.status,
      rejectReason: rejectReason ?? this.rejectReason,
      syncState: syncState ?? this.syncState,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (clientId.present) {
      map['client_id'] = Variable<String>(clientId.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<String>(serverId.value);
    }
    if (amountPoisha.present) {
      map['amount_poisha'] = Variable<int>(amountPoisha.value);
    }
    if (destination.present) {
      map['destination'] = Variable<String>(destination.value);
    }
    if (reference.present) {
      map['reference'] = Variable<String>(reference.value);
    }
    if (slipMediaClientId.present) {
      map['slip_media_client_id'] = Variable<String>(slipMediaClientId.value);
    }
    if (depositedAt.present) {
      map['deposited_at'] = Variable<DateTime>(depositedAt.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (rejectReason.present) {
      map['reject_reason'] = Variable<String>(rejectReason.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(syncState.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DepositsCompanion(')
          ..write('clientId: $clientId, ')
          ..write('serverId: $serverId, ')
          ..write('amountPoisha: $amountPoisha, ')
          ..write('destination: $destination, ')
          ..write('reference: $reference, ')
          ..write('slipMediaClientId: $slipMediaClientId, ')
          ..write('depositedAt: $depositedAt, ')
          ..write('status: $status, ')
          ..write('rejectReason: $rejectReason, ')
          ..write('syncState: $syncState, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CashClosingsTable extends CashClosings
    with TableInfo<$CashClosingsTable, CashClosingRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CashClosingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _businessDateMeta = const VerificationMeta(
    'businessDate',
  );
  @override
  late final GeneratedColumn<String> businessDate = GeneratedColumn<String>(
    'business_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cashPoishaMeta = const VerificationMeta(
    'cashPoisha',
  );
  @override
  late final GeneratedColumn<int> cashPoisha = GeneratedColumn<int>(
    'cash_poisha',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mobilePoishaMeta = const VerificationMeta(
    'mobilePoisha',
  );
  @override
  late final GeneratedColumn<int> mobilePoisha = GeneratedColumn<int>(
    'mobile_poisha',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _depositedPoishaMeta = const VerificationMeta(
    'depositedPoisha',
  );
  @override
  late final GeneratedColumn<int> depositedPoisha = GeneratedColumn<int>(
    'deposited_poisha',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _onHandPoishaMeta = const VerificationMeta(
    'onHandPoisha',
  );
  @override
  late final GeneratedColumn<int> onHandPoisha = GeneratedColumn<int>(
    'on_hand_poisha',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _confirmedAtMeta = const VerificationMeta(
    'confirmedAt',
  );
  @override
  late final GeneratedColumn<DateTime> confirmedAt = GeneratedColumn<DateTime>(
    'confirmed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncStateMeta = const VerificationMeta(
    'syncState',
  );
  @override
  late final GeneratedColumn<String> syncState = GeneratedColumn<String>(
    'sync_state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('queued'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    businessDate,
    cashPoisha,
    mobilePoisha,
    depositedPoisha,
    onHandPoisha,
    confirmedAt,
    syncState,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cash_closings';
  @override
  VerificationContext validateIntegrity(
    Insertable<CashClosingRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('business_date')) {
      context.handle(
        _businessDateMeta,
        businessDate.isAcceptableOrUnknown(
          data['business_date']!,
          _businessDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_businessDateMeta);
    }
    if (data.containsKey('cash_poisha')) {
      context.handle(
        _cashPoishaMeta,
        cashPoisha.isAcceptableOrUnknown(data['cash_poisha']!, _cashPoishaMeta),
      );
    } else if (isInserting) {
      context.missing(_cashPoishaMeta);
    }
    if (data.containsKey('mobile_poisha')) {
      context.handle(
        _mobilePoishaMeta,
        mobilePoisha.isAcceptableOrUnknown(
          data['mobile_poisha']!,
          _mobilePoishaMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_mobilePoishaMeta);
    }
    if (data.containsKey('deposited_poisha')) {
      context.handle(
        _depositedPoishaMeta,
        depositedPoisha.isAcceptableOrUnknown(
          data['deposited_poisha']!,
          _depositedPoishaMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_depositedPoishaMeta);
    }
    if (data.containsKey('on_hand_poisha')) {
      context.handle(
        _onHandPoishaMeta,
        onHandPoisha.isAcceptableOrUnknown(
          data['on_hand_poisha']!,
          _onHandPoishaMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_onHandPoishaMeta);
    }
    if (data.containsKey('confirmed_at')) {
      context.handle(
        _confirmedAtMeta,
        confirmedAt.isAcceptableOrUnknown(
          data['confirmed_at']!,
          _confirmedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_confirmedAtMeta);
    }
    if (data.containsKey('sync_state')) {
      context.handle(
        _syncStateMeta,
        syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {businessDate};
  @override
  CashClosingRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CashClosingRow(
      businessDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}business_date'],
      )!,
      cashPoisha: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cash_poisha'],
      )!,
      mobilePoisha: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}mobile_poisha'],
      )!,
      depositedPoisha: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deposited_poisha'],
      )!,
      onHandPoisha: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}on_hand_poisha'],
      )!,
      confirmedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}confirmed_at'],
      )!,
      syncState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_state'],
      )!,
    );
  }

  @override
  $CashClosingsTable createAlias(String alias) {
    return $CashClosingsTable(attachedDatabase, alias);
  }
}

class CashClosingRow extends DataClass implements Insertable<CashClosingRow> {
  final String businessDate;
  final int cashPoisha;
  final int mobilePoisha;
  final int depositedPoisha;
  final int onHandPoisha;
  final DateTime confirmedAt;
  final String syncState;
  const CashClosingRow({
    required this.businessDate,
    required this.cashPoisha,
    required this.mobilePoisha,
    required this.depositedPoisha,
    required this.onHandPoisha,
    required this.confirmedAt,
    required this.syncState,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['business_date'] = Variable<String>(businessDate);
    map['cash_poisha'] = Variable<int>(cashPoisha);
    map['mobile_poisha'] = Variable<int>(mobilePoisha);
    map['deposited_poisha'] = Variable<int>(depositedPoisha);
    map['on_hand_poisha'] = Variable<int>(onHandPoisha);
    map['confirmed_at'] = Variable<DateTime>(confirmedAt);
    map['sync_state'] = Variable<String>(syncState);
    return map;
  }

  CashClosingsCompanion toCompanion(bool nullToAbsent) {
    return CashClosingsCompanion(
      businessDate: Value(businessDate),
      cashPoisha: Value(cashPoisha),
      mobilePoisha: Value(mobilePoisha),
      depositedPoisha: Value(depositedPoisha),
      onHandPoisha: Value(onHandPoisha),
      confirmedAt: Value(confirmedAt),
      syncState: Value(syncState),
    );
  }

  factory CashClosingRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CashClosingRow(
      businessDate: serializer.fromJson<String>(json['businessDate']),
      cashPoisha: serializer.fromJson<int>(json['cashPoisha']),
      mobilePoisha: serializer.fromJson<int>(json['mobilePoisha']),
      depositedPoisha: serializer.fromJson<int>(json['depositedPoisha']),
      onHandPoisha: serializer.fromJson<int>(json['onHandPoisha']),
      confirmedAt: serializer.fromJson<DateTime>(json['confirmedAt']),
      syncState: serializer.fromJson<String>(json['syncState']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'businessDate': serializer.toJson<String>(businessDate),
      'cashPoisha': serializer.toJson<int>(cashPoisha),
      'mobilePoisha': serializer.toJson<int>(mobilePoisha),
      'depositedPoisha': serializer.toJson<int>(depositedPoisha),
      'onHandPoisha': serializer.toJson<int>(onHandPoisha),
      'confirmedAt': serializer.toJson<DateTime>(confirmedAt),
      'syncState': serializer.toJson<String>(syncState),
    };
  }

  CashClosingRow copyWith({
    String? businessDate,
    int? cashPoisha,
    int? mobilePoisha,
    int? depositedPoisha,
    int? onHandPoisha,
    DateTime? confirmedAt,
    String? syncState,
  }) => CashClosingRow(
    businessDate: businessDate ?? this.businessDate,
    cashPoisha: cashPoisha ?? this.cashPoisha,
    mobilePoisha: mobilePoisha ?? this.mobilePoisha,
    depositedPoisha: depositedPoisha ?? this.depositedPoisha,
    onHandPoisha: onHandPoisha ?? this.onHandPoisha,
    confirmedAt: confirmedAt ?? this.confirmedAt,
    syncState: syncState ?? this.syncState,
  );
  CashClosingRow copyWithCompanion(CashClosingsCompanion data) {
    return CashClosingRow(
      businessDate: data.businessDate.present
          ? data.businessDate.value
          : this.businessDate,
      cashPoisha: data.cashPoisha.present
          ? data.cashPoisha.value
          : this.cashPoisha,
      mobilePoisha: data.mobilePoisha.present
          ? data.mobilePoisha.value
          : this.mobilePoisha,
      depositedPoisha: data.depositedPoisha.present
          ? data.depositedPoisha.value
          : this.depositedPoisha,
      onHandPoisha: data.onHandPoisha.present
          ? data.onHandPoisha.value
          : this.onHandPoisha,
      confirmedAt: data.confirmedAt.present
          ? data.confirmedAt.value
          : this.confirmedAt,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CashClosingRow(')
          ..write('businessDate: $businessDate, ')
          ..write('cashPoisha: $cashPoisha, ')
          ..write('mobilePoisha: $mobilePoisha, ')
          ..write('depositedPoisha: $depositedPoisha, ')
          ..write('onHandPoisha: $onHandPoisha, ')
          ..write('confirmedAt: $confirmedAt, ')
          ..write('syncState: $syncState')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    businessDate,
    cashPoisha,
    mobilePoisha,
    depositedPoisha,
    onHandPoisha,
    confirmedAt,
    syncState,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CashClosingRow &&
          other.businessDate == this.businessDate &&
          other.cashPoisha == this.cashPoisha &&
          other.mobilePoisha == this.mobilePoisha &&
          other.depositedPoisha == this.depositedPoisha &&
          other.onHandPoisha == this.onHandPoisha &&
          other.confirmedAt == this.confirmedAt &&
          other.syncState == this.syncState);
}

class CashClosingsCompanion extends UpdateCompanion<CashClosingRow> {
  final Value<String> businessDate;
  final Value<int> cashPoisha;
  final Value<int> mobilePoisha;
  final Value<int> depositedPoisha;
  final Value<int> onHandPoisha;
  final Value<DateTime> confirmedAt;
  final Value<String> syncState;
  final Value<int> rowid;
  const CashClosingsCompanion({
    this.businessDate = const Value.absent(),
    this.cashPoisha = const Value.absent(),
    this.mobilePoisha = const Value.absent(),
    this.depositedPoisha = const Value.absent(),
    this.onHandPoisha = const Value.absent(),
    this.confirmedAt = const Value.absent(),
    this.syncState = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CashClosingsCompanion.insert({
    required String businessDate,
    required int cashPoisha,
    required int mobilePoisha,
    required int depositedPoisha,
    required int onHandPoisha,
    required DateTime confirmedAt,
    this.syncState = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : businessDate = Value(businessDate),
       cashPoisha = Value(cashPoisha),
       mobilePoisha = Value(mobilePoisha),
       depositedPoisha = Value(depositedPoisha),
       onHandPoisha = Value(onHandPoisha),
       confirmedAt = Value(confirmedAt);
  static Insertable<CashClosingRow> custom({
    Expression<String>? businessDate,
    Expression<int>? cashPoisha,
    Expression<int>? mobilePoisha,
    Expression<int>? depositedPoisha,
    Expression<int>? onHandPoisha,
    Expression<DateTime>? confirmedAt,
    Expression<String>? syncState,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (businessDate != null) 'business_date': businessDate,
      if (cashPoisha != null) 'cash_poisha': cashPoisha,
      if (mobilePoisha != null) 'mobile_poisha': mobilePoisha,
      if (depositedPoisha != null) 'deposited_poisha': depositedPoisha,
      if (onHandPoisha != null) 'on_hand_poisha': onHandPoisha,
      if (confirmedAt != null) 'confirmed_at': confirmedAt,
      if (syncState != null) 'sync_state': syncState,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CashClosingsCompanion copyWith({
    Value<String>? businessDate,
    Value<int>? cashPoisha,
    Value<int>? mobilePoisha,
    Value<int>? depositedPoisha,
    Value<int>? onHandPoisha,
    Value<DateTime>? confirmedAt,
    Value<String>? syncState,
    Value<int>? rowid,
  }) {
    return CashClosingsCompanion(
      businessDate: businessDate ?? this.businessDate,
      cashPoisha: cashPoisha ?? this.cashPoisha,
      mobilePoisha: mobilePoisha ?? this.mobilePoisha,
      depositedPoisha: depositedPoisha ?? this.depositedPoisha,
      onHandPoisha: onHandPoisha ?? this.onHandPoisha,
      confirmedAt: confirmedAt ?? this.confirmedAt,
      syncState: syncState ?? this.syncState,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (businessDate.present) {
      map['business_date'] = Variable<String>(businessDate.value);
    }
    if (cashPoisha.present) {
      map['cash_poisha'] = Variable<int>(cashPoisha.value);
    }
    if (mobilePoisha.present) {
      map['mobile_poisha'] = Variable<int>(mobilePoisha.value);
    }
    if (depositedPoisha.present) {
      map['deposited_poisha'] = Variable<int>(depositedPoisha.value);
    }
    if (onHandPoisha.present) {
      map['on_hand_poisha'] = Variable<int>(onHandPoisha.value);
    }
    if (confirmedAt.present) {
      map['confirmed_at'] = Variable<DateTime>(confirmedAt.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(syncState.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CashClosingsCompanion(')
          ..write('businessDate: $businessDate, ')
          ..write('cashPoisha: $cashPoisha, ')
          ..write('mobilePoisha: $mobilePoisha, ')
          ..write('depositedPoisha: $depositedPoisha, ')
          ..write('onHandPoisha: $onHandPoisha, ')
          ..write('confirmedAt: $confirmedAt, ')
          ..write('syncState: $syncState, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $VisitsTable extends Visits with TableInfo<$VisitsTable, VisitRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VisitsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _clientIdMeta = const VerificationMeta(
    'clientId',
  );
  @override
  late final GeneratedColumn<String> clientId = GeneratedColumn<String>(
    'client_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _serverIdMeta = const VerificationMeta(
    'serverId',
  );
  @override
  late final GeneratedColumn<String> serverId = GeneratedColumn<String>(
    'server_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _customerIdMeta = const VerificationMeta(
    'customerId',
  );
  @override
  late final GeneratedColumn<String> customerId = GeneratedColumn<String>(
    'customer_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userNameMeta = const VerificationMeta(
    'userName',
  );
  @override
  late final GeneratedColumn<String> userName = GeneratedColumn<String>(
    'user_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _checkInAtMeta = const VerificationMeta(
    'checkInAt',
  );
  @override
  late final GeneratedColumn<DateTime> checkInAt = GeneratedColumn<DateTime>(
    'check_in_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _checkOutAtMeta = const VerificationMeta(
    'checkOutAt',
  );
  @override
  late final GeneratedColumn<DateTime> checkOutAt = GeneratedColumn<DateTime>(
    'check_out_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _outcomeMeta = const VerificationMeta(
    'outcome',
  );
  @override
  late final GeneratedColumn<String> outcome = GeneratedColumn<String>(
    'outcome',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _latMeta = const VerificationMeta('lat');
  @override
  late final GeneratedColumn<double> lat = GeneratedColumn<double>(
    'lat',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lngMeta = const VerificationMeta('lng');
  @override
  late final GeneratedColumn<double> lng = GeneratedColumn<double>(
    'lng',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _accuracyMMeta = const VerificationMeta(
    'accuracyM',
  );
  @override
  late final GeneratedColumn<double> accuracyM = GeneratedColumn<double>(
    'accuracy_m',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _mockMeta = const VerificationMeta('mock');
  @override
  late final GeneratedColumn<bool> mock = GeneratedColumn<bool>(
    'mock',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("mock" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _distanceToPinMMeta = const VerificationMeta(
    'distanceToPinM',
  );
  @override
  late final GeneratedColumn<int> distanceToPinM = GeneratedColumn<int>(
    'distance_to_pin_m',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _photoMediaClientIdsJsonMeta =
      const VerificationMeta('photoMediaClientIdsJson');
  @override
  late final GeneratedColumn<String> photoMediaClientIdsJson =
      GeneratedColumn<String>(
        'photo_media_client_ids_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('[]'),
      );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('manual'),
  );
  static const VerificationMeta _syncStateMeta = const VerificationMeta(
    'syncState',
  );
  @override
  late final GeneratedColumn<String> syncState = GeneratedColumn<String>(
    'sync_state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('queued'),
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _coWorkSessionIdMeta = const VerificationMeta(
    'coWorkSessionId',
  );
  @override
  late final GeneratedColumn<String> coWorkSessionId = GeneratedColumn<String>(
    'co_work_session_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _coWorkParticipantIdsJsonMeta =
      const VerificationMeta('coWorkParticipantIdsJson');
  @override
  late final GeneratedColumn<String> coWorkParticipantIdsJson =
      GeneratedColumn<String>(
        'co_work_participant_ids_json',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    clientId,
    serverId,
    customerId,
    userName,
    checkInAt,
    checkOutAt,
    outcome,
    lat,
    lng,
    accuracyM,
    mock,
    distanceToPinM,
    photoMediaClientIdsJson,
    note,
    source,
    syncState,
    userId,
    coWorkSessionId,
    coWorkParticipantIdsJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'visits';
  @override
  VerificationContext validateIntegrity(
    Insertable<VisitRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('client_id')) {
      context.handle(
        _clientIdMeta,
        clientId.isAcceptableOrUnknown(data['client_id']!, _clientIdMeta),
      );
    } else if (isInserting) {
      context.missing(_clientIdMeta);
    }
    if (data.containsKey('server_id')) {
      context.handle(
        _serverIdMeta,
        serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta),
      );
    }
    if (data.containsKey('customer_id')) {
      context.handle(
        _customerIdMeta,
        customerId.isAcceptableOrUnknown(data['customer_id']!, _customerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_customerIdMeta);
    }
    if (data.containsKey('user_name')) {
      context.handle(
        _userNameMeta,
        userName.isAcceptableOrUnknown(data['user_name']!, _userNameMeta),
      );
    }
    if (data.containsKey('check_in_at')) {
      context.handle(
        _checkInAtMeta,
        checkInAt.isAcceptableOrUnknown(data['check_in_at']!, _checkInAtMeta),
      );
    } else if (isInserting) {
      context.missing(_checkInAtMeta);
    }
    if (data.containsKey('check_out_at')) {
      context.handle(
        _checkOutAtMeta,
        checkOutAt.isAcceptableOrUnknown(
          data['check_out_at']!,
          _checkOutAtMeta,
        ),
      );
    }
    if (data.containsKey('outcome')) {
      context.handle(
        _outcomeMeta,
        outcome.isAcceptableOrUnknown(data['outcome']!, _outcomeMeta),
      );
    } else if (isInserting) {
      context.missing(_outcomeMeta);
    }
    if (data.containsKey('lat')) {
      context.handle(
        _latMeta,
        lat.isAcceptableOrUnknown(data['lat']!, _latMeta),
      );
    }
    if (data.containsKey('lng')) {
      context.handle(
        _lngMeta,
        lng.isAcceptableOrUnknown(data['lng']!, _lngMeta),
      );
    }
    if (data.containsKey('accuracy_m')) {
      context.handle(
        _accuracyMMeta,
        accuracyM.isAcceptableOrUnknown(data['accuracy_m']!, _accuracyMMeta),
      );
    }
    if (data.containsKey('mock')) {
      context.handle(
        _mockMeta,
        mock.isAcceptableOrUnknown(data['mock']!, _mockMeta),
      );
    }
    if (data.containsKey('distance_to_pin_m')) {
      context.handle(
        _distanceToPinMMeta,
        distanceToPinM.isAcceptableOrUnknown(
          data['distance_to_pin_m']!,
          _distanceToPinMMeta,
        ),
      );
    }
    if (data.containsKey('photo_media_client_ids_json')) {
      context.handle(
        _photoMediaClientIdsJsonMeta,
        photoMediaClientIdsJson.isAcceptableOrUnknown(
          data['photo_media_client_ids_json']!,
          _photoMediaClientIdsJsonMeta,
        ),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    }
    if (data.containsKey('sync_state')) {
      context.handle(
        _syncStateMeta,
        syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta),
      );
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    }
    if (data.containsKey('co_work_session_id')) {
      context.handle(
        _coWorkSessionIdMeta,
        coWorkSessionId.isAcceptableOrUnknown(
          data['co_work_session_id']!,
          _coWorkSessionIdMeta,
        ),
      );
    }
    if (data.containsKey('co_work_participant_ids_json')) {
      context.handle(
        _coWorkParticipantIdsJsonMeta,
        coWorkParticipantIdsJson.isAcceptableOrUnknown(
          data['co_work_participant_ids_json']!,
          _coWorkParticipantIdsJsonMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {clientId};
  @override
  VisitRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VisitRow(
      clientId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}client_id'],
      )!,
      serverId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}server_id'],
      ),
      customerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}customer_id'],
      )!,
      userName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_name'],
      ),
      checkInAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}check_in_at'],
      )!,
      checkOutAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}check_out_at'],
      ),
      outcome: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}outcome'],
      )!,
      lat: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}lat'],
      ),
      lng: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}lng'],
      ),
      accuracyM: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}accuracy_m'],
      ),
      mock: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}mock'],
      )!,
      distanceToPinM: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}distance_to_pin_m'],
      ),
      photoMediaClientIdsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}photo_media_client_ids_json'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      syncState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_state'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      ),
      coWorkSessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}co_work_session_id'],
      ),
      coWorkParticipantIdsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}co_work_participant_ids_json'],
      ),
    );
  }

  @override
  $VisitsTable createAlias(String alias) {
    return $VisitsTable(attachedDatabase, alias);
  }
}

class VisitRow extends DataClass implements Insertable<VisitRow> {
  final String clientId;
  final String? serverId;
  final String customerId;
  final String? userName;
  final DateTime checkInAt;
  final DateTime? checkOutAt;
  final String outcome;
  final double? lat;
  final double? lng;
  final double? accuracyM;
  final bool mock;
  final int? distanceToPinM;
  final String photoMediaClientIdsJson;
  final String? note;
  final String source;
  final String syncState;

  /// Recorder's user id from the server; null = recorded on this phone (v4).
  final String? userId;

  /// Co-work session the visit was made in (v4, contract 1.9.0). Set at save
  /// time by the recorder; cleared when the server could not confirm it
  /// (flag `cowork_invalid`).
  final String? coWorkSessionId;

  /// Partners (user ids, without the recorder): our estimate at save time,
  /// replaced by the server's `coWork.participantIds` on pull (v4).
  final String? coWorkParticipantIdsJson;
  const VisitRow({
    required this.clientId,
    this.serverId,
    required this.customerId,
    this.userName,
    required this.checkInAt,
    this.checkOutAt,
    required this.outcome,
    this.lat,
    this.lng,
    this.accuracyM,
    required this.mock,
    this.distanceToPinM,
    required this.photoMediaClientIdsJson,
    this.note,
    required this.source,
    required this.syncState,
    this.userId,
    this.coWorkSessionId,
    this.coWorkParticipantIdsJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['client_id'] = Variable<String>(clientId);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<String>(serverId);
    }
    map['customer_id'] = Variable<String>(customerId);
    if (!nullToAbsent || userName != null) {
      map['user_name'] = Variable<String>(userName);
    }
    map['check_in_at'] = Variable<DateTime>(checkInAt);
    if (!nullToAbsent || checkOutAt != null) {
      map['check_out_at'] = Variable<DateTime>(checkOutAt);
    }
    map['outcome'] = Variable<String>(outcome);
    if (!nullToAbsent || lat != null) {
      map['lat'] = Variable<double>(lat);
    }
    if (!nullToAbsent || lng != null) {
      map['lng'] = Variable<double>(lng);
    }
    if (!nullToAbsent || accuracyM != null) {
      map['accuracy_m'] = Variable<double>(accuracyM);
    }
    map['mock'] = Variable<bool>(mock);
    if (!nullToAbsent || distanceToPinM != null) {
      map['distance_to_pin_m'] = Variable<int>(distanceToPinM);
    }
    map['photo_media_client_ids_json'] = Variable<String>(
      photoMediaClientIdsJson,
    );
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['source'] = Variable<String>(source);
    map['sync_state'] = Variable<String>(syncState);
    if (!nullToAbsent || userId != null) {
      map['user_id'] = Variable<String>(userId);
    }
    if (!nullToAbsent || coWorkSessionId != null) {
      map['co_work_session_id'] = Variable<String>(coWorkSessionId);
    }
    if (!nullToAbsent || coWorkParticipantIdsJson != null) {
      map['co_work_participant_ids_json'] = Variable<String>(
        coWorkParticipantIdsJson,
      );
    }
    return map;
  }

  VisitsCompanion toCompanion(bool nullToAbsent) {
    return VisitsCompanion(
      clientId: Value(clientId),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      customerId: Value(customerId),
      userName: userName == null && nullToAbsent
          ? const Value.absent()
          : Value(userName),
      checkInAt: Value(checkInAt),
      checkOutAt: checkOutAt == null && nullToAbsent
          ? const Value.absent()
          : Value(checkOutAt),
      outcome: Value(outcome),
      lat: lat == null && nullToAbsent ? const Value.absent() : Value(lat),
      lng: lng == null && nullToAbsent ? const Value.absent() : Value(lng),
      accuracyM: accuracyM == null && nullToAbsent
          ? const Value.absent()
          : Value(accuracyM),
      mock: Value(mock),
      distanceToPinM: distanceToPinM == null && nullToAbsent
          ? const Value.absent()
          : Value(distanceToPinM),
      photoMediaClientIdsJson: Value(photoMediaClientIdsJson),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      source: Value(source),
      syncState: Value(syncState),
      userId: userId == null && nullToAbsent
          ? const Value.absent()
          : Value(userId),
      coWorkSessionId: coWorkSessionId == null && nullToAbsent
          ? const Value.absent()
          : Value(coWorkSessionId),
      coWorkParticipantIdsJson: coWorkParticipantIdsJson == null && nullToAbsent
          ? const Value.absent()
          : Value(coWorkParticipantIdsJson),
    );
  }

  factory VisitRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VisitRow(
      clientId: serializer.fromJson<String>(json['clientId']),
      serverId: serializer.fromJson<String?>(json['serverId']),
      customerId: serializer.fromJson<String>(json['customerId']),
      userName: serializer.fromJson<String?>(json['userName']),
      checkInAt: serializer.fromJson<DateTime>(json['checkInAt']),
      checkOutAt: serializer.fromJson<DateTime?>(json['checkOutAt']),
      outcome: serializer.fromJson<String>(json['outcome']),
      lat: serializer.fromJson<double?>(json['lat']),
      lng: serializer.fromJson<double?>(json['lng']),
      accuracyM: serializer.fromJson<double?>(json['accuracyM']),
      mock: serializer.fromJson<bool>(json['mock']),
      distanceToPinM: serializer.fromJson<int?>(json['distanceToPinM']),
      photoMediaClientIdsJson: serializer.fromJson<String>(
        json['photoMediaClientIdsJson'],
      ),
      note: serializer.fromJson<String?>(json['note']),
      source: serializer.fromJson<String>(json['source']),
      syncState: serializer.fromJson<String>(json['syncState']),
      userId: serializer.fromJson<String?>(json['userId']),
      coWorkSessionId: serializer.fromJson<String?>(json['coWorkSessionId']),
      coWorkParticipantIdsJson: serializer.fromJson<String?>(
        json['coWorkParticipantIdsJson'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'clientId': serializer.toJson<String>(clientId),
      'serverId': serializer.toJson<String?>(serverId),
      'customerId': serializer.toJson<String>(customerId),
      'userName': serializer.toJson<String?>(userName),
      'checkInAt': serializer.toJson<DateTime>(checkInAt),
      'checkOutAt': serializer.toJson<DateTime?>(checkOutAt),
      'outcome': serializer.toJson<String>(outcome),
      'lat': serializer.toJson<double?>(lat),
      'lng': serializer.toJson<double?>(lng),
      'accuracyM': serializer.toJson<double?>(accuracyM),
      'mock': serializer.toJson<bool>(mock),
      'distanceToPinM': serializer.toJson<int?>(distanceToPinM),
      'photoMediaClientIdsJson': serializer.toJson<String>(
        photoMediaClientIdsJson,
      ),
      'note': serializer.toJson<String?>(note),
      'source': serializer.toJson<String>(source),
      'syncState': serializer.toJson<String>(syncState),
      'userId': serializer.toJson<String?>(userId),
      'coWorkSessionId': serializer.toJson<String?>(coWorkSessionId),
      'coWorkParticipantIdsJson': serializer.toJson<String?>(
        coWorkParticipantIdsJson,
      ),
    };
  }

  VisitRow copyWith({
    String? clientId,
    Value<String?> serverId = const Value.absent(),
    String? customerId,
    Value<String?> userName = const Value.absent(),
    DateTime? checkInAt,
    Value<DateTime?> checkOutAt = const Value.absent(),
    String? outcome,
    Value<double?> lat = const Value.absent(),
    Value<double?> lng = const Value.absent(),
    Value<double?> accuracyM = const Value.absent(),
    bool? mock,
    Value<int?> distanceToPinM = const Value.absent(),
    String? photoMediaClientIdsJson,
    Value<String?> note = const Value.absent(),
    String? source,
    String? syncState,
    Value<String?> userId = const Value.absent(),
    Value<String?> coWorkSessionId = const Value.absent(),
    Value<String?> coWorkParticipantIdsJson = const Value.absent(),
  }) => VisitRow(
    clientId: clientId ?? this.clientId,
    serverId: serverId.present ? serverId.value : this.serverId,
    customerId: customerId ?? this.customerId,
    userName: userName.present ? userName.value : this.userName,
    checkInAt: checkInAt ?? this.checkInAt,
    checkOutAt: checkOutAt.present ? checkOutAt.value : this.checkOutAt,
    outcome: outcome ?? this.outcome,
    lat: lat.present ? lat.value : this.lat,
    lng: lng.present ? lng.value : this.lng,
    accuracyM: accuracyM.present ? accuracyM.value : this.accuracyM,
    mock: mock ?? this.mock,
    distanceToPinM: distanceToPinM.present
        ? distanceToPinM.value
        : this.distanceToPinM,
    photoMediaClientIdsJson:
        photoMediaClientIdsJson ?? this.photoMediaClientIdsJson,
    note: note.present ? note.value : this.note,
    source: source ?? this.source,
    syncState: syncState ?? this.syncState,
    userId: userId.present ? userId.value : this.userId,
    coWorkSessionId: coWorkSessionId.present
        ? coWorkSessionId.value
        : this.coWorkSessionId,
    coWorkParticipantIdsJson: coWorkParticipantIdsJson.present
        ? coWorkParticipantIdsJson.value
        : this.coWorkParticipantIdsJson,
  );
  VisitRow copyWithCompanion(VisitsCompanion data) {
    return VisitRow(
      clientId: data.clientId.present ? data.clientId.value : this.clientId,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      customerId: data.customerId.present
          ? data.customerId.value
          : this.customerId,
      userName: data.userName.present ? data.userName.value : this.userName,
      checkInAt: data.checkInAt.present ? data.checkInAt.value : this.checkInAt,
      checkOutAt: data.checkOutAt.present
          ? data.checkOutAt.value
          : this.checkOutAt,
      outcome: data.outcome.present ? data.outcome.value : this.outcome,
      lat: data.lat.present ? data.lat.value : this.lat,
      lng: data.lng.present ? data.lng.value : this.lng,
      accuracyM: data.accuracyM.present ? data.accuracyM.value : this.accuracyM,
      mock: data.mock.present ? data.mock.value : this.mock,
      distanceToPinM: data.distanceToPinM.present
          ? data.distanceToPinM.value
          : this.distanceToPinM,
      photoMediaClientIdsJson: data.photoMediaClientIdsJson.present
          ? data.photoMediaClientIdsJson.value
          : this.photoMediaClientIdsJson,
      note: data.note.present ? data.note.value : this.note,
      source: data.source.present ? data.source.value : this.source,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
      userId: data.userId.present ? data.userId.value : this.userId,
      coWorkSessionId: data.coWorkSessionId.present
          ? data.coWorkSessionId.value
          : this.coWorkSessionId,
      coWorkParticipantIdsJson: data.coWorkParticipantIdsJson.present
          ? data.coWorkParticipantIdsJson.value
          : this.coWorkParticipantIdsJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VisitRow(')
          ..write('clientId: $clientId, ')
          ..write('serverId: $serverId, ')
          ..write('customerId: $customerId, ')
          ..write('userName: $userName, ')
          ..write('checkInAt: $checkInAt, ')
          ..write('checkOutAt: $checkOutAt, ')
          ..write('outcome: $outcome, ')
          ..write('lat: $lat, ')
          ..write('lng: $lng, ')
          ..write('accuracyM: $accuracyM, ')
          ..write('mock: $mock, ')
          ..write('distanceToPinM: $distanceToPinM, ')
          ..write('photoMediaClientIdsJson: $photoMediaClientIdsJson, ')
          ..write('note: $note, ')
          ..write('source: $source, ')
          ..write('syncState: $syncState, ')
          ..write('userId: $userId, ')
          ..write('coWorkSessionId: $coWorkSessionId, ')
          ..write('coWorkParticipantIdsJson: $coWorkParticipantIdsJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    clientId,
    serverId,
    customerId,
    userName,
    checkInAt,
    checkOutAt,
    outcome,
    lat,
    lng,
    accuracyM,
    mock,
    distanceToPinM,
    photoMediaClientIdsJson,
    note,
    source,
    syncState,
    userId,
    coWorkSessionId,
    coWorkParticipantIdsJson,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VisitRow &&
          other.clientId == this.clientId &&
          other.serverId == this.serverId &&
          other.customerId == this.customerId &&
          other.userName == this.userName &&
          other.checkInAt == this.checkInAt &&
          other.checkOutAt == this.checkOutAt &&
          other.outcome == this.outcome &&
          other.lat == this.lat &&
          other.lng == this.lng &&
          other.accuracyM == this.accuracyM &&
          other.mock == this.mock &&
          other.distanceToPinM == this.distanceToPinM &&
          other.photoMediaClientIdsJson == this.photoMediaClientIdsJson &&
          other.note == this.note &&
          other.source == this.source &&
          other.syncState == this.syncState &&
          other.userId == this.userId &&
          other.coWorkSessionId == this.coWorkSessionId &&
          other.coWorkParticipantIdsJson == this.coWorkParticipantIdsJson);
}

class VisitsCompanion extends UpdateCompanion<VisitRow> {
  final Value<String> clientId;
  final Value<String?> serverId;
  final Value<String> customerId;
  final Value<String?> userName;
  final Value<DateTime> checkInAt;
  final Value<DateTime?> checkOutAt;
  final Value<String> outcome;
  final Value<double?> lat;
  final Value<double?> lng;
  final Value<double?> accuracyM;
  final Value<bool> mock;
  final Value<int?> distanceToPinM;
  final Value<String> photoMediaClientIdsJson;
  final Value<String?> note;
  final Value<String> source;
  final Value<String> syncState;
  final Value<String?> userId;
  final Value<String?> coWorkSessionId;
  final Value<String?> coWorkParticipantIdsJson;
  final Value<int> rowid;
  const VisitsCompanion({
    this.clientId = const Value.absent(),
    this.serverId = const Value.absent(),
    this.customerId = const Value.absent(),
    this.userName = const Value.absent(),
    this.checkInAt = const Value.absent(),
    this.checkOutAt = const Value.absent(),
    this.outcome = const Value.absent(),
    this.lat = const Value.absent(),
    this.lng = const Value.absent(),
    this.accuracyM = const Value.absent(),
    this.mock = const Value.absent(),
    this.distanceToPinM = const Value.absent(),
    this.photoMediaClientIdsJson = const Value.absent(),
    this.note = const Value.absent(),
    this.source = const Value.absent(),
    this.syncState = const Value.absent(),
    this.userId = const Value.absent(),
    this.coWorkSessionId = const Value.absent(),
    this.coWorkParticipantIdsJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VisitsCompanion.insert({
    required String clientId,
    this.serverId = const Value.absent(),
    required String customerId,
    this.userName = const Value.absent(),
    required DateTime checkInAt,
    this.checkOutAt = const Value.absent(),
    required String outcome,
    this.lat = const Value.absent(),
    this.lng = const Value.absent(),
    this.accuracyM = const Value.absent(),
    this.mock = const Value.absent(),
    this.distanceToPinM = const Value.absent(),
    this.photoMediaClientIdsJson = const Value.absent(),
    this.note = const Value.absent(),
    this.source = const Value.absent(),
    this.syncState = const Value.absent(),
    this.userId = const Value.absent(),
    this.coWorkSessionId = const Value.absent(),
    this.coWorkParticipantIdsJson = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : clientId = Value(clientId),
       customerId = Value(customerId),
       checkInAt = Value(checkInAt),
       outcome = Value(outcome);
  static Insertable<VisitRow> custom({
    Expression<String>? clientId,
    Expression<String>? serverId,
    Expression<String>? customerId,
    Expression<String>? userName,
    Expression<DateTime>? checkInAt,
    Expression<DateTime>? checkOutAt,
    Expression<String>? outcome,
    Expression<double>? lat,
    Expression<double>? lng,
    Expression<double>? accuracyM,
    Expression<bool>? mock,
    Expression<int>? distanceToPinM,
    Expression<String>? photoMediaClientIdsJson,
    Expression<String>? note,
    Expression<String>? source,
    Expression<String>? syncState,
    Expression<String>? userId,
    Expression<String>? coWorkSessionId,
    Expression<String>? coWorkParticipantIdsJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (clientId != null) 'client_id': clientId,
      if (serverId != null) 'server_id': serverId,
      if (customerId != null) 'customer_id': customerId,
      if (userName != null) 'user_name': userName,
      if (checkInAt != null) 'check_in_at': checkInAt,
      if (checkOutAt != null) 'check_out_at': checkOutAt,
      if (outcome != null) 'outcome': outcome,
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
      if (accuracyM != null) 'accuracy_m': accuracyM,
      if (mock != null) 'mock': mock,
      if (distanceToPinM != null) 'distance_to_pin_m': distanceToPinM,
      if (photoMediaClientIdsJson != null)
        'photo_media_client_ids_json': photoMediaClientIdsJson,
      if (note != null) 'note': note,
      if (source != null) 'source': source,
      if (syncState != null) 'sync_state': syncState,
      if (userId != null) 'user_id': userId,
      if (coWorkSessionId != null) 'co_work_session_id': coWorkSessionId,
      if (coWorkParticipantIdsJson != null)
        'co_work_participant_ids_json': coWorkParticipantIdsJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VisitsCompanion copyWith({
    Value<String>? clientId,
    Value<String?>? serverId,
    Value<String>? customerId,
    Value<String?>? userName,
    Value<DateTime>? checkInAt,
    Value<DateTime?>? checkOutAt,
    Value<String>? outcome,
    Value<double?>? lat,
    Value<double?>? lng,
    Value<double?>? accuracyM,
    Value<bool>? mock,
    Value<int?>? distanceToPinM,
    Value<String>? photoMediaClientIdsJson,
    Value<String?>? note,
    Value<String>? source,
    Value<String>? syncState,
    Value<String?>? userId,
    Value<String?>? coWorkSessionId,
    Value<String?>? coWorkParticipantIdsJson,
    Value<int>? rowid,
  }) {
    return VisitsCompanion(
      clientId: clientId ?? this.clientId,
      serverId: serverId ?? this.serverId,
      customerId: customerId ?? this.customerId,
      userName: userName ?? this.userName,
      checkInAt: checkInAt ?? this.checkInAt,
      checkOutAt: checkOutAt ?? this.checkOutAt,
      outcome: outcome ?? this.outcome,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      accuracyM: accuracyM ?? this.accuracyM,
      mock: mock ?? this.mock,
      distanceToPinM: distanceToPinM ?? this.distanceToPinM,
      photoMediaClientIdsJson:
          photoMediaClientIdsJson ?? this.photoMediaClientIdsJson,
      note: note ?? this.note,
      source: source ?? this.source,
      syncState: syncState ?? this.syncState,
      userId: userId ?? this.userId,
      coWorkSessionId: coWorkSessionId ?? this.coWorkSessionId,
      coWorkParticipantIdsJson:
          coWorkParticipantIdsJson ?? this.coWorkParticipantIdsJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (clientId.present) {
      map['client_id'] = Variable<String>(clientId.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<String>(serverId.value);
    }
    if (customerId.present) {
      map['customer_id'] = Variable<String>(customerId.value);
    }
    if (userName.present) {
      map['user_name'] = Variable<String>(userName.value);
    }
    if (checkInAt.present) {
      map['check_in_at'] = Variable<DateTime>(checkInAt.value);
    }
    if (checkOutAt.present) {
      map['check_out_at'] = Variable<DateTime>(checkOutAt.value);
    }
    if (outcome.present) {
      map['outcome'] = Variable<String>(outcome.value);
    }
    if (lat.present) {
      map['lat'] = Variable<double>(lat.value);
    }
    if (lng.present) {
      map['lng'] = Variable<double>(lng.value);
    }
    if (accuracyM.present) {
      map['accuracy_m'] = Variable<double>(accuracyM.value);
    }
    if (mock.present) {
      map['mock'] = Variable<bool>(mock.value);
    }
    if (distanceToPinM.present) {
      map['distance_to_pin_m'] = Variable<int>(distanceToPinM.value);
    }
    if (photoMediaClientIdsJson.present) {
      map['photo_media_client_ids_json'] = Variable<String>(
        photoMediaClientIdsJson.value,
      );
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(syncState.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (coWorkSessionId.present) {
      map['co_work_session_id'] = Variable<String>(coWorkSessionId.value);
    }
    if (coWorkParticipantIdsJson.present) {
      map['co_work_participant_ids_json'] = Variable<String>(
        coWorkParticipantIdsJson.value,
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VisitsCompanion(')
          ..write('clientId: $clientId, ')
          ..write('serverId: $serverId, ')
          ..write('customerId: $customerId, ')
          ..write('userName: $userName, ')
          ..write('checkInAt: $checkInAt, ')
          ..write('checkOutAt: $checkOutAt, ')
          ..write('outcome: $outcome, ')
          ..write('lat: $lat, ')
          ..write('lng: $lng, ')
          ..write('accuracyM: $accuracyM, ')
          ..write('mock: $mock, ')
          ..write('distanceToPinM: $distanceToPinM, ')
          ..write('photoMediaClientIdsJson: $photoMediaClientIdsJson, ')
          ..write('note: $note, ')
          ..write('source: $source, ')
          ..write('syncState: $syncState, ')
          ..write('userId: $userId, ')
          ..write('coWorkSessionId: $coWorkSessionId, ')
          ..write('coWorkParticipantIdsJson: $coWorkParticipantIdsJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $NotesTable extends Notes with TableInfo<$NotesTable, NoteRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NotesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _clientIdMeta = const VerificationMeta(
    'clientId',
  );
  @override
  late final GeneratedColumn<String> clientId = GeneratedColumn<String>(
    'client_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _serverIdMeta = const VerificationMeta(
    'serverId',
  );
  @override
  late final GeneratedColumn<String> serverId = GeneratedColumn<String>(
    'server_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _customerIdMeta = const VerificationMeta(
    'customerId',
  );
  @override
  late final GeneratedColumn<String> customerId = GeneratedColumn<String>(
    'customer_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _authorIdMeta = const VerificationMeta(
    'authorId',
  );
  @override
  late final GeneratedColumn<String> authorId = GeneratedColumn<String>(
    'author_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _authorNameMeta = const VerificationMeta(
    'authorName',
  );
  @override
  late final GeneratedColumn<String> authorName = GeneratedColumn<String>(
    'author_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('general'),
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _voiceMediaClientIdMeta =
      const VerificationMeta('voiceMediaClientId');
  @override
  late final GeneratedColumn<String> voiceMediaClientId =
      GeneratedColumn<String>(
        'voice_media_client_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _editableUntilMeta = const VerificationMeta(
    'editableUntil',
  );
  @override
  late final GeneratedColumn<DateTime> editableUntil =
      GeneratedColumn<DateTime>(
        'editable_until',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _syncStateMeta = const VerificationMeta(
    'syncState',
  );
  @override
  late final GeneratedColumn<String> syncState = GeneratedColumn<String>(
    'sync_state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('queued'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    clientId,
    serverId,
    customerId,
    authorId,
    authorName,
    category,
    body,
    voiceMediaClientId,
    createdAt,
    editableUntil,
    syncState,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'notes';
  @override
  VerificationContext validateIntegrity(
    Insertable<NoteRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('client_id')) {
      context.handle(
        _clientIdMeta,
        clientId.isAcceptableOrUnknown(data['client_id']!, _clientIdMeta),
      );
    } else if (isInserting) {
      context.missing(_clientIdMeta);
    }
    if (data.containsKey('server_id')) {
      context.handle(
        _serverIdMeta,
        serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta),
      );
    }
    if (data.containsKey('customer_id')) {
      context.handle(
        _customerIdMeta,
        customerId.isAcceptableOrUnknown(data['customer_id']!, _customerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_customerIdMeta);
    }
    if (data.containsKey('author_id')) {
      context.handle(
        _authorIdMeta,
        authorId.isAcceptableOrUnknown(data['author_id']!, _authorIdMeta),
      );
    }
    if (data.containsKey('author_name')) {
      context.handle(
        _authorNameMeta,
        authorName.isAcceptableOrUnknown(data['author_name']!, _authorNameMeta),
      );
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    }
    if (data.containsKey('text')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['text']!, _bodyMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    if (data.containsKey('voice_media_client_id')) {
      context.handle(
        _voiceMediaClientIdMeta,
        voiceMediaClientId.isAcceptableOrUnknown(
          data['voice_media_client_id']!,
          _voiceMediaClientIdMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('editable_until')) {
      context.handle(
        _editableUntilMeta,
        editableUntil.isAcceptableOrUnknown(
          data['editable_until']!,
          _editableUntilMeta,
        ),
      );
    }
    if (data.containsKey('sync_state')) {
      context.handle(
        _syncStateMeta,
        syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {clientId};
  @override
  NoteRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NoteRow(
      clientId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}client_id'],
      )!,
      serverId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}server_id'],
      ),
      customerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}customer_id'],
      )!,
      authorId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}author_id'],
      ),
      authorName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}author_name'],
      ),
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}text'],
      )!,
      voiceMediaClientId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}voice_media_client_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      editableUntil: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}editable_until'],
      ),
      syncState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_state'],
      )!,
    );
  }

  @override
  $NotesTable createAlias(String alias) {
    return $NotesTable(attachedDatabase, alias);
  }
}

class NoteRow extends DataClass implements Insertable<NoteRow> {
  final String clientId;
  final String? serverId;
  final String customerId;
  final String? authorId;
  final String? authorName;
  final String category;
  final String body;
  final String? voiceMediaClientId;
  final DateTime createdAt;
  final DateTime? editableUntil;
  final String syncState;
  const NoteRow({
    required this.clientId,
    this.serverId,
    required this.customerId,
    this.authorId,
    this.authorName,
    required this.category,
    required this.body,
    this.voiceMediaClientId,
    required this.createdAt,
    this.editableUntil,
    required this.syncState,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['client_id'] = Variable<String>(clientId);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<String>(serverId);
    }
    map['customer_id'] = Variable<String>(customerId);
    if (!nullToAbsent || authorId != null) {
      map['author_id'] = Variable<String>(authorId);
    }
    if (!nullToAbsent || authorName != null) {
      map['author_name'] = Variable<String>(authorName);
    }
    map['category'] = Variable<String>(category);
    map['text'] = Variable<String>(body);
    if (!nullToAbsent || voiceMediaClientId != null) {
      map['voice_media_client_id'] = Variable<String>(voiceMediaClientId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || editableUntil != null) {
      map['editable_until'] = Variable<DateTime>(editableUntil);
    }
    map['sync_state'] = Variable<String>(syncState);
    return map;
  }

  NotesCompanion toCompanion(bool nullToAbsent) {
    return NotesCompanion(
      clientId: Value(clientId),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      customerId: Value(customerId),
      authorId: authorId == null && nullToAbsent
          ? const Value.absent()
          : Value(authorId),
      authorName: authorName == null && nullToAbsent
          ? const Value.absent()
          : Value(authorName),
      category: Value(category),
      body: Value(body),
      voiceMediaClientId: voiceMediaClientId == null && nullToAbsent
          ? const Value.absent()
          : Value(voiceMediaClientId),
      createdAt: Value(createdAt),
      editableUntil: editableUntil == null && nullToAbsent
          ? const Value.absent()
          : Value(editableUntil),
      syncState: Value(syncState),
    );
  }

  factory NoteRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NoteRow(
      clientId: serializer.fromJson<String>(json['clientId']),
      serverId: serializer.fromJson<String?>(json['serverId']),
      customerId: serializer.fromJson<String>(json['customerId']),
      authorId: serializer.fromJson<String?>(json['authorId']),
      authorName: serializer.fromJson<String?>(json['authorName']),
      category: serializer.fromJson<String>(json['category']),
      body: serializer.fromJson<String>(json['body']),
      voiceMediaClientId: serializer.fromJson<String?>(
        json['voiceMediaClientId'],
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      editableUntil: serializer.fromJson<DateTime?>(json['editableUntil']),
      syncState: serializer.fromJson<String>(json['syncState']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'clientId': serializer.toJson<String>(clientId),
      'serverId': serializer.toJson<String?>(serverId),
      'customerId': serializer.toJson<String>(customerId),
      'authorId': serializer.toJson<String?>(authorId),
      'authorName': serializer.toJson<String?>(authorName),
      'category': serializer.toJson<String>(category),
      'body': serializer.toJson<String>(body),
      'voiceMediaClientId': serializer.toJson<String?>(voiceMediaClientId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'editableUntil': serializer.toJson<DateTime?>(editableUntil),
      'syncState': serializer.toJson<String>(syncState),
    };
  }

  NoteRow copyWith({
    String? clientId,
    Value<String?> serverId = const Value.absent(),
    String? customerId,
    Value<String?> authorId = const Value.absent(),
    Value<String?> authorName = const Value.absent(),
    String? category,
    String? body,
    Value<String?> voiceMediaClientId = const Value.absent(),
    DateTime? createdAt,
    Value<DateTime?> editableUntil = const Value.absent(),
    String? syncState,
  }) => NoteRow(
    clientId: clientId ?? this.clientId,
    serverId: serverId.present ? serverId.value : this.serverId,
    customerId: customerId ?? this.customerId,
    authorId: authorId.present ? authorId.value : this.authorId,
    authorName: authorName.present ? authorName.value : this.authorName,
    category: category ?? this.category,
    body: body ?? this.body,
    voiceMediaClientId: voiceMediaClientId.present
        ? voiceMediaClientId.value
        : this.voiceMediaClientId,
    createdAt: createdAt ?? this.createdAt,
    editableUntil: editableUntil.present
        ? editableUntil.value
        : this.editableUntil,
    syncState: syncState ?? this.syncState,
  );
  NoteRow copyWithCompanion(NotesCompanion data) {
    return NoteRow(
      clientId: data.clientId.present ? data.clientId.value : this.clientId,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      customerId: data.customerId.present
          ? data.customerId.value
          : this.customerId,
      authorId: data.authorId.present ? data.authorId.value : this.authorId,
      authorName: data.authorName.present
          ? data.authorName.value
          : this.authorName,
      category: data.category.present ? data.category.value : this.category,
      body: data.body.present ? data.body.value : this.body,
      voiceMediaClientId: data.voiceMediaClientId.present
          ? data.voiceMediaClientId.value
          : this.voiceMediaClientId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      editableUntil: data.editableUntil.present
          ? data.editableUntil.value
          : this.editableUntil,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NoteRow(')
          ..write('clientId: $clientId, ')
          ..write('serverId: $serverId, ')
          ..write('customerId: $customerId, ')
          ..write('authorId: $authorId, ')
          ..write('authorName: $authorName, ')
          ..write('category: $category, ')
          ..write('body: $body, ')
          ..write('voiceMediaClientId: $voiceMediaClientId, ')
          ..write('createdAt: $createdAt, ')
          ..write('editableUntil: $editableUntil, ')
          ..write('syncState: $syncState')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    clientId,
    serverId,
    customerId,
    authorId,
    authorName,
    category,
    body,
    voiceMediaClientId,
    createdAt,
    editableUntil,
    syncState,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NoteRow &&
          other.clientId == this.clientId &&
          other.serverId == this.serverId &&
          other.customerId == this.customerId &&
          other.authorId == this.authorId &&
          other.authorName == this.authorName &&
          other.category == this.category &&
          other.body == this.body &&
          other.voiceMediaClientId == this.voiceMediaClientId &&
          other.createdAt == this.createdAt &&
          other.editableUntil == this.editableUntil &&
          other.syncState == this.syncState);
}

class NotesCompanion extends UpdateCompanion<NoteRow> {
  final Value<String> clientId;
  final Value<String?> serverId;
  final Value<String> customerId;
  final Value<String?> authorId;
  final Value<String?> authorName;
  final Value<String> category;
  final Value<String> body;
  final Value<String?> voiceMediaClientId;
  final Value<DateTime> createdAt;
  final Value<DateTime?> editableUntil;
  final Value<String> syncState;
  final Value<int> rowid;
  const NotesCompanion({
    this.clientId = const Value.absent(),
    this.serverId = const Value.absent(),
    this.customerId = const Value.absent(),
    this.authorId = const Value.absent(),
    this.authorName = const Value.absent(),
    this.category = const Value.absent(),
    this.body = const Value.absent(),
    this.voiceMediaClientId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.editableUntil = const Value.absent(),
    this.syncState = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  NotesCompanion.insert({
    required String clientId,
    this.serverId = const Value.absent(),
    required String customerId,
    this.authorId = const Value.absent(),
    this.authorName = const Value.absent(),
    this.category = const Value.absent(),
    required String body,
    this.voiceMediaClientId = const Value.absent(),
    required DateTime createdAt,
    this.editableUntil = const Value.absent(),
    this.syncState = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : clientId = Value(clientId),
       customerId = Value(customerId),
       body = Value(body),
       createdAt = Value(createdAt);
  static Insertable<NoteRow> custom({
    Expression<String>? clientId,
    Expression<String>? serverId,
    Expression<String>? customerId,
    Expression<String>? authorId,
    Expression<String>? authorName,
    Expression<String>? category,
    Expression<String>? body,
    Expression<String>? voiceMediaClientId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? editableUntil,
    Expression<String>? syncState,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (clientId != null) 'client_id': clientId,
      if (serverId != null) 'server_id': serverId,
      if (customerId != null) 'customer_id': customerId,
      if (authorId != null) 'author_id': authorId,
      if (authorName != null) 'author_name': authorName,
      if (category != null) 'category': category,
      if (body != null) 'text': body,
      if (voiceMediaClientId != null)
        'voice_media_client_id': voiceMediaClientId,
      if (createdAt != null) 'created_at': createdAt,
      if (editableUntil != null) 'editable_until': editableUntil,
      if (syncState != null) 'sync_state': syncState,
      if (rowid != null) 'rowid': rowid,
    });
  }

  NotesCompanion copyWith({
    Value<String>? clientId,
    Value<String?>? serverId,
    Value<String>? customerId,
    Value<String?>? authorId,
    Value<String?>? authorName,
    Value<String>? category,
    Value<String>? body,
    Value<String?>? voiceMediaClientId,
    Value<DateTime>? createdAt,
    Value<DateTime?>? editableUntil,
    Value<String>? syncState,
    Value<int>? rowid,
  }) {
    return NotesCompanion(
      clientId: clientId ?? this.clientId,
      serverId: serverId ?? this.serverId,
      customerId: customerId ?? this.customerId,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      category: category ?? this.category,
      body: body ?? this.body,
      voiceMediaClientId: voiceMediaClientId ?? this.voiceMediaClientId,
      createdAt: createdAt ?? this.createdAt,
      editableUntil: editableUntil ?? this.editableUntil,
      syncState: syncState ?? this.syncState,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (clientId.present) {
      map['client_id'] = Variable<String>(clientId.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<String>(serverId.value);
    }
    if (customerId.present) {
      map['customer_id'] = Variable<String>(customerId.value);
    }
    if (authorId.present) {
      map['author_id'] = Variable<String>(authorId.value);
    }
    if (authorName.present) {
      map['author_name'] = Variable<String>(authorName.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (body.present) {
      map['text'] = Variable<String>(body.value);
    }
    if (voiceMediaClientId.present) {
      map['voice_media_client_id'] = Variable<String>(voiceMediaClientId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (editableUntil.present) {
      map['editable_until'] = Variable<DateTime>(editableUntil.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(syncState.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NotesCompanion(')
          ..write('clientId: $clientId, ')
          ..write('serverId: $serverId, ')
          ..write('customerId: $customerId, ')
          ..write('authorId: $authorId, ')
          ..write('authorName: $authorName, ')
          ..write('category: $category, ')
          ..write('body: $body, ')
          ..write('voiceMediaClientId: $voiceMediaClientId, ')
          ..write('createdAt: $createdAt, ')
          ..write('editableUntil: $editableUntil, ')
          ..write('syncState: $syncState, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PromisesTable extends Promises
    with TableInfo<$PromisesTable, PromiseRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PromisesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _clientIdMeta = const VerificationMeta(
    'clientId',
  );
  @override
  late final GeneratedColumn<String> clientId = GeneratedColumn<String>(
    'client_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _serverIdMeta = const VerificationMeta(
    'serverId',
  );
  @override
  late final GeneratedColumn<String> serverId = GeneratedColumn<String>(
    'server_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _customerIdMeta = const VerificationMeta(
    'customerId',
  );
  @override
  late final GeneratedColumn<String> customerId = GeneratedColumn<String>(
    'customer_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _erpPlanIdMeta = const VerificationMeta(
    'erpPlanId',
  );
  @override
  late final GeneratedColumn<String> erpPlanId = GeneratedColumn<String>(
    'erp_plan_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _promisedDateMeta = const VerificationMeta(
    'promisedDate',
  );
  @override
  late final GeneratedColumn<String> promisedDate = GeneratedColumn<String>(
    'promised_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _promisedAmountPoishaMeta =
      const VerificationMeta('promisedAmountPoisha');
  @override
  late final GeneratedColumn<int> promisedAmountPoisha = GeneratedColumn<int>(
    'promised_amount_poisha',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _paidTowardsPoishaMeta = const VerificationMeta(
    'paidTowardsPoisha',
  );
  @override
  late final GeneratedColumn<int> paidTowardsPoisha = GeneratedColumn<int>(
    'paid_towards_poisha',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('open'),
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncStateMeta = const VerificationMeta(
    'syncState',
  );
  @override
  late final GeneratedColumn<String> syncState = GeneratedColumn<String>(
    'sync_state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('queued'),
  );
  static const VerificationMeta _reminderScheduledMeta = const VerificationMeta(
    'reminderScheduled',
  );
  @override
  late final GeneratedColumn<bool> reminderScheduled = GeneratedColumn<bool>(
    'reminder_scheduled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("reminder_scheduled" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    clientId,
    serverId,
    customerId,
    erpPlanId,
    promisedDate,
    promisedAmountPoisha,
    paidTowardsPoisha,
    status,
    note,
    createdAt,
    syncState,
    reminderScheduled,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'promises';
  @override
  VerificationContext validateIntegrity(
    Insertable<PromiseRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('client_id')) {
      context.handle(
        _clientIdMeta,
        clientId.isAcceptableOrUnknown(data['client_id']!, _clientIdMeta),
      );
    } else if (isInserting) {
      context.missing(_clientIdMeta);
    }
    if (data.containsKey('server_id')) {
      context.handle(
        _serverIdMeta,
        serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta),
      );
    }
    if (data.containsKey('customer_id')) {
      context.handle(
        _customerIdMeta,
        customerId.isAcceptableOrUnknown(data['customer_id']!, _customerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_customerIdMeta);
    }
    if (data.containsKey('erp_plan_id')) {
      context.handle(
        _erpPlanIdMeta,
        erpPlanId.isAcceptableOrUnknown(data['erp_plan_id']!, _erpPlanIdMeta),
      );
    }
    if (data.containsKey('promised_date')) {
      context.handle(
        _promisedDateMeta,
        promisedDate.isAcceptableOrUnknown(
          data['promised_date']!,
          _promisedDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_promisedDateMeta);
    }
    if (data.containsKey('promised_amount_poisha')) {
      context.handle(
        _promisedAmountPoishaMeta,
        promisedAmountPoisha.isAcceptableOrUnknown(
          data['promised_amount_poisha']!,
          _promisedAmountPoishaMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_promisedAmountPoishaMeta);
    }
    if (data.containsKey('paid_towards_poisha')) {
      context.handle(
        _paidTowardsPoishaMeta,
        paidTowardsPoisha.isAcceptableOrUnknown(
          data['paid_towards_poisha']!,
          _paidTowardsPoishaMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('sync_state')) {
      context.handle(
        _syncStateMeta,
        syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta),
      );
    }
    if (data.containsKey('reminder_scheduled')) {
      context.handle(
        _reminderScheduledMeta,
        reminderScheduled.isAcceptableOrUnknown(
          data['reminder_scheduled']!,
          _reminderScheduledMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {clientId};
  @override
  PromiseRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PromiseRow(
      clientId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}client_id'],
      )!,
      serverId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}server_id'],
      ),
      customerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}customer_id'],
      )!,
      erpPlanId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}erp_plan_id'],
      ),
      promisedDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}promised_date'],
      )!,
      promisedAmountPoisha: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}promised_amount_poisha'],
      )!,
      paidTowardsPoisha: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}paid_towards_poisha'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      syncState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_state'],
      )!,
      reminderScheduled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}reminder_scheduled'],
      )!,
    );
  }

  @override
  $PromisesTable createAlias(String alias) {
    return $PromisesTable(attachedDatabase, alias);
  }
}

class PromiseRow extends DataClass implements Insertable<PromiseRow> {
  final String clientId;
  final String? serverId;
  final String customerId;
  final String? erpPlanId;
  final String promisedDate;
  final int promisedAmountPoisha;
  final int paidTowardsPoisha;
  final String status;
  final String? note;
  final DateTime createdAt;
  final String syncState;
  final bool reminderScheduled;
  const PromiseRow({
    required this.clientId,
    this.serverId,
    required this.customerId,
    this.erpPlanId,
    required this.promisedDate,
    required this.promisedAmountPoisha,
    required this.paidTowardsPoisha,
    required this.status,
    this.note,
    required this.createdAt,
    required this.syncState,
    required this.reminderScheduled,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['client_id'] = Variable<String>(clientId);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<String>(serverId);
    }
    map['customer_id'] = Variable<String>(customerId);
    if (!nullToAbsent || erpPlanId != null) {
      map['erp_plan_id'] = Variable<String>(erpPlanId);
    }
    map['promised_date'] = Variable<String>(promisedDate);
    map['promised_amount_poisha'] = Variable<int>(promisedAmountPoisha);
    map['paid_towards_poisha'] = Variable<int>(paidTowardsPoisha);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['sync_state'] = Variable<String>(syncState);
    map['reminder_scheduled'] = Variable<bool>(reminderScheduled);
    return map;
  }

  PromisesCompanion toCompanion(bool nullToAbsent) {
    return PromisesCompanion(
      clientId: Value(clientId),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      customerId: Value(customerId),
      erpPlanId: erpPlanId == null && nullToAbsent
          ? const Value.absent()
          : Value(erpPlanId),
      promisedDate: Value(promisedDate),
      promisedAmountPoisha: Value(promisedAmountPoisha),
      paidTowardsPoisha: Value(paidTowardsPoisha),
      status: Value(status),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      createdAt: Value(createdAt),
      syncState: Value(syncState),
      reminderScheduled: Value(reminderScheduled),
    );
  }

  factory PromiseRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PromiseRow(
      clientId: serializer.fromJson<String>(json['clientId']),
      serverId: serializer.fromJson<String?>(json['serverId']),
      customerId: serializer.fromJson<String>(json['customerId']),
      erpPlanId: serializer.fromJson<String?>(json['erpPlanId']),
      promisedDate: serializer.fromJson<String>(json['promisedDate']),
      promisedAmountPoisha: serializer.fromJson<int>(
        json['promisedAmountPoisha'],
      ),
      paidTowardsPoisha: serializer.fromJson<int>(json['paidTowardsPoisha']),
      status: serializer.fromJson<String>(json['status']),
      note: serializer.fromJson<String?>(json['note']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      syncState: serializer.fromJson<String>(json['syncState']),
      reminderScheduled: serializer.fromJson<bool>(json['reminderScheduled']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'clientId': serializer.toJson<String>(clientId),
      'serverId': serializer.toJson<String?>(serverId),
      'customerId': serializer.toJson<String>(customerId),
      'erpPlanId': serializer.toJson<String?>(erpPlanId),
      'promisedDate': serializer.toJson<String>(promisedDate),
      'promisedAmountPoisha': serializer.toJson<int>(promisedAmountPoisha),
      'paidTowardsPoisha': serializer.toJson<int>(paidTowardsPoisha),
      'status': serializer.toJson<String>(status),
      'note': serializer.toJson<String?>(note),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'syncState': serializer.toJson<String>(syncState),
      'reminderScheduled': serializer.toJson<bool>(reminderScheduled),
    };
  }

  PromiseRow copyWith({
    String? clientId,
    Value<String?> serverId = const Value.absent(),
    String? customerId,
    Value<String?> erpPlanId = const Value.absent(),
    String? promisedDate,
    int? promisedAmountPoisha,
    int? paidTowardsPoisha,
    String? status,
    Value<String?> note = const Value.absent(),
    DateTime? createdAt,
    String? syncState,
    bool? reminderScheduled,
  }) => PromiseRow(
    clientId: clientId ?? this.clientId,
    serverId: serverId.present ? serverId.value : this.serverId,
    customerId: customerId ?? this.customerId,
    erpPlanId: erpPlanId.present ? erpPlanId.value : this.erpPlanId,
    promisedDate: promisedDate ?? this.promisedDate,
    promisedAmountPoisha: promisedAmountPoisha ?? this.promisedAmountPoisha,
    paidTowardsPoisha: paidTowardsPoisha ?? this.paidTowardsPoisha,
    status: status ?? this.status,
    note: note.present ? note.value : this.note,
    createdAt: createdAt ?? this.createdAt,
    syncState: syncState ?? this.syncState,
    reminderScheduled: reminderScheduled ?? this.reminderScheduled,
  );
  PromiseRow copyWithCompanion(PromisesCompanion data) {
    return PromiseRow(
      clientId: data.clientId.present ? data.clientId.value : this.clientId,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      customerId: data.customerId.present
          ? data.customerId.value
          : this.customerId,
      erpPlanId: data.erpPlanId.present ? data.erpPlanId.value : this.erpPlanId,
      promisedDate: data.promisedDate.present
          ? data.promisedDate.value
          : this.promisedDate,
      promisedAmountPoisha: data.promisedAmountPoisha.present
          ? data.promisedAmountPoisha.value
          : this.promisedAmountPoisha,
      paidTowardsPoisha: data.paidTowardsPoisha.present
          ? data.paidTowardsPoisha.value
          : this.paidTowardsPoisha,
      status: data.status.present ? data.status.value : this.status,
      note: data.note.present ? data.note.value : this.note,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
      reminderScheduled: data.reminderScheduled.present
          ? data.reminderScheduled.value
          : this.reminderScheduled,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PromiseRow(')
          ..write('clientId: $clientId, ')
          ..write('serverId: $serverId, ')
          ..write('customerId: $customerId, ')
          ..write('erpPlanId: $erpPlanId, ')
          ..write('promisedDate: $promisedDate, ')
          ..write('promisedAmountPoisha: $promisedAmountPoisha, ')
          ..write('paidTowardsPoisha: $paidTowardsPoisha, ')
          ..write('status: $status, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('syncState: $syncState, ')
          ..write('reminderScheduled: $reminderScheduled')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    clientId,
    serverId,
    customerId,
    erpPlanId,
    promisedDate,
    promisedAmountPoisha,
    paidTowardsPoisha,
    status,
    note,
    createdAt,
    syncState,
    reminderScheduled,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PromiseRow &&
          other.clientId == this.clientId &&
          other.serverId == this.serverId &&
          other.customerId == this.customerId &&
          other.erpPlanId == this.erpPlanId &&
          other.promisedDate == this.promisedDate &&
          other.promisedAmountPoisha == this.promisedAmountPoisha &&
          other.paidTowardsPoisha == this.paidTowardsPoisha &&
          other.status == this.status &&
          other.note == this.note &&
          other.createdAt == this.createdAt &&
          other.syncState == this.syncState &&
          other.reminderScheduled == this.reminderScheduled);
}

class PromisesCompanion extends UpdateCompanion<PromiseRow> {
  final Value<String> clientId;
  final Value<String?> serverId;
  final Value<String> customerId;
  final Value<String?> erpPlanId;
  final Value<String> promisedDate;
  final Value<int> promisedAmountPoisha;
  final Value<int> paidTowardsPoisha;
  final Value<String> status;
  final Value<String?> note;
  final Value<DateTime> createdAt;
  final Value<String> syncState;
  final Value<bool> reminderScheduled;
  final Value<int> rowid;
  const PromisesCompanion({
    this.clientId = const Value.absent(),
    this.serverId = const Value.absent(),
    this.customerId = const Value.absent(),
    this.erpPlanId = const Value.absent(),
    this.promisedDate = const Value.absent(),
    this.promisedAmountPoisha = const Value.absent(),
    this.paidTowardsPoisha = const Value.absent(),
    this.status = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.syncState = const Value.absent(),
    this.reminderScheduled = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PromisesCompanion.insert({
    required String clientId,
    this.serverId = const Value.absent(),
    required String customerId,
    this.erpPlanId = const Value.absent(),
    required String promisedDate,
    required int promisedAmountPoisha,
    this.paidTowardsPoisha = const Value.absent(),
    this.status = const Value.absent(),
    this.note = const Value.absent(),
    required DateTime createdAt,
    this.syncState = const Value.absent(),
    this.reminderScheduled = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : clientId = Value(clientId),
       customerId = Value(customerId),
       promisedDate = Value(promisedDate),
       promisedAmountPoisha = Value(promisedAmountPoisha),
       createdAt = Value(createdAt);
  static Insertable<PromiseRow> custom({
    Expression<String>? clientId,
    Expression<String>? serverId,
    Expression<String>? customerId,
    Expression<String>? erpPlanId,
    Expression<String>? promisedDate,
    Expression<int>? promisedAmountPoisha,
    Expression<int>? paidTowardsPoisha,
    Expression<String>? status,
    Expression<String>? note,
    Expression<DateTime>? createdAt,
    Expression<String>? syncState,
    Expression<bool>? reminderScheduled,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (clientId != null) 'client_id': clientId,
      if (serverId != null) 'server_id': serverId,
      if (customerId != null) 'customer_id': customerId,
      if (erpPlanId != null) 'erp_plan_id': erpPlanId,
      if (promisedDate != null) 'promised_date': promisedDate,
      if (promisedAmountPoisha != null)
        'promised_amount_poisha': promisedAmountPoisha,
      if (paidTowardsPoisha != null) 'paid_towards_poisha': paidTowardsPoisha,
      if (status != null) 'status': status,
      if (note != null) 'note': note,
      if (createdAt != null) 'created_at': createdAt,
      if (syncState != null) 'sync_state': syncState,
      if (reminderScheduled != null) 'reminder_scheduled': reminderScheduled,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PromisesCompanion copyWith({
    Value<String>? clientId,
    Value<String?>? serverId,
    Value<String>? customerId,
    Value<String?>? erpPlanId,
    Value<String>? promisedDate,
    Value<int>? promisedAmountPoisha,
    Value<int>? paidTowardsPoisha,
    Value<String>? status,
    Value<String?>? note,
    Value<DateTime>? createdAt,
    Value<String>? syncState,
    Value<bool>? reminderScheduled,
    Value<int>? rowid,
  }) {
    return PromisesCompanion(
      clientId: clientId ?? this.clientId,
      serverId: serverId ?? this.serverId,
      customerId: customerId ?? this.customerId,
      erpPlanId: erpPlanId ?? this.erpPlanId,
      promisedDate: promisedDate ?? this.promisedDate,
      promisedAmountPoisha: promisedAmountPoisha ?? this.promisedAmountPoisha,
      paidTowardsPoisha: paidTowardsPoisha ?? this.paidTowardsPoisha,
      status: status ?? this.status,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      syncState: syncState ?? this.syncState,
      reminderScheduled: reminderScheduled ?? this.reminderScheduled,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (clientId.present) {
      map['client_id'] = Variable<String>(clientId.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<String>(serverId.value);
    }
    if (customerId.present) {
      map['customer_id'] = Variable<String>(customerId.value);
    }
    if (erpPlanId.present) {
      map['erp_plan_id'] = Variable<String>(erpPlanId.value);
    }
    if (promisedDate.present) {
      map['promised_date'] = Variable<String>(promisedDate.value);
    }
    if (promisedAmountPoisha.present) {
      map['promised_amount_poisha'] = Variable<int>(promisedAmountPoisha.value);
    }
    if (paidTowardsPoisha.present) {
      map['paid_towards_poisha'] = Variable<int>(paidTowardsPoisha.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(syncState.value);
    }
    if (reminderScheduled.present) {
      map['reminder_scheduled'] = Variable<bool>(reminderScheduled.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PromisesCompanion(')
          ..write('clientId: $clientId, ')
          ..write('serverId: $serverId, ')
          ..write('customerId: $customerId, ')
          ..write('erpPlanId: $erpPlanId, ')
          ..write('promisedDate: $promisedDate, ')
          ..write('promisedAmountPoisha: $promisedAmountPoisha, ')
          ..write('paidTowardsPoisha: $paidTowardsPoisha, ')
          ..write('status: $status, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('syncState: $syncState, ')
          ..write('reminderScheduled: $reminderScheduled, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TagEventsTable extends TagEvents
    with TableInfo<$TagEventsTable, TagEventRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TagEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _clientIdMeta = const VerificationMeta(
    'clientId',
  );
  @override
  late final GeneratedColumn<String> clientId = GeneratedColumn<String>(
    'client_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _customerIdMeta = const VerificationMeta(
    'customerId',
  );
  @override
  late final GeneratedColumn<String> customerId = GeneratedColumn<String>(
    'customer_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _previousJsonMeta = const VerificationMeta(
    'previousJson',
  );
  @override
  late final GeneratedColumn<String> previousJson = GeneratedColumn<String>(
    'previous_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nextJsonMeta = const VerificationMeta(
    'nextJson',
  );
  @override
  late final GeneratedColumn<String> nextJson = GeneratedColumn<String>(
    'next_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reasonCodeMeta = const VerificationMeta(
    'reasonCode',
  );
  @override
  late final GeneratedColumn<String> reasonCode = GeneratedColumn<String>(
    'reason_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
    'reason',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _atMeta = const VerificationMeta('at');
  @override
  late final GeneratedColumn<DateTime> at = GeneratedColumn<DateTime>(
    'at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncStateMeta = const VerificationMeta(
    'syncState',
  );
  @override
  late final GeneratedColumn<String> syncState = GeneratedColumn<String>(
    'sync_state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('queued'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    clientId,
    customerId,
    previousJson,
    nextJson,
    reasonCode,
    reason,
    at,
    syncState,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tag_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<TagEventRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('client_id')) {
      context.handle(
        _clientIdMeta,
        clientId.isAcceptableOrUnknown(data['client_id']!, _clientIdMeta),
      );
    } else if (isInserting) {
      context.missing(_clientIdMeta);
    }
    if (data.containsKey('customer_id')) {
      context.handle(
        _customerIdMeta,
        customerId.isAcceptableOrUnknown(data['customer_id']!, _customerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_customerIdMeta);
    }
    if (data.containsKey('previous_json')) {
      context.handle(
        _previousJsonMeta,
        previousJson.isAcceptableOrUnknown(
          data['previous_json']!,
          _previousJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_previousJsonMeta);
    }
    if (data.containsKey('next_json')) {
      context.handle(
        _nextJsonMeta,
        nextJson.isAcceptableOrUnknown(data['next_json']!, _nextJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_nextJsonMeta);
    }
    if (data.containsKey('reason_code')) {
      context.handle(
        _reasonCodeMeta,
        reasonCode.isAcceptableOrUnknown(data['reason_code']!, _reasonCodeMeta),
      );
    } else if (isInserting) {
      context.missing(_reasonCodeMeta);
    }
    if (data.containsKey('reason')) {
      context.handle(
        _reasonMeta,
        reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta),
      );
    } else if (isInserting) {
      context.missing(_reasonMeta);
    }
    if (data.containsKey('at')) {
      context.handle(_atMeta, at.isAcceptableOrUnknown(data['at']!, _atMeta));
    } else if (isInserting) {
      context.missing(_atMeta);
    }
    if (data.containsKey('sync_state')) {
      context.handle(
        _syncStateMeta,
        syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {clientId};
  @override
  TagEventRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TagEventRow(
      clientId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}client_id'],
      )!,
      customerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}customer_id'],
      )!,
      previousJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}previous_json'],
      )!,
      nextJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}next_json'],
      )!,
      reasonCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reason_code'],
      )!,
      reason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reason'],
      )!,
      at: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}at'],
      )!,
      syncState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_state'],
      )!,
    );
  }

  @override
  $TagEventsTable createAlias(String alias) {
    return $TagEventsTable(attachedDatabase, alias);
  }
}

class TagEventRow extends DataClass implements Insertable<TagEventRow> {
  final String clientId;
  final String customerId;
  final String previousJson;
  final String nextJson;
  final String reasonCode;
  final String reason;
  final DateTime at;
  final String syncState;
  const TagEventRow({
    required this.clientId,
    required this.customerId,
    required this.previousJson,
    required this.nextJson,
    required this.reasonCode,
    required this.reason,
    required this.at,
    required this.syncState,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['client_id'] = Variable<String>(clientId);
    map['customer_id'] = Variable<String>(customerId);
    map['previous_json'] = Variable<String>(previousJson);
    map['next_json'] = Variable<String>(nextJson);
    map['reason_code'] = Variable<String>(reasonCode);
    map['reason'] = Variable<String>(reason);
    map['at'] = Variable<DateTime>(at);
    map['sync_state'] = Variable<String>(syncState);
    return map;
  }

  TagEventsCompanion toCompanion(bool nullToAbsent) {
    return TagEventsCompanion(
      clientId: Value(clientId),
      customerId: Value(customerId),
      previousJson: Value(previousJson),
      nextJson: Value(nextJson),
      reasonCode: Value(reasonCode),
      reason: Value(reason),
      at: Value(at),
      syncState: Value(syncState),
    );
  }

  factory TagEventRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TagEventRow(
      clientId: serializer.fromJson<String>(json['clientId']),
      customerId: serializer.fromJson<String>(json['customerId']),
      previousJson: serializer.fromJson<String>(json['previousJson']),
      nextJson: serializer.fromJson<String>(json['nextJson']),
      reasonCode: serializer.fromJson<String>(json['reasonCode']),
      reason: serializer.fromJson<String>(json['reason']),
      at: serializer.fromJson<DateTime>(json['at']),
      syncState: serializer.fromJson<String>(json['syncState']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'clientId': serializer.toJson<String>(clientId),
      'customerId': serializer.toJson<String>(customerId),
      'previousJson': serializer.toJson<String>(previousJson),
      'nextJson': serializer.toJson<String>(nextJson),
      'reasonCode': serializer.toJson<String>(reasonCode),
      'reason': serializer.toJson<String>(reason),
      'at': serializer.toJson<DateTime>(at),
      'syncState': serializer.toJson<String>(syncState),
    };
  }

  TagEventRow copyWith({
    String? clientId,
    String? customerId,
    String? previousJson,
    String? nextJson,
    String? reasonCode,
    String? reason,
    DateTime? at,
    String? syncState,
  }) => TagEventRow(
    clientId: clientId ?? this.clientId,
    customerId: customerId ?? this.customerId,
    previousJson: previousJson ?? this.previousJson,
    nextJson: nextJson ?? this.nextJson,
    reasonCode: reasonCode ?? this.reasonCode,
    reason: reason ?? this.reason,
    at: at ?? this.at,
    syncState: syncState ?? this.syncState,
  );
  TagEventRow copyWithCompanion(TagEventsCompanion data) {
    return TagEventRow(
      clientId: data.clientId.present ? data.clientId.value : this.clientId,
      customerId: data.customerId.present
          ? data.customerId.value
          : this.customerId,
      previousJson: data.previousJson.present
          ? data.previousJson.value
          : this.previousJson,
      nextJson: data.nextJson.present ? data.nextJson.value : this.nextJson,
      reasonCode: data.reasonCode.present
          ? data.reasonCode.value
          : this.reasonCode,
      reason: data.reason.present ? data.reason.value : this.reason,
      at: data.at.present ? data.at.value : this.at,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TagEventRow(')
          ..write('clientId: $clientId, ')
          ..write('customerId: $customerId, ')
          ..write('previousJson: $previousJson, ')
          ..write('nextJson: $nextJson, ')
          ..write('reasonCode: $reasonCode, ')
          ..write('reason: $reason, ')
          ..write('at: $at, ')
          ..write('syncState: $syncState')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    clientId,
    customerId,
    previousJson,
    nextJson,
    reasonCode,
    reason,
    at,
    syncState,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TagEventRow &&
          other.clientId == this.clientId &&
          other.customerId == this.customerId &&
          other.previousJson == this.previousJson &&
          other.nextJson == this.nextJson &&
          other.reasonCode == this.reasonCode &&
          other.reason == this.reason &&
          other.at == this.at &&
          other.syncState == this.syncState);
}

class TagEventsCompanion extends UpdateCompanion<TagEventRow> {
  final Value<String> clientId;
  final Value<String> customerId;
  final Value<String> previousJson;
  final Value<String> nextJson;
  final Value<String> reasonCode;
  final Value<String> reason;
  final Value<DateTime> at;
  final Value<String> syncState;
  final Value<int> rowid;
  const TagEventsCompanion({
    this.clientId = const Value.absent(),
    this.customerId = const Value.absent(),
    this.previousJson = const Value.absent(),
    this.nextJson = const Value.absent(),
    this.reasonCode = const Value.absent(),
    this.reason = const Value.absent(),
    this.at = const Value.absent(),
    this.syncState = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TagEventsCompanion.insert({
    required String clientId,
    required String customerId,
    required String previousJson,
    required String nextJson,
    required String reasonCode,
    required String reason,
    required DateTime at,
    this.syncState = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : clientId = Value(clientId),
       customerId = Value(customerId),
       previousJson = Value(previousJson),
       nextJson = Value(nextJson),
       reasonCode = Value(reasonCode),
       reason = Value(reason),
       at = Value(at);
  static Insertable<TagEventRow> custom({
    Expression<String>? clientId,
    Expression<String>? customerId,
    Expression<String>? previousJson,
    Expression<String>? nextJson,
    Expression<String>? reasonCode,
    Expression<String>? reason,
    Expression<DateTime>? at,
    Expression<String>? syncState,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (clientId != null) 'client_id': clientId,
      if (customerId != null) 'customer_id': customerId,
      if (previousJson != null) 'previous_json': previousJson,
      if (nextJson != null) 'next_json': nextJson,
      if (reasonCode != null) 'reason_code': reasonCode,
      if (reason != null) 'reason': reason,
      if (at != null) 'at': at,
      if (syncState != null) 'sync_state': syncState,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TagEventsCompanion copyWith({
    Value<String>? clientId,
    Value<String>? customerId,
    Value<String>? previousJson,
    Value<String>? nextJson,
    Value<String>? reasonCode,
    Value<String>? reason,
    Value<DateTime>? at,
    Value<String>? syncState,
    Value<int>? rowid,
  }) {
    return TagEventsCompanion(
      clientId: clientId ?? this.clientId,
      customerId: customerId ?? this.customerId,
      previousJson: previousJson ?? this.previousJson,
      nextJson: nextJson ?? this.nextJson,
      reasonCode: reasonCode ?? this.reasonCode,
      reason: reason ?? this.reason,
      at: at ?? this.at,
      syncState: syncState ?? this.syncState,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (clientId.present) {
      map['client_id'] = Variable<String>(clientId.value);
    }
    if (customerId.present) {
      map['customer_id'] = Variable<String>(customerId.value);
    }
    if (previousJson.present) {
      map['previous_json'] = Variable<String>(previousJson.value);
    }
    if (nextJson.present) {
      map['next_json'] = Variable<String>(nextJson.value);
    }
    if (reasonCode.present) {
      map['reason_code'] = Variable<String>(reasonCode.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (at.present) {
      map['at'] = Variable<DateTime>(at.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(syncState.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TagEventsCompanion(')
          ..write('clientId: $clientId, ')
          ..write('customerId: $customerId, ')
          ..write('previousJson: $previousJson, ')
          ..write('nextJson: $nextJson, ')
          ..write('reasonCode: $reasonCode, ')
          ..write('reason: $reason, ')
          ..write('at: $at, ')
          ..write('syncState: $syncState, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AttendanceEventsTable extends AttendanceEvents
    with TableInfo<$AttendanceEventsTable, AttendanceEventRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AttendanceEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _clientIdMeta = const VerificationMeta(
    'clientId',
  );
  @override
  late final GeneratedColumn<String> clientId = GeneratedColumn<String>(
    'client_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _atMeta = const VerificationMeta('at');
  @override
  late final GeneratedColumn<DateTime> at = GeneratedColumn<DateTime>(
    'at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deviceTimeMeta = const VerificationMeta(
    'deviceTime',
  );
  @override
  late final GeneratedColumn<DateTime> deviceTime = GeneratedColumn<DateTime>(
    'device_time',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _businessDateMeta = const VerificationMeta(
    'businessDate',
  );
  @override
  late final GeneratedColumn<String> businessDate = GeneratedColumn<String>(
    'business_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _latMeta = const VerificationMeta('lat');
  @override
  late final GeneratedColumn<double> lat = GeneratedColumn<double>(
    'lat',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lngMeta = const VerificationMeta('lng');
  @override
  late final GeneratedColumn<double> lng = GeneratedColumn<double>(
    'lng',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _accuracyMMeta = const VerificationMeta(
    'accuracyM',
  );
  @override
  late final GeneratedColumn<double> accuracyM = GeneratedColumn<double>(
    'accuracy_m',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _mockMeta = const VerificationMeta('mock');
  @override
  late final GeneratedColumn<bool> mock = GeneratedColumn<bool>(
    'mock',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("mock" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _selfieMediaClientIdMeta =
      const VerificationMeta('selfieMediaClientId');
  @override
  late final GeneratedColumn<String> selfieMediaClientId =
      GeneratedColumn<String>(
        'selfie_media_client_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _syncStateMeta = const VerificationMeta(
    'syncState',
  );
  @override
  late final GeneratedColumn<String> syncState = GeneratedColumn<String>(
    'sync_state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('queued'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    clientId,
    type,
    at,
    deviceTime,
    businessDate,
    lat,
    lng,
    accuracyM,
    mock,
    selfieMediaClientId,
    syncState,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'attendance_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<AttendanceEventRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('client_id')) {
      context.handle(
        _clientIdMeta,
        clientId.isAcceptableOrUnknown(data['client_id']!, _clientIdMeta),
      );
    } else if (isInserting) {
      context.missing(_clientIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('at')) {
      context.handle(_atMeta, at.isAcceptableOrUnknown(data['at']!, _atMeta));
    } else if (isInserting) {
      context.missing(_atMeta);
    }
    if (data.containsKey('device_time')) {
      context.handle(
        _deviceTimeMeta,
        deviceTime.isAcceptableOrUnknown(data['device_time']!, _deviceTimeMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceTimeMeta);
    }
    if (data.containsKey('business_date')) {
      context.handle(
        _businessDateMeta,
        businessDate.isAcceptableOrUnknown(
          data['business_date']!,
          _businessDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_businessDateMeta);
    }
    if (data.containsKey('lat')) {
      context.handle(
        _latMeta,
        lat.isAcceptableOrUnknown(data['lat']!, _latMeta),
      );
    }
    if (data.containsKey('lng')) {
      context.handle(
        _lngMeta,
        lng.isAcceptableOrUnknown(data['lng']!, _lngMeta),
      );
    }
    if (data.containsKey('accuracy_m')) {
      context.handle(
        _accuracyMMeta,
        accuracyM.isAcceptableOrUnknown(data['accuracy_m']!, _accuracyMMeta),
      );
    }
    if (data.containsKey('mock')) {
      context.handle(
        _mockMeta,
        mock.isAcceptableOrUnknown(data['mock']!, _mockMeta),
      );
    }
    if (data.containsKey('selfie_media_client_id')) {
      context.handle(
        _selfieMediaClientIdMeta,
        selfieMediaClientId.isAcceptableOrUnknown(
          data['selfie_media_client_id']!,
          _selfieMediaClientIdMeta,
        ),
      );
    }
    if (data.containsKey('sync_state')) {
      context.handle(
        _syncStateMeta,
        syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {clientId};
  @override
  AttendanceEventRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AttendanceEventRow(
      clientId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}client_id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      at: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}at'],
      )!,
      deviceTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}device_time'],
      )!,
      businessDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}business_date'],
      )!,
      lat: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}lat'],
      ),
      lng: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}lng'],
      ),
      accuracyM: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}accuracy_m'],
      ),
      mock: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}mock'],
      )!,
      selfieMediaClientId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}selfie_media_client_id'],
      ),
      syncState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_state'],
      )!,
    );
  }

  @override
  $AttendanceEventsTable createAlias(String alias) {
    return $AttendanceEventsTable(attachedDatabase, alias);
  }
}

class AttendanceEventRow extends DataClass
    implements Insertable<AttendanceEventRow> {
  final String clientId;

  /// work_in | break_start | break_end | work_out
  final String type;
  final DateTime at;
  final DateTime deviceTime;
  final String businessDate;
  final double? lat;
  final double? lng;
  final double? accuracyM;
  final bool mock;
  final String? selfieMediaClientId;
  final String syncState;
  const AttendanceEventRow({
    required this.clientId,
    required this.type,
    required this.at,
    required this.deviceTime,
    required this.businessDate,
    this.lat,
    this.lng,
    this.accuracyM,
    required this.mock,
    this.selfieMediaClientId,
    required this.syncState,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['client_id'] = Variable<String>(clientId);
    map['type'] = Variable<String>(type);
    map['at'] = Variable<DateTime>(at);
    map['device_time'] = Variable<DateTime>(deviceTime);
    map['business_date'] = Variable<String>(businessDate);
    if (!nullToAbsent || lat != null) {
      map['lat'] = Variable<double>(lat);
    }
    if (!nullToAbsent || lng != null) {
      map['lng'] = Variable<double>(lng);
    }
    if (!nullToAbsent || accuracyM != null) {
      map['accuracy_m'] = Variable<double>(accuracyM);
    }
    map['mock'] = Variable<bool>(mock);
    if (!nullToAbsent || selfieMediaClientId != null) {
      map['selfie_media_client_id'] = Variable<String>(selfieMediaClientId);
    }
    map['sync_state'] = Variable<String>(syncState);
    return map;
  }

  AttendanceEventsCompanion toCompanion(bool nullToAbsent) {
    return AttendanceEventsCompanion(
      clientId: Value(clientId),
      type: Value(type),
      at: Value(at),
      deviceTime: Value(deviceTime),
      businessDate: Value(businessDate),
      lat: lat == null && nullToAbsent ? const Value.absent() : Value(lat),
      lng: lng == null && nullToAbsent ? const Value.absent() : Value(lng),
      accuracyM: accuracyM == null && nullToAbsent
          ? const Value.absent()
          : Value(accuracyM),
      mock: Value(mock),
      selfieMediaClientId: selfieMediaClientId == null && nullToAbsent
          ? const Value.absent()
          : Value(selfieMediaClientId),
      syncState: Value(syncState),
    );
  }

  factory AttendanceEventRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AttendanceEventRow(
      clientId: serializer.fromJson<String>(json['clientId']),
      type: serializer.fromJson<String>(json['type']),
      at: serializer.fromJson<DateTime>(json['at']),
      deviceTime: serializer.fromJson<DateTime>(json['deviceTime']),
      businessDate: serializer.fromJson<String>(json['businessDate']),
      lat: serializer.fromJson<double?>(json['lat']),
      lng: serializer.fromJson<double?>(json['lng']),
      accuracyM: serializer.fromJson<double?>(json['accuracyM']),
      mock: serializer.fromJson<bool>(json['mock']),
      selfieMediaClientId: serializer.fromJson<String?>(
        json['selfieMediaClientId'],
      ),
      syncState: serializer.fromJson<String>(json['syncState']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'clientId': serializer.toJson<String>(clientId),
      'type': serializer.toJson<String>(type),
      'at': serializer.toJson<DateTime>(at),
      'deviceTime': serializer.toJson<DateTime>(deviceTime),
      'businessDate': serializer.toJson<String>(businessDate),
      'lat': serializer.toJson<double?>(lat),
      'lng': serializer.toJson<double?>(lng),
      'accuracyM': serializer.toJson<double?>(accuracyM),
      'mock': serializer.toJson<bool>(mock),
      'selfieMediaClientId': serializer.toJson<String?>(selfieMediaClientId),
      'syncState': serializer.toJson<String>(syncState),
    };
  }

  AttendanceEventRow copyWith({
    String? clientId,
    String? type,
    DateTime? at,
    DateTime? deviceTime,
    String? businessDate,
    Value<double?> lat = const Value.absent(),
    Value<double?> lng = const Value.absent(),
    Value<double?> accuracyM = const Value.absent(),
    bool? mock,
    Value<String?> selfieMediaClientId = const Value.absent(),
    String? syncState,
  }) => AttendanceEventRow(
    clientId: clientId ?? this.clientId,
    type: type ?? this.type,
    at: at ?? this.at,
    deviceTime: deviceTime ?? this.deviceTime,
    businessDate: businessDate ?? this.businessDate,
    lat: lat.present ? lat.value : this.lat,
    lng: lng.present ? lng.value : this.lng,
    accuracyM: accuracyM.present ? accuracyM.value : this.accuracyM,
    mock: mock ?? this.mock,
    selfieMediaClientId: selfieMediaClientId.present
        ? selfieMediaClientId.value
        : this.selfieMediaClientId,
    syncState: syncState ?? this.syncState,
  );
  AttendanceEventRow copyWithCompanion(AttendanceEventsCompanion data) {
    return AttendanceEventRow(
      clientId: data.clientId.present ? data.clientId.value : this.clientId,
      type: data.type.present ? data.type.value : this.type,
      at: data.at.present ? data.at.value : this.at,
      deviceTime: data.deviceTime.present
          ? data.deviceTime.value
          : this.deviceTime,
      businessDate: data.businessDate.present
          ? data.businessDate.value
          : this.businessDate,
      lat: data.lat.present ? data.lat.value : this.lat,
      lng: data.lng.present ? data.lng.value : this.lng,
      accuracyM: data.accuracyM.present ? data.accuracyM.value : this.accuracyM,
      mock: data.mock.present ? data.mock.value : this.mock,
      selfieMediaClientId: data.selfieMediaClientId.present
          ? data.selfieMediaClientId.value
          : this.selfieMediaClientId,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AttendanceEventRow(')
          ..write('clientId: $clientId, ')
          ..write('type: $type, ')
          ..write('at: $at, ')
          ..write('deviceTime: $deviceTime, ')
          ..write('businessDate: $businessDate, ')
          ..write('lat: $lat, ')
          ..write('lng: $lng, ')
          ..write('accuracyM: $accuracyM, ')
          ..write('mock: $mock, ')
          ..write('selfieMediaClientId: $selfieMediaClientId, ')
          ..write('syncState: $syncState')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    clientId,
    type,
    at,
    deviceTime,
    businessDate,
    lat,
    lng,
    accuracyM,
    mock,
    selfieMediaClientId,
    syncState,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AttendanceEventRow &&
          other.clientId == this.clientId &&
          other.type == this.type &&
          other.at == this.at &&
          other.deviceTime == this.deviceTime &&
          other.businessDate == this.businessDate &&
          other.lat == this.lat &&
          other.lng == this.lng &&
          other.accuracyM == this.accuracyM &&
          other.mock == this.mock &&
          other.selfieMediaClientId == this.selfieMediaClientId &&
          other.syncState == this.syncState);
}

class AttendanceEventsCompanion extends UpdateCompanion<AttendanceEventRow> {
  final Value<String> clientId;
  final Value<String> type;
  final Value<DateTime> at;
  final Value<DateTime> deviceTime;
  final Value<String> businessDate;
  final Value<double?> lat;
  final Value<double?> lng;
  final Value<double?> accuracyM;
  final Value<bool> mock;
  final Value<String?> selfieMediaClientId;
  final Value<String> syncState;
  final Value<int> rowid;
  const AttendanceEventsCompanion({
    this.clientId = const Value.absent(),
    this.type = const Value.absent(),
    this.at = const Value.absent(),
    this.deviceTime = const Value.absent(),
    this.businessDate = const Value.absent(),
    this.lat = const Value.absent(),
    this.lng = const Value.absent(),
    this.accuracyM = const Value.absent(),
    this.mock = const Value.absent(),
    this.selfieMediaClientId = const Value.absent(),
    this.syncState = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AttendanceEventsCompanion.insert({
    required String clientId,
    required String type,
    required DateTime at,
    required DateTime deviceTime,
    required String businessDate,
    this.lat = const Value.absent(),
    this.lng = const Value.absent(),
    this.accuracyM = const Value.absent(),
    this.mock = const Value.absent(),
    this.selfieMediaClientId = const Value.absent(),
    this.syncState = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : clientId = Value(clientId),
       type = Value(type),
       at = Value(at),
       deviceTime = Value(deviceTime),
       businessDate = Value(businessDate);
  static Insertable<AttendanceEventRow> custom({
    Expression<String>? clientId,
    Expression<String>? type,
    Expression<DateTime>? at,
    Expression<DateTime>? deviceTime,
    Expression<String>? businessDate,
    Expression<double>? lat,
    Expression<double>? lng,
    Expression<double>? accuracyM,
    Expression<bool>? mock,
    Expression<String>? selfieMediaClientId,
    Expression<String>? syncState,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (clientId != null) 'client_id': clientId,
      if (type != null) 'type': type,
      if (at != null) 'at': at,
      if (deviceTime != null) 'device_time': deviceTime,
      if (businessDate != null) 'business_date': businessDate,
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
      if (accuracyM != null) 'accuracy_m': accuracyM,
      if (mock != null) 'mock': mock,
      if (selfieMediaClientId != null)
        'selfie_media_client_id': selfieMediaClientId,
      if (syncState != null) 'sync_state': syncState,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AttendanceEventsCompanion copyWith({
    Value<String>? clientId,
    Value<String>? type,
    Value<DateTime>? at,
    Value<DateTime>? deviceTime,
    Value<String>? businessDate,
    Value<double?>? lat,
    Value<double?>? lng,
    Value<double?>? accuracyM,
    Value<bool>? mock,
    Value<String?>? selfieMediaClientId,
    Value<String>? syncState,
    Value<int>? rowid,
  }) {
    return AttendanceEventsCompanion(
      clientId: clientId ?? this.clientId,
      type: type ?? this.type,
      at: at ?? this.at,
      deviceTime: deviceTime ?? this.deviceTime,
      businessDate: businessDate ?? this.businessDate,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      accuracyM: accuracyM ?? this.accuracyM,
      mock: mock ?? this.mock,
      selfieMediaClientId: selfieMediaClientId ?? this.selfieMediaClientId,
      syncState: syncState ?? this.syncState,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (clientId.present) {
      map['client_id'] = Variable<String>(clientId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (at.present) {
      map['at'] = Variable<DateTime>(at.value);
    }
    if (deviceTime.present) {
      map['device_time'] = Variable<DateTime>(deviceTime.value);
    }
    if (businessDate.present) {
      map['business_date'] = Variable<String>(businessDate.value);
    }
    if (lat.present) {
      map['lat'] = Variable<double>(lat.value);
    }
    if (lng.present) {
      map['lng'] = Variable<double>(lng.value);
    }
    if (accuracyM.present) {
      map['accuracy_m'] = Variable<double>(accuracyM.value);
    }
    if (mock.present) {
      map['mock'] = Variable<bool>(mock.value);
    }
    if (selfieMediaClientId.present) {
      map['selfie_media_client_id'] = Variable<String>(
        selfieMediaClientId.value,
      );
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(syncState.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AttendanceEventsCompanion(')
          ..write('clientId: $clientId, ')
          ..write('type: $type, ')
          ..write('at: $at, ')
          ..write('deviceTime: $deviceTime, ')
          ..write('businessDate: $businessDate, ')
          ..write('lat: $lat, ')
          ..write('lng: $lng, ')
          ..write('accuracyM: $accuracyM, ')
          ..write('mock: $mock, ')
          ..write('selfieMediaClientId: $selfieMediaClientId, ')
          ..write('syncState: $syncState, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AttendanceDaysTable extends AttendanceDays
    with TableInfo<$AttendanceDaysTable, AttendanceDayRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AttendanceDaysTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _businessDateMeta = const VerificationMeta(
    'businessDate',
  );
  @override
  late final GeneratedColumn<String> businessDate = GeneratedColumn<String>(
    'business_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _firstInMeta = const VerificationMeta(
    'firstIn',
  );
  @override
  late final GeneratedColumn<DateTime> firstIn = GeneratedColumn<DateTime>(
    'first_in',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastOutMeta = const VerificationMeta(
    'lastOut',
  );
  @override
  late final GeneratedColumn<DateTime> lastOut = GeneratedColumn<DateTime>(
    'last_out',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _breakMinMeta = const VerificationMeta(
    'breakMin',
  );
  @override
  late final GeneratedColumn<int> breakMin = GeneratedColumn<int>(
    'break_min',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lateMinMeta = const VerificationMeta(
    'lateMin',
  );
  @override
  late final GeneratedColumn<int> lateMin = GeneratedColumn<int>(
    'late_min',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _breaksJsonMeta = const VerificationMeta(
    'breaksJson',
  );
  @override
  late final GeneratedColumn<String> breaksJson = GeneratedColumn<String>(
    'breaks_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    businessDate,
    status,
    firstIn,
    lastOut,
    breakMin,
    lateMin,
    breaksJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'attendance_day';
  @override
  VerificationContext validateIntegrity(
    Insertable<AttendanceDayRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('business_date')) {
      context.handle(
        _businessDateMeta,
        businessDate.isAcceptableOrUnknown(
          data['business_date']!,
          _businessDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_businessDateMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('first_in')) {
      context.handle(
        _firstInMeta,
        firstIn.isAcceptableOrUnknown(data['first_in']!, _firstInMeta),
      );
    }
    if (data.containsKey('last_out')) {
      context.handle(
        _lastOutMeta,
        lastOut.isAcceptableOrUnknown(data['last_out']!, _lastOutMeta),
      );
    }
    if (data.containsKey('break_min')) {
      context.handle(
        _breakMinMeta,
        breakMin.isAcceptableOrUnknown(data['break_min']!, _breakMinMeta),
      );
    }
    if (data.containsKey('late_min')) {
      context.handle(
        _lateMinMeta,
        lateMin.isAcceptableOrUnknown(data['late_min']!, _lateMinMeta),
      );
    }
    if (data.containsKey('breaks_json')) {
      context.handle(
        _breaksJsonMeta,
        breaksJson.isAcceptableOrUnknown(data['breaks_json']!, _breaksJsonMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {businessDate};
  @override
  AttendanceDayRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AttendanceDayRow(
      businessDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}business_date'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      firstIn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}first_in'],
      ),
      lastOut: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_out'],
      ),
      breakMin: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}break_min'],
      )!,
      lateMin: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}late_min'],
      )!,
      breaksJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}breaks_json'],
      )!,
    );
  }

  @override
  $AttendanceDaysTable createAlias(String alias) {
    return $AttendanceDaysTable(attachedDatabase, alias);
  }
}

class AttendanceDayRow extends DataClass
    implements Insertable<AttendanceDayRow> {
  final String businessDate;
  final String status;
  final DateTime? firstIn;
  final DateTime? lastOut;
  final int breakMin;
  final int lateMin;
  final String breaksJson;
  const AttendanceDayRow({
    required this.businessDate,
    required this.status,
    this.firstIn,
    this.lastOut,
    required this.breakMin,
    required this.lateMin,
    required this.breaksJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['business_date'] = Variable<String>(businessDate);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || firstIn != null) {
      map['first_in'] = Variable<DateTime>(firstIn);
    }
    if (!nullToAbsent || lastOut != null) {
      map['last_out'] = Variable<DateTime>(lastOut);
    }
    map['break_min'] = Variable<int>(breakMin);
    map['late_min'] = Variable<int>(lateMin);
    map['breaks_json'] = Variable<String>(breaksJson);
    return map;
  }

  AttendanceDaysCompanion toCompanion(bool nullToAbsent) {
    return AttendanceDaysCompanion(
      businessDate: Value(businessDate),
      status: Value(status),
      firstIn: firstIn == null && nullToAbsent
          ? const Value.absent()
          : Value(firstIn),
      lastOut: lastOut == null && nullToAbsent
          ? const Value.absent()
          : Value(lastOut),
      breakMin: Value(breakMin),
      lateMin: Value(lateMin),
      breaksJson: Value(breaksJson),
    );
  }

  factory AttendanceDayRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AttendanceDayRow(
      businessDate: serializer.fromJson<String>(json['businessDate']),
      status: serializer.fromJson<String>(json['status']),
      firstIn: serializer.fromJson<DateTime?>(json['firstIn']),
      lastOut: serializer.fromJson<DateTime?>(json['lastOut']),
      breakMin: serializer.fromJson<int>(json['breakMin']),
      lateMin: serializer.fromJson<int>(json['lateMin']),
      breaksJson: serializer.fromJson<String>(json['breaksJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'businessDate': serializer.toJson<String>(businessDate),
      'status': serializer.toJson<String>(status),
      'firstIn': serializer.toJson<DateTime?>(firstIn),
      'lastOut': serializer.toJson<DateTime?>(lastOut),
      'breakMin': serializer.toJson<int>(breakMin),
      'lateMin': serializer.toJson<int>(lateMin),
      'breaksJson': serializer.toJson<String>(breaksJson),
    };
  }

  AttendanceDayRow copyWith({
    String? businessDate,
    String? status,
    Value<DateTime?> firstIn = const Value.absent(),
    Value<DateTime?> lastOut = const Value.absent(),
    int? breakMin,
    int? lateMin,
    String? breaksJson,
  }) => AttendanceDayRow(
    businessDate: businessDate ?? this.businessDate,
    status: status ?? this.status,
    firstIn: firstIn.present ? firstIn.value : this.firstIn,
    lastOut: lastOut.present ? lastOut.value : this.lastOut,
    breakMin: breakMin ?? this.breakMin,
    lateMin: lateMin ?? this.lateMin,
    breaksJson: breaksJson ?? this.breaksJson,
  );
  AttendanceDayRow copyWithCompanion(AttendanceDaysCompanion data) {
    return AttendanceDayRow(
      businessDate: data.businessDate.present
          ? data.businessDate.value
          : this.businessDate,
      status: data.status.present ? data.status.value : this.status,
      firstIn: data.firstIn.present ? data.firstIn.value : this.firstIn,
      lastOut: data.lastOut.present ? data.lastOut.value : this.lastOut,
      breakMin: data.breakMin.present ? data.breakMin.value : this.breakMin,
      lateMin: data.lateMin.present ? data.lateMin.value : this.lateMin,
      breaksJson: data.breaksJson.present
          ? data.breaksJson.value
          : this.breaksJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AttendanceDayRow(')
          ..write('businessDate: $businessDate, ')
          ..write('status: $status, ')
          ..write('firstIn: $firstIn, ')
          ..write('lastOut: $lastOut, ')
          ..write('breakMin: $breakMin, ')
          ..write('lateMin: $lateMin, ')
          ..write('breaksJson: $breaksJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    businessDate,
    status,
    firstIn,
    lastOut,
    breakMin,
    lateMin,
    breaksJson,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AttendanceDayRow &&
          other.businessDate == this.businessDate &&
          other.status == this.status &&
          other.firstIn == this.firstIn &&
          other.lastOut == this.lastOut &&
          other.breakMin == this.breakMin &&
          other.lateMin == this.lateMin &&
          other.breaksJson == this.breaksJson);
}

class AttendanceDaysCompanion extends UpdateCompanion<AttendanceDayRow> {
  final Value<String> businessDate;
  final Value<String> status;
  final Value<DateTime?> firstIn;
  final Value<DateTime?> lastOut;
  final Value<int> breakMin;
  final Value<int> lateMin;
  final Value<String> breaksJson;
  final Value<int> rowid;
  const AttendanceDaysCompanion({
    this.businessDate = const Value.absent(),
    this.status = const Value.absent(),
    this.firstIn = const Value.absent(),
    this.lastOut = const Value.absent(),
    this.breakMin = const Value.absent(),
    this.lateMin = const Value.absent(),
    this.breaksJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AttendanceDaysCompanion.insert({
    required String businessDate,
    required String status,
    this.firstIn = const Value.absent(),
    this.lastOut = const Value.absent(),
    this.breakMin = const Value.absent(),
    this.lateMin = const Value.absent(),
    this.breaksJson = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : businessDate = Value(businessDate),
       status = Value(status);
  static Insertable<AttendanceDayRow> custom({
    Expression<String>? businessDate,
    Expression<String>? status,
    Expression<DateTime>? firstIn,
    Expression<DateTime>? lastOut,
    Expression<int>? breakMin,
    Expression<int>? lateMin,
    Expression<String>? breaksJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (businessDate != null) 'business_date': businessDate,
      if (status != null) 'status': status,
      if (firstIn != null) 'first_in': firstIn,
      if (lastOut != null) 'last_out': lastOut,
      if (breakMin != null) 'break_min': breakMin,
      if (lateMin != null) 'late_min': lateMin,
      if (breaksJson != null) 'breaks_json': breaksJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AttendanceDaysCompanion copyWith({
    Value<String>? businessDate,
    Value<String>? status,
    Value<DateTime?>? firstIn,
    Value<DateTime?>? lastOut,
    Value<int>? breakMin,
    Value<int>? lateMin,
    Value<String>? breaksJson,
    Value<int>? rowid,
  }) {
    return AttendanceDaysCompanion(
      businessDate: businessDate ?? this.businessDate,
      status: status ?? this.status,
      firstIn: firstIn ?? this.firstIn,
      lastOut: lastOut ?? this.lastOut,
      breakMin: breakMin ?? this.breakMin,
      lateMin: lateMin ?? this.lateMin,
      breaksJson: breaksJson ?? this.breaksJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (businessDate.present) {
      map['business_date'] = Variable<String>(businessDate.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (firstIn.present) {
      map['first_in'] = Variable<DateTime>(firstIn.value);
    }
    if (lastOut.present) {
      map['last_out'] = Variable<DateTime>(lastOut.value);
    }
    if (breakMin.present) {
      map['break_min'] = Variable<int>(breakMin.value);
    }
    if (lateMin.present) {
      map['late_min'] = Variable<int>(lateMin.value);
    }
    if (breaksJson.present) {
      map['breaks_json'] = Variable<String>(breaksJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AttendanceDaysCompanion(')
          ..write('businessDate: $businessDate, ')
          ..write('status: $status, ')
          ..write('firstIn: $firstIn, ')
          ..write('lastOut: $lastOut, ')
          ..write('breakMin: $breakMin, ')
          ..write('lateMin: $lateMin, ')
          ..write('breaksJson: $breaksJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $HandoversTable extends Handovers
    with TableInfo<$HandoversTable, HandoverRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HandoversTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _serverIdMeta = const VerificationMeta(
    'serverId',
  );
  @override
  late final GeneratedColumn<String> serverId = GeneratedColumn<String>(
    'server_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fromUserNameMeta = const VerificationMeta(
    'fromUserName',
  );
  @override
  late final GeneratedColumn<String> fromUserName = GeneratedColumn<String>(
    'from_user_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _toUserIdMeta = const VerificationMeta(
    'toUserId',
  );
  @override
  late final GeneratedColumn<String> toUserId = GeneratedColumn<String>(
    'to_user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _summaryJsonMeta = const VerificationMeta(
    'summaryJson',
  );
  @override
  late final GeneratedColumn<String> summaryJson = GeneratedColumn<String>(
    'summary_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
    'reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _expiresAtMeta = const VerificationMeta(
    'expiresAt',
  );
  @override
  late final GeneratedColumn<DateTime> expiresAt = GeneratedColumn<DateTime>(
    'expires_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    serverId,
    fromUserName,
    toUserId,
    summaryJson,
    reason,
    status,
    expiresAt,
    role,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'handovers';
  @override
  VerificationContext validateIntegrity(
    Insertable<HandoverRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('server_id')) {
      context.handle(
        _serverIdMeta,
        serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta),
      );
    } else if (isInserting) {
      context.missing(_serverIdMeta);
    }
    if (data.containsKey('from_user_name')) {
      context.handle(
        _fromUserNameMeta,
        fromUserName.isAcceptableOrUnknown(
          data['from_user_name']!,
          _fromUserNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_fromUserNameMeta);
    }
    if (data.containsKey('to_user_id')) {
      context.handle(
        _toUserIdMeta,
        toUserId.isAcceptableOrUnknown(data['to_user_id']!, _toUserIdMeta),
      );
    } else if (isInserting) {
      context.missing(_toUserIdMeta);
    }
    if (data.containsKey('summary_json')) {
      context.handle(
        _summaryJsonMeta,
        summaryJson.isAcceptableOrUnknown(
          data['summary_json']!,
          _summaryJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_summaryJsonMeta);
    }
    if (data.containsKey('reason')) {
      context.handle(
        _reasonMeta,
        reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('expires_at')) {
      context.handle(
        _expiresAtMeta,
        expiresAt.isAcceptableOrUnknown(data['expires_at']!, _expiresAtMeta),
      );
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {serverId};
  @override
  HandoverRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HandoverRow(
      serverId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}server_id'],
      )!,
      fromUserName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}from_user_name'],
      )!,
      toUserId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}to_user_id'],
      )!,
      summaryJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}summary_json'],
      )!,
      reason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reason'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      expiresAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}expires_at'],
      ),
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
    );
  }

  @override
  $HandoversTable createAlias(String alias) {
    return $HandoversTable(attachedDatabase, alias);
  }
}

class HandoverRow extends DataClass implements Insertable<HandoverRow> {
  final String serverId;
  final String fromUserName;
  final String toUserId;
  final String summaryJson;
  final String? reason;
  final String status;
  final DateTime? expiresAt;

  /// incoming | outgoing
  final String role;
  const HandoverRow({
    required this.serverId,
    required this.fromUserName,
    required this.toUserId,
    required this.summaryJson,
    this.reason,
    required this.status,
    this.expiresAt,
    required this.role,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['server_id'] = Variable<String>(serverId);
    map['from_user_name'] = Variable<String>(fromUserName);
    map['to_user_id'] = Variable<String>(toUserId);
    map['summary_json'] = Variable<String>(summaryJson);
    if (!nullToAbsent || reason != null) {
      map['reason'] = Variable<String>(reason);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || expiresAt != null) {
      map['expires_at'] = Variable<DateTime>(expiresAt);
    }
    map['role'] = Variable<String>(role);
    return map;
  }

  HandoversCompanion toCompanion(bool nullToAbsent) {
    return HandoversCompanion(
      serverId: Value(serverId),
      fromUserName: Value(fromUserName),
      toUserId: Value(toUserId),
      summaryJson: Value(summaryJson),
      reason: reason == null && nullToAbsent
          ? const Value.absent()
          : Value(reason),
      status: Value(status),
      expiresAt: expiresAt == null && nullToAbsent
          ? const Value.absent()
          : Value(expiresAt),
      role: Value(role),
    );
  }

  factory HandoverRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HandoverRow(
      serverId: serializer.fromJson<String>(json['serverId']),
      fromUserName: serializer.fromJson<String>(json['fromUserName']),
      toUserId: serializer.fromJson<String>(json['toUserId']),
      summaryJson: serializer.fromJson<String>(json['summaryJson']),
      reason: serializer.fromJson<String?>(json['reason']),
      status: serializer.fromJson<String>(json['status']),
      expiresAt: serializer.fromJson<DateTime?>(json['expiresAt']),
      role: serializer.fromJson<String>(json['role']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'serverId': serializer.toJson<String>(serverId),
      'fromUserName': serializer.toJson<String>(fromUserName),
      'toUserId': serializer.toJson<String>(toUserId),
      'summaryJson': serializer.toJson<String>(summaryJson),
      'reason': serializer.toJson<String?>(reason),
      'status': serializer.toJson<String>(status),
      'expiresAt': serializer.toJson<DateTime?>(expiresAt),
      'role': serializer.toJson<String>(role),
    };
  }

  HandoverRow copyWith({
    String? serverId,
    String? fromUserName,
    String? toUserId,
    String? summaryJson,
    Value<String?> reason = const Value.absent(),
    String? status,
    Value<DateTime?> expiresAt = const Value.absent(),
    String? role,
  }) => HandoverRow(
    serverId: serverId ?? this.serverId,
    fromUserName: fromUserName ?? this.fromUserName,
    toUserId: toUserId ?? this.toUserId,
    summaryJson: summaryJson ?? this.summaryJson,
    reason: reason.present ? reason.value : this.reason,
    status: status ?? this.status,
    expiresAt: expiresAt.present ? expiresAt.value : this.expiresAt,
    role: role ?? this.role,
  );
  HandoverRow copyWithCompanion(HandoversCompanion data) {
    return HandoverRow(
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      fromUserName: data.fromUserName.present
          ? data.fromUserName.value
          : this.fromUserName,
      toUserId: data.toUserId.present ? data.toUserId.value : this.toUserId,
      summaryJson: data.summaryJson.present
          ? data.summaryJson.value
          : this.summaryJson,
      reason: data.reason.present ? data.reason.value : this.reason,
      status: data.status.present ? data.status.value : this.status,
      expiresAt: data.expiresAt.present ? data.expiresAt.value : this.expiresAt,
      role: data.role.present ? data.role.value : this.role,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HandoverRow(')
          ..write('serverId: $serverId, ')
          ..write('fromUserName: $fromUserName, ')
          ..write('toUserId: $toUserId, ')
          ..write('summaryJson: $summaryJson, ')
          ..write('reason: $reason, ')
          ..write('status: $status, ')
          ..write('expiresAt: $expiresAt, ')
          ..write('role: $role')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    serverId,
    fromUserName,
    toUserId,
    summaryJson,
    reason,
    status,
    expiresAt,
    role,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HandoverRow &&
          other.serverId == this.serverId &&
          other.fromUserName == this.fromUserName &&
          other.toUserId == this.toUserId &&
          other.summaryJson == this.summaryJson &&
          other.reason == this.reason &&
          other.status == this.status &&
          other.expiresAt == this.expiresAt &&
          other.role == this.role);
}

class HandoversCompanion extends UpdateCompanion<HandoverRow> {
  final Value<String> serverId;
  final Value<String> fromUserName;
  final Value<String> toUserId;
  final Value<String> summaryJson;
  final Value<String?> reason;
  final Value<String> status;
  final Value<DateTime?> expiresAt;
  final Value<String> role;
  final Value<int> rowid;
  const HandoversCompanion({
    this.serverId = const Value.absent(),
    this.fromUserName = const Value.absent(),
    this.toUserId = const Value.absent(),
    this.summaryJson = const Value.absent(),
    this.reason = const Value.absent(),
    this.status = const Value.absent(),
    this.expiresAt = const Value.absent(),
    this.role = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HandoversCompanion.insert({
    required String serverId,
    required String fromUserName,
    required String toUserId,
    required String summaryJson,
    this.reason = const Value.absent(),
    required String status,
    this.expiresAt = const Value.absent(),
    required String role,
    this.rowid = const Value.absent(),
  }) : serverId = Value(serverId),
       fromUserName = Value(fromUserName),
       toUserId = Value(toUserId),
       summaryJson = Value(summaryJson),
       status = Value(status),
       role = Value(role);
  static Insertable<HandoverRow> custom({
    Expression<String>? serverId,
    Expression<String>? fromUserName,
    Expression<String>? toUserId,
    Expression<String>? summaryJson,
    Expression<String>? reason,
    Expression<String>? status,
    Expression<DateTime>? expiresAt,
    Expression<String>? role,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (serverId != null) 'server_id': serverId,
      if (fromUserName != null) 'from_user_name': fromUserName,
      if (toUserId != null) 'to_user_id': toUserId,
      if (summaryJson != null) 'summary_json': summaryJson,
      if (reason != null) 'reason': reason,
      if (status != null) 'status': status,
      if (expiresAt != null) 'expires_at': expiresAt,
      if (role != null) 'role': role,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HandoversCompanion copyWith({
    Value<String>? serverId,
    Value<String>? fromUserName,
    Value<String>? toUserId,
    Value<String>? summaryJson,
    Value<String?>? reason,
    Value<String>? status,
    Value<DateTime?>? expiresAt,
    Value<String>? role,
    Value<int>? rowid,
  }) {
    return HandoversCompanion(
      serverId: serverId ?? this.serverId,
      fromUserName: fromUserName ?? this.fromUserName,
      toUserId: toUserId ?? this.toUserId,
      summaryJson: summaryJson ?? this.summaryJson,
      reason: reason ?? this.reason,
      status: status ?? this.status,
      expiresAt: expiresAt ?? this.expiresAt,
      role: role ?? this.role,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (serverId.present) {
      map['server_id'] = Variable<String>(serverId.value);
    }
    if (fromUserName.present) {
      map['from_user_name'] = Variable<String>(fromUserName.value);
    }
    if (toUserId.present) {
      map['to_user_id'] = Variable<String>(toUserId.value);
    }
    if (summaryJson.present) {
      map['summary_json'] = Variable<String>(summaryJson.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (expiresAt.present) {
      map['expires_at'] = Variable<DateTime>(expiresAt.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HandoversCompanion(')
          ..write('serverId: $serverId, ')
          ..write('fromUserName: $fromUserName, ')
          ..write('toUserId: $toUserId, ')
          ..write('summaryJson: $summaryJson, ')
          ..write('reason: $reason, ')
          ..write('status: $status, ')
          ..write('expiresAt: $expiresAt, ')
          ..write('role: $role, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MediaQueueTable extends MediaQueue
    with TableInfo<$MediaQueueTable, MediaQueueRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MediaQueueTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _clientIdMeta = const VerificationMeta(
    'clientId',
  );
  @override
  late final GeneratedColumn<String> clientId = GeneratedColumn<String>(
    'client_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localPathMeta = const VerificationMeta(
    'localPath',
  );
  @override
  late final GeneratedColumn<String> localPath = GeneratedColumn<String>(
    'local_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sha256Meta = const VerificationMeta('sha256');
  @override
  late final GeneratedColumn<String> sha256 = GeneratedColumn<String>(
    'sha256',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sizeBytesMeta = const VerificationMeta(
    'sizeBytes',
  );
  @override
  late final GeneratedColumn<int> sizeBytes = GeneratedColumn<int>(
    'size_bytes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _capturedAtMeta = const VerificationMeta(
    'capturedAt',
  );
  @override
  late final GeneratedColumn<DateTime> capturedAt = GeneratedColumn<DateTime>(
    'captured_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerEntityMeta = const VerificationMeta(
    'ownerEntity',
  );
  @override
  late final GeneratedColumn<String> ownerEntity = GeneratedColumn<String>(
    'owner_entity',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerClientIdMeta = const VerificationMeta(
    'ownerClientId',
  );
  @override
  late final GeneratedColumn<String> ownerClientId = GeneratedColumn<String>(
    'owner_client_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _serverMediaIdMeta = const VerificationMeta(
    'serverMediaId',
  );
  @override
  late final GeneratedColumn<String> serverMediaId = GeneratedColumn<String>(
    'server_media_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
    'state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _attemptsMeta = const VerificationMeta(
    'attempts',
  );
  @override
  late final GeneratedColumn<int> attempts = GeneratedColumn<int>(
    'attempts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _nextAttemptAtMeta = const VerificationMeta(
    'nextAttemptAt',
  );
  @override
  late final GeneratedColumn<DateTime> nextAttemptAt =
      GeneratedColumn<DateTime>(
        'next_attempt_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    clientId,
    kind,
    localPath,
    sha256,
    sizeBytes,
    capturedAt,
    ownerEntity,
    ownerClientId,
    serverMediaId,
    state,
    attempts,
    nextAttemptAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'media_queue';
  @override
  VerificationContext validateIntegrity(
    Insertable<MediaQueueRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('client_id')) {
      context.handle(
        _clientIdMeta,
        clientId.isAcceptableOrUnknown(data['client_id']!, _clientIdMeta),
      );
    } else if (isInserting) {
      context.missing(_clientIdMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('local_path')) {
      context.handle(
        _localPathMeta,
        localPath.isAcceptableOrUnknown(data['local_path']!, _localPathMeta),
      );
    } else if (isInserting) {
      context.missing(_localPathMeta);
    }
    if (data.containsKey('sha256')) {
      context.handle(
        _sha256Meta,
        sha256.isAcceptableOrUnknown(data['sha256']!, _sha256Meta),
      );
    } else if (isInserting) {
      context.missing(_sha256Meta);
    }
    if (data.containsKey('size_bytes')) {
      context.handle(
        _sizeBytesMeta,
        sizeBytes.isAcceptableOrUnknown(data['size_bytes']!, _sizeBytesMeta),
      );
    } else if (isInserting) {
      context.missing(_sizeBytesMeta);
    }
    if (data.containsKey('captured_at')) {
      context.handle(
        _capturedAtMeta,
        capturedAt.isAcceptableOrUnknown(data['captured_at']!, _capturedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_capturedAtMeta);
    }
    if (data.containsKey('owner_entity')) {
      context.handle(
        _ownerEntityMeta,
        ownerEntity.isAcceptableOrUnknown(
          data['owner_entity']!,
          _ownerEntityMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_ownerEntityMeta);
    }
    if (data.containsKey('owner_client_id')) {
      context.handle(
        _ownerClientIdMeta,
        ownerClientId.isAcceptableOrUnknown(
          data['owner_client_id']!,
          _ownerClientIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_ownerClientIdMeta);
    }
    if (data.containsKey('server_media_id')) {
      context.handle(
        _serverMediaIdMeta,
        serverMediaId.isAcceptableOrUnknown(
          data['server_media_id']!,
          _serverMediaIdMeta,
        ),
      );
    }
    if (data.containsKey('state')) {
      context.handle(
        _stateMeta,
        state.isAcceptableOrUnknown(data['state']!, _stateMeta),
      );
    }
    if (data.containsKey('attempts')) {
      context.handle(
        _attemptsMeta,
        attempts.isAcceptableOrUnknown(data['attempts']!, _attemptsMeta),
      );
    }
    if (data.containsKey('next_attempt_at')) {
      context.handle(
        _nextAttemptAtMeta,
        nextAttemptAt.isAcceptableOrUnknown(
          data['next_attempt_at']!,
          _nextAttemptAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {clientId};
  @override
  MediaQueueRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MediaQueueRow(
      clientId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}client_id'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      localPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_path'],
      )!,
      sha256: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sha256'],
      )!,
      sizeBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}size_bytes'],
      )!,
      capturedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}captured_at'],
      )!,
      ownerEntity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_entity'],
      )!,
      ownerClientId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_client_id'],
      )!,
      serverMediaId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}server_media_id'],
      ),
      state: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}state'],
      )!,
      attempts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempts'],
      )!,
      nextAttemptAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}next_attempt_at'],
      ),
    );
  }

  @override
  $MediaQueueTable createAlias(String alias) {
    return $MediaQueueTable(attachedDatabase, alias);
  }
}

class MediaQueueRow extends DataClass implements Insertable<MediaQueueRow> {
  final String clientId;
  final String kind;
  final String localPath;
  final String sha256;
  final int sizeBytes;
  final DateTime capturedAt;
  final String ownerEntity;
  final String ownerClientId;
  final String? serverMediaId;
  final String state;
  final int attempts;
  final DateTime? nextAttemptAt;
  const MediaQueueRow({
    required this.clientId,
    required this.kind,
    required this.localPath,
    required this.sha256,
    required this.sizeBytes,
    required this.capturedAt,
    required this.ownerEntity,
    required this.ownerClientId,
    this.serverMediaId,
    required this.state,
    required this.attempts,
    this.nextAttemptAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['client_id'] = Variable<String>(clientId);
    map['kind'] = Variable<String>(kind);
    map['local_path'] = Variable<String>(localPath);
    map['sha256'] = Variable<String>(sha256);
    map['size_bytes'] = Variable<int>(sizeBytes);
    map['captured_at'] = Variable<DateTime>(capturedAt);
    map['owner_entity'] = Variable<String>(ownerEntity);
    map['owner_client_id'] = Variable<String>(ownerClientId);
    if (!nullToAbsent || serverMediaId != null) {
      map['server_media_id'] = Variable<String>(serverMediaId);
    }
    map['state'] = Variable<String>(state);
    map['attempts'] = Variable<int>(attempts);
    if (!nullToAbsent || nextAttemptAt != null) {
      map['next_attempt_at'] = Variable<DateTime>(nextAttemptAt);
    }
    return map;
  }

  MediaQueueCompanion toCompanion(bool nullToAbsent) {
    return MediaQueueCompanion(
      clientId: Value(clientId),
      kind: Value(kind),
      localPath: Value(localPath),
      sha256: Value(sha256),
      sizeBytes: Value(sizeBytes),
      capturedAt: Value(capturedAt),
      ownerEntity: Value(ownerEntity),
      ownerClientId: Value(ownerClientId),
      serverMediaId: serverMediaId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverMediaId),
      state: Value(state),
      attempts: Value(attempts),
      nextAttemptAt: nextAttemptAt == null && nullToAbsent
          ? const Value.absent()
          : Value(nextAttemptAt),
    );
  }

  factory MediaQueueRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MediaQueueRow(
      clientId: serializer.fromJson<String>(json['clientId']),
      kind: serializer.fromJson<String>(json['kind']),
      localPath: serializer.fromJson<String>(json['localPath']),
      sha256: serializer.fromJson<String>(json['sha256']),
      sizeBytes: serializer.fromJson<int>(json['sizeBytes']),
      capturedAt: serializer.fromJson<DateTime>(json['capturedAt']),
      ownerEntity: serializer.fromJson<String>(json['ownerEntity']),
      ownerClientId: serializer.fromJson<String>(json['ownerClientId']),
      serverMediaId: serializer.fromJson<String?>(json['serverMediaId']),
      state: serializer.fromJson<String>(json['state']),
      attempts: serializer.fromJson<int>(json['attempts']),
      nextAttemptAt: serializer.fromJson<DateTime?>(json['nextAttemptAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'clientId': serializer.toJson<String>(clientId),
      'kind': serializer.toJson<String>(kind),
      'localPath': serializer.toJson<String>(localPath),
      'sha256': serializer.toJson<String>(sha256),
      'sizeBytes': serializer.toJson<int>(sizeBytes),
      'capturedAt': serializer.toJson<DateTime>(capturedAt),
      'ownerEntity': serializer.toJson<String>(ownerEntity),
      'ownerClientId': serializer.toJson<String>(ownerClientId),
      'serverMediaId': serializer.toJson<String?>(serverMediaId),
      'state': serializer.toJson<String>(state),
      'attempts': serializer.toJson<int>(attempts),
      'nextAttemptAt': serializer.toJson<DateTime?>(nextAttemptAt),
    };
  }

  MediaQueueRow copyWith({
    String? clientId,
    String? kind,
    String? localPath,
    String? sha256,
    int? sizeBytes,
    DateTime? capturedAt,
    String? ownerEntity,
    String? ownerClientId,
    Value<String?> serverMediaId = const Value.absent(),
    String? state,
    int? attempts,
    Value<DateTime?> nextAttemptAt = const Value.absent(),
  }) => MediaQueueRow(
    clientId: clientId ?? this.clientId,
    kind: kind ?? this.kind,
    localPath: localPath ?? this.localPath,
    sha256: sha256 ?? this.sha256,
    sizeBytes: sizeBytes ?? this.sizeBytes,
    capturedAt: capturedAt ?? this.capturedAt,
    ownerEntity: ownerEntity ?? this.ownerEntity,
    ownerClientId: ownerClientId ?? this.ownerClientId,
    serverMediaId: serverMediaId.present
        ? serverMediaId.value
        : this.serverMediaId,
    state: state ?? this.state,
    attempts: attempts ?? this.attempts,
    nextAttemptAt: nextAttemptAt.present
        ? nextAttemptAt.value
        : this.nextAttemptAt,
  );
  MediaQueueRow copyWithCompanion(MediaQueueCompanion data) {
    return MediaQueueRow(
      clientId: data.clientId.present ? data.clientId.value : this.clientId,
      kind: data.kind.present ? data.kind.value : this.kind,
      localPath: data.localPath.present ? data.localPath.value : this.localPath,
      sha256: data.sha256.present ? data.sha256.value : this.sha256,
      sizeBytes: data.sizeBytes.present ? data.sizeBytes.value : this.sizeBytes,
      capturedAt: data.capturedAt.present
          ? data.capturedAt.value
          : this.capturedAt,
      ownerEntity: data.ownerEntity.present
          ? data.ownerEntity.value
          : this.ownerEntity,
      ownerClientId: data.ownerClientId.present
          ? data.ownerClientId.value
          : this.ownerClientId,
      serverMediaId: data.serverMediaId.present
          ? data.serverMediaId.value
          : this.serverMediaId,
      state: data.state.present ? data.state.value : this.state,
      attempts: data.attempts.present ? data.attempts.value : this.attempts,
      nextAttemptAt: data.nextAttemptAt.present
          ? data.nextAttemptAt.value
          : this.nextAttemptAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MediaQueueRow(')
          ..write('clientId: $clientId, ')
          ..write('kind: $kind, ')
          ..write('localPath: $localPath, ')
          ..write('sha256: $sha256, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('capturedAt: $capturedAt, ')
          ..write('ownerEntity: $ownerEntity, ')
          ..write('ownerClientId: $ownerClientId, ')
          ..write('serverMediaId: $serverMediaId, ')
          ..write('state: $state, ')
          ..write('attempts: $attempts, ')
          ..write('nextAttemptAt: $nextAttemptAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    clientId,
    kind,
    localPath,
    sha256,
    sizeBytes,
    capturedAt,
    ownerEntity,
    ownerClientId,
    serverMediaId,
    state,
    attempts,
    nextAttemptAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MediaQueueRow &&
          other.clientId == this.clientId &&
          other.kind == this.kind &&
          other.localPath == this.localPath &&
          other.sha256 == this.sha256 &&
          other.sizeBytes == this.sizeBytes &&
          other.capturedAt == this.capturedAt &&
          other.ownerEntity == this.ownerEntity &&
          other.ownerClientId == this.ownerClientId &&
          other.serverMediaId == this.serverMediaId &&
          other.state == this.state &&
          other.attempts == this.attempts &&
          other.nextAttemptAt == this.nextAttemptAt);
}

class MediaQueueCompanion extends UpdateCompanion<MediaQueueRow> {
  final Value<String> clientId;
  final Value<String> kind;
  final Value<String> localPath;
  final Value<String> sha256;
  final Value<int> sizeBytes;
  final Value<DateTime> capturedAt;
  final Value<String> ownerEntity;
  final Value<String> ownerClientId;
  final Value<String?> serverMediaId;
  final Value<String> state;
  final Value<int> attempts;
  final Value<DateTime?> nextAttemptAt;
  final Value<int> rowid;
  const MediaQueueCompanion({
    this.clientId = const Value.absent(),
    this.kind = const Value.absent(),
    this.localPath = const Value.absent(),
    this.sha256 = const Value.absent(),
    this.sizeBytes = const Value.absent(),
    this.capturedAt = const Value.absent(),
    this.ownerEntity = const Value.absent(),
    this.ownerClientId = const Value.absent(),
    this.serverMediaId = const Value.absent(),
    this.state = const Value.absent(),
    this.attempts = const Value.absent(),
    this.nextAttemptAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MediaQueueCompanion.insert({
    required String clientId,
    required String kind,
    required String localPath,
    required String sha256,
    required int sizeBytes,
    required DateTime capturedAt,
    required String ownerEntity,
    required String ownerClientId,
    this.serverMediaId = const Value.absent(),
    this.state = const Value.absent(),
    this.attempts = const Value.absent(),
    this.nextAttemptAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : clientId = Value(clientId),
       kind = Value(kind),
       localPath = Value(localPath),
       sha256 = Value(sha256),
       sizeBytes = Value(sizeBytes),
       capturedAt = Value(capturedAt),
       ownerEntity = Value(ownerEntity),
       ownerClientId = Value(ownerClientId);
  static Insertable<MediaQueueRow> custom({
    Expression<String>? clientId,
    Expression<String>? kind,
    Expression<String>? localPath,
    Expression<String>? sha256,
    Expression<int>? sizeBytes,
    Expression<DateTime>? capturedAt,
    Expression<String>? ownerEntity,
    Expression<String>? ownerClientId,
    Expression<String>? serverMediaId,
    Expression<String>? state,
    Expression<int>? attempts,
    Expression<DateTime>? nextAttemptAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (clientId != null) 'client_id': clientId,
      if (kind != null) 'kind': kind,
      if (localPath != null) 'local_path': localPath,
      if (sha256 != null) 'sha256': sha256,
      if (sizeBytes != null) 'size_bytes': sizeBytes,
      if (capturedAt != null) 'captured_at': capturedAt,
      if (ownerEntity != null) 'owner_entity': ownerEntity,
      if (ownerClientId != null) 'owner_client_id': ownerClientId,
      if (serverMediaId != null) 'server_media_id': serverMediaId,
      if (state != null) 'state': state,
      if (attempts != null) 'attempts': attempts,
      if (nextAttemptAt != null) 'next_attempt_at': nextAttemptAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MediaQueueCompanion copyWith({
    Value<String>? clientId,
    Value<String>? kind,
    Value<String>? localPath,
    Value<String>? sha256,
    Value<int>? sizeBytes,
    Value<DateTime>? capturedAt,
    Value<String>? ownerEntity,
    Value<String>? ownerClientId,
    Value<String?>? serverMediaId,
    Value<String>? state,
    Value<int>? attempts,
    Value<DateTime?>? nextAttemptAt,
    Value<int>? rowid,
  }) {
    return MediaQueueCompanion(
      clientId: clientId ?? this.clientId,
      kind: kind ?? this.kind,
      localPath: localPath ?? this.localPath,
      sha256: sha256 ?? this.sha256,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      capturedAt: capturedAt ?? this.capturedAt,
      ownerEntity: ownerEntity ?? this.ownerEntity,
      ownerClientId: ownerClientId ?? this.ownerClientId,
      serverMediaId: serverMediaId ?? this.serverMediaId,
      state: state ?? this.state,
      attempts: attempts ?? this.attempts,
      nextAttemptAt: nextAttemptAt ?? this.nextAttemptAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (clientId.present) {
      map['client_id'] = Variable<String>(clientId.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (localPath.present) {
      map['local_path'] = Variable<String>(localPath.value);
    }
    if (sha256.present) {
      map['sha256'] = Variable<String>(sha256.value);
    }
    if (sizeBytes.present) {
      map['size_bytes'] = Variable<int>(sizeBytes.value);
    }
    if (capturedAt.present) {
      map['captured_at'] = Variable<DateTime>(capturedAt.value);
    }
    if (ownerEntity.present) {
      map['owner_entity'] = Variable<String>(ownerEntity.value);
    }
    if (ownerClientId.present) {
      map['owner_client_id'] = Variable<String>(ownerClientId.value);
    }
    if (serverMediaId.present) {
      map['server_media_id'] = Variable<String>(serverMediaId.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    if (attempts.present) {
      map['attempts'] = Variable<int>(attempts.value);
    }
    if (nextAttemptAt.present) {
      map['next_attempt_at'] = Variable<DateTime>(nextAttemptAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MediaQueueCompanion(')
          ..write('clientId: $clientId, ')
          ..write('kind: $kind, ')
          ..write('localPath: $localPath, ')
          ..write('sha256: $sha256, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('capturedAt: $capturedAt, ')
          ..write('ownerEntity: $ownerEntity, ')
          ..write('ownerClientId: $ownerClientId, ')
          ..write('serverMediaId: $serverMediaId, ')
          ..write('state: $state, ')
          ..write('attempts: $attempts, ')
          ..write('nextAttemptAt: $nextAttemptAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OutboxTable extends Outbox with TableInfo<$OutboxTable, OutboxRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OutboxTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _mutationIdMeta = const VerificationMeta(
    'mutationId',
  );
  @override
  late final GeneratedColumn<String> mutationId = GeneratedColumn<String>(
    'mutation_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityMeta = const VerificationMeta('entity');
  @override
  late final GeneratedColumn<String> entity = GeneratedColumn<String>(
    'entity',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _opMeta = const VerificationMeta('op');
  @override
  late final GeneratedColumn<String> op = GeneratedColumn<String>(
    'op',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dependsOnJsonMeta = const VerificationMeta(
    'dependsOnJson',
  );
  @override
  late final GeneratedColumn<String> dependsOnJson = GeneratedColumn<String>(
    'depends_on_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
    'state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _attemptsMeta = const VerificationMeta(
    'attempts',
  );
  @override
  late final GeneratedColumn<int> attempts = GeneratedColumn<int>(
    'attempts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _nextAttemptAtMeta = const VerificationMeta(
    'nextAttemptAt',
  );
  @override
  late final GeneratedColumn<DateTime> nextAttemptAt =
      GeneratedColumn<DateTime>(
        'next_attempt_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _resultMeta = const VerificationMeta('result');
  @override
  late final GeneratedColumn<String> result = GeneratedColumn<String>(
    'result',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _doneAtMeta = const VerificationMeta('doneAt');
  @override
  late final GeneratedColumn<DateTime> doneAt = GeneratedColumn<DateTime>(
    'done_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    mutationId,
    entity,
    op,
    payloadJson,
    dependsOnJson,
    createdAt,
    state,
    attempts,
    nextAttemptAt,
    lastError,
    result,
    doneAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'outbox';
  @override
  VerificationContext validateIntegrity(
    Insertable<OutboxRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('mutation_id')) {
      context.handle(
        _mutationIdMeta,
        mutationId.isAcceptableOrUnknown(data['mutation_id']!, _mutationIdMeta),
      );
    } else if (isInserting) {
      context.missing(_mutationIdMeta);
    }
    if (data.containsKey('entity')) {
      context.handle(
        _entityMeta,
        entity.isAcceptableOrUnknown(data['entity']!, _entityMeta),
      );
    } else if (isInserting) {
      context.missing(_entityMeta);
    }
    if (data.containsKey('op')) {
      context.handle(_opMeta, op.isAcceptableOrUnknown(data['op']!, _opMeta));
    } else if (isInserting) {
      context.missing(_opMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('depends_on_json')) {
      context.handle(
        _dependsOnJsonMeta,
        dependsOnJson.isAcceptableOrUnknown(
          data['depends_on_json']!,
          _dependsOnJsonMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('state')) {
      context.handle(
        _stateMeta,
        state.isAcceptableOrUnknown(data['state']!, _stateMeta),
      );
    }
    if (data.containsKey('attempts')) {
      context.handle(
        _attemptsMeta,
        attempts.isAcceptableOrUnknown(data['attempts']!, _attemptsMeta),
      );
    }
    if (data.containsKey('next_attempt_at')) {
      context.handle(
        _nextAttemptAtMeta,
        nextAttemptAt.isAcceptableOrUnknown(
          data['next_attempt_at']!,
          _nextAttemptAtMeta,
        ),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    if (data.containsKey('result')) {
      context.handle(
        _resultMeta,
        result.isAcceptableOrUnknown(data['result']!, _resultMeta),
      );
    }
    if (data.containsKey('done_at')) {
      context.handle(
        _doneAtMeta,
        doneAt.isAcceptableOrUnknown(data['done_at']!, _doneAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {mutationId};
  @override
  OutboxRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OutboxRow(
      mutationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mutation_id'],
      )!,
      entity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity'],
      )!,
      op: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}op'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
      dependsOnJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}depends_on_json'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      state: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}state'],
      )!,
      attempts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempts'],
      )!,
      nextAttemptAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}next_attempt_at'],
      ),
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
      result: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}result'],
      ),
      doneAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}done_at'],
      ),
    );
  }

  @override
  $OutboxTable createAlias(String alias) {
    return $OutboxTable(attachedDatabase, alias);
  }
}

class OutboxRow extends DataClass implements Insertable<OutboxRow> {
  final String mutationId;
  final String entity;
  final String op;
  final String payloadJson;
  final String dependsOnJson;
  final DateTime createdAt;

  /// pending | sending | done | failed — never deleted while pending/failed.
  final String state;
  final int attempts;
  final DateTime? nextAttemptAt;
  final String? lastError;
  final String? result;
  final DateTime? doneAt;
  const OutboxRow({
    required this.mutationId,
    required this.entity,
    required this.op,
    required this.payloadJson,
    required this.dependsOnJson,
    required this.createdAt,
    required this.state,
    required this.attempts,
    this.nextAttemptAt,
    this.lastError,
    this.result,
    this.doneAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['mutation_id'] = Variable<String>(mutationId);
    map['entity'] = Variable<String>(entity);
    map['op'] = Variable<String>(op);
    map['payload_json'] = Variable<String>(payloadJson);
    map['depends_on_json'] = Variable<String>(dependsOnJson);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['state'] = Variable<String>(state);
    map['attempts'] = Variable<int>(attempts);
    if (!nullToAbsent || nextAttemptAt != null) {
      map['next_attempt_at'] = Variable<DateTime>(nextAttemptAt);
    }
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    if (!nullToAbsent || result != null) {
      map['result'] = Variable<String>(result);
    }
    if (!nullToAbsent || doneAt != null) {
      map['done_at'] = Variable<DateTime>(doneAt);
    }
    return map;
  }

  OutboxCompanion toCompanion(bool nullToAbsent) {
    return OutboxCompanion(
      mutationId: Value(mutationId),
      entity: Value(entity),
      op: Value(op),
      payloadJson: Value(payloadJson),
      dependsOnJson: Value(dependsOnJson),
      createdAt: Value(createdAt),
      state: Value(state),
      attempts: Value(attempts),
      nextAttemptAt: nextAttemptAt == null && nullToAbsent
          ? const Value.absent()
          : Value(nextAttemptAt),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
      result: result == null && nullToAbsent
          ? const Value.absent()
          : Value(result),
      doneAt: doneAt == null && nullToAbsent
          ? const Value.absent()
          : Value(doneAt),
    );
  }

  factory OutboxRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OutboxRow(
      mutationId: serializer.fromJson<String>(json['mutationId']),
      entity: serializer.fromJson<String>(json['entity']),
      op: serializer.fromJson<String>(json['op']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      dependsOnJson: serializer.fromJson<String>(json['dependsOnJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      state: serializer.fromJson<String>(json['state']),
      attempts: serializer.fromJson<int>(json['attempts']),
      nextAttemptAt: serializer.fromJson<DateTime?>(json['nextAttemptAt']),
      lastError: serializer.fromJson<String?>(json['lastError']),
      result: serializer.fromJson<String?>(json['result']),
      doneAt: serializer.fromJson<DateTime?>(json['doneAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'mutationId': serializer.toJson<String>(mutationId),
      'entity': serializer.toJson<String>(entity),
      'op': serializer.toJson<String>(op),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'dependsOnJson': serializer.toJson<String>(dependsOnJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'state': serializer.toJson<String>(state),
      'attempts': serializer.toJson<int>(attempts),
      'nextAttemptAt': serializer.toJson<DateTime?>(nextAttemptAt),
      'lastError': serializer.toJson<String?>(lastError),
      'result': serializer.toJson<String?>(result),
      'doneAt': serializer.toJson<DateTime?>(doneAt),
    };
  }

  OutboxRow copyWith({
    String? mutationId,
    String? entity,
    String? op,
    String? payloadJson,
    String? dependsOnJson,
    DateTime? createdAt,
    String? state,
    int? attempts,
    Value<DateTime?> nextAttemptAt = const Value.absent(),
    Value<String?> lastError = const Value.absent(),
    Value<String?> result = const Value.absent(),
    Value<DateTime?> doneAt = const Value.absent(),
  }) => OutboxRow(
    mutationId: mutationId ?? this.mutationId,
    entity: entity ?? this.entity,
    op: op ?? this.op,
    payloadJson: payloadJson ?? this.payloadJson,
    dependsOnJson: dependsOnJson ?? this.dependsOnJson,
    createdAt: createdAt ?? this.createdAt,
    state: state ?? this.state,
    attempts: attempts ?? this.attempts,
    nextAttemptAt: nextAttemptAt.present
        ? nextAttemptAt.value
        : this.nextAttemptAt,
    lastError: lastError.present ? lastError.value : this.lastError,
    result: result.present ? result.value : this.result,
    doneAt: doneAt.present ? doneAt.value : this.doneAt,
  );
  OutboxRow copyWithCompanion(OutboxCompanion data) {
    return OutboxRow(
      mutationId: data.mutationId.present
          ? data.mutationId.value
          : this.mutationId,
      entity: data.entity.present ? data.entity.value : this.entity,
      op: data.op.present ? data.op.value : this.op,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      dependsOnJson: data.dependsOnJson.present
          ? data.dependsOnJson.value
          : this.dependsOnJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      state: data.state.present ? data.state.value : this.state,
      attempts: data.attempts.present ? data.attempts.value : this.attempts,
      nextAttemptAt: data.nextAttemptAt.present
          ? data.nextAttemptAt.value
          : this.nextAttemptAt,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
      result: data.result.present ? data.result.value : this.result,
      doneAt: data.doneAt.present ? data.doneAt.value : this.doneAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OutboxRow(')
          ..write('mutationId: $mutationId, ')
          ..write('entity: $entity, ')
          ..write('op: $op, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('dependsOnJson: $dependsOnJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('state: $state, ')
          ..write('attempts: $attempts, ')
          ..write('nextAttemptAt: $nextAttemptAt, ')
          ..write('lastError: $lastError, ')
          ..write('result: $result, ')
          ..write('doneAt: $doneAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    mutationId,
    entity,
    op,
    payloadJson,
    dependsOnJson,
    createdAt,
    state,
    attempts,
    nextAttemptAt,
    lastError,
    result,
    doneAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OutboxRow &&
          other.mutationId == this.mutationId &&
          other.entity == this.entity &&
          other.op == this.op &&
          other.payloadJson == this.payloadJson &&
          other.dependsOnJson == this.dependsOnJson &&
          other.createdAt == this.createdAt &&
          other.state == this.state &&
          other.attempts == this.attempts &&
          other.nextAttemptAt == this.nextAttemptAt &&
          other.lastError == this.lastError &&
          other.result == this.result &&
          other.doneAt == this.doneAt);
}

class OutboxCompanion extends UpdateCompanion<OutboxRow> {
  final Value<String> mutationId;
  final Value<String> entity;
  final Value<String> op;
  final Value<String> payloadJson;
  final Value<String> dependsOnJson;
  final Value<DateTime> createdAt;
  final Value<String> state;
  final Value<int> attempts;
  final Value<DateTime?> nextAttemptAt;
  final Value<String?> lastError;
  final Value<String?> result;
  final Value<DateTime?> doneAt;
  final Value<int> rowid;
  const OutboxCompanion({
    this.mutationId = const Value.absent(),
    this.entity = const Value.absent(),
    this.op = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.dependsOnJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.state = const Value.absent(),
    this.attempts = const Value.absent(),
    this.nextAttemptAt = const Value.absent(),
    this.lastError = const Value.absent(),
    this.result = const Value.absent(),
    this.doneAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OutboxCompanion.insert({
    required String mutationId,
    required String entity,
    required String op,
    required String payloadJson,
    this.dependsOnJson = const Value.absent(),
    required DateTime createdAt,
    this.state = const Value.absent(),
    this.attempts = const Value.absent(),
    this.nextAttemptAt = const Value.absent(),
    this.lastError = const Value.absent(),
    this.result = const Value.absent(),
    this.doneAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : mutationId = Value(mutationId),
       entity = Value(entity),
       op = Value(op),
       payloadJson = Value(payloadJson),
       createdAt = Value(createdAt);
  static Insertable<OutboxRow> custom({
    Expression<String>? mutationId,
    Expression<String>? entity,
    Expression<String>? op,
    Expression<String>? payloadJson,
    Expression<String>? dependsOnJson,
    Expression<DateTime>? createdAt,
    Expression<String>? state,
    Expression<int>? attempts,
    Expression<DateTime>? nextAttemptAt,
    Expression<String>? lastError,
    Expression<String>? result,
    Expression<DateTime>? doneAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (mutationId != null) 'mutation_id': mutationId,
      if (entity != null) 'entity': entity,
      if (op != null) 'op': op,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (dependsOnJson != null) 'depends_on_json': dependsOnJson,
      if (createdAt != null) 'created_at': createdAt,
      if (state != null) 'state': state,
      if (attempts != null) 'attempts': attempts,
      if (nextAttemptAt != null) 'next_attempt_at': nextAttemptAt,
      if (lastError != null) 'last_error': lastError,
      if (result != null) 'result': result,
      if (doneAt != null) 'done_at': doneAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OutboxCompanion copyWith({
    Value<String>? mutationId,
    Value<String>? entity,
    Value<String>? op,
    Value<String>? payloadJson,
    Value<String>? dependsOnJson,
    Value<DateTime>? createdAt,
    Value<String>? state,
    Value<int>? attempts,
    Value<DateTime?>? nextAttemptAt,
    Value<String?>? lastError,
    Value<String?>? result,
    Value<DateTime?>? doneAt,
    Value<int>? rowid,
  }) {
    return OutboxCompanion(
      mutationId: mutationId ?? this.mutationId,
      entity: entity ?? this.entity,
      op: op ?? this.op,
      payloadJson: payloadJson ?? this.payloadJson,
      dependsOnJson: dependsOnJson ?? this.dependsOnJson,
      createdAt: createdAt ?? this.createdAt,
      state: state ?? this.state,
      attempts: attempts ?? this.attempts,
      nextAttemptAt: nextAttemptAt ?? this.nextAttemptAt,
      lastError: lastError ?? this.lastError,
      result: result ?? this.result,
      doneAt: doneAt ?? this.doneAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (mutationId.present) {
      map['mutation_id'] = Variable<String>(mutationId.value);
    }
    if (entity.present) {
      map['entity'] = Variable<String>(entity.value);
    }
    if (op.present) {
      map['op'] = Variable<String>(op.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (dependsOnJson.present) {
      map['depends_on_json'] = Variable<String>(dependsOnJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    if (attempts.present) {
      map['attempts'] = Variable<int>(attempts.value);
    }
    if (nextAttemptAt.present) {
      map['next_attempt_at'] = Variable<DateTime>(nextAttemptAt.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (result.present) {
      map['result'] = Variable<String>(result.value);
    }
    if (doneAt.present) {
      map['done_at'] = Variable<DateTime>(doneAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OutboxCompanion(')
          ..write('mutationId: $mutationId, ')
          ..write('entity: $entity, ')
          ..write('op: $op, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('dependsOnJson: $dependsOnJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('state: $state, ')
          ..write('attempts: $attempts, ')
          ..write('nextAttemptAt: $nextAttemptAt, ')
          ..write('lastError: $lastError, ')
          ..write('result: $result, ')
          ..write('doneAt: $doneAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $IdMapTable extends IdMap with TableInfo<$IdMapTable, IdMapRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $IdMapTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _clientIdMeta = const VerificationMeta(
    'clientId',
  );
  @override
  late final GeneratedColumn<String> clientId = GeneratedColumn<String>(
    'client_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityMeta = const VerificationMeta('entity');
  @override
  late final GeneratedColumn<String> entity = GeneratedColumn<String>(
    'entity',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _serverIdMeta = const VerificationMeta(
    'serverId',
  );
  @override
  late final GeneratedColumn<String> serverId = GeneratedColumn<String>(
    'server_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [clientId, entity, serverId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'id_map';
  @override
  VerificationContext validateIntegrity(
    Insertable<IdMapRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('client_id')) {
      context.handle(
        _clientIdMeta,
        clientId.isAcceptableOrUnknown(data['client_id']!, _clientIdMeta),
      );
    } else if (isInserting) {
      context.missing(_clientIdMeta);
    }
    if (data.containsKey('entity')) {
      context.handle(
        _entityMeta,
        entity.isAcceptableOrUnknown(data['entity']!, _entityMeta),
      );
    } else if (isInserting) {
      context.missing(_entityMeta);
    }
    if (data.containsKey('server_id')) {
      context.handle(
        _serverIdMeta,
        serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta),
      );
    } else if (isInserting) {
      context.missing(_serverIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {clientId};
  @override
  IdMapRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return IdMapRow(
      clientId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}client_id'],
      )!,
      entity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity'],
      )!,
      serverId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}server_id'],
      )!,
    );
  }

  @override
  $IdMapTable createAlias(String alias) {
    return $IdMapTable(attachedDatabase, alias);
  }
}

class IdMapRow extends DataClass implements Insertable<IdMapRow> {
  final String clientId;
  final String entity;
  final String serverId;
  const IdMapRow({
    required this.clientId,
    required this.entity,
    required this.serverId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['client_id'] = Variable<String>(clientId);
    map['entity'] = Variable<String>(entity);
    map['server_id'] = Variable<String>(serverId);
    return map;
  }

  IdMapCompanion toCompanion(bool nullToAbsent) {
    return IdMapCompanion(
      clientId: Value(clientId),
      entity: Value(entity),
      serverId: Value(serverId),
    );
  }

  factory IdMapRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return IdMapRow(
      clientId: serializer.fromJson<String>(json['clientId']),
      entity: serializer.fromJson<String>(json['entity']),
      serverId: serializer.fromJson<String>(json['serverId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'clientId': serializer.toJson<String>(clientId),
      'entity': serializer.toJson<String>(entity),
      'serverId': serializer.toJson<String>(serverId),
    };
  }

  IdMapRow copyWith({String? clientId, String? entity, String? serverId}) =>
      IdMapRow(
        clientId: clientId ?? this.clientId,
        entity: entity ?? this.entity,
        serverId: serverId ?? this.serverId,
      );
  IdMapRow copyWithCompanion(IdMapCompanion data) {
    return IdMapRow(
      clientId: data.clientId.present ? data.clientId.value : this.clientId,
      entity: data.entity.present ? data.entity.value : this.entity,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('IdMapRow(')
          ..write('clientId: $clientId, ')
          ..write('entity: $entity, ')
          ..write('serverId: $serverId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(clientId, entity, serverId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is IdMapRow &&
          other.clientId == this.clientId &&
          other.entity == this.entity &&
          other.serverId == this.serverId);
}

class IdMapCompanion extends UpdateCompanion<IdMapRow> {
  final Value<String> clientId;
  final Value<String> entity;
  final Value<String> serverId;
  final Value<int> rowid;
  const IdMapCompanion({
    this.clientId = const Value.absent(),
    this.entity = const Value.absent(),
    this.serverId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  IdMapCompanion.insert({
    required String clientId,
    required String entity,
    required String serverId,
    this.rowid = const Value.absent(),
  }) : clientId = Value(clientId),
       entity = Value(entity),
       serverId = Value(serverId);
  static Insertable<IdMapRow> custom({
    Expression<String>? clientId,
    Expression<String>? entity,
    Expression<String>? serverId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (clientId != null) 'client_id': clientId,
      if (entity != null) 'entity': entity,
      if (serverId != null) 'server_id': serverId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  IdMapCompanion copyWith({
    Value<String>? clientId,
    Value<String>? entity,
    Value<String>? serverId,
    Value<int>? rowid,
  }) {
    return IdMapCompanion(
      clientId: clientId ?? this.clientId,
      entity: entity ?? this.entity,
      serverId: serverId ?? this.serverId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (clientId.present) {
      map['client_id'] = Variable<String>(clientId.value);
    }
    if (entity.present) {
      map['entity'] = Variable<String>(entity.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<String>(serverId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('IdMapCompanion(')
          ..write('clientId: $clientId, ')
          ..write('entity: $entity, ')
          ..write('serverId: $serverId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncMetaTable extends SyncMeta
    with TableInfo<$SyncMetaTable, SyncMetaRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncMetaTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _pullCursorMeta = const VerificationMeta(
    'pullCursor',
  );
  @override
  late final GeneratedColumn<String> pullCursor = GeneratedColumn<String>(
    'pull_cursor',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastPullAtMeta = const VerificationMeta(
    'lastPullAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastPullAt = GeneratedColumn<DateTime>(
    'last_pull_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastPushAtMeta = const VerificationMeta(
    'lastPushAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastPushAt = GeneratedColumn<DateTime>(
    'last_push_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastSuccessAtMeta = const VerificationMeta(
    'lastSuccessAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSuccessAt =
      GeneratedColumn<DateTime>(
        'last_success_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _serverOffsetMsMeta = const VerificationMeta(
    'serverOffsetMs',
  );
  @override
  late final GeneratedColumn<int> serverOffsetMs = GeneratedColumn<int>(
    'server_offset_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _bootstrapDoneMeta = const VerificationMeta(
    'bootstrapDone',
  );
  @override
  late final GeneratedColumn<bool> bootstrapDone = GeneratedColumn<bool>(
    'bootstrap_done',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("bootstrap_done" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    pullCursor,
    lastPullAt,
    lastPushAt,
    lastSuccessAt,
    serverOffsetMs,
    bootstrapDone,
    lastError,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_state';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncMetaRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('pull_cursor')) {
      context.handle(
        _pullCursorMeta,
        pullCursor.isAcceptableOrUnknown(data['pull_cursor']!, _pullCursorMeta),
      );
    }
    if (data.containsKey('last_pull_at')) {
      context.handle(
        _lastPullAtMeta,
        lastPullAt.isAcceptableOrUnknown(
          data['last_pull_at']!,
          _lastPullAtMeta,
        ),
      );
    }
    if (data.containsKey('last_push_at')) {
      context.handle(
        _lastPushAtMeta,
        lastPushAt.isAcceptableOrUnknown(
          data['last_push_at']!,
          _lastPushAtMeta,
        ),
      );
    }
    if (data.containsKey('last_success_at')) {
      context.handle(
        _lastSuccessAtMeta,
        lastSuccessAt.isAcceptableOrUnknown(
          data['last_success_at']!,
          _lastSuccessAtMeta,
        ),
      );
    }
    if (data.containsKey('server_offset_ms')) {
      context.handle(
        _serverOffsetMsMeta,
        serverOffsetMs.isAcceptableOrUnknown(
          data['server_offset_ms']!,
          _serverOffsetMsMeta,
        ),
      );
    }
    if (data.containsKey('bootstrap_done')) {
      context.handle(
        _bootstrapDoneMeta,
        bootstrapDone.isAcceptableOrUnknown(
          data['bootstrap_done']!,
          _bootstrapDoneMeta,
        ),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncMetaRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncMetaRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      pullCursor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pull_cursor'],
      ),
      lastPullAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_pull_at'],
      ),
      lastPushAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_push_at'],
      ),
      lastSuccessAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_success_at'],
      ),
      serverOffsetMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_offset_ms'],
      )!,
      bootstrapDone: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}bootstrap_done'],
      )!,
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
    );
  }

  @override
  $SyncMetaTable createAlias(String alias) {
    return $SyncMetaTable(attachedDatabase, alias);
  }
}

class SyncMetaRow extends DataClass implements Insertable<SyncMetaRow> {
  final int id;
  final String? pullCursor;
  final DateTime? lastPullAt;
  final DateTime? lastPushAt;
  final DateTime? lastSuccessAt;
  final int serverOffsetMs;
  final bool bootstrapDone;
  final String? lastError;
  const SyncMetaRow({
    required this.id,
    this.pullCursor,
    this.lastPullAt,
    this.lastPushAt,
    this.lastSuccessAt,
    required this.serverOffsetMs,
    required this.bootstrapDone,
    this.lastError,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || pullCursor != null) {
      map['pull_cursor'] = Variable<String>(pullCursor);
    }
    if (!nullToAbsent || lastPullAt != null) {
      map['last_pull_at'] = Variable<DateTime>(lastPullAt);
    }
    if (!nullToAbsent || lastPushAt != null) {
      map['last_push_at'] = Variable<DateTime>(lastPushAt);
    }
    if (!nullToAbsent || lastSuccessAt != null) {
      map['last_success_at'] = Variable<DateTime>(lastSuccessAt);
    }
    map['server_offset_ms'] = Variable<int>(serverOffsetMs);
    map['bootstrap_done'] = Variable<bool>(bootstrapDone);
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    return map;
  }

  SyncMetaCompanion toCompanion(bool nullToAbsent) {
    return SyncMetaCompanion(
      id: Value(id),
      pullCursor: pullCursor == null && nullToAbsent
          ? const Value.absent()
          : Value(pullCursor),
      lastPullAt: lastPullAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastPullAt),
      lastPushAt: lastPushAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastPushAt),
      lastSuccessAt: lastSuccessAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSuccessAt),
      serverOffsetMs: Value(serverOffsetMs),
      bootstrapDone: Value(bootstrapDone),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
    );
  }

  factory SyncMetaRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncMetaRow(
      id: serializer.fromJson<int>(json['id']),
      pullCursor: serializer.fromJson<String?>(json['pullCursor']),
      lastPullAt: serializer.fromJson<DateTime?>(json['lastPullAt']),
      lastPushAt: serializer.fromJson<DateTime?>(json['lastPushAt']),
      lastSuccessAt: serializer.fromJson<DateTime?>(json['lastSuccessAt']),
      serverOffsetMs: serializer.fromJson<int>(json['serverOffsetMs']),
      bootstrapDone: serializer.fromJson<bool>(json['bootstrapDone']),
      lastError: serializer.fromJson<String?>(json['lastError']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'pullCursor': serializer.toJson<String?>(pullCursor),
      'lastPullAt': serializer.toJson<DateTime?>(lastPullAt),
      'lastPushAt': serializer.toJson<DateTime?>(lastPushAt),
      'lastSuccessAt': serializer.toJson<DateTime?>(lastSuccessAt),
      'serverOffsetMs': serializer.toJson<int>(serverOffsetMs),
      'bootstrapDone': serializer.toJson<bool>(bootstrapDone),
      'lastError': serializer.toJson<String?>(lastError),
    };
  }

  SyncMetaRow copyWith({
    int? id,
    Value<String?> pullCursor = const Value.absent(),
    Value<DateTime?> lastPullAt = const Value.absent(),
    Value<DateTime?> lastPushAt = const Value.absent(),
    Value<DateTime?> lastSuccessAt = const Value.absent(),
    int? serverOffsetMs,
    bool? bootstrapDone,
    Value<String?> lastError = const Value.absent(),
  }) => SyncMetaRow(
    id: id ?? this.id,
    pullCursor: pullCursor.present ? pullCursor.value : this.pullCursor,
    lastPullAt: lastPullAt.present ? lastPullAt.value : this.lastPullAt,
    lastPushAt: lastPushAt.present ? lastPushAt.value : this.lastPushAt,
    lastSuccessAt: lastSuccessAt.present
        ? lastSuccessAt.value
        : this.lastSuccessAt,
    serverOffsetMs: serverOffsetMs ?? this.serverOffsetMs,
    bootstrapDone: bootstrapDone ?? this.bootstrapDone,
    lastError: lastError.present ? lastError.value : this.lastError,
  );
  SyncMetaRow copyWithCompanion(SyncMetaCompanion data) {
    return SyncMetaRow(
      id: data.id.present ? data.id.value : this.id,
      pullCursor: data.pullCursor.present
          ? data.pullCursor.value
          : this.pullCursor,
      lastPullAt: data.lastPullAt.present
          ? data.lastPullAt.value
          : this.lastPullAt,
      lastPushAt: data.lastPushAt.present
          ? data.lastPushAt.value
          : this.lastPushAt,
      lastSuccessAt: data.lastSuccessAt.present
          ? data.lastSuccessAt.value
          : this.lastSuccessAt,
      serverOffsetMs: data.serverOffsetMs.present
          ? data.serverOffsetMs.value
          : this.serverOffsetMs,
      bootstrapDone: data.bootstrapDone.present
          ? data.bootstrapDone.value
          : this.bootstrapDone,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncMetaRow(')
          ..write('id: $id, ')
          ..write('pullCursor: $pullCursor, ')
          ..write('lastPullAt: $lastPullAt, ')
          ..write('lastPushAt: $lastPushAt, ')
          ..write('lastSuccessAt: $lastSuccessAt, ')
          ..write('serverOffsetMs: $serverOffsetMs, ')
          ..write('bootstrapDone: $bootstrapDone, ')
          ..write('lastError: $lastError')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    pullCursor,
    lastPullAt,
    lastPushAt,
    lastSuccessAt,
    serverOffsetMs,
    bootstrapDone,
    lastError,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncMetaRow &&
          other.id == this.id &&
          other.pullCursor == this.pullCursor &&
          other.lastPullAt == this.lastPullAt &&
          other.lastPushAt == this.lastPushAt &&
          other.lastSuccessAt == this.lastSuccessAt &&
          other.serverOffsetMs == this.serverOffsetMs &&
          other.bootstrapDone == this.bootstrapDone &&
          other.lastError == this.lastError);
}

class SyncMetaCompanion extends UpdateCompanion<SyncMetaRow> {
  final Value<int> id;
  final Value<String?> pullCursor;
  final Value<DateTime?> lastPullAt;
  final Value<DateTime?> lastPushAt;
  final Value<DateTime?> lastSuccessAt;
  final Value<int> serverOffsetMs;
  final Value<bool> bootstrapDone;
  final Value<String?> lastError;
  const SyncMetaCompanion({
    this.id = const Value.absent(),
    this.pullCursor = const Value.absent(),
    this.lastPullAt = const Value.absent(),
    this.lastPushAt = const Value.absent(),
    this.lastSuccessAt = const Value.absent(),
    this.serverOffsetMs = const Value.absent(),
    this.bootstrapDone = const Value.absent(),
    this.lastError = const Value.absent(),
  });
  SyncMetaCompanion.insert({
    this.id = const Value.absent(),
    this.pullCursor = const Value.absent(),
    this.lastPullAt = const Value.absent(),
    this.lastPushAt = const Value.absent(),
    this.lastSuccessAt = const Value.absent(),
    this.serverOffsetMs = const Value.absent(),
    this.bootstrapDone = const Value.absent(),
    this.lastError = const Value.absent(),
  });
  static Insertable<SyncMetaRow> custom({
    Expression<int>? id,
    Expression<String>? pullCursor,
    Expression<DateTime>? lastPullAt,
    Expression<DateTime>? lastPushAt,
    Expression<DateTime>? lastSuccessAt,
    Expression<int>? serverOffsetMs,
    Expression<bool>? bootstrapDone,
    Expression<String>? lastError,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (pullCursor != null) 'pull_cursor': pullCursor,
      if (lastPullAt != null) 'last_pull_at': lastPullAt,
      if (lastPushAt != null) 'last_push_at': lastPushAt,
      if (lastSuccessAt != null) 'last_success_at': lastSuccessAt,
      if (serverOffsetMs != null) 'server_offset_ms': serverOffsetMs,
      if (bootstrapDone != null) 'bootstrap_done': bootstrapDone,
      if (lastError != null) 'last_error': lastError,
    });
  }

  SyncMetaCompanion copyWith({
    Value<int>? id,
    Value<String?>? pullCursor,
    Value<DateTime?>? lastPullAt,
    Value<DateTime?>? lastPushAt,
    Value<DateTime?>? lastSuccessAt,
    Value<int>? serverOffsetMs,
    Value<bool>? bootstrapDone,
    Value<String?>? lastError,
  }) {
    return SyncMetaCompanion(
      id: id ?? this.id,
      pullCursor: pullCursor ?? this.pullCursor,
      lastPullAt: lastPullAt ?? this.lastPullAt,
      lastPushAt: lastPushAt ?? this.lastPushAt,
      lastSuccessAt: lastSuccessAt ?? this.lastSuccessAt,
      serverOffsetMs: serverOffsetMs ?? this.serverOffsetMs,
      bootstrapDone: bootstrapDone ?? this.bootstrapDone,
      lastError: lastError ?? this.lastError,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (pullCursor.present) {
      map['pull_cursor'] = Variable<String>(pullCursor.value);
    }
    if (lastPullAt.present) {
      map['last_pull_at'] = Variable<DateTime>(lastPullAt.value);
    }
    if (lastPushAt.present) {
      map['last_push_at'] = Variable<DateTime>(lastPushAt.value);
    }
    if (lastSuccessAt.present) {
      map['last_success_at'] = Variable<DateTime>(lastSuccessAt.value);
    }
    if (serverOffsetMs.present) {
      map['server_offset_ms'] = Variable<int>(serverOffsetMs.value);
    }
    if (bootstrapDone.present) {
      map['bootstrap_done'] = Variable<bool>(bootstrapDone.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncMetaCompanion(')
          ..write('id: $id, ')
          ..write('pullCursor: $pullCursor, ')
          ..write('lastPullAt: $lastPullAt, ')
          ..write('lastPushAt: $lastPushAt, ')
          ..write('lastSuccessAt: $lastSuccessAt, ')
          ..write('serverOffsetMs: $serverOffsetMs, ')
          ..write('bootstrapDone: $bootstrapDone, ')
          ..write('lastError: $lastError')
          ..write(')'))
        .toString();
  }
}

class $LocationQueueTable extends LocationQueue
    with TableInfo<$LocationQueueTable, LocationPointRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocationQueueTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _tMeta = const VerificationMeta('t');
  @override
  late final GeneratedColumn<DateTime> t = GeneratedColumn<DateTime>(
    't',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _latMeta = const VerificationMeta('lat');
  @override
  late final GeneratedColumn<double> lat = GeneratedColumn<double>(
    'lat',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lngMeta = const VerificationMeta('lng');
  @override
  late final GeneratedColumn<double> lng = GeneratedColumn<double>(
    'lng',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accMeta = const VerificationMeta('acc');
  @override
  late final GeneratedColumn<double> acc = GeneratedColumn<double>(
    'acc',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _spdMeta = const VerificationMeta('spd');
  @override
  late final GeneratedColumn<double> spd = GeneratedColumn<double>(
    'spd',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hdgMeta = const VerificationMeta('hdg');
  @override
  late final GeneratedColumn<double> hdg = GeneratedColumn<double>(
    'hdg',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _altMeta = const VerificationMeta('alt');
  @override
  late final GeneratedColumn<double> alt = GeneratedColumn<double>(
    'alt',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _actMeta = const VerificationMeta('act');
  @override
  late final GeneratedColumn<String> act = GeneratedColumn<String>(
    'act',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _batMeta = const VerificationMeta('bat');
  @override
  late final GeneratedColumn<double> bat = GeneratedColumn<double>(
    'bat',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _chgMeta = const VerificationMeta('chg');
  @override
  late final GeneratedColumn<bool> chg = GeneratedColumn<bool>(
    'chg',
    aliasedName,
    true,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("chg" IN (0, 1))',
    ),
  );
  static const VerificationMeta _mockMeta = const VerificationMeta('mock');
  @override
  late final GeneratedColumn<bool> mock = GeneratedColumn<bool>(
    'mock',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("mock" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    t,
    lat,
    lng,
    acc,
    spd,
    hdg,
    alt,
    act,
    bat,
    chg,
    mock,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'location_queue';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocationPointRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('t')) {
      context.handle(_tMeta, t.isAcceptableOrUnknown(data['t']!, _tMeta));
    } else if (isInserting) {
      context.missing(_tMeta);
    }
    if (data.containsKey('lat')) {
      context.handle(
        _latMeta,
        lat.isAcceptableOrUnknown(data['lat']!, _latMeta),
      );
    } else if (isInserting) {
      context.missing(_latMeta);
    }
    if (data.containsKey('lng')) {
      context.handle(
        _lngMeta,
        lng.isAcceptableOrUnknown(data['lng']!, _lngMeta),
      );
    } else if (isInserting) {
      context.missing(_lngMeta);
    }
    if (data.containsKey('acc')) {
      context.handle(
        _accMeta,
        acc.isAcceptableOrUnknown(data['acc']!, _accMeta),
      );
    } else if (isInserting) {
      context.missing(_accMeta);
    }
    if (data.containsKey('spd')) {
      context.handle(
        _spdMeta,
        spd.isAcceptableOrUnknown(data['spd']!, _spdMeta),
      );
    }
    if (data.containsKey('hdg')) {
      context.handle(
        _hdgMeta,
        hdg.isAcceptableOrUnknown(data['hdg']!, _hdgMeta),
      );
    }
    if (data.containsKey('alt')) {
      context.handle(
        _altMeta,
        alt.isAcceptableOrUnknown(data['alt']!, _altMeta),
      );
    }
    if (data.containsKey('act')) {
      context.handle(
        _actMeta,
        act.isAcceptableOrUnknown(data['act']!, _actMeta),
      );
    }
    if (data.containsKey('bat')) {
      context.handle(
        _batMeta,
        bat.isAcceptableOrUnknown(data['bat']!, _batMeta),
      );
    }
    if (data.containsKey('chg')) {
      context.handle(
        _chgMeta,
        chg.isAcceptableOrUnknown(data['chg']!, _chgMeta),
      );
    }
    if (data.containsKey('mock')) {
      context.handle(
        _mockMeta,
        mock.isAcceptableOrUnknown(data['mock']!, _mockMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocationPointRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocationPointRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      t: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}t'],
      )!,
      lat: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}lat'],
      )!,
      lng: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}lng'],
      )!,
      acc: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}acc'],
      )!,
      spd: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}spd'],
      ),
      hdg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}hdg'],
      ),
      alt: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}alt'],
      ),
      act: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}act'],
      ),
      bat: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}bat'],
      ),
      chg: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}chg'],
      ),
      mock: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}mock'],
      )!,
    );
  }

  @override
  $LocationQueueTable createAlias(String alias) {
    return $LocationQueueTable(attachedDatabase, alias);
  }
}

class LocationPointRow extends DataClass
    implements Insertable<LocationPointRow> {
  final int id;
  final DateTime t;
  final double lat;
  final double lng;
  final double acc;
  final double? spd;
  final double? hdg;
  final double? alt;
  final String? act;
  final double? bat;
  final bool? chg;
  final bool mock;
  const LocationPointRow({
    required this.id,
    required this.t,
    required this.lat,
    required this.lng,
    required this.acc,
    this.spd,
    this.hdg,
    this.alt,
    this.act,
    this.bat,
    this.chg,
    required this.mock,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['t'] = Variable<DateTime>(t);
    map['lat'] = Variable<double>(lat);
    map['lng'] = Variable<double>(lng);
    map['acc'] = Variable<double>(acc);
    if (!nullToAbsent || spd != null) {
      map['spd'] = Variable<double>(spd);
    }
    if (!nullToAbsent || hdg != null) {
      map['hdg'] = Variable<double>(hdg);
    }
    if (!nullToAbsent || alt != null) {
      map['alt'] = Variable<double>(alt);
    }
    if (!nullToAbsent || act != null) {
      map['act'] = Variable<String>(act);
    }
    if (!nullToAbsent || bat != null) {
      map['bat'] = Variable<double>(bat);
    }
    if (!nullToAbsent || chg != null) {
      map['chg'] = Variable<bool>(chg);
    }
    map['mock'] = Variable<bool>(mock);
    return map;
  }

  LocationQueueCompanion toCompanion(bool nullToAbsent) {
    return LocationQueueCompanion(
      id: Value(id),
      t: Value(t),
      lat: Value(lat),
      lng: Value(lng),
      acc: Value(acc),
      spd: spd == null && nullToAbsent ? const Value.absent() : Value(spd),
      hdg: hdg == null && nullToAbsent ? const Value.absent() : Value(hdg),
      alt: alt == null && nullToAbsent ? const Value.absent() : Value(alt),
      act: act == null && nullToAbsent ? const Value.absent() : Value(act),
      bat: bat == null && nullToAbsent ? const Value.absent() : Value(bat),
      chg: chg == null && nullToAbsent ? const Value.absent() : Value(chg),
      mock: Value(mock),
    );
  }

  factory LocationPointRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocationPointRow(
      id: serializer.fromJson<int>(json['id']),
      t: serializer.fromJson<DateTime>(json['t']),
      lat: serializer.fromJson<double>(json['lat']),
      lng: serializer.fromJson<double>(json['lng']),
      acc: serializer.fromJson<double>(json['acc']),
      spd: serializer.fromJson<double?>(json['spd']),
      hdg: serializer.fromJson<double?>(json['hdg']),
      alt: serializer.fromJson<double?>(json['alt']),
      act: serializer.fromJson<String?>(json['act']),
      bat: serializer.fromJson<double?>(json['bat']),
      chg: serializer.fromJson<bool?>(json['chg']),
      mock: serializer.fromJson<bool>(json['mock']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      't': serializer.toJson<DateTime>(t),
      'lat': serializer.toJson<double>(lat),
      'lng': serializer.toJson<double>(lng),
      'acc': serializer.toJson<double>(acc),
      'spd': serializer.toJson<double?>(spd),
      'hdg': serializer.toJson<double?>(hdg),
      'alt': serializer.toJson<double?>(alt),
      'act': serializer.toJson<String?>(act),
      'bat': serializer.toJson<double?>(bat),
      'chg': serializer.toJson<bool?>(chg),
      'mock': serializer.toJson<bool>(mock),
    };
  }

  LocationPointRow copyWith({
    int? id,
    DateTime? t,
    double? lat,
    double? lng,
    double? acc,
    Value<double?> spd = const Value.absent(),
    Value<double?> hdg = const Value.absent(),
    Value<double?> alt = const Value.absent(),
    Value<String?> act = const Value.absent(),
    Value<double?> bat = const Value.absent(),
    Value<bool?> chg = const Value.absent(),
    bool? mock,
  }) => LocationPointRow(
    id: id ?? this.id,
    t: t ?? this.t,
    lat: lat ?? this.lat,
    lng: lng ?? this.lng,
    acc: acc ?? this.acc,
    spd: spd.present ? spd.value : this.spd,
    hdg: hdg.present ? hdg.value : this.hdg,
    alt: alt.present ? alt.value : this.alt,
    act: act.present ? act.value : this.act,
    bat: bat.present ? bat.value : this.bat,
    chg: chg.present ? chg.value : this.chg,
    mock: mock ?? this.mock,
  );
  LocationPointRow copyWithCompanion(LocationQueueCompanion data) {
    return LocationPointRow(
      id: data.id.present ? data.id.value : this.id,
      t: data.t.present ? data.t.value : this.t,
      lat: data.lat.present ? data.lat.value : this.lat,
      lng: data.lng.present ? data.lng.value : this.lng,
      acc: data.acc.present ? data.acc.value : this.acc,
      spd: data.spd.present ? data.spd.value : this.spd,
      hdg: data.hdg.present ? data.hdg.value : this.hdg,
      alt: data.alt.present ? data.alt.value : this.alt,
      act: data.act.present ? data.act.value : this.act,
      bat: data.bat.present ? data.bat.value : this.bat,
      chg: data.chg.present ? data.chg.value : this.chg,
      mock: data.mock.present ? data.mock.value : this.mock,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocationPointRow(')
          ..write('id: $id, ')
          ..write('t: $t, ')
          ..write('lat: $lat, ')
          ..write('lng: $lng, ')
          ..write('acc: $acc, ')
          ..write('spd: $spd, ')
          ..write('hdg: $hdg, ')
          ..write('alt: $alt, ')
          ..write('act: $act, ')
          ..write('bat: $bat, ')
          ..write('chg: $chg, ')
          ..write('mock: $mock')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, t, lat, lng, acc, spd, hdg, alt, act, bat, chg, mock);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocationPointRow &&
          other.id == this.id &&
          other.t == this.t &&
          other.lat == this.lat &&
          other.lng == this.lng &&
          other.acc == this.acc &&
          other.spd == this.spd &&
          other.hdg == this.hdg &&
          other.alt == this.alt &&
          other.act == this.act &&
          other.bat == this.bat &&
          other.chg == this.chg &&
          other.mock == this.mock);
}

class LocationQueueCompanion extends UpdateCompanion<LocationPointRow> {
  final Value<int> id;
  final Value<DateTime> t;
  final Value<double> lat;
  final Value<double> lng;
  final Value<double> acc;
  final Value<double?> spd;
  final Value<double?> hdg;
  final Value<double?> alt;
  final Value<String?> act;
  final Value<double?> bat;
  final Value<bool?> chg;
  final Value<bool> mock;
  const LocationQueueCompanion({
    this.id = const Value.absent(),
    this.t = const Value.absent(),
    this.lat = const Value.absent(),
    this.lng = const Value.absent(),
    this.acc = const Value.absent(),
    this.spd = const Value.absent(),
    this.hdg = const Value.absent(),
    this.alt = const Value.absent(),
    this.act = const Value.absent(),
    this.bat = const Value.absent(),
    this.chg = const Value.absent(),
    this.mock = const Value.absent(),
  });
  LocationQueueCompanion.insert({
    this.id = const Value.absent(),
    required DateTime t,
    required double lat,
    required double lng,
    required double acc,
    this.spd = const Value.absent(),
    this.hdg = const Value.absent(),
    this.alt = const Value.absent(),
    this.act = const Value.absent(),
    this.bat = const Value.absent(),
    this.chg = const Value.absent(),
    this.mock = const Value.absent(),
  }) : t = Value(t),
       lat = Value(lat),
       lng = Value(lng),
       acc = Value(acc);
  static Insertable<LocationPointRow> custom({
    Expression<int>? id,
    Expression<DateTime>? t,
    Expression<double>? lat,
    Expression<double>? lng,
    Expression<double>? acc,
    Expression<double>? spd,
    Expression<double>? hdg,
    Expression<double>? alt,
    Expression<String>? act,
    Expression<double>? bat,
    Expression<bool>? chg,
    Expression<bool>? mock,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (t != null) 't': t,
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
      if (acc != null) 'acc': acc,
      if (spd != null) 'spd': spd,
      if (hdg != null) 'hdg': hdg,
      if (alt != null) 'alt': alt,
      if (act != null) 'act': act,
      if (bat != null) 'bat': bat,
      if (chg != null) 'chg': chg,
      if (mock != null) 'mock': mock,
    });
  }

  LocationQueueCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? t,
    Value<double>? lat,
    Value<double>? lng,
    Value<double>? acc,
    Value<double?>? spd,
    Value<double?>? hdg,
    Value<double?>? alt,
    Value<String?>? act,
    Value<double?>? bat,
    Value<bool?>? chg,
    Value<bool>? mock,
  }) {
    return LocationQueueCompanion(
      id: id ?? this.id,
      t: t ?? this.t,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      acc: acc ?? this.acc,
      spd: spd ?? this.spd,
      hdg: hdg ?? this.hdg,
      alt: alt ?? this.alt,
      act: act ?? this.act,
      bat: bat ?? this.bat,
      chg: chg ?? this.chg,
      mock: mock ?? this.mock,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (t.present) {
      map['t'] = Variable<DateTime>(t.value);
    }
    if (lat.present) {
      map['lat'] = Variable<double>(lat.value);
    }
    if (lng.present) {
      map['lng'] = Variable<double>(lng.value);
    }
    if (acc.present) {
      map['acc'] = Variable<double>(acc.value);
    }
    if (spd.present) {
      map['spd'] = Variable<double>(spd.value);
    }
    if (hdg.present) {
      map['hdg'] = Variable<double>(hdg.value);
    }
    if (alt.present) {
      map['alt'] = Variable<double>(alt.value);
    }
    if (act.present) {
      map['act'] = Variable<String>(act.value);
    }
    if (bat.present) {
      map['bat'] = Variable<double>(bat.value);
    }
    if (chg.present) {
      map['chg'] = Variable<bool>(chg.value);
    }
    if (mock.present) {
      map['mock'] = Variable<bool>(mock.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocationQueueCompanion(')
          ..write('id: $id, ')
          ..write('t: $t, ')
          ..write('lat: $lat, ')
          ..write('lng: $lng, ')
          ..write('acc: $acc, ')
          ..write('spd: $spd, ')
          ..write('hdg: $hdg, ')
          ..write('alt: $alt, ')
          ..write('act: $act, ')
          ..write('bat: $bat, ')
          ..write('chg: $chg, ')
          ..write('mock: $mock')
          ..write(')'))
        .toString();
  }
}

class $ContactAttemptsTable extends ContactAttempts
    with TableInfo<$ContactAttemptsTable, ContactAttemptRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ContactAttemptsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _clientIdMeta = const VerificationMeta(
    'clientId',
  );
  @override
  late final GeneratedColumn<String> clientId = GeneratedColumn<String>(
    'client_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _serverIdMeta = const VerificationMeta(
    'serverId',
  );
  @override
  late final GeneratedColumn<String> serverId = GeneratedColumn<String>(
    'server_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _customerIdMeta = const VerificationMeta(
    'customerId',
  );
  @override
  late final GeneratedColumn<String> customerId = GeneratedColumn<String>(
    'customer_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _channelMeta = const VerificationMeta(
    'channel',
  );
  @override
  late final GeneratedColumn<String> channel = GeneratedColumn<String>(
    'channel',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _phoneIndexMeta = const VerificationMeta(
    'phoneIndex',
  );
  @override
  late final GeneratedColumn<int> phoneIndex = GeneratedColumn<int>(
    'phone_index',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _targetMeta = const VerificationMeta('target');
  @override
  late final GeneratedColumn<String> target = GeneratedColumn<String>(
    'target',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('customer'),
  );
  static const VerificationMeta _atMeta = const VerificationMeta('at');
  @override
  late final GeneratedColumn<DateTime> at = GeneratedColumn<DateTime>(
    'at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _outcomeMeta = const VerificationMeta(
    'outcome',
  );
  @override
  late final GeneratedColumn<String> outcome = GeneratedColumn<String>(
    'outcome',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncStateMeta = const VerificationMeta(
    'syncState',
  );
  @override
  late final GeneratedColumn<String> syncState = GeneratedColumn<String>(
    'sync_state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('queued'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    clientId,
    serverId,
    customerId,
    channel,
    phoneIndex,
    target,
    at,
    outcome,
    note,
    syncState,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'contact_attempts';
  @override
  VerificationContext validateIntegrity(
    Insertable<ContactAttemptRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('client_id')) {
      context.handle(
        _clientIdMeta,
        clientId.isAcceptableOrUnknown(data['client_id']!, _clientIdMeta),
      );
    } else if (isInserting) {
      context.missing(_clientIdMeta);
    }
    if (data.containsKey('server_id')) {
      context.handle(
        _serverIdMeta,
        serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta),
      );
    }
    if (data.containsKey('customer_id')) {
      context.handle(
        _customerIdMeta,
        customerId.isAcceptableOrUnknown(data['customer_id']!, _customerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_customerIdMeta);
    }
    if (data.containsKey('channel')) {
      context.handle(
        _channelMeta,
        channel.isAcceptableOrUnknown(data['channel']!, _channelMeta),
      );
    } else if (isInserting) {
      context.missing(_channelMeta);
    }
    if (data.containsKey('phone_index')) {
      context.handle(
        _phoneIndexMeta,
        phoneIndex.isAcceptableOrUnknown(data['phone_index']!, _phoneIndexMeta),
      );
    }
    if (data.containsKey('target')) {
      context.handle(
        _targetMeta,
        target.isAcceptableOrUnknown(data['target']!, _targetMeta),
      );
    }
    if (data.containsKey('at')) {
      context.handle(_atMeta, at.isAcceptableOrUnknown(data['at']!, _atMeta));
    } else if (isInserting) {
      context.missing(_atMeta);
    }
    if (data.containsKey('outcome')) {
      context.handle(
        _outcomeMeta,
        outcome.isAcceptableOrUnknown(data['outcome']!, _outcomeMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('sync_state')) {
      context.handle(
        _syncStateMeta,
        syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {clientId};
  @override
  ContactAttemptRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ContactAttemptRow(
      clientId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}client_id'],
      )!,
      serverId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}server_id'],
      ),
      customerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}customer_id'],
      )!,
      channel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}channel'],
      )!,
      phoneIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}phone_index'],
      ),
      target: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target'],
      )!,
      at: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}at'],
      )!,
      outcome: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}outcome'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      syncState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_state'],
      )!,
    );
  }

  @override
  $ContactAttemptsTable createAlias(String alias) {
    return $ContactAttemptsTable(attachedDatabase, alias);
  }
}

class ContactAttemptRow extends DataClass
    implements Insertable<ContactAttemptRow> {
  final String clientId;
  final String? serverId;
  final String customerId;

  /// call | sms | whatsapp
  final String channel;

  /// Index into the customer's phones — never the number itself.
  final int? phoneIndex;

  /// customer | guarantor (schema 6, contract 1.12.0).
  final String target;
  final DateTime at;

  /// connected | no_answer | busy | switched_off | wrong_number | sent
  final String? outcome;
  final String? note;
  final String syncState;
  const ContactAttemptRow({
    required this.clientId,
    this.serverId,
    required this.customerId,
    required this.channel,
    this.phoneIndex,
    required this.target,
    required this.at,
    this.outcome,
    this.note,
    required this.syncState,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['client_id'] = Variable<String>(clientId);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<String>(serverId);
    }
    map['customer_id'] = Variable<String>(customerId);
    map['channel'] = Variable<String>(channel);
    if (!nullToAbsent || phoneIndex != null) {
      map['phone_index'] = Variable<int>(phoneIndex);
    }
    map['target'] = Variable<String>(target);
    map['at'] = Variable<DateTime>(at);
    if (!nullToAbsent || outcome != null) {
      map['outcome'] = Variable<String>(outcome);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['sync_state'] = Variable<String>(syncState);
    return map;
  }

  ContactAttemptsCompanion toCompanion(bool nullToAbsent) {
    return ContactAttemptsCompanion(
      clientId: Value(clientId),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      customerId: Value(customerId),
      channel: Value(channel),
      phoneIndex: phoneIndex == null && nullToAbsent
          ? const Value.absent()
          : Value(phoneIndex),
      target: Value(target),
      at: Value(at),
      outcome: outcome == null && nullToAbsent
          ? const Value.absent()
          : Value(outcome),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      syncState: Value(syncState),
    );
  }

  factory ContactAttemptRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ContactAttemptRow(
      clientId: serializer.fromJson<String>(json['clientId']),
      serverId: serializer.fromJson<String?>(json['serverId']),
      customerId: serializer.fromJson<String>(json['customerId']),
      channel: serializer.fromJson<String>(json['channel']),
      phoneIndex: serializer.fromJson<int?>(json['phoneIndex']),
      target: serializer.fromJson<String>(json['target']),
      at: serializer.fromJson<DateTime>(json['at']),
      outcome: serializer.fromJson<String?>(json['outcome']),
      note: serializer.fromJson<String?>(json['note']),
      syncState: serializer.fromJson<String>(json['syncState']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'clientId': serializer.toJson<String>(clientId),
      'serverId': serializer.toJson<String?>(serverId),
      'customerId': serializer.toJson<String>(customerId),
      'channel': serializer.toJson<String>(channel),
      'phoneIndex': serializer.toJson<int?>(phoneIndex),
      'target': serializer.toJson<String>(target),
      'at': serializer.toJson<DateTime>(at),
      'outcome': serializer.toJson<String?>(outcome),
      'note': serializer.toJson<String?>(note),
      'syncState': serializer.toJson<String>(syncState),
    };
  }

  ContactAttemptRow copyWith({
    String? clientId,
    Value<String?> serverId = const Value.absent(),
    String? customerId,
    String? channel,
    Value<int?> phoneIndex = const Value.absent(),
    String? target,
    DateTime? at,
    Value<String?> outcome = const Value.absent(),
    Value<String?> note = const Value.absent(),
    String? syncState,
  }) => ContactAttemptRow(
    clientId: clientId ?? this.clientId,
    serverId: serverId.present ? serverId.value : this.serverId,
    customerId: customerId ?? this.customerId,
    channel: channel ?? this.channel,
    phoneIndex: phoneIndex.present ? phoneIndex.value : this.phoneIndex,
    target: target ?? this.target,
    at: at ?? this.at,
    outcome: outcome.present ? outcome.value : this.outcome,
    note: note.present ? note.value : this.note,
    syncState: syncState ?? this.syncState,
  );
  ContactAttemptRow copyWithCompanion(ContactAttemptsCompanion data) {
    return ContactAttemptRow(
      clientId: data.clientId.present ? data.clientId.value : this.clientId,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      customerId: data.customerId.present
          ? data.customerId.value
          : this.customerId,
      channel: data.channel.present ? data.channel.value : this.channel,
      phoneIndex: data.phoneIndex.present
          ? data.phoneIndex.value
          : this.phoneIndex,
      target: data.target.present ? data.target.value : this.target,
      at: data.at.present ? data.at.value : this.at,
      outcome: data.outcome.present ? data.outcome.value : this.outcome,
      note: data.note.present ? data.note.value : this.note,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ContactAttemptRow(')
          ..write('clientId: $clientId, ')
          ..write('serverId: $serverId, ')
          ..write('customerId: $customerId, ')
          ..write('channel: $channel, ')
          ..write('phoneIndex: $phoneIndex, ')
          ..write('target: $target, ')
          ..write('at: $at, ')
          ..write('outcome: $outcome, ')
          ..write('note: $note, ')
          ..write('syncState: $syncState')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    clientId,
    serverId,
    customerId,
    channel,
    phoneIndex,
    target,
    at,
    outcome,
    note,
    syncState,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ContactAttemptRow &&
          other.clientId == this.clientId &&
          other.serverId == this.serverId &&
          other.customerId == this.customerId &&
          other.channel == this.channel &&
          other.phoneIndex == this.phoneIndex &&
          other.target == this.target &&
          other.at == this.at &&
          other.outcome == this.outcome &&
          other.note == this.note &&
          other.syncState == this.syncState);
}

class ContactAttemptsCompanion extends UpdateCompanion<ContactAttemptRow> {
  final Value<String> clientId;
  final Value<String?> serverId;
  final Value<String> customerId;
  final Value<String> channel;
  final Value<int?> phoneIndex;
  final Value<String> target;
  final Value<DateTime> at;
  final Value<String?> outcome;
  final Value<String?> note;
  final Value<String> syncState;
  final Value<int> rowid;
  const ContactAttemptsCompanion({
    this.clientId = const Value.absent(),
    this.serverId = const Value.absent(),
    this.customerId = const Value.absent(),
    this.channel = const Value.absent(),
    this.phoneIndex = const Value.absent(),
    this.target = const Value.absent(),
    this.at = const Value.absent(),
    this.outcome = const Value.absent(),
    this.note = const Value.absent(),
    this.syncState = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ContactAttemptsCompanion.insert({
    required String clientId,
    this.serverId = const Value.absent(),
    required String customerId,
    required String channel,
    this.phoneIndex = const Value.absent(),
    this.target = const Value.absent(),
    required DateTime at,
    this.outcome = const Value.absent(),
    this.note = const Value.absent(),
    this.syncState = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : clientId = Value(clientId),
       customerId = Value(customerId),
       channel = Value(channel),
       at = Value(at);
  static Insertable<ContactAttemptRow> custom({
    Expression<String>? clientId,
    Expression<String>? serverId,
    Expression<String>? customerId,
    Expression<String>? channel,
    Expression<int>? phoneIndex,
    Expression<String>? target,
    Expression<DateTime>? at,
    Expression<String>? outcome,
    Expression<String>? note,
    Expression<String>? syncState,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (clientId != null) 'client_id': clientId,
      if (serverId != null) 'server_id': serverId,
      if (customerId != null) 'customer_id': customerId,
      if (channel != null) 'channel': channel,
      if (phoneIndex != null) 'phone_index': phoneIndex,
      if (target != null) 'target': target,
      if (at != null) 'at': at,
      if (outcome != null) 'outcome': outcome,
      if (note != null) 'note': note,
      if (syncState != null) 'sync_state': syncState,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ContactAttemptsCompanion copyWith({
    Value<String>? clientId,
    Value<String?>? serverId,
    Value<String>? customerId,
    Value<String>? channel,
    Value<int?>? phoneIndex,
    Value<String>? target,
    Value<DateTime>? at,
    Value<String?>? outcome,
    Value<String?>? note,
    Value<String>? syncState,
    Value<int>? rowid,
  }) {
    return ContactAttemptsCompanion(
      clientId: clientId ?? this.clientId,
      serverId: serverId ?? this.serverId,
      customerId: customerId ?? this.customerId,
      channel: channel ?? this.channel,
      phoneIndex: phoneIndex ?? this.phoneIndex,
      target: target ?? this.target,
      at: at ?? this.at,
      outcome: outcome ?? this.outcome,
      note: note ?? this.note,
      syncState: syncState ?? this.syncState,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (clientId.present) {
      map['client_id'] = Variable<String>(clientId.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<String>(serverId.value);
    }
    if (customerId.present) {
      map['customer_id'] = Variable<String>(customerId.value);
    }
    if (channel.present) {
      map['channel'] = Variable<String>(channel.value);
    }
    if (phoneIndex.present) {
      map['phone_index'] = Variable<int>(phoneIndex.value);
    }
    if (target.present) {
      map['target'] = Variable<String>(target.value);
    }
    if (at.present) {
      map['at'] = Variable<DateTime>(at.value);
    }
    if (outcome.present) {
      map['outcome'] = Variable<String>(outcome.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(syncState.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ContactAttemptsCompanion(')
          ..write('clientId: $clientId, ')
          ..write('serverId: $serverId, ')
          ..write('customerId: $customerId, ')
          ..write('channel: $channel, ')
          ..write('phoneIndex: $phoneIndex, ')
          ..write('target: $target, ')
          ..write('at: $at, ')
          ..write('outcome: $outcome, ')
          ..write('note: $note, ')
          ..write('syncState: $syncState, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CoworkSessionsTable extends CoworkSessions
    with TableInfo<$CoworkSessionsTable, CoworkSessionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CoworkSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _businessDateMeta = const VerificationMeta(
    'businessDate',
  );
  @override
  late final GeneratedColumn<String> businessDate = GeneratedColumn<String>(
    'business_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdByMeta = const VerificationMeta(
    'createdBy',
  );
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
    'created_by',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _membersJsonMeta = const VerificationMeta(
    'membersJson',
  );
  @override
  late final GeneratedColumn<String> membersJson = GeneratedColumn<String>(
    'members_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endedAtMeta = const VerificationMeta(
    'endedAt',
  );
  @override
  late final GeneratedColumn<DateTime> endedAt = GeneratedColumn<DateTime>(
    'ended_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    businessDate,
    status,
    createdBy,
    note,
    membersJson,
    createdAt,
    endedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cowork_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<CoworkSessionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('business_date')) {
      context.handle(
        _businessDateMeta,
        businessDate.isAcceptableOrUnknown(
          data['business_date']!,
          _businessDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_businessDateMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('created_by')) {
      context.handle(
        _createdByMeta,
        createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta),
      );
    } else if (isInserting) {
      context.missing(_createdByMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('members_json')) {
      context.handle(
        _membersJsonMeta,
        membersJson.isAcceptableOrUnknown(
          data['members_json']!,
          _membersJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_membersJsonMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('ended_at')) {
      context.handle(
        _endedAtMeta,
        endedAt.isAcceptableOrUnknown(data['ended_at']!, _endedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CoworkSessionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CoworkSessionRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      businessDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}business_date'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      createdBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      membersJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}members_json'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      endedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ended_at'],
      ),
    );
  }

  @override
  $CoworkSessionsTable createAlias(String alias) {
    return $CoworkSessionsTable(attachedDatabase, alias);
  }
}

class CoworkSessionRow extends DataClass
    implements Insertable<CoworkSessionRow> {
  final String id;
  final String businessDate;

  /// open | ended
  final String status;
  final String createdBy;
  final String? note;

  /// CoworkMember[] as JSON (userId, name, status, invitedBy, invitedAt, respondedAt, leftAt).
  final String membersJson;
  final DateTime createdAt;
  final DateTime? endedAt;
  const CoworkSessionRow({
    required this.id,
    required this.businessDate,
    required this.status,
    required this.createdBy,
    this.note,
    required this.membersJson,
    required this.createdAt,
    this.endedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['business_date'] = Variable<String>(businessDate);
    map['status'] = Variable<String>(status);
    map['created_by'] = Variable<String>(createdBy);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['members_json'] = Variable<String>(membersJson);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || endedAt != null) {
      map['ended_at'] = Variable<DateTime>(endedAt);
    }
    return map;
  }

  CoworkSessionsCompanion toCompanion(bool nullToAbsent) {
    return CoworkSessionsCompanion(
      id: Value(id),
      businessDate: Value(businessDate),
      status: Value(status),
      createdBy: Value(createdBy),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      membersJson: Value(membersJson),
      createdAt: Value(createdAt),
      endedAt: endedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(endedAt),
    );
  }

  factory CoworkSessionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CoworkSessionRow(
      id: serializer.fromJson<String>(json['id']),
      businessDate: serializer.fromJson<String>(json['businessDate']),
      status: serializer.fromJson<String>(json['status']),
      createdBy: serializer.fromJson<String>(json['createdBy']),
      note: serializer.fromJson<String?>(json['note']),
      membersJson: serializer.fromJson<String>(json['membersJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      endedAt: serializer.fromJson<DateTime?>(json['endedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'businessDate': serializer.toJson<String>(businessDate),
      'status': serializer.toJson<String>(status),
      'createdBy': serializer.toJson<String>(createdBy),
      'note': serializer.toJson<String?>(note),
      'membersJson': serializer.toJson<String>(membersJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'endedAt': serializer.toJson<DateTime?>(endedAt),
    };
  }

  CoworkSessionRow copyWith({
    String? id,
    String? businessDate,
    String? status,
    String? createdBy,
    Value<String?> note = const Value.absent(),
    String? membersJson,
    DateTime? createdAt,
    Value<DateTime?> endedAt = const Value.absent(),
  }) => CoworkSessionRow(
    id: id ?? this.id,
    businessDate: businessDate ?? this.businessDate,
    status: status ?? this.status,
    createdBy: createdBy ?? this.createdBy,
    note: note.present ? note.value : this.note,
    membersJson: membersJson ?? this.membersJson,
    createdAt: createdAt ?? this.createdAt,
    endedAt: endedAt.present ? endedAt.value : this.endedAt,
  );
  CoworkSessionRow copyWithCompanion(CoworkSessionsCompanion data) {
    return CoworkSessionRow(
      id: data.id.present ? data.id.value : this.id,
      businessDate: data.businessDate.present
          ? data.businessDate.value
          : this.businessDate,
      status: data.status.present ? data.status.value : this.status,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      note: data.note.present ? data.note.value : this.note,
      membersJson: data.membersJson.present
          ? data.membersJson.value
          : this.membersJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CoworkSessionRow(')
          ..write('id: $id, ')
          ..write('businessDate: $businessDate, ')
          ..write('status: $status, ')
          ..write('createdBy: $createdBy, ')
          ..write('note: $note, ')
          ..write('membersJson: $membersJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('endedAt: $endedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    businessDate,
    status,
    createdBy,
    note,
    membersJson,
    createdAt,
    endedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CoworkSessionRow &&
          other.id == this.id &&
          other.businessDate == this.businessDate &&
          other.status == this.status &&
          other.createdBy == this.createdBy &&
          other.note == this.note &&
          other.membersJson == this.membersJson &&
          other.createdAt == this.createdAt &&
          other.endedAt == this.endedAt);
}

class CoworkSessionsCompanion extends UpdateCompanion<CoworkSessionRow> {
  final Value<String> id;
  final Value<String> businessDate;
  final Value<String> status;
  final Value<String> createdBy;
  final Value<String?> note;
  final Value<String> membersJson;
  final Value<DateTime> createdAt;
  final Value<DateTime?> endedAt;
  final Value<int> rowid;
  const CoworkSessionsCompanion({
    this.id = const Value.absent(),
    this.businessDate = const Value.absent(),
    this.status = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.note = const Value.absent(),
    this.membersJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CoworkSessionsCompanion.insert({
    required String id,
    required String businessDate,
    required String status,
    required String createdBy,
    this.note = const Value.absent(),
    required String membersJson,
    required DateTime createdAt,
    this.endedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       businessDate = Value(businessDate),
       status = Value(status),
       createdBy = Value(createdBy),
       membersJson = Value(membersJson),
       createdAt = Value(createdAt);
  static Insertable<CoworkSessionRow> custom({
    Expression<String>? id,
    Expression<String>? businessDate,
    Expression<String>? status,
    Expression<String>? createdBy,
    Expression<String>? note,
    Expression<String>? membersJson,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? endedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (businessDate != null) 'business_date': businessDate,
      if (status != null) 'status': status,
      if (createdBy != null) 'created_by': createdBy,
      if (note != null) 'note': note,
      if (membersJson != null) 'members_json': membersJson,
      if (createdAt != null) 'created_at': createdAt,
      if (endedAt != null) 'ended_at': endedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CoworkSessionsCompanion copyWith({
    Value<String>? id,
    Value<String>? businessDate,
    Value<String>? status,
    Value<String>? createdBy,
    Value<String?>? note,
    Value<String>? membersJson,
    Value<DateTime>? createdAt,
    Value<DateTime?>? endedAt,
    Value<int>? rowid,
  }) {
    return CoworkSessionsCompanion(
      id: id ?? this.id,
      businessDate: businessDate ?? this.businessDate,
      status: status ?? this.status,
      createdBy: createdBy ?? this.createdBy,
      note: note ?? this.note,
      membersJson: membersJson ?? this.membersJson,
      createdAt: createdAt ?? this.createdAt,
      endedAt: endedAt ?? this.endedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (businessDate.present) {
      map['business_date'] = Variable<String>(businessDate.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (membersJson.present) {
      map['members_json'] = Variable<String>(membersJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<DateTime>(endedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CoworkSessionsCompanion(')
          ..write('id: $id, ')
          ..write('businessDate: $businessDate, ')
          ..write('status: $status, ')
          ..write('createdBy: $createdBy, ')
          ..write('note: $note, ')
          ..write('membersJson: $membersJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BroadcastsTable extends Broadcasts
    with TableInfo<$BroadcastsTable, BroadcastRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BroadcastsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _serverIdMeta = const VerificationMeta(
    'serverId',
  );
  @override
  late final GeneratedColumn<String> serverId = GeneratedColumn<String>(
    'server_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleBnMeta = const VerificationMeta(
    'titleBn',
  );
  @override
  late final GeneratedColumn<String> titleBn = GeneratedColumn<String>(
    'title_bn',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleEnMeta = const VerificationMeta(
    'titleEn',
  );
  @override
  late final GeneratedColumn<String> titleEn = GeneratedColumn<String>(
    'title_en',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bodyBnMeta = const VerificationMeta('bodyBn');
  @override
  late final GeneratedColumn<String> bodyBn = GeneratedColumn<String>(
    'body_bn',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bodyEnMeta = const VerificationMeta('bodyEn');
  @override
  late final GeneratedColumn<String> bodyEn = GeneratedColumn<String>(
    'body_en',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _requireAckMeta = const VerificationMeta(
    'requireAck',
  );
  @override
  late final GeneratedColumn<bool> requireAck = GeneratedColumn<bool>(
    'require_ack',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("require_ack" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _senderNameMeta = const VerificationMeta(
    'senderName',
  );
  @override
  late final GeneratedColumn<String> senderName = GeneratedColumn<String>(
    'sender_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ackedAtMeta = const VerificationMeta(
    'ackedAt',
  );
  @override
  late final GeneratedColumn<DateTime> ackedAt = GeneratedColumn<DateTime>(
    'acked_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ackStateMeta = const VerificationMeta(
    'ackState',
  );
  @override
  late final GeneratedColumn<String> ackState = GeneratedColumn<String>(
    'ack_state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('none'),
  );
  static const VerificationMeta _ackMutationIdMeta = const VerificationMeta(
    'ackMutationId',
  );
  @override
  late final GeneratedColumn<String> ackMutationId = GeneratedColumn<String>(
    'ack_mutation_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    serverId,
    titleBn,
    titleEn,
    bodyBn,
    bodyEn,
    requireAck,
    senderName,
    createdAt,
    ackedAt,
    ackState,
    ackMutationId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'broadcasts';
  @override
  VerificationContext validateIntegrity(
    Insertable<BroadcastRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('server_id')) {
      context.handle(
        _serverIdMeta,
        serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta),
      );
    } else if (isInserting) {
      context.missing(_serverIdMeta);
    }
    if (data.containsKey('title_bn')) {
      context.handle(
        _titleBnMeta,
        titleBn.isAcceptableOrUnknown(data['title_bn']!, _titleBnMeta),
      );
    } else if (isInserting) {
      context.missing(_titleBnMeta);
    }
    if (data.containsKey('title_en')) {
      context.handle(
        _titleEnMeta,
        titleEn.isAcceptableOrUnknown(data['title_en']!, _titleEnMeta),
      );
    }
    if (data.containsKey('body_bn')) {
      context.handle(
        _bodyBnMeta,
        bodyBn.isAcceptableOrUnknown(data['body_bn']!, _bodyBnMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyBnMeta);
    }
    if (data.containsKey('body_en')) {
      context.handle(
        _bodyEnMeta,
        bodyEn.isAcceptableOrUnknown(data['body_en']!, _bodyEnMeta),
      );
    }
    if (data.containsKey('require_ack')) {
      context.handle(
        _requireAckMeta,
        requireAck.isAcceptableOrUnknown(data['require_ack']!, _requireAckMeta),
      );
    }
    if (data.containsKey('sender_name')) {
      context.handle(
        _senderNameMeta,
        senderName.isAcceptableOrUnknown(data['sender_name']!, _senderNameMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('acked_at')) {
      context.handle(
        _ackedAtMeta,
        ackedAt.isAcceptableOrUnknown(data['acked_at']!, _ackedAtMeta),
      );
    }
    if (data.containsKey('ack_state')) {
      context.handle(
        _ackStateMeta,
        ackState.isAcceptableOrUnknown(data['ack_state']!, _ackStateMeta),
      );
    }
    if (data.containsKey('ack_mutation_id')) {
      context.handle(
        _ackMutationIdMeta,
        ackMutationId.isAcceptableOrUnknown(
          data['ack_mutation_id']!,
          _ackMutationIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {serverId};
  @override
  BroadcastRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BroadcastRow(
      serverId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}server_id'],
      )!,
      titleBn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title_bn'],
      )!,
      titleEn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title_en'],
      ),
      bodyBn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body_bn'],
      )!,
      bodyEn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body_en'],
      ),
      requireAck: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}require_ack'],
      )!,
      senderName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sender_name'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      ackedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}acked_at'],
      ),
      ackState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ack_state'],
      )!,
      ackMutationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ack_mutation_id'],
      ),
    );
  }

  @override
  $BroadcastsTable createAlias(String alias) {
    return $BroadcastsTable(attachedDatabase, alias);
  }
}

class BroadcastRow extends DataClass implements Insertable<BroadcastRow> {
  final String serverId;
  final String titleBn;
  final String? titleEn;
  final String bodyBn;
  final String? bodyEn;
  final bool requireAck;
  final String? senderName;
  final DateTime createdAt;

  /// When I tapped "read" (or the server's time once it knows).
  final DateTime? ackedAt;

  /// none | queued | synced | failed
  final String ackState;
  final String? ackMutationId;
  const BroadcastRow({
    required this.serverId,
    required this.titleBn,
    this.titleEn,
    required this.bodyBn,
    this.bodyEn,
    required this.requireAck,
    this.senderName,
    required this.createdAt,
    this.ackedAt,
    required this.ackState,
    this.ackMutationId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['server_id'] = Variable<String>(serverId);
    map['title_bn'] = Variable<String>(titleBn);
    if (!nullToAbsent || titleEn != null) {
      map['title_en'] = Variable<String>(titleEn);
    }
    map['body_bn'] = Variable<String>(bodyBn);
    if (!nullToAbsent || bodyEn != null) {
      map['body_en'] = Variable<String>(bodyEn);
    }
    map['require_ack'] = Variable<bool>(requireAck);
    if (!nullToAbsent || senderName != null) {
      map['sender_name'] = Variable<String>(senderName);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || ackedAt != null) {
      map['acked_at'] = Variable<DateTime>(ackedAt);
    }
    map['ack_state'] = Variable<String>(ackState);
    if (!nullToAbsent || ackMutationId != null) {
      map['ack_mutation_id'] = Variable<String>(ackMutationId);
    }
    return map;
  }

  BroadcastsCompanion toCompanion(bool nullToAbsent) {
    return BroadcastsCompanion(
      serverId: Value(serverId),
      titleBn: Value(titleBn),
      titleEn: titleEn == null && nullToAbsent
          ? const Value.absent()
          : Value(titleEn),
      bodyBn: Value(bodyBn),
      bodyEn: bodyEn == null && nullToAbsent
          ? const Value.absent()
          : Value(bodyEn),
      requireAck: Value(requireAck),
      senderName: senderName == null && nullToAbsent
          ? const Value.absent()
          : Value(senderName),
      createdAt: Value(createdAt),
      ackedAt: ackedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(ackedAt),
      ackState: Value(ackState),
      ackMutationId: ackMutationId == null && nullToAbsent
          ? const Value.absent()
          : Value(ackMutationId),
    );
  }

  factory BroadcastRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BroadcastRow(
      serverId: serializer.fromJson<String>(json['serverId']),
      titleBn: serializer.fromJson<String>(json['titleBn']),
      titleEn: serializer.fromJson<String?>(json['titleEn']),
      bodyBn: serializer.fromJson<String>(json['bodyBn']),
      bodyEn: serializer.fromJson<String?>(json['bodyEn']),
      requireAck: serializer.fromJson<bool>(json['requireAck']),
      senderName: serializer.fromJson<String?>(json['senderName']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      ackedAt: serializer.fromJson<DateTime?>(json['ackedAt']),
      ackState: serializer.fromJson<String>(json['ackState']),
      ackMutationId: serializer.fromJson<String?>(json['ackMutationId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'serverId': serializer.toJson<String>(serverId),
      'titleBn': serializer.toJson<String>(titleBn),
      'titleEn': serializer.toJson<String?>(titleEn),
      'bodyBn': serializer.toJson<String>(bodyBn),
      'bodyEn': serializer.toJson<String?>(bodyEn),
      'requireAck': serializer.toJson<bool>(requireAck),
      'senderName': serializer.toJson<String?>(senderName),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'ackedAt': serializer.toJson<DateTime?>(ackedAt),
      'ackState': serializer.toJson<String>(ackState),
      'ackMutationId': serializer.toJson<String?>(ackMutationId),
    };
  }

  BroadcastRow copyWith({
    String? serverId,
    String? titleBn,
    Value<String?> titleEn = const Value.absent(),
    String? bodyBn,
    Value<String?> bodyEn = const Value.absent(),
    bool? requireAck,
    Value<String?> senderName = const Value.absent(),
    DateTime? createdAt,
    Value<DateTime?> ackedAt = const Value.absent(),
    String? ackState,
    Value<String?> ackMutationId = const Value.absent(),
  }) => BroadcastRow(
    serverId: serverId ?? this.serverId,
    titleBn: titleBn ?? this.titleBn,
    titleEn: titleEn.present ? titleEn.value : this.titleEn,
    bodyBn: bodyBn ?? this.bodyBn,
    bodyEn: bodyEn.present ? bodyEn.value : this.bodyEn,
    requireAck: requireAck ?? this.requireAck,
    senderName: senderName.present ? senderName.value : this.senderName,
    createdAt: createdAt ?? this.createdAt,
    ackedAt: ackedAt.present ? ackedAt.value : this.ackedAt,
    ackState: ackState ?? this.ackState,
    ackMutationId: ackMutationId.present
        ? ackMutationId.value
        : this.ackMutationId,
  );
  BroadcastRow copyWithCompanion(BroadcastsCompanion data) {
    return BroadcastRow(
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      titleBn: data.titleBn.present ? data.titleBn.value : this.titleBn,
      titleEn: data.titleEn.present ? data.titleEn.value : this.titleEn,
      bodyBn: data.bodyBn.present ? data.bodyBn.value : this.bodyBn,
      bodyEn: data.bodyEn.present ? data.bodyEn.value : this.bodyEn,
      requireAck: data.requireAck.present
          ? data.requireAck.value
          : this.requireAck,
      senderName: data.senderName.present
          ? data.senderName.value
          : this.senderName,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      ackedAt: data.ackedAt.present ? data.ackedAt.value : this.ackedAt,
      ackState: data.ackState.present ? data.ackState.value : this.ackState,
      ackMutationId: data.ackMutationId.present
          ? data.ackMutationId.value
          : this.ackMutationId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BroadcastRow(')
          ..write('serverId: $serverId, ')
          ..write('titleBn: $titleBn, ')
          ..write('titleEn: $titleEn, ')
          ..write('bodyBn: $bodyBn, ')
          ..write('bodyEn: $bodyEn, ')
          ..write('requireAck: $requireAck, ')
          ..write('senderName: $senderName, ')
          ..write('createdAt: $createdAt, ')
          ..write('ackedAt: $ackedAt, ')
          ..write('ackState: $ackState, ')
          ..write('ackMutationId: $ackMutationId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    serverId,
    titleBn,
    titleEn,
    bodyBn,
    bodyEn,
    requireAck,
    senderName,
    createdAt,
    ackedAt,
    ackState,
    ackMutationId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BroadcastRow &&
          other.serverId == this.serverId &&
          other.titleBn == this.titleBn &&
          other.titleEn == this.titleEn &&
          other.bodyBn == this.bodyBn &&
          other.bodyEn == this.bodyEn &&
          other.requireAck == this.requireAck &&
          other.senderName == this.senderName &&
          other.createdAt == this.createdAt &&
          other.ackedAt == this.ackedAt &&
          other.ackState == this.ackState &&
          other.ackMutationId == this.ackMutationId);
}

class BroadcastsCompanion extends UpdateCompanion<BroadcastRow> {
  final Value<String> serverId;
  final Value<String> titleBn;
  final Value<String?> titleEn;
  final Value<String> bodyBn;
  final Value<String?> bodyEn;
  final Value<bool> requireAck;
  final Value<String?> senderName;
  final Value<DateTime> createdAt;
  final Value<DateTime?> ackedAt;
  final Value<String> ackState;
  final Value<String?> ackMutationId;
  final Value<int> rowid;
  const BroadcastsCompanion({
    this.serverId = const Value.absent(),
    this.titleBn = const Value.absent(),
    this.titleEn = const Value.absent(),
    this.bodyBn = const Value.absent(),
    this.bodyEn = const Value.absent(),
    this.requireAck = const Value.absent(),
    this.senderName = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.ackedAt = const Value.absent(),
    this.ackState = const Value.absent(),
    this.ackMutationId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BroadcastsCompanion.insert({
    required String serverId,
    required String titleBn,
    this.titleEn = const Value.absent(),
    required String bodyBn,
    this.bodyEn = const Value.absent(),
    this.requireAck = const Value.absent(),
    this.senderName = const Value.absent(),
    required DateTime createdAt,
    this.ackedAt = const Value.absent(),
    this.ackState = const Value.absent(),
    this.ackMutationId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : serverId = Value(serverId),
       titleBn = Value(titleBn),
       bodyBn = Value(bodyBn),
       createdAt = Value(createdAt);
  static Insertable<BroadcastRow> custom({
    Expression<String>? serverId,
    Expression<String>? titleBn,
    Expression<String>? titleEn,
    Expression<String>? bodyBn,
    Expression<String>? bodyEn,
    Expression<bool>? requireAck,
    Expression<String>? senderName,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? ackedAt,
    Expression<String>? ackState,
    Expression<String>? ackMutationId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (serverId != null) 'server_id': serverId,
      if (titleBn != null) 'title_bn': titleBn,
      if (titleEn != null) 'title_en': titleEn,
      if (bodyBn != null) 'body_bn': bodyBn,
      if (bodyEn != null) 'body_en': bodyEn,
      if (requireAck != null) 'require_ack': requireAck,
      if (senderName != null) 'sender_name': senderName,
      if (createdAt != null) 'created_at': createdAt,
      if (ackedAt != null) 'acked_at': ackedAt,
      if (ackState != null) 'ack_state': ackState,
      if (ackMutationId != null) 'ack_mutation_id': ackMutationId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BroadcastsCompanion copyWith({
    Value<String>? serverId,
    Value<String>? titleBn,
    Value<String?>? titleEn,
    Value<String>? bodyBn,
    Value<String?>? bodyEn,
    Value<bool>? requireAck,
    Value<String?>? senderName,
    Value<DateTime>? createdAt,
    Value<DateTime?>? ackedAt,
    Value<String>? ackState,
    Value<String?>? ackMutationId,
    Value<int>? rowid,
  }) {
    return BroadcastsCompanion(
      serverId: serverId ?? this.serverId,
      titleBn: titleBn ?? this.titleBn,
      titleEn: titleEn ?? this.titleEn,
      bodyBn: bodyBn ?? this.bodyBn,
      bodyEn: bodyEn ?? this.bodyEn,
      requireAck: requireAck ?? this.requireAck,
      senderName: senderName ?? this.senderName,
      createdAt: createdAt ?? this.createdAt,
      ackedAt: ackedAt ?? this.ackedAt,
      ackState: ackState ?? this.ackState,
      ackMutationId: ackMutationId ?? this.ackMutationId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (serverId.present) {
      map['server_id'] = Variable<String>(serverId.value);
    }
    if (titleBn.present) {
      map['title_bn'] = Variable<String>(titleBn.value);
    }
    if (titleEn.present) {
      map['title_en'] = Variable<String>(titleEn.value);
    }
    if (bodyBn.present) {
      map['body_bn'] = Variable<String>(bodyBn.value);
    }
    if (bodyEn.present) {
      map['body_en'] = Variable<String>(bodyEn.value);
    }
    if (requireAck.present) {
      map['require_ack'] = Variable<bool>(requireAck.value);
    }
    if (senderName.present) {
      map['sender_name'] = Variable<String>(senderName.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (ackedAt.present) {
      map['acked_at'] = Variable<DateTime>(ackedAt.value);
    }
    if (ackState.present) {
      map['ack_state'] = Variable<String>(ackState.value);
    }
    if (ackMutationId.present) {
      map['ack_mutation_id'] = Variable<String>(ackMutationId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BroadcastsCompanion(')
          ..write('serverId: $serverId, ')
          ..write('titleBn: $titleBn, ')
          ..write('titleEn: $titleEn, ')
          ..write('bodyBn: $bodyBn, ')
          ..write('bodyEn: $bodyEn, ')
          ..write('requireAck: $requireAck, ')
          ..write('senderName: $senderName, ')
          ..write('createdAt: $createdAt, ')
          ..write('ackedAt: $ackedAt, ')
          ..write('ackState: $ackState, ')
          ..write('ackMutationId: $ackMutationId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $NotificationsTable extends Notifications
    with TableInfo<$NotificationsTable, NotificationRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NotificationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _serverIdMeta = const VerificationMeta(
    'serverId',
  );
  @override
  late final GeneratedColumn<String> serverId = GeneratedColumn<String>(
    'server_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dataJsonMeta = const VerificationMeta(
    'dataJson',
  );
  @override
  late final GeneratedColumn<String> dataJson = GeneratedColumn<String>(
    'data_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _readAtMeta = const VerificationMeta('readAt');
  @override
  late final GeneratedColumn<DateTime> readAt = GeneratedColumn<DateTime>(
    'read_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    serverId,
    type,
    title,
    body,
    dataJson,
    readAt,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'notifications';
  @override
  VerificationContext validateIntegrity(
    Insertable<NotificationRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('server_id')) {
      context.handle(
        _serverIdMeta,
        serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta),
      );
    } else if (isInserting) {
      context.missing(_serverIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    if (data.containsKey('data_json')) {
      context.handle(
        _dataJsonMeta,
        dataJson.isAcceptableOrUnknown(data['data_json']!, _dataJsonMeta),
      );
    }
    if (data.containsKey('read_at')) {
      context.handle(
        _readAtMeta,
        readAt.isAcceptableOrUnknown(data['read_at']!, _readAtMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {serverId};
  @override
  NotificationRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NotificationRow(
      serverId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}server_id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      )!,
      dataJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}data_json'],
      )!,
      readAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}read_at'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $NotificationsTable createAlias(String alias) {
    return $NotificationsTable(attachedDatabase, alias);
  }
}

class NotificationRow extends DataClass implements Insertable<NotificationRow> {
  final String serverId;
  final String type;
  final String title;
  final String body;
  final String dataJson;
  final DateTime? readAt;
  final DateTime createdAt;
  const NotificationRow({
    required this.serverId,
    required this.type,
    required this.title,
    required this.body,
    required this.dataJson,
    this.readAt,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['server_id'] = Variable<String>(serverId);
    map['type'] = Variable<String>(type);
    map['title'] = Variable<String>(title);
    map['body'] = Variable<String>(body);
    map['data_json'] = Variable<String>(dataJson);
    if (!nullToAbsent || readAt != null) {
      map['read_at'] = Variable<DateTime>(readAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  NotificationsCompanion toCompanion(bool nullToAbsent) {
    return NotificationsCompanion(
      serverId: Value(serverId),
      type: Value(type),
      title: Value(title),
      body: Value(body),
      dataJson: Value(dataJson),
      readAt: readAt == null && nullToAbsent
          ? const Value.absent()
          : Value(readAt),
      createdAt: Value(createdAt),
    );
  }

  factory NotificationRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NotificationRow(
      serverId: serializer.fromJson<String>(json['serverId']),
      type: serializer.fromJson<String>(json['type']),
      title: serializer.fromJson<String>(json['title']),
      body: serializer.fromJson<String>(json['body']),
      dataJson: serializer.fromJson<String>(json['dataJson']),
      readAt: serializer.fromJson<DateTime?>(json['readAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'serverId': serializer.toJson<String>(serverId),
      'type': serializer.toJson<String>(type),
      'title': serializer.toJson<String>(title),
      'body': serializer.toJson<String>(body),
      'dataJson': serializer.toJson<String>(dataJson),
      'readAt': serializer.toJson<DateTime?>(readAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  NotificationRow copyWith({
    String? serverId,
    String? type,
    String? title,
    String? body,
    String? dataJson,
    Value<DateTime?> readAt = const Value.absent(),
    DateTime? createdAt,
  }) => NotificationRow(
    serverId: serverId ?? this.serverId,
    type: type ?? this.type,
    title: title ?? this.title,
    body: body ?? this.body,
    dataJson: dataJson ?? this.dataJson,
    readAt: readAt.present ? readAt.value : this.readAt,
    createdAt: createdAt ?? this.createdAt,
  );
  NotificationRow copyWithCompanion(NotificationsCompanion data) {
    return NotificationRow(
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      type: data.type.present ? data.type.value : this.type,
      title: data.title.present ? data.title.value : this.title,
      body: data.body.present ? data.body.value : this.body,
      dataJson: data.dataJson.present ? data.dataJson.value : this.dataJson,
      readAt: data.readAt.present ? data.readAt.value : this.readAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NotificationRow(')
          ..write('serverId: $serverId, ')
          ..write('type: $type, ')
          ..write('title: $title, ')
          ..write('body: $body, ')
          ..write('dataJson: $dataJson, ')
          ..write('readAt: $readAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(serverId, type, title, body, dataJson, readAt, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NotificationRow &&
          other.serverId == this.serverId &&
          other.type == this.type &&
          other.title == this.title &&
          other.body == this.body &&
          other.dataJson == this.dataJson &&
          other.readAt == this.readAt &&
          other.createdAt == this.createdAt);
}

class NotificationsCompanion extends UpdateCompanion<NotificationRow> {
  final Value<String> serverId;
  final Value<String> type;
  final Value<String> title;
  final Value<String> body;
  final Value<String> dataJson;
  final Value<DateTime?> readAt;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const NotificationsCompanion({
    this.serverId = const Value.absent(),
    this.type = const Value.absent(),
    this.title = const Value.absent(),
    this.body = const Value.absent(),
    this.dataJson = const Value.absent(),
    this.readAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  NotificationsCompanion.insert({
    required String serverId,
    required String type,
    required String title,
    required String body,
    this.dataJson = const Value.absent(),
    this.readAt = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : serverId = Value(serverId),
       type = Value(type),
       title = Value(title),
       body = Value(body),
       createdAt = Value(createdAt);
  static Insertable<NotificationRow> custom({
    Expression<String>? serverId,
    Expression<String>? type,
    Expression<String>? title,
    Expression<String>? body,
    Expression<String>? dataJson,
    Expression<DateTime>? readAt,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (serverId != null) 'server_id': serverId,
      if (type != null) 'type': type,
      if (title != null) 'title': title,
      if (body != null) 'body': body,
      if (dataJson != null) 'data_json': dataJson,
      if (readAt != null) 'read_at': readAt,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  NotificationsCompanion copyWith({
    Value<String>? serverId,
    Value<String>? type,
    Value<String>? title,
    Value<String>? body,
    Value<String>? dataJson,
    Value<DateTime?>? readAt,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return NotificationsCompanion(
      serverId: serverId ?? this.serverId,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      dataJson: dataJson ?? this.dataJson,
      readAt: readAt ?? this.readAt,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (serverId.present) {
      map['server_id'] = Variable<String>(serverId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (dataJson.present) {
      map['data_json'] = Variable<String>(dataJson.value);
    }
    if (readAt.present) {
      map['read_at'] = Variable<DateTime>(readAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NotificationsCompanion(')
          ..write('serverId: $serverId, ')
          ..write('type: $type, ')
          ..write('title: $title, ')
          ..write('body: $body, ')
          ..write('dataJson: $dataJson, ')
          ..write('readAt: $readAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $KvSettingsTable extends KvSettings
    with TableInfo<$KvSettingsTable, KvRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $KvSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueJsonMeta = const VerificationMeta(
    'valueJson',
  );
  @override
  late final GeneratedColumn<String> valueJson = GeneratedColumn<String>(
    'value_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, valueJson];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'kv_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<KvRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value_json')) {
      context.handle(
        _valueJsonMeta,
        valueJson.isAcceptableOrUnknown(data['value_json']!, _valueJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_valueJsonMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  KvRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return KvRow(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      valueJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value_json'],
      )!,
    );
  }

  @override
  $KvSettingsTable createAlias(String alias) {
    return $KvSettingsTable(attachedDatabase, alias);
  }
}

class KvRow extends DataClass implements Insertable<KvRow> {
  final String key;
  final String valueJson;
  const KvRow({required this.key, required this.valueJson});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value_json'] = Variable<String>(valueJson);
    return map;
  }

  KvSettingsCompanion toCompanion(bool nullToAbsent) {
    return KvSettingsCompanion(key: Value(key), valueJson: Value(valueJson));
  }

  factory KvRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return KvRow(
      key: serializer.fromJson<String>(json['key']),
      valueJson: serializer.fromJson<String>(json['valueJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'valueJson': serializer.toJson<String>(valueJson),
    };
  }

  KvRow copyWith({String? key, String? valueJson}) =>
      KvRow(key: key ?? this.key, valueJson: valueJson ?? this.valueJson);
  KvRow copyWithCompanion(KvSettingsCompanion data) {
    return KvRow(
      key: data.key.present ? data.key.value : this.key,
      valueJson: data.valueJson.present ? data.valueJson.value : this.valueJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('KvRow(')
          ..write('key: $key, ')
          ..write('valueJson: $valueJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, valueJson);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is KvRow &&
          other.key == this.key &&
          other.valueJson == this.valueJson);
}

class KvSettingsCompanion extends UpdateCompanion<KvRow> {
  final Value<String> key;
  final Value<String> valueJson;
  final Value<int> rowid;
  const KvSettingsCompanion({
    this.key = const Value.absent(),
    this.valueJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  KvSettingsCompanion.insert({
    required String key,
    required String valueJson,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       valueJson = Value(valueJson);
  static Insertable<KvRow> custom({
    Expression<String>? key,
    Expression<String>? valueJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (valueJson != null) 'value_json': valueJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  KvSettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? valueJson,
    Value<int>? rowid,
  }) {
    return KvSettingsCompanion(
      key: key ?? this.key,
      valueJson: valueJson ?? this.valueJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (valueJson.present) {
      map['value_json'] = Variable<String>(valueJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('KvSettingsCompanion(')
          ..write('key: $key, ')
          ..write('valueJson: $valueJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CustomersTable customers = $CustomersTable(this);
  late final $PlansTable plans = $PlansTable(this);
  late final $ScheduleLinesTable scheduleLines = $ScheduleLinesTable(this);
  late final $ErpPaymentsTable erpPayments = $ErpPaymentsTable(this);
  late final $LocationProposalsTable locationProposals =
      $LocationProposalsTable(this);
  late final $CollectionsTable collections = $CollectionsTable(this);
  late final $ReceiptBlocksTable receiptBlocks = $ReceiptBlocksTable(this);
  late final $CashPositionsTable cashPositions = $CashPositionsTable(this);
  late final $DepositsTable deposits = $DepositsTable(this);
  late final $CashClosingsTable cashClosings = $CashClosingsTable(this);
  late final $VisitsTable visits = $VisitsTable(this);
  late final $NotesTable notes = $NotesTable(this);
  late final $PromisesTable promises = $PromisesTable(this);
  late final $TagEventsTable tagEvents = $TagEventsTable(this);
  late final $AttendanceEventsTable attendanceEvents = $AttendanceEventsTable(
    this,
  );
  late final $AttendanceDaysTable attendanceDays = $AttendanceDaysTable(this);
  late final $HandoversTable handovers = $HandoversTable(this);
  late final $MediaQueueTable mediaQueue = $MediaQueueTable(this);
  late final $OutboxTable outbox = $OutboxTable(this);
  late final $IdMapTable idMap = $IdMapTable(this);
  late final $SyncMetaTable syncMeta = $SyncMetaTable(this);
  late final $LocationQueueTable locationQueue = $LocationQueueTable(this);
  late final $ContactAttemptsTable contactAttempts = $ContactAttemptsTable(
    this,
  );
  late final $CoworkSessionsTable coworkSessions = $CoworkSessionsTable(this);
  late final $BroadcastsTable broadcasts = $BroadcastsTable(this);
  late final $NotificationsTable notifications = $NotificationsTable(this);
  late final $KvSettingsTable kvSettings = $KvSettingsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    customers,
    plans,
    scheduleLines,
    erpPayments,
    locationProposals,
    collections,
    receiptBlocks,
    cashPositions,
    deposits,
    cashClosings,
    visits,
    notes,
    promises,
    tagEvents,
    attendanceEvents,
    attendanceDays,
    handovers,
    mediaQueue,
    outbox,
    idMap,
    syncMeta,
    locationQueue,
    contactAttempts,
    coworkSessions,
    broadcasts,
    notifications,
    kvSettings,
  ];
}

typedef $$CustomersTableCreateCompanionBuilder = CustomersCompanion Function({
  required String serverId,
  Value<String?> erpCustomerId,
  required String code,
  required String nameBn,
  Value<String?> nameEn,
  Value<String> phonesJson,
  Value<String?> address,
  Value<String?> areaId,
  Value<String?> areaName,
  Value<double?> lat,
  Value<double?> lng,
  Value<String> locationStatus,
  Value<int> totalOutstandingPoisha,
  Value<int?> installmentPoisha,
  Value<int> overduePoisha,
  Value<String?> nextDueDate,
  Value<int> daysOverdue,
  Value<bool> dueToday,
  Value<bool> overdue,
  Value<bool> badSuggested,
  Value<String?> badReasonJson,
  Value<String> tagState,
  Value<String?> tagSeverity,
  Value<String?> tagReason,
  Value<DateTime?> lastVisitAt,
  Value<String?> openPromiseId,
  Value<String?> openPromiseDate,
  Value<int?> openPromisePoisha,
  Value<int> pendingFieldPoisha,
  Value<String?> assigneeId,
  Value<DateTime?> erpFetchedAt,
  Value<String?> guarantorJson,
  Value<String> searchText,
  Value<int> version,
  Value<int> rowid,
});
typedef $$CustomersTableUpdateCompanionBuilder = CustomersCompanion Function({
  Value<String> serverId,
  Value<String?> erpCustomerId,
  Value<String> code,
  Value<String> nameBn,
  Value<String?> nameEn,
  Value<String> phonesJson,
  Value<String?> address,
  Value<String?> areaId,
  Value<String?> areaName,
  Value<double?> lat,
  Value<double?> lng,
  Value<String> locationStatus,
  Value<int> totalOutstandingPoisha,
  Value<int?> installmentPoisha,
  Value<int> overduePoisha,
  Value<String?> nextDueDate,
  Value<int> daysOverdue,
  Value<bool> dueToday,
  Value<bool> overdue,
  Value<bool> badSuggested,
  Value<String?> badReasonJson,
  Value<String> tagState,
  Value<String?> tagSeverity,
  Value<String?> tagReason,
  Value<DateTime?> lastVisitAt,
  Value<String?> openPromiseId,
  Value<String?> openPromiseDate,
  Value<int?> openPromisePoisha,
  Value<int> pendingFieldPoisha,
  Value<String?> assigneeId,
  Value<DateTime?> erpFetchedAt,
  Value<String?> guarantorJson,
  Value<String> searchText,
  Value<int> version,
  Value<int> rowid,
});

class $$CustomersTableFilterComposer
    extends Composer<_$AppDatabase, $CustomersTable> {
  $$CustomersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get erpCustomerId => $composableBuilder(
    column: $table.erpCustomerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nameBn => $composableBuilder(
    column: $table.nameBn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nameEn => $composableBuilder(
    column: $table.nameEn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phonesJson => $composableBuilder(
    column: $table.phonesJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get areaId => $composableBuilder(
    column: $table.areaId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get areaName => $composableBuilder(
    column: $table.areaName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lat => $composableBuilder(
    column: $table.lat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lng => $composableBuilder(
    column: $table.lng,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get locationStatus => $composableBuilder(
    column: $table.locationStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalOutstandingPoisha => $composableBuilder(
    column: $table.totalOutstandingPoisha,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get installmentPoisha => $composableBuilder(
    column: $table.installmentPoisha,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get overduePoisha => $composableBuilder(
    column: $table.overduePoisha,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nextDueDate => $composableBuilder(
    column: $table.nextDueDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get daysOverdue => $composableBuilder(
    column: $table.daysOverdue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get dueToday => $composableBuilder(
    column: $table.dueToday,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get overdue => $composableBuilder(
    column: $table.overdue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get badSuggested => $composableBuilder(
    column: $table.badSuggested,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get badReasonJson => $composableBuilder(
    column: $table.badReasonJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tagState => $composableBuilder(
    column: $table.tagState,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tagSeverity => $composableBuilder(
    column: $table.tagSeverity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tagReason => $composableBuilder(
    column: $table.tagReason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastVisitAt => $composableBuilder(
    column: $table.lastVisitAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get openPromiseId => $composableBuilder(
    column: $table.openPromiseId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get openPromiseDate => $composableBuilder(
    column: $table.openPromiseDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get openPromisePoisha => $composableBuilder(
    column: $table.openPromisePoisha,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pendingFieldPoisha => $composableBuilder(
    column: $table.pendingFieldPoisha,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get assigneeId => $composableBuilder(
    column: $table.assigneeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get erpFetchedAt => $composableBuilder(
    column: $table.erpFetchedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get guarantorJson => $composableBuilder(
    column: $table.guarantorJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get searchText => $composableBuilder(
    column: $table.searchText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CustomersTableOrderingComposer
    extends Composer<_$AppDatabase, $CustomersTable> {
  $$CustomersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get erpCustomerId => $composableBuilder(
    column: $table.erpCustomerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nameBn => $composableBuilder(
    column: $table.nameBn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nameEn => $composableBuilder(
    column: $table.nameEn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phonesJson => $composableBuilder(
    column: $table.phonesJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get areaId => $composableBuilder(
    column: $table.areaId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get areaName => $composableBuilder(
    column: $table.areaName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lat => $composableBuilder(
    column: $table.lat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lng => $composableBuilder(
    column: $table.lng,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get locationStatus => $composableBuilder(
    column: $table.locationStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalOutstandingPoisha => $composableBuilder(
    column: $table.totalOutstandingPoisha,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get installmentPoisha => $composableBuilder(
    column: $table.installmentPoisha,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get overduePoisha => $composableBuilder(
    column: $table.overduePoisha,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nextDueDate => $composableBuilder(
    column: $table.nextDueDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get daysOverdue => $composableBuilder(
    column: $table.daysOverdue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get dueToday => $composableBuilder(
    column: $table.dueToday,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get overdue => $composableBuilder(
    column: $table.overdue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get badSuggested => $composableBuilder(
    column: $table.badSuggested,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get badReasonJson => $composableBuilder(
    column: $table.badReasonJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tagState => $composableBuilder(
    column: $table.tagState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tagSeverity => $composableBuilder(
    column: $table.tagSeverity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tagReason => $composableBuilder(
    column: $table.tagReason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastVisitAt => $composableBuilder(
    column: $table.lastVisitAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get openPromiseId => $composableBuilder(
    column: $table.openPromiseId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get openPromiseDate => $composableBuilder(
    column: $table.openPromiseDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get openPromisePoisha => $composableBuilder(
    column: $table.openPromisePoisha,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pendingFieldPoisha => $composableBuilder(
    column: $table.pendingFieldPoisha,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get assigneeId => $composableBuilder(
    column: $table.assigneeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get erpFetchedAt => $composableBuilder(
    column: $table.erpFetchedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get guarantorJson => $composableBuilder(
    column: $table.guarantorJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get searchText => $composableBuilder(
    column: $table.searchText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CustomersTableAnnotationComposer
    extends Composer<_$AppDatabase, $CustomersTable> {
  $$CustomersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<String> get erpCustomerId => $composableBuilder(
    column: $table.erpCustomerId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get nameBn =>
      $composableBuilder(column: $table.nameBn, builder: (column) => column);

  GeneratedColumn<String> get nameEn =>
      $composableBuilder(column: $table.nameEn, builder: (column) => column);

  GeneratedColumn<String> get phonesJson => $composableBuilder(
    column: $table.phonesJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<String> get areaId =>
      $composableBuilder(column: $table.areaId, builder: (column) => column);

  GeneratedColumn<String> get areaName =>
      $composableBuilder(column: $table.areaName, builder: (column) => column);

  GeneratedColumn<double> get lat =>
      $composableBuilder(column: $table.lat, builder: (column) => column);

  GeneratedColumn<double> get lng =>
      $composableBuilder(column: $table.lng, builder: (column) => column);

  GeneratedColumn<String> get locationStatus => $composableBuilder(
    column: $table.locationStatus,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalOutstandingPoisha => $composableBuilder(
    column: $table.totalOutstandingPoisha,
    builder: (column) => column,
  );

  GeneratedColumn<int> get installmentPoisha => $composableBuilder(
    column: $table.installmentPoisha,
    builder: (column) => column,
  );

  GeneratedColumn<int> get overduePoisha => $composableBuilder(
    column: $table.overduePoisha,
    builder: (column) => column,
  );

  GeneratedColumn<String> get nextDueDate => $composableBuilder(
    column: $table.nextDueDate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get daysOverdue => $composableBuilder(
    column: $table.daysOverdue,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get dueToday =>
      $composableBuilder(column: $table.dueToday, builder: (column) => column);

  GeneratedColumn<bool> get overdue =>
      $composableBuilder(column: $table.overdue, builder: (column) => column);

  GeneratedColumn<bool> get badSuggested => $composableBuilder(
    column: $table.badSuggested,
    builder: (column) => column,
  );

  GeneratedColumn<String> get badReasonJson => $composableBuilder(
    column: $table.badReasonJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get tagState =>
      $composableBuilder(column: $table.tagState, builder: (column) => column);

  GeneratedColumn<String> get tagSeverity => $composableBuilder(
    column: $table.tagSeverity,
    builder: (column) => column,
  );

  GeneratedColumn<String> get tagReason =>
      $composableBuilder(column: $table.tagReason, builder: (column) => column);

  GeneratedColumn<DateTime> get lastVisitAt => $composableBuilder(
    column: $table.lastVisitAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get openPromiseId => $composableBuilder(
    column: $table.openPromiseId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get openPromiseDate => $composableBuilder(
    column: $table.openPromiseDate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get openPromisePoisha => $composableBuilder(
    column: $table.openPromisePoisha,
    builder: (column) => column,
  );

  GeneratedColumn<int> get pendingFieldPoisha => $composableBuilder(
    column: $table.pendingFieldPoisha,
    builder: (column) => column,
  );

  GeneratedColumn<String> get assigneeId => $composableBuilder(
    column: $table.assigneeId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get erpFetchedAt => $composableBuilder(
    column: $table.erpFetchedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get guarantorJson => $composableBuilder(
    column: $table.guarantorJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get searchText => $composableBuilder(
    column: $table.searchText,
    builder: (column) => column,
  );

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);
}

class $$CustomersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CustomersTable,
          CustomerRow,
          $$CustomersTableFilterComposer,
          $$CustomersTableOrderingComposer,
          $$CustomersTableAnnotationComposer,
          $$CustomersTableCreateCompanionBuilder,
          $$CustomersTableUpdateCompanionBuilder,
          (
            CustomerRow,
            BaseReferences<_$AppDatabase, $CustomersTable, CustomerRow>,
          ),
          CustomerRow,
          PrefetchHooks Function()
        > {
  $$CustomersTableTableManager(_$AppDatabase db, $CustomersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CustomersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CustomersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CustomersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> serverId = const Value.absent(),
                Value<String?> erpCustomerId = const Value.absent(),
                Value<String> code = const Value.absent(),
                Value<String> nameBn = const Value.absent(),
                Value<String?> nameEn = const Value.absent(),
                Value<String> phonesJson = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<String?> areaId = const Value.absent(),
                Value<String?> areaName = const Value.absent(),
                Value<double?> lat = const Value.absent(),
                Value<double?> lng = const Value.absent(),
                Value<String> locationStatus = const Value.absent(),
                Value<int> totalOutstandingPoisha = const Value.absent(),
                Value<int?> installmentPoisha = const Value.absent(),
                Value<int> overduePoisha = const Value.absent(),
                Value<String?> nextDueDate = const Value.absent(),
                Value<int> daysOverdue = const Value.absent(),
                Value<bool> dueToday = const Value.absent(),
                Value<bool> overdue = const Value.absent(),
                Value<bool> badSuggested = const Value.absent(),
                Value<String?> badReasonJson = const Value.absent(),
                Value<String> tagState = const Value.absent(),
                Value<String?> tagSeverity = const Value.absent(),
                Value<String?> tagReason = const Value.absent(),
                Value<DateTime?> lastVisitAt = const Value.absent(),
                Value<String?> openPromiseId = const Value.absent(),
                Value<String?> openPromiseDate = const Value.absent(),
                Value<int?> openPromisePoisha = const Value.absent(),
                Value<int> pendingFieldPoisha = const Value.absent(),
                Value<String?> assigneeId = const Value.absent(),
                Value<DateTime?> erpFetchedAt = const Value.absent(),
                Value<String?> guarantorJson = const Value.absent(),
                Value<String> searchText = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CustomersCompanion(
                serverId: serverId,
                erpCustomerId: erpCustomerId,
                code: code,
                nameBn: nameBn,
                nameEn: nameEn,
                phonesJson: phonesJson,
                address: address,
                areaId: areaId,
                areaName: areaName,
                lat: lat,
                lng: lng,
                locationStatus: locationStatus,
                totalOutstandingPoisha: totalOutstandingPoisha,
                installmentPoisha: installmentPoisha,
                overduePoisha: overduePoisha,
                nextDueDate: nextDueDate,
                daysOverdue: daysOverdue,
                dueToday: dueToday,
                overdue: overdue,
                badSuggested: badSuggested,
                badReasonJson: badReasonJson,
                tagState: tagState,
                tagSeverity: tagSeverity,
                tagReason: tagReason,
                lastVisitAt: lastVisitAt,
                openPromiseId: openPromiseId,
                openPromiseDate: openPromiseDate,
                openPromisePoisha: openPromisePoisha,
                pendingFieldPoisha: pendingFieldPoisha,
                assigneeId: assigneeId,
                erpFetchedAt: erpFetchedAt,
                guarantorJson: guarantorJson,
                searchText: searchText,
                version: version,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String serverId,
                Value<String?> erpCustomerId = const Value.absent(),
                required String code,
                required String nameBn,
                Value<String?> nameEn = const Value.absent(),
                Value<String> phonesJson = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<String?> areaId = const Value.absent(),
                Value<String?> areaName = const Value.absent(),
                Value<double?> lat = const Value.absent(),
                Value<double?> lng = const Value.absent(),
                Value<String> locationStatus = const Value.absent(),
                Value<int> totalOutstandingPoisha = const Value.absent(),
                Value<int?> installmentPoisha = const Value.absent(),
                Value<int> overduePoisha = const Value.absent(),
                Value<String?> nextDueDate = const Value.absent(),
                Value<int> daysOverdue = const Value.absent(),
                Value<bool> dueToday = const Value.absent(),
                Value<bool> overdue = const Value.absent(),
                Value<bool> badSuggested = const Value.absent(),
                Value<String?> badReasonJson = const Value.absent(),
                Value<String> tagState = const Value.absent(),
                Value<String?> tagSeverity = const Value.absent(),
                Value<String?> tagReason = const Value.absent(),
                Value<DateTime?> lastVisitAt = const Value.absent(),
                Value<String?> openPromiseId = const Value.absent(),
                Value<String?> openPromiseDate = const Value.absent(),
                Value<int?> openPromisePoisha = const Value.absent(),
                Value<int> pendingFieldPoisha = const Value.absent(),
                Value<String?> assigneeId = const Value.absent(),
                Value<DateTime?> erpFetchedAt = const Value.absent(),
                Value<String?> guarantorJson = const Value.absent(),
                Value<String> searchText = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CustomersCompanion.insert(
                serverId: serverId,
                erpCustomerId: erpCustomerId,
                code: code,
                nameBn: nameBn,
                nameEn: nameEn,
                phonesJson: phonesJson,
                address: address,
                areaId: areaId,
                areaName: areaName,
                lat: lat,
                lng: lng,
                locationStatus: locationStatus,
                totalOutstandingPoisha: totalOutstandingPoisha,
                installmentPoisha: installmentPoisha,
                overduePoisha: overduePoisha,
                nextDueDate: nextDueDate,
                daysOverdue: daysOverdue,
                dueToday: dueToday,
                overdue: overdue,
                badSuggested: badSuggested,
                badReasonJson: badReasonJson,
                tagState: tagState,
                tagSeverity: tagSeverity,
                tagReason: tagReason,
                lastVisitAt: lastVisitAt,
                openPromiseId: openPromiseId,
                openPromiseDate: openPromiseDate,
                openPromisePoisha: openPromisePoisha,
                pendingFieldPoisha: pendingFieldPoisha,
                assigneeId: assigneeId,
                erpFetchedAt: erpFetchedAt,
                guarantorJson: guarantorJson,
                searchText: searchText,
                version: version,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CustomersTable, CustomerRow>(table),
                  BaseReferences<_$AppDatabase, $CustomersTable, CustomerRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CustomersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CustomersTable,
      CustomerRow,
      $$CustomersTableFilterComposer,
      $$CustomersTableOrderingComposer,
      $$CustomersTableAnnotationComposer,
      $$CustomersTableCreateCompanionBuilder,
      $$CustomersTableUpdateCompanionBuilder,
      (
        CustomerRow,
        BaseReferences<_$AppDatabase, $CustomersTable, CustomerRow>,
      ),
      CustomerRow,
      PrefetchHooks Function()
    >;
typedef $$PlansTableCreateCompanionBuilder = PlansCompanion Function({
  required String erpPlanId,
  required String customerId,
  required String product,
  required String startDate,
  required String finalDueDate,
  required int installmentCount,
  required int totalPayablePoisha,
  Value<int> downPaymentPoisha,
  required int paidPoisha,
  required int outstandingPoisha,
  required String status,
  Value<bool> badSuggested,
  Value<int> rowid,
});
typedef $$PlansTableUpdateCompanionBuilder = PlansCompanion Function({
  Value<String> erpPlanId,
  Value<String> customerId,
  Value<String> product,
  Value<String> startDate,
  Value<String> finalDueDate,
  Value<int> installmentCount,
  Value<int> totalPayablePoisha,
  Value<int> downPaymentPoisha,
  Value<int> paidPoisha,
  Value<int> outstandingPoisha,
  Value<String> status,
  Value<bool> badSuggested,
  Value<int> rowid,
});

class $$PlansTableFilterComposer extends Composer<_$AppDatabase, $PlansTable> {
  $$PlansTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get erpPlanId => $composableBuilder(
    column: $table.erpPlanId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get product => $composableBuilder(
    column: $table.product,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get finalDueDate => $composableBuilder(
    column: $table.finalDueDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get installmentCount => $composableBuilder(
    column: $table.installmentCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalPayablePoisha => $composableBuilder(
    column: $table.totalPayablePoisha,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get downPaymentPoisha => $composableBuilder(
    column: $table.downPaymentPoisha,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get paidPoisha => $composableBuilder(
    column: $table.paidPoisha,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get outstandingPoisha => $composableBuilder(
    column: $table.outstandingPoisha,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get badSuggested => $composableBuilder(
    column: $table.badSuggested,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PlansTableOrderingComposer
    extends Composer<_$AppDatabase, $PlansTable> {
  $$PlansTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get erpPlanId => $composableBuilder(
    column: $table.erpPlanId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get product => $composableBuilder(
    column: $table.product,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get finalDueDate => $composableBuilder(
    column: $table.finalDueDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get installmentCount => $composableBuilder(
    column: $table.installmentCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalPayablePoisha => $composableBuilder(
    column: $table.totalPayablePoisha,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get downPaymentPoisha => $composableBuilder(
    column: $table.downPaymentPoisha,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get paidPoisha => $composableBuilder(
    column: $table.paidPoisha,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get outstandingPoisha => $composableBuilder(
    column: $table.outstandingPoisha,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get badSuggested => $composableBuilder(
    column: $table.badSuggested,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PlansTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlansTable> {
  $$PlansTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get erpPlanId =>
      $composableBuilder(column: $table.erpPlanId, builder: (column) => column);

  GeneratedColumn<String> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get product =>
      $composableBuilder(column: $table.product, builder: (column) => column);

  GeneratedColumn<String> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<String> get finalDueDate => $composableBuilder(
    column: $table.finalDueDate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get installmentCount => $composableBuilder(
    column: $table.installmentCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalPayablePoisha => $composableBuilder(
    column: $table.totalPayablePoisha,
    builder: (column) => column,
  );

  GeneratedColumn<int> get downPaymentPoisha => $composableBuilder(
    column: $table.downPaymentPoisha,
    builder: (column) => column,
  );

  GeneratedColumn<int> get paidPoisha => $composableBuilder(
    column: $table.paidPoisha,
    builder: (column) => column,
  );

  GeneratedColumn<int> get outstandingPoisha => $composableBuilder(
    column: $table.outstandingPoisha,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<bool> get badSuggested => $composableBuilder(
    column: $table.badSuggested,
    builder: (column) => column,
  );
}

class $$PlansTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlansTable,
          PlanRow,
          $$PlansTableFilterComposer,
          $$PlansTableOrderingComposer,
          $$PlansTableAnnotationComposer,
          $$PlansTableCreateCompanionBuilder,
          $$PlansTableUpdateCompanionBuilder,
          (PlanRow, BaseReferences<_$AppDatabase, $PlansTable, PlanRow>),
          PlanRow,
          PrefetchHooks Function()
        > {
  $$PlansTableTableManager(_$AppDatabase db, $PlansTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlansTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlansTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlansTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> erpPlanId = const Value.absent(),
                Value<String> customerId = const Value.absent(),
                Value<String> product = const Value.absent(),
                Value<String> startDate = const Value.absent(),
                Value<String> finalDueDate = const Value.absent(),
                Value<int> installmentCount = const Value.absent(),
                Value<int> totalPayablePoisha = const Value.absent(),
                Value<int> downPaymentPoisha = const Value.absent(),
                Value<int> paidPoisha = const Value.absent(),
                Value<int> outstandingPoisha = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<bool> badSuggested = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlansCompanion(
                erpPlanId: erpPlanId,
                customerId: customerId,
                product: product,
                startDate: startDate,
                finalDueDate: finalDueDate,
                installmentCount: installmentCount,
                totalPayablePoisha: totalPayablePoisha,
                downPaymentPoisha: downPaymentPoisha,
                paidPoisha: paidPoisha,
                outstandingPoisha: outstandingPoisha,
                status: status,
                badSuggested: badSuggested,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String erpPlanId,
                required String customerId,
                required String product,
                required String startDate,
                required String finalDueDate,
                required int installmentCount,
                required int totalPayablePoisha,
                Value<int> downPaymentPoisha = const Value.absent(),
                required int paidPoisha,
                required int outstandingPoisha,
                required String status,
                Value<bool> badSuggested = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlansCompanion.insert(
                erpPlanId: erpPlanId,
                customerId: customerId,
                product: product,
                startDate: startDate,
                finalDueDate: finalDueDate,
                installmentCount: installmentCount,
                totalPayablePoisha: totalPayablePoisha,
                downPaymentPoisha: downPaymentPoisha,
                paidPoisha: paidPoisha,
                outstandingPoisha: outstandingPoisha,
                status: status,
                badSuggested: badSuggested,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PlansTable, PlanRow>(table),
                  BaseReferences<_$AppDatabase, $PlansTable, PlanRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PlansTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlansTable,
      PlanRow,
      $$PlansTableFilterComposer,
      $$PlansTableOrderingComposer,
      $$PlansTableAnnotationComposer,
      $$PlansTableCreateCompanionBuilder,
      $$PlansTableUpdateCompanionBuilder,
      (PlanRow, BaseReferences<_$AppDatabase, $PlansTable, PlanRow>),
      PlanRow,
      PrefetchHooks Function()
    >;
typedef $$ScheduleLinesTableCreateCompanionBuilder =
    ScheduleLinesCompanion Function({
      required String erpPlanId,
      required int seq,
      required String dueDate,
      required int amountPoisha,
      required int paidPoisha,
      required String status,
      Value<bool> estimated,
      Value<int> rowid,
    });
typedef $$ScheduleLinesTableUpdateCompanionBuilder =
    ScheduleLinesCompanion Function({
      Value<String> erpPlanId,
      Value<int> seq,
      Value<String> dueDate,
      Value<int> amountPoisha,
      Value<int> paidPoisha,
      Value<String> status,
      Value<bool> estimated,
      Value<int> rowid,
    });

class $$ScheduleLinesTableFilterComposer
    extends Composer<_$AppDatabase, $ScheduleLinesTable> {
  $$ScheduleLinesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get erpPlanId => $composableBuilder(
    column: $table.erpPlanId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get seq => $composableBuilder(
    column: $table.seq,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountPoisha => $composableBuilder(
    column: $table.amountPoisha,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get paidPoisha => $composableBuilder(
    column: $table.paidPoisha,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get estimated => $composableBuilder(
    column: $table.estimated,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ScheduleLinesTableOrderingComposer
    extends Composer<_$AppDatabase, $ScheduleLinesTable> {
  $$ScheduleLinesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get erpPlanId => $composableBuilder(
    column: $table.erpPlanId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get seq => $composableBuilder(
    column: $table.seq,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountPoisha => $composableBuilder(
    column: $table.amountPoisha,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get paidPoisha => $composableBuilder(
    column: $table.paidPoisha,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get estimated => $composableBuilder(
    column: $table.estimated,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ScheduleLinesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ScheduleLinesTable> {
  $$ScheduleLinesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get erpPlanId =>
      $composableBuilder(column: $table.erpPlanId, builder: (column) => column);

  GeneratedColumn<int> get seq =>
      $composableBuilder(column: $table.seq, builder: (column) => column);

  GeneratedColumn<String> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumn<int> get amountPoisha => $composableBuilder(
    column: $table.amountPoisha,
    builder: (column) => column,
  );

  GeneratedColumn<int> get paidPoisha => $composableBuilder(
    column: $table.paidPoisha,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<bool> get estimated =>
      $composableBuilder(column: $table.estimated, builder: (column) => column);
}

class $$ScheduleLinesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ScheduleLinesTable,
          ScheduleLineRow,
          $$ScheduleLinesTableFilterComposer,
          $$ScheduleLinesTableOrderingComposer,
          $$ScheduleLinesTableAnnotationComposer,
          $$ScheduleLinesTableCreateCompanionBuilder,
          $$ScheduleLinesTableUpdateCompanionBuilder,
          (
            ScheduleLineRow,
            BaseReferences<_$AppDatabase, $ScheduleLinesTable, ScheduleLineRow>,
          ),
          ScheduleLineRow,
          PrefetchHooks Function()
        > {
  $$ScheduleLinesTableTableManager(_$AppDatabase db, $ScheduleLinesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ScheduleLinesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ScheduleLinesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ScheduleLinesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> erpPlanId = const Value.absent(),
                Value<int> seq = const Value.absent(),
                Value<String> dueDate = const Value.absent(),
                Value<int> amountPoisha = const Value.absent(),
                Value<int> paidPoisha = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<bool> estimated = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ScheduleLinesCompanion(
                erpPlanId: erpPlanId,
                seq: seq,
                dueDate: dueDate,
                amountPoisha: amountPoisha,
                paidPoisha: paidPoisha,
                status: status,
                estimated: estimated,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String erpPlanId,
                required int seq,
                required String dueDate,
                required int amountPoisha,
                required int paidPoisha,
                required String status,
                Value<bool> estimated = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ScheduleLinesCompanion.insert(
                erpPlanId: erpPlanId,
                seq: seq,
                dueDate: dueDate,
                amountPoisha: amountPoisha,
                paidPoisha: paidPoisha,
                status: status,
                estimated: estimated,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ScheduleLinesTable, ScheduleLineRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $ScheduleLinesTable,
                    ScheduleLineRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ScheduleLinesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ScheduleLinesTable,
      ScheduleLineRow,
      $$ScheduleLinesTableFilterComposer,
      $$ScheduleLinesTableOrderingComposer,
      $$ScheduleLinesTableAnnotationComposer,
      $$ScheduleLinesTableCreateCompanionBuilder,
      $$ScheduleLinesTableUpdateCompanionBuilder,
      (
        ScheduleLineRow,
        BaseReferences<_$AppDatabase, $ScheduleLinesTable, ScheduleLineRow>,
      ),
      ScheduleLineRow,
      PrefetchHooks Function()
    >;
typedef $$ErpPaymentsTableCreateCompanionBuilder =
    ErpPaymentsCompanion Function({
      required String erpPaymentId,
      required String customerId,
      Value<String?> planId,
      required String date,
      required int amountPoisha,
      required String method,
      required String source,
      Value<String?> receiptNo,
      Value<bool> reversed,
      Value<int> rowid,
    });
typedef $$ErpPaymentsTableUpdateCompanionBuilder =
    ErpPaymentsCompanion Function({
      Value<String> erpPaymentId,
      Value<String> customerId,
      Value<String?> planId,
      Value<String> date,
      Value<int> amountPoisha,
      Value<String> method,
      Value<String> source,
      Value<String?> receiptNo,
      Value<bool> reversed,
      Value<int> rowid,
    });

class $$ErpPaymentsTableFilterComposer
    extends Composer<_$AppDatabase, $ErpPaymentsTable> {
  $$ErpPaymentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get erpPaymentId => $composableBuilder(
    column: $table.erpPaymentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get planId => $composableBuilder(
    column: $table.planId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountPoisha => $composableBuilder(
    column: $table.amountPoisha,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get method => $composableBuilder(
    column: $table.method,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get receiptNo => $composableBuilder(
    column: $table.receiptNo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get reversed => $composableBuilder(
    column: $table.reversed,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ErpPaymentsTableOrderingComposer
    extends Composer<_$AppDatabase, $ErpPaymentsTable> {
  $$ErpPaymentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get erpPaymentId => $composableBuilder(
    column: $table.erpPaymentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get planId => $composableBuilder(
    column: $table.planId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountPoisha => $composableBuilder(
    column: $table.amountPoisha,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get method => $composableBuilder(
    column: $table.method,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get receiptNo => $composableBuilder(
    column: $table.receiptNo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get reversed => $composableBuilder(
    column: $table.reversed,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ErpPaymentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ErpPaymentsTable> {
  $$ErpPaymentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get erpPaymentId => $composableBuilder(
    column: $table.erpPaymentId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get planId =>
      $composableBuilder(column: $table.planId, builder: (column) => column);

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<int> get amountPoisha => $composableBuilder(
    column: $table.amountPoisha,
    builder: (column) => column,
  );

  GeneratedColumn<String> get method =>
      $composableBuilder(column: $table.method, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get receiptNo =>
      $composableBuilder(column: $table.receiptNo, builder: (column) => column);

  GeneratedColumn<bool> get reversed =>
      $composableBuilder(column: $table.reversed, builder: (column) => column);
}

class $$ErpPaymentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ErpPaymentsTable,
          ErpPaymentRow,
          $$ErpPaymentsTableFilterComposer,
          $$ErpPaymentsTableOrderingComposer,
          $$ErpPaymentsTableAnnotationComposer,
          $$ErpPaymentsTableCreateCompanionBuilder,
          $$ErpPaymentsTableUpdateCompanionBuilder,
          (
            ErpPaymentRow,
            BaseReferences<_$AppDatabase, $ErpPaymentsTable, ErpPaymentRow>,
          ),
          ErpPaymentRow,
          PrefetchHooks Function()
        > {
  $$ErpPaymentsTableTableManager(_$AppDatabase db, $ErpPaymentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ErpPaymentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ErpPaymentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ErpPaymentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> erpPaymentId = const Value.absent(),
                Value<String> customerId = const Value.absent(),
                Value<String?> planId = const Value.absent(),
                Value<String> date = const Value.absent(),
                Value<int> amountPoisha = const Value.absent(),
                Value<String> method = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String?> receiptNo = const Value.absent(),
                Value<bool> reversed = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ErpPaymentsCompanion(
                erpPaymentId: erpPaymentId,
                customerId: customerId,
                planId: planId,
                date: date,
                amountPoisha: amountPoisha,
                method: method,
                source: source,
                receiptNo: receiptNo,
                reversed: reversed,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String erpPaymentId,
                required String customerId,
                Value<String?> planId = const Value.absent(),
                required String date,
                required int amountPoisha,
                required String method,
                required String source,
                Value<String?> receiptNo = const Value.absent(),
                Value<bool> reversed = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ErpPaymentsCompanion.insert(
                erpPaymentId: erpPaymentId,
                customerId: customerId,
                planId: planId,
                date: date,
                amountPoisha: amountPoisha,
                method: method,
                source: source,
                receiptNo: receiptNo,
                reversed: reversed,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ErpPaymentsTable, ErpPaymentRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $ErpPaymentsTable,
                    ErpPaymentRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ErpPaymentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ErpPaymentsTable,
      ErpPaymentRow,
      $$ErpPaymentsTableFilterComposer,
      $$ErpPaymentsTableOrderingComposer,
      $$ErpPaymentsTableAnnotationComposer,
      $$ErpPaymentsTableCreateCompanionBuilder,
      $$ErpPaymentsTableUpdateCompanionBuilder,
      (
        ErpPaymentRow,
        BaseReferences<_$AppDatabase, $ErpPaymentsTable, ErpPaymentRow>,
      ),
      ErpPaymentRow,
      PrefetchHooks Function()
    >;
typedef $$LocationProposalsTableCreateCompanionBuilder =
    LocationProposalsCompanion Function({
      required String clientId,
      required String customerId,
      required double lat,
      required double lng,
      required double accuracyM,
      Value<String?> photoMediaClientId,
      Value<String?> note,
      Value<String> status,
      Value<String> syncState,
      Value<String?> decisionReason,
      Value<String> method,
      Value<String?> deviceGeoJson,
      Value<int> rowid,
    });
typedef $$LocationProposalsTableUpdateCompanionBuilder =
    LocationProposalsCompanion Function({
      Value<String> clientId,
      Value<String> customerId,
      Value<double> lat,
      Value<double> lng,
      Value<double> accuracyM,
      Value<String?> photoMediaClientId,
      Value<String?> note,
      Value<String> status,
      Value<String> syncState,
      Value<String?> decisionReason,
      Value<String> method,
      Value<String?> deviceGeoJson,
      Value<int> rowid,
    });

class $$LocationProposalsTableFilterComposer
    extends Composer<_$AppDatabase, $LocationProposalsTable> {
  $$LocationProposalsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get clientId => $composableBuilder(
    column: $table.clientId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lat => $composableBuilder(
    column: $table.lat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lng => $composableBuilder(
    column: $table.lng,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get accuracyM => $composableBuilder(
    column: $table.accuracyM,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get photoMediaClientId => $composableBuilder(
    column: $table.photoMediaClientId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get decisionReason => $composableBuilder(
    column: $table.decisionReason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get method => $composableBuilder(
    column: $table.method,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceGeoJson => $composableBuilder(
    column: $table.deviceGeoJson,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocationProposalsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocationProposalsTable> {
  $$LocationProposalsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get clientId => $composableBuilder(
    column: $table.clientId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lat => $composableBuilder(
    column: $table.lat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lng => $composableBuilder(
    column: $table.lng,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get accuracyM => $composableBuilder(
    column: $table.accuracyM,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get photoMediaClientId => $composableBuilder(
    column: $table.photoMediaClientId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get decisionReason => $composableBuilder(
    column: $table.decisionReason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get method => $composableBuilder(
    column: $table.method,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceGeoJson => $composableBuilder(
    column: $table.deviceGeoJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocationProposalsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocationProposalsTable> {
  $$LocationProposalsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get clientId =>
      $composableBuilder(column: $table.clientId, builder: (column) => column);

  GeneratedColumn<String> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => column,
  );

  GeneratedColumn<double> get lat =>
      $composableBuilder(column: $table.lat, builder: (column) => column);

  GeneratedColumn<double> get lng =>
      $composableBuilder(column: $table.lng, builder: (column) => column);

  GeneratedColumn<double> get accuracyM =>
      $composableBuilder(column: $table.accuracyM, builder: (column) => column);

  GeneratedColumn<String> get photoMediaClientId => $composableBuilder(
    column: $table.photoMediaClientId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);

  GeneratedColumn<String> get decisionReason => $composableBuilder(
    column: $table.decisionReason,
    builder: (column) => column,
  );

  GeneratedColumn<String> get method =>
      $composableBuilder(column: $table.method, builder: (column) => column);

  GeneratedColumn<String> get deviceGeoJson => $composableBuilder(
    column: $table.deviceGeoJson,
    builder: (column) => column,
  );
}

class $$LocationProposalsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocationProposalsTable,
          LocationProposalRow,
          $$LocationProposalsTableFilterComposer,
          $$LocationProposalsTableOrderingComposer,
          $$LocationProposalsTableAnnotationComposer,
          $$LocationProposalsTableCreateCompanionBuilder,
          $$LocationProposalsTableUpdateCompanionBuilder,
          (
            LocationProposalRow,
            BaseReferences<
              _$AppDatabase,
              $LocationProposalsTable,
              LocationProposalRow
            >,
          ),
          LocationProposalRow,
          PrefetchHooks Function()
        > {
  $$LocationProposalsTableTableManager(
    _$AppDatabase db,
    $LocationProposalsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocationProposalsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocationProposalsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocationProposalsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> clientId = const Value.absent(),
                Value<String> customerId = const Value.absent(),
                Value<double> lat = const Value.absent(),
                Value<double> lng = const Value.absent(),
                Value<double> accuracyM = const Value.absent(),
                Value<String?> photoMediaClientId = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> syncState = const Value.absent(),
                Value<String?> decisionReason = const Value.absent(),
                Value<String> method = const Value.absent(),
                Value<String?> deviceGeoJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocationProposalsCompanion(
                clientId: clientId,
                customerId: customerId,
                lat: lat,
                lng: lng,
                accuracyM: accuracyM,
                photoMediaClientId: photoMediaClientId,
                note: note,
                status: status,
                syncState: syncState,
                decisionReason: decisionReason,
                method: method,
                deviceGeoJson: deviceGeoJson,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String clientId,
                required String customerId,
                required double lat,
                required double lng,
                required double accuracyM,
                Value<String?> photoMediaClientId = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> syncState = const Value.absent(),
                Value<String?> decisionReason = const Value.absent(),
                Value<String> method = const Value.absent(),
                Value<String?> deviceGeoJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocationProposalsCompanion.insert(
                clientId: clientId,
                customerId: customerId,
                lat: lat,
                lng: lng,
                accuracyM: accuracyM,
                photoMediaClientId: photoMediaClientId,
                note: note,
                status: status,
                syncState: syncState,
                decisionReason: decisionReason,
                method: method,
                deviceGeoJson: deviceGeoJson,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LocationProposalsTable, LocationProposalRow>(
                    table,
                  ),
                  BaseReferences<
                    _$AppDatabase,
                    $LocationProposalsTable,
                    LocationProposalRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocationProposalsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocationProposalsTable,
      LocationProposalRow,
      $$LocationProposalsTableFilterComposer,
      $$LocationProposalsTableOrderingComposer,
      $$LocationProposalsTableAnnotationComposer,
      $$LocationProposalsTableCreateCompanionBuilder,
      $$LocationProposalsTableUpdateCompanionBuilder,
      (
        LocationProposalRow,
        BaseReferences<
          _$AppDatabase,
          $LocationProposalsTable,
          LocationProposalRow
        >,
      ),
      LocationProposalRow,
      PrefetchHooks Function()
    >;
typedef $$CollectionsTableCreateCompanionBuilder =
    CollectionsCompanion Function({
      required String clientId,
      Value<String?> serverId,
      required String customerId,
      required String customerName,
      required String customerCode,
      Value<String?> erpPlanId,
      required int amountPoisha,
      required String method,
      Value<String?> transactionRef,
      required String receiptNo,
      Value<String?> physicalReceiptNo,
      Value<String?> payerName,
      Value<String?> note,
      required DateTime recordedAt,
      required DateTime deviceTime,
      required String businessDate,
      Value<double?> lat,
      Value<double?> lng,
      Value<double?> accuracyM,
      Value<bool> mock,
      Value<String?> visitClientId,
      Value<String?> photoMediaClientId,
      Value<String> status,
      Value<String?> erpReceiptNo,
      Value<String?> conflictCode,
      Value<String?> conflictMessage,
      Value<String?> resolutionText,
      Value<String> flagsJson,
      Value<String> syncState,
      Value<int> rowid,
    });
typedef $$CollectionsTableUpdateCompanionBuilder =
    CollectionsCompanion Function({
      Value<String> clientId,
      Value<String?> serverId,
      Value<String> customerId,
      Value<String> customerName,
      Value<String> customerCode,
      Value<String?> erpPlanId,
      Value<int> amountPoisha,
      Value<String> method,
      Value<String?> transactionRef,
      Value<String> receiptNo,
      Value<String?> physicalReceiptNo,
      Value<String?> payerName,
      Value<String?> note,
      Value<DateTime> recordedAt,
      Value<DateTime> deviceTime,
      Value<String> businessDate,
      Value<double?> lat,
      Value<double?> lng,
      Value<double?> accuracyM,
      Value<bool> mock,
      Value<String?> visitClientId,
      Value<String?> photoMediaClientId,
      Value<String> status,
      Value<String?> erpReceiptNo,
      Value<String?> conflictCode,
      Value<String?> conflictMessage,
      Value<String?> resolutionText,
      Value<String> flagsJson,
      Value<String> syncState,
      Value<int> rowid,
    });

class $$CollectionsTableFilterComposer
    extends Composer<_$AppDatabase, $CollectionsTable> {
  $$CollectionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get clientId => $composableBuilder(
    column: $table.clientId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customerName => $composableBuilder(
    column: $table.customerName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customerCode => $composableBuilder(
    column: $table.customerCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get erpPlanId => $composableBuilder(
    column: $table.erpPlanId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountPoisha => $composableBuilder(
    column: $table.amountPoisha,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get method => $composableBuilder(
    column: $table.method,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get transactionRef => $composableBuilder(
    column: $table.transactionRef,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get receiptNo => $composableBuilder(
    column: $table.receiptNo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get physicalReceiptNo => $composableBuilder(
    column: $table.physicalReceiptNo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payerName => $composableBuilder(
    column: $table.payerName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deviceTime => $composableBuilder(
    column: $table.deviceTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get businessDate => $composableBuilder(
    column: $table.businessDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lat => $composableBuilder(
    column: $table.lat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lng => $composableBuilder(
    column: $table.lng,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get accuracyM => $composableBuilder(
    column: $table.accuracyM,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get mock => $composableBuilder(
    column: $table.mock,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get visitClientId => $composableBuilder(
    column: $table.visitClientId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get photoMediaClientId => $composableBuilder(
    column: $table.photoMediaClientId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get erpReceiptNo => $composableBuilder(
    column: $table.erpReceiptNo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get conflictCode => $composableBuilder(
    column: $table.conflictCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get conflictMessage => $composableBuilder(
    column: $table.conflictMessage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get resolutionText => $composableBuilder(
    column: $table.resolutionText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get flagsJson => $composableBuilder(
    column: $table.flagsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CollectionsTableOrderingComposer
    extends Composer<_$AppDatabase, $CollectionsTable> {
  $$CollectionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get clientId => $composableBuilder(
    column: $table.clientId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customerName => $composableBuilder(
    column: $table.customerName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customerCode => $composableBuilder(
    column: $table.customerCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get erpPlanId => $composableBuilder(
    column: $table.erpPlanId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountPoisha => $composableBuilder(
    column: $table.amountPoisha,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get method => $composableBuilder(
    column: $table.method,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get transactionRef => $composableBuilder(
    column: $table.transactionRef,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get receiptNo => $composableBuilder(
    column: $table.receiptNo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get physicalReceiptNo => $composableBuilder(
    column: $table.physicalReceiptNo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payerName => $composableBuilder(
    column: $table.payerName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deviceTime => $composableBuilder(
    column: $table.deviceTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get businessDate => $composableBuilder(
    column: $table.businessDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lat => $composableBuilder(
    column: $table.lat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lng => $composableBuilder(
    column: $table.lng,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get accuracyM => $composableBuilder(
    column: $table.accuracyM,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get mock => $composableBuilder(
    column: $table.mock,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get visitClientId => $composableBuilder(
    column: $table.visitClientId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get photoMediaClientId => $composableBuilder(
    column: $table.photoMediaClientId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get erpReceiptNo => $composableBuilder(
    column: $table.erpReceiptNo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get conflictCode => $composableBuilder(
    column: $table.conflictCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get conflictMessage => $composableBuilder(
    column: $table.conflictMessage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get resolutionText => $composableBuilder(
    column: $table.resolutionText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get flagsJson => $composableBuilder(
    column: $table.flagsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CollectionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CollectionsTable> {
  $$CollectionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get clientId =>
      $composableBuilder(column: $table.clientId, builder: (column) => column);

  GeneratedColumn<String> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<String> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get customerName => $composableBuilder(
    column: $table.customerName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get customerCode => $composableBuilder(
    column: $table.customerCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get erpPlanId =>
      $composableBuilder(column: $table.erpPlanId, builder: (column) => column);

  GeneratedColumn<int> get amountPoisha => $composableBuilder(
    column: $table.amountPoisha,
    builder: (column) => column,
  );

  GeneratedColumn<String> get method =>
      $composableBuilder(column: $table.method, builder: (column) => column);

  GeneratedColumn<String> get transactionRef => $composableBuilder(
    column: $table.transactionRef,
    builder: (column) => column,
  );

  GeneratedColumn<String> get receiptNo =>
      $composableBuilder(column: $table.receiptNo, builder: (column) => column);

  GeneratedColumn<String> get physicalReceiptNo => $composableBuilder(
    column: $table.physicalReceiptNo,
    builder: (column) => column,
  );

  GeneratedColumn<String> get payerName =>
      $composableBuilder(column: $table.payerName, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get deviceTime => $composableBuilder(
    column: $table.deviceTime,
    builder: (column) => column,
  );

  GeneratedColumn<String> get businessDate => $composableBuilder(
    column: $table.businessDate,
    builder: (column) => column,
  );

  GeneratedColumn<double> get lat =>
      $composableBuilder(column: $table.lat, builder: (column) => column);

  GeneratedColumn<double> get lng =>
      $composableBuilder(column: $table.lng, builder: (column) => column);

  GeneratedColumn<double> get accuracyM =>
      $composableBuilder(column: $table.accuracyM, builder: (column) => column);

  GeneratedColumn<bool> get mock =>
      $composableBuilder(column: $table.mock, builder: (column) => column);

  GeneratedColumn<String> get visitClientId => $composableBuilder(
    column: $table.visitClientId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get photoMediaClientId => $composableBuilder(
    column: $table.photoMediaClientId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get erpReceiptNo => $composableBuilder(
    column: $table.erpReceiptNo,
    builder: (column) => column,
  );

  GeneratedColumn<String> get conflictCode => $composableBuilder(
    column: $table.conflictCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get conflictMessage => $composableBuilder(
    column: $table.conflictMessage,
    builder: (column) => column,
  );

  GeneratedColumn<String> get resolutionText => $composableBuilder(
    column: $table.resolutionText,
    builder: (column) => column,
  );

  GeneratedColumn<String> get flagsJson =>
      $composableBuilder(column: $table.flagsJson, builder: (column) => column);

  GeneratedColumn<String> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);
}

class $$CollectionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CollectionsTable,
          CollectionRow,
          $$CollectionsTableFilterComposer,
          $$CollectionsTableOrderingComposer,
          $$CollectionsTableAnnotationComposer,
          $$CollectionsTableCreateCompanionBuilder,
          $$CollectionsTableUpdateCompanionBuilder,
          (
            CollectionRow,
            BaseReferences<_$AppDatabase, $CollectionsTable, CollectionRow>,
          ),
          CollectionRow,
          PrefetchHooks Function()
        > {
  $$CollectionsTableTableManager(_$AppDatabase db, $CollectionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CollectionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CollectionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CollectionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> clientId = const Value.absent(),
                Value<String?> serverId = const Value.absent(),
                Value<String> customerId = const Value.absent(),
                Value<String> customerName = const Value.absent(),
                Value<String> customerCode = const Value.absent(),
                Value<String?> erpPlanId = const Value.absent(),
                Value<int> amountPoisha = const Value.absent(),
                Value<String> method = const Value.absent(),
                Value<String?> transactionRef = const Value.absent(),
                Value<String> receiptNo = const Value.absent(),
                Value<String?> physicalReceiptNo = const Value.absent(),
                Value<String?> payerName = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<DateTime> recordedAt = const Value.absent(),
                Value<DateTime> deviceTime = const Value.absent(),
                Value<String> businessDate = const Value.absent(),
                Value<double?> lat = const Value.absent(),
                Value<double?> lng = const Value.absent(),
                Value<double?> accuracyM = const Value.absent(),
                Value<bool> mock = const Value.absent(),
                Value<String?> visitClientId = const Value.absent(),
                Value<String?> photoMediaClientId = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> erpReceiptNo = const Value.absent(),
                Value<String?> conflictCode = const Value.absent(),
                Value<String?> conflictMessage = const Value.absent(),
                Value<String?> resolutionText = const Value.absent(),
                Value<String> flagsJson = const Value.absent(),
                Value<String> syncState = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CollectionsCompanion(
                clientId: clientId,
                serverId: serverId,
                customerId: customerId,
                customerName: customerName,
                customerCode: customerCode,
                erpPlanId: erpPlanId,
                amountPoisha: amountPoisha,
                method: method,
                transactionRef: transactionRef,
                receiptNo: receiptNo,
                physicalReceiptNo: physicalReceiptNo,
                payerName: payerName,
                note: note,
                recordedAt: recordedAt,
                deviceTime: deviceTime,
                businessDate: businessDate,
                lat: lat,
                lng: lng,
                accuracyM: accuracyM,
                mock: mock,
                visitClientId: visitClientId,
                photoMediaClientId: photoMediaClientId,
                status: status,
                erpReceiptNo: erpReceiptNo,
                conflictCode: conflictCode,
                conflictMessage: conflictMessage,
                resolutionText: resolutionText,
                flagsJson: flagsJson,
                syncState: syncState,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String clientId,
                Value<String?> serverId = const Value.absent(),
                required String customerId,
                required String customerName,
                required String customerCode,
                Value<String?> erpPlanId = const Value.absent(),
                required int amountPoisha,
                required String method,
                Value<String?> transactionRef = const Value.absent(),
                required String receiptNo,
                Value<String?> physicalReceiptNo = const Value.absent(),
                Value<String?> payerName = const Value.absent(),
                Value<String?> note = const Value.absent(),
                required DateTime recordedAt,
                required DateTime deviceTime,
                required String businessDate,
                Value<double?> lat = const Value.absent(),
                Value<double?> lng = const Value.absent(),
                Value<double?> accuracyM = const Value.absent(),
                Value<bool> mock = const Value.absent(),
                Value<String?> visitClientId = const Value.absent(),
                Value<String?> photoMediaClientId = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> erpReceiptNo = const Value.absent(),
                Value<String?> conflictCode = const Value.absent(),
                Value<String?> conflictMessage = const Value.absent(),
                Value<String?> resolutionText = const Value.absent(),
                Value<String> flagsJson = const Value.absent(),
                Value<String> syncState = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CollectionsCompanion.insert(
                clientId: clientId,
                serverId: serverId,
                customerId: customerId,
                customerName: customerName,
                customerCode: customerCode,
                erpPlanId: erpPlanId,
                amountPoisha: amountPoisha,
                method: method,
                transactionRef: transactionRef,
                receiptNo: receiptNo,
                physicalReceiptNo: physicalReceiptNo,
                payerName: payerName,
                note: note,
                recordedAt: recordedAt,
                deviceTime: deviceTime,
                businessDate: businessDate,
                lat: lat,
                lng: lng,
                accuracyM: accuracyM,
                mock: mock,
                visitClientId: visitClientId,
                photoMediaClientId: photoMediaClientId,
                status: status,
                erpReceiptNo: erpReceiptNo,
                conflictCode: conflictCode,
                conflictMessage: conflictMessage,
                resolutionText: resolutionText,
                flagsJson: flagsJson,
                syncState: syncState,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CollectionsTable, CollectionRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $CollectionsTable,
                    CollectionRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CollectionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CollectionsTable,
      CollectionRow,
      $$CollectionsTableFilterComposer,
      $$CollectionsTableOrderingComposer,
      $$CollectionsTableAnnotationComposer,
      $$CollectionsTableCreateCompanionBuilder,
      $$CollectionsTableUpdateCompanionBuilder,
      (
        CollectionRow,
        BaseReferences<_$AppDatabase, $CollectionsTable, CollectionRow>,
      ),
      CollectionRow,
      PrefetchHooks Function()
    >;
typedef $$ReceiptBlocksTableCreateCompanionBuilder =
    ReceiptBlocksCompanion Function({
      Value<int> id,
      required String prefix,
      required String businessDate,
      required int fromSeq,
      required int toSeq,
      required int lastUsed,
      Value<bool> offline,
    });
typedef $$ReceiptBlocksTableUpdateCompanionBuilder =
    ReceiptBlocksCompanion Function({
      Value<int> id,
      Value<String> prefix,
      Value<String> businessDate,
      Value<int> fromSeq,
      Value<int> toSeq,
      Value<int> lastUsed,
      Value<bool> offline,
    });

class $$ReceiptBlocksTableFilterComposer
    extends Composer<_$AppDatabase, $ReceiptBlocksTable> {
  $$ReceiptBlocksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get prefix => $composableBuilder(
    column: $table.prefix,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get businessDate => $composableBuilder(
    column: $table.businessDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fromSeq => $composableBuilder(
    column: $table.fromSeq,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get toSeq => $composableBuilder(
    column: $table.toSeq,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastUsed => $composableBuilder(
    column: $table.lastUsed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get offline => $composableBuilder(
    column: $table.offline,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ReceiptBlocksTableOrderingComposer
    extends Composer<_$AppDatabase, $ReceiptBlocksTable> {
  $$ReceiptBlocksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get prefix => $composableBuilder(
    column: $table.prefix,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get businessDate => $composableBuilder(
    column: $table.businessDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fromSeq => $composableBuilder(
    column: $table.fromSeq,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get toSeq => $composableBuilder(
    column: $table.toSeq,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastUsed => $composableBuilder(
    column: $table.lastUsed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get offline => $composableBuilder(
    column: $table.offline,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ReceiptBlocksTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReceiptBlocksTable> {
  $$ReceiptBlocksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get prefix =>
      $composableBuilder(column: $table.prefix, builder: (column) => column);

  GeneratedColumn<String> get businessDate => $composableBuilder(
    column: $table.businessDate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get fromSeq =>
      $composableBuilder(column: $table.fromSeq, builder: (column) => column);

  GeneratedColumn<int> get toSeq =>
      $composableBuilder(column: $table.toSeq, builder: (column) => column);

  GeneratedColumn<int> get lastUsed =>
      $composableBuilder(column: $table.lastUsed, builder: (column) => column);

  GeneratedColumn<bool> get offline =>
      $composableBuilder(column: $table.offline, builder: (column) => column);
}

class $$ReceiptBlocksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReceiptBlocksTable,
          ReceiptBlockRow,
          $$ReceiptBlocksTableFilterComposer,
          $$ReceiptBlocksTableOrderingComposer,
          $$ReceiptBlocksTableAnnotationComposer,
          $$ReceiptBlocksTableCreateCompanionBuilder,
          $$ReceiptBlocksTableUpdateCompanionBuilder,
          (
            ReceiptBlockRow,
            BaseReferences<_$AppDatabase, $ReceiptBlocksTable, ReceiptBlockRow>,
          ),
          ReceiptBlockRow,
          PrefetchHooks Function()
        > {
  $$ReceiptBlocksTableTableManager(_$AppDatabase db, $ReceiptBlocksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReceiptBlocksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReceiptBlocksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReceiptBlocksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> prefix = const Value.absent(),
                Value<String> businessDate = const Value.absent(),
                Value<int> fromSeq = const Value.absent(),
                Value<int> toSeq = const Value.absent(),
                Value<int> lastUsed = const Value.absent(),
                Value<bool> offline = const Value.absent(),
              }) => ReceiptBlocksCompanion(
                id: id,
                prefix: prefix,
                businessDate: businessDate,
                fromSeq: fromSeq,
                toSeq: toSeq,
                lastUsed: lastUsed,
                offline: offline,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String prefix,
                required String businessDate,
                required int fromSeq,
                required int toSeq,
                required int lastUsed,
                Value<bool> offline = const Value.absent(),
              }) => ReceiptBlocksCompanion.insert(
                id: id,
                prefix: prefix,
                businessDate: businessDate,
                fromSeq: fromSeq,
                toSeq: toSeq,
                lastUsed: lastUsed,
                offline: offline,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ReceiptBlocksTable, ReceiptBlockRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $ReceiptBlocksTable,
                    ReceiptBlockRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ReceiptBlocksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReceiptBlocksTable,
      ReceiptBlockRow,
      $$ReceiptBlocksTableFilterComposer,
      $$ReceiptBlocksTableOrderingComposer,
      $$ReceiptBlocksTableAnnotationComposer,
      $$ReceiptBlocksTableCreateCompanionBuilder,
      $$ReceiptBlocksTableUpdateCompanionBuilder,
      (
        ReceiptBlockRow,
        BaseReferences<_$AppDatabase, $ReceiptBlocksTable, ReceiptBlockRow>,
      ),
      ReceiptBlockRow,
      PrefetchHooks Function()
    >;
typedef $$CashPositionsTableCreateCompanionBuilder =
    CashPositionsCompanion Function({
      Value<int> id,
      required int serverOnHandPoisha,
      required int limitPoisha,
      Value<int> pendingDepositsPoisha,
      required DateTime asOf,
    });
typedef $$CashPositionsTableUpdateCompanionBuilder =
    CashPositionsCompanion Function({
      Value<int> id,
      Value<int> serverOnHandPoisha,
      Value<int> limitPoisha,
      Value<int> pendingDepositsPoisha,
      Value<DateTime> asOf,
    });

class $$CashPositionsTableFilterComposer
    extends Composer<_$AppDatabase, $CashPositionsTable> {
  $$CashPositionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverOnHandPoisha => $composableBuilder(
    column: $table.serverOnHandPoisha,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get limitPoisha => $composableBuilder(
    column: $table.limitPoisha,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pendingDepositsPoisha => $composableBuilder(
    column: $table.pendingDepositsPoisha,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get asOf => $composableBuilder(
    column: $table.asOf,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CashPositionsTableOrderingComposer
    extends Composer<_$AppDatabase, $CashPositionsTable> {
  $$CashPositionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverOnHandPoisha => $composableBuilder(
    column: $table.serverOnHandPoisha,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get limitPoisha => $composableBuilder(
    column: $table.limitPoisha,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pendingDepositsPoisha => $composableBuilder(
    column: $table.pendingDepositsPoisha,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get asOf => $composableBuilder(
    column: $table.asOf,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CashPositionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CashPositionsTable> {
  $$CashPositionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get serverOnHandPoisha => $composableBuilder(
    column: $table.serverOnHandPoisha,
    builder: (column) => column,
  );

  GeneratedColumn<int> get limitPoisha => $composableBuilder(
    column: $table.limitPoisha,
    builder: (column) => column,
  );

  GeneratedColumn<int> get pendingDepositsPoisha => $composableBuilder(
    column: $table.pendingDepositsPoisha,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get asOf =>
      $composableBuilder(column: $table.asOf, builder: (column) => column);
}

class $$CashPositionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CashPositionsTable,
          CashPositionRow,
          $$CashPositionsTableFilterComposer,
          $$CashPositionsTableOrderingComposer,
          $$CashPositionsTableAnnotationComposer,
          $$CashPositionsTableCreateCompanionBuilder,
          $$CashPositionsTableUpdateCompanionBuilder,
          (
            CashPositionRow,
            BaseReferences<_$AppDatabase, $CashPositionsTable, CashPositionRow>,
          ),
          CashPositionRow,
          PrefetchHooks Function()
        > {
  $$CashPositionsTableTableManager(_$AppDatabase db, $CashPositionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CashPositionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CashPositionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CashPositionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> serverOnHandPoisha = const Value.absent(),
                Value<int> limitPoisha = const Value.absent(),
                Value<int> pendingDepositsPoisha = const Value.absent(),
                Value<DateTime> asOf = const Value.absent(),
              }) => CashPositionsCompanion(
                id: id,
                serverOnHandPoisha: serverOnHandPoisha,
                limitPoisha: limitPoisha,
                pendingDepositsPoisha: pendingDepositsPoisha,
                asOf: asOf,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int serverOnHandPoisha,
                required int limitPoisha,
                Value<int> pendingDepositsPoisha = const Value.absent(),
                required DateTime asOf,
              }) => CashPositionsCompanion.insert(
                id: id,
                serverOnHandPoisha: serverOnHandPoisha,
                limitPoisha: limitPoisha,
                pendingDepositsPoisha: pendingDepositsPoisha,
                asOf: asOf,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CashPositionsTable, CashPositionRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $CashPositionsTable,
                    CashPositionRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CashPositionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CashPositionsTable,
      CashPositionRow,
      $$CashPositionsTableFilterComposer,
      $$CashPositionsTableOrderingComposer,
      $$CashPositionsTableAnnotationComposer,
      $$CashPositionsTableCreateCompanionBuilder,
      $$CashPositionsTableUpdateCompanionBuilder,
      (
        CashPositionRow,
        BaseReferences<_$AppDatabase, $CashPositionsTable, CashPositionRow>,
      ),
      CashPositionRow,
      PrefetchHooks Function()
    >;
typedef $$DepositsTableCreateCompanionBuilder = DepositsCompanion Function({
  required String clientId,
  Value<String?> serverId,
  required int amountPoisha,
  required String destination,
  Value<String?> reference,
  Value<String?> slipMediaClientId,
  required DateTime depositedAt,
  Value<String> status,
  Value<String?> rejectReason,
  Value<String> syncState,
  Value<int> rowid,
});
typedef $$DepositsTableUpdateCompanionBuilder = DepositsCompanion Function({
  Value<String> clientId,
  Value<String?> serverId,
  Value<int> amountPoisha,
  Value<String> destination,
  Value<String?> reference,
  Value<String?> slipMediaClientId,
  Value<DateTime> depositedAt,
  Value<String> status,
  Value<String?> rejectReason,
  Value<String> syncState,
  Value<int> rowid,
});

class $$DepositsTableFilterComposer
    extends Composer<_$AppDatabase, $DepositsTable> {
  $$DepositsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get clientId => $composableBuilder(
    column: $table.clientId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountPoisha => $composableBuilder(
    column: $table.amountPoisha,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get destination => $composableBuilder(
    column: $table.destination,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reference => $composableBuilder(
    column: $table.reference,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get slipMediaClientId => $composableBuilder(
    column: $table.slipMediaClientId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get depositedAt => $composableBuilder(
    column: $table.depositedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rejectReason => $composableBuilder(
    column: $table.rejectReason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DepositsTableOrderingComposer
    extends Composer<_$AppDatabase, $DepositsTable> {
  $$DepositsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get clientId => $composableBuilder(
    column: $table.clientId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountPoisha => $composableBuilder(
    column: $table.amountPoisha,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get destination => $composableBuilder(
    column: $table.destination,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reference => $composableBuilder(
    column: $table.reference,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get slipMediaClientId => $composableBuilder(
    column: $table.slipMediaClientId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get depositedAt => $composableBuilder(
    column: $table.depositedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rejectReason => $composableBuilder(
    column: $table.rejectReason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DepositsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DepositsTable> {
  $$DepositsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get clientId =>
      $composableBuilder(column: $table.clientId, builder: (column) => column);

  GeneratedColumn<String> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<int> get amountPoisha => $composableBuilder(
    column: $table.amountPoisha,
    builder: (column) => column,
  );

  GeneratedColumn<String> get destination => $composableBuilder(
    column: $table.destination,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reference =>
      $composableBuilder(column: $table.reference, builder: (column) => column);

  GeneratedColumn<String> get slipMediaClientId => $composableBuilder(
    column: $table.slipMediaClientId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get depositedAt => $composableBuilder(
    column: $table.depositedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get rejectReason => $composableBuilder(
    column: $table.rejectReason,
    builder: (column) => column,
  );

  GeneratedColumn<String> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);
}

class $$DepositsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DepositsTable,
          DepositRow,
          $$DepositsTableFilterComposer,
          $$DepositsTableOrderingComposer,
          $$DepositsTableAnnotationComposer,
          $$DepositsTableCreateCompanionBuilder,
          $$DepositsTableUpdateCompanionBuilder,
          (
            DepositRow,
            BaseReferences<_$AppDatabase, $DepositsTable, DepositRow>,
          ),
          DepositRow,
          PrefetchHooks Function()
        > {
  $$DepositsTableTableManager(_$AppDatabase db, $DepositsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DepositsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DepositsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DepositsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> clientId = const Value.absent(),
                Value<String?> serverId = const Value.absent(),
                Value<int> amountPoisha = const Value.absent(),
                Value<String> destination = const Value.absent(),
                Value<String?> reference = const Value.absent(),
                Value<String?> slipMediaClientId = const Value.absent(),
                Value<DateTime> depositedAt = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> rejectReason = const Value.absent(),
                Value<String> syncState = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DepositsCompanion(
                clientId: clientId,
                serverId: serverId,
                amountPoisha: amountPoisha,
                destination: destination,
                reference: reference,
                slipMediaClientId: slipMediaClientId,
                depositedAt: depositedAt,
                status: status,
                rejectReason: rejectReason,
                syncState: syncState,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String clientId,
                Value<String?> serverId = const Value.absent(),
                required int amountPoisha,
                required String destination,
                Value<String?> reference = const Value.absent(),
                Value<String?> slipMediaClientId = const Value.absent(),
                required DateTime depositedAt,
                Value<String> status = const Value.absent(),
                Value<String?> rejectReason = const Value.absent(),
                Value<String> syncState = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DepositsCompanion.insert(
                clientId: clientId,
                serverId: serverId,
                amountPoisha: amountPoisha,
                destination: destination,
                reference: reference,
                slipMediaClientId: slipMediaClientId,
                depositedAt: depositedAt,
                status: status,
                rejectReason: rejectReason,
                syncState: syncState,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DepositsTable, DepositRow>(table),
                  BaseReferences<_$AppDatabase, $DepositsTable, DepositRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DepositsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DepositsTable,
      DepositRow,
      $$DepositsTableFilterComposer,
      $$DepositsTableOrderingComposer,
      $$DepositsTableAnnotationComposer,
      $$DepositsTableCreateCompanionBuilder,
      $$DepositsTableUpdateCompanionBuilder,
      (DepositRow, BaseReferences<_$AppDatabase, $DepositsTable, DepositRow>),
      DepositRow,
      PrefetchHooks Function()
    >;
typedef $$CashClosingsTableCreateCompanionBuilder =
    CashClosingsCompanion Function({
      required String businessDate,
      required int cashPoisha,
      required int mobilePoisha,
      required int depositedPoisha,
      required int onHandPoisha,
      required DateTime confirmedAt,
      Value<String> syncState,
      Value<int> rowid,
    });
typedef $$CashClosingsTableUpdateCompanionBuilder =
    CashClosingsCompanion Function({
      Value<String> businessDate,
      Value<int> cashPoisha,
      Value<int> mobilePoisha,
      Value<int> depositedPoisha,
      Value<int> onHandPoisha,
      Value<DateTime> confirmedAt,
      Value<String> syncState,
      Value<int> rowid,
    });

class $$CashClosingsTableFilterComposer
    extends Composer<_$AppDatabase, $CashClosingsTable> {
  $$CashClosingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get businessDate => $composableBuilder(
    column: $table.businessDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cashPoisha => $composableBuilder(
    column: $table.cashPoisha,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get mobilePoisha => $composableBuilder(
    column: $table.mobilePoisha,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get depositedPoisha => $composableBuilder(
    column: $table.depositedPoisha,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get onHandPoisha => $composableBuilder(
    column: $table.onHandPoisha,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get confirmedAt => $composableBuilder(
    column: $table.confirmedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CashClosingsTableOrderingComposer
    extends Composer<_$AppDatabase, $CashClosingsTable> {
  $$CashClosingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get businessDate => $composableBuilder(
    column: $table.businessDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cashPoisha => $composableBuilder(
    column: $table.cashPoisha,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get mobilePoisha => $composableBuilder(
    column: $table.mobilePoisha,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get depositedPoisha => $composableBuilder(
    column: $table.depositedPoisha,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get onHandPoisha => $composableBuilder(
    column: $table.onHandPoisha,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get confirmedAt => $composableBuilder(
    column: $table.confirmedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CashClosingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CashClosingsTable> {
  $$CashClosingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get businessDate => $composableBuilder(
    column: $table.businessDate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get cashPoisha => $composableBuilder(
    column: $table.cashPoisha,
    builder: (column) => column,
  );

  GeneratedColumn<int> get mobilePoisha => $composableBuilder(
    column: $table.mobilePoisha,
    builder: (column) => column,
  );

  GeneratedColumn<int> get depositedPoisha => $composableBuilder(
    column: $table.depositedPoisha,
    builder: (column) => column,
  );

  GeneratedColumn<int> get onHandPoisha => $composableBuilder(
    column: $table.onHandPoisha,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get confirmedAt => $composableBuilder(
    column: $table.confirmedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);
}

class $$CashClosingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CashClosingsTable,
          CashClosingRow,
          $$CashClosingsTableFilterComposer,
          $$CashClosingsTableOrderingComposer,
          $$CashClosingsTableAnnotationComposer,
          $$CashClosingsTableCreateCompanionBuilder,
          $$CashClosingsTableUpdateCompanionBuilder,
          (
            CashClosingRow,
            BaseReferences<_$AppDatabase, $CashClosingsTable, CashClosingRow>,
          ),
          CashClosingRow,
          PrefetchHooks Function()
        > {
  $$CashClosingsTableTableManager(_$AppDatabase db, $CashClosingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CashClosingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CashClosingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CashClosingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> businessDate = const Value.absent(),
                Value<int> cashPoisha = const Value.absent(),
                Value<int> mobilePoisha = const Value.absent(),
                Value<int> depositedPoisha = const Value.absent(),
                Value<int> onHandPoisha = const Value.absent(),
                Value<DateTime> confirmedAt = const Value.absent(),
                Value<String> syncState = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CashClosingsCompanion(
                businessDate: businessDate,
                cashPoisha: cashPoisha,
                mobilePoisha: mobilePoisha,
                depositedPoisha: depositedPoisha,
                onHandPoisha: onHandPoisha,
                confirmedAt: confirmedAt,
                syncState: syncState,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String businessDate,
                required int cashPoisha,
                required int mobilePoisha,
                required int depositedPoisha,
                required int onHandPoisha,
                required DateTime confirmedAt,
                Value<String> syncState = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CashClosingsCompanion.insert(
                businessDate: businessDate,
                cashPoisha: cashPoisha,
                mobilePoisha: mobilePoisha,
                depositedPoisha: depositedPoisha,
                onHandPoisha: onHandPoisha,
                confirmedAt: confirmedAt,
                syncState: syncState,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CashClosingsTable, CashClosingRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $CashClosingsTable,
                    CashClosingRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CashClosingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CashClosingsTable,
      CashClosingRow,
      $$CashClosingsTableFilterComposer,
      $$CashClosingsTableOrderingComposer,
      $$CashClosingsTableAnnotationComposer,
      $$CashClosingsTableCreateCompanionBuilder,
      $$CashClosingsTableUpdateCompanionBuilder,
      (
        CashClosingRow,
        BaseReferences<_$AppDatabase, $CashClosingsTable, CashClosingRow>,
      ),
      CashClosingRow,
      PrefetchHooks Function()
    >;
typedef $$VisitsTableCreateCompanionBuilder = VisitsCompanion Function({
  required String clientId,
  Value<String?> serverId,
  required String customerId,
  Value<String?> userName,
  required DateTime checkInAt,
  Value<DateTime?> checkOutAt,
  required String outcome,
  Value<double?> lat,
  Value<double?> lng,
  Value<double?> accuracyM,
  Value<bool> mock,
  Value<int?> distanceToPinM,
  Value<String> photoMediaClientIdsJson,
  Value<String?> note,
  Value<String> source,
  Value<String> syncState,
  Value<String?> userId,
  Value<String?> coWorkSessionId,
  Value<String?> coWorkParticipantIdsJson,
  Value<int> rowid,
});
typedef $$VisitsTableUpdateCompanionBuilder = VisitsCompanion Function({
  Value<String> clientId,
  Value<String?> serverId,
  Value<String> customerId,
  Value<String?> userName,
  Value<DateTime> checkInAt,
  Value<DateTime?> checkOutAt,
  Value<String> outcome,
  Value<double?> lat,
  Value<double?> lng,
  Value<double?> accuracyM,
  Value<bool> mock,
  Value<int?> distanceToPinM,
  Value<String> photoMediaClientIdsJson,
  Value<String?> note,
  Value<String> source,
  Value<String> syncState,
  Value<String?> userId,
  Value<String?> coWorkSessionId,
  Value<String?> coWorkParticipantIdsJson,
  Value<int> rowid,
});

class $$VisitsTableFilterComposer
    extends Composer<_$AppDatabase, $VisitsTable> {
  $$VisitsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get clientId => $composableBuilder(
    column: $table.clientId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userName => $composableBuilder(
    column: $table.userName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get checkInAt => $composableBuilder(
    column: $table.checkInAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get checkOutAt => $composableBuilder(
    column: $table.checkOutAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get outcome => $composableBuilder(
    column: $table.outcome,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lat => $composableBuilder(
    column: $table.lat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lng => $composableBuilder(
    column: $table.lng,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get accuracyM => $composableBuilder(
    column: $table.accuracyM,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get mock => $composableBuilder(
    column: $table.mock,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get distanceToPinM => $composableBuilder(
    column: $table.distanceToPinM,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get photoMediaClientIdsJson => $composableBuilder(
    column: $table.photoMediaClientIdsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coWorkSessionId => $composableBuilder(
    column: $table.coWorkSessionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coWorkParticipantIdsJson => $composableBuilder(
    column: $table.coWorkParticipantIdsJson,
    builder: (column) => ColumnFilters(column),
  );
}

class $$VisitsTableOrderingComposer
    extends Composer<_$AppDatabase, $VisitsTable> {
  $$VisitsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get clientId => $composableBuilder(
    column: $table.clientId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userName => $composableBuilder(
    column: $table.userName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get checkInAt => $composableBuilder(
    column: $table.checkInAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get checkOutAt => $composableBuilder(
    column: $table.checkOutAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get outcome => $composableBuilder(
    column: $table.outcome,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lat => $composableBuilder(
    column: $table.lat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lng => $composableBuilder(
    column: $table.lng,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get accuracyM => $composableBuilder(
    column: $table.accuracyM,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get mock => $composableBuilder(
    column: $table.mock,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get distanceToPinM => $composableBuilder(
    column: $table.distanceToPinM,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get photoMediaClientIdsJson => $composableBuilder(
    column: $table.photoMediaClientIdsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coWorkSessionId => $composableBuilder(
    column: $table.coWorkSessionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coWorkParticipantIdsJson => $composableBuilder(
    column: $table.coWorkParticipantIdsJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$VisitsTableAnnotationComposer
    extends Composer<_$AppDatabase, $VisitsTable> {
  $$VisitsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get clientId =>
      $composableBuilder(column: $table.clientId, builder: (column) => column);

  GeneratedColumn<String> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<String> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get userName =>
      $composableBuilder(column: $table.userName, builder: (column) => column);

  GeneratedColumn<DateTime> get checkInAt =>
      $composableBuilder(column: $table.checkInAt, builder: (column) => column);

  GeneratedColumn<DateTime> get checkOutAt => $composableBuilder(
    column: $table.checkOutAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get outcome =>
      $composableBuilder(column: $table.outcome, builder: (column) => column);

  GeneratedColumn<double> get lat =>
      $composableBuilder(column: $table.lat, builder: (column) => column);

  GeneratedColumn<double> get lng =>
      $composableBuilder(column: $table.lng, builder: (column) => column);

  GeneratedColumn<double> get accuracyM =>
      $composableBuilder(column: $table.accuracyM, builder: (column) => column);

  GeneratedColumn<bool> get mock =>
      $composableBuilder(column: $table.mock, builder: (column) => column);

  GeneratedColumn<int> get distanceToPinM => $composableBuilder(
    column: $table.distanceToPinM,
    builder: (column) => column,
  );

  GeneratedColumn<String> get photoMediaClientIdsJson => $composableBuilder(
    column: $table.photoMediaClientIdsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get coWorkSessionId => $composableBuilder(
    column: $table.coWorkSessionId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get coWorkParticipantIdsJson => $composableBuilder(
    column: $table.coWorkParticipantIdsJson,
    builder: (column) => column,
  );
}

class $$VisitsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VisitsTable,
          VisitRow,
          $$VisitsTableFilterComposer,
          $$VisitsTableOrderingComposer,
          $$VisitsTableAnnotationComposer,
          $$VisitsTableCreateCompanionBuilder,
          $$VisitsTableUpdateCompanionBuilder,
          (VisitRow, BaseReferences<_$AppDatabase, $VisitsTable, VisitRow>),
          VisitRow,
          PrefetchHooks Function()
        > {
  $$VisitsTableTableManager(_$AppDatabase db, $VisitsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VisitsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VisitsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VisitsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> clientId = const Value.absent(),
                Value<String?> serverId = const Value.absent(),
                Value<String> customerId = const Value.absent(),
                Value<String?> userName = const Value.absent(),
                Value<DateTime> checkInAt = const Value.absent(),
                Value<DateTime?> checkOutAt = const Value.absent(),
                Value<String> outcome = const Value.absent(),
                Value<double?> lat = const Value.absent(),
                Value<double?> lng = const Value.absent(),
                Value<double?> accuracyM = const Value.absent(),
                Value<bool> mock = const Value.absent(),
                Value<int?> distanceToPinM = const Value.absent(),
                Value<String> photoMediaClientIdsJson = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String> syncState = const Value.absent(),
                Value<String?> userId = const Value.absent(),
                Value<String?> coWorkSessionId = const Value.absent(),
                Value<String?> coWorkParticipantIdsJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VisitsCompanion(
                clientId: clientId,
                serverId: serverId,
                customerId: customerId,
                userName: userName,
                checkInAt: checkInAt,
                checkOutAt: checkOutAt,
                outcome: outcome,
                lat: lat,
                lng: lng,
                accuracyM: accuracyM,
                mock: mock,
                distanceToPinM: distanceToPinM,
                photoMediaClientIdsJson: photoMediaClientIdsJson,
                note: note,
                source: source,
                syncState: syncState,
                userId: userId,
                coWorkSessionId: coWorkSessionId,
                coWorkParticipantIdsJson: coWorkParticipantIdsJson,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String clientId,
                Value<String?> serverId = const Value.absent(),
                required String customerId,
                Value<String?> userName = const Value.absent(),
                required DateTime checkInAt,
                Value<DateTime?> checkOutAt = const Value.absent(),
                required String outcome,
                Value<double?> lat = const Value.absent(),
                Value<double?> lng = const Value.absent(),
                Value<double?> accuracyM = const Value.absent(),
                Value<bool> mock = const Value.absent(),
                Value<int?> distanceToPinM = const Value.absent(),
                Value<String> photoMediaClientIdsJson = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String> syncState = const Value.absent(),
                Value<String?> userId = const Value.absent(),
                Value<String?> coWorkSessionId = const Value.absent(),
                Value<String?> coWorkParticipantIdsJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VisitsCompanion.insert(
                clientId: clientId,
                serverId: serverId,
                customerId: customerId,
                userName: userName,
                checkInAt: checkInAt,
                checkOutAt: checkOutAt,
                outcome: outcome,
                lat: lat,
                lng: lng,
                accuracyM: accuracyM,
                mock: mock,
                distanceToPinM: distanceToPinM,
                photoMediaClientIdsJson: photoMediaClientIdsJson,
                note: note,
                source: source,
                syncState: syncState,
                userId: userId,
                coWorkSessionId: coWorkSessionId,
                coWorkParticipantIdsJson: coWorkParticipantIdsJson,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$VisitsTable, VisitRow>(table),
                  BaseReferences<_$AppDatabase, $VisitsTable, VisitRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$VisitsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VisitsTable,
      VisitRow,
      $$VisitsTableFilterComposer,
      $$VisitsTableOrderingComposer,
      $$VisitsTableAnnotationComposer,
      $$VisitsTableCreateCompanionBuilder,
      $$VisitsTableUpdateCompanionBuilder,
      (VisitRow, BaseReferences<_$AppDatabase, $VisitsTable, VisitRow>),
      VisitRow,
      PrefetchHooks Function()
    >;
typedef $$NotesTableCreateCompanionBuilder = NotesCompanion Function({
  required String clientId,
  Value<String?> serverId,
  required String customerId,
  Value<String?> authorId,
  Value<String?> authorName,
  Value<String> category,
  required String body,
  Value<String?> voiceMediaClientId,
  required DateTime createdAt,
  Value<DateTime?> editableUntil,
  Value<String> syncState,
  Value<int> rowid,
});
typedef $$NotesTableUpdateCompanionBuilder = NotesCompanion Function({
  Value<String> clientId,
  Value<String?> serverId,
  Value<String> customerId,
  Value<String?> authorId,
  Value<String?> authorName,
  Value<String> category,
  Value<String> body,
  Value<String?> voiceMediaClientId,
  Value<DateTime> createdAt,
  Value<DateTime?> editableUntil,
  Value<String> syncState,
  Value<int> rowid,
});

class $$NotesTableFilterComposer extends Composer<_$AppDatabase, $NotesTable> {
  $$NotesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get clientId => $composableBuilder(
    column: $table.clientId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get authorId => $composableBuilder(
    column: $table.authorId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get authorName => $composableBuilder(
    column: $table.authorName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get voiceMediaClientId => $composableBuilder(
    column: $table.voiceMediaClientId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get editableUntil => $composableBuilder(
    column: $table.editableUntil,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnFilters(column),
  );
}

class $$NotesTableOrderingComposer
    extends Composer<_$AppDatabase, $NotesTable> {
  $$NotesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get clientId => $composableBuilder(
    column: $table.clientId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get authorId => $composableBuilder(
    column: $table.authorId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get authorName => $composableBuilder(
    column: $table.authorName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get voiceMediaClientId => $composableBuilder(
    column: $table.voiceMediaClientId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get editableUntil => $composableBuilder(
    column: $table.editableUntil,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$NotesTableAnnotationComposer
    extends Composer<_$AppDatabase, $NotesTable> {
  $$NotesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get clientId =>
      $composableBuilder(column: $table.clientId, builder: (column) => column);

  GeneratedColumn<String> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<String> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get authorId =>
      $composableBuilder(column: $table.authorId, builder: (column) => column);

  GeneratedColumn<String> get authorName => $composableBuilder(
    column: $table.authorName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<String> get voiceMediaClientId => $composableBuilder(
    column: $table.voiceMediaClientId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get editableUntil => $composableBuilder(
    column: $table.editableUntil,
    builder: (column) => column,
  );

  GeneratedColumn<String> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);
}

class $$NotesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NotesTable,
          NoteRow,
          $$NotesTableFilterComposer,
          $$NotesTableOrderingComposer,
          $$NotesTableAnnotationComposer,
          $$NotesTableCreateCompanionBuilder,
          $$NotesTableUpdateCompanionBuilder,
          (NoteRow, BaseReferences<_$AppDatabase, $NotesTable, NoteRow>),
          NoteRow,
          PrefetchHooks Function()
        > {
  $$NotesTableTableManager(_$AppDatabase db, $NotesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NotesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NotesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NotesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> clientId = const Value.absent(),
                Value<String?> serverId = const Value.absent(),
                Value<String> customerId = const Value.absent(),
                Value<String?> authorId = const Value.absent(),
                Value<String?> authorName = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<String?> voiceMediaClientId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> editableUntil = const Value.absent(),
                Value<String> syncState = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NotesCompanion(
                clientId: clientId,
                serverId: serverId,
                customerId: customerId,
                authorId: authorId,
                authorName: authorName,
                category: category,
                body: body,
                voiceMediaClientId: voiceMediaClientId,
                createdAt: createdAt,
                editableUntil: editableUntil,
                syncState: syncState,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String clientId,
                Value<String?> serverId = const Value.absent(),
                required String customerId,
                Value<String?> authorId = const Value.absent(),
                Value<String?> authorName = const Value.absent(),
                Value<String> category = const Value.absent(),
                required String body,
                Value<String?> voiceMediaClientId = const Value.absent(),
                required DateTime createdAt,
                Value<DateTime?> editableUntil = const Value.absent(),
                Value<String> syncState = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NotesCompanion.insert(
                clientId: clientId,
                serverId: serverId,
                customerId: customerId,
                authorId: authorId,
                authorName: authorName,
                category: category,
                body: body,
                voiceMediaClientId: voiceMediaClientId,
                createdAt: createdAt,
                editableUntil: editableUntil,
                syncState: syncState,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$NotesTable, NoteRow>(table),
                  BaseReferences<_$AppDatabase, $NotesTable, NoteRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$NotesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NotesTable,
      NoteRow,
      $$NotesTableFilterComposer,
      $$NotesTableOrderingComposer,
      $$NotesTableAnnotationComposer,
      $$NotesTableCreateCompanionBuilder,
      $$NotesTableUpdateCompanionBuilder,
      (NoteRow, BaseReferences<_$AppDatabase, $NotesTable, NoteRow>),
      NoteRow,
      PrefetchHooks Function()
    >;
typedef $$PromisesTableCreateCompanionBuilder = PromisesCompanion Function({
  required String clientId,
  Value<String?> serverId,
  required String customerId,
  Value<String?> erpPlanId,
  required String promisedDate,
  required int promisedAmountPoisha,
  Value<int> paidTowardsPoisha,
  Value<String> status,
  Value<String?> note,
  required DateTime createdAt,
  Value<String> syncState,
  Value<bool> reminderScheduled,
  Value<int> rowid,
});
typedef $$PromisesTableUpdateCompanionBuilder = PromisesCompanion Function({
  Value<String> clientId,
  Value<String?> serverId,
  Value<String> customerId,
  Value<String?> erpPlanId,
  Value<String> promisedDate,
  Value<int> promisedAmountPoisha,
  Value<int> paidTowardsPoisha,
  Value<String> status,
  Value<String?> note,
  Value<DateTime> createdAt,
  Value<String> syncState,
  Value<bool> reminderScheduled,
  Value<int> rowid,
});

class $$PromisesTableFilterComposer
    extends Composer<_$AppDatabase, $PromisesTable> {
  $$PromisesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get clientId => $composableBuilder(
    column: $table.clientId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get erpPlanId => $composableBuilder(
    column: $table.erpPlanId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get promisedDate => $composableBuilder(
    column: $table.promisedDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get promisedAmountPoisha => $composableBuilder(
    column: $table.promisedAmountPoisha,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get paidTowardsPoisha => $composableBuilder(
    column: $table.paidTowardsPoisha,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get reminderScheduled => $composableBuilder(
    column: $table.reminderScheduled,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PromisesTableOrderingComposer
    extends Composer<_$AppDatabase, $PromisesTable> {
  $$PromisesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get clientId => $composableBuilder(
    column: $table.clientId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get erpPlanId => $composableBuilder(
    column: $table.erpPlanId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get promisedDate => $composableBuilder(
    column: $table.promisedDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get promisedAmountPoisha => $composableBuilder(
    column: $table.promisedAmountPoisha,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get paidTowardsPoisha => $composableBuilder(
    column: $table.paidTowardsPoisha,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get reminderScheduled => $composableBuilder(
    column: $table.reminderScheduled,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PromisesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PromisesTable> {
  $$PromisesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get clientId =>
      $composableBuilder(column: $table.clientId, builder: (column) => column);

  GeneratedColumn<String> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<String> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get erpPlanId =>
      $composableBuilder(column: $table.erpPlanId, builder: (column) => column);

  GeneratedColumn<String> get promisedDate => $composableBuilder(
    column: $table.promisedDate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get promisedAmountPoisha => $composableBuilder(
    column: $table.promisedAmountPoisha,
    builder: (column) => column,
  );

  GeneratedColumn<int> get paidTowardsPoisha => $composableBuilder(
    column: $table.paidTowardsPoisha,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);

  GeneratedColumn<bool> get reminderScheduled => $composableBuilder(
    column: $table.reminderScheduled,
    builder: (column) => column,
  );
}

class $$PromisesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PromisesTable,
          PromiseRow,
          $$PromisesTableFilterComposer,
          $$PromisesTableOrderingComposer,
          $$PromisesTableAnnotationComposer,
          $$PromisesTableCreateCompanionBuilder,
          $$PromisesTableUpdateCompanionBuilder,
          (
            PromiseRow,
            BaseReferences<_$AppDatabase, $PromisesTable, PromiseRow>,
          ),
          PromiseRow,
          PrefetchHooks Function()
        > {
  $$PromisesTableTableManager(_$AppDatabase db, $PromisesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PromisesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PromisesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PromisesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> clientId = const Value.absent(),
                Value<String?> serverId = const Value.absent(),
                Value<String> customerId = const Value.absent(),
                Value<String?> erpPlanId = const Value.absent(),
                Value<String> promisedDate = const Value.absent(),
                Value<int> promisedAmountPoisha = const Value.absent(),
                Value<int> paidTowardsPoisha = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String> syncState = const Value.absent(),
                Value<bool> reminderScheduled = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PromisesCompanion(
                clientId: clientId,
                serverId: serverId,
                customerId: customerId,
                erpPlanId: erpPlanId,
                promisedDate: promisedDate,
                promisedAmountPoisha: promisedAmountPoisha,
                paidTowardsPoisha: paidTowardsPoisha,
                status: status,
                note: note,
                createdAt: createdAt,
                syncState: syncState,
                reminderScheduled: reminderScheduled,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String clientId,
                Value<String?> serverId = const Value.absent(),
                required String customerId,
                Value<String?> erpPlanId = const Value.absent(),
                required String promisedDate,
                required int promisedAmountPoisha,
                Value<int> paidTowardsPoisha = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> note = const Value.absent(),
                required DateTime createdAt,
                Value<String> syncState = const Value.absent(),
                Value<bool> reminderScheduled = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PromisesCompanion.insert(
                clientId: clientId,
                serverId: serverId,
                customerId: customerId,
                erpPlanId: erpPlanId,
                promisedDate: promisedDate,
                promisedAmountPoisha: promisedAmountPoisha,
                paidTowardsPoisha: paidTowardsPoisha,
                status: status,
                note: note,
                createdAt: createdAt,
                syncState: syncState,
                reminderScheduled: reminderScheduled,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PromisesTable, PromiseRow>(table),
                  BaseReferences<_$AppDatabase, $PromisesTable, PromiseRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PromisesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PromisesTable,
      PromiseRow,
      $$PromisesTableFilterComposer,
      $$PromisesTableOrderingComposer,
      $$PromisesTableAnnotationComposer,
      $$PromisesTableCreateCompanionBuilder,
      $$PromisesTableUpdateCompanionBuilder,
      (PromiseRow, BaseReferences<_$AppDatabase, $PromisesTable, PromiseRow>),
      PromiseRow,
      PrefetchHooks Function()
    >;
typedef $$TagEventsTableCreateCompanionBuilder = TagEventsCompanion Function({
  required String clientId,
  required String customerId,
  required String previousJson,
  required String nextJson,
  required String reasonCode,
  required String reason,
  required DateTime at,
  Value<String> syncState,
  Value<int> rowid,
});
typedef $$TagEventsTableUpdateCompanionBuilder = TagEventsCompanion Function({
  Value<String> clientId,
  Value<String> customerId,
  Value<String> previousJson,
  Value<String> nextJson,
  Value<String> reasonCode,
  Value<String> reason,
  Value<DateTime> at,
  Value<String> syncState,
  Value<int> rowid,
});

class $$TagEventsTableFilterComposer
    extends Composer<_$AppDatabase, $TagEventsTable> {
  $$TagEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get clientId => $composableBuilder(
    column: $table.clientId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get previousJson => $composableBuilder(
    column: $table.previousJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nextJson => $composableBuilder(
    column: $table.nextJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reasonCode => $composableBuilder(
    column: $table.reasonCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TagEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $TagEventsTable> {
  $$TagEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get clientId => $composableBuilder(
    column: $table.clientId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get previousJson => $composableBuilder(
    column: $table.previousJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nextJson => $composableBuilder(
    column: $table.nextJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reasonCode => $composableBuilder(
    column: $table.reasonCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TagEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TagEventsTable> {
  $$TagEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get clientId =>
      $composableBuilder(column: $table.clientId, builder: (column) => column);

  GeneratedColumn<String> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get previousJson => $composableBuilder(
    column: $table.previousJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get nextJson =>
      $composableBuilder(column: $table.nextJson, builder: (column) => column);

  GeneratedColumn<String> get reasonCode => $composableBuilder(
    column: $table.reasonCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumn<DateTime> get at =>
      $composableBuilder(column: $table.at, builder: (column) => column);

  GeneratedColumn<String> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);
}

class $$TagEventsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TagEventsTable,
          TagEventRow,
          $$TagEventsTableFilterComposer,
          $$TagEventsTableOrderingComposer,
          $$TagEventsTableAnnotationComposer,
          $$TagEventsTableCreateCompanionBuilder,
          $$TagEventsTableUpdateCompanionBuilder,
          (
            TagEventRow,
            BaseReferences<_$AppDatabase, $TagEventsTable, TagEventRow>,
          ),
          TagEventRow,
          PrefetchHooks Function()
        > {
  $$TagEventsTableTableManager(_$AppDatabase db, $TagEventsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TagEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TagEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TagEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> clientId = const Value.absent(),
                Value<String> customerId = const Value.absent(),
                Value<String> previousJson = const Value.absent(),
                Value<String> nextJson = const Value.absent(),
                Value<String> reasonCode = const Value.absent(),
                Value<String> reason = const Value.absent(),
                Value<DateTime> at = const Value.absent(),
                Value<String> syncState = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TagEventsCompanion(
                clientId: clientId,
                customerId: customerId,
                previousJson: previousJson,
                nextJson: nextJson,
                reasonCode: reasonCode,
                reason: reason,
                at: at,
                syncState: syncState,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String clientId,
                required String customerId,
                required String previousJson,
                required String nextJson,
                required String reasonCode,
                required String reason,
                required DateTime at,
                Value<String> syncState = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TagEventsCompanion.insert(
                clientId: clientId,
                customerId: customerId,
                previousJson: previousJson,
                nextJson: nextJson,
                reasonCode: reasonCode,
                reason: reason,
                at: at,
                syncState: syncState,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TagEventsTable, TagEventRow>(table),
                  BaseReferences<_$AppDatabase, $TagEventsTable, TagEventRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TagEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TagEventsTable,
      TagEventRow,
      $$TagEventsTableFilterComposer,
      $$TagEventsTableOrderingComposer,
      $$TagEventsTableAnnotationComposer,
      $$TagEventsTableCreateCompanionBuilder,
      $$TagEventsTableUpdateCompanionBuilder,
      (
        TagEventRow,
        BaseReferences<_$AppDatabase, $TagEventsTable, TagEventRow>,
      ),
      TagEventRow,
      PrefetchHooks Function()
    >;
typedef $$AttendanceEventsTableCreateCompanionBuilder =
    AttendanceEventsCompanion Function({
      required String clientId,
      required String type,
      required DateTime at,
      required DateTime deviceTime,
      required String businessDate,
      Value<double?> lat,
      Value<double?> lng,
      Value<double?> accuracyM,
      Value<bool> mock,
      Value<String?> selfieMediaClientId,
      Value<String> syncState,
      Value<int> rowid,
    });
typedef $$AttendanceEventsTableUpdateCompanionBuilder =
    AttendanceEventsCompanion Function({
      Value<String> clientId,
      Value<String> type,
      Value<DateTime> at,
      Value<DateTime> deviceTime,
      Value<String> businessDate,
      Value<double?> lat,
      Value<double?> lng,
      Value<double?> accuracyM,
      Value<bool> mock,
      Value<String?> selfieMediaClientId,
      Value<String> syncState,
      Value<int> rowid,
    });

class $$AttendanceEventsTableFilterComposer
    extends Composer<_$AppDatabase, $AttendanceEventsTable> {
  $$AttendanceEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get clientId => $composableBuilder(
    column: $table.clientId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deviceTime => $composableBuilder(
    column: $table.deviceTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get businessDate => $composableBuilder(
    column: $table.businessDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lat => $composableBuilder(
    column: $table.lat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lng => $composableBuilder(
    column: $table.lng,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get accuracyM => $composableBuilder(
    column: $table.accuracyM,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get mock => $composableBuilder(
    column: $table.mock,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get selfieMediaClientId => $composableBuilder(
    column: $table.selfieMediaClientId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AttendanceEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $AttendanceEventsTable> {
  $$AttendanceEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get clientId => $composableBuilder(
    column: $table.clientId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deviceTime => $composableBuilder(
    column: $table.deviceTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get businessDate => $composableBuilder(
    column: $table.businessDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lat => $composableBuilder(
    column: $table.lat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lng => $composableBuilder(
    column: $table.lng,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get accuracyM => $composableBuilder(
    column: $table.accuracyM,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get mock => $composableBuilder(
    column: $table.mock,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get selfieMediaClientId => $composableBuilder(
    column: $table.selfieMediaClientId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AttendanceEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AttendanceEventsTable> {
  $$AttendanceEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get clientId =>
      $composableBuilder(column: $table.clientId, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<DateTime> get at =>
      $composableBuilder(column: $table.at, builder: (column) => column);

  GeneratedColumn<DateTime> get deviceTime => $composableBuilder(
    column: $table.deviceTime,
    builder: (column) => column,
  );

  GeneratedColumn<String> get businessDate => $composableBuilder(
    column: $table.businessDate,
    builder: (column) => column,
  );

  GeneratedColumn<double> get lat =>
      $composableBuilder(column: $table.lat, builder: (column) => column);

  GeneratedColumn<double> get lng =>
      $composableBuilder(column: $table.lng, builder: (column) => column);

  GeneratedColumn<double> get accuracyM =>
      $composableBuilder(column: $table.accuracyM, builder: (column) => column);

  GeneratedColumn<bool> get mock =>
      $composableBuilder(column: $table.mock, builder: (column) => column);

  GeneratedColumn<String> get selfieMediaClientId => $composableBuilder(
    column: $table.selfieMediaClientId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);
}

class $$AttendanceEventsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AttendanceEventsTable,
          AttendanceEventRow,
          $$AttendanceEventsTableFilterComposer,
          $$AttendanceEventsTableOrderingComposer,
          $$AttendanceEventsTableAnnotationComposer,
          $$AttendanceEventsTableCreateCompanionBuilder,
          $$AttendanceEventsTableUpdateCompanionBuilder,
          (
            AttendanceEventRow,
            BaseReferences<
              _$AppDatabase,
              $AttendanceEventsTable,
              AttendanceEventRow
            >,
          ),
          AttendanceEventRow,
          PrefetchHooks Function()
        > {
  $$AttendanceEventsTableTableManager(
    _$AppDatabase db,
    $AttendanceEventsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AttendanceEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AttendanceEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AttendanceEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> clientId = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<DateTime> at = const Value.absent(),
                Value<DateTime> deviceTime = const Value.absent(),
                Value<String> businessDate = const Value.absent(),
                Value<double?> lat = const Value.absent(),
                Value<double?> lng = const Value.absent(),
                Value<double?> accuracyM = const Value.absent(),
                Value<bool> mock = const Value.absent(),
                Value<String?> selfieMediaClientId = const Value.absent(),
                Value<String> syncState = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AttendanceEventsCompanion(
                clientId: clientId,
                type: type,
                at: at,
                deviceTime: deviceTime,
                businessDate: businessDate,
                lat: lat,
                lng: lng,
                accuracyM: accuracyM,
                mock: mock,
                selfieMediaClientId: selfieMediaClientId,
                syncState: syncState,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String clientId,
                required String type,
                required DateTime at,
                required DateTime deviceTime,
                required String businessDate,
                Value<double?> lat = const Value.absent(),
                Value<double?> lng = const Value.absent(),
                Value<double?> accuracyM = const Value.absent(),
                Value<bool> mock = const Value.absent(),
                Value<String?> selfieMediaClientId = const Value.absent(),
                Value<String> syncState = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AttendanceEventsCompanion.insert(
                clientId: clientId,
                type: type,
                at: at,
                deviceTime: deviceTime,
                businessDate: businessDate,
                lat: lat,
                lng: lng,
                accuracyM: accuracyM,
                mock: mock,
                selfieMediaClientId: selfieMediaClientId,
                syncState: syncState,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AttendanceEventsTable, AttendanceEventRow>(
                    table,
                  ),
                  BaseReferences<
                    _$AppDatabase,
                    $AttendanceEventsTable,
                    AttendanceEventRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AttendanceEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AttendanceEventsTable,
      AttendanceEventRow,
      $$AttendanceEventsTableFilterComposer,
      $$AttendanceEventsTableOrderingComposer,
      $$AttendanceEventsTableAnnotationComposer,
      $$AttendanceEventsTableCreateCompanionBuilder,
      $$AttendanceEventsTableUpdateCompanionBuilder,
      (
        AttendanceEventRow,
        BaseReferences<
          _$AppDatabase,
          $AttendanceEventsTable,
          AttendanceEventRow
        >,
      ),
      AttendanceEventRow,
      PrefetchHooks Function()
    >;
typedef $$AttendanceDaysTableCreateCompanionBuilder =
    AttendanceDaysCompanion Function({
      required String businessDate,
      required String status,
      Value<DateTime?> firstIn,
      Value<DateTime?> lastOut,
      Value<int> breakMin,
      Value<int> lateMin,
      Value<String> breaksJson,
      Value<int> rowid,
    });
typedef $$AttendanceDaysTableUpdateCompanionBuilder =
    AttendanceDaysCompanion Function({
      Value<String> businessDate,
      Value<String> status,
      Value<DateTime?> firstIn,
      Value<DateTime?> lastOut,
      Value<int> breakMin,
      Value<int> lateMin,
      Value<String> breaksJson,
      Value<int> rowid,
    });

class $$AttendanceDaysTableFilterComposer
    extends Composer<_$AppDatabase, $AttendanceDaysTable> {
  $$AttendanceDaysTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get businessDate => $composableBuilder(
    column: $table.businessDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get firstIn => $composableBuilder(
    column: $table.firstIn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastOut => $composableBuilder(
    column: $table.lastOut,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get breakMin => $composableBuilder(
    column: $table.breakMin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lateMin => $composableBuilder(
    column: $table.lateMin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get breaksJson => $composableBuilder(
    column: $table.breaksJson,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AttendanceDaysTableOrderingComposer
    extends Composer<_$AppDatabase, $AttendanceDaysTable> {
  $$AttendanceDaysTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get businessDate => $composableBuilder(
    column: $table.businessDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get firstIn => $composableBuilder(
    column: $table.firstIn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastOut => $composableBuilder(
    column: $table.lastOut,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get breakMin => $composableBuilder(
    column: $table.breakMin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lateMin => $composableBuilder(
    column: $table.lateMin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get breaksJson => $composableBuilder(
    column: $table.breaksJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AttendanceDaysTableAnnotationComposer
    extends Composer<_$AppDatabase, $AttendanceDaysTable> {
  $$AttendanceDaysTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get businessDate => $composableBuilder(
    column: $table.businessDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get firstIn =>
      $composableBuilder(column: $table.firstIn, builder: (column) => column);

  GeneratedColumn<DateTime> get lastOut =>
      $composableBuilder(column: $table.lastOut, builder: (column) => column);

  GeneratedColumn<int> get breakMin =>
      $composableBuilder(column: $table.breakMin, builder: (column) => column);

  GeneratedColumn<int> get lateMin =>
      $composableBuilder(column: $table.lateMin, builder: (column) => column);

  GeneratedColumn<String> get breaksJson => $composableBuilder(
    column: $table.breaksJson,
    builder: (column) => column,
  );
}

class $$AttendanceDaysTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AttendanceDaysTable,
          AttendanceDayRow,
          $$AttendanceDaysTableFilterComposer,
          $$AttendanceDaysTableOrderingComposer,
          $$AttendanceDaysTableAnnotationComposer,
          $$AttendanceDaysTableCreateCompanionBuilder,
          $$AttendanceDaysTableUpdateCompanionBuilder,
          (
            AttendanceDayRow,
            BaseReferences<
              _$AppDatabase,
              $AttendanceDaysTable,
              AttendanceDayRow
            >,
          ),
          AttendanceDayRow,
          PrefetchHooks Function()
        > {
  $$AttendanceDaysTableTableManager(
    _$AppDatabase db,
    $AttendanceDaysTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AttendanceDaysTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AttendanceDaysTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AttendanceDaysTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> businessDate = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime?> firstIn = const Value.absent(),
                Value<DateTime?> lastOut = const Value.absent(),
                Value<int> breakMin = const Value.absent(),
                Value<int> lateMin = const Value.absent(),
                Value<String> breaksJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AttendanceDaysCompanion(
                businessDate: businessDate,
                status: status,
                firstIn: firstIn,
                lastOut: lastOut,
                breakMin: breakMin,
                lateMin: lateMin,
                breaksJson: breaksJson,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String businessDate,
                required String status,
                Value<DateTime?> firstIn = const Value.absent(),
                Value<DateTime?> lastOut = const Value.absent(),
                Value<int> breakMin = const Value.absent(),
                Value<int> lateMin = const Value.absent(),
                Value<String> breaksJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AttendanceDaysCompanion.insert(
                businessDate: businessDate,
                status: status,
                firstIn: firstIn,
                lastOut: lastOut,
                breakMin: breakMin,
                lateMin: lateMin,
                breaksJson: breaksJson,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AttendanceDaysTable, AttendanceDayRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $AttendanceDaysTable,
                    AttendanceDayRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AttendanceDaysTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AttendanceDaysTable,
      AttendanceDayRow,
      $$AttendanceDaysTableFilterComposer,
      $$AttendanceDaysTableOrderingComposer,
      $$AttendanceDaysTableAnnotationComposer,
      $$AttendanceDaysTableCreateCompanionBuilder,
      $$AttendanceDaysTableUpdateCompanionBuilder,
      (
        AttendanceDayRow,
        BaseReferences<_$AppDatabase, $AttendanceDaysTable, AttendanceDayRow>,
      ),
      AttendanceDayRow,
      PrefetchHooks Function()
    >;
typedef $$HandoversTableCreateCompanionBuilder = HandoversCompanion Function({
  required String serverId,
  required String fromUserName,
  required String toUserId,
  required String summaryJson,
  Value<String?> reason,
  required String status,
  Value<DateTime?> expiresAt,
  required String role,
  Value<int> rowid,
});
typedef $$HandoversTableUpdateCompanionBuilder = HandoversCompanion Function({
  Value<String> serverId,
  Value<String> fromUserName,
  Value<String> toUserId,
  Value<String> summaryJson,
  Value<String?> reason,
  Value<String> status,
  Value<DateTime?> expiresAt,
  Value<String> role,
  Value<int> rowid,
});

class $$HandoversTableFilterComposer
    extends Composer<_$AppDatabase, $HandoversTable> {
  $$HandoversTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fromUserName => $composableBuilder(
    column: $table.fromUserName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get toUserId => $composableBuilder(
    column: $table.toUserId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get summaryJson => $composableBuilder(
    column: $table.summaryJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get expiresAt => $composableBuilder(
    column: $table.expiresAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );
}

class $$HandoversTableOrderingComposer
    extends Composer<_$AppDatabase, $HandoversTable> {
  $$HandoversTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fromUserName => $composableBuilder(
    column: $table.fromUserName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get toUserId => $composableBuilder(
    column: $table.toUserId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get summaryJson => $composableBuilder(
    column: $table.summaryJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get expiresAt => $composableBuilder(
    column: $table.expiresAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HandoversTableAnnotationComposer
    extends Composer<_$AppDatabase, $HandoversTable> {
  $$HandoversTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<String> get fromUserName => $composableBuilder(
    column: $table.fromUserName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get toUserId =>
      $composableBuilder(column: $table.toUserId, builder: (column) => column);

  GeneratedColumn<String> get summaryJson => $composableBuilder(
    column: $table.summaryJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get expiresAt =>
      $composableBuilder(column: $table.expiresAt, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);
}

class $$HandoversTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HandoversTable,
          HandoverRow,
          $$HandoversTableFilterComposer,
          $$HandoversTableOrderingComposer,
          $$HandoversTableAnnotationComposer,
          $$HandoversTableCreateCompanionBuilder,
          $$HandoversTableUpdateCompanionBuilder,
          (
            HandoverRow,
            BaseReferences<_$AppDatabase, $HandoversTable, HandoverRow>,
          ),
          HandoverRow,
          PrefetchHooks Function()
        > {
  $$HandoversTableTableManager(_$AppDatabase db, $HandoversTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HandoversTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HandoversTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HandoversTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> serverId = const Value.absent(),
                Value<String> fromUserName = const Value.absent(),
                Value<String> toUserId = const Value.absent(),
                Value<String> summaryJson = const Value.absent(),
                Value<String?> reason = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime?> expiresAt = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HandoversCompanion(
                serverId: serverId,
                fromUserName: fromUserName,
                toUserId: toUserId,
                summaryJson: summaryJson,
                reason: reason,
                status: status,
                expiresAt: expiresAt,
                role: role,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String serverId,
                required String fromUserName,
                required String toUserId,
                required String summaryJson,
                Value<String?> reason = const Value.absent(),
                required String status,
                Value<DateTime?> expiresAt = const Value.absent(),
                required String role,
                Value<int> rowid = const Value.absent(),
              }) => HandoversCompanion.insert(
                serverId: serverId,
                fromUserName: fromUserName,
                toUserId: toUserId,
                summaryJson: summaryJson,
                reason: reason,
                status: status,
                expiresAt: expiresAt,
                role: role,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$HandoversTable, HandoverRow>(table),
                  BaseReferences<_$AppDatabase, $HandoversTable, HandoverRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$HandoversTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HandoversTable,
      HandoverRow,
      $$HandoversTableFilterComposer,
      $$HandoversTableOrderingComposer,
      $$HandoversTableAnnotationComposer,
      $$HandoversTableCreateCompanionBuilder,
      $$HandoversTableUpdateCompanionBuilder,
      (
        HandoverRow,
        BaseReferences<_$AppDatabase, $HandoversTable, HandoverRow>,
      ),
      HandoverRow,
      PrefetchHooks Function()
    >;
typedef $$MediaQueueTableCreateCompanionBuilder = MediaQueueCompanion Function({
  required String clientId,
  required String kind,
  required String localPath,
  required String sha256,
  required int sizeBytes,
  required DateTime capturedAt,
  required String ownerEntity,
  required String ownerClientId,
  Value<String?> serverMediaId,
  Value<String> state,
  Value<int> attempts,
  Value<DateTime?> nextAttemptAt,
  Value<int> rowid,
});
typedef $$MediaQueueTableUpdateCompanionBuilder = MediaQueueCompanion Function({
  Value<String> clientId,
  Value<String> kind,
  Value<String> localPath,
  Value<String> sha256,
  Value<int> sizeBytes,
  Value<DateTime> capturedAt,
  Value<String> ownerEntity,
  Value<String> ownerClientId,
  Value<String?> serverMediaId,
  Value<String> state,
  Value<int> attempts,
  Value<DateTime?> nextAttemptAt,
  Value<int> rowid,
});

class $$MediaQueueTableFilterComposer
    extends Composer<_$AppDatabase, $MediaQueueTable> {
  $$MediaQueueTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get clientId => $composableBuilder(
    column: $table.clientId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sha256 => $composableBuilder(
    column: $table.sha256,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get capturedAt => $composableBuilder(
    column: $table.capturedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerEntity => $composableBuilder(
    column: $table.ownerEntity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerClientId => $composableBuilder(
    column: $table.ownerClientId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get serverMediaId => $composableBuilder(
    column: $table.serverMediaId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get nextAttemptAt => $composableBuilder(
    column: $table.nextAttemptAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MediaQueueTableOrderingComposer
    extends Composer<_$AppDatabase, $MediaQueueTable> {
  $$MediaQueueTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get clientId => $composableBuilder(
    column: $table.clientId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sha256 => $composableBuilder(
    column: $table.sha256,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get capturedAt => $composableBuilder(
    column: $table.capturedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerEntity => $composableBuilder(
    column: $table.ownerEntity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerClientId => $composableBuilder(
    column: $table.ownerClientId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get serverMediaId => $composableBuilder(
    column: $table.serverMediaId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get nextAttemptAt => $composableBuilder(
    column: $table.nextAttemptAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MediaQueueTableAnnotationComposer
    extends Composer<_$AppDatabase, $MediaQueueTable> {
  $$MediaQueueTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get clientId =>
      $composableBuilder(column: $table.clientId, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get localPath =>
      $composableBuilder(column: $table.localPath, builder: (column) => column);

  GeneratedColumn<String> get sha256 =>
      $composableBuilder(column: $table.sha256, builder: (column) => column);

  GeneratedColumn<int> get sizeBytes =>
      $composableBuilder(column: $table.sizeBytes, builder: (column) => column);

  GeneratedColumn<DateTime> get capturedAt => $composableBuilder(
    column: $table.capturedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ownerEntity => $composableBuilder(
    column: $table.ownerEntity,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ownerClientId => $composableBuilder(
    column: $table.ownerClientId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get serverMediaId => $composableBuilder(
    column: $table.serverMediaId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<int> get attempts =>
      $composableBuilder(column: $table.attempts, builder: (column) => column);

  GeneratedColumn<DateTime> get nextAttemptAt => $composableBuilder(
    column: $table.nextAttemptAt,
    builder: (column) => column,
  );
}

class $$MediaQueueTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MediaQueueTable,
          MediaQueueRow,
          $$MediaQueueTableFilterComposer,
          $$MediaQueueTableOrderingComposer,
          $$MediaQueueTableAnnotationComposer,
          $$MediaQueueTableCreateCompanionBuilder,
          $$MediaQueueTableUpdateCompanionBuilder,
          (
            MediaQueueRow,
            BaseReferences<_$AppDatabase, $MediaQueueTable, MediaQueueRow>,
          ),
          MediaQueueRow,
          PrefetchHooks Function()
        > {
  $$MediaQueueTableTableManager(_$AppDatabase db, $MediaQueueTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MediaQueueTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MediaQueueTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MediaQueueTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> clientId = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> localPath = const Value.absent(),
                Value<String> sha256 = const Value.absent(),
                Value<int> sizeBytes = const Value.absent(),
                Value<DateTime> capturedAt = const Value.absent(),
                Value<String> ownerEntity = const Value.absent(),
                Value<String> ownerClientId = const Value.absent(),
                Value<String?> serverMediaId = const Value.absent(),
                Value<String> state = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<DateTime?> nextAttemptAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MediaQueueCompanion(
                clientId: clientId,
                kind: kind,
                localPath: localPath,
                sha256: sha256,
                sizeBytes: sizeBytes,
                capturedAt: capturedAt,
                ownerEntity: ownerEntity,
                ownerClientId: ownerClientId,
                serverMediaId: serverMediaId,
                state: state,
                attempts: attempts,
                nextAttemptAt: nextAttemptAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String clientId,
                required String kind,
                required String localPath,
                required String sha256,
                required int sizeBytes,
                required DateTime capturedAt,
                required String ownerEntity,
                required String ownerClientId,
                Value<String?> serverMediaId = const Value.absent(),
                Value<String> state = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<DateTime?> nextAttemptAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MediaQueueCompanion.insert(
                clientId: clientId,
                kind: kind,
                localPath: localPath,
                sha256: sha256,
                sizeBytes: sizeBytes,
                capturedAt: capturedAt,
                ownerEntity: ownerEntity,
                ownerClientId: ownerClientId,
                serverMediaId: serverMediaId,
                state: state,
                attempts: attempts,
                nextAttemptAt: nextAttemptAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MediaQueueTable, MediaQueueRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $MediaQueueTable,
                    MediaQueueRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MediaQueueTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MediaQueueTable,
      MediaQueueRow,
      $$MediaQueueTableFilterComposer,
      $$MediaQueueTableOrderingComposer,
      $$MediaQueueTableAnnotationComposer,
      $$MediaQueueTableCreateCompanionBuilder,
      $$MediaQueueTableUpdateCompanionBuilder,
      (
        MediaQueueRow,
        BaseReferences<_$AppDatabase, $MediaQueueTable, MediaQueueRow>,
      ),
      MediaQueueRow,
      PrefetchHooks Function()
    >;
typedef $$OutboxTableCreateCompanionBuilder = OutboxCompanion Function({
  required String mutationId,
  required String entity,
  required String op,
  required String payloadJson,
  Value<String> dependsOnJson,
  required DateTime createdAt,
  Value<String> state,
  Value<int> attempts,
  Value<DateTime?> nextAttemptAt,
  Value<String?> lastError,
  Value<String?> result,
  Value<DateTime?> doneAt,
  Value<int> rowid,
});
typedef $$OutboxTableUpdateCompanionBuilder = OutboxCompanion Function({
  Value<String> mutationId,
  Value<String> entity,
  Value<String> op,
  Value<String> payloadJson,
  Value<String> dependsOnJson,
  Value<DateTime> createdAt,
  Value<String> state,
  Value<int> attempts,
  Value<DateTime?> nextAttemptAt,
  Value<String?> lastError,
  Value<String?> result,
  Value<DateTime?> doneAt,
  Value<int> rowid,
});

class $$OutboxTableFilterComposer
    extends Composer<_$AppDatabase, $OutboxTable> {
  $$OutboxTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get mutationId => $composableBuilder(
    column: $table.mutationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entity => $composableBuilder(
    column: $table.entity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get op => $composableBuilder(
    column: $table.op,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dependsOnJson => $composableBuilder(
    column: $table.dependsOnJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get nextAttemptAt => $composableBuilder(
    column: $table.nextAttemptAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get result => $composableBuilder(
    column: $table.result,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get doneAt => $composableBuilder(
    column: $table.doneAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$OutboxTableOrderingComposer
    extends Composer<_$AppDatabase, $OutboxTable> {
  $$OutboxTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get mutationId => $composableBuilder(
    column: $table.mutationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entity => $composableBuilder(
    column: $table.entity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get op => $composableBuilder(
    column: $table.op,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dependsOnJson => $composableBuilder(
    column: $table.dependsOnJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get nextAttemptAt => $composableBuilder(
    column: $table.nextAttemptAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get result => $composableBuilder(
    column: $table.result,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get doneAt => $composableBuilder(
    column: $table.doneAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$OutboxTableAnnotationComposer
    extends Composer<_$AppDatabase, $OutboxTable> {
  $$OutboxTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get mutationId => $composableBuilder(
    column: $table.mutationId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entity =>
      $composableBuilder(column: $table.entity, builder: (column) => column);

  GeneratedColumn<String> get op =>
      $composableBuilder(column: $table.op, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get dependsOnJson => $composableBuilder(
    column: $table.dependsOnJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<int> get attempts =>
      $composableBuilder(column: $table.attempts, builder: (column) => column);

  GeneratedColumn<DateTime> get nextAttemptAt => $composableBuilder(
    column: $table.nextAttemptAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);

  GeneratedColumn<String> get result =>
      $composableBuilder(column: $table.result, builder: (column) => column);

  GeneratedColumn<DateTime> get doneAt =>
      $composableBuilder(column: $table.doneAt, builder: (column) => column);
}

class $$OutboxTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OutboxTable,
          OutboxRow,
          $$OutboxTableFilterComposer,
          $$OutboxTableOrderingComposer,
          $$OutboxTableAnnotationComposer,
          $$OutboxTableCreateCompanionBuilder,
          $$OutboxTableUpdateCompanionBuilder,
          (OutboxRow, BaseReferences<_$AppDatabase, $OutboxTable, OutboxRow>),
          OutboxRow,
          PrefetchHooks Function()
        > {
  $$OutboxTableTableManager(_$AppDatabase db, $OutboxTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OutboxTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OutboxTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OutboxTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> mutationId = const Value.absent(),
                Value<String> entity = const Value.absent(),
                Value<String> op = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<String> dependsOnJson = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String> state = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<DateTime?> nextAttemptAt = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<String?> result = const Value.absent(),
                Value<DateTime?> doneAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OutboxCompanion(
                mutationId: mutationId,
                entity: entity,
                op: op,
                payloadJson: payloadJson,
                dependsOnJson: dependsOnJson,
                createdAt: createdAt,
                state: state,
                attempts: attempts,
                nextAttemptAt: nextAttemptAt,
                lastError: lastError,
                result: result,
                doneAt: doneAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String mutationId,
                required String entity,
                required String op,
                required String payloadJson,
                Value<String> dependsOnJson = const Value.absent(),
                required DateTime createdAt,
                Value<String> state = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<DateTime?> nextAttemptAt = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<String?> result = const Value.absent(),
                Value<DateTime?> doneAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OutboxCompanion.insert(
                mutationId: mutationId,
                entity: entity,
                op: op,
                payloadJson: payloadJson,
                dependsOnJson: dependsOnJson,
                createdAt: createdAt,
                state: state,
                attempts: attempts,
                nextAttemptAt: nextAttemptAt,
                lastError: lastError,
                result: result,
                doneAt: doneAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$OutboxTable, OutboxRow>(table),
                  BaseReferences<_$AppDatabase, $OutboxTable, OutboxRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$OutboxTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OutboxTable,
      OutboxRow,
      $$OutboxTableFilterComposer,
      $$OutboxTableOrderingComposer,
      $$OutboxTableAnnotationComposer,
      $$OutboxTableCreateCompanionBuilder,
      $$OutboxTableUpdateCompanionBuilder,
      (OutboxRow, BaseReferences<_$AppDatabase, $OutboxTable, OutboxRow>),
      OutboxRow,
      PrefetchHooks Function()
    >;
typedef $$IdMapTableCreateCompanionBuilder = IdMapCompanion Function({
  required String clientId,
  required String entity,
  required String serverId,
  Value<int> rowid,
});
typedef $$IdMapTableUpdateCompanionBuilder = IdMapCompanion Function({
  Value<String> clientId,
  Value<String> entity,
  Value<String> serverId,
  Value<int> rowid,
});

class $$IdMapTableFilterComposer extends Composer<_$AppDatabase, $IdMapTable> {
  $$IdMapTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get clientId => $composableBuilder(
    column: $table.clientId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entity => $composableBuilder(
    column: $table.entity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$IdMapTableOrderingComposer
    extends Composer<_$AppDatabase, $IdMapTable> {
  $$IdMapTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get clientId => $composableBuilder(
    column: $table.clientId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entity => $composableBuilder(
    column: $table.entity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$IdMapTableAnnotationComposer
    extends Composer<_$AppDatabase, $IdMapTable> {
  $$IdMapTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get clientId =>
      $composableBuilder(column: $table.clientId, builder: (column) => column);

  GeneratedColumn<String> get entity =>
      $composableBuilder(column: $table.entity, builder: (column) => column);

  GeneratedColumn<String> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);
}

class $$IdMapTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $IdMapTable,
          IdMapRow,
          $$IdMapTableFilterComposer,
          $$IdMapTableOrderingComposer,
          $$IdMapTableAnnotationComposer,
          $$IdMapTableCreateCompanionBuilder,
          $$IdMapTableUpdateCompanionBuilder,
          (IdMapRow, BaseReferences<_$AppDatabase, $IdMapTable, IdMapRow>),
          IdMapRow,
          PrefetchHooks Function()
        > {
  $$IdMapTableTableManager(_$AppDatabase db, $IdMapTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$IdMapTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$IdMapTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$IdMapTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> clientId = const Value.absent(),
                Value<String> entity = const Value.absent(),
                Value<String> serverId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => IdMapCompanion(
                clientId: clientId,
                entity: entity,
                serverId: serverId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String clientId,
                required String entity,
                required String serverId,
                Value<int> rowid = const Value.absent(),
              }) => IdMapCompanion.insert(
                clientId: clientId,
                entity: entity,
                serverId: serverId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$IdMapTable, IdMapRow>(table),
                  BaseReferences<_$AppDatabase, $IdMapTable, IdMapRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$IdMapTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $IdMapTable,
      IdMapRow,
      $$IdMapTableFilterComposer,
      $$IdMapTableOrderingComposer,
      $$IdMapTableAnnotationComposer,
      $$IdMapTableCreateCompanionBuilder,
      $$IdMapTableUpdateCompanionBuilder,
      (IdMapRow, BaseReferences<_$AppDatabase, $IdMapTable, IdMapRow>),
      IdMapRow,
      PrefetchHooks Function()
    >;
typedef $$SyncMetaTableCreateCompanionBuilder = SyncMetaCompanion Function({
  Value<int> id,
  Value<String?> pullCursor,
  Value<DateTime?> lastPullAt,
  Value<DateTime?> lastPushAt,
  Value<DateTime?> lastSuccessAt,
  Value<int> serverOffsetMs,
  Value<bool> bootstrapDone,
  Value<String?> lastError,
});
typedef $$SyncMetaTableUpdateCompanionBuilder = SyncMetaCompanion Function({
  Value<int> id,
  Value<String?> pullCursor,
  Value<DateTime?> lastPullAt,
  Value<DateTime?> lastPushAt,
  Value<DateTime?> lastSuccessAt,
  Value<int> serverOffsetMs,
  Value<bool> bootstrapDone,
  Value<String?> lastError,
});

class $$SyncMetaTableFilterComposer
    extends Composer<_$AppDatabase, $SyncMetaTable> {
  $$SyncMetaTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pullCursor => $composableBuilder(
    column: $table.pullCursor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastPullAt => $composableBuilder(
    column: $table.lastPullAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastPushAt => $composableBuilder(
    column: $table.lastPushAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSuccessAt => $composableBuilder(
    column: $table.lastSuccessAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverOffsetMs => $composableBuilder(
    column: $table.serverOffsetMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get bootstrapDone => $composableBuilder(
    column: $table.bootstrapDone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncMetaTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncMetaTable> {
  $$SyncMetaTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pullCursor => $composableBuilder(
    column: $table.pullCursor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastPullAt => $composableBuilder(
    column: $table.lastPullAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastPushAt => $composableBuilder(
    column: $table.lastPushAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSuccessAt => $composableBuilder(
    column: $table.lastSuccessAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverOffsetMs => $composableBuilder(
    column: $table.serverOffsetMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get bootstrapDone => $composableBuilder(
    column: $table.bootstrapDone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncMetaTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncMetaTable> {
  $$SyncMetaTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get pullCursor => $composableBuilder(
    column: $table.pullCursor,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastPullAt => $composableBuilder(
    column: $table.lastPullAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastPushAt => $composableBuilder(
    column: $table.lastPushAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastSuccessAt => $composableBuilder(
    column: $table.lastSuccessAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get serverOffsetMs => $composableBuilder(
    column: $table.serverOffsetMs,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get bootstrapDone => $composableBuilder(
    column: $table.bootstrapDone,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);
}

class $$SyncMetaTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncMetaTable,
          SyncMetaRow,
          $$SyncMetaTableFilterComposer,
          $$SyncMetaTableOrderingComposer,
          $$SyncMetaTableAnnotationComposer,
          $$SyncMetaTableCreateCompanionBuilder,
          $$SyncMetaTableUpdateCompanionBuilder,
          (
            SyncMetaRow,
            BaseReferences<_$AppDatabase, $SyncMetaTable, SyncMetaRow>,
          ),
          SyncMetaRow,
          PrefetchHooks Function()
        > {
  $$SyncMetaTableTableManager(_$AppDatabase db, $SyncMetaTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncMetaTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncMetaTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncMetaTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> pullCursor = const Value.absent(),
                Value<DateTime?> lastPullAt = const Value.absent(),
                Value<DateTime?> lastPushAt = const Value.absent(),
                Value<DateTime?> lastSuccessAt = const Value.absent(),
                Value<int> serverOffsetMs = const Value.absent(),
                Value<bool> bootstrapDone = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
              }) => SyncMetaCompanion(
                id: id,
                pullCursor: pullCursor,
                lastPullAt: lastPullAt,
                lastPushAt: lastPushAt,
                lastSuccessAt: lastSuccessAt,
                serverOffsetMs: serverOffsetMs,
                bootstrapDone: bootstrapDone,
                lastError: lastError,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> pullCursor = const Value.absent(),
                Value<DateTime?> lastPullAt = const Value.absent(),
                Value<DateTime?> lastPushAt = const Value.absent(),
                Value<DateTime?> lastSuccessAt = const Value.absent(),
                Value<int> serverOffsetMs = const Value.absent(),
                Value<bool> bootstrapDone = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
              }) => SyncMetaCompanion.insert(
                id: id,
                pullCursor: pullCursor,
                lastPullAt: lastPullAt,
                lastPushAt: lastPushAt,
                lastSuccessAt: lastSuccessAt,
                serverOffsetMs: serverOffsetMs,
                bootstrapDone: bootstrapDone,
                lastError: lastError,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SyncMetaTable, SyncMetaRow>(table),
                  BaseReferences<_$AppDatabase, $SyncMetaTable, SyncMetaRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncMetaTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncMetaTable,
      SyncMetaRow,
      $$SyncMetaTableFilterComposer,
      $$SyncMetaTableOrderingComposer,
      $$SyncMetaTableAnnotationComposer,
      $$SyncMetaTableCreateCompanionBuilder,
      $$SyncMetaTableUpdateCompanionBuilder,
      (SyncMetaRow, BaseReferences<_$AppDatabase, $SyncMetaTable, SyncMetaRow>),
      SyncMetaRow,
      PrefetchHooks Function()
    >;
typedef $$LocationQueueTableCreateCompanionBuilder =
    LocationQueueCompanion Function({
      Value<int> id,
      required DateTime t,
      required double lat,
      required double lng,
      required double acc,
      Value<double?> spd,
      Value<double?> hdg,
      Value<double?> alt,
      Value<String?> act,
      Value<double?> bat,
      Value<bool?> chg,
      Value<bool> mock,
    });
typedef $$LocationQueueTableUpdateCompanionBuilder =
    LocationQueueCompanion Function({
      Value<int> id,
      Value<DateTime> t,
      Value<double> lat,
      Value<double> lng,
      Value<double> acc,
      Value<double?> spd,
      Value<double?> hdg,
      Value<double?> alt,
      Value<String?> act,
      Value<double?> bat,
      Value<bool?> chg,
      Value<bool> mock,
    });

class $$LocationQueueTableFilterComposer
    extends Composer<_$AppDatabase, $LocationQueueTable> {
  $$LocationQueueTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get t => $composableBuilder(
    column: $table.t,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lat => $composableBuilder(
    column: $table.lat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lng => $composableBuilder(
    column: $table.lng,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get acc => $composableBuilder(
    column: $table.acc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get spd => $composableBuilder(
    column: $table.spd,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get hdg => $composableBuilder(
    column: $table.hdg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get alt => $composableBuilder(
    column: $table.alt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get act => $composableBuilder(
    column: $table.act,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get bat => $composableBuilder(
    column: $table.bat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get chg => $composableBuilder(
    column: $table.chg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get mock => $composableBuilder(
    column: $table.mock,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocationQueueTableOrderingComposer
    extends Composer<_$AppDatabase, $LocationQueueTable> {
  $$LocationQueueTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get t => $composableBuilder(
    column: $table.t,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lat => $composableBuilder(
    column: $table.lat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lng => $composableBuilder(
    column: $table.lng,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get acc => $composableBuilder(
    column: $table.acc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get spd => $composableBuilder(
    column: $table.spd,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get hdg => $composableBuilder(
    column: $table.hdg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get alt => $composableBuilder(
    column: $table.alt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get act => $composableBuilder(
    column: $table.act,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get bat => $composableBuilder(
    column: $table.bat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get chg => $composableBuilder(
    column: $table.chg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get mock => $composableBuilder(
    column: $table.mock,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocationQueueTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocationQueueTable> {
  $$LocationQueueTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get t =>
      $composableBuilder(column: $table.t, builder: (column) => column);

  GeneratedColumn<double> get lat =>
      $composableBuilder(column: $table.lat, builder: (column) => column);

  GeneratedColumn<double> get lng =>
      $composableBuilder(column: $table.lng, builder: (column) => column);

  GeneratedColumn<double> get acc =>
      $composableBuilder(column: $table.acc, builder: (column) => column);

  GeneratedColumn<double> get spd =>
      $composableBuilder(column: $table.spd, builder: (column) => column);

  GeneratedColumn<double> get hdg =>
      $composableBuilder(column: $table.hdg, builder: (column) => column);

  GeneratedColumn<double> get alt =>
      $composableBuilder(column: $table.alt, builder: (column) => column);

  GeneratedColumn<String> get act =>
      $composableBuilder(column: $table.act, builder: (column) => column);

  GeneratedColumn<double> get bat =>
      $composableBuilder(column: $table.bat, builder: (column) => column);

  GeneratedColumn<bool> get chg =>
      $composableBuilder(column: $table.chg, builder: (column) => column);

  GeneratedColumn<bool> get mock =>
      $composableBuilder(column: $table.mock, builder: (column) => column);
}

class $$LocationQueueTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocationQueueTable,
          LocationPointRow,
          $$LocationQueueTableFilterComposer,
          $$LocationQueueTableOrderingComposer,
          $$LocationQueueTableAnnotationComposer,
          $$LocationQueueTableCreateCompanionBuilder,
          $$LocationQueueTableUpdateCompanionBuilder,
          (
            LocationPointRow,
            BaseReferences<
              _$AppDatabase,
              $LocationQueueTable,
              LocationPointRow
            >,
          ),
          LocationPointRow,
          PrefetchHooks Function()
        > {
  $$LocationQueueTableTableManager(_$AppDatabase db, $LocationQueueTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocationQueueTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocationQueueTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocationQueueTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> t = const Value.absent(),
                Value<double> lat = const Value.absent(),
                Value<double> lng = const Value.absent(),
                Value<double> acc = const Value.absent(),
                Value<double?> spd = const Value.absent(),
                Value<double?> hdg = const Value.absent(),
                Value<double?> alt = const Value.absent(),
                Value<String?> act = const Value.absent(),
                Value<double?> bat = const Value.absent(),
                Value<bool?> chg = const Value.absent(),
                Value<bool> mock = const Value.absent(),
              }) => LocationQueueCompanion(
                id: id,
                t: t,
                lat: lat,
                lng: lng,
                acc: acc,
                spd: spd,
                hdg: hdg,
                alt: alt,
                act: act,
                bat: bat,
                chg: chg,
                mock: mock,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime t,
                required double lat,
                required double lng,
                required double acc,
                Value<double?> spd = const Value.absent(),
                Value<double?> hdg = const Value.absent(),
                Value<double?> alt = const Value.absent(),
                Value<String?> act = const Value.absent(),
                Value<double?> bat = const Value.absent(),
                Value<bool?> chg = const Value.absent(),
                Value<bool> mock = const Value.absent(),
              }) => LocationQueueCompanion.insert(
                id: id,
                t: t,
                lat: lat,
                lng: lng,
                acc: acc,
                spd: spd,
                hdg: hdg,
                alt: alt,
                act: act,
                bat: bat,
                chg: chg,
                mock: mock,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LocationQueueTable, LocationPointRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $LocationQueueTable,
                    LocationPointRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocationQueueTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocationQueueTable,
      LocationPointRow,
      $$LocationQueueTableFilterComposer,
      $$LocationQueueTableOrderingComposer,
      $$LocationQueueTableAnnotationComposer,
      $$LocationQueueTableCreateCompanionBuilder,
      $$LocationQueueTableUpdateCompanionBuilder,
      (
        LocationPointRow,
        BaseReferences<_$AppDatabase, $LocationQueueTable, LocationPointRow>,
      ),
      LocationPointRow,
      PrefetchHooks Function()
    >;
typedef $$ContactAttemptsTableCreateCompanionBuilder =
    ContactAttemptsCompanion Function({
      required String clientId,
      Value<String?> serverId,
      required String customerId,
      required String channel,
      Value<int?> phoneIndex,
      Value<String> target,
      required DateTime at,
      Value<String?> outcome,
      Value<String?> note,
      Value<String> syncState,
      Value<int> rowid,
    });
typedef $$ContactAttemptsTableUpdateCompanionBuilder =
    ContactAttemptsCompanion Function({
      Value<String> clientId,
      Value<String?> serverId,
      Value<String> customerId,
      Value<String> channel,
      Value<int?> phoneIndex,
      Value<String> target,
      Value<DateTime> at,
      Value<String?> outcome,
      Value<String?> note,
      Value<String> syncState,
      Value<int> rowid,
    });

class $$ContactAttemptsTableFilterComposer
    extends Composer<_$AppDatabase, $ContactAttemptsTable> {
  $$ContactAttemptsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get clientId => $composableBuilder(
    column: $table.clientId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get channel => $composableBuilder(
    column: $table.channel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get phoneIndex => $composableBuilder(
    column: $table.phoneIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get target => $composableBuilder(
    column: $table.target,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get outcome => $composableBuilder(
    column: $table.outcome,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ContactAttemptsTableOrderingComposer
    extends Composer<_$AppDatabase, $ContactAttemptsTable> {
  $$ContactAttemptsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get clientId => $composableBuilder(
    column: $table.clientId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get channel => $composableBuilder(
    column: $table.channel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get phoneIndex => $composableBuilder(
    column: $table.phoneIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get target => $composableBuilder(
    column: $table.target,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get outcome => $composableBuilder(
    column: $table.outcome,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ContactAttemptsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ContactAttemptsTable> {
  $$ContactAttemptsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get clientId =>
      $composableBuilder(column: $table.clientId, builder: (column) => column);

  GeneratedColumn<String> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<String> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get channel =>
      $composableBuilder(column: $table.channel, builder: (column) => column);

  GeneratedColumn<int> get phoneIndex => $composableBuilder(
    column: $table.phoneIndex,
    builder: (column) => column,
  );

  GeneratedColumn<String> get target =>
      $composableBuilder(column: $table.target, builder: (column) => column);

  GeneratedColumn<DateTime> get at =>
      $composableBuilder(column: $table.at, builder: (column) => column);

  GeneratedColumn<String> get outcome =>
      $composableBuilder(column: $table.outcome, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);
}

class $$ContactAttemptsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ContactAttemptsTable,
          ContactAttemptRow,
          $$ContactAttemptsTableFilterComposer,
          $$ContactAttemptsTableOrderingComposer,
          $$ContactAttemptsTableAnnotationComposer,
          $$ContactAttemptsTableCreateCompanionBuilder,
          $$ContactAttemptsTableUpdateCompanionBuilder,
          (
            ContactAttemptRow,
            BaseReferences<
              _$AppDatabase,
              $ContactAttemptsTable,
              ContactAttemptRow
            >,
          ),
          ContactAttemptRow,
          PrefetchHooks Function()
        > {
  $$ContactAttemptsTableTableManager(
    _$AppDatabase db,
    $ContactAttemptsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ContactAttemptsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ContactAttemptsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ContactAttemptsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> clientId = const Value.absent(),
                Value<String?> serverId = const Value.absent(),
                Value<String> customerId = const Value.absent(),
                Value<String> channel = const Value.absent(),
                Value<int?> phoneIndex = const Value.absent(),
                Value<String> target = const Value.absent(),
                Value<DateTime> at = const Value.absent(),
                Value<String?> outcome = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String> syncState = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ContactAttemptsCompanion(
                clientId: clientId,
                serverId: serverId,
                customerId: customerId,
                channel: channel,
                phoneIndex: phoneIndex,
                target: target,
                at: at,
                outcome: outcome,
                note: note,
                syncState: syncState,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String clientId,
                Value<String?> serverId = const Value.absent(),
                required String customerId,
                required String channel,
                Value<int?> phoneIndex = const Value.absent(),
                Value<String> target = const Value.absent(),
                required DateTime at,
                Value<String?> outcome = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String> syncState = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ContactAttemptsCompanion.insert(
                clientId: clientId,
                serverId: serverId,
                customerId: customerId,
                channel: channel,
                phoneIndex: phoneIndex,
                target: target,
                at: at,
                outcome: outcome,
                note: note,
                syncState: syncState,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ContactAttemptsTable, ContactAttemptRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $ContactAttemptsTable,
                    ContactAttemptRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ContactAttemptsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ContactAttemptsTable,
      ContactAttemptRow,
      $$ContactAttemptsTableFilterComposer,
      $$ContactAttemptsTableOrderingComposer,
      $$ContactAttemptsTableAnnotationComposer,
      $$ContactAttemptsTableCreateCompanionBuilder,
      $$ContactAttemptsTableUpdateCompanionBuilder,
      (
        ContactAttemptRow,
        BaseReferences<_$AppDatabase, $ContactAttemptsTable, ContactAttemptRow>,
      ),
      ContactAttemptRow,
      PrefetchHooks Function()
    >;
typedef $$CoworkSessionsTableCreateCompanionBuilder =
    CoworkSessionsCompanion Function({
      required String id,
      required String businessDate,
      required String status,
      required String createdBy,
      Value<String?> note,
      required String membersJson,
      required DateTime createdAt,
      Value<DateTime?> endedAt,
      Value<int> rowid,
    });
typedef $$CoworkSessionsTableUpdateCompanionBuilder =
    CoworkSessionsCompanion Function({
      Value<String> id,
      Value<String> businessDate,
      Value<String> status,
      Value<String> createdBy,
      Value<String?> note,
      Value<String> membersJson,
      Value<DateTime> createdAt,
      Value<DateTime?> endedAt,
      Value<int> rowid,
    });

class $$CoworkSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $CoworkSessionsTable> {
  $$CoworkSessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get businessDate => $composableBuilder(
    column: $table.businessDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get membersJson => $composableBuilder(
    column: $table.membersJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CoworkSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $CoworkSessionsTable> {
  $$CoworkSessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get businessDate => $composableBuilder(
    column: $table.businessDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get membersJson => $composableBuilder(
    column: $table.membersJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CoworkSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CoworkSessionsTable> {
  $$CoworkSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get businessDate => $composableBuilder(
    column: $table.businessDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get membersJson => $composableBuilder(
    column: $table.membersJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => column);
}

class $$CoworkSessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CoworkSessionsTable,
          CoworkSessionRow,
          $$CoworkSessionsTableFilterComposer,
          $$CoworkSessionsTableOrderingComposer,
          $$CoworkSessionsTableAnnotationComposer,
          $$CoworkSessionsTableCreateCompanionBuilder,
          $$CoworkSessionsTableUpdateCompanionBuilder,
          (
            CoworkSessionRow,
            BaseReferences<
              _$AppDatabase,
              $CoworkSessionsTable,
              CoworkSessionRow
            >,
          ),
          CoworkSessionRow,
          PrefetchHooks Function()
        > {
  $$CoworkSessionsTableTableManager(
    _$AppDatabase db,
    $CoworkSessionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CoworkSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CoworkSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CoworkSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> businessDate = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> createdBy = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String> membersJson = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> endedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CoworkSessionsCompanion(
                id: id,
                businessDate: businessDate,
                status: status,
                createdBy: createdBy,
                note: note,
                membersJson: membersJson,
                createdAt: createdAt,
                endedAt: endedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String businessDate,
                required String status,
                required String createdBy,
                Value<String?> note = const Value.absent(),
                required String membersJson,
                required DateTime createdAt,
                Value<DateTime?> endedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CoworkSessionsCompanion.insert(
                id: id,
                businessDate: businessDate,
                status: status,
                createdBy: createdBy,
                note: note,
                membersJson: membersJson,
                createdAt: createdAt,
                endedAt: endedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CoworkSessionsTable, CoworkSessionRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $CoworkSessionsTable,
                    CoworkSessionRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CoworkSessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CoworkSessionsTable,
      CoworkSessionRow,
      $$CoworkSessionsTableFilterComposer,
      $$CoworkSessionsTableOrderingComposer,
      $$CoworkSessionsTableAnnotationComposer,
      $$CoworkSessionsTableCreateCompanionBuilder,
      $$CoworkSessionsTableUpdateCompanionBuilder,
      (
        CoworkSessionRow,
        BaseReferences<_$AppDatabase, $CoworkSessionsTable, CoworkSessionRow>,
      ),
      CoworkSessionRow,
      PrefetchHooks Function()
    >;
typedef $$BroadcastsTableCreateCompanionBuilder = BroadcastsCompanion Function({
  required String serverId,
  required String titleBn,
  Value<String?> titleEn,
  required String bodyBn,
  Value<String?> bodyEn,
  Value<bool> requireAck,
  Value<String?> senderName,
  required DateTime createdAt,
  Value<DateTime?> ackedAt,
  Value<String> ackState,
  Value<String?> ackMutationId,
  Value<int> rowid,
});
typedef $$BroadcastsTableUpdateCompanionBuilder = BroadcastsCompanion Function({
  Value<String> serverId,
  Value<String> titleBn,
  Value<String?> titleEn,
  Value<String> bodyBn,
  Value<String?> bodyEn,
  Value<bool> requireAck,
  Value<String?> senderName,
  Value<DateTime> createdAt,
  Value<DateTime?> ackedAt,
  Value<String> ackState,
  Value<String?> ackMutationId,
  Value<int> rowid,
});

class $$BroadcastsTableFilterComposer
    extends Composer<_$AppDatabase, $BroadcastsTable> {
  $$BroadcastsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get titleBn => $composableBuilder(
    column: $table.titleBn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get titleEn => $composableBuilder(
    column: $table.titleEn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bodyBn => $composableBuilder(
    column: $table.bodyBn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bodyEn => $composableBuilder(
    column: $table.bodyEn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get requireAck => $composableBuilder(
    column: $table.requireAck,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get senderName => $composableBuilder(
    column: $table.senderName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get ackedAt => $composableBuilder(
    column: $table.ackedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ackState => $composableBuilder(
    column: $table.ackState,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ackMutationId => $composableBuilder(
    column: $table.ackMutationId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BroadcastsTableOrderingComposer
    extends Composer<_$AppDatabase, $BroadcastsTable> {
  $$BroadcastsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get titleBn => $composableBuilder(
    column: $table.titleBn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get titleEn => $composableBuilder(
    column: $table.titleEn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bodyBn => $composableBuilder(
    column: $table.bodyBn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bodyEn => $composableBuilder(
    column: $table.bodyEn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get requireAck => $composableBuilder(
    column: $table.requireAck,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get senderName => $composableBuilder(
    column: $table.senderName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get ackedAt => $composableBuilder(
    column: $table.ackedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ackState => $composableBuilder(
    column: $table.ackState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ackMutationId => $composableBuilder(
    column: $table.ackMutationId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BroadcastsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BroadcastsTable> {
  $$BroadcastsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<String> get titleBn =>
      $composableBuilder(column: $table.titleBn, builder: (column) => column);

  GeneratedColumn<String> get titleEn =>
      $composableBuilder(column: $table.titleEn, builder: (column) => column);

  GeneratedColumn<String> get bodyBn =>
      $composableBuilder(column: $table.bodyBn, builder: (column) => column);

  GeneratedColumn<String> get bodyEn =>
      $composableBuilder(column: $table.bodyEn, builder: (column) => column);

  GeneratedColumn<bool> get requireAck => $composableBuilder(
    column: $table.requireAck,
    builder: (column) => column,
  );

  GeneratedColumn<String> get senderName => $composableBuilder(
    column: $table.senderName,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get ackedAt =>
      $composableBuilder(column: $table.ackedAt, builder: (column) => column);

  GeneratedColumn<String> get ackState =>
      $composableBuilder(column: $table.ackState, builder: (column) => column);

  GeneratedColumn<String> get ackMutationId => $composableBuilder(
    column: $table.ackMutationId,
    builder: (column) => column,
  );
}

class $$BroadcastsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BroadcastsTable,
          BroadcastRow,
          $$BroadcastsTableFilterComposer,
          $$BroadcastsTableOrderingComposer,
          $$BroadcastsTableAnnotationComposer,
          $$BroadcastsTableCreateCompanionBuilder,
          $$BroadcastsTableUpdateCompanionBuilder,
          (
            BroadcastRow,
            BaseReferences<_$AppDatabase, $BroadcastsTable, BroadcastRow>,
          ),
          BroadcastRow,
          PrefetchHooks Function()
        > {
  $$BroadcastsTableTableManager(_$AppDatabase db, $BroadcastsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BroadcastsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BroadcastsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BroadcastsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> serverId = const Value.absent(),
                Value<String> titleBn = const Value.absent(),
                Value<String?> titleEn = const Value.absent(),
                Value<String> bodyBn = const Value.absent(),
                Value<String?> bodyEn = const Value.absent(),
                Value<bool> requireAck = const Value.absent(),
                Value<String?> senderName = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> ackedAt = const Value.absent(),
                Value<String> ackState = const Value.absent(),
                Value<String?> ackMutationId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BroadcastsCompanion(
                serverId: serverId,
                titleBn: titleBn,
                titleEn: titleEn,
                bodyBn: bodyBn,
                bodyEn: bodyEn,
                requireAck: requireAck,
                senderName: senderName,
                createdAt: createdAt,
                ackedAt: ackedAt,
                ackState: ackState,
                ackMutationId: ackMutationId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String serverId,
                required String titleBn,
                Value<String?> titleEn = const Value.absent(),
                required String bodyBn,
                Value<String?> bodyEn = const Value.absent(),
                Value<bool> requireAck = const Value.absent(),
                Value<String?> senderName = const Value.absent(),
                required DateTime createdAt,
                Value<DateTime?> ackedAt = const Value.absent(),
                Value<String> ackState = const Value.absent(),
                Value<String?> ackMutationId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BroadcastsCompanion.insert(
                serverId: serverId,
                titleBn: titleBn,
                titleEn: titleEn,
                bodyBn: bodyBn,
                bodyEn: bodyEn,
                requireAck: requireAck,
                senderName: senderName,
                createdAt: createdAt,
                ackedAt: ackedAt,
                ackState: ackState,
                ackMutationId: ackMutationId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$BroadcastsTable, BroadcastRow>(table),
                  BaseReferences<_$AppDatabase, $BroadcastsTable, BroadcastRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BroadcastsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BroadcastsTable,
      BroadcastRow,
      $$BroadcastsTableFilterComposer,
      $$BroadcastsTableOrderingComposer,
      $$BroadcastsTableAnnotationComposer,
      $$BroadcastsTableCreateCompanionBuilder,
      $$BroadcastsTableUpdateCompanionBuilder,
      (
        BroadcastRow,
        BaseReferences<_$AppDatabase, $BroadcastsTable, BroadcastRow>,
      ),
      BroadcastRow,
      PrefetchHooks Function()
    >;
typedef $$NotificationsTableCreateCompanionBuilder =
    NotificationsCompanion Function({
      required String serverId,
      required String type,
      required String title,
      required String body,
      Value<String> dataJson,
      Value<DateTime?> readAt,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$NotificationsTableUpdateCompanionBuilder =
    NotificationsCompanion Function({
      Value<String> serverId,
      Value<String> type,
      Value<String> title,
      Value<String> body,
      Value<String> dataJson,
      Value<DateTime?> readAt,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$NotificationsTableFilterComposer
    extends Composer<_$AppDatabase, $NotificationsTable> {
  $$NotificationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dataJson => $composableBuilder(
    column: $table.dataJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get readAt => $composableBuilder(
    column: $table.readAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$NotificationsTableOrderingComposer
    extends Composer<_$AppDatabase, $NotificationsTable> {
  $$NotificationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dataJson => $composableBuilder(
    column: $table.dataJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get readAt => $composableBuilder(
    column: $table.readAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$NotificationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $NotificationsTable> {
  $$NotificationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<String> get dataJson =>
      $composableBuilder(column: $table.dataJson, builder: (column) => column);

  GeneratedColumn<DateTime> get readAt =>
      $composableBuilder(column: $table.readAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$NotificationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NotificationsTable,
          NotificationRow,
          $$NotificationsTableFilterComposer,
          $$NotificationsTableOrderingComposer,
          $$NotificationsTableAnnotationComposer,
          $$NotificationsTableCreateCompanionBuilder,
          $$NotificationsTableUpdateCompanionBuilder,
          (
            NotificationRow,
            BaseReferences<_$AppDatabase, $NotificationsTable, NotificationRow>,
          ),
          NotificationRow,
          PrefetchHooks Function()
        > {
  $$NotificationsTableTableManager(_$AppDatabase db, $NotificationsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NotificationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NotificationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NotificationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> serverId = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<String> dataJson = const Value.absent(),
                Value<DateTime?> readAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NotificationsCompanion(
                serverId: serverId,
                type: type,
                title: title,
                body: body,
                dataJson: dataJson,
                readAt: readAt,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String serverId,
                required String type,
                required String title,
                required String body,
                Value<String> dataJson = const Value.absent(),
                Value<DateTime?> readAt = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => NotificationsCompanion.insert(
                serverId: serverId,
                type: type,
                title: title,
                body: body,
                dataJson: dataJson,
                readAt: readAt,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$NotificationsTable, NotificationRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $NotificationsTable,
                    NotificationRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$NotificationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NotificationsTable,
      NotificationRow,
      $$NotificationsTableFilterComposer,
      $$NotificationsTableOrderingComposer,
      $$NotificationsTableAnnotationComposer,
      $$NotificationsTableCreateCompanionBuilder,
      $$NotificationsTableUpdateCompanionBuilder,
      (
        NotificationRow,
        BaseReferences<_$AppDatabase, $NotificationsTable, NotificationRow>,
      ),
      NotificationRow,
      PrefetchHooks Function()
    >;
typedef $$KvSettingsTableCreateCompanionBuilder = KvSettingsCompanion Function({
  required String key,
  required String valueJson,
  Value<int> rowid,
});
typedef $$KvSettingsTableUpdateCompanionBuilder = KvSettingsCompanion Function({
  Value<String> key,
  Value<String> valueJson,
  Value<int> rowid,
});

class $$KvSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $KvSettingsTable> {
  $$KvSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get valueJson => $composableBuilder(
    column: $table.valueJson,
    builder: (column) => ColumnFilters(column),
  );
}

class $$KvSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $KvSettingsTable> {
  $$KvSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get valueJson => $composableBuilder(
    column: $table.valueJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$KvSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $KvSettingsTable> {
  $$KvSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get valueJson =>
      $composableBuilder(column: $table.valueJson, builder: (column) => column);
}

class $$KvSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $KvSettingsTable,
          KvRow,
          $$KvSettingsTableFilterComposer,
          $$KvSettingsTableOrderingComposer,
          $$KvSettingsTableAnnotationComposer,
          $$KvSettingsTableCreateCompanionBuilder,
          $$KvSettingsTableUpdateCompanionBuilder,
          (KvRow, BaseReferences<_$AppDatabase, $KvSettingsTable, KvRow>),
          KvRow,
          PrefetchHooks Function()
        > {
  $$KvSettingsTableTableManager(_$AppDatabase db, $KvSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$KvSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$KvSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$KvSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> valueJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => KvSettingsCompanion(
                key: key,
                valueJson: valueJson,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                required String valueJson,
                Value<int> rowid = const Value.absent(),
              }) => KvSettingsCompanion.insert(
                key: key,
                valueJson: valueJson,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$KvSettingsTable, KvRow>(table),
                  BaseReferences<_$AppDatabase, $KvSettingsTable, KvRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$KvSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $KvSettingsTable,
      KvRow,
      $$KvSettingsTableFilterComposer,
      $$KvSettingsTableOrderingComposer,
      $$KvSettingsTableAnnotationComposer,
      $$KvSettingsTableCreateCompanionBuilder,
      $$KvSettingsTableUpdateCompanionBuilder,
      (KvRow, BaseReferences<_$AppDatabase, $KvSettingsTable, KvRow>),
      KvRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CustomersTableTableManager get customers =>
      $$CustomersTableTableManager(_db, _db.customers);
  $$PlansTableTableManager get plans =>
      $$PlansTableTableManager(_db, _db.plans);
  $$ScheduleLinesTableTableManager get scheduleLines =>
      $$ScheduleLinesTableTableManager(_db, _db.scheduleLines);
  $$ErpPaymentsTableTableManager get erpPayments =>
      $$ErpPaymentsTableTableManager(_db, _db.erpPayments);
  $$LocationProposalsTableTableManager get locationProposals =>
      $$LocationProposalsTableTableManager(_db, _db.locationProposals);
  $$CollectionsTableTableManager get collections =>
      $$CollectionsTableTableManager(_db, _db.collections);
  $$ReceiptBlocksTableTableManager get receiptBlocks =>
      $$ReceiptBlocksTableTableManager(_db, _db.receiptBlocks);
  $$CashPositionsTableTableManager get cashPositions =>
      $$CashPositionsTableTableManager(_db, _db.cashPositions);
  $$DepositsTableTableManager get deposits =>
      $$DepositsTableTableManager(_db, _db.deposits);
  $$CashClosingsTableTableManager get cashClosings =>
      $$CashClosingsTableTableManager(_db, _db.cashClosings);
  $$VisitsTableTableManager get visits =>
      $$VisitsTableTableManager(_db, _db.visits);
  $$NotesTableTableManager get notes =>
      $$NotesTableTableManager(_db, _db.notes);
  $$PromisesTableTableManager get promises =>
      $$PromisesTableTableManager(_db, _db.promises);
  $$TagEventsTableTableManager get tagEvents =>
      $$TagEventsTableTableManager(_db, _db.tagEvents);
  $$AttendanceEventsTableTableManager get attendanceEvents =>
      $$AttendanceEventsTableTableManager(_db, _db.attendanceEvents);
  $$AttendanceDaysTableTableManager get attendanceDays =>
      $$AttendanceDaysTableTableManager(_db, _db.attendanceDays);
  $$HandoversTableTableManager get handovers =>
      $$HandoversTableTableManager(_db, _db.handovers);
  $$MediaQueueTableTableManager get mediaQueue =>
      $$MediaQueueTableTableManager(_db, _db.mediaQueue);
  $$OutboxTableTableManager get outbox =>
      $$OutboxTableTableManager(_db, _db.outbox);
  $$IdMapTableTableManager get idMap =>
      $$IdMapTableTableManager(_db, _db.idMap);
  $$SyncMetaTableTableManager get syncMeta =>
      $$SyncMetaTableTableManager(_db, _db.syncMeta);
  $$LocationQueueTableTableManager get locationQueue =>
      $$LocationQueueTableTableManager(_db, _db.locationQueue);
  $$ContactAttemptsTableTableManager get contactAttempts =>
      $$ContactAttemptsTableTableManager(_db, _db.contactAttempts);
  $$CoworkSessionsTableTableManager get coworkSessions =>
      $$CoworkSessionsTableTableManager(_db, _db.coworkSessions);
  $$BroadcastsTableTableManager get broadcasts =>
      $$BroadcastsTableTableManager(_db, _db.broadcasts);
  $$NotificationsTableTableManager get notifications =>
      $$NotificationsTableTableManager(_db, _db.notifications);
  $$KvSettingsTableTableManager get kvSettings =>
      $$KvSettingsTableTableManager(_db, _db.kvSettings);
}
