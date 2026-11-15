import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/tokens.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../customers/customers.dart';

/// Collect FAB without a customer → pick one (priorities first).
class CustomerPickerScreen extends ConsumerStatefulWidget {
  const CustomerPickerScreen({super.key});
  @override
  ConsumerState<CustomerPickerScreen> createState() => _CustomerPickerScreenState();
}

class _CustomerPickerScreenState extends ConsumerState<CustomerPickerScreen> {
  String _q = '';

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final all = ref.watch(allCustomersProvider).value ?? const <Customer>[];
    final today = ref.watch(todayProvider);
    final p = prioritize(all, today);
    final ordered = [...p.promised, ...p.due, ...p.overdue, ...all.where((c) => !p.promised.contains(c) && !p.due.contains(c) && !p.overdue.contains(c))];
    final q = _q.trim().toLowerCase();
    final items = q.isEmpty ? ordered : ordered.where((c) => c.row.searchText.contains(q)).toList();
    return Scaffold(
      appBar: AppBar(title: Text(l.collectTitle)),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(Space.screen, 0, Space.screen, Space.s8),
          child: TextField(
            autofocus: true,
            onChanged: (v) => setState(() => _q = v),
            decoration: InputDecoration(hintText: l.customersSearch, prefixIcon: const Icon(Icons.search_rounded)),
          ),
        ),
        Expanded(
          child: ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, _) => const Divider(indent: 76, height: 1),
            itemBuilder: (_, i) => CustomerTile(customer: items[i], onTap: () => context.pushReplacement('/collect/${items[i].id}')),
          ),
        ),
      ]),
    );
  }
}
