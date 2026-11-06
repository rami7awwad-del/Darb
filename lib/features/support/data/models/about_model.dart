import 'package:darb/features/support/data/models/contact_info_model.dart';

/// Model that holds the about data parsed from the API.
class AboutModel {
  const AboutModel({required this.text, required this.links});

  final String text;
  final ContactInfoModel links;
}
