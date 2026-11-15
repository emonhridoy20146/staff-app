import 'package:material_ui/material_ui.dart';

import '../../core/feature/feature_manifest.dart';
import '../../core/permissions/permission_service.dart';
import '../../l10n/app_localizations.dart';
import 'src/tags.dart';

/// Bad-customer tags (FR-TAG-001…004). Staff tags go to manager review.
final tagsManifest = FeatureManifest(
  name: 'tags',
  flag: 'module.tags',
  permissions: const [Perm.tagView, Perm.tagSet],
  pushHandlers: [TagPushHandler()],
  customerActions: [
    CustomerActionDef(
      id: 'tag',
      order: 40,
      permission: Perm.tagSet,
      icon: Icons.flag_rounded,
      label: (c) => AppLocalizations.of(c).actionTag,
      onTap: (c, ref, x) => showTagSheet(c, x.customerId),
    ),
  ],
);
