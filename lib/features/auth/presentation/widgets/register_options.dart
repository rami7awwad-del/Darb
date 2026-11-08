import 'package:flutter/widgets.dart';
import 'package:darb/core/style/phosphor_icons.dart';

/// One option the user can pick in the registration steps.
class ChoiceOption {
  const ChoiceOption({
    required this.id,
    required this.label,
    required this.icon,
    this.description,
  });

  final int id;
  final String label;
  final IconData icon;
  final String? description;
}

/// Shared register options values and helpers.
abstract class RegisterOptions {
  static final List<ChoiceOption> sources = [
    ChoiceOption(id: 1, label: 'فيسبوك', icon: PhosphorIconsRegular.facebookLogo),
    ChoiceOption(id: 2, label: 'إنستا', icon: PhosphorIconsRegular.instagramLogo),
    ChoiceOption(id: 3, label: 'صديق', icon: PhosphorIconsRegular.users),
    ChoiceOption(id: 4, label: 'المدرسة', icon: PhosphorIconsRegular.graduationCap),
    ChoiceOption(id: 5, label: 'غير ذلك', icon: PhosphorIconsRegular.dotsThreeCircle),
  ];

  static final List<ChoiceOption> genders = [
    ChoiceOption(id: 1, label: 'ذكر', icon: PhosphorIconsRegular.genderMale),
    ChoiceOption(id: 0, label: 'أنثى', icon: PhosphorIconsRegular.genderFemale),
  ];

  static final List<ChoiceOption> institutions = [
    ChoiceOption(
      id: 1,
      label: 'مدرسة',
      icon: PhosphorIconsRegular.graduationCap,
      description: 'للمدارس الحكومية والخاصة بمراحلها المختلفة.',
    ),
    ChoiceOption(
      id: 2,
      label: 'معهد',
      icon: PhosphorIconsRegular.bank,
      description: 'للمعاهد الأكاديمية، ومراكز التدريب، والمؤسسات التعليمية المتخصصة.',
    ),
  ];

  static IconData get branchIcon => PhosphorIconsRegular.bookOpen;
}
