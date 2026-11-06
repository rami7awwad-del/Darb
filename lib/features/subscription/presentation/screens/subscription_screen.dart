import 'package:darb/core/models/base_state.dart';
import 'package:darb/core/models/enums/state_value.dart';
import 'package:darb/core/routing/app_routes.dart';
import 'package:darb/core/style/app_colors.dart';
import 'package:darb/core/style/app_text_styles.dart';
import 'package:darb/core/widgets/app_circle_close_button.dart';
import 'package:darb/core/widgets/app_load_error.dart';
import 'package:darb/core/widgets/app_network_image.dart';
import 'package:darb/core/widgets/app_primary_button.dart';
import 'package:darb/core/widgets/app_snack_bar.dart';
import 'package:darb/features/gallery/presentation/widgets/gallery_header.dart';
import 'package:darb/features/home/data/models/subject_model.dart';
import 'package:darb/features/subscription/presentation/cubit/subscription_cubit.dart';
import 'package:darb/features/subscription/presentation/screens/checkout_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Small private widget used only in this file.
enum _Option { year, free, codeSubject, codeCount }

/// Screen that shows the subscription.
class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

/// State for the subscription screen widget.
class _SubscriptionScreenState extends State<SubscriptionScreen> {
  final _subjectCode = TextEditingController();
  final _countCode = TextEditingController();
  _Option _selected = _Option.year;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _subjectCode.dispose();
    _countCode.dispose();
    super.dispose();
  }

  Future<void> _submit(SubscriptionData data) async {
    FocusScope.of(context).unfocus();
    switch (_selected) {
      case _Option.year:
        Navigator.pushNamed(
          context,
          AppRoutes.checkout,
          arguments: CheckoutArgs(methods: data.methods, total: '55,000'),
        );
      case _Option.free:
        showAppSnackBar(context, 'الباقة المجانية مفعلة تلقائيًا',
            isError: false);
      case _Option.codeSubject || _Option.codeCount:
        final code = _selected == _Option.codeSubject
            ? _subjectCode.text
            : _countCode.text;
        final error = await context.read<SubscriptionCubit>().redeem(code);
        if (!mounted) return;
        if (error != null) {
          showAppSnackBar(context, error);
          return;
        }
        showAppSnackBar(context, 'تم تفعيل الاشتراك بنجاح', isError: false);
        Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SubscriptionCubit>();
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        children: [
          GalleryHeader(
            title: 'الإشتراكات',
            icon: Icons.inventory_2_outlined,
            onBack: () => Navigator.pop(context),
          ),
          Expanded(
            child: BlocBuilder<SubscriptionCubit, BaseState<SubscriptionData>>(
              builder: (context, state) {
                if (state.stateValue == StateValue.error) {
                  return AppLoadError(
                    message: state.errorMessage,
                    onRetry: cubit.load,
                  );
                }
                final data = state.data;
                if (data == null) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.main600),
                  );
                }
                final all = <int, SubjectModel>{
                  for (final p in data.packages)
                    for (final s in p.subjects) s.id: s,
                }.values.toList();
                final free = all.where((s) => s.isFree).toList();

                return ListView(
                  padding: EdgeInsets.fromLTRB(16.w, 24.h, 16.w, 24.h),
                  children: [
                    _PlanCard(
                      title: 'سنة واحدة',
                      description: 'لتحصل على جميع الميزات التطبيق',
                      price: '55 الف ل.س',
                      priceSuffix: '/ سنة',
                      selected: _selected == _Option.year,
                      filled: true,
                      onTap: () => setState(() => _selected = _Option.year),
                      onDetails: () => _showSubjects(context, all),
                    ),
                    SizedBox(height: 16.h),
                    _PlanCard(
                      title: 'مجاني',
                      description: 'لتحصل على بعض الميزات التطبيق',
                      price: '0,0 ل.س',
                      priceSuffix: '/ 7 ايام تجربة',
                      selected: _selected == _Option.free,
                      filled: false,
                      onTap: () => setState(() => _selected = _Option.free),
                      onDetails: () => _showSubjects(context, free),
                    ),
                    SizedBox(height: 16.h),
                    _CodeField(
                      controller: _subjectCode,
                      hint: 'أكتب كود لمادة أو لمنهاج كامل',
                      selected: _selected == _Option.codeSubject,
                      onSelect: () =>
                          setState(() => _selected = _Option.codeSubject),
                    ),
                    SizedBox(height: 16.h),
                    _CodeField(
                      controller: _countCode,
                      hint: 'أكتب كود لعدد من المواد..',
                      selected: _selected == _Option.codeCount,
                      onSelect: () =>
                          setState(() => _selected = _Option.codeCount),
                    ),
                    SizedBox(height: 24.h),
                    AppPrimaryButton(
                      text: 'أشترك الان',
                      isLoading: data.redeeming,
                      onPressed: () => _submit(data),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget that shows the radio dot.
class _RadioDot extends StatelessWidget {
  const _RadioDot({required this.selected, this.light = false});

  final bool selected;
  final bool light;

  @override
  Widget build(BuildContext context) {
    final color = light ? AppColors.white : AppColors.main600;
    return Container(
      width: 22.w,
      height: 22.w,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 1.5),
      ),
      child: selected
          ? Container(
              width: 12.w,
              height: 12.w,
              decoration: BoxDecoration(
                color: light ? AppColors.grey50 : AppColors.main600,
                shape: BoxShape.circle,
              ),
            )
          : null,
    );
  }
}

/// Card widget for the plan.
class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.title,
    required this.description,
    required this.price,
    required this.priceSuffix,
    required this.selected,
    required this.filled,
    required this.onTap,
    required this.onDetails,
  });

  final String title;
  final String description;
  final String price;
  final String priceSuffix;
  final bool selected;

  final bool filled;
  final VoidCallback onTap;
  final VoidCallback onDetails;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(12.r);
    final titleColor = filled ? AppColors.white : AppColors.main600;
    final textColor = filled ? AppColors.white : AppColors.grey400;
    final priceColor = filled ? AppColors.white : AppColors.second500;
    return Material(
      color: filled ? AppColors.second500 : AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(
          color: filled
              ? AppColors.second500
              : (selected ? AppColors.main600 : AppColors.grey100),
        ),
      ),
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 8.h,
                  children: [
                    Row(
                      spacing: 8.w,
                      children: [
                        Text(
                          title,
                          style: AppTextStyles.font16Medium
                              .copyWith(color: titleColor),
                        ),
                        InkWell(
                          onTap: onDetails,
                          borderRadius: BorderRadius.circular(8.r),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8.r),
                              border: Border.all(color: AppColors.main600),
                            ),
                            child: Text(
                              'تفاصيل',
                              style: AppTextStyles.font12Regular
                                  .copyWith(color: AppColors.main600),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      description,
                      style:
                          AppTextStyles.font12Regular.copyWith(color: textColor),
                    ),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: price,
                            style: AppTextStyles.font16Medium
                                .copyWith(color: priceColor),
                          ),
                          TextSpan(
                            text: ' $priceSuffix',
                            style: AppTextStyles.font12Regular
                                .copyWith(color: priceColor),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12.w),
              _RadioDot(selected: selected, light: filled),
            ],
          ),
        ),
      ),
    );
  }
}

