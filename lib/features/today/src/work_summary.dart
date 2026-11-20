import '../../../core/feature/feature_manifest.dart';

/// Counts of one day's work log (FR-M-041). Money that reached the ERP and
/// money still waiting are two numbers; they are never added together.
class WorkDaySummary {
  const WorkDaySummary({this.visits = 0, this.collections = 0, this.postedPoisha = 0, this.pendingPoisha = 0, this.promises = 0, this.others = 0});
  final int visits;
  final int collections;
  final int postedPoisha;
  final int pendingPoisha;
  final int promises;

  /// Notes, pins, calls and tasks.
  final int others;
  bool get isEmpty => visits + collections + promises + others == 0;
}

WorkDaySummary summarizeWork(Iterable<WorkLogEntry> entries) {
  var visits = 0, collections = 0, posted = 0, pending = 0, promises = 0, others = 0;
  for (final e in entries) {
    switch (e.kind) {
      case WorkKind.visit:
        visits++;
      case WorkKind.collection:
        collections++;
        if (e.pending) {
          pending += e.amountPoisha ?? 0;
        } else {
          posted += e.amountPoisha ?? 0;
        }
      case WorkKind.promise:
        promises++;
      case WorkKind.note || WorkKind.pin || WorkKind.task || WorkKind.call:
        others++;
    }
  }
  return WorkDaySummary(visits: visits, collections: collections, postedPoisha: posted, pendingPoisha: pending, promises: promises, others: others);
}

/// The day's entries, latest first; entries of the same moment keep a steady order.
List<WorkLogEntry> orderWork(Iterable<WorkLogEntry> entries) => [...entries]..sort((a, b) {
    final c = b.at.compareTo(a.at);
    return c != 0 ? c : a.kind.index.compareTo(b.kind.index);
  });
