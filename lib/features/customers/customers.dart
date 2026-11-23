/// Public barrel of the `customers` feature. Other features import ONLY
/// this file (fos_lints `feature_boundary`).
library;

export 'manifest.dart';
export 'src/customer_providers.dart'
    show customerRepositoryProvider, customerFilterProvider, customerKindFilterProvider, promiseMakersProvider, myCustomerUserIdProvider, multiBranchProvider, allCustomersProvider, branchCustomersProvider, customerProvider, customerPlansProvider, plansPaidTodayProvider, todayPrioritiesProvider, todayProvider, currentFixProvider, selectedBranchIdProvider, branchListProvider;
export 'src/data/customer_repository.dart' show CustomerRepository, PlanWithSchedule;
export 'src/domain/customer.dart' show Customer, TodayPriorities, CustomerFilter, InvoiceKind, InvoiceKinds, prioritize, matchesFilter, matchesKind, inBranch;
export 'src/presentation/customer_detail_screen.dart' show CustomerDetailScreen, launchNavigate, launchCall;
export 'src/presentation/customer_list_screen.dart' show CustomerListScreen, filterLabel;
export 'src/presentation/customer_tile.dart' show CustomerTile;
export 'src/presentation/customer_work_row.dart' show CustomerWorkRow, OpenDetailsArrow;
export 'src/presentation/invoice_kind_label.dart' show InvoiceKindLabel;
export 'src/pin_correction.dart' show openPinCorrection, submitLocationProposal;
export 'src/presentation/map_pin_screen.dart' show MapPinScreen;
