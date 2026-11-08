import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:darb/core/models/base_state.dart';
import 'package:darb/core/models/enums/state_value.dart';
import 'package:darb/core/style/app_colors.dart';
import 'package:darb/core/style/app_text_styles.dart';
import 'package:darb/core/widgets/app_load_error.dart';
import 'package:darb/features/gallery/presentation/widgets/gallery_header.dart';
import 'package:darb/features/support/data/models/faq_model.dart';
import 'package:darb/features/support/presentation/cubit/faqs_cubit.dart';

/// Screen that shows the faqs.
class FaqsScreen extends StatelessWidget {
  const FaqsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          GalleryHeader(
            title: 'الأسئلة الشائعة',
            icon: null,
            onBack: () => Navigator.pop(context),
          ),
          Expanded(
            child: BlocBuilder<FaqsCubit, BaseState<List<FaqModel>>>(
              builder: (context, state) {
                if (state.stateValue == StateValue.loading) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.main600),
                  );
                }
                if (state.stateValue == StateValue.error) {
                  return AppLoadError(
                    message: state.errorMessage,
                    onRetry: context.read<FaqsCubit>().load,
                  );
                }
                final faqs = state.data!;
                if (faqs.isEmpty) {
                  return Center(
                    child: Text(
                      'لا توجد أسئلة حاليًا',
                      style: AppTextStyles.font14Regular.copyWith(
                        color: AppColors.grey300,
                      ),
                    ),
                  );
                }
                return _FaqList(faqs: faqs);
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// List widget for the faq.
class _FaqList extends StatefulWidget {
  const _FaqList({required this.faqs});

  final List<FaqModel> faqs;

  @override
  State<_FaqList> createState() => _FaqListState();
}

/// State for the faq list widget.
class _FaqListState extends State<_FaqList> {
  int? _openId;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.main600,
      onRefresh: context.read<FaqsCubit>().load,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
        itemCount: widget.faqs.length,
        separatorBuilder: (context, _) =>
            const Divider(height: 1, color: AppColors.grey50),
        itemBuilder: (context, i) {
          final faq = widget.faqs[i];
          return _FaqTile(
            faq: faq,
            open: _openId == faq.id,
            onTap: () => setState(() => _openId = _openId == faq.id ? null : faq.id),
          );
        },
      ),
    );
  }
}

/// List tile widget for the faq.
class _FaqTile extends StatelessWidget {
  const _FaqTile({required this.faq, required this.open, required this.onTap});

  final FaqModel faq;
  final bool open;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: 48.h),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    faq.question,
                    style: AppTextStyles.font14Regular.copyWith(
                      color: AppColors.grey500,
                    ),
                  ),
                ),
                AnimatedRotation(
                  turns: open ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 20.w,
                    color: AppColors.second500,
                  ),
                ),
              ],
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          alignment: Alignment.topCenter,
          child: open
              ? Padding(
                  padding: EdgeInsets.only(bottom: 12.h, top: 4.h),
                  child: Text(
                    faq.answer,
                    style: AppTextStyles.font12Regular.copyWith(
                      color: AppColors.second500,
                    ),
                  ),
                )
              : const SizedBox(width: double.infinity),
        ),
      ],
    );
  }
}
