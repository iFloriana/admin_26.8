import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_template/utils/colors.dart';

import '../../utils/custom_text_styles.dart';
import '../custome_text.dart';

class CustomAppBarWithDrawer extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Color backgroundColor;
  final List<Widget>? actions;
  final Function? onDrawerPressed;

  CustomAppBarWithDrawer({
    required this.title,
    this.backgroundColor = primaryColor,
    this.actions,
    this.onDrawerPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: CustomTextWidget(
        text: title,
        textAlign: TextAlign.start,
        textStyle: CustomTextStyles.textFontSemiBold(
          size: 20.sp,
          color: Colors.white,
        ),
      ),
      backgroundColor: backgroundColor,
      toolbarHeight: 70.h,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(20.0.r),
        ),
      ),
      leading: IconButton(
        icon: Icon(Icons.menu, color: Colors.white),
        onPressed: () {
          if (onDrawerPressed != null) {
            onDrawerPressed!();
          } else {
            Scaffold.of(context).openDrawer(); 
          }
        },
      ),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(70.h);
}
