import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/tokens.dart';
import '../../../../l10n/app_localizations.dart';
import '../domain/collection_rules.dart';

/// Brand-neutral glyphs (no third-party logos unless licensed).
IconData methodIcon(PaymentMethod m) => switch (m) {
      PaymentMethod.cash => Icons.payments_rounded,
      PaymentMethod.bkash => Icons.phone_android_rounded,
      PaymentMethod.nagad => Icons.account_balance_wallet_rounded,
      PaymentMethod.rocket => Icons.rocket_launch_rounded,
      PaymentMethod.bankTransfer => Icons.account_balance_rounded,
      PaymentMethod.otherMobile => Icons.more_horiz_rounded,
    };

Color methodColor(PaymentMethod m) => switch (m) {
      PaymentMethod.cash => MethodColors.cash,
      PaymentMethod.bkash => MethodColors.bkash,
      PaymentMethod.nagad => MethodColors.nagad,
      PaymentMethod.rocket => MethodColors.rocket,
      PaymentMethod.bankTransfer => MethodColors.bankTransfer,
      PaymentMethod.otherMobile => MethodColors.otherMobile,
    };

String methodLabel(AppLocalizations l, PaymentMethod m) => switch (m) {
      PaymentMethod.cash => l.collectMethodCash,
      PaymentMethod.bkash => l.collectMethodBkash,
      PaymentMethod.nagad => l.collectMethodNagad,
      PaymentMethod.rocket => l.collectMethodRocket,
      PaymentMethod.bankTransfer => l.collectMethodBank,
      PaymentMethod.otherMobile => l.collectMethodOther,
    };
