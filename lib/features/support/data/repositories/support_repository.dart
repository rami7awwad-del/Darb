import 'dart:async';

import 'package:darb/core/services/api_constants.dart';
import 'package:darb/features/auth/data/models/terms_model.dart';
import 'package:darb/features/support/data/datasources/support_remote_data_source.dart';
import 'package:darb/features/support/data/models/about_model.dart';
import 'package:darb/features/support/data/models/faq_model.dart';
import 'package:darb/features/support/data/models/info_page_type.dart';

/// Repository that gives the cubits access to the support data.
class SupportRepository {
  SupportRepository(this._remote);

  final SupportRemoteDataSource _remote;

  Future<List<FaqModel>> getFaqs() => _remote.getFaqs();

  /// Gets page.
  Future<TermsModel> getPage(InfoPageType type) async =>
      TermsModel.fromHtml(await _remote.getPageValue(type.endpoint));

  /// Gets about.
  Future<AboutModel> getAbout() async {
    final (raw, links) = await (
      _remote.getPageValue(ApiConstants.pagesAboutApplication),
      _remote.getInfos(),
    ).wait;
    final text = raw
        .replaceAll(RegExp(r'<[^>]+>'), ' ')
        .replaceAll('&nbsp;', ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    return AboutModel(text: text, links: links);
  }

  /// Sends contact.
  Future<void> sendContact({
    required String firstName,
    required String lastName,
    required String phone,
    required String text,
  }) =>
      _remote.addContactUs(
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        text: text,
      );
}
