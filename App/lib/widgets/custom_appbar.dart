import 'package:flutter/material.dart';
import 'package:baigan/theme/app_colors.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showCartIcon;

  const CustomAppBar({
    super.key,
    required this.title,
    this.showCartIcon = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: true,
      title: Text(
        title,
        style: TextStyle(color: AppColors.white),
      ),
      actions: showCartIcon
          ? [
              IconButton(
                icon: Icon(
                  Icons.shopping_cart,
                  color: AppColors.white,
                ),
                onPressed: () {},
              ),
            ]
          : null,
      backgroundColor: AppColors.secondaryDarkGray,
      elevation: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/top_background.png"),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
