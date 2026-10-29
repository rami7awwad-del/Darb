import 'package:darb/features/support/data/models/contact_info_model.dart';

/// محتوى ورقة "حول التطبيق": النص (pages/about-application) + روابط التواصل (infos/all).
class AboutModel {
  const AboutModel({required this.text, required this.links});

  final String text;
  final ContactInfoModel links;
}
