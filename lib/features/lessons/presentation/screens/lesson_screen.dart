import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:darb/core/style/app_colors.dart';
import 'package:darb/core/style/app_text_styles.dart';
import 'package:darb/core/widgets/app_primary_button.dart';
import 'package:darb/features/courses/data/models/course_details_model.dart';
import 'package:darb/features/gallery/presentation/widgets/gallery_header.dart';
import 'package:darb/features/lessons/presentation/cubit/lesson_cubit.dart';
import 'package:darb/features/lessons/presentation/widgets/comments_section.dart';

/// شاشة الدرس:
/// - فيديو يوتيوب: يُشغَّل داخل التطبيق.
/// - ملف (type = File) أو رابط غير يوتيوب: بطاقة بزر فتح عبر url_launcher.
/// ثم قسم النقاشات (تعليقات الدرس) وحقل الكتابة.
/// ⚠️ مصدر المحتوى هو حقل `file` في الدرس (courses/details)؛ فـ endpoints
/// lessions/details و yt-dlp غير مستخدمة. يتطلب LessonCubit في الشجرة.
class LessonScreen extends StatefulWidget {
  const LessonScreen({super.key, required this.lesson});

  final CourseLessonModel lesson;

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  YoutubePlayerController? _yt;

  @override
  void initState() {
    super.initState();
    context.read<LessonCubit>().attend();
    final lesson = widget.lesson;
    if (!lesson.isFile) {
      final id = YoutubePlayer.convertUrlToId(lesson.file);
      if (id != null) {
        _yt = YoutubePlayerController(
          initialVideoId: id,
          flags: const YoutubePlayerFlags(autoPlay: false),
        );
      }
    }
  }

  @override
  void deactivate() {
    _yt?.pause();
    super.deactivate();
  }

  @override
  void dispose() {
    _yt?.dispose();
    super.dispose();
  }

  Future<void> _openExternal() async {
    final uri = Uri.tryParse(widget.lesson.file);
    final ok = uri != null &&
        await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('تعذر فتح الرابط')));
    }
  }

  Widget _scaffold(BuildContext context, Widget? player) {
    final lesson = widget.lesson;
    final cubit = context.read<LessonCubit>();
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        children: [
          if (player != null)
            _PlayerHeader(
              player: player,
              onBack: () => Navigator.pop(context),
            )
          else
            GalleryHeader(
              title: 'الدرس',
              icon: null,
              onBack: () => Navigator.pop(context),
            ),
          Expanded(
            child: RefreshIndicator(
              color: AppColors.main600,
              onRefresh: () => cubit.load(silent: true),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h), // 📏
                children: [
                  Text(
                    lesson.name,
                    style: AppTextStyles.font16Medium.copyWith(
                      color: AppColors.main600,
                    ),
                  ),
                  SizedBox(height: 16.h), // 📏
                  if (player == null) ...[
                    _ContentCard(lesson: lesson, onOpen: _openExternal),
                    SizedBox(height: 24.h), // 📏
                  ],
                  const CommentsSection(),
                ],
              ),
            ),
          ),
          const CommentInput(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final yt = _yt;
    if (yt == null) return _scaffold(context, null);
    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller: yt,
        showVideoProgressIndicator: true,
        progressIndicatorColor: AppColors.main600,
      ),
      builder: (context, player) => _scaffold(context, player),
    );
  }
}

class _PlayerHeader extends StatelessWidget {
  const _PlayerHeader({required this.player, required this.onBack});

  final Widget player;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(24.r)),
        ),
        child: SafeArea(
          bottom: false,
          child: ClipRRect(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(24.r)),
            child: Stack(
              children: [
                player,
                PositionedDirectional(
                  top: 8.h, // 📏
                  start: 8.w, // 📏
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: onBack,
                    child: Padding(
                      padding: EdgeInsets.all(8.w), // 📏
                      child: Icon(
                        Icons.arrow_back_rounded,
                        size: 24.w, // 📏
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ContentCard extends StatelessWidget {
  const _ContentCard({required this.lesson, required this.onOpen});

  final CourseLessonModel lesson;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final hasLink = lesson.file.isNotEmpty;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w), // 📏
      decoration: BoxDecoration(
        color: AppColors.second50,
        borderRadius: BorderRadius.circular(16.r), // 📏
        border: Border.all(color: AppColors.second100),
      ),
      child: Column(
        spacing: 12.h, // 📏
        children: [
          Icon(
            lesson.isFile
                ? Icons.description_outlined
                : Icons.play_circle_outline_rounded,
            size: 48.w, // 📏
            color: AppColors.second500,
          ),
          Text(
            hasLink
                ? (lesson.isFile ? 'ملف الدرس' : 'رابط الدرس')
                : 'لا يوجد محتوى لهذا الدرس',
            style: AppTextStyles.font14Medium.copyWith(
              color: AppColors.second700,
            ),
          ),
          if (hasLink)
            AppPrimaryButton(
              text: lesson.isFile ? 'فتح الملف' : 'فتح الرابط',
              icon: Icon(Icons.open_in_new_rounded, size: 18.w, color: AppColors.white),
              onPressed: onOpen,
            ),
        ],
      ),
    );
  }
}
