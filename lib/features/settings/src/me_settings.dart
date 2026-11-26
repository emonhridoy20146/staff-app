import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/feature/feature_manifest.dart';
import '../../../core/format/digits.dart';
import '../../../core/permissions/permission_service.dart';
import '../../../core/providers.dart';
import '../../../core/settings/ui_prefs.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/status_colors.dart';
import '../../../core/theme/tag_colors.dart';
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
                subtitle: Text(l.settingsMeHint),
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

/// What a role is called (contract `Role`); one this app does not know shows as its key.
String roleLabel(AppLocalizations l, String role) => switch (role) {
      'field_staff' => l.roleFieldStaff,
      'branch_manager' => l.roleBranchManager,
      'area_manager' => l.roleAreaManager,
      'super_admin' => l.roleSuperAdmin,
      'viewer' => l.roleViewer,
      _ => role,
    };

/// Settings (FR-M-084, design guide §5.7, v2 2026-11-26): six sections (Account, Work, Location & battery,
/// Display & language, Privacy, Help & about) of uniform rows: icon, title, one-line hint, current value.
/// A choice opens a sheet of radio rows and applies at once. Features add their rows through the manifest
/// (`settingsRows`), so a module that is off leaves none. Local only: no pull to refresh.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final p = ref.watch(uiPrefsProvider);
    final ctrl = ref.read(uiPrefsProvider.notifier);
    final device = ref.watch(deviceIdentityProvider);
    final f = ref.watch(fmtProvider);
    final access = ref.watch(accessProvider);
    final user = ref.watch(sessionProvider).user;
    final lang = Localizations.localeOf(context).languageCode;
    final given = [
      for (final m in ref.watch(featureManifestsProvider))
        if (access.flag(m.flag))
          for (final r in m.settingsRows)
            if ((r.permission == null || access.can(r.permission!)) && (r.visible?.call(ref) ?? true)) r,
    ]..sort((a, b) => a.order.compareTo(b.order));
    List<Widget> from(SettingsSection s) => [
          for (final r in given)
            if (r.section == s)
              _SettingsRow(
                key: ValueKey('settings-${r.id}'),
                icon: r.icon,
                tone: r.tone,
                title: r.title(l),
                hint: r.hint?.call(l),
                value: r.value?.call(ref, l, f),
                onTap: r.route == null ? null : () => context.push(r.route!),
              ),
        ];
    final languages = {'bn': l.settingsLanguageBn, 'en': l.settingsLanguageEn};
    final digits = {DigitStyle.bangla: l.settingsDigitsBn, DigitStyle.latin: l.settingsDigitsEn};
    final themes = {ThemeMode.system: l.settingsThemeSystem, ThemeMode.light: l.settingsThemeLight, ThemeMode.dark: l.settingsThemeDark};

    final sections = <(String, List<Widget>)>[
      (
        l.settingsSectionAccount,
        [
          if (user != null)
            _SettingsRow(
              key: const ValueKey('settings-profile'),
              icon: Icons.person_rounded,
              title: user.name.of(lang),
              hint: [if (user.employeeCode.isNotEmpty) l.meStaffCode(user.employeeCode), roleLabel(l, user.role)].join(' · '),
            ),
          ...from(SettingsSection.account),
          _SettingsRow(
            key: const ValueKey('settings-logout'),
            icon: Icons.logout_rounded,
            danger: true,
            title: l.meLogout,
            hint: l.settingsLogoutHint,
            onTap: () => confirmLogout(context, ref),
          ),
        ],
      ),
      (l.settingsSectionWork, from(SettingsSection.work)),
      (l.settingsSectionLocation, from(SettingsSection.locationBattery)),
      (
        l.settingsSectionDisplay,
        [
          _SettingsRow(
            key: const ValueKey('settings-language'),
            icon: Icons.translate_rounded,
            tone: ActionTone.teal,
            title: l.settingsLanguage,
            hint: l.settingsLanguageHint,
            value: languages[p.language] ?? p.language,
            onTap: () => _pickOne<String>(context, title: l.settingsLanguage, current: p.language, options: languages, onPick: (v) => ctrl.update(p.copyWith(language: v))),
          ),
          _SettingsRow(
            key: const ValueKey('settings-digits'),
            icon: Icons.pin_rounded,
            tone: ActionTone.violet,
            title: l.settingsDigits,
            hint: l.settingsDigitsHint,
            value: digits[p.digits],
            onTap: () => _pickOne<DigitStyle>(context, title: l.settingsDigits, current: p.digits, options: digits, onPick: (v) => ctrl.update(p.copyWith(digits: v))),
          ),
          _SettingsRow(
            key: const ValueKey('settings-theme'),
            icon: Icons.dark_mode_rounded,
            title: l.settingsTheme,
            hint: l.settingsThemeHint,
            value: themes[p.themeMode],
            onTap: () => _pickOne<ThemeMode>(context, title: l.settingsTheme, current: p.themeMode, options: themes, onPick: (v) => ctrl.update(p.copyWith(themeMode: v))),
          ),
          _SettingsRow(
            key: const ValueKey('settings-contrast'),
            icon: Icons.wb_sunny_rounded,
            tone: ActionTone.amber,
            title: l.settingsHighContrastTitle,
            hint: l.settingsHighContrastHint,
            toggle: p.highContrast,
            onToggle: (v) => ctrl.update(p.copyWith(highContrast: v)),
          ),
          ...from(SettingsSection.display),
        ],
      ),
      (
        l.settingsSectionPrivacy,
        [
          _SettingsRow(
            key: const ValueKey('settings-privacy'),
            icon: Icons.privacy_tip_rounded,
            tone: ActionTone.violet,
            title: l.settingsPrivacy,
            hint: l.consentTitle,
            onTap: () => _showPrivacy(context),
          ),
          ...from(SettingsSection.privacy),
        ],
      ),
      (
        l.settingsSectionAbout,
        [
          ...from(SettingsSection.about),
          _SettingsRow(key: const ValueKey('settings-version'), icon: Icons.info_rounded, title: l.settingsAbout, hint: l.appName, value: f.num(device.appVersion)),
          _SettingsRow(
            key: const ValueKey('settings-device'),
            icon: Icons.phone_android_rounded,
            tone: ActionTone.teal,
            title: l.settingsDeviceTitle,
            hint: l.settingsDeviceHint,
            value: device.deviceId.substring(0, device.deviceId.length.clamp(0, 8)),
            mono: true,
          ),
          _SettingsRow(
            key: const ValueKey('settings-server'),
            icon: Icons.dns_rounded,
            tone: ActionTone.green,
            title: l.settingsServerTitle,
            hint: l.settingsServerHint,
            value: ref.watch(envProvider).isDemo ? l.settingsServerDemo : l.settingsServerLive,
          ),
        ],
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(l.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(Space.screen, Space.s4, Space.screen, Space.s32),
        children: [
          for (final (title, rows) in sections)
            if (rows.isNotEmpty) _SettingsGroup(title: title, rows: rows),
        ],
      ),
    );
  }
}

