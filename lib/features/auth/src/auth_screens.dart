import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/api/field_api.dart';
import '../../../core/auth/pin.dart';
import '../../../core/format/digits.dart';
import '../../../core/providers.dart';
import '../../../core/settings/ui_prefs.dart';
import '../../../core/time/clock.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/ui/amount_keypad.dart';
import '../../../core/ui/brand.dart';
import '../../../core/ui/common.dart';
import '../../../l10n/app_localizations.dart';
import 'session_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _phone = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;
  bool _busy = false;
  LoginFailure? _failure;

  @override
  void dispose() {
    _phone.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _busy = true;
      _failure = null;
    });
    try {
      await ref.read(sessionProvider.notifier).login(toLatinDigits(_phone.text), _password.text);
    } on LoginFailure catch (f) {
      if (mounted) setState(() => _failure = f);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final s = ref.watch(sessionProvider);
    final demo = ref.watch(envProvider).isDemo;
    return Scaffold(
      backgroundColor: cs.surface,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            BrandHero(title: l.appName, subtitle: l.appTagline, height: 300),
            Padding(
              padding: const EdgeInsets.fromLTRB(Space.s24, Space.s24, Space.s24, Space.s32),
              child: AutofillGroup(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(l.loginTitle, style: t.headlineSmall),
                    const SizedBox(height: Space.s4),
                    Text(l.loginSubtitle, style: t.bodyMedium!.copyWith(color: cs.onSurfaceVariant)),
                    if (s.lockedOut) ...[
                      const SizedBox(height: Space.s16),
                      InfoBanner(icon: Icons.lock_clock_rounded, text: l.pinLockedOut, tone: BannerTone.warning),
                    ],
                    const SizedBox(height: Space.s24),
                    TextField(
                      controller: _phone,
                      keyboardType: TextInputType.phone,
                      autofillHints: const [AutofillHints.telephoneNumber],
                      textInputAction: TextInputAction.next,
                      style: t.bodyLarge,
                      decoration: InputDecoration(labelText: l.loginPhone, prefixIcon: const Icon(Icons.phone_iphone_rounded)),
                    ),
                    const SizedBox(height: Space.s16),
                    TextField(
                      controller: _password,
                      obscureText: _obscure,
                      autofillHints: const [AutofillHints.password],
                      onSubmitted: (_) => _submit(),
                      style: t.bodyLarge,
                      decoration: InputDecoration(
                        labelText: l.loginPassword,
                        prefixIcon: const Icon(Icons.key_rounded),
                        suffixIcon: IconButton(
                          tooltip: _obscure ? l.showPassword : l.hidePassword,
                          icon: Icon(_obscure ? Icons.visibility_rounded : Icons.visibility_off_rounded),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                      ),
                    ),
                    if (_failure case final f?) ...[
                      const SizedBox(height: Space.s16),
                      InfoBanner(
                        key: const ValueKey('login-failure'),
                        icon: f.error == LoginError.deviceNotApproved ? Icons.hourglass_top_rounded : Icons.error_outline_rounded,
                        text: loginFailureText(f, l, ref.read(fmtProvider), ref.read(clockProvider)),
                        // A new phone waiting for the office is a normal step, not an error.
                        tone: f.error == LoginError.deviceNotApproved ? BannerTone.info : BannerTone.danger,
                      ),
                      if (f.error == LoginError.deviceNotApproved) ...[
                        const SizedBox(height: Space.s8),
                        OutlinedButton.icon(
                          onPressed: _busy ? null : _submit,
                          icon: const Icon(Icons.refresh_rounded),
                          label: Text(l.loginRetry),
                        ),
                      ],
                    ],
                    const SizedBox(height: Space.s24),
                    FilledButton(
                      onPressed: _busy ? null : _submit,
                      child: _busy
                          ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5))
                          : Text(l.loginButton),
                    ),
                    if (demo) ...[
                      const SizedBox(height: Space.s16),
                      Text(l.loginDemoHint, textAlign: TextAlign.center, style: t.bodySmall!.copyWith(color: cs.onSurfaceVariant)),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The words for a failed login (owner report 2026-11-24). The unlock time is
/// Dhaka time: only the time on the same Dhaka day, otherwise date and time.
String loginFailureText(LoginFailure f, AppLocalizations l, Fmt fmt, Clock clock) => switch (f.error) {
      LoginError.invalid => l.loginErrorInvalid,
      LoginError.network => l.loginErrorNetwork,
      LoginError.locked => switch (f.until) {
          null => l.loginErrorLockedNoTime,
          final u => l.loginErrorLocked(businessDateOf(u) == businessDateOf(clock.nowUtc()) ? fmt.time(u) : fmt.dateTime(u)),
        },
      LoginError.deviceNotApproved => l.loginDeviceNotApproved,
      LoginError.otherUserUnsynced => l.loginErrorOtherUserUnsynced,
      LoginError.forbidden => l.loginErrorForbidden(f.code ?? 'HTTP_403'),
      LoginError.other => l.errorGeneric,
    };

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});
  @override
  ConsumerState<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _cur = TextEditingController();
  final _new = TextEditingController();
  final _confirm = TextEditingController();
  String? _error;
  bool _busy = false;

  Future<void> _submit() async {
    final l = AppLocalizations.of(context);
    if (_new.text.length < 8) return setState(() => _error = l.changePasswordTooShort);
    if (_new.text != _confirm.text) return setState(() => _error = l.changePasswordMismatch);
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(sessionProvider.notifier).changePassword(_cur.text, _new.text);
    } on ApiException catch (e) {
      setState(() => _error = e.isNetwork ? l.changePasswordOnline : (e.statusCode == 400 ? l.changePasswordWrong : l.errorGeneric));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(Space.s24),
          children: [
            const SizedBox(height: Space.s24),
            Icon(Icons.password_rounded, size: 48, color: cs.primary),
            const SizedBox(height: Space.s16),
            Text(l.changePasswordTitle, style: t.headlineSmall),
            const SizedBox(height: Space.s8),
            Text(l.changePasswordBody, style: t.bodyLarge!.copyWith(color: cs.onSurfaceVariant)),
            const SizedBox(height: Space.s24),
            TextField(controller: _cur, obscureText: true, decoration: InputDecoration(labelText: l.changePasswordCurrent)),
            const SizedBox(height: Space.s16),
            TextField(controller: _new, obscureText: true, decoration: InputDecoration(labelText: l.changePasswordNew)),
            const SizedBox(height: Space.s16),
            TextField(controller: _confirm, obscureText: true, decoration: InputDecoration(labelText: l.changePasswordConfirm)),
            if (_error != null) ...[
              const SizedBox(height: Space.s16),
              InfoBanner(icon: Icons.error_outline_rounded, text: _error!, tone: BannerTone.danger),
            ],
            const SizedBox(height: Space.s24),
            FilledButton(onPressed: _busy ? null : _submit, child: Text(l.actionContinue)),
          ],
        ),
      ),
    );
  }
}

