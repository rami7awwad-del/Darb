import 'package:darb/core/navigation/app_navigator.dart';
import 'package:darb/core/routing/app_routes%20.dart';
import 'package:darb/core/services/api_service.dart';
import 'package:darb/core/services/dio_factory.dart';
import 'package:darb/core/services/firebase_notification_service.dart';
import 'package:darb/core/services/storage_service.dart';
import 'package:darb/core/style/app_colors.dart';
import 'package:darb/core/style/app_text_styles.dart';
import 'package:darb/features/auth/data/datasources/auth_remote_data_source%20.dart';
import 'package:darb/features/auth/data/repositories/auth_repository%20.dart';
import 'package:darb/features/splash/splash_screen%20.dart';
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
      // انتهت صلاحية التوكن: نعيد المستخدم لبداية التطبيق.
      // TODO: استبدل SplashScreen بشاشة تسجيل الدخول عند إنشائها.
      navigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const SplashScreen()),
        (_) => false,
      );
    },
  ).getDio();
  final apiService = ApiService(dio);

  // Notifications
  final notificationService = FirebaseNotificationService();
  await notificationService.init();

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<StorageService>.value(value: storageService),
        RepositoryProvider<ApiService>.value(value: apiService),
        RepositoryProvider<FirebaseNotificationService>.value(
          value: notificationService,
        ),
        RepositoryProvider<AuthRemoteDataSource>(
          create: (context) => AuthRemoteDataSource(context.read<ApiService>()),
        ),
        RepositoryProvider<AuthRepository>(
          create: (context) => AuthRepository(
            context.read<AuthRemoteDataSource>(),
            context.read<StorageService>(),
            context.read<FirebaseNotificationService>(),
          ),
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
          home: child,
        );
      },
      child: const SplashScreen(),
    );
  }
}
