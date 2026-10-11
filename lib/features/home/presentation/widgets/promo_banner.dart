import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:darb/core/style/app_colors.dart';
import 'package:darb/core/style/app_text_styles.dart';

/// بانر "تفقد حسابك الآن". الزر يستدعي [onTap] (يفتح نافذة إكمال الحساب).
/// البانر نفسه UI فقط: لا API.
/// الشرائح تستعمل icon1 و icon2 من assets/images. لإضافة شريحة أضف مسارًا للقائمة.
/// ⚠️ قياس تقديري: ارتفاع البانر (108)، حجم الصورة (128)، التدرج اللوني،
/// وحجم النقاط. (في Figma ثلاث نقاط، وهنا بعدد الشرائح المتوفرة.)
class PromoBanner extends StatefulWidget {
  const PromoBanner({super.key, this.onTap});

  /// يُستدعى عند الضغط على زر "تفقد حسابك الان".
  final VoidCallback? onTap;

  @override
  State<PromoBanner> createState() => _PromoBannerState();
}

class _PromoBannerState extends State<PromoBanner> {
  static const List<String> _slides = [
    'assets/images/icon1.png',
    'assets/images/icon2.png',
  ];

  final _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 134.h,
          child: PageView.builder(
            controller: _controller,
            itemCount: _slides.length,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (context, i) =>
                _Slide(image: _slides[i], onTap: widget.onTap),
          ),
        ),
        SizedBox(height: 10.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 4.w,
          children: [
            for (var i = 0; i < _slides.length; i++)
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: i == _index ? 24.w : 6.w,
                height: 6.w,
                decoration: BoxDecoration(
                  color: i == _index ? AppColors.second500 : AppColors.grey100,
                  borderRadius: BorderRadius.circular(3.r),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _Slide extends StatelessWidget {
  const _Slide({required this.image, this.onTap});

  final String image;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: 108.h,
          child: Container(
            padding: EdgeInsetsDirectional.only(start: 20.w, end: 150.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.r),
              gradient: LinearGradient(
                begin: AlignmentDirectional.centerEnd,
                end: AlignmentDirectional.centerStart,
                colors: const [AppColors.main700, AppColors.main500],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'طريقتك الجديدة\nللتفوق تبدأ من هنا.',
                  style: AppTextStyles.font14Medium
                      .copyWith(color: AppColors.white),
                ),
                SizedBox(height: 10.h),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onTap,
                  child: Container(
                    height: 30.h,
                    padding: EdgeInsets.symmetric(horizontal: 14.w),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(
                        color: AppColors.white.withValues(alpha: 0.6),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      'تفقد حسابك الان',
                      style: AppTextStyles.font12Regular
                          .copyWith(color: AppColors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        PositionedDirectional(
          end: 16.w,
          bottom: 0,
          child: Image.asset(image, height: 128.h, fit: BoxFit.contain),
        ),
      ],
    );
  }
}
