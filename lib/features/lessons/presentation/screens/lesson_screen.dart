import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:darb/core/style/app_colors.dart';
import 'package:darb/core/style/app_text_styles.dart';
import 'package:darb/features/courses/data/models/course_details_model.dart';
import 'package:darb/features/lessons/data/repositories/lessons_repository.dart';
import 'package:darb/core/routing/app_routes.dart';
import 'package:darb/features/courses/presentation/widgets/lesson_timeline_tile.dart';
import 'package:darb/features/lessons/presentation/cubit/lesson_cubit.dart';
import 'package:darb/features/lessons/presentation/widgets/comments_section.dart';

/// وسائط شاشة الدرس: الدرس الحالي + فصله (لعرض "مسار التعلم" أسفل الشاشة).
class LessonArgs {
  const LessonArgs({
    required this.lesson,
    this.semesterName = '',
    this.lessons = const [],
  });

  final CourseLessonModel lesson;
  final String semesterName;
  final List<CourseLessonModel> lessons;
}

/// شاشة الدرس حسب الفيغما: مشغّل الفيديو في الأعلى بحواف سفلية دائرية، ثم
/// النقاشات + حقل التعليق، ثم "مسار التعلم" لدروس الفصل.
/// ⚠️ إن جاء `file` فارغًا من courses/details نجلبه من lessions/details.
class LessonScreen extends StatefulWidget {
  const LessonScreen({super.key, required this.args});

  final LessonArgs args;

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  YoutubePlayerController? _yt;
  String _file = '';
  bool _resolving = true;
  String? _videoId;

  CourseLessonModel get _lesson => widget.args.lesson;

  @override
  void initState() {
    super.initState();
    context.read<LessonCubit>().attend();
    _resolve();
  }

  Future<void> _resolve() async {
    var file = _lesson.file;
    if (file.isEmpty) {
      try {
        file = await context.read<LessonsRepository>().getLessonFile(_lesson.id);
      } catch (_) {}
    }
    if (!mounted) return;
    setState(() {
      _file = file;
      _resolving = false;
      if (!_lesson.isFile && file.isNotEmpty) {
        _videoId = YoutubePlayerController.convertUrlToId(file);
      }
    });
  }

  /// المشغّل داخل التطبيق لا يُنشأ إلا عند الضغط على تشغيل، فلا يعلّق فتح الشاشة.
  void _play() {
    final id = _videoId;
    if (id == null || _yt != null) return;
    setState(() {
      _yt = YoutubePlayerController.fromVideoId(
        videoId: id,
        autoPlay: true,
        params: const YoutubePlayerParams(
          showControls: true,
          showFullscreenButton: true,
        ),
      );
    });
  }

  @override
  void deactivate() {
    _yt?.pauseVideo();
    super.deactivate();
  }

  @override
  void dispose() {
    _yt?.close();
    super.dispose();
  }

