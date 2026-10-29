/// رد infos/all: روابط التواصل الاجتماعي ومعلومات الاتصال.
class ContactInfoModel {
  const ContactInfoModel({
    this.email,
    this.phone,
    this.facebook,
    this.instagram,
    this.telegram,
    this.whatsapp,
  });

  final String? email;
  final String? phone;
  final String? facebook;
  final String? instagram;
  final String? telegram;
  final String? whatsapp;

  static String? _s(dynamic v) {
    final text = v?.toString().trim();
    return (text == null || text.isEmpty) ? null : text;
  }

  factory ContactInfoModel.fromJson(Map<String, dynamic> json) =>
      ContactInfoModel(
        email: _s(json['email']),
        phone: _s(json['phone']),
        facebook: _s(json['facebook']),
        instagram: _s(json['instagram']),
        telegram: _s(json['telegram']),
        whatsapp: _s(json['whatsapp']),
      );
}
