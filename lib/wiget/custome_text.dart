import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../utils/custom_text_styles.dart';

class CustomTextWidget extends StatelessWidget {
  final String text;
  final TextAlign textAlign;
  final TextStyle? textStyle;

  CustomTextWidget({
    required this.text,
    this.textAlign = TextAlign.start,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      style: textStyle ?? CustomTextStyles.textFontRegular(size: 16.sp),
    );
  }
}
