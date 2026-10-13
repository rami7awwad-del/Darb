import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:darb/core/widgets/app_network_image.dart';

/// صور متتالية فوق بعضها (الأمامية أسفل اليسار، والخلفية تظهر من الأعلى واليمين).
/// ⚠️ الإزاحة (step) ونصف القطر تقديريان من Figma؛ عدّلهما حسب التصميم.
class StackedPhotos extends StatelessWidget {
  const StackedPhotos({
    super.key,
    required this.images,
    this.maxLayers = 3,
    this.step,
    this.radius,
  });

  final List<String> images;
  final int maxLayers;
  final double? step;
  final double? radius;

  @override
  Widget build(BuildContext context) {
    final offset = step ?? 8.w;
    final r = radius ?? 12.r;

    // بدون صور: طبقة واحدة تعرض المكان البديل.
    final List<String?> urls =
        images.isEmpty ? [null] : images.take(maxLayers).toList();
    final layers = urls.length;
    final shift = offset * (layers - 1);

    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth - shift;
        final h = c.maxHeight - shift;

        return Stack(
          children: [
            // نرسم من الخلف إلى الأمام؛ الأخيرة (i = 0) هي الأعلى.
            for (var i = layers - 1; i >= 0; i--)
              Positioned(
                left: offset * i,
                top: offset * (layers - 1 - i),
                width: w,
                height: h,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(r),
                    child: AppNetworkImage(
                      url: urls[i],
                      width: w,
                      height: h,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
