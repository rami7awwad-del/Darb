import 'package:darb/core/widgets/app_responsive.dart';
import 'package:darb/features/subscription/presentation/subscription_access.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:darb/core/models/base_state.dart';
import 'package:darb/core/models/enums/state_value.dart';
import 'package:darb/core/routing/app_routes.dart';
import 'package:darb/core/style/app_colors.dart';
import 'package:darb/core/style/app_text_styles.dart';
import 'package:darb/core/widgets/app_load_error.dart';
import 'package:darb/features/gallery/presentation/widgets/gallery_header.dart';
import 'package:darb/features/home/data/models/subject_model.dart';
import 'package:darb/features/subjects/presentation/cubit/subjects_cubit.dart';
import 'package:darb/features/subjects/presentation/widgets/subject_tile.dart';

/// Screen that shows the subjects.
class SubjectsScreen extends StatelessWidget {
  const SubjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          GalleryHeader(
            title: 'كل الفئات',
            icon: null,
            onBack: () => Navigator.pop(context),
          ),
          Expanded(
            child: BlocBuilder<SubjectsCubit, BaseState<List<SubjectModel>>>(
              builder: (context, state) {
                final cubit = context.read<SubjectsCubit>();
                if (state.stateValue == StateValue.loading) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.main600),
                  );
                }
                if (state.stateValue == StateValue.error) {
                  return AppLoadError(
                    message: state.errorMessage,
                    onRetry: cubit.load,
                  );
                }
                final subjects = state.data!;
                return RefreshIndicator(
                  color: AppColors.main600,
                  onRefresh: () => cubit.load(silent: true),
                  child: subjects.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            SizedBox(height: 120.h),
                            Center(
                              child: Text(
                                'لا توجد مواد حاليًا',
                                style: AppTextStyles.font14Regular.copyWith(
                                  color: AppColors.grey300,
                                ),
                              ),
                            ),
                          ],
                        )
                      : GridView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: EdgeInsets.fromLTRB(16.w, 24.h, 16.w, 24.h),
                          itemCount: subjects.length,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            // More columns in landscape.
                            crossAxisCount: gridColumnsOf(
                              context,
                              portrait: 3,
                              landscape: 5,
                            ),
                            crossAxisSpacing: 8.w,
                            mainAxisSpacing: 24.h,
                            mainAxisExtent: SubjectTile.height,
                          ),
                          itemBuilder: (context, i) => SubjectTile(
                            subject: subjects[i],
                            onTap: () => openSubjectWithAccess(context, subjects[i]),
                          ),
                        ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
