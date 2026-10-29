enum DownloadedKind { video, pdf }

/// عنصر محمّل على الجهاز (فيديو أو ملف PDF) كما في تصميم "الكورسات المحملة".
/// ⚠️ لا يوجد endpoint ولا تخزين محلي للتنزيلات بعد؛ النموذج للواجهة فقط.
class DownloadedItem {
  const DownloadedItem({
    required this.order,
    required this.title,
    required this.kind,
    required this.meta,
  });

  /// الرقم في المربع الأزرق.
  final int order;
  final String title;
  final DownloadedKind kind;

  /// "22:30 دقيقة" للفيديو أو "40 صفحة" للـ PDF.
  final String meta;
}
