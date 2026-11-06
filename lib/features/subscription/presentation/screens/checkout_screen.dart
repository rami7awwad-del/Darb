import 'package:darb/core/style/app_colors.dart';
import 'package:darb/core/style/app_text_styles.dart';
import 'package:darb/core/widgets/app_network_image.dart';
import 'package:darb/core/widgets/app_primary_button.dart';
import 'package:darb/core/widgets/app_snack_bar.dart';
import 'package:darb/features/gallery/presentation/widgets/gallery_header.dart';
import 'package:darb/features/subscription/data/models/payment_method_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CheckoutArgs {
  const CheckoutArgs({required this.methods, required this.total});

  final List<PaymentMethodModel> methods;

  /// المجموع المعروض (شكلي).
  final String total;
}

/// خيار دفع معروض: من وسائل الدفع الفعلية، مع "كاش مباشر مع الأدمن" ثابتًا.
class _Choice {
  const _Choice(this.key, this.label, this.image);

  final String key;
  final String label;
  final String image; // فارغ = أيقونة
}

/// خيارات الدفع / إتمام الشراء (Figma: Checkout page).
/// ⚠️ الصفحة شكلية: لا يوجد endpoint للشراء، و"إتمام الشراء" يعرض رسالة فقط.
class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key, required this.args});

  final CheckoutArgs args;

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String? _selected;

  late final List<_Choice> _choices = [
    for (final m in widget.args.methods)
      _Choice(
        'm${m.id}',
        m.agentName.isNotEmpty ? m.agentName : m.method,
        m.image,
      ),
    const _Choice('cash', 'كاش مباشر مع الأدمن', ''),
  ];

  void _complete() {
    if (_selected == null) {
      showAppSnackBar(context, 'اختر وسيلة الدفع');
      return;
    }
    showAppSnackBar(
      context,
      'للاشتراك: حوّل المبلغ ثم فعّل الكود الذي تحصل عليه',
      isError: false,
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    _selected ??= _choices.first.key;
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        children: [
          GalleryHeader(
            title: 'إتمام الشراء',
            icon: null,
            onBack: () => Navigator.pop(context),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(16.w, 24.h, 16.w, 24.h), // 📏
              children: [
                Text(
                  'اختر وسيلة الدفع',
                  style: AppTextStyles.font16Medium
                      .copyWith(color: AppColors.main600),
                ),
                SizedBox(height: 12.h), // 📏
                for (final c in _choices) ...[
                  _ChoiceTile(
                    choice: c,
                    selected: _selected == c.key,
                    onTap: () => setState(() => _selected = c.key),
                  ),
                  SizedBox(height: 12.h), // 📏
                ],
                SizedBox(height: 16.h), // 📏
                Text(
                  'الحساب',
                  style: AppTextStyles.font16Medium
                      .copyWith(color: AppColors.main600),
                ),
                SizedBox(height: 12.h), // 📏
                Row(
                  spacing: 6.w, // 📏
                  children: [
                    Icon(Icons.receipt_long_outlined,
                        size: 18.w, color: AppColors.second500), // 📏
                    Text(
                      'المجموع النهائي :',
                      style: AppTextStyles.font12Regular
                          .copyWith(color: AppColors.grey300),
                    ),
                    Text(
                      '${widget.args.total} ل.س',
                      style: AppTextStyles.font12Bold
                          .copyWith(color: AppColors.second500),
                    ),
                  ],
                ),
                SizedBox(height: 24.h), // 📏
                AppPrimaryButton(text: 'إتمام الشراء', onPressed: _complete),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// صف خيار دفع: الشعار والاسم في البداية ودائرة الاختيار في النهاية (Figma).
class _ChoiceTile extends StatelessWidget {
  const _ChoiceTile({
    required this.choice,
    required this.selected,
    required this.onTap,
  });

  final _Choice choice;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(8.r); // 📏
    return Material(
      color: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(
          color: selected ? AppColors.second500 : AppColors.grey100,
        ),
      ),
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h), // 📏
          child: Row(
            children: [
              SizedBox(
                width: 40.w, // 📏
                height: 24.w, // 📏
                child: choice.image.isEmpty
                    ? Icon(Icons.payments_outlined,
                        size: 22.w, color: AppColors.grey300)
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(4.r), // 📏
                        child: AppNetworkImage(
                          url: choice.image,
                          width: 40.w,
                          height: 24.w,
                        ),
                      ),
              ),
              SizedBox(width: 12.w), // 📏
              Expanded(
                child: Text(
                  choice.label,
                  style: AppTextStyles.font12Regular
                      .copyWith(color: AppColors.main600),
                ),
              ),
              Container(
                width: 20.w, // 📏
                height: 20.w, // 📏
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected ? AppColors.second500 : AppColors.main600,
                  ),
                ),
                child: selected
                    ? Container(
                        width: 10.w, // 📏
                        height: 10.w, // 📏
                        decoration: const BoxDecoration(
                          color: AppColors.second500,
                          shape: BoxShape.circle,
                        ),
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
