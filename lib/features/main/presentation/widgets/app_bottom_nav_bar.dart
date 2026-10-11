import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

import 'package:darb/core/style/app_colors.dart';

/// الشريط السفلي: 4 تبويبات، الفعّال بلون main600 مع خط تحته.
/// الترتيب (RTL، من اليمين): الرئيسية، الصور، المكتبة، الحساب (كما في Figma).
/// ⚠️ قياس تقديري: ارتفاع الشريط (64)، ألوان التبويبات غير الفعّالة (second400)،
/// وعرض الخط تحت الفعّال (20).
class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static final List<({IconData regular, IconData fill})> _items = [
    (regular: PhosphorIconsRegular.house, fill: PhosphorIconsFill.house),
    (regular: PhosphorIconsRegular.image, fill: PhosphorIconsFill.image),
    (regular: PhosphorIconsRegular.books, fill: PhosphorIconsFill.books),
    (
      regular: PhosphorIconsRegular.userCircle,
      fill: PhosphorIconsFill.userCircle
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: Color(0xFFEDEDED), width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64.h,
          child: Row(
            children: [
              for (var i = 0; i < _items.length; i++)
                Expanded(
                  child: InkWell(
                    onTap: () => onTap(i),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      spacing: 4.h,
                      children: [
                        Icon(
                          i == currentIndex ? _items[i].fill : _items[i].regular,
                          size: 26.w,
                          color: i == currentIndex
                              ? AppColors.main600
                              : AppColors.second400,
                        ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: i == currentIndex ? 20.w : 0,
                          height: 3.h,
                          decoration: BoxDecoration(
                            color: AppColors.main600,
                            borderRadius: BorderRadius.circular(2.r),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
