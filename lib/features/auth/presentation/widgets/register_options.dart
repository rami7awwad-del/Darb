import 'package:flutter/widgets.dart';
import 'package:darb/core/style/phosphor_icons.dart';

/// خيار قابل للاختيار: [id] هو القيمة المرسلة للـ API.
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

/// القيم تطابق وصف الحقول في Postman (users/edit و schools/all).
/// ⚠️ الأيقونات: أقرب ما وجدته في Phosphor، تحقق منها مع Figma.
abstract class RegisterOptions {
  /// know_about_app: Facebook=1, Instagram=2, Friend=3, School=4, Otherwise=5
  static final List<ChoiceOption> sources = [
    ChoiceOption(id: 1, label: 'فيسبوك', icon: PhosphorIconsRegular.facebookLogo),
    ChoiceOption(id: 2, label: 'إنستا', icon: PhosphorIconsRegular.instagramLogo),
    ChoiceOption(id: 3, label: 'صديق', icon: PhosphorIconsRegular.users),
    ChoiceOption(id: 4, label: 'المدرسة', icon: PhosphorIconsRegular.graduationCap),
    ChoiceOption(id: 5, label: 'غير ذلك', icon: PhosphorIconsRegular.dotsThreeCircle),
  ];

  /// gender: 0 أنثى، 1 ذكر (ترتيب العرض كما في Figma: ذكر ثم أنثى)
  static final List<ChoiceOption> genders = [
    ChoiceOption(id: 1, label: 'ذكر', icon: PhosphorIconsRegular.genderMale),
    ChoiceOption(id: 0, label: 'أنثى', icon: PhosphorIconsRegular.genderFemale),
  ];

  /// type: School=1, Institute=2
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

  /// أيقونة موحدة لكل الفروع (القائمة تأتي من الـ API بلا أيقونات).
  static IconData get branchIcon => PhosphorIconsRegular.bookOpen;
}
