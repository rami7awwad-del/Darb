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



void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Storage: يجب أن يُهيَّأ قبل إنشاء Dio ليكون التوكن جاهزًا في أول طلب
  final storageService = StorageService();
  await storageService.init();

  // Network
  final dio = DioFactory(
    storageService,
    onUnauthorized: () {
      navigatorKey.currentState?.pushNamedAndRemoveUntil(
        AppRoutes.login,
        (_) => false,
      );
    },
  ).getDio();
  final apiService = ApiService(dio);

  

  final authRemoteDataSource = AuthRemoteDataSource(apiService);
  final authRepository = AuthRepository(
    authRemoteDataSource,
    storageService,

  );
  final registrationRepository = RegistrationRepository(
    RegistrationRemoteDataSource(apiService),
  );

final homeRepository = HomeRepository(HomeRemoteDataSource(apiService));
final profileRepository = ProfileRepository(ProfileRemoteDataSource(apiService));
final galleryRepository = GalleryRepository(GalleryRemoteDataSource(apiService));
final libraryRepository = LibraryRepository(LibraryRemoteDataSource(apiService));
final supportRepository = SupportRepository(SupportRemoteDataSource(apiService));
final subjectsRepository = SubjectsRepository(SubjectsRemoteDataSource(apiService));
final notificationsRepository = NotificationsRepository(NotificationsRemoteDataSource(apiService));
final coursesRepository = CoursesRepository(CoursesRemoteDataSource(apiService));
final lessonsRepository = LessonsRepository(LessonsRemoteDataSource(apiService));

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<HomeRepository>.value(value: homeRepository),
        RepositoryProvider<ProfileRepository>.value(value: profileRepository),
        RepositoryProvider<GalleryRepository>.value(value: galleryRepository),
        RepositoryProvider<LibraryRepository>.value(value: libraryRepository),
        RepositoryProvider<SupportRepository>.value(value: supportRepository),
        RepositoryProvider<SubjectsRepository>.value(value: subjectsRepository),
        RepositoryProvider<NotificationsRepository>.value(value: notificationsRepository),
        RepositoryProvider<CoursesRepository>.value(value: coursesRepository),
        RepositoryProvider<LessonsRepository>.value(value: lessonsRepository),
        RepositoryProvider<StorageService>.value(value: storageService),
        RepositoryProvider<ApiService>.value(value: apiService),
        RepositoryProvider<AuthRemoteDataSource>.value(value: authRemoteDataSource,),
        RepositoryProvider<AuthRepository>.value(value: authRepository),
        RepositoryProvider<RegistrationRepository>.value(value: registrationRepository,),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(430, 932), // أبعاد iPhone Pro Max من Figma
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          navigatorKey: navigatorKey,
          debugShowCheckedModeBanner: false,
          title: 'Darb',

          // التطبيق عربي فقط (RTL)
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
