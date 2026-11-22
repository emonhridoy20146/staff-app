/// Public barrel of the `collections` feature.
library;

export 'manifest.dart';
export 'src/collection_providers.dart' show todayTotalsProvider, todayCollectionsProvider, collectionProblemsProvider, recordCollectionProvider, nonCashInHandProvider, depositLockedIdsProvider, collectionRepositoryProvider;
export 'src/data/collection_repository.dart' show DayTotals, CollectionRepository;
export 'src/domain/collection_rules.dart' show PaymentMethod, PaymentMethodX, cashState, CashState, isInHand, isLockedByDeposit, inHandStatuses;
export 'src/presentation/method_visuals.dart' show methodIcon, methodLabel, methodColor;
