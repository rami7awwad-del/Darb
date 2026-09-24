import 'package:darb/features/splash/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
// 👈 استيراد حزمة اللغات
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/style/app_colors.dart';
import 'core/style/app_text_styles.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(430, 932), // أبعاد شاشة iPhone Pro Max من فيغما
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Darb',

          // 🟢 إجبار التطبيق على اللغة العربية واتجاه RTL
          locale: const Locale('ar'),
          supportedLocales: const [Locale('ar')],
          localizationsDelegates: const [
            // تم استخدام const مع الـ Delegates المتوافقة
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],

          theme: ThemeData(
            scaffoldBackgroundColor: AppColors.white,
            fontFamily: AppTextStyles.fontFamily,
            primaryColor: AppColors.primary,
          ),
          home: child,
        );
      },
      child: const SplashScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.main50,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text(
          'تطبيق درب',
          style: AppTextStyles.font20Bold.copyWith(color: AppColors.white),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Text(
          'مرحباً بك في التطبيق',
          style: AppTextStyles.font25Bold.copyWith(color: AppColors.primary),
        ),
      ),
    );
  }
}
