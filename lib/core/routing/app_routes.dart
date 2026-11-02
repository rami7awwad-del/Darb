import 'package:darb/features/courses/data/repositories/courses_repository.dart';
import 'package:darb/features/courses/presentation/cubit/course_details_cubit.dart';
import 'package:darb/features/courses/presentation/screens/course_details_screen.dart';
import 'package:darb/features/courses/data/models/course_details_model.dart';
import 'package:darb/features/home/data/models/course_model.dart';
import 'package:darb/features/lessons/data/repositories/lessons_repository.dart';
import 'package:darb/features/lessons/presentation/cubit/lesson_cubit.dart';
import 'package:darb/features/lessons/presentation/screens/lesson_screen.dart';
import 'package:darb/features/quiz/data/models/quiz_models.dart';
import 'package:darb/features/quiz/presentation/cubit/quiz_cubit.dart';
import 'package:darb/features/quiz/presentation/screens/quiz_result_screen.dart';
import 'package:darb/features/quiz/presentation/screens/quiz_review_screen.dart';
import 'package:darb/features/quiz/presentation/screens/quiz_screen.dart';
import 'package:darb/features/achievements/presentation/cubit/achievements_cubit.dart';
import 'package:darb/features/achievements/presentation/screens/achievements_screen.dart';
import 'package:darb/features/auth/data/repositories/auth_repository.dart';
import 'package:darb/features/auth/data/repositories/registration_repository.dart';
import 'package:darb/features/auth/presentation/cubit/login/login_cubit.dart';
import 'package:darb/features/auth/presentation/cubit/otp/otp_cubit.dart';
import 'package:darb/features/auth/presentation/cubit/register/register_cubit.dart';
import 'package:darb/features/auth/presentation/screens/login_screen.dart';
import 'package:darb/features/auth/presentation/screens/otp_screen.dart';
import 'package:darb/features/auth/presentation/screens/register_screen.dart';
import 'package:darb/features/auth/presentation/screens/register_success_screen.dart';
import 'package:darb/features/downloads/presentation/screens/downloaded_courses_screen.dart';
import 'package:darb/features/gallery/data/models/gallery_model.dart';
import 'package:darb/features/gallery/data/repositories/gallery_repository.dart';
import 'package:darb/features/gallery/presentation/cubit/gallery_cubit.dart';
import 'package:darb/features/gallery/presentation/screens/gallery_album_screen.dart';
import 'package:darb/features/library/data/repositories/library_repository.dart';
import 'package:darb/features/library/presentation/cubit/library_cubit.dart';
import 'package:darb/features/home/data/repositories/home_repository.dart';
import 'package:darb/features/home/presentation/cubit/home_cubit.dart';
import 'package:darb/features/main/presentation/screens/main_layout_screen.dart';
import 'package:darb/features/notifications/data/repositories/notifications_repository.dart';
import 'package:darb/features/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:darb/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:darb/features/profile/data/repositories/profile_repository.dart';
import 'package:darb/features/home/data/models/subject_model.dart';
import 'package:darb/features/splash/splash_screen.dart';
import 'package:darb/features/subjects/data/repositories/subjects_repository.dart';
import 'package:darb/features/subjects/presentation/cubit/subject_details_cubit.dart';
import 'package:darb/features/subjects/presentation/cubit/subjects_cubit.dart';
import 'package:darb/features/subjects/presentation/screens/subject_details_screen.dart';
import 'package:darb/features/subjects/presentation/screens/subjects_screen.dart';
import 'package:darb/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:darb/features/support/data/models/info_page_type.dart';
import 'package:darb/features/support/data/repositories/support_repository.dart';
import 'package:darb/features/support/presentation/cubit/faqs_cubit.dart';
import 'package:darb/features/support/presentation/cubit/info_page_cubit.dart';
import 'package:darb/features/support/presentation/screens/faqs_screen.dart';
import 'package:darb/features/support/presentation/screens/info_page_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// أسماء المسارات. تُضاف هنا مسارات كل شاشة عند بنائها.
abstract class AppRoutes {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String otp = '/otp';
  static const String register = '/register';
  static const String registerSuccess = '/registerSuccess';
  static const String mainLayout = '/mainLayout';
  static const String galleryAlbum = '/galleryAlbum';
  static const String faqs = '/faqs';
  static const String infoPage = '/infoPage';
  static const String downloadedCourses = '/downloadedCourses';
  static const String achievements = '/achievements';
  static const String subjects = '/subjects';
  static const String subjectDetails = '/subjectDetails';
  static const String notifications = '/notifications';
  static const String courseDetails = '/courseDetails';
  static const String lesson = '/lesson';
  static const String quiz = '/quiz';
  static const String quizResult = '/quizResult';
  static const String quizReview = '/quizReview';
}

