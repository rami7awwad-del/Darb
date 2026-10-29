import 'package:flutter/material.dart';

import 'package:darb/features/gallery/presentation/screens/gallery_screen.dart';
import 'package:darb/features/home/presentation/screens/home_screen.dart';
import 'package:darb/features/library/presentation/screens/library_screen.dart';
import 'package:darb/features/main/presentation/widgets/app_bottom_nav_bar.dart';
import 'package:darb/features/profile/presentation/screens/profile_screen.dart';

/// الهيكل الرئيسي بعد الدخول: تبويبات مع شريط سفلي.
/// IndexedStack يحفظ حالة كل تبويب (الرئيسية لا تُعاد عند التنقل).
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
          LibraryScreen(),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
      ),
    );
  }
}
