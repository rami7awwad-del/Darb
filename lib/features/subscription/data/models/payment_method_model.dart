/// Model that holds the payment method data parsed from the API.
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

  final String method;

  final String agentName;
  final String phone;
  final String governorate;
  final String image;

  /// Builds the object from the API json.
  factory PaymentMethodModel.fromJson(Map<String, dynamic> json) {
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