/// One titled section: its rows in one card, a hairline between them (starting after the icon).
class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.title, required this.rows});
  final String title;
  final List<Widget> rows;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: Space.s20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(Space.s4, Space.s8, Space.s4, Space.s8),
          child: Semantics(header: true, child: Text(title, style: t.titleSmall!.copyWith(color: cs.onSurfaceVariant))),
        ),
        Card(
          clipBehavior: Clip.antiAlias,
          child: Column(children: [
            for (var i = 0; i < rows.length; i++) ...[
              if (i > 0) const Divider(height: 1, indent: Space.s16 + Space.s40 + Space.s12),
              rows[i],
            ],
          ]),
        ),
      ]),
    );
  }
}

/// A settings row: the icon in a tonal square (`action.*`), the title, a one-line hint, the current value and
/// a chevron when it opens something; or a switch. 64 dp at least. [danger] is the sign-out look.
class _SettingsRow extends StatelessWidget {
  const _SettingsRow({super.key, required this.icon, required this.title, this.tone = ActionTone.brand, this.hint, this.value, this.onTap, this.toggle, this.onToggle, this.danger = false, this.mono = false});
  final IconData icon;
  final ActionTone tone;
  final String title;
  final String? hint;
  final String? value;
  final VoidCallback? onTap;
  final bool? toggle;
  final ValueChanged<bool>? onToggle;
  final bool danger;
  final bool mono;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final tones = danger ? StatusStyle(fg: cs.error, bg: cs.errorContainer) : context.actionColors.of(tone);
    final row = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: Space.s64),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Space.s16, vertical: Space.s12),
        child: Row(children: [
          Container(
            width: Space.s40,
            height: Space.s40,
            decoration: BoxDecoration(color: tones.bg, borderRadius: Radii.brLg),
            child: Icon(icon, size: 22, color: tones.fg),
          ),
          const SizedBox(width: Space.s12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
              Text(title, style: t.titleSmall!.copyWith(color: danger ? cs.error : null)),
              if (hint != null && hint!.isNotEmpty) Text(hint!, style: t.bodyMedium!.copyWith(color: cs.onSurfaceVariant)),
            ]),
          ),
          if (value != null) ...[
            const SizedBox(width: Space.s8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: Space.s64 * 2),
              child: Text(
                value!,
                style: (mono ? AppTheme.mono(t.labelLarge!) : AppTheme.tabular(t.labelLarge!)).copyWith(color: cs.onSurfaceVariant),
                textAlign: TextAlign.end,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
          if (toggle != null)
            Padding(padding: const EdgeInsets.only(left: Space.s8), child: Switch(value: toggle!, onChanged: onToggle))
          else if (onTap != null)
            Padding(padding: const EdgeInsets.only(left: Space.s4), child: Icon(Icons.chevron_right_rounded, color: cs.onSurfaceVariant)),
        ]),
      ),
    );
    if (toggle != null) return MergeSemantics(child: InkWell(onTap: () => onToggle?.call(!toggle!), child: row));
    return onTap == null ? row : InkWell(onTap: onTap, child: row);
  }
}

/// A choice of a settings row: a sheet of radio rows; a tap applies it and closes the sheet.
Future<void> _pickOne<T>(BuildContext context, {required String title, required T current, required Map<T, String> options, required ValueChanged<T> onPick}) =>
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      builder: (sheet) {
        final t = Theme.of(sheet).textTheme;
        final cs = Theme.of(sheet).colorScheme;
        return SafeArea(
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Padding(padding: const EdgeInsets.fromLTRB(Space.s24, 0, Space.s24, Space.s8), child: Text(title, style: t.titleLarge)),
            for (final e in options.entries)
              ListTile(
                key: ValueKey('settings-option-${e.key}'),
                minTileHeight: Sizes.primaryButton,
                leading: Icon(e.key == current ? Icons.radio_button_checked_rounded : Icons.radio_button_unchecked_rounded, color: e.key == current ? cs.primary : cs.outline),
                title: Text(e.value, style: t.bodyLarge),
                onTap: () {
                  Navigator.of(sheet).pop();
                  onPick(e.key);
                },
              ),
            const SizedBox(height: Space.s8),
          ]),
        );
      },
    );

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
