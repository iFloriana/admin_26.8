import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_template/route/app_route.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AppImages.loginbg),
            fit: BoxFit.cover,
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
        spacing: 5,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 🔹 Admin Card
          Expanded(
            child: GestureDetector(
              onTap: () => getController.setSelectedRole("Admin"),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
                height: getController.selectedRole.value == "Admin" ? 70 : 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: getController.selectedRole.value == "Admin"
                        ? [secondaryColor, primaryColor]
                        : [Colors.grey.shade200, Colors.grey.shade400],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: getController.selectedRole.value == "Admin"
                          ? primaryColor.withOpacity(0.5)
                          : Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(2, 4),
                    ),
                  ],
                  border: getController.selectedRole.value == "Admin"
                      ? Border.all(color: primaryColor, width: 2)
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.admin_panel_settings,
                      size: 28,
                      color: getController.selectedRole.value == "Admin"
                          ? Colors.white
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
                            ? Colors.white
                            : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // SizedBox(width: 15.w),
          // 🔹 Manager Card
          Expanded(
            child: GestureDetector(
              onTap: () => getController.setSelectedRole("Manager"),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
                height: getController.selectedRole.value == "Manager" ? 70 : 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: getController.selectedRole.value == "Manager"
                        ? [secondaryColor, primaryColor]
                        : [Colors.grey.shade200, Colors.grey.shade400],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: getController.selectedRole.value == "Manager"
                          ? primaryColor.withOpacity(0.5)
                          : Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(2, 4),
                    ),
                  ],
                  border: getController.selectedRole.value == "Manager"
                      ? Border.all(color: primaryColor, width: 2)
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.business_center,
                      size: 28,
                      color: getController.selectedRole.value == "Manager"
                          ? Colors.white
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
                            ? Colors.white
                            : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // SizedBox(width: 15.w),
          // 🔹 Staff Card
          Expanded(
            child: GestureDetector(
              onTap: () => getController.setSelectedRole("Staff"),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
                height: getController.selectedRole.value == "Staff" ? 70 : 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: getController.selectedRole.value == "Staff"
                        ? [secondaryColor, primaryColor]
                        : [Colors.grey.shade200, Colors.grey.shade400],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: getController.selectedRole.value == "Staff"
                          ? primaryColor.withOpacity(0.5)
                          : Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(2, 4),
                    ),
                  ],
                  border: getController.selectedRole.value == "Staff"
                      ? Border.all(color: primaryColor, width: 2)
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: 28,
                      color: getController.selectedRole.value == "Staff"
                          ? Colors.white
                          : primaryColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Staff",
                      style: TextStyle(
                        fontSize: getController.selectedRole.value == "Staff"
                            ? 16
                            : 14,
                        fontWeight: FontWeight.bold,
                        color: getController.selectedRole.value == "Staff"
                            ? Colors.white
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
            return null;
          },
        ));
  }

  Widget Btn_Login() {
    return Obx(() => ElevatedButtonExample(
          text: "Login",
          onPressed: getController.loading.value
              ? () {}
              : () {
                  if (_formKey.currentState?.validate() ?? false) {
                    if (getController.selectedRole.value.isNotEmpty) {
                      if (getController.selectedRole.value == 'Admin') {
                        getController.onLoginPress();
                      } else if (getController.selectedRole.value ==
                          'Manager') {
                        getController.onLoginPressManager();
                      } else if (getController.selectedRole.value == 'Staff') {
                        getController.onLoginPressStaff();
                      }
                    } else {
                      CustomSnackbar.showError(
                          'Role Error', 'Please select a valid role');
                    }
                  } else {
                    CustomSnackbar.showError('Validation Error',
                        'Please fill in all fields correctly');
                  }
                },
        ));
  }

  Widget login_screen_body() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        spacing: 5,
        children: [
          SizedBox(height: 25),
          Image.asset(
            "${AppImages.happlogo}",
            height: 100,
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
          SizedBox(height: 20),
          Role(),
          SizedBox(height: 20),
          InputTxtfield_Email(),
          SizedBox(height: 5),
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
          SizedBox(height: 10.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Obx(() => getController.selectedRole.value == 'Admin'
                  ? GestureDetector(
                      onTap: () => Get.to(RegisterScreen()),
                      child: Align(
                          alignment: Alignment.center,
                          child: Container(
                            padding: EdgeInsets.all(5),
                            decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                                color: white),
                            child: CustomTextWidget(
                                text: "Create New account",
                                textStyle: CustomTextStyles.textFontBold(
                                    size: 14.sp,
                                    color: primaryColor,
                                    textOverflow: TextOverflow.ellipsis)),
                          )))
                  : SizedBox.shrink()),
              SizedBox(height: 10.h),
              Obx(() => getController.selectedRole.value == 'Admin'
                  ? GestureDetector(
                      onTap: () => Get.offAllNamed(Routes.Renewpackagescreen),
                      child: Align(
                          alignment: Alignment.center,
                          child: Container(
                            padding: EdgeInsets.all(5),
                            decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                                color: white),
                            child: CustomTextWidget(
                                text: "Renew Package",
                                textStyle: CustomTextStyles.textFontBold(
                                    size: 14.sp,
                                    color: primaryColor,
                                    textOverflow: TextOverflow.ellipsis)),
                          )))
                  : SizedBox.shrink()),
            ],
          )
        ],
      ),
    );
  }

  Widget Login_screen() {
    return Column(
      children: [
        SizedBox(height: 30.h),
        login_screen_body(),
      ],
    );
  }
}
