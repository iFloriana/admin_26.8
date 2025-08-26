import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_template/utils/colors.dart';
import 'package:flutter_template/utils/custom_text_styles.dart';
import 'package:flutter_template/utils/validation.dart';
import 'package:flutter_template/wiget/Custome_button.dart';
import 'package:flutter_template/wiget/Custome_textfield.dart';
import 'package:flutter_template/wiget/appbar/commen_appbar.dart';
import 'package:flutter_template/wiget/custome_dropdown.dart';
import 'package:flutter_template/wiget/custome_text.dart';
import 'package:get/get.dart';
import 'package:multi_dropdown/multi_dropdown.dart';
import 'Addcustomercontroller.dart';

class Addcustomerscreen extends StatelessWidget {
  Addcustomerscreen({super.key});
  final Addcustomercontroller customerController =
      Get.put(Addcustomercontroller());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Customers"),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            spacing: 10,
            children: [
              SizedBox(height: 1.h),
              // Image upload section
              _buildImageUploadSection(context),
              SizedBox(height: 1.h),
              CustomTextFormField(
                controller: customerController.fullNameController,
                labelText: 'Full Name',
                keyboardType: TextInputType.text,
                validator: (value) => Validation.validatename(value),
              ),
              CustomTextFormField(
                controller: customerController.emailController,
                labelText: 'Email',
                keyboardType: TextInputType.emailAddress,
                validator: (value) => Validation.validateEmail(value),
              ),
              CustomTextFormField(
                controller: customerController.phoneController,
                labelText: 'Phone Number',
                keyboardType: TextInputType.phone,
                validator: (value) => Validation.validatePhone(value),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
              ),

              genderDropdown(),
              Obx(() => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomTextWidget(
                        text: 'Status',
                        textStyle:
                            CustomTextStyles.textFontRegular(size: 14.sp),
                      ),
                      Switch(
                        value: customerController.isActive.value,
                        onChanged: (value) {
                          customerController.isActive.value = value;
                        },
                        activeColor: primaryColor,
                      ),
                    ],
                  )),
              Obx(() => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomTextWidget(
                        text: 'Enable Package & Membership',
                        textStyle:
                            CustomTextStyles.textFontRegular(size: 14.sp),
                      ),
                      Switch(
                        activeColor: primaryColor,
                        value: customerController.showPackageFields.value,
                        onChanged: (value) {
                          customerController.showPackageFields.value = value;
                        },
                      ),
                    ],
                  )),
              Obx(() => customerController.showPackageFields.value
                  ? Column(
                      children: [
                        MultiDropdown<BranchPackage>(
                          items: customerController.branchPackageList
                              .map((package) => DropdownItem(
                                    label: package.packageName ?? '',
                                    value: package,
                                  ))
                              .toList(),
                          controller: customerController.packageController,
                          enabled: true,
                          searchEnabled: true,
                          chipDecoration: const ChipDecoration(
                            backgroundColor: secondaryColor,
                            wrap: true,
                            runSpacing: 2,
                            spacing: 10,
                          ),
                          fieldDecoration: FieldDecoration(
                            hintText: 'Select Branch Packages',
                            hintStyle: const TextStyle(color: Colors.grey),
                            showClearIcon: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Colors.grey),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: secondaryColor,
                              ),
                            ),
                          ),
                          dropdownItemDecoration: DropdownItemDecoration(
                            selectedIcon: const Icon(Icons.check_box,
                                color: primaryColor),
                            disabledIcon:
                                Icon(Icons.lock, color: Colors.grey.shade300),
                          ),
                          onSelectionChange: (selectedItems) {
                            customerController.selectedPackages.value =
                                selectedItems;
                          },
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Obx(() => DropdownButton<String>(
                                value: customerController
                                        .selectedBranchMembership.value.isEmpty
                                    ? null
                                    : customerController
                                        .selectedBranchMembership.value,
                                isExpanded: true,
                                hint: const Text('Select Branch Membership'),
                                underline: const SizedBox(),
                                items: customerController.branchMembershipList
                                    .map((membership) {
                                  return DropdownMenuItem<String>(
                                    value: membership.id,
                                    child:
                                        Text(membership.membershipName ?? ''),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  if (newValue != null) {
                                    customerController.selectedBranchMembership
                                        .value = newValue;
                                  }
                                },
                              )),
                        ),
                      ],
                    )
                  : const SizedBox()),
              Btn_addCustomer(),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageUploadSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // CustomTextWidget(
        //   text: 'Customer Photo',
        //   textStyle: CustomTextStyles.textFontRegular(size: 14.sp),
        // ),
        SizedBox(height: 8.h),
        Center(
          child: Obx(() => GestureDetector(
                onTap: () => customerController.showImageSourceDialog(context),
                child: Container(
                  height: 120.h,
                  width: 120.w,
                  decoration: BoxDecoration(
                    border: Border.all(color: primaryColor, width: 2),
                    borderRadius: BorderRadius.circular(10.r),
                    color: Colors.grey.shade100,
                  ),
                  child: customerController.selectedImage.value != null
                      ? Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8.r),
                              child: Image.file(
                                customerController.selectedImage.value!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                              ),
                            ),
                            Positioned(
                              top: 4,
                              right: 4,
                              child: GestureDetector(
                                onTap: customerController.removeSelectedImage,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.person,
                              size: 40.sp,
                              color: primaryColor,
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              'No Image',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                ),
              )),
        ),
        SizedBox(height: 8.h),
        // Row(
        //   mainAxisAlignment: MainAxisAlignment.center,
        //   children: [
        //     ElevatedButton.icon(
        //       onPressed: () =>
        //           customerController.showImageSourceDialog(context),
        //       icon: const Icon(Icons.add_a_photo),
        //       label: const Text('Upload Photo'),
        //       style: ElevatedButton.styleFrom(
        //         backgroundColor: primaryColor,
        //         foregroundColor: Colors.white,
        //         shape: RoundedRectangleBorder(
        //           borderRadius: BorderRadius.circular(8.r),
        //         ),
        //       ),
        //     ),
        //   ],
        // ),
      ],
    );
  }

  Widget genderDropdown() {
    return Obx(() => CustomDropdown<String>(
          value: customerController.selectedGender.value.isEmpty
              ? null
              : customerController.selectedGender.value,
          items: customerController.genderOptions,
          hintText: 'Gender',
          labelText: 'Gender',
          onChanged: (newValue) {
            if (newValue != null) {
              customerController.selectedGender.value = newValue;
            }
          },
        ));
  }

  Widget Btn_addCustomer() {
    return Obx(() => ElevatedButtonExample(
          text:
              customerController.isLoading.value ? "Adding..." : "Add Customer",
          onPressed: customerController.isLoading.value
              ? () {}
              : () {
                  customerController.addCustomer();
                },
        ));
  }
}
