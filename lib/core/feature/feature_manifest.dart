import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../l10n/app_localizations.dart';
import '../settings/ui_prefs.dart';
import '../sync/sync_handlers.dart';
import '../theme/tag_colors.dart' show ActionTone;

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
  const TodayCardDef({required this.id, required this.order, required this.builder, this.permission, this.alert = false});
  final String id;
  final int order;
  final String? permission;
  final WidgetBuilder builder;

  /// Something is wrong or waiting (tracking stopped, a must-read notice, a sync problem, a handover): Home
  /// shows alerts above the quick actions, the other cards after them (design guide §5.1).
  final bool alert;
}

/// The done / still-to-do mark of a quick action, with its words (attendance: given, or still to give).
class QuickActionState {
  const QuickActionState({required this.done, required this.label});
  final bool done;
  final String label;
}

/// A shortcut on Home (FR-M-083): one cell of the quick-action grid, given by the feature that owns the
/// screen it opens. Home shows the first nine by [order] (six or three when fewer can be used); a feature
/// whose flag is off, or whose [permission] the user lacks, gives none.
class QuickActionDef {
  const QuickActionDef({required this.id, required this.order, required this.icon, required this.tone, required this.label, required this.route, this.permission, this.visible, this.badge, this.state});
  final String id;
  final int order;
  final String? permission;

  /// Extra condition from server data; null = always, once flag and permission allow.
  final bool Function(WidgetRef ref)? visible;
  final IconData icon;

  /// The tonal container of the icon (tokens `action.*`).
  final ActionTone tone;
  final String Function(AppLocalizations l) label;
  final String route;

  /// How many things wait behind it (unread notices, open tasks); 0 shows no badge.
  final int Function(WidgetRef ref)? badge;
  final QuickActionState? Function(WidgetRef ref, AppLocalizations l)? state;
}

/// The sections of the Settings screen (FR-M-084), in display order.
enum SettingsSection { account, work, locationBattery, display, privacy, about }

/// A row a feature adds to Settings: icon, title, one-line hint, current value, and where a tap goes.
class SettingsRowDef {
  const SettingsRowDef({required this.id, required this.section, required this.order, required this.icon, required this.title, this.tone = ActionTone.brand, this.hint, this.value, this.route, this.permission, this.visible});
  final String id;
  final SettingsSection section;
  final int order;
  final String? permission;
  final bool Function(WidgetRef ref)? visible;
  final IconData icon;
  final ActionTone tone;
  final String Function(AppLocalizations l) title;
  final String Function(AppLocalizations l)? hint;

  /// The current value in words, from the feature's own providers (so it stays live).
  final String? Function(WidgetRef ref, AppLocalizations l, Fmt f)? value;
  final String? route;
}

/// An entry in the Me tab.
class MeEntryDef {
  const MeEntryDef({required this.id, required this.order, required this.builder, this.permission, this.visible});
  final String id;
  final int order;
  final String? permission;

  /// Extra condition from server data (e.g. an admin setting); null = always, once flag and permission allow.
  final bool Function(WidgetRef ref)? visible;
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

  /// The entry's own page (a task, a receipt); a tap goes here first, else to
  /// the customer.
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

/// What an alert is about (its icon colour).
enum AlertKind { promise, task, cowork, notice, handover }

/// Something that waits for the signed-in user (FR-M-044): a promise due
/// today, a new task, a co-work request, an unread notice, a handover.
/// Shown on the alerts screen behind the bell; the bell counts them.
class AppAlert {
  const AppAlert({required this.id, required this.kind, required this.icon, required this.title, this.subtitle, this.route, this.customerId});
  final String id;
  final AlertKind kind;
  final IconData icon;

  /// Built when shown, so it follows the language and the digit style.
  final String Function(AppLocalizations l, Fmt f) title;
  final String Function(AppLocalizations l, Fmt f)? subtitle;

  /// Where a tap goes; a [customerId] opens that customer instead.
  final String? route;
  final String? customerId;
}

/// Extension point: a feature lists what waits for the user, from its own
/// providers (it may `watch` them through [ref], so the list stays live).
class AlertSourceDef {
  const AlertSourceDef({required this.id, required this.read});
  final String id;
  final List<AppAlert> Function(Ref ref) read;
}

/// How a map uses a feature's layer.
enum MapLayerMode {
  /// A working map (the customer map): markers may be tapped.
  interactive,

  /// Landmarks for reference only (e.g. the pin-setting screen): nothing is
  /// tappable, every touch goes to the map underneath.
  reference,
}

/// Extension point: a layer a feature draws on every map of the app (e.g. map
/// places, FR-PLC-001): the customer map, the pin-setting screen, and any
/// other map. [layer] returns a flutter_map layer widget (it may watch
/// providers through [WidgetRef] and the camera through `MapCamera.of`, so it
/// stays live and works offline); [onLongPress] is offered a long press on an
/// interactive map (the first layer that has one takes it). Maps never read
/// the feature's tables themselves; they list layers via `mapLayersProvider`.
class MapLayerDef {
  const MapLayerDef({required this.id, required this.layer, this.permission, this.onLongPress});
  final String id;
  final String? permission;
  final Widget Function(BuildContext context, WidgetRef ref, MapLayerMode mode) layer;
  final void Function(BuildContext context, WidgetRef ref, double lat, double lng)? onLongPress;
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
    this.alertSources = const [],
    this.mapLayers = const [],
    this.quickActions = const [],
    this.settingsRows = const [],
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
  final List<AlertSourceDef> alertSources;
  final List<MapLayerDef> mapLayers;
  final List<QuickActionDef> quickActions;
  final List<SettingsRowDef> settingsRows;
}

/// The registered manifests (overridden at bootstrap from
/// `lib/app/features.dart`). Read by shells / screens that render
/// extension points.
final featureManifestsProvider = Provider<List<FeatureManifest>>((ref) => const []);

/// Everything that waits for the user, from every feature (the bell's count
/// and the alerts screen).
final alertsProvider = Provider<List<AppAlert>>((ref) => [
      for (final m in ref.watch(featureManifestsProvider))
        for (final s in m.alertSources) ...s.read(ref),
    ]);
