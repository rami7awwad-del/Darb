import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:darb/core/models/base_state.dart';
import 'package:darb/core/models/enums/state_value.dart';
import 'package:darb/core/style/app_colors.dart';
import 'package:darb/core/style/app_text_styles.dart';
import 'package:darb/core/widgets/app_load_error.dart';
import 'package:darb/features/auth/data/models/terms_model.dart';
import 'package:darb/features/gallery/presentation/widgets/gallery_header.dart';
import 'package:darb/features/support/data/models/info_page_type.dart';
import 'package:darb/features/support/presentation/cubit/info_page_cubit.dart';

/// شاشة نصية: سياسة الاستخدام أو سياسة الخصوصية (بنود بعنوان أزرق ونص رمادي).
/// 📏 حشوة الصفحة (16 جانبيًا، 32 علويًا)، حجم عنوان البند 16 ونص البند 12،
/// المسافات بين العنوان والنص (8) وحول الفاصل (16).
class InfoPageScreen extends StatelessWidget {
  const InfoPageScreen({super.key, required this.type});

  final InfoPageType type;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          GalleryHeader(
            title: type.title,
            icon: null,
            onBack: () => Navigator.pop(context),
          ),
          Expanded(
            child: BlocBuilder<InfoPageCubit, BaseState<TermsModel>>(
              builder: (context, state) {
                if (state.stateValue == StateValue.loading) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.main600),
                  );
                }
                if (state.stateValue == StateValue.error) {
                  return AppLoadError(
                    message: state.errorMessage,
                    onRetry: context.read<InfoPageCubit>().load,
                  );
                }
                return _Sections(page: state.data!);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Sections extends StatelessWidget {
  const _Sections({required this.page});

  final TermsModel page;

  @override
  Widget build(BuildContext context) {
    final sections = page.sections;
    return ListView(
      padding: EdgeInsets.fromLTRB(16.w, 32.h, 16.w, 24.h), // 📏
      children: [
        for (var i = 0; i < sections.length; i++) ...[
          if (i > 0)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16.h), // 📏
              child: const Divider(height: 1, color: AppColors.grey50),
            ),
          if (sections[i].title != null)
            Padding(
              padding: EdgeInsets.only(bottom: 8.h), // 📏
              child: Text(
                sections[i].title!,
                style: AppTextStyles.font16Medium.copyWith(
                  color: AppColors.second500,
                ),
              ),
            ),
          if (sections[i].body.isNotEmpty)
            Text(
              sections[i].body,
              style: AppTextStyles.font12Regular.copyWith(
                color: AppColors.grey400,
              ),
            ),
        ],
      ],
    );
  }
}
