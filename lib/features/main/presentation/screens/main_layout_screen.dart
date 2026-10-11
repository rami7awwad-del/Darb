import 'package:flutter/material.dart';

import 'package:darb/core/style/app_colors.dart';
import 'package:darb/core/style/app_text_styles.dart';
import 'package:darb/features/gallery/presentation/screens/gallery_screen.dart';
import 'package:darb/features/home/presentation/screens/home_screen.dart';
import 'package:darb/features/main/presentation/widgets/app_bottom_nav_bar.dart';

/// الهيكل الرئيسي بعد الدخول: تبويبات مع شريط سفلي.
/// IndexedStack يحفظ حالة كل تبويب (الرئيسية لا تُعاد عند التنقل).
/// TODO: استبدل الأماكن المؤقتة بالشاشات الحقيقية (المكتبة، الحساب).
class MainLayoutScreen extends StatefulWidget {
  const MainLayoutScreen({super.key});

  @override
  State<MainLayoutScreen> createState() => _MainLayoutScreenState();
}

class _MainLayoutScreenState extends State<MainLayoutScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: const [
          HomeScreen(),
          GalleryScreen(),
          _ComingSoon(title: 'المكتبة'),
          _ComingSoon(title: 'حسابي'),
        ],
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
      ),
    );
  }
}

class _ComingSoon extends StatelessWidget {
  const _ComingSoon({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        '$title: قيد البناء',
        style: AppTextStyles.font16Medium.copyWith(color: AppColors.grey300),
      ),
    );
  }
}
