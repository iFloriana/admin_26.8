import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_template/route/app_route.dart';
import 'package:flutter_template/ui/auth/register/register_controller.dart';
import 'package:flutter_template/utils/colors.dart';
import 'package:flutter_template/utils/custom_text_styles.dart';
import 'package:flutter_template/utils/validation.dart';
import 'package:flutter_template/wiget/Custome_button.dart';
import 'package:flutter_template/wiget/Custome_textfield.dart';
import 'package:flutter_template/wiget/custome_text.dart';
import 'package:get/get.dart';

import '../../../wiget/appbar/commen_appbar.dart';

class RegisterScreen extends StatelessWidget {
  final RegisterController getController = Get.put(RegisterController());
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Register',
        backgroundColor: primaryColor,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              // loginScreenHeader(),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  spacing: 10.h,
                  children: [
                    InputTxtfield_fullName(),
                    InputTxtfield_Email(),
                    InputTxtfield_Phone(),
                    InputTxtfield_saloneName(),
                    InputTxtfield_add(),
                    SizedBox(height: 20.h),
                    ElevatedButtonExample(
                      height: 35.h,
                      text: 'Select Packages',
                      onPressed: () {
                        final isValid =
                            _formKey.currentState?.validate() ?? false;
                        if (!isValid) return;
                        var register_data = {
                          "owner_name": getController.fullnameController.text,
                          "owner_phone": getController.phoneController.text,
                          "owner_email": getController.emailController.text,
                          "salon_address": getController.addressController.text,
                          "salon_name": getController.salonNameController.text,
                        };
                        Get.toNamed(Routes.packagesScreen,
                            arguments: register_data);
                      },
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(bottom: 20.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomTextWidget(
              text: 'Already have an account?',
              textStyle: CustomTextStyles.textFontRegular(size: 13.sp),
            ),
            SizedBox(width: 10.w),
            GestureDetector(
              onTap: () => Get.toNamed(Routes.loginScreen),
              child: CustomTextWidget(
                text: 'Login Here',
                textStyle: CustomTextStyles.textFontBold(
                    size: 13.sp,
                    color: primaryColor,
                    textOverflow: TextOverflow.ellipsis),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget loginScreenHeader() {
  //   return Container(
  //     width: double.infinity,
  //     decoration: BoxDecoration(
  //       color: primaryColor,
  //       borderRadius: BorderRadius.only(
  //         bottomLeft: Radius.circular(20.r),
  //         bottomRight: Radius.circular(20.r),
  //       ),
  //     ),
  //     child: Padding(
  //       padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
  //       child: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         children: [
  //           SizedBox(height: 20.h),
  //           Text(
  //             'Register',
  //             style: TextStyle(
  //               color: Colors.white,
  //               fontSize: 20.sp,
  //               fontWeight: FontWeight.bold,
  //             ),
  //           ),
  //           SizedBox(height: 2.h),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget InputTxtfield_fullName() {
    return CustomTextFormField(
      controller: getController.fullnameController,
      labelText: "Owner's Name",
      keyboardType: TextInputType.text,
      validator: (value) => Validation.validatename(value),
    );
  }

  Widget InputTxtfield_Email() {
    return CustomTextFormField(
      controller: getController.emailController,
      labelText: "Owner's Email",
      keyboardType: TextInputType.emailAddress,
      validator: (value) => Validation.validateEmail(value),
    );
  }

  Widget InputTxtfield_Phone() {
    return CustomTextFormField(
      controller: getController.phoneController,
      labelText: "Owner's Phone",
      keyboardType: TextInputType.phone,
      validator: (value) => Validation.validatePhone(value),
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(10),
      ],
    );
  }

  Widget InputTxtfield_saloneName() {
    return CustomTextFormField(
      controller: getController.salonNameController,
      labelText: "Salon's Name",
      keyboardType: TextInputType.text,
      validator: (value) => Validation.validatename(value),
    );
  }

  Widget InputTxtfield_add() {
    return CustomTextFormField(
      controller: getController.addressController,
      labelText: 'Address',
      maxLines: 2,
      keyboardType: TextInputType.text,
      validator: (value) => Validation.validateAddress(value),
    );
  }
}
