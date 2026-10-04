/// بند واحد من الشروط: عنوان مرقّم (اختياري) + نصه.
class TermsSection {
  const TermsSection({this.title, required this.body});

  final String? title;
  final String body;
}

/// رد pages/terms-conditions: data.value نص HTML بصيغة:
/// "الشروط و الأحكام<div>1. عنوان</div><div>نص البند</div><div>2. ...</div>..."
/// لا توجد حزمة HTML في المشروع، فنحلّله بتعبير نمطي بسيط.
class TermsModel {
  const TermsModel({this.heading, required this.sections});

  final String? heading;
  final List<TermsSection> sections;

  static final RegExp _divPattern =
      RegExp(r'<div[^>]*>(.*?)</div>', dotAll: true);
  static final RegExp _titlePattern = RegExp(r'^\d+\s*[\.\-\)]');

  static String _clean(String raw) => raw
      .replaceAll(RegExp(r'<[^>]+>'), ' ')
      .replaceAll('&nbsp;', ' ')
      .replaceAll('&amp;', '&')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  factory TermsModel.fromHtml(String html) {
    final texts = _divPattern
        .allMatches(html)
        .map((m) => _clean(m.group(1)!))
        .where((t) => t.isNotEmpty)
        .toList();

    // لا توجد وسوم div: نعرض النص كاملًا كبند واحد.
    if (texts.isEmpty) {
      return TermsModel(sections: [TermsSection(body: _clean(html))]);
    }

    final firstDiv = html.indexOf('<div');
    final heading = firstDiv > 0 ? _clean(html.substring(0, firstDiv)) : '';

    final sections = <TermsSection>[];
    String? title;
    final body = <String>[];

    void flush() {
      if (title != null || body.isNotEmpty) {
        sections.add(TermsSection(title: title, body: body.join('\n')));
      }
      title = null;
      body.clear();
    }

    for (final text in texts) {
      if (_titlePattern.hasMatch(text)) {
        flush();
        title = text;
      } else {
        body.add(text);
      }
    }
    flush();

    return TermsModel(
      heading: heading.isEmpty ? null : heading,
      sections: sections,
    );
  }
}
