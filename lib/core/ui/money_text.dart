import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../settings/ui_prefs.dart';
import '../theme/app_theme.dart';

/// Money with tabular figures, `৳` prefix and South-Asian grouping.
/// Neutral colour — status is conveyed by badges, never by red amounts.
/// TalkBack reads the amount in words.
class MoneyText extends ConsumerWidget {
  const MoneyText(this.poisha, {super.key, this.style, this.color, this.textAlign});
  final int poisha;
  final TextStyle? style;
  final Color? color;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final f = ref.watch(fmtProvider);
    final base = style ?? Theme.of(context).textTheme.titleMedium!;
    return Semantics(
      label: f.words(poisha),
      excludeSemantics: true,
      child: Text(
        f.money(poisha),
        textAlign: textAlign,
        maxLines: 1,
        softWrap: false,
        overflow: TextOverflow.visible,
        style: AppTheme.tabular(base).copyWith(color: color),
      ),
    );
  }
}
