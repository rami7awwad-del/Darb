import 'package:flutter/material.dart';

import 'package:darb/features/gallery/presentation/screens/gallery_screen.dart';
import 'package:darb/features/home/presentation/screens/home_screen.dart';
import 'package:darb/features/library/presentation/screens/library_screen.dart';
import 'package:darb/features/main/presentation/widgets/app_bottom_nav_bar.dart';
import 'package:darb/features/profile/presentation/screens/profile_screen.dart';

/// Screen that shows the main layout.
class MainLayoutScreen extends StatefulWidget {
  const MainLayoutScreen({super.key});

  @override
  State<MainLayoutScreen> createState() => _MainLayoutScreenState();
}

/// State for the main layout screen widget.
class _MainLayoutScreenState extends State<MainLayoutScreen> {
  int _index = 0;

  /// Back goes to the home tab first and never leaves this screen.
  void _onBackInvoked(bool didPop, Object? result) {
    if (didPop) return;
    if (_index != 0) {
      setState(() => _index = 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Block the system back button so the user cannot leave the home screen.
      canPop: false,
      onPopInvokedWithResult: _onBackInvoked,
      child: Scaffold(
        // IndexedStack keeps the state of every tab alive.
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
      ),
    );
  }
}
