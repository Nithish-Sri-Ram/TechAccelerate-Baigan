import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:baigan/controller/navbar_controller.dart';
import 'package:baigan/screens/home_screen.dart';
import 'package:baigan/screens/profile_screen.dart';
import 'package:baigan/theme/app_colors.dart';

class BottomNavbar extends StatefulWidget {
  const BottomNavbar({super.key});

  @override
  State<BottomNavbar> createState() {
    return _BottomNavbarState();
  }
}

class _BottomNavbarState extends State<BottomNavbar> {
  final controller = Get.put(NavbarController());

  @override
  Widget build(BuildContext context) {
    return GetBuilder<NavbarController>(builder: (context) {
      return Scaffold(
        body: IndexedStack(
          index: controller.tabIndex,
          children: const [
            HomeScreen(),
            ProfileScreen(),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: controller.tabIndex,
          onTap: controller.changeTabIndex,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.primaryDark,
          unselectedItemColor: AppColors.primaryDark,
          items: [
            BottomNavigationBarItem(
              icon: Icon(
                controller.tabIndex == 0 ? Icons.home : Icons.home_outlined,
                color: AppColors.primaryDark,
              ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                controller.tabIndex == 1 ? Icons.person : Icons.person_outlined,
                color: AppColors.primaryDark,
              ),
              label: 'Profile',
            ),
          ],
        ),
      );
    });
  }
}