/// ربط أسماء المسارات بالشاشات.
/// - المعاملات تُمرَّر عبر settings.arguments.
/// - أنشئ BlocProvider الخاص بكل شاشة هنا عند الحاجة.
abstract class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute(
          builder: (_) => const SplashScreen(),
          settings: settings,
        );

      case AppRoutes.login:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => LoginCubit(context.read<AuthRepository>()),
            child: const LoginScreen(),
          ),
          settings: settings,
        );

      case AppRoutes.otp:
        final phone = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) =>
                OtpCubit(context.read<AuthRepository>(), phone: phone),
            child: OtpScreen(phone: phone),
          ),
          settings: settings,
        );

      case AppRoutes.register:
        final phone = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) =>
                RegisterCubit(context.read<RegistrationRepository>())
                  ..loadInitial(),
            child: RegisterScreen(phone: phone),
          ),
          settings: settings,
        );

      case AppRoutes.registerSuccess:
        return MaterialPageRoute(
          builder: (_) => const RegisterSuccessScreen(),
          settings: settings,
        );

      case AppRoutes.mainLayout:
        // Cubits التبويبات على مستوى المسار حتى تبقى بياناتها عند التنقل بين التبويبات.
        return MaterialPageRoute(
          builder: (_) => MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (context) => HomeCubit(
                  context.read<HomeRepository>(),
                  context.read<ProfileRepository>(),
                )..load(),
              ),
              BlocProvider(
                create: (context) =>
                    GalleryCubit(context.read<GalleryRepository>())..load(),
              ),
              BlocProvider(
                create: (context) =>
                    LibraryCubit(context.read<LibraryRepository>())..load(),
              ),
              BlocProvider(
                create: (context) =>
                    ProfileCubit(context.read<ProfileRepository>())..load(),
              ),
            ],
            child: const MainLayoutScreen(),
          ),
          settings: settings,
        );

      case AppRoutes.galleryAlbum:
        final album = settings.arguments as GalleryModel;
        return MaterialPageRoute(
          builder: (_) => GalleryAlbumScreen(album: album),
          settings: settings,
        );

      case AppRoutes.faqs:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) =>
                FaqsCubit(context.read<SupportRepository>())..load(),
            child: const FaqsScreen(),
          ),
          settings: settings,
        );

      case AppRoutes.infoPage:
        final type = settings.arguments as InfoPageType;
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) =>
                InfoPageCubit(context.read<SupportRepository>(), type: type)
                  ..load(),
            child: InfoPageScreen(type: type),
          ),
          settings: settings,
        );

      case AppRoutes.downloadedCourses:
        // TODO: مرّر العناصر من مخزن التنزيلات عند بنائه.
        return MaterialPageRoute(
          builder: (_) => const DownloadedCoursesScreen(),
          settings: settings,
        );

      case AppRoutes.achievements:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => AchievementsCubit(
              context.read<ProfileRepository>(),
              context.read<LibraryRepository>(),
            )..load(),
            child: const AchievementsScreen(),
          ),
          settings: settings,
        );

      case AppRoutes.notifications:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) =>
                NotificationsCubit(context.read<NotificationsRepository>())
                  ..load(),
            child: const NotificationsScreen(),
          ),
          settings: settings,
        );

      case AppRoutes.subjects:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) =>
                SubjectsCubit(context.read<SubjectsRepository>())..load(),
            child: const SubjectsScreen(),
          ),
          settings: settings,
        );

      case AppRoutes.subjectDetails:
        final subject = settings.arguments as SubjectModel;
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => SubjectDetailsCubit(
              context.read<SubjectsRepository>(),
              subjectId: subject.id,
            )..load(),
            child: SubjectDetailsScreen(subject: subject),
          ),
          settings: settings,
        );

      case AppRoutes.courseDetails:
        final course = settings.arguments as CourseModel;
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => CourseDetailsCubit(
              context.read<CoursesRepository>(),
              courseId: course.id,
            )..load(),
            child: CourseDetailsScreen(course: course),
          ),
          settings: settings,
        );

      case AppRoutes.lesson:
        final args = settings.arguments as LessonArgs;
        final lesson = args.lesson;
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => LessonCubit(
              context.read<LessonsRepository>(),
              lessonId: lesson.id,
            )..load(),
            child: LessonScreen(args: args),
          ),
          settings: settings,
        );

      case AppRoutes.quiz:
        final args = settings.arguments as QuizArgs;
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => QuizCubit(),
            child: QuizScreen(args: args),
          ),
          settings: settings,
        );

      case AppRoutes.quizResult:
        final outcome = settings.arguments as QuizOutcome;
        return MaterialPageRoute(
          builder: (_) => QuizResultScreen(outcome: outcome),
          settings: settings,
        );

      case AppRoutes.quizReview:
        final outcome = settings.arguments as QuizOutcome;
        return MaterialPageRoute(
          builder: (_) => QuizReviewScreen(outcome: outcome),
          settings: settings,
        );

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
