import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:darb/core/models/base_state.dart';
import 'package:darb/core/models/enums/state_value.dart';
import 'package:darb/core/style/app_colors.dart';
import 'package:darb/core/style/app_text_styles.dart';
import 'package:darb/core/widgets/app_load_error.dart';
import 'package:darb/core/widgets/app_network_image.dart';
import 'package:darb/features/lessons/data/models/comment_model.dart';
import 'package:darb/features/lessons/presentation/cubit/lesson_cubit.dart';

/// قسم "النقاشات": قائمة التعليقات وزر "عرض المزيد". حقل الكتابة في CommentInput.
class CommentsSection extends StatelessWidget {
  const CommentsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<LessonCubit>();
    return BlocBuilder<LessonCubit, BaseState<CommentsData>>(
      builder: (context, state) {
        final data = state.data!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              spacing: 8.w, // 📏
              children: [
                Text(
                  'النقاشات',
                  style: AppTextStyles.font20Bold.copyWith(
                    color: AppColors.grey700,
                  ),
                ),
                Icon(
                  Icons.forum_outlined,
                  size: 22.w, // 📏
                  color: AppColors.second500,
                ),
              ],
            ),
            SizedBox(height: 16.h), // 📏
            if (state.stateValue == StateValue.loading)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 24.h), // 📏
                child: const Center(
                  child: CircularProgressIndicator(color: AppColors.main600),
                ),
              )
            else if (state.stateValue == StateValue.error)
              AppLoadError(message: state.errorMessage, onRetry: cubit.load)
            else if (data.comments.isEmpty)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 24.h), // 📏
                child: Center(
                  child: Text(
                    'لا توجد تعليقات بعد، كن أول من يعلّق',
                    style: AppTextStyles.font14Regular.copyWith(
                      color: AppColors.grey300,
                    ),
                  ),
                ),
              )
            else ...[
              for (final c in data.comments) ...[
                _CommentTile(comment: c),
                SizedBox(height: 12.h), // 📏
              ],
              if (data.hasMore)
                Center(
                  child: data.loadingMore
                      ? const CircularProgressIndicator(
                          color: AppColors.main600,
                        )
                      : TextButton(
                          onPressed: cubit.loadMore,
                          child: Text(
                            'عرض المزيد',
                            style: AppTextStyles.font14Medium.copyWith(
                              color: AppColors.second500,
                            ),
                          ),
                        ),
                ),
            ],
          ],
        );
      },
    );
  }
}

class _CommentTile extends StatelessWidget {
  const _CommentTile({required this.comment});

  final CommentModel comment;

  @override
  Widget build(BuildContext context) {
    final size = 36.w; // 📏
    return Container(
      padding: EdgeInsets.all(12.w), // 📏
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(11.r), // 📏
        border: Border.all(color: AppColors.grey50),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12.w, // 📏
        children: [
          ClipOval(
            child: AppNetworkImage(
              url: comment.userImage,
              width: size,
              height: size,
              fit: BoxFit.cover,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 4.h, // 📏
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        comment.userName.isEmpty ? 'مستخدم' : comment.userName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.font14Medium.copyWith(
                          color: AppColors.grey700,
                        ),
                      ),
                    ),
                    Text(
                      comment.dateLabel,
                      style: AppTextStyles.font12Regular.copyWith(
                        color: AppColors.grey200,
                      ),
                    ),
                  ],
                ),
                Text(
                  comment.text,
                  style: AppTextStyles.font14Regular.copyWith(
                    color: AppColors.grey400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// حقل كتابة تعليق مع زر إرسال، ثابت أسفل الشاشة.
class CommentInput extends StatefulWidget {
  const CommentInput({super.key});

  @override
  State<CommentInput> createState() => _CommentInputState();
}

class _CommentInputState extends State<CommentInput> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    final error = await context.read<LessonCubit>().send(text);
    if (!mounted) return;
    if (error == null) {
      _controller.clear();
      FocusScope.of(context).unfocus();
    } else {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(error)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final sending = context.select<LessonCubit, bool>(
      (c) => c.state.data?.sending ?? false,
    );
    return Container(
      color: AppColors.white,
      child: SafeArea(
        top: false,
        child: Row(
          spacing: 8.w, // 📏
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                minLines: 1,
                maxLines: 3,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _send(),
                style: AppTextStyles.font14Regular,
                decoration: InputDecoration(
                  hintText: 'اكتب تعليقك...',
                  hintStyle: AppTextStyles.font14Regular.copyWith(
                    color: AppColors.grey200,
                  ),
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ), // 📏
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(11.r), // 📏
                    borderSide: const BorderSide(color: AppColors.grey50),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(11.r), // 📏
                    borderSide: const BorderSide(color: AppColors.main600),
                  ),
                ),
              ),
            ),
            Material(
              color: AppColors.main600,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: sending ? null : _send,
                child: SizedBox(
                  width: 44.w, // 📏
                  height: 44.w, // 📏
                  child: sending
                      ? Padding(
                          padding: EdgeInsets.all(12.w),
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.white,
                          ),
                        )
                      : Icon(Icons.send_rounded, size: 20.w, color: AppColors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
