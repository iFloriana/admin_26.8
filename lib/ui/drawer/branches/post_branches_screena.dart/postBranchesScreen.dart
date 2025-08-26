import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_template/ui/drawer/branches/post_branches_screena.dart/postBranchescontroller.dart';
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

import '../../../../wiget/loading.dart';

class Postbranchesscreen extends StatelessWidget {
  Postbranchesscreen({super.key});
  final Postbranchescontroller getController =
      Get.find<Postbranchescontroller>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Add Branch"),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            spacing: 10,
            children: [
              SizedBox(
                height: 1.h,
              ),
              SizedBox(
                width: 80.h,
                child: ImagePickerBranch(),
              ),

              CustomTextFormField(
                controller: getController.nameController,
                labelText: 'Name',
                keyboardType: TextInputType.text,
                validator: (value) => Validation.validatename(value),
              ),
              Category(),

              CustomTextFormField(
                controller: getController.contactEmailController,
                labelText: 'Email',
                keyboardType: TextInputType.emailAddress,
                validator: (value) => Validation.validateEmail(value),
              ),
              CustomTextFormField(
                controller: getController.contactNumberController,
                labelText: 'Number',
                keyboardType: TextInputType.number,
                validator: (value) => Validation.validatePhone(value),
              ),
              paymentMethodDropdown(),
              serviceDropdown(),
              CustomTextFormField(
                controller: getController.addressController,
                labelText: 'Address',
                maxLines: 2,
                keyboardType: TextInputType.text,
                validator: (value) => Validation.validateAddress(value),
              ),
              CustomTextFormField(
                controller: getController.discriptionController,
                labelText: 'Discription',
                maxLines: 2,
                keyboardType: TextInputType.text,
                validator: (value) => Validation.validatedisscription(value),
              ),
              Row(spacing: 5.w, children: [
                Expanded(
                    child: CustomTextFormField(
                  controller: getController.landmarkController,
                  labelText: 'Landmark',
                  keyboardType: TextInputType.text,
                )),
                Expanded(
                    child: CustomTextFormField(
                  controller: getController.countryController,
                  labelText: 'Country',
                  keyboardType: TextInputType.text,
                )),
              ]),
              Row(
                spacing: 5.w,
                children: [
                  Expanded(
                    child: CustomTextFormField(
                      controller: getController.stateController,
                      labelText: 'State',
                      keyboardType: TextInputType.text,
                    ),
                  ),
                  Expanded(
                    child: CustomTextFormField(
                      controller: getController.cityController,
                      labelText: 'City',
                      keyboardType: TextInputType.text,
                    ),
                  )
                ],
              ),

              CustomTextFormField(
                controller: getController.postalCodeController,
                labelText: 'Postal Code',
                keyboardType: TextInputType.text,
              ),

              Obx(() => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomTextWidget(
                        text: 'Status',
                        textStyle:
                            CustomTextStyles.textFontRegular(size: 14.sp),
                      ),
                      Switch(
                        value: getController.isActive.value,
                        onChanged: (value) {
                          getController.isActive.value = value;
                        },
                        activeColor: primaryColor,
                      ),
                    ],
                  )),

              // Row(
              //   children: [
              //     Expanded(
              //       child: Obx(() => CustomTextFormField(
              //             controller: getController.latController
              //               ..text = getController.latitude.value,
              //             labelText: 'Latitude',
              //             suffixIcon: IconButton(
              //               icon: Icon(Icons.gps_fixed),
              //               onPressed: () async {
              //                 await getController.fetchLocation();
              //               },
              //             ),
              //           )),
              //     ),
              //     SizedBox(
              //       width: 5.w,
              //     ),
              //     Expanded(
              //       child: Obx(() => CustomTextFormField(
              //             controller: getController.lngController
              //               ..text = getController.longitude.value,
              //             labelText: 'Longitude',
              //             suffixIcon: IconButton(
              //               icon: Icon(Icons.gps_fixed),
              //               onPressed: () async {
              //                 await getController.fetchLocation();
              //               },
              //             ),
              //           )),
              //     ),
              //   ],
              // ),
              Btn_addBranch(),
              SizedBox(
                height: 10.h,
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget Category() {
    return Obx(() => CustomDropdown<String>(
          value: getController.selectedCategory.value.isEmpty
              ? null
              : getController.selectedCategory.value,
          items: getController.dropdownItemSelectedCategory,
          hintText: 'Category',
          labelText: 'Category',
          onChanged: (newValue) {
            if (newValue != null) {
              getController.selectedCategory(newValue);
            }
          },
        ));
  }

  Widget serviceDropdown() {
    return Obx(() {
      if (getController.serviceList.isEmpty) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              SizedBox(
                  width: 16,
                  height: 16,
                  child: CustomLoadingAvatar()),
              SizedBox(width: 12),
              Text('Loading services...',
                  style: TextStyle(color: Colors.grey.shade600)),
            ],
          ),
        );
      }

      return MultiDropdown<Service>(
        items: getController.serviceList
            .map((service) => DropdownItem(
                  label: service.name ?? '',
                  value: service,
                ))
            .toList(),
        controller: getController.serviceController,
        enabled: true,
        searchEnabled: true,
        chipDecoration: const ChipDecoration(
          backgroundColor: secondaryColor,
          wrap: true,
          runSpacing: 2,
          spacing: 10,
        ),
        fieldDecoration: FieldDecoration(
          hintText: 'Select Services',
          hintStyle: CustomTextStyles.textFontMedium(size: 14.sp, color: grey),
          showClearIcon: true,
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
            borderSide: BorderSide(
              color: grey,
              width: 1.0,
            ),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
            borderSide: BorderSide(
              color: primaryColor,
              width: 2.0,
            ),
          ),
          errorBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
            borderSide: BorderSide(
              color: red,
              width: 1.0,
            ),
          ),
        ),
        dropdownItemDecoration: DropdownItemDecoration(
          selectedIcon: const Icon(Icons.check_box, color: primaryColor),
          disabledIcon: Icon(Icons.lock, color: Colors.grey.shade300),
        ),
        onSelectionChange: (selectedItems) {
          getController.selectedServices.value = selectedItems;
        },
      );
    });
  }

  Widget Btn_addBranch() {
    return ElevatedButtonExample(
      text: "Add Branch",
      onPressed: () {
        getController.onBranchAdd();
      },
    );
  }

  Widget paymentMethodDropdown() {
    final List<String> _paymentMethods = ['Cash', 'UPI'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Text(
        //   'Payment Methods',
        //   style: TextStyle(
        //     fontSize: 16.sp,
        //     fontWeight: FontWeight.bold,
        //   ),
        // ),
        // SizedBox(height: 8.h),
        MultiDropdown<String>(
          items: _paymentMethods
              .map((method) => DropdownItem(
                    label: method.toUpperCase(),
                    value: method,
                  ))
              .toList(),
          controller: getController.paymentMethodController,
          enabled: true,
          searchEnabled: true,
          chipDecoration: const ChipDecoration(
            backgroundColor: secondaryColor,
            wrap: true,
            runSpacing: 2,
            spacing: 10,
          ),
          fieldDecoration: FieldDecoration(
            hintText: 'Select Payment Methods',
            hintStyle:
                CustomTextStyles.textFontMedium(size: 14.sp, color: grey),
            showClearIcon: true,
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8.0)),
              borderSide: BorderSide(
                color: grey,
                width: 1.0,
              ),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8.0)),
              borderSide: BorderSide(
                color: primaryColor,
                width: 2.0,
              ),
            ),
            errorBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8.0)),
              borderSide: BorderSide(
                color: red,
                width: 1.0,
              ),
            ),
          ),
          dropdownItemDecoration: DropdownItemDecoration(
            selectedIcon: const Icon(Icons.check_box, color: primaryColor),
            disabledIcon: Icon(Icons.lock, color: Colors.grey.shade300),
          ),
          onSelectionChange: (selectedItems) {
            getController.selectedPaymentMethod.value = selectedItems;
          },
        ),
      ],
    );
  }
}

class ImagePickerBranch extends StatelessWidget {
  ImagePickerBranch({super.key});
  final Postbranchescontroller getController =
      Get.find<Postbranchescontroller>();

  @override
  Widget build(BuildContext context) {
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
          height: 120,
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: primaryColor),
            borderRadius: BorderRadius.circular(10.r),
            color: secondaryColor.withOpacity(0.2),
          ),
          alignment: Alignment.center,
          child: getController.singleImage.value != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(10.r),
                  child: Image.file(
                    getController.singleImage.value!,
                    fit: BoxFit.cover,
                    height: 120,
                    width: double.infinity,
                  ),
                )
              : Icon(Icons.image_rounded, color: primaryColor, size: 30.sp),
        ),
      );
    });
  }
}
