
import 'package:darb/features/auth/data/repositories/auth_repository.dart';
import 'package:darb/features/auth/data/repositories/registration_repository.dart';
import 'package:darb/features/auth/presentation/cubit/login/login_cubit.dart';
import 'package:darb/features/auth/presentation/cubit/otp/otp_cubit.dart';
import 'package:darb/features/auth/presentation/cubit/register/register_cubit.dart';
import 'package:darb/features/auth/presentation/screens/login_screen.dart';
import 'package:darb/features/auth/presentation/screens/otp_screen.dart';
import 'package:darb/features/auth/presentation/screens/register_screen.dart';
import 'package:darb/features/auth/presentation/screens/register_success_screen.dart';
import 'package:darb/features/splash/splash_screen.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// أسماء المسارات. تُضاف هنا مسارات كل شاشة عند بنائها.
abstract class AppRoutes {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String otp = '/otp';
  static const String register = '/register';
  static const String registerSuccess = '/registerSuccess';
  // static const String mainLayout = '/mainLayout';
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

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
