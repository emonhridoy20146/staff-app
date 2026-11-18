/// Public barrel of the `customers` feature. Other features import ONLY
/// this file (fos_lints `feature_boundary`).
library;

export 'manifest.dart';
export 'src/customer_providers.dart'
    show customerRepositoryProvider, customerFilterProvider, allCustomersProvider, customerProvider, customerPlansProvider, plansPaidTodayProvider, todayPrioritiesProvider, todayProvider, currentFixProvider;
export 'src/data/customer_repository.dart' show CustomerRepository, PlanWithSchedule;
export 'src/domain/customer.dart' show Customer, TodayPriorities, CustomerFilter, prioritize, matchesFilter;
export 'src/presentation/customer_detail_screen.dart' show CustomerDetailScreen, launchNavigate, launchCall;
export 'src/presentation/customer_list_screen.dart' show CustomerListScreen, filterLabel;
export 'src/presentation/customer_tile.dart' show CustomerTile;
export 'src/pin_correction.dart' show openPinCorrection, submitLocationProposal;
export 'src/presentation/map_pin_screen.dart' show MapPinScreen;
