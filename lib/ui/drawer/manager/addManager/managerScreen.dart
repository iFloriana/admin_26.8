import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_template/ui/drawer/manager/addManager/managerController.dart';
import 'package:flutter_template/utils/validation.dart';
import 'package:flutter_template/wiget/Custome_button.dart';
import 'package:flutter_template/wiget/Custome_textfield.dart';
import 'package:flutter_template/wiget/appbar/commen_appbar.dart';
import 'package:flutter_template/wiget/custome_dropdown.dart';
import 'package:get/get.dart';
import 'package:flutter_template/ui/drawer/manager/getManager/getmanagerController.dart';

import '../../../../utils/colors.dart';
import '../../../../network/network_const.dart';
import '../../../../utils/custom_text_styles.dart';
import '../../../../wiget/loading.dart';

class Managerscreen extends StatelessWidget {
  final Manager? manager;
  Managerscreen({super.key, this.manager});
  final Managercontroller getController = Get.put(Managercontroller());

  void prefillFields() {
    if (manager != null) {
      getController.fullNameController.text = manager!.full_name;
      getController.emailController.text = manager!.email;
      getController.contactNumberController.text = manager!.contactNumber;
      getController.passwordController.text = manager!.password;
      getController.confirmPasswordController.text = manager!.password;
      getController.selectedGender.value =
          manager!.gender?.capitalizeFirst ?? 'Male';

      // Set network image for edit mode
      getController.editImageUrl.value = manager!.image_url;

      // Branch prefill can be handled after branchList is loaded
      if (manager!.branchId != null) {
        ever(getController.branchList, (_) {
          final branch = getController.branchList
              .firstWhereOrNull((b) => b.id == manager!.branchId);
          if (branch != null) {
            getController.selectedBranch.value = branch;
          }
        });
      }
    } else {
      // Ensure fresh form when adding new manager
      getController.resetForm();
    }
  }

  @override
  Widget build(BuildContext context) {
    prefillFields();
    return Scaffold(
        appBar: CustomAppBar(
          title: manager == null ? "Add Manager" : "Edit Manager",
        ),
        body: Obx(() => getController.isLoading.value
            ? const Center(child: CustomLoadingAvatar())
            : SingleChildScrollView(
                child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Column(
                      spacing: 10,
                      children: [
                        SizedBox(
                          height: 1.h,
                        ),
                        ImagePickerWidget(),
                        InputTxtfield_firstName(),
                        InputTxtfield_Email(),
                        InputTxtfield_Phone(),
                        InputTxtfield_password(),
                        InputTxtfield_confirmPassword(),
                        Gender(),
                        _buildBranchDropdown(),
                        Btn_saveManager(context),
                        if (manager == null)
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                getController.resetForm();
                              },
                              child: const Text('Clear Form'),
                            ),
                          ),
                      ],
                    )),
              )));
  }

  Widget ImagePickerWidget() {
    return Obx(() {
      return GestureDetector(
        onTap: () async {
          Get.bottomSheet(
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.photo_library),
                    title: const Text('Choose from Gallery'),
                    onTap: () async {
                      Get.back();
                      await getController.pickImageFromGallery();
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.camera_alt),
                    title: const Text('Take Photo'),
                    onTap: () async {
                      Get.back();
                      await getController.pickImageFromCamera();
                    },
                  ),
                ],
              ),
            ),
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
          );
        },
        child: Container(
          height: 120.h,
          width: 120.w,
          decoration: BoxDecoration(
            border: Border.all(color: primaryColor),
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(10.r),
            color: secondaryColor.withOpacity(0.2),
          ),
          child: getController.singleImage.value != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(10.r),
                  child: Image.file(
                    getController.singleImage.value!,
                    fit: BoxFit.cover,
                  ),
                )
              : getController.editImageUrl.value.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(10.r),
                      child: Image.network(
                        '${Apis.pdfUrl}${getController.editImageUrl.value}?v=${DateTime.now().millisecondsSinceEpoch}',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.image_not_supported,
                                    color: Colors.grey[600], size: 40.sp),
                                SizedBox(height: 8.h),
                                Text(
                                  'Image Corrupted',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12.sp,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_a_photo,
                            color: primaryColor, size: 40.sp),
                        SizedBox(height: 8.h),
                        Text(
                          'Add Photo',
                          style: TextStyle(
                            color: primaryColor,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
        ),
      );
    });
  }

  Widget Gender() {
    return Obx(() => CustomDropdown<String>(
          value: getController.selectedGender.value.isEmpty
              ? null
              : getController.selectedGender.value,
          items: getController.dropdownItems,
          hintText: 'Gender',
          labelText: 'Gender',
          onChanged: (newValue) {
            if (newValue != null) {
              getController.selectedGender(newValue);
            }
          },
        ));
  }

  Widget InputTxtfield_firstName() {
    return CustomTextFormField(
      controller: getController.fullNameController,
      labelText: "Full Name",
      keyboardType: TextInputType.text,
      validator: (value) => Validation.validatename(value),
    );
  }

  Widget InputTxtfield_lastName() {
    return CustomTextFormField(
      controller: getController.lastNameController,
      labelText: "Last Name",
      keyboardType: TextInputType.text,
      validator: (value) => Validation.validatename(value),
    );
  }

  Widget InputTxtfield_Email() {
    return CustomTextFormField(
      controller: getController.emailController,
      labelText: "Email",
      keyboardType: TextInputType.emailAddress,
      validator: (value) => Validation.validateEmail(value),
    );
  }

  Widget InputTxtfield_Phone() {
    return CustomTextFormField(
      controller: getController.contactNumberController,
      labelText: "Contact Number",
      keyboardType: TextInputType.phone,
      validator: (value) => Validation.validatePhone(value),
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(10),
      ],
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

  Widget _buildBranchDropdown() {
    return Obx(() => DropdownButtonFormField<Branch>(
          value: getController.selectedBranch.value,
          decoration: InputDecoration(
            labelText: 'Branch *',
            labelStyle: CustomTextStyles.textFontMedium(size: 14, color: grey),
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              borderSide: BorderSide(
                  color: primaryColor, width: 2.0), // Active/focused border
            ),
          ),
          items: getController.branchList
              .map((item) =>
                  DropdownMenuItem(value: item, child: Text(item.name ?? '')))
              .toList(),
          onChanged: (v) {
            if (v != null) {
              getController.selectedBranch.value = v;
            }
          },
          validator: (v) => v == null ? 'Required' : null,
        ));
  }

  Widget Btn_saveManager(BuildContext context) {
    return ElevatedButtonExample(
      text: manager == null ? "Add Manager" : "Save Changes",
      onPressed: () async {
        if (manager == null) {
          await getController.onManagerAdd();
        } else {
          await getController.updateManager(manager!.id);
        }
        Navigator.of(context).pop();
      },
    );
  }
}
