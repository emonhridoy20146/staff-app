/// Public barrel of the `cowork` feature. Other features import ONLY this
/// file (fos_lints `feature_boundary`).
library;

export 'manifest.dart';
export 'src/cowork_data.dart' show coworkForVisitProvider, coworkSessionsProvider, myUserIdProvider, coworkTodayProvider;
export 'src/cowork_domain.dart' show CoworkSession, CoworkMember, CoworkToday;
export 'src/cowork_widgets.dart' show CoworkVisitSwitch, CoworkChip, coworkNamesProvider;
