// lib/widgets/custom_loading_avatar.dart

import 'package:flutter/material.dart';
import 'package:flutter_template/utils/app_images.dart';
import 'package:flutter_template/utils/colors.dart';


class CustomLoadingAvatar extends StatelessWidget {
  final double radius;

  const CustomLoadingAvatar({super.key, this.radius = 40});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: primaryColor,
      foregroundImage: AssetImage(AppImages.loading),
    );
  }
}
