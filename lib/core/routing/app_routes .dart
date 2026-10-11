import 'package:darb/features/auth/data/repositories/auth_repository.dart';
import 'package:darb/features/auth/data/repositories/registration_repository.dart';
import 'package:darb/features/auth/presentation/cubit/login/login_cubit.dart';
import 'package:darb/features/auth/presentation/cubit/otp/otp_cubit.dart';
import 'package:darb/features/auth/presentation/cubit/register/register_cubit.dart';
import 'package:darb/features/auth/presentation/screens/login_screen.dart';
import 'package:darb/features/auth/presentation/screens/otp_screen.dart';
import 'package:darb/features/auth/presentation/screens/register_screen.dart';
import 'package:darb/features/auth/presentation/screens/register_success_screen%20.dart';
import 'package:darb/features/gallery/data/models/gallery_model.dart';
import 'package:darb/features/gallery/data/repositories/gallery_repository.dart';
import 'package:darb/features/gallery/presentation/cubit/gallery_cubit.dart';
import 'package:darb/features/gallery/presentation/screens/gallery_album_screen.dart';
import 'package:darb/features/home/data/repositories/home_repository.dart';
import 'package:darb/features/home/presentation/cubit/home_cubit.dart';
import 'package:darb/features/main/presentation/screens/main_layout_screen.dart';
import 'package:darb/features/profile/data/repositories/profile_repository.dart';
import 'package:darb/features/splash/splash_screen%20.dart';
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

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