  Future<void> _openExternal() async {
    final uri = Uri.tryParse(_file);
    final ok = uri != null &&
        await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('تعذر فتح الرابط')));
    }
  }

  void _openLesson(CourseLessonModel next) {
    if (next.id == _lesson.id) return;
    if (next.isLocked) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('هذا الدرس مقفل، اشترك في الدورة لفتحه')),
        );
      return;
    }
    Navigator.pushReplacementNamed(
      context,
      AppRoutes.lesson,
      arguments: LessonArgs(
        lesson: next,
        semesterName: widget.args.semesterName,
        lessons: widget.args.lessons,
      ),
    );
  }

  Widget _scaffold(BuildContext context, Widget? player) {
    final cubit = context.read<LessonCubit>();
    final lessons = widget.args.lessons;
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        children: [
          _MediaHeader(
            onBack: () => Navigator.pop(context),
            timeLabel: _lesson.time,
            child: player != null
                ? AspectRatio(aspectRatio: 16 / 9, child: player)
                : _MediaPlaceholder(
                  loading: _resolving,
                  lesson: _lesson,
                  hasLink: _file.isNotEmpty,
                  videoId: _videoId,
                  onPlay: _play,
                  onOpen: _openExternal,
                ),
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
                    _lesson.name,
                    style: AppTextStyles.font16Medium.copyWith(
                      color: AppColors.main600,
                    ),
                  ),
                  SizedBox(height: 16.h), // 📏
                  const CommentsSection(),
                  SizedBox(height: 12.h), // 📏
                  const CommentInput(),
                  if (lessons.isNotEmpty) ...[
                    SizedBox(height: 24.h), // 📏
                    Row(
                      spacing: 8.w, // 📏
                      children: [
                        Text(
                          'مسار التعلم',
                          style: AppTextStyles.font20Bold.copyWith(
                            color: AppColors.grey700,
                          ),
                        ),
                        Icon(
                          Icons.route_outlined,
                          size: 22.w, // 📏
                          color: AppColors.second500,
                        ),
                      ],
                    ),
                    if (widget.args.semesterName.isNotEmpty) ...[
                      SizedBox(height: 8.h), // 📏
                      Text(
                        widget.args.semesterName,
                        style: AppTextStyles.font12Regular.copyWith(
                          color: AppColors.second500,
                        ),
                      ),
                    ],
                    SizedBox(height: 12.h), // 📏
                    for (var i = 0; i < lessons.length; i++)
                      LessonTimelineTile(
                        lesson: lessons[i],
                        isLast: i == lessons.length - 1,
                        onTap: () => _openLesson(lessons[i]),
                      ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final yt = _yt;
    if (yt == null) return _scaffold(context, null);
    return YoutubePlayer(
      controller: yt,
      builder: (context, player, controller) => _scaffold(context, player),
    );
  }
}

/// منطقة الوسائط أعلى الشاشة: خلفية سوداء بحواف سفلية دائرية، سهم الرجوع،
/// وشارة مدة الدرس (كما في الفيغما).
class _MediaHeader extends StatelessWidget {
  const _MediaHeader({
    required this.child,
    required this.onBack,
    required this.timeLabel,
  });

  final Widget child;
  final VoidCallback onBack;
  final String timeLabel;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.vertical(bottom: Radius.circular(24.r)); // 📏
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(color: Colors.black, borderRadius: radius),
        child: SafeArea(
          bottom: false,
          child: ClipRRect(
            borderRadius: radius,
            child: Stack(
              children: [
                child,
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
                if (timeLabel.isNotEmpty)
                  PositionedDirectional(
                    top: 12.h, // 📏
                    end: 12.w, // 📏
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ), // 📏
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(8.r), // 📏
                      ),
                      child: Text(
                        timeLabel,
                        style: AppTextStyles.font12Regular.copyWith(
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

/// بديل المشغّل (16:9) عند غياب فيديو يوتيوب: تحميل، أو ملف/رابط خارجي، أو لا محتوى.
class _MediaPlaceholder extends StatelessWidget {
  const _MediaPlaceholder({
    required this.loading,
    required this.lesson,
    required this.hasLink,
    required this.onOpen,
    this.videoId,
    this.onPlay,
  });

  final String? videoId;
  final VoidCallback? onPlay;

  final bool loading;
  final CourseLessonModel lesson;
  final bool hasLink;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Center(
        child: loading
            ? const CircularProgressIndicator(color: AppColors.white)
            : videoId != null
                ? _Thumbnail(
                    videoId: videoId!,
                    onPlay: onPlay!,
                    onOpen: onOpen,
                  )
            : hasLink
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 8.h, // 📏
                    children: [
                      Icon(
                        lesson.isFile
                            ? Icons.description_outlined
                            : Icons.play_circle_outline_rounded,
                        size: 48.w, // 📏
                        color: AppColors.white,
                      ),
                      TextButton.icon(
                        onPressed: onOpen,
                        icon: const Icon(
                          Icons.open_in_new_rounded,
                          color: AppColors.main400,
                        ),
                        label: Text(
                          lesson.isFile ? 'فتح الملف' : 'فتح الرابط',
                          style: AppTextStyles.font14Medium.copyWith(
                            color: AppColors.main400,
                          ),
                        ),
                      ),
                    ],
                  )
                : Text(
                    'لا يوجد محتوى لهذا الدرس',
                    style: AppTextStyles.font14Medium.copyWith(
                      color: AppColors.grey100,
                    ),
                  ),
      ),
    );
  }
}

/// غلاف الفيديو (صورة يوتيوب المصغّرة) مع زر تشغيل داخل التطبيق وزر فتح في يوتيوب.
class _Thumbnail extends StatelessWidget {
  const _Thumbnail({
    required this.videoId,
    required this.onPlay,
    required this.onOpen,
  });

  final String videoId;
  final VoidCallback onPlay;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(
          'https://img.youtube.com/vi/$videoId/hqdefault.jpg',
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const ColoredBox(color: Colors.black),
        ),
        const ColoredBox(color: Colors.black26),
        Center(
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onPlay,
            child: Icon(
              Icons.play_circle_fill_rounded,
              size: 64.w, // 📏
              color: AppColors.white,
            ),
          ),
        ),
        PositionedDirectional(
          bottom: 8.h, // 📏
          end: 8.w, // 📏
          child: TextButton.icon(
            onPressed: onOpen,
            icon: Icon(Icons.open_in_new_rounded,
                size: 16.w, color: AppColors.white),
            label: Text(
              'فتح في يوتيوب',
              style: AppTextStyles.font12Regular.copyWith(
                color: AppColors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
