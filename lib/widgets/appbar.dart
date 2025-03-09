import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final IconData? leadingIcon;
  final VoidCallback? onLeadingPressed;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final Gradient? gradient;
  final Color? textColor;
  final Color? iconColor;

  const CustomAppBar({
    super.key,
    required this.title,
    this.leadingIcon,
    this.onLeadingPressed,
    this.actions,
    this.backgroundColor,
    this.gradient,
    this.textColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: textColor ?? Colors.white,
        ),
      ),
      leading: leadingIcon != null
          ? IconButton(
              icon: Icon(
                leadingIcon,
                color: iconColor ?? Colors.white,
              ),
              onPressed: onLeadingPressed ?? () => Navigator.pop(context),
            )
          : null,
      automaticallyImplyLeading: leadingIcon == null,
      actions: actions,
      backgroundColor: gradient != null
          ? Colors.transparent
          : (backgroundColor ?? Colors.blue),
      flexibleSpace: gradient != null
          ? Container(
              decoration: BoxDecoration(
                gradient: gradient,
              ),
            )
          : null,
      elevation: 4,
      iconTheme: IconThemeData(
        color: iconColor ?? Colors.white,
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
