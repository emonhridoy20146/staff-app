import 'package:go_router/go_router.dart';

import '../../core/feature/feature_manifest.dart';
import '../../core/permissions/permission_service.dart';
import '../../core/sync/sync_handlers.dart';
import 'src/data/customer_repository.dart';
import 'src/presentation/customer_detail_screen.dart';

/// Customers: list, search, filters, detail, plans, schedule, ERP payments
/// (FR-CUS-001…008, 010). Read-only mirror of the ERP via field-api.
FeatureManifest customersManifest(SyncHandlerRegistry Function() registry) => FeatureManifest(
      name: 'customers',
      flag: 'module.customers',
      permissions: const [Perm.customerView, Perm.customerLocationPropose],
      routes: [
        GoRoute(path: '/customers/:id', builder: (_, s) => CustomerDetailScreen(customerId: s.pathParameters['id']!, initialAction: s.uri.queryParameters['action'])),
      ],
      pullHandlers: [CustomerPullHandler(registry)],
    );
