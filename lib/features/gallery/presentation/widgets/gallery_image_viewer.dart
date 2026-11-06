import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:darb/core/style/app_colors.dart';
import 'package:darb/core/widgets/app_circle_close_button.dart';
import 'package:darb/core/widgets/app_network_image.dart';

/// Shows gallery image viewer.
Future<void> showGalleryImageViewer(BuildContext context, String url) {
  return showDialog<void>(
    context: context,
    builder: (_) => _GalleryImageViewer(url: url),
  );
}

/// Viewer widget for the gallery image.
class _GalleryImageViewer extends StatelessWidget {
  const _GalleryImageViewer({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16.r),
            child: AspectRatio(
              aspectRatio: 1.3,
              child: AppNetworkImage(url: url),
            ),
          ),
          PositionedDirectional(
            top: 12.w,
            end: 12.w,
            child: AppCircleCloseButton(
              color: AppColors.white,
              onTap: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}
