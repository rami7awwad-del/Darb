import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:darb/core/style/app_colors.dart';
import 'package:darb/core/style/app_text_styles.dart';
import 'package:darb/features/courses/data/models/course_details_model.dart';
import 'package:darb/core/models/base_state.dart';
import 'package:darb/core/models/enums/state_value.dart';
import 'package:darb/core/widgets/app_load_error.dart';
import 'package:darb/features/courses/presentation/lesson_access.dart';
import 'package:darb/features/lessons/data/models/lesson_details_model.dart';
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
  String? _videoId;

  /// الدرس من التفاصيل الموحّدة إن وصلت، وإلا من وسائط الفتح.
  CourseLessonModel _lessonOf(LessonDetailsModel? d) =>
      d?.lesson ?? widget.args.lesson;

  @override
  void initState() {
    super.initState();
    context.read<LessonCubit>().attend();
  }

  /// يُستدعى عند وصول lessions/details: يحدد رابط المحتوى ومعرّف الفيديو.
  void _applyDetails(LessonDetailsModel details) {
    final lesson = details.lesson;
    setState(() {
      _file = lesson.file;
      _videoId = !lesson.isFile && lesson.file.isNotEmpty
          ? YoutubePlayerController.convertUrlToId(lesson.file)
          : null;
    });
  }

  /// المشغّل داخل التطبيق لا يُنشأ إلا عند الضغط على تشغيل، فلا يعلّق فتح الشاشة.
  void _play() {
    final id = _videoId;
    if (id == null || _yt != null) return;
    // مثل تنفيذ الزميل: الإطار من youtube.com لا youtube-nocookie.com، لأن
    // السكربت يأتي من youtube.com أصلًا ولا يُحَلّ النطاق الثاني دائمًا.
    final controller = YoutubePlayerController(
      params: const YoutubePlayerParams(
        showFullscreenButton: true,
        interfaceLanguage: 'ar',
        privacyEnhancedMode: false,
      ),
      onWebResourceError: (error) {
        final path = Uri.tryParse(error.url ?? '')?.path ?? '';
        final fatal = (error.isForMainFrame ?? false) ||
            path == '/iframe_api' ||
            path.startsWith('/embed') ||
            path.endsWith('/www-widgetapi.js');
        if (fatal) _fail();
      },
    )..loadVideoById(videoId: id);
    setState(() => _yt = controller);
  }

  /// فشل تحميل المشغّل: نرجع للغلاف (وفيه زر الفتح في يوتيوب).
  void _fail() {
    WidgetsBinding.instance
      ..addPostFrameCallback((_) {
        if (!mounted) return;
        _yt?.close();
        setState(() => _yt = null);
      })
      ..ensureVisualUpdate();
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

  /// الانتقال لدرس آخر من "مسار التعلم" مع قيود الوصول (اشتراك / أكمل السابق).
  void _openLesson(
    CourseLessonModel next,
    List<CourseLessonModel> lessons,
    String semesterName,
    CourseLessonModel current,
  ) {
    if (next.id == current.id) return;
    openLessonWithAccess(
      context,
      lesson: next,
      lessons: lessons,
      semesterName: semesterName,
      replace: true,
    );
  }

  Widget _scaffold(
    BuildContext context,
    BaseState<CommentsData> state,
    Widget? player,
  ) {
    final cubit = context.read<LessonCubit>();
    final details = state.data?.details;
    final lesson = _lessonOf(details);
    // مسار التعلم من التفاصيل الموحّدة، وإلا من وسائط الفتح.
    final lessons = (details?.semesterLessons.isNotEmpty ?? false)
        ? details!.semesterLessons
        : widget.args.lessons;
    final semesterName = (details?.semesterName.isNotEmpty ?? false)
        ? details!.semesterName
        : widget.args.semesterName;
    final loading = details == null && state.stateValue != StateValue.error;
    final failed = details == null && state.stateValue == StateValue.error;
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        children: [
          _MediaHeader(
            clip: _yt == null,
            onBack: () => Navigator.pop(context),
            timeLabel: lesson.time,
            child: player != null
                ? AspectRatio(aspectRatio: 16 / 9, child: player)
                : _MediaPlaceholder(
                    loading: loading,
                    lesson: lesson,
                    hasLink: _file.isNotEmpty,
                    videoId: _videoId,
                    onPlay: _play,
                    onOpen: _openExternal,
                  ),
          ),
          Expanded(
            child: failed
                ? AppLoadError(message: state.errorMessage, onRetry: cubit.load)
                : RefreshIndicator(
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
                          if (semesterName.isNotEmpty) ...[
                            SizedBox(height: 8.h), // 📏
                            Text(
                              semesterName,
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
                              onTap: () => _openLesson(
                                lessons[i],
                                lessons,
                                semesterName,
                                lesson,
                              ),
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
    return BlocConsumer<LessonCubit, BaseState<CommentsData>>(
      listenWhen: (prev, curr) =>
          curr.data?.details != null &&
          !identical(prev.data?.details, curr.data?.details),
      listener: (context, state) => _applyDetails(state.data!.details!),
      builder: (context, state) {
        final yt = _yt;
        return _scaffold(
          context,
          state,
          yt == null ? null : YoutubePlayer(controller: yt),
        );
      },
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
    this.clip = true,
  });

  final bool clip;
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
          child: _maybeClip(
            clip,
            radius,
            Stack(
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

/// قصّ الحواف الدائرية يُتجاوز أثناء تشغيل يوتيوب: قصّ الـ WebView داخل صفحة
/// قابلة للتمرير يجمّد الصفحة أو يُظهرها سوداء (كما في تنفيذ الزميل).
Widget _maybeClip(bool clip, BorderRadius radius, Widget child) =>
    clip ? ClipRRect(borderRadius: radius, child: child) : child;
