import 'package:flutter/material.dart';
// import '../utils/constants.dart';
import '../utils/styles.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool showBackButton;
  final String? title;
  final VoidCallback? onBackPressed;
  final List<Widget>? actions;
  
  const CustomAppBar({
    super.key,
    this.showBackButton = false,
    this.title,
    this.onBackPressed,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      leading: showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              color: Theme.of(context).appBarTheme.iconTheme?.color,
              onPressed: onBackPressed ?? () => Navigator.maybePop(context),
            )
          : null,
      title: title != null
          ? Text(
              title!,
              style: AppTextStyles.appBarTitle.copyWith(
                color: Theme.of(context).appBarTheme.titleTextStyle?.color,
              ),
            )
          : null,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}