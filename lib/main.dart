import 'package:darb/core/navigation/app_navigator.dart';
import 'package:darb/core/routing/app_routes.dart';
import 'package:darb/core/services/api_service.dart';
import 'package:darb/core/services/dio_factory.dart';
import 'package:darb/core/services/firebase_notification_service.dart';
import 'package:darb/core/services/storage_service.dart';
import 'package:darb/core/style/app_colors.dart';
import 'package:darb/core/style/app_text_styles.dart';
import 'package:darb/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:darb/features/auth/data/datasources/registration_remote_data_source.dart';
import 'package:darb/features/auth/data/repositories/auth_repository.dart';
import 'package:darb/features/auth/data/repositories/registration_repository.dart';
import 'package:darb/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

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

  // Notifications
  final notificationService = FirebaseNotificationService();
  await notificationService.init();

  final authRemoteDataSource = AuthRemoteDataSource(apiService);
  final authRepository = AuthRepository(
    authRemoteDataSource,
    storageService,
    notificationService,
  );
  final registrationRepository = RegistrationRepository(
    RegistrationRemoteDataSource(apiService),
  );

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<StorageService>.value(value: storageService),
        RepositoryProvider<ApiService>.value(value: apiService),
        RepositoryProvider<FirebaseNotificationService>.value(
          value: notificationService,
        ),
        RepositoryProvider<AuthRemoteDataSource>.value(
          value: authRemoteDataSource,
        ),
        RepositoryProvider<AuthRepository>.value(value: authRepository),
        RepositoryProvider<RegistrationRepository>.value(
          value: registrationRepository,
        ),
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
