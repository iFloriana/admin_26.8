import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_template/ui/auth/forgot/forgot_screen.dart'
    show ForgotScreen;
import 'package:flutter_template/utils/app_images.dart';
import 'package:flutter_template/utils/colors.dart';
import 'package:get/get.dart';
import '../../../utils/custom_text_styles.dart';
import '../../../utils/validation.dart';
import '../../../wiget/Custome_textfield.dart';
import '../../../wiget/Custome_button.dart';
import '../../../wiget/custome_snackbar.dart';
import '../../../wiget/custome_text.dart';
import '../register/register_screen.dart';
import 'login_controller.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final LoginController getController = Get.put(LoginController());
  final _formKey = GlobalKey<FormState>();
  bool isAdminSelected = false;
  bool isManagerSelected = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AppImages.loginbg), // your background image
            fit: BoxFit.cover, // covers the whole screen
          ),
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Login_screen(),
              ],
            ),
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
    return Obx(() {
      return Row(
        spacing: 15,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 🔹 Admin Card
          Expanded(
            child: GestureDetector(
              onTap: () => getController.selectedRole("Admin"),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
                height: getController.selectedRole.value == "Admin" ? 70 : 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: getController.selectedRole.value == "Admin"
                        ? [Colors.grey.shade200, secondaryColor]
                        : [Colors.grey.shade200, secondaryColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: getController.selectedRole.value == "Admin"
                          ? secondaryColor
                          : Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(2, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.admin_panel_settings,
                      size: 28,
                      color: getController.selectedRole.value == "Admin"
                          ? primaryColor
                          : primaryColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Admin",
                      style: TextStyle(
                        fontSize: getController.selectedRole.value == "Admin"
                            ? 16
                            : 14,
                        fontWeight: FontWeight.bold,
                        color: getController.selectedRole.value == "Admin"
                            ? Colors.black
                            : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 🔹 Manager Card
          Expanded(
            child: GestureDetector(
              onTap: () => getController.selectedRole("Manager"),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
                height: getController.selectedRole.value == "Manager" ? 70 : 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: getController.selectedRole.value == "Manager"
                        ? [Colors.grey.shade200, secondaryColor]
                        : [Colors.grey.shade200, secondaryColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: getController.selectedRole.value == "Manager"
                          ? secondaryColor
                          : Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(2, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.business_center,
                      size: 28,
                      color: getController.selectedRole.value == "Manager"
                          ? primaryColor
                          : primaryColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Manager",
                      style: TextStyle(
                        fontSize: getController.selectedRole.value == "Manager"
                            ? 16
                            : 14,
                        fontWeight: FontWeight.bold,
                        color: getController.selectedRole.value == "Manager"
                            ? Colors.black
                            : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    });
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
          height: 150.h,
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
          SizedBox(height: 5),
          Image.asset(
            "${AppImages.happlogo}",
            height: 100,
            // width: 50,
          ),
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
          SizedBox(height: 5),
          Role(),
          SizedBox(height: 5),
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
          SizedBox(height: 5.h),
          Btn_Login(),
          Obx(() => getController.selectedRole.value == 'Admin'
              ? GestureDetector(
                  onTap: () => Get.to(RegisterScreen()),
                  child: Align(
                      alignment: Alignment.center,
                      child: Container(
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            color: white),
                        child: CustomTextWidget(
                            text: "Create new account",
                            textStyle: CustomTextStyles.textFontBold(
                                size: 14.sp,
                                color: primaryColor,
                                textOverflow: TextOverflow.ellipsis)),
                      )))
              : SizedBox.shrink()),
        ],
      ),
    );
  }

  Widget Login_screen() {
    return Column(
      spacing: 35.h,
      children: [
        login_screen_body(),
      ],
    );
  }
}
