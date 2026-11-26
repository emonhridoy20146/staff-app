import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/feature/feature_manifest.dart';
import '../../../core/format/digits.dart';
import '../../../core/permissions/permission_service.dart';
import '../../../core/providers.dart';
import '../../../core/settings/ui_prefs.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/ui/refreshable.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/auth.dart';

/// Me tab: profile, feature entries (attendance, cash, handovers, sync),
/// settings and sign-out (FR-M-011, FR-M-016).
class MeScreen extends ConsumerWidget {
  const MeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final lang = Localizations.localeOf(context).languageCode;
    final user = ref.watch(sessionProvider).user;
    final access = ref.watch(accessProvider);
    final entries = [
      for (final m in ref.watch(featureManifestsProvider))
        if (access.flag(m.flag))
          for (final e in m.meEntries)
            if ((e.permission == null || access.can(e.permission!)) && (e.visible?.call(ref) ?? true)) e,
    ]..sort((a, b) => a.order.compareTo(b.order));
    final name = user?.name.of(lang) ?? '';

    return Scaffold(
      backgroundColor: cs.surfaceContainerLowest,
      // Pull down: a sync refreshes what the Me entries show (cash, attendance, tasks, notices…).
      body: PullToRefresh(
        child: CustomScrollView(physics: const AlwaysScrollableScrollPhysics(), slivers: [
        SliverAppBar(pinned: true, backgroundColor: cs.surfaceContainer, title: Text(l.meTitle)),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(Space.screen, Space.s16, Space.screen, Space.s32),
          sliver: SliverList.list(children: [
            Row(children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: cs.primary,
                foregroundColor: cs.onPrimary,
                child: Text(name.isEmpty ? '?' : name.characters.first, style: t.headlineSmall!.copyWith(color: cs.onPrimary)),
              ),
              const SizedBox(width: Space.s16),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(name, style: t.titleLarge),
                  if (user != null && user.employeeCode.isNotEmpty) Text(l.meStaffCode(user.employeeCode), style: t.bodyMedium!.copyWith(color: cs.onSurfaceVariant)),
                ]),
              ),
            ]),
            const SizedBox(height: Space.s20),
            for (final e in entries) ...[e.builder(context), const SizedBox(height: Space.cardGap)],
            Card(
              child: ListTile(
                minTileHeight: 64,
                leading: const Icon(Icons.settings_rounded),
                title: Text(l.meSettings),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => context.push('/settings'),
              ),
            ),
            const SizedBox(height: Space.s24),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(foregroundColor: cs.error, side: BorderSide(color: cs.error.withValues(alpha: 0.5))),
              onPressed: () => confirmLogout(context, ref),
              icon: const Icon(Icons.logout_rounded),
              label: Text(l.meLogout),
            ),
          ]),
        ),
      ]),
      ),
    );
  }
}

