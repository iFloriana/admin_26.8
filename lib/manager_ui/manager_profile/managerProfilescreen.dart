import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_template/manager_ui/drawer/drawerscreen.dart';
import 'package:get/get.dart';

import '../../main.dart';
import '../../utils/colors.dart';
import '../../utils/custom_text_styles.dart';
import '../../wiget/appbar/commen_appbar.dart';
import '../../wiget/custome_text.dart';
import 'managerProfileCOntroller.dart';

class Managerprofilescreen extends StatelessWidget {
  Managerprofilescreen({super.key});
  var getController = Get.put(Managerprofilecontroller());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Manager Profile Screen',
      ),
      drawer: ManagerDrawerScreen(),
      body: Center(
        child: Column(
          children: [
            CustomTextWidget(
              text: getController.fullname.value.toString(),
              textStyle: CustomTextStyles.textFontBold(
                  size: 22.sp,
                  color: black,
                  textOverflow: TextOverflow.ellipsis),
            ),
            CustomTextWidget(
              text: getController.phone.value.toString(),
              textStyle: CustomTextStyles.textFontBold(
                  size: 22.sp,
                  color: black,
                  textOverflow: TextOverflow.ellipsis),
            ),
            CustomTextWidget(
              text: getController.email.value.toString(),
              textStyle: CustomTextStyles.textFontBold(
                  size: 22.sp,
                  color: black,
                  textOverflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ),
    );
  }
}
