import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart' show Icons;

import '../../core/feature/feature_manifest.dart';
import '../../core/permissions/permission_service.dart';
import '../../core/providers.dart';
import '../../core/settings/ui_prefs.dart';
import '../../core/sync/sync_handlers.dart';
import '../../l10n/app_localizations.dart';
import 'src/contact_attempts.dart';
import 'src/pin_correction.dart';
import 'src/data/customer_repository.dart';
import 'src/presentation/customer_detail_screen.dart';

/// Customers: list, search, filters, detail, plans, schedule, ERP payments
/// (FR-CUS-001…008, 010). Read-only mirror of the ERP via field-api.
FeatureManifest customersManifest(SyncHandlerRegistry Function() registry) => FeatureManifest(
      name: 'customers',
      flag: 'module.customers',
      permissions: const [Perm.customerView, Perm.customerLocationPropose],
      routes: [
        GoRoute(path: '/customers/:id/pin', builder: (_, s) => PinCorrectionScreen(customerId: s.pathParameters['id']!)),
        GoRoute(path: '/customers/:id', builder: (_, s) => CustomerDetailScreen(customerId: s.pathParameters['id']!, initialAction: s.uri.queryParameters['action'])),
      ],
      pullHandlers: [CustomerPullHandler(registry), ContactAttemptPullHandler()],
      pushHandlers: [ContactAttemptPushHandler(), LocationProposalPushHandler()],
      customerActions: [
        CustomerActionDef(
          id: 'pin',
          order: 90,
          permission: Perm.customerLocationPropose,
          icon: Icons.edit_location_alt_rounded,
          label: (c) => AppLocalizations.of(c).actionCorrectLocation,
          onTap: (c, ref, x) => openPinCorrection(c, x.customerId),
        ),
      ],
      timelineSources: [
        TimelineSourceDef(
          id: 'contact-attempts',
          watch: (context, ref, id) {
            final l = AppLocalizations.of(context);
            return watchContactAttempts(ref.read(databaseProvider), id).map((rows) {
              final f = ref.read(fmtProvider);
              return [
                for (final a in rows)
                  TimelineEntry(at: a.at, icon: callOutcomeIcon(a.outcome), title: l.timelineCall(callOutcomeLabel(l, a.outcome ?? '')), subtitle: f.dateTime(a.at)),
              ];
            });
          },
        ),
      ],
    );
