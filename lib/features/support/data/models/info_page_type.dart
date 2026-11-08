import 'package:darb/core/services/api_constants.dart';

/// Possible values for the info page type.
enum InfoPageType { terms, privacy }

/// Extra helpers for the info page type x.
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
