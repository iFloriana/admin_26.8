import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_template/ui/auth/forgot/forgot_screen.dart'
    show ForgotScreen;
import 'package:flutter_template/utils/app_images.dart';
import 'package:flutter_template/utils/colors.dart';
import 'package:get/get.dart';
import '../../../route/app_route.dart';
import '../../../utils/custom_text_styles.dart';
import '../../../utils/validation.dart';
import '../../../wiget/Custome_textfield.dart';
import '../../../wiget/Custome_button.dart';
import '../../../wiget/custome_dropdown.dart';
import '../../../wiget/custome_snackbar.dart';
import '../../../wiget/custome_text.dart';
import '../register/register_screen.dart';
import 'login_controller.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final LoginController getController = Get.put(LoginController());
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Login_screen(),
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
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your email';
        }
        return Validation.validateEmail(value);
      },
    );
  }

  Widget Role() {
    return Obx(() => CustomDropdown<String>(
          value: getController.selectedRole.value.isEmpty
              ? null
              : getController.selectedRole.value,
          items: getController.dropdownItems,
          labelText: 'Role',
          onChanged: (newValue) {
            if (newValue != null) {
              getController.selectedRole(newValue);
            }
          },
        ));
  }

  Widget InputTxtfield_Pass() {
    return Obx(() => CustomTextFormField(
          controller: getController.passController,
          labelText: 'Password',
          obscureText: !getController.showPass.value,
          suffixIcon: IconButton(
            onPressed: () {
              getController.toggleShowPass();
            },
            icon: Icon(
              getController.showPass.value
                  ? Icons.visibility
                  : Icons.visibility_off,
              color: grey,
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your password';
            }
            return null; // Return null if the input is valid
          },
        ));
  }

  Widget Btn_Login() {
    return ElevatedButtonExample(
      text: "Login",
      onPressed: () {
        if (_formKey.currentState?.validate() ?? false) {
          if (getController.selectedRole.value == 'Admin') {
            getController.onLoginPress();
          } else if (getController.selectedRole.value == 'Manager') {
            getController.onLoginPressManager();
          } else {
            CustomSnackbar.showError(
                'Role Error', 'Please select a valid role');
          }
        } else {
          CustomSnackbar.showError(
              'Validation Error', 'Please fill in all fields correctly');
        }
      },
    );
  }

  Widget login_screen_header() {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Semantics(
          label: 'Submit button',
          child: ElevatedButton(onPressed: () {}, child: Text('Submit')),
        ),
        Container(
          height: 170.h,
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

  Widget login_screen_body() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        spacing: 10.h,
        children: [
          CustomTextWidget(
            text: 'Welcome Back!',
            textStyle: CustomTextStyles.textFontSemiBold(
              size: 16.sp,
            ),
          ),
          CustomTextWidget(
            text: 'You Have Been Missed For Long Time',
            textStyle:
                CustomTextStyles.textFontSemiBold(size: 12.sp, color: grey),
          ),
          Role(),
          InputTxtfield_Email(),
          InputTxtfield_Pass(),
          Obx(() => getController.selectedRole.value == 'Admin'
              ? GestureDetector(
                  onTap: () {
                    Get.to(ForgotScreen());
                  },
                  child: Align(
                      alignment: Alignment.topRight,
                      child: CustomTextWidget(
                          text: "Forgot your password?",
                          textStyle: CustomTextStyles.textFontBold(
                              size: 14.sp,
                              color: primaryColor,
                              textOverflow: TextOverflow.ellipsis))))
              : SizedBox.shrink()),
          SizedBox(height: 10.h),
          Btn_Login(),
          Obx(() => getController.selectedRole.value == 'Admin'
              ? GestureDetector(
                  onTap: () => Get.to(RegisterScreen()),
                  child: Align(
                      alignment: Alignment.center,
                      child: CustomTextWidget(
                          text: "Create new account",
                          textStyle: CustomTextStyles.textFontBold(
                              size: 14.sp,
                              color: primaryColor,
                              textOverflow: TextOverflow.ellipsis))))
              : SizedBox.shrink()),
        ],
      ),
    );
  }

  Widget Login_screen() {
    return Column(
      spacing: 35.h,
      children: [
        login_screen_header(),
        login_screen_body(),
      ],
    );
  }
}
