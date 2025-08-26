import 'package:flutter/material.dart';
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
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io';
import '../../../../network/network_const.dart';
import '../../../../wiget/loading.dart';
import '../customerController.dart';

class EditCustomerScreen extends StatelessWidget {
  EditCustomerScreen({super.key});
  final CustomerController customerController = Get.find<CustomerController>();

  void prefillCustomerFields(Customer customer) {
    // Clear previous selections
    customerController.fullNameController.text = '';
    customerController.emailController.text = '';
    customerController.phoneController.text = '';
    customerController.selectedGender.value = 'Male';
    customerController.isActive.value = true;
    customerController.showPackageFields.value = false;
    customerController.selectedPackages.clear();
    customerController.packageController.clearAll();
    customerController.selectedBranchMembership.value = '';
    customerController.selectedImage.value = null;
    customerController.existingImageUrl.value = null;

    // Prefill controllers
    customerController.fullNameController.text = customer.fullName;
    customerController.emailController.text = customer.email;
    customerController.phoneController.text = customer.phoneNumber;
    if (customer.image != null && customer.image!.isNotEmpty) {
      customerController.existingImageUrl.value =
          '${Apis.pdfUrl}${customer.image}?v=${DateTime.now().millisecondsSinceEpoch}';
    } else {
      customerController.existingImageUrl.value = null;
    }
    //  customerController.   customer.image;   pre selected image

    // Prefill gender
    final genderValue = customer.gender.capitalizeFirst ?? 'Male';
    customerController.selectedGender.value =
        customerController.genderOptions.contains(genderValue)
            ? genderValue
            : 'Male';

    // Prefill status
    customerController.isActive.value = customer.status == 1;

    customerController.singleImage.value = null;
    // Prefill package/membership fields
    final hasPackages = customer.branchPackage.isNotEmpty;
    final hasMembership = (customer.branchMembershipId.isNotEmpty) ||
        (customer.branchMembershipObj != null &&
            customer.branchMembershipObj!['_id'] != null);
    customerController.showPackageFields.value = hasPackages || hasMembership;

    // Prefill branch packages
    if (hasPackages && customerController.branchPackageList.isNotEmpty) {
      final customerPackageIds =
          customer.branchPackage.map((id) => id.toString().trim()).toList();
      final selectedPkgs = customerController.branchPackageList
          .where((pkg) =>
              pkg.id != null &&
              customerPackageIds.contains(pkg.id.toString().trim()))
          .toList();
      customerController.selectedPackages.value = selectedPkgs;
      customerController.packageController.clearAll();
      customerController.packageController
          .selectWhere((item) => selectedPkgs.contains(item.value));
    } else {
      customerController.selectedPackages.clear();
      customerController.packageController.clearAll();
    }

    // Prefill branch membership (use id from object if id is missing)
    String? membershipId;
    if (customer.branchMembershipId.isNotEmpty) {
      membershipId = customer.branchMembershipId;
    } else if (customer.branchMembershipObj != null &&
        customer.branchMembershipObj!['_id'] != null) {
      membershipId = customer.branchMembershipObj!['_id'];
    }
    if (membershipId != null &&
        customerController.branchMembershipList
            .any((m) => m.id == membershipId)) {
      customerController.selectedBranchMembership.value = membershipId;
    } else {
      customerController.selectedBranchMembership.value = '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final customer = Get.arguments as Customer;

    return Obx(() {
      if (!customerController.packagesLoaded.value ||
          !customerController.membershipsLoaded.value) {
        return const Center(child: CustomLoadingAvatar());
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        prefillCustomerFields(customer);
      });

      return Scaffold(
        appBar: CustomAppBar(title: "Edit Customer"),
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
                ),
                genderDropdown(customer),
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
                // Enable Package & Membership toggle and dropdowns
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
                          // Branch Packages Dropdown (Multi-select)
                          MultiDropdown(
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
                                borderSide:
                                    const BorderSide(color: Colors.grey),
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
                                  Icon(Icons.lock, color: Colors.grey),
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
                                          .selectedBranchMembership
                                          .value
                                          .isEmpty
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
                                      customerController
                                          .selectedBranchMembership
                                          .value = newValue;
                                    }
                                  },
                                )),
                          ),
                        ],
                      )
                    : const SizedBox()),
                Btn_updateCustomer(customer.id),
                SizedBox(height: 20.h),
              ],
            ),
          ),
        ),
      );
    });
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
                            // Positioned(
                            //   top: 4,
                            //   right: 4,
                            //   child: GestureDetector(
                            //     onTap: customerController.removeSelectedImage,
                            //     child: Container(
                            //       padding: const EdgeInsets.all(4),
                            //       decoration: const BoxDecoration(
                            //         color: Colors.red,
                            //         shape: BoxShape.circle,
                            //       ),
                            //       child: const Icon(
                            //         Icons.close,
                            //         color: Colors.white,
                            //         size: 16,
                            //       ),
                            //     ),
                            //   ),
                            // ),
                          ],
                        )
                      : customerController.existingImageUrl.value != null &&
                              customerController
                                  .existingImageUrl.value!.isNotEmpty
                          ? Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8.r),
                                  child: CachedNetworkImage(
                                    imageUrl: customerController
                                        .existingImageUrl.value!,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                    placeholder: (context, url) => const Center(
                                      child: CustomLoadingAvatar(),
                                    ),
                                    errorWidget: (context, url, error) =>
                                        const Icon(
                                      Icons.error,
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                                // Positioned(
                                //   top: 4,
                                //   right: 4,
                                //   child: GestureDetector(
                                //     onTap: () {
                                //       customerController
                                //           .existingImageUrl.value = null;
                                //     },
                                //     child: Container(
                                //       padding: const EdgeInsets.all(4),
                                //       decoration: const BoxDecoration(
                                //         color: Colors.red,
                                //         shape: BoxShape.circle,
                                //       ),
                                //       child: const Icon(
                                //         Icons.close,
                                //         color: Colors.white,
                                //         size: 16,
                                //       ),
                                //     ),
                                //   ),
                                // ),
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

  Widget genderDropdown(Customer customer) {
    return Obx(() => CustomDropdown<String>(
          value: customerController.selectedGender.value.isEmpty
              ? (customer.gender.isNotEmpty ? customer.gender : 'Male')
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

  Widget Btn_updateCustomer(String customerId) {
    return Obx(() => ElevatedButtonExample(
          text: customerController.isLoading.value
              ? "Updating..."
              : "Update Customer",
          onPressed: customerController.isLoading.value
              ? () {}
              : () {
                  customerController.updateCustomer(customerId);
                },
        ));
  }
}
