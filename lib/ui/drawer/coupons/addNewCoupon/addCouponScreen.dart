import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_template/commen_items/commen_class.dart';
import 'package:flutter_template/ui/drawer/coupons/addNewCoupon/addCouponController.dart';
import 'package:flutter_template/ui/drawer/coupons/couponsController.dart';
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
import '../../../../network/network_const.dart';

class AddCouponScreen extends StatelessWidget {
  AddCouponScreen({super.key});
  final Addcouponcontroller getController = Get.put(Addcouponcontroller());

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: CustomAppBar(
        title: getController.isEditMode.value ? 'Edit Coupon' : 'Add Coupon',
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            spacing: 10,
            children: [
              SizedBox(
                height: 2.h,
              ),
              Obx(() {
                final file = getController.singleImage.value;
                final netUrl = getController.editImageUrl.value;
                return GestureDetector(
                  onTap: () async {
                    Get.bottomSheet(
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(16)),
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
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(16)),
                      ),
                    );
                  },
                  child: Container(
                    height: 100,
                    width: 100,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: primaryColor),
                      borderRadius: BorderRadius.circular(10),
                      color: secondaryColor.withOpacity(0.2),
                    ),
                    child: file != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(
                              file,
                              fit: BoxFit.cover,
                            ),
                          )
                        : (netUrl.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                  // Use your coupon image base URL if needed
                                  '${Apis.pdfUrl}$netUrl?v=${DateTime.now().millisecondsSinceEpoch}',
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Icon(Icons.image_rounded,
                                color: primaryColor, size: 40)),
                  ),
                );
              }),
              CustomTextFormField(
                controller: getController.nameController,
                labelText: 'Name',
                keyboardType: TextInputType.text,
                validator: (value) => Validation.validatename(value),
              ),
              CustomTextFormField(
                controller: getController.descriptionController,
                labelText: 'Description',
                maxLines: 2,
                keyboardType: TextInputType.text,
                validator: (value) => Validation.validatedisscription(value),
              ),
              Row(
                children: [
                  Expanded(child: coupon_type()),
                  SizedBox(
                    width: 5,
                  ),
                  Expanded(child: discount_type()),
                ],
              ),
              Row(
                children: [
                  Expanded(child: startTime(context)),
                  SizedBox(
                    width: 5,
                  ),
                  Expanded(child: endTime(context)),
                ],
              ),
              branchChips(),
              CustomTextFormField(
                controller: getController.coponCodeController,
                labelText: 'Coupon Code',
                keyboardType: TextInputType.text,
                validator: (value) => Validation.validateisBlanck(value),
              ),
              CustomTextFormField(
                controller: getController.discountAmtController,
                labelText: 'Discount Amount',
                keyboardType: TextInputType.number,
                validator: (value) => Validation.validateisBlanck(value),
              ),
              CustomTextFormField(
                controller: getController.userLimitController,
                labelText: 'Use Limit',
                keyboardType: TextInputType.number,
                validator: (value) => Validation.validateisBlanck(value),
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
              // Add image picker and preview

              Btn_Coupons(),
              SizedBox(
                height: 5.h,
              )
            ],
          ),
        ),
      ),
    ));
  }

  Widget coupon_type() {
    return Obx(() => CustomDropdown<String>(
          value: getController.selectedCouponType.value.isEmpty
              ? null
              : getController.selectedCouponType.value,
          items: getController.dropdownCouponTypeItem,
          hintText: 'Coupon type',
          labelText: 'Coupon type',
          onChanged: (newValue) {
            if (newValue != null) {
              getController.selectedCouponType(newValue);
            }
          },
        ));
  }

  Widget discount_type() {
    return Obx(() => CustomDropdown<String>(
          value: getController.selectedDiscountType.value.isEmpty
              ? null
              : getController.selectedDiscountType.value,
          items: getController.dropdownDiscountTypeItem,
          hintText: 'Discount Type',
          labelText: 'Discount Type',
          onChanged: (newValue) {
            if (newValue != null) {
              getController.selectedDiscountType(newValue);
            }
          },
        ));
  }

  Widget startTime(BuildContext context) {
    return CustomTextFormField(
      controller: getController.StarttimeController,
      labelText: 'Start Time',
      keyboardType: TextInputType.none,
      validator: (value) => Validation.validateTime(value),
      suffixIcon: IconButton(
        onPressed: () async {
          await pickAndSetDate(
            context: context,
            controller: getController.StarttimeController,
          );
        },
        icon: Icon(Icons.calendar_today),
      ),
    );
  }

  Widget endTime(BuildContext context) {
    return CustomTextFormField(
      controller: getController.EndtimeController,
      labelText: 'End Time',
      keyboardType: TextInputType.none,
      validator: (value) => Validation.validateTime(value),
      suffixIcon: IconButton(
        onPressed: () async {
          await pickAndSetDate(
            context: context,
            controller: getController.EndtimeController,
          );
        },
        icon: Icon(Icons.calendar_today),
      ),
    );
  }

  Widget branchChips() {
    return Obx(() {
      return MultiDropdown<Branch>(
        items: getController.branchList
            .map((branch) => DropdownItem(
                  label: branch.name ?? 'Unknown',
                  value: branch,
                ))
            .toList(),
        controller: getController.branchController,
        enabled: true,
        searchEnabled: true,
        chipDecoration: const ChipDecoration(
          backgroundColor: primaryColor,
          wrap: true,
          runSpacing: 2,
          spacing: 10,
        ),
        fieldDecoration: const FieldDecoration(
          hintText: 'Select Branches *',
          showClearIcon: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
            borderSide: BorderSide(color: Colors.grey, width: 1.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
            borderSide: BorderSide(color: primaryColor, width: 2.0),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
            borderSide: BorderSide(color: Colors.red, width: 1.0),
          ),
        ),
        dropdownItemDecoration: DropdownItemDecoration(
          selectedIcon: const Icon(Icons.check_box, color: primaryColor),
          disabledIcon: Icon(Icons.lock, color: Colors.grey.shade300),
        ),
        onSelectionChange: (selectedItems) {
          getController.selectedBranches.value = selectedItems;
        },
      );
    });
  }

  Widget Btn_Coupons() {
    return ElevatedButtonExample(
      text: getController.isEditMode.value ? 'Update Coupon' : 'Add Coupon',
      onPressed: () {
        getController.onCoupons();
      },
    );
  }
}
