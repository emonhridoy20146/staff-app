import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../sync/sync_handlers.dart';

/// Context passed to customer-action builders (extension point).
class CustomerActionContext {
  const CustomerActionContext({required this.customerId, required this.customerName});
  final String customerId;
  final String customerName;
}

/// A button on customer detail contributed by a feature.
class CustomerActionDef {
  const CustomerActionDef({
    required this.id,
    required this.order,
    required this.permission,
    required this.icon,
    required this.label,
    required this.onTap,
    this.primary = false,
  });
  final String id;
  final int order;
  final String permission;
  final IconData icon;
  final String Function(BuildContext) label;
  final void Function(BuildContext, WidgetRef, CustomerActionContext) onTap;

  /// Shown as the filled primary action (only "Collect").
  final bool primary;
}

/// A card on the Today screen contributed by a feature.
class TodayCardDef {
  const TodayCardDef({required this.id, required this.order, required this.builder, this.permission});
  final String id;
  final int order;
  final String? permission;
  final WidgetBuilder builder;
}

/// An entry in the Me tab.
class MeEntryDef {
  const MeEntryDef({required this.id, required this.order, required this.builder, this.permission});
  final String id;
  final int order;
  final String? permission;
  final WidgetBuilder builder;
}

/// One item on the customer timeline, contributed by any feature.
class TimelineEntry {
  const TimelineEntry({required this.at, required this.icon, required this.title, this.subtitle, this.trailing, this.statusChip});
  final DateTime at;
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Widget? statusChip;
}

/// Extension point: a feature contributes timeline items for a customer.
class TimelineSourceDef {
  const TimelineSourceDef({required this.id, required this.watch});
  final String id;
  final Stream<List<TimelineEntry>> Function(BuildContext context, WidgetRef ref, String customerId) watch;
}

/// What kind of work a work-log entry is (its colour and the day's counts).
enum WorkKind { visit, collection, promise, note, pin, task, call }

/// One thing the signed-in user did on a day (FR-M-041), contributed by the
/// feature that owns it.
class WorkLogEntry {
  const WorkLogEntry({required this.at, required this.kind, required this.icon, required this.title, this.subtitle, this.customerId, this.route, this.amountPoisha, this.pending = false});
  final DateTime at;
  final WorkKind kind;
  final IconData icon;
  final String title;
  final String? subtitle;

  /// The customer it was done for; a tap opens that customer.
  final String? customerId;

  /// Where a tap goes when there is no customer (a task).
  final String? route;

  /// Money of a collection.
  final int? amountPoisha;

  /// Saved here or on the server but not final yet (money not in the ERP).
  final bool pending;
}

/// Extension point: a feature lists the user's own work of one Dhaka
/// business day. The Today's Work screen merges every source; it never
/// reads another feature's tables itself.
class WorkLogSourceDef {
  const WorkLogSourceDef({required this.id, required this.watch});
  final String id;
  final Stream<List<WorkLogEntry>> Function(BuildContext context, WidgetRef ref, String businessDate) watch;
}

/// Feature module manifest (04-architecture §3). Each feature folder
/// `lib/features/<name>/` exports exactly one manifest from its barrel and
/// is listed once in `lib/app/features.dart`.
class FeatureManifest {
  const FeatureManifest({
    required this.name,
    this.flag,
    this.permissions = const [],
    this.routes = const [],
    this.pullHandlers = const [],
    this.pushHandlers = const [],
    this.customerActions = const [],
    this.todayCards = const [],
    this.meEntries = const [],
    this.timelineSources = const [],
    this.workLogSources = const [],
  });

  final String name;

  /// e.g. `module.collections` — default OFF until the server says ON.
  final String? flag;

  /// Keys this feature checks (must exist in the master catalog).
  final List<String> permissions;
  final List<RouteBase> routes;
  final List<PullHandler> pullHandlers;
  final List<PushResultHandler> pushHandlers;
  final List<CustomerActionDef> customerActions;
  final List<TodayCardDef> todayCards;
  final List<MeEntryDef> meEntries;
  final List<TimelineSourceDef> timelineSources;
  final List<WorkLogSourceDef> workLogSources;
}

/// The registered manifests (overridden at bootstrap from
/// `lib/app/features.dart`). Read by shells / screens that render
/// extension points.
final featureManifestsProvider = Provider<List<FeatureManifest>>((ref) => const []);
