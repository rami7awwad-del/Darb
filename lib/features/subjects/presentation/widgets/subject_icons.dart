import 'package:flutter/material.dart';

/// أيقونات صفحة المادة في مكان واحد.
/// 🎨 مؤقتة من Material؛ بدّلها بما يقابلها في Figma من هنا فقط.
abstract class SubjectIcons {
  static const IconData course = Icons.auto_stories_outlined; // 🎨 بجانب اسم الدورة
  static const IconData exam = Icons.quiz_outlined; // 🎨 أيقونة الاختبار الكبيرة
  static const IconData activity = Icons.psychology_alt_outlined; // 🎨 أيقونة النشاط
  static const IconData subscribers = Icons.visibility_outlined; // 🎨 بجانب العدد (22)
}
