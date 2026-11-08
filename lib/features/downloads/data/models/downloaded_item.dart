/// Possible values for the downloaded kind.
enum DownloadedKind { video, pdf }

/// One downloaded course or lesson.
class DownloadedItem {
  const DownloadedItem({
    required this.order,
    required this.title,
    required this.kind,
    required this.meta,
  });

  final int order;
  final String title;
  final DownloadedKind kind;

  final String meta;
}
