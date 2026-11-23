/// Public barrel of the `prospects` feature (possible customers, FR-M-073).
library;

export 'manifest.dart';
export 'src/prospects_data.dart' show Prospect, ProspectDraft, ProspectError, ProspectInvalid, prospectServiceProvider, prospectsProvider, validateProspect;
export 'src/prospects_ui.dart' show ProspectsScreen, ProspectFormScreen, ProspectsMeEntry, prospectStatusLabel;