/// Sign-out is blocked while anything (outbox or photos) is unsent.
Future<void> confirmLogout(BuildContext context, WidgetRef ref) async {
  final l = AppLocalizations.of(context);
  final f = ref.read(fmtProvider);
  final unsynced = await ref.read(outboxReaderProvider).unsyncedCount();
  if (!context.mounted) return;
  if (unsynced > 0) {
    await showDialog<void>(
      context: context,
      builder: (d) => AlertDialog(
        icon: const Icon(Icons.cloud_upload_rounded),
        title: Text(l.logoutTitle),
        content: Text(l.logoutBlocked(f.num(unsynced))),
        actions: [
          TextButton(onPressed: () => Navigator.of(d).pop(), child: Text(l.actionCancel)),
          FilledButton(
            onPressed: () {
              Navigator.of(d).pop();
              ref.read(syncEngineProvider).syncNow();
            },
            child: Text(l.actionSyncNow),
          ),
        ],
      ),
    );
    return;
  }
  final ok = await showDialog<bool>(
    context: context,
    builder: (d) => AlertDialog(
      title: Text(l.logoutTitle),
      content: Text(l.logoutConfirm),
      actions: [
        TextButton(onPressed: () => Navigator.of(d).pop(false), child: Text(l.actionCancel)),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: Theme.of(d).colorScheme.error),
          onPressed: () => Navigator.of(d).pop(true),
          child: Text(l.logoutButton),
        ),
      ],
    ),
  );
  if (ok == true) {
    try {
      await ref.read(sessionProvider.notifier).logout();
    } on StateError {
      // Something was saved between the check and now: keep everything.
    }
  }
}

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final p = ref.watch(uiPrefsProvider);
    final ctrl = ref.read(uiPrefsProvider.notifier);
    final device = ref.watch(deviceIdentityProvider);
    final f = ref.watch(fmtProvider);

    Widget group(String title, Widget child) => Padding(
          padding: const EdgeInsets.only(bottom: Space.s20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text(title, style: t.titleSmall),
            const SizedBox(height: Space.s8),
            child,
          ]),
        );

    return Scaffold(
      appBar: AppBar(title: Text(l.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(Space.screen),
        children: [
          group(
            l.settingsLanguage,
            SegmentedButton<String>(
              segments: [ButtonSegment(value: 'bn', label: Text(l.settingsLanguageBn)), ButtonSegment(value: 'en', label: Text(l.settingsLanguageEn))],
              selected: {p.language},
              onSelectionChanged: (s) => ctrl.update(p.copyWith(language: s.first)),
            ),
          ),
          group(
            l.settingsDigits,
            SegmentedButton<DigitStyle>(
              segments: [
                ButtonSegment(value: DigitStyle.bangla, label: Text(l.settingsDigitsBn)),
                ButtonSegment(value: DigitStyle.latin, label: Text(l.settingsDigitsEn)),
              ],
              selected: {p.digits},
              onSelectionChanged: (s) => ctrl.update(p.copyWith(digits: s.first)),
            ),
          ),
          group(
            l.settingsTheme,
            SegmentedButton<ThemeMode>(
              segments: [
                ButtonSegment(value: ThemeMode.system, label: Text(l.settingsThemeSystem)),
                ButtonSegment(value: ThemeMode.light, label: Text(l.settingsThemeLight)),
                ButtonSegment(value: ThemeMode.dark, label: Text(l.settingsThemeDark)),
              ],
              selected: {p.themeMode},
              onSelectionChanged: (s) => ctrl.update(p.copyWith(themeMode: s.first)),
            ),
          ),
          Card(
            child: SwitchListTile(
              secondary: const Icon(Icons.wb_sunny_rounded),
              title: Text(l.settingsHighContrast),
              value: p.highContrast,
              onChanged: (v) => ctrl.update(p.copyWith(highContrast: v)),
            ),
          ),
          const SizedBox(height: Space.s12),
          Card(
            child: Column(children: [
              ListTile(
                leading: const Icon(Icons.privacy_tip_rounded),
                title: Text(l.settingsPrivacy),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => _showPrivacy(context),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.info_rounded),
                title: Text(l.settingsAbout),
                subtitle: Text('${l.settingsVersion(f.num(device.appVersion))}\n${l.settingsDevice(device.deviceId.substring(0, device.deviceId.length.clamp(0, 8)))}'),
                isThreeLine: true,
              ),
            ]),
          ),
          const SizedBox(height: Space.s12),
          Text(l.appName, textAlign: TextAlign.center, style: t.bodySmall!.copyWith(color: cs.onSurfaceVariant)),
        ],
      ),
    );
  }
}

void _showPrivacy(BuildContext context) {
  final l = AppLocalizations.of(context);
  final t = Theme.of(context).textTheme;
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      builder: (_, sc) => ListView(
        controller: sc,
        padding: const EdgeInsets.all(Space.s24),
        children: [
          Text(l.consentTitle, style: t.titleLarge),
          const SizedBox(height: Space.s12),
          for (final s in [l.consentIntro, l.consentDutyOnly, l.consentWhy, l.consentVisible, l.consentPhotos, l.consentRetention])
            Padding(padding: const EdgeInsets.only(bottom: Space.s12), child: Text(s, style: t.bodyLarge)),
        ],
      ),
    ),
  );
}
