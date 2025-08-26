import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_template/ui/auth/forgot/forgot_controller.dart';
import 'package:flutter_template/utils/app_images.dart';
import 'package:flutter_template/utils/colors.dart';
import 'package:get/get.dart';
import '../../../utils/custom_text_styles.dart';
import '../../../utils/validation.dart';
import '../../../wiget/Custome_textfield.dart';
import '../../../wiget/Custome_button.dart';
import '../../../wiget/custome_snackbar.dart';
import '../../../wiget/custome_text.dart';

class ForgotScreen extends StatelessWidget {
  ForgotScreen({super.key});

  final ForgotController getController = Get.put(ForgotController());
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: white),
          onPressed: () => Get.back(),
        ),
        title: CustomTextWidget(
          text: 'Forgot Password',
          textStyle:
              CustomTextStyles.textFontSemiBold(size: 16.sp, color: white),
        ),
        backgroundColor: primaryColor,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              forgot_screen(),
            ],
          ),
        ),
      ),
    );
  }

  Widget InputTxtfield_Email() {
    return CustomTextFormField(
      controller: getController.emailController,
      labelText: 'Email',
      keyboardType: TextInputType.emailAddress,
      validator: (value) => Validation.validateEmail(value),
    );
  }

  Widget Btn_Forgot() {
    return ElevatedButtonExample(
      text: "Continue",
      onPressed: () {
        if (_formKey.currentState?.validate() ?? false) {
          getController.onForgotPress();
        } else {
          CustomSnackbar.showError(
              'Validation Error', 'Please fill in all fields correctly');
        }
      },
    );
  }

  Widget Forgot_screen_header() {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Container(
          height: 100.h,
          width: double.infinity,
          decoration: BoxDecoration(
            color: primaryColor,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20.r),
              bottomRight: Radius.circular(20.r),
            ),
          ),
        ),
        Positioned(
          bottom: -50,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                    blurRadius: 10, color: secondaryColor, spreadRadius: 6)
              ],
            ),
            child: CircleAvatar(
              radius: 70,
              backgroundColor: primaryColor,
              foregroundImage: AssetImage(
                AppImages.applogo,
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget forgot_screen_body() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          CustomTextWidget(
            text: 'Forgot Password',
            textStyle: CustomTextStyles.textFontSemiBold(size: 16.sp),
          ),
          SizedBox(height: 3.h),
          SizedBox(
            width: 180.w,
            child: CustomTextWidget(
              textAlign: TextAlign.center,
              text: 'Please enter your email to reset your password.',
              textStyle:
                  CustomTextStyles.textFontSemiBold(size: 12.sp, color: grey),
            ),
          ),
          SizedBox(height: 20.h),
          InputTxtfield_Email(),
          SizedBox(height: 30.h),
          Btn_Forgot(),
        ],
      ),
    );
  }

  Widget forgot_screen() {
    return Column(
      children: [
        Forgot_screen_header(),
        SizedBox(height: 45.h),
        forgot_screen_body(),
      ],
    );
  }
}