/// PIN setup (enter twice) and unlock share this screen.
class PinScreen extends ConsumerStatefulWidget {
  const PinScreen({super.key, required this.setup});
  final bool setup;
  @override
  ConsumerState<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends ConsumerState<PinScreen> {
  String _pin = '';
  String? _first;
  String? _error;
  bool _busy = false;

  Future<void> _digit(String d) async {
    if (_busy || _pin.length >= 4) return;
    setState(() {
      _pin += d;
      _error = null;
    });
    if (_pin.length < 4) return;
    final l = AppLocalizations.of(context);
    final c = ref.read(sessionProvider.notifier);
    if (widget.setup) {
      if (_first == null) {
        if (isWeakPin(_pin)) {
          setState(() {
            _error = l.pinWeak;
            _pin = '';
          });
          return;
        }
        setState(() {
          _first = _pin;
          _pin = '';
        });
        return;
      }
      if (_first != _pin) {
        setState(() {
          _error = l.pinMismatch;
          _first = null;
          _pin = '';
        });
        return;
      }
      setState(() => _busy = true);
      await c.setPin(_pin);
      return;
    }
    setState(() => _busy = true);
    final ok = await c.unlock(_pin);
    if (!mounted) return;
    if (!ok) {
      final left = maxPinFailures - ref.read(sessionProvider).pinFailures;
      setState(() {
        _busy = false;
        _pin = '';
        _error = left > 0 ? l.pinWrong(left) : l.pinLockedOut;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final user = ref.watch(sessionProvider).user;
    final lang = Localizations.localeOf(context).languageCode;
    final title = widget.setup ? (_first == null ? l.pinSetupTitle : l.pinConfirmTitle) : l.pinUnlockTitle;
    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            const BrandMark(size: 56),
            const SizedBox(height: Space.s20),
            if (!widget.setup && user != null)
              Text(l.pinUnlockGreeting(user.name.of(lang)), style: t.bodyLarge!.copyWith(color: cs.onSurfaceVariant)),
            const SizedBox(height: Space.s4),
            Text(title, style: t.headlineSmall),
            if (widget.setup) ...[
              const SizedBox(height: Space.s8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Space.s32),
                child: Text(l.pinSetupBody, textAlign: TextAlign.center, style: t.bodyMedium!.copyWith(color: cs.onSurfaceVariant)),
              ),
            ],
            SizedBox(
              height: 48,
              child: Center(
                child: _busy && _error == null
                    ? Row(mainAxisSize: MainAxisSize.min, children: [
                        const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2.5)),
                        const SizedBox(width: Space.s12),
                        Text(l.pinChecking, style: t.bodyMedium!.copyWith(color: cs.onSurfaceVariant)),
                      ])
                    : (_error == null ? null : Text(_error!, textAlign: TextAlign.center, style: t.bodyMedium!.copyWith(color: cs.error))),
              ),
            ),
            PinPad(
              length: _pin.length,
              error: _error != null,
              onDigit: _digit,
              onBackspace: () => setState(() => _pin = _pin.isEmpty ? '' : _pin.substring(0, _pin.length - 1)),
            ),
            if (!widget.setup)
              TextButton(
                onPressed: () => ref.read(sessionProvider.notifier).usePassword(),
                child: Text(l.pinForgot),
              ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
