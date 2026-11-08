import 'package:flutter/material.dart';

import 'package:darb/core/style/phosphor_icons.dart' as ph;

/// Shared profile icons values and helpers.
abstract class ProfileIcons {
  static const IconData profileHeader = Icons.manage_accounts_outlined;

  static const IconData faq = Icons.quiz_outlined;
  static const IconData contact = Icons.headset_mic_outlined;
  static const IconData subscription = Icons.verified_outlined;
  static const IconData achievements = Icons.workspace_premium_outlined;
  static const IconData about = Icons.info_outline_rounded;
  static const IconData privacy = Icons.privacy_tip_outlined;
  static const IconData downloads = Icons.download_for_offline_outlined;
  static const IconData terms = Icons.description_outlined;
  static const IconData exams = Icons.fact_check_outlined;
  static const IconData editProfile = Icons.edit_outlined;
  static const IconData logout = Icons.logout_rounded;

  static const IconData user = ph.PhosphorIconsRegular.user;
  static const IconData phone = ph.PhosphorIconsRegular.phone;
  static const IconData school = ph.PhosphorIconsRegular.graduationCap;
  static const IconData description = Icons.notes_rounded;

  static const IconData points = Icons.star_outline_rounded;
  static const IconData semesters = Icons.layers_outlined;
  static const IconData lessons = Icons.menu_book_outlined;

  static const IconData play = Icons.play_arrow_rounded;
  static const IconData videoMeta = Icons.videocam_outlined;
  static const IconData pdfMeta = Icons.insert_drive_file_outlined;
  static const IconData book = Icons.auto_stories_outlined;

  static const IconData facebook = ph.PhosphorIconsRegular.facebookLogo;
  static const IconData instagram = ph.PhosphorIconsRegular.instagramLogo;
  static const IconData telegram = Icons.send_rounded;
  static const IconData whatsapp = Icons.chat_rounded;
}
