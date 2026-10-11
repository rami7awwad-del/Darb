import 'package:flutter/material.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

import 'package:darb/core/style/app_colors.dart';

/// صورة من الشبكة مع مكان بديل أثناء التحميل وعند الفشل.
/// [fallbackAsset] صورة محلية تظهر عند الفشل (مثل الصورة الشخصية الافتراضية).
class AppNetworkImage extends StatelessWidget {
  const AppNetworkImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.fallbackAsset,
  });

  final String? url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final String? fallbackAsset;

  Widget _placeholder() => Container(
        width: width,
        height: height,
        color: AppColors.grey50,
        child: Icon(PhosphorIconsRegular.image, color: AppColors.grey100),
      );

  Widget _fallback() => fallbackAsset == null
      ? _placeholder()
      : Image.asset(fallbackAsset!, width: width, height: height, fit: fit);

  @override
  Widget build(BuildContext context) {
    final address = url;
    if (address == null || address.isEmpty) return _fallback();

    return Image.network(
      address,
      width: width,
      height: height,
      fit: fit,
      loadingBuilder: (context, child, progress) =>
          progress == null ? child : _placeholder(),
      errorBuilder: (context, error, stackTrace) => _fallback(),
    );
  }
}
