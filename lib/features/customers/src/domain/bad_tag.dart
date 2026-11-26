import '../../../../core/theme/tag_colors.dart' show TagKind;

/// Bad-tag customers stand out (FR-M-081): which customers get the coloured frame and chip, and which kind.
/// Pure rules; the rows, the Home filter and the tag sheet read them.

/// Where the mark comes from: a set tag, or the latest visit's outcome.
enum BadTagSource { tag, visit }

/// What a customer row shows: the [kind] (colour, icon, word) and why.
class BadTag {
  const BadTag(this.kind, this.source);
  final TagKind kind;
  final BadTagSource source;

  @override
  bool operator ==(Object other) => other is BadTag && other.kind == kind && other.source == source;
  @override
  int get hashCode => Object.hash(kind, source);
  @override
  String toString() => 'BadTag(${kind.name}, ${source.name})';
}

/// The visit outcome that marks a customer like an absconded tag (contract `VisitOutcome`, 1.41.0).
const runawayOutcome = 'runaway';

/// The colour of one reason option (the tag sheet's swatches). `other` and any code this app does not know
/// are the generic bad kind.
TagKind tagKindForReason(String? reasonCode) => switch (reasonCode) {
      'absconded' => TagKind.absconded,
      'refused_to_pay' => TagKind.refusedToPay,
      'fraud_suspected' => TagKind.fraudSuspected,
      'repeated_broken_promise' => TagKind.brokenPromise,
      'plan_ended_unpaid' => TagKind.planEndedUnpaid,
      _ => TagKind.other,
    };

/// What a row will show for a tag of this [severity] and [reasonCode]: `watch` is not a bad tag (null);
/// absconded is the strongest, then `legal`, then the reason's own kind.
TagKind? tagKindForChoice({required String? severity, required String? reasonCode}) {
  if (severity == 'watch') return null;
  if (reasonCode == 'absconded') return TagKind.absconded;
  if (severity == 'legal') return TagKind.legal;
  return tagKindForReason(reasonCode);
}

/// The kind of a customer's tag, or null when it is not a bad tag: the tag must be set (`tagged`; `none` and
/// `pending` are not) with severity `bad` or `legal`. A set tag with no severity, or one this app does not
/// know, counts as bad (the app has always shown such a tag as "bad"); only `watch` is left out.
TagKind? tagKindOf({required String? state, required String? severity, required String? reasonCode}) =>
    state == 'tagged' ? tagKindForChoice(severity: severity, reasonCode: reasonCode) : null;

/// How far the customer's last-contact time may run ahead of the runaway visit and still be that visit
/// (rounding, and a collection saved in the same minute).
const runawaySlack = Duration(minutes: 1);

/// The customer's latest visit on the phone says runaway, and nothing happened after it: [lastContactAt] is
/// `customers.last_visit_at`, which also moves on a later visit the phone does not hold and on a collection.
/// Someone who was met or who paid after "runaway" is no longer shown as one.
bool runawayStands({required String? lastVisitOutcome, required DateTime? lastVisitAt, required DateTime? lastContactAt}) {
  if (lastVisitOutcome != runawayOutcome || lastVisitAt == null) return false;
  return lastContactAt == null || !lastContactAt.isAfter(lastVisitAt.add(runawaySlack));
}

/// The mark of a customer, or null: an absconded tag, else a standing runaway visit (shown the same way),
/// else the tag's kind.
BadTag? badTagOf({
  required String? tagState,
  required String? tagSeverity,
  required String? tagReasonCode,
  required String? lastVisitOutcome,
  required DateTime? lastVisitAt,
  required DateTime? lastContactAt,
}) {
  final kind = tagKindOf(state: tagState, severity: tagSeverity, reasonCode: tagReasonCode);
  if (kind == TagKind.absconded) return const BadTag(TagKind.absconded, BadTagSource.tag);
  if (runawayStands(lastVisitOutcome: lastVisitOutcome, lastVisitAt: lastVisitAt, lastContactAt: lastContactAt)) {
    return const BadTag(TagKind.absconded, BadTagSource.visit);
  }
  return kind == null ? null : BadTag(kind, BadTagSource.tag);
}
