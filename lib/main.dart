import 'package:darb/core/navigation/app_navigator.dart';
import 'package:darb/core/routing/app_routes.dart';
import 'package:darb/core/services/api_service.dart';
import 'package:darb/core/services/dio_factory.dart';
import 'package:darb/core/services/storage_service.dart';
import 'package:darb/core/style/app_colors.dart';
import 'package:darb/core/style/app_text_styles.dart';
import 'package:darb/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:darb/features/auth/data/datasources/registration_remote_data_source.dart';
import 'package:darb/features/auth/data/repositories/auth_repository.dart';
import 'package:darb/features/auth/data/repositories/registration_repository.dart';
import 'package:darb/features/profile/data/repositories/profile_repository.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:darb/features/home/data/datasources/home_remote_data_source.dart';
import 'package:darb/features/home/data/repositories/home_repository.dart';
import 'package:darb/features/gallery/data/datasources/gallery_remote_data_source.dart';
import 'package:darb/features/gallery/data/repositories/gallery_repository.dart';
import 'package:darb/features/courses/data/datasources/courses_remote_data_source.dart';
import 'package:darb/features/courses/data/repositories/courses_repository.dart';
import 'package:darb/features/lessons/data/datasources/lessons_remote_data_source.dart';
import 'package:darb/features/lessons/data/repositories/lessons_repository.dart';
import 'package:darb/features/library/data/datasources/library_remote_data_source.dart';
import 'package:darb/features/library/data/repositories/library_repository.dart';
import 'package:darb/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:darb/features/support/data/datasources/support_remote_data_source.dart';
import 'package:darb/features/support/data/repositories/support_repository.dart';
import 'package:darb/features/subjects/data/datasources/subjects_remote_data_source.dart';
import 'package:darb/features/subjects/data/repositories/subjects_repository.dart';
import 'package:darb/features/notifications/data/datasources/notifications_remote_data_source.dart';
import 'package:darb/features/notifications/data/repositories/notifications_repository.dart';

import 'package:darb/features/quiz/data/datasources/quiz_remote_data_source.dart';
import 'package:darb/features/quiz/data/repositories/quiz_repository.dart';
import 'package:darb/features/subscription/data/datasources/subscription_remote_data_source.dart';
import 'package:darb/features/subscription/data/repositories/subscription_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Allow both portrait and landscape.
  await SystemChrome.setPreferredOrientations(DeviceOrientation.values);

  // Storage must be ready before Dio is created so the token is available on the first request.
  final storageService = StorageService();
  await storageService.init();

  final dio = DioFactory(
    storageService,
    // Send the user back to login when the server rejects the token.
    onUnauthorized: () {
      navigatorKey.currentState?.pushNamedAndRemoveUntil(
        AppRoutes.login,
        (_) => false,
      );
    },
  ).getDio();
  final apiService = ApiService(dio);

  final authRemoteDataSource = AuthRemoteDataSource(apiService);
  final authRepository = AuthRepository(authRemoteDataSource, storageService);

  final registrationRepository = RegistrationRepository(
    RegistrationRemoteDataSource(apiService),
  );

  final homeRepository = HomeRepository(HomeRemoteDataSource(apiService));
  final profileRepository = ProfileRepository(
    ProfileRemoteDataSource(apiService),
  );
  final galleryRepository = GalleryRepository(
    GalleryRemoteDataSource(apiService),
  );
  final libraryRepository = LibraryRepository(
    LibraryRemoteDataSource(apiService),
  );
  final supportRepository = SupportRepository(
    SupportRemoteDataSource(apiService),
  );
  final subjectsRepository = SubjectsRepository(
    SubjectsRemoteDataSource(apiService),
  );
  final notificationsRepository = NotificationsRepository(
    NotificationsRemoteDataSource(apiService),
  );
  final coursesRepository = CoursesRepository(
    CoursesRemoteDataSource(apiService),
  );
  final lessonsRepository = LessonsRepository(
    LessonsRemoteDataSource(apiService),
  );
  final quizRepository = QuizRepository(QuizRemoteDataSource(apiService));
  final subscriptionRepository = SubscriptionRepository(
    SubscriptionRemoteDataSource(apiService),
  );

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<HomeRepository>.value(value: homeRepository),
        RepositoryProvider<ProfileRepository>.value(value: profileRepository),
        RepositoryProvider<GalleryRepository>.value(value: galleryRepository),
        RepositoryProvider<LibraryRepository>.value(value: libraryRepository),
        RepositoryProvider<SupportRepository>.value(value: supportRepository),
        RepositoryProvider<SubjectsRepository>.value(value: subjectsRepository),
        RepositoryProvider<NotificationsRepository>.value( value: notificationsRepository,),
        RepositoryProvider<CoursesRepository>.value(value: coursesRepository),
        RepositoryProvider<LessonsRepository>.value(value: lessonsRepository),
        RepositoryProvider<QuizRepository>.value(value: quizRepository),
        RepositoryProvider<SubscriptionRepository>.value( value: subscriptionRepository,),
        RepositoryProvider<StorageService>.value(value: storageService),
        RepositoryProvider<ApiService>.value(value: apiService),
        RepositoryProvider<AuthRemoteDataSource>.value( value: authRemoteDataSource,),
        RepositoryProvider<AuthRepository>.value(value: authRepository),
        RepositoryProvider<RegistrationRepository>.value( value: registrationRepository,),
      ],
      child: const MyApp(),
    ),
  );
}

/// Root widget of the app.
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

/// Keeps the screen scale in sync with the orientation.
class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  // Design sizes taken from the Figma frames.
  static const Size _portraitDesign = Size(430, 932);
  static const Size _landscapeDesign = Size(932, 430);

  bool _isLandscape = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _isLandscape = _readLandscape();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  // Rebuild only when the orientation really changes.
  void didChangeMetrics() {
    final landscape = _readLandscape();
    if (landscape != _isLandscape) {
      setState(() => _isLandscape = landscape);
    }
  }

  /// Reads landscape.
  bool _readLandscape() {
    final views = WidgetsBinding.instance.platformDispatcher.views;
    if (views.isEmpty) return false;
    final size = views.first.physicalSize;
    return size.width > size.height;
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      // Swap the design size in landscape so width and height scale evenly.
      designSize: _isLandscape ? _landscapeDesign : _portraitDesign,
      minTextAdapt: true,
      // Split screen mode would inflate heights in landscape.
      splitScreenMode: false,
      builder: (context, child) {
        return MaterialApp(
          navigatorKey: navigatorKey,
          debugShowCheckedModeBanner: false,
          title: 'Darb',
          // The app is Arabic only, so the layout is right to left.
          locale: const Locale('ar'),
          supportedLocales: const [Locale('ar')],
          initialRoute: AppRoutes.splash,
          onGenerateRoute: AppRouter.onGenerateRoute,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          theme: ThemeData(
            scaffoldBackgroundColor: AppColors.white,
            fontFamily: AppTextStyles.fontFamily,
            primaryColor: AppColors.primary,
            colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary)
                .copyWith(
                  primary: AppColors.primary,
                  secondary: AppColors.secondary,
                  error: AppColors.danger,
                ),
          ),
        );
      },
    );
  }
}
