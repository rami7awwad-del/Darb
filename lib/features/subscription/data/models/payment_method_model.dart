/// عنصر payment-methods/all: وسيلة دفع ومعلومات الوكيل (للتعليمات).
class PaymentMethodModel {
  const PaymentMethodModel({
    required this.id,
    required this.method,
    this.agentName = '',
    this.phone = '',
    this.governorate = '',
    this.image = '',
  });

  final int id;

  /// اسم الوسيلة (مثل شام كاش).
  final String method;

  /// اسم الوكيل (حقل name).
  final String agentName;
  final String phone;
  final String governorate;
  final String image;

  factory PaymentMethodModel.fromJson(Map<String, dynamic> json) {
    // governorate قد تكون نصًا أو كائنًا فيه name.
    final gov = json['governorate'];
    return PaymentMethodModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      method: (json['method'] ?? json['title'] ?? '').toString(),
      agentName: (json['name'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
      governorate: gov is Map ? (gov['name'] ?? '').toString() : (gov ?? '').toString(),
      image: (json['image'] ?? '').toString(),
    );
  }
}
