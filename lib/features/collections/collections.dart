/// Public barrel of the `collections` feature.
library;

export 'manifest.dart';
export 'src/collection_providers.dart' show todayTotalsProvider, todayCollectionsProvider, collectionProblemsProvider, recordCollectionProvider;
export 'src/data/collection_repository.dart' show DayTotals;
export 'src/domain/collection_rules.dart' show PaymentMethod, cashState, CashState;
export 'src/presentation/method_visuals.dart' show methodIcon, methodLabel, methodColor;
