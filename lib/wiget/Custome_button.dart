import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_template/utils/colors.dart';
import 'package:flutter_template/wiget/custome_text.dart';
import '../utils/custom_text_styles.dart';

class ElevatedButtonExample extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final VoidCallback? onLongPress;
  final ButtonStyle? style;
  final Widget? icon;
  final EdgeInsetsGeometry? padding;
  final double? height;
  final double? width;

  const ElevatedButtonExample({
    Key? key,
    required this.text,
    required this.onPressed,
    this.onLongPress,
    this.style,
    this.icon,
    this.padding,
    this.height = 50.0,
    this.width = double.infinity,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: SizedBox(
        height: height,
        width: width,
        child: icon != null
            ? ElevatedButton.icon(
                onPressed: onPressed,
                onLongPress: onLongPress,
                icon: icon!,
                label: CustomTextWidget(
                  text: text,
                  textAlign: TextAlign.center,
                  textStyle: CustomTextStyles.textFontSemiBold(size: 15.sp, color: white),
                ),
                style: style ?? _defaultStyle(),
              )
            : ElevatedButton(
                onPressed: onPressed,
                onLongPress: onLongPress,
                style: style ?? _defaultStyle(),
                child: CustomTextWidget(
                  text: text,
                  textAlign: TextAlign.center,
                  textStyle: CustomTextStyles.textFontSemiBold(size: 15.sp, color: white),
                ),
              ),
      ),
    );
  }

  ButtonStyle _defaultStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: primaryColor,
      foregroundColor: white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.r),
      ),
    );
  }
}
