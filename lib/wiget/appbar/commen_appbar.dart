import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_template/utils/colors.dart';
import '../../utils/custom_text_styles.dart';
import '../custome_text.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Color backgroundColor;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;

  CustomAppBar({
    required this.title,
    this.backgroundColor = primaryColor,
    this.actions,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: CustomTextWidget(
        text: title,
        textAlign: TextAlign.start,
        textStyle: CustomTextStyles.textFontSemiBold(
          size: 17.sp,
          color: Colors.white,
        ),
      ),
      backgroundColor: backgroundColor,
      toolbarHeight: 70.h,
      iconTheme: IconThemeData(color: white),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(20.0.r),
        ),
      ),
      actions: actions,
      bottom: bottom,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(70.h);
}
