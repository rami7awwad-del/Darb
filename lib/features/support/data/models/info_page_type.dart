import 'package:darb/core/services/api_constants.dart';

/// الصفحات النصية التي تُعرض كشاشة كاملة (حول التطبيق تُعرض كورقة سفلية).
enum InfoPageType { terms, privacy }

extension InfoPageTypeX on InfoPageType {
  String get title => switch (this) {
        InfoPageType.terms => 'سياسة الاستخدام',
        InfoPageType.privacy => 'سياسة الخصوصية',
      };

  String get endpoint => switch (this) {
        InfoPageType.terms => ApiConstants.pagesTermsConditions,
        InfoPageType.privacy => ApiConstants.pagesPrivacyPolicy,
      };
}
