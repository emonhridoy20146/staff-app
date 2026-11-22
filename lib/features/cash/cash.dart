/// Public barrel of the `cash` feature.
library;

export 'manifest.dart';
export 'src/record_deposit.dart' show linkDepositSlip, depositSlipKind;
export 'src/cash.dart' show CashMeter, CashCard, showDepositSheet, depositByClientIdProvider, depositFailureText;
