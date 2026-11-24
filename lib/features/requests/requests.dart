/// Public barrel of the `requests` feature (staff requests and reports, FR-M-075).
library;

export 'manifest.dart';
export 'src/requests_data.dart' show linkRequestPhotos, requestMediaOwner, requestServiceProvider, requestsProvider, requestsWithNewsProvider;
export 'src/requests_domain.dart';
export 'src/requests_ui.dart' show RequestsScreen, RequestFormScreen, RequestDetailScreen, RequestsMeEntry, requestStatusLabel, requestTypeLabel;