/// Input field widget for the code.
class _CodeField extends StatelessWidget {
  const _CodeField({
    required this.controller,
    required this.hint,
    required this.selected,
    required this.onSelect,
  });

  final TextEditingController controller;
  final String hint;
  final bool selected;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52.h,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(11.r),
        border: Border.all(
          color: selected ? AppColors.main600 : AppColors.grey100,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              onTap: onSelect,
              onChanged: (_) => onSelect(),
              textInputAction: TextInputAction.done,
              style: AppTextStyles.font12Regular
                  .copyWith(color: AppColors.grey500),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: AppTextStyles.font12Regular
                    .copyWith(color: AppColors.grey300),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          GestureDetector(
            onTap: onSelect,
            child: _RadioDot(selected: selected),
          ),
        ],
      ),
    );
  }
}

/// Shows subjects.
void _showSubjects(BuildContext context, List<SubjectModel> subjects) {
  showDialog<void>(
    context: context,
    builder: (ctx) => Dialog(
      backgroundColor: AppColors.white,
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'المواد المتاحة',
                    style: AppTextStyles.font16Medium
                        .copyWith(color: AppColors.grey500),
                  ),
                ),
                AppCircleCloseButton(onTap: () => Navigator.pop(ctx)),
              ],
            ),
            SizedBox(height: 16.h),
            if (subjects.isEmpty)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 24.h),
                child: Center(
                  child: Text(
                    'لا توجد مواد',
                    style: AppTextStyles.font14Regular
                        .copyWith(color: AppColors.grey300),
                  ),
                ),
              )
            else
              Flexible(
                child: GridView.builder(
                  shrinkWrap: true,
                  itemCount: subjects.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12.w,
                    mainAxisSpacing: 12.h,
                    mainAxisExtent: 80.h,
                  ),
                  itemBuilder: (_, i) => Container(
                    decoration: BoxDecoration(
                      color: AppColors.second100,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    padding: EdgeInsets.all(8.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      spacing: 4.h,
                      children: [
                        Text(
                          subjects[i].name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.font12Medium
                              .copyWith(color: AppColors.grey500),
                        ),
                        ClipOval(
                          child: AppNetworkImage(
                            url: subjects[i].image,
                            width: 36.w,
                            height: 36.w,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    ),
  );
}
