import 'package:material_ui/material_ui.dart';

import '../../../core/theme/tokens.dart';
import '../../../l10n/app_localizations.dart';

/// Phase 2 — OEM battery guide (FR-M-011 §4).
/// Shown from the tracking status card when GPS is unreliable on this device.
/// Each section can be expanded to reveal the OEM-specific steps.
class OemBatteryGuideScreen extends StatelessWidget {
  const OemBatteryGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    final brands = oemBrands(l);

    return Scaffold(
      appBar: AppBar(title: Text(l.oemGuideTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(Space.screen, Space.s16, Space.screen, Space.s32),
        children: [
          Container(
            padding: const EdgeInsets.all(Space.s16),
            decoration: BoxDecoration(
              color: cs.primaryContainer,
              borderRadius: Radii.brMd,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.battery_saver_rounded, color: cs.onPrimaryContainer, size: 20),
                const SizedBox(width: Space.s12),
                Expanded(child: Text(l.oemGuideSubtitle, style: t.bodyMedium!.copyWith(color: cs.onPrimaryContainer))),
              ],
            ),
          ),
          const SizedBox(height: Space.s16),
          ...brands.map((b) => OemBrandTile(brand: b)),
          const SizedBox(height: Space.s24),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l.oemGuideDone),
          ),
        ],
      ),
    );
  }
}

enum OemBrandId { xiaomi, samsung, oppo, vivo, huawei, oneplus, other }

class OemBrand {
  const OemBrand({required this.id, required this.name, required this.steps});
  final OemBrandId id;
  final String name;
  final List<String> steps;
}

/// Every brand's steps (Realme shares ColorOS with Oppo; Redmi / POCO are Xiaomi).
List<OemBrand> oemBrands(AppLocalizations l) => [
      OemBrand(id: OemBrandId.xiaomi, name: l.oemGuideXiaomiName, steps: [l.oemGuideXiaomiStep1, l.oemGuideXiaomiStep2, l.oemGuideXiaomiStep3]),
      OemBrand(id: OemBrandId.samsung, name: l.oemGuideSamsungName, steps: [l.oemGuideSamsungStep1, l.oemGuideSamsungStep2, l.oemGuideSamsungStep3]),
      OemBrand(id: OemBrandId.oppo, name: l.oemGuideOppoName, steps: [l.oemGuideOppoStep1, l.oemGuideOppoStep2, l.oemGuideOppoStep3]),
      OemBrand(id: OemBrandId.vivo, name: l.oemGuideVivoName, steps: [l.oemGuideVivoStep1, l.oemGuideVivoStep2, l.oemGuideVivoStep3]),
      OemBrand(id: OemBrandId.huawei, name: l.oemGuideHuaweiName, steps: [l.oemGuideHuaweiStep1, l.oemGuideHuaweiStep2, l.oemGuideHuaweiStep3]),
      OemBrand(id: OemBrandId.oneplus, name: l.oemGuideOneplusName, steps: [l.oemGuideOneplusStep1, l.oemGuideOneplusStep2]),
      OemBrand(id: OemBrandId.other, name: l.oemGuideOtherName, steps: [l.oemGuideOtherStep1, l.oemGuideOtherStep2]),
    ];

/// Pure rule (unit-tested): which guide fits `Build.MANUFACTURER` (FR-M-078).
OemBrandId oemBrandFor(String? manufacturer) {
  final m = (manufacturer ?? '').toLowerCase();
  bool any(List<String> names) => names.any(m.contains);
  if (any(['xiaomi', 'redmi', 'poco'])) return OemBrandId.xiaomi;
  if (any(['samsung'])) return OemBrandId.samsung;
  if (any(['oppo', 'realme'])) return OemBrandId.oppo;
  if (any(['vivo', 'iqoo'])) return OemBrandId.vivo;
  if (any(['huawei', 'honor'])) return OemBrandId.huawei;
  if (any(['oneplus', 'nothing'])) return OemBrandId.oneplus;
  return OemBrandId.other;
}

class OemBrandTile extends StatefulWidget {
  const OemBrandTile({super.key, required this.brand, this.initiallyOpen = false});
  final OemBrand brand;
  final bool initiallyOpen;

  @override
  State<OemBrandTile> createState() => _OemBrandTileState();
}

class _OemBrandTileState extends State<OemBrandTile> {
  late bool _expanded = widget.initiallyOpen;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: Space.s8),
      child: Material(
        color: cs.surface,
        borderRadius: Radii.brMd,
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            InkWell(
              onTap: () => setState(() => _expanded = !_expanded),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: Space.s16, vertical: Space.s12),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(color: cs.primaryContainer, borderRadius: Radii.brSm),
                      child: const Icon(Icons.smartphone_rounded, size: 20),
                    ),
                    const SizedBox(width: Space.s12),
                    Expanded(child: Text(widget.brand.name, style: t.titleSmall)),
                    Icon(_expanded ? Icons.expand_less_rounded : Icons.expand_more_rounded, color: cs.onSurfaceVariant),
                  ],
                ),
              ),
            ),
            if (_expanded)
              Padding(
                padding: const EdgeInsets.fromLTRB(Space.s16, 0, Space.s16, Space.s16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(height: 1),
                    const SizedBox(height: Space.s12),
                    ...widget.brand.steps.asMap().entries.map(
                          (e) => Padding(
                            padding: const EdgeInsets.only(bottom: Space.s8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(color: cs.secondaryContainer, shape: BoxShape.circle),
                                  child: Center(child: Text('${e.key + 1}', style: t.labelSmall!.copyWith(color: cs.onSecondaryContainer, fontWeight: FontWeight.bold))),
                                ),
                                const SizedBox(width: Space.s8),
                                Expanded(child: Text(e.value, style: t.bodySmall!.copyWith(color: cs.onSurface))),
                              ],
                            ),
                          ),
                        ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
