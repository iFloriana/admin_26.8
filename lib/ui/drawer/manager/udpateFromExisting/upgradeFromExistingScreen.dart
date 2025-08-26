import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../utils/colors.dart';
import '../../../../utils/custom_text_styles.dart';
import '../../../../utils/validation.dart';
import '../../../../wiget/Custome_button.dart';
import '../../../../wiget/Custome_textfield.dart';
import '../../../../wiget/appbar/commen_appbar.dart';
import 'upgradeFromExistingController.dart';

class Upgradefromexistingscreen extends StatelessWidget {
  Upgradefromexistingscreen({super.key});
  final Upgradefromexistingcontroller getController =
      Get.put(Upgradefromexistingcontroller());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Upgrade from existing staff',
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          spacing: 10,
          children: [
            _buildStaffDropdown(),
            InputTxtfield_password(),
            InputTxtfield_confirmPassword(),
            btn_upgrade_staff2manager(),
          ],
        ),
      ),
    );
  }

  Widget _buildStaffDropdown() {
    return Obx(() => DropdownButtonFormField<String>(
          value: getController.selectedStaffId.value.isEmpty
              ? null
              : getController.selectedStaffId.value,
          decoration: InputDecoration(
            labelText: 'Staff *',
            labelStyle: CustomTextStyles.textFontMedium(size: 14, color: grey),
            border: const OutlineInputBorder(),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(
                  color: primaryColor, width: 2.0), // Active/focused border
            ),
          ),
          isExpanded: true,
          items: getController.staffList
              .map((staff) => DropdownMenuItem<String>(
                    value: staff.sId,
                    child: Text(staff.fullName ?? ''),
                  ))
              .toList(),
          onChanged: (value) {
            getController.selectedStaffId.value = value ?? '';
          },
          validator: (v) => v == null || v.isEmpty ? 'Required' : null,
        ));
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

  Widget btn_upgrade_staff2manager() {
    return ElevatedButtonExample(
      text: "Upgrade Staff to Manager",
      onPressed: () {
        getController.upgradeStaff2Manager();
      },
    );
  }
}
