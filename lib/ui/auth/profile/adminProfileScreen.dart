import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_template/ui/auth/profile/adminProfileController.dart';
import 'package:flutter_template/ui/drawer/drawer_screen.dart';
import 'package:flutter_template/utils/colors.dart';
import 'package:flutter_template/utils/custom_text_styles.dart';
import 'package:flutter_template/utils/validation.dart';
import 'package:flutter_template/wiget/Custome_button.dart';
import 'package:flutter_template/wiget/Custome_textfield.dart';
import 'package:flutter_template/wiget/appbar/commen_appbar.dart';
import 'package:flutter_template/wiget/custome_text.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../../../wiget/loading.dart';

class Adminprofilescreen extends StatelessWidget {
  Adminprofilescreen({super.key});
  final Adminprofilecontroller getController =
      Get.put(Adminprofilecontroller());

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: CustomAppBar(title: "Profile"),
        drawer: DrawerScreen(),
        body: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    spacing: 20.h,
                    children: [
                      GestureDetector(
                        onTap: getController.expand_details,
                        child: Obx(() => GestureDetector(
                              onTap: getController.expand_details,
                              child: Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: secondaryColor.withOpacity(0.2),
                                      spreadRadius: 1,
                                      blurRadius: 5,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: AnimatedSize(
                                  duration: Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            getController
                                                    .isExpanded_Details.value
                                                ? "Update Profile Details"
                                                : "Profile Details",
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 18),
                                          ),
                                          FaIcon(
                                              getController
                                                      .isExpanded_Details.value
                                                  ? FontAwesomeIcons.angleUp
                                                  : FontAwesomeIcons.angleDown,
                                              color: primaryColor,
                                              size: 20.sp),
                                        ],
                                      ),
                                      if (getController
                                          .isExpanded_Details.value)
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 12.0),
                                          child: Column(
                                            spacing: 10,
                                            children: [
                                              SizedBox(height: 1.h),
                                              InputTxtfield_fullName(),
                                              InputTxtfield_Email(),
                                              InputTxtfield_Phone(),
                                              InputTxtfield_saloneName(),
                                              InputTxtfield_add(),
                                              SizedBox(height: 20.h),
                                              ElevatedButtonExample(
                                                onPressed: () {
                                                  getController
                                                      .onProdileUpdate();
                                                },
                                                text: "Update",
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            )),
                      ),
                      GestureDetector(
                        onTap: getController.expand_pass,
                        child: Obx(() => GestureDetector(
                              onTap: getController.expand_pass,
                              child: Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: secondaryColor.withOpacity(0.2),
                                      spreadRadius: 1,
                                      blurRadius: 5,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: AnimatedSize(
                                  duration: Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            getController.isExpanded_pass.value
                                                ? "Update Password"
                                                : "Update Password",
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 18),
                                          ),
                                          FaIcon(
                                              getController
                                                      .isExpanded_pass.value
                                                  ? FontAwesomeIcons.angleUp
                                                  : FontAwesomeIcons.angleDown,
                                              color: primaryColor,
                                              size: 20.sp),
                                        ],
                                      ),
                                      if (getController.isExpanded_pass.value)
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 12.0),
                                          child: Column(
                                            spacing: 10,
                                            children: [
                                              SizedBox(height: 1.h),
                                              InputTxtfield_Oldpassword(),
                                              InputTxtfield_password(),
                                              InputTxtfield_confirmPassword(),
                                              SizedBox(height: 20.h),
                                              ElevatedButtonExample(
                                                onPressed: () {
                                                  getController
                                                      .onChangePAssword();
                                                },
                                                text: "Change Password",
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            )),
                      ),
                      SizedBox(height: 20),
                      Obx(() {
                        if (getController.isLoading.value) {
                          return CustomLoadingAvatar();
                        } else if (getController.error.isNotEmpty) {
                          return Text(getController.error.value,
                              style: TextStyle(color: Colors.red));
                        } else {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CustomTextWidget(
                                text: "${getController.country.value}",
                                textStyle: CustomTextStyles.textFontRegular(
                                  size: 16.sp,
                                  color: black,
                                ),
                              ),
                              CustomTextWidget(
                                text: "${getController.state.value}",
                                textStyle: CustomTextStyles.textFontRegular(
                                  size: 16.sp,
                                  color: black,
                                ),
                              ),
                              CustomTextWidget(
                                text: "${getController.district.value}",
                                textStyle: CustomTextStyles.textFontRegular(
                                  size: 16.sp,
                                  color: black,
                                ),
                              ),
                              CustomTextWidget(
                                text: "${getController.block.value}",
                                textStyle: CustomTextStyles.textFontRegular(
                                  size: 16.sp,
                                  color: black,
                                ),
                              ),
                            ],
                          );
                        }
                      }),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

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

  Widget InputTxtfield_password() {
    return Obx(() => CustomTextFormField(
          controller: getController.passwordController,
          labelText: 'Password',
          obscureText: !getController.showPassword.value,
          suffixIcon: IconButton(
            onPressed: () {
              getController.toggleShowPassword();
            },
            icon: Icon(
              getController.showPassword.value
                  ? Icons.visibility
                  : Icons.visibility_off,
              color: grey,
            ),
          ),
          validator: (value) => Validation.validatePassword(value),
        ));
  }

  Widget InputTxtfield_confirmPassword() {
    return Obx(() => CustomTextFormField(
          controller: getController.confirmPasswordController,
          labelText: 'Confirm Password',
          obscureText: !getController.showConfirmPassword.value,
          suffixIcon: IconButton(
            onPressed: () {
              getController.toggleShowConfirmPass();
            },
            icon: Icon(
              getController.showConfirmPassword.value
                  ? Icons.visibility
                  : Icons.visibility_off,
              color: grey,
            ),
          ),
          validator: (value) => Validation.validatePassword(value),
        ));
  }

  Widget InputTxtfield_Oldpassword() {
    return Obx(() => CustomTextFormField(
          controller: getController.oldPasswordController,
          labelText: 'Password',
          obscureText: !getController.showOldPassword.value,
          suffixIcon: IconButton(
            onPressed: () {
              getController.toggleShowOldPass();
            },
            icon: Icon(
              getController.showOldPassword.value
                  ? Icons.visibility
                  : Icons.visibility_off,
              color: grey,
            ),
          ),
          validator: (value) => Validation.validatePassword(value),
        ));
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
