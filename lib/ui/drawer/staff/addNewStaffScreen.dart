import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_template/commen_items/commen_class.dart';
import 'package:flutter_template/ui/drawer/staff/addNewStaffController.dart';
import 'package:flutter_template/utils/colors.dart';
import 'package:flutter_template/utils/validation.dart';
import 'package:flutter_template/wiget/Custome_button.dart';
import 'package:flutter_template/wiget/Custome_textfield.dart';
import 'package:flutter_template/wiget/custome_dropdown.dart';
import 'package:flutter_template/wiget/custome_snackbar.dart';
import 'package:get/get.dart';
import 'package:multi_dropdown/multi_dropdown.dart';
import 'package:flutter_template/ui/drawer/staff/staffDetailsController.dart';
import 'package:flutter_template/network/network_const.dart';

import '../../../utils/custom_text_styles.dart';
import '../../../wiget/appbar/commen_appbar.dart';

class Addnewstaffscreen extends StatelessWidget {
  final bool showAppBar;
  final Data? staff;
  Addnewstaffscreen({super.key, this.showAppBar = true, this.staff});
  final Addnewstaffcontroller getController = Get.put(Addnewstaffcontroller());

  final _formKey = GlobalKey<FormState>();

  Widget _stepForm(int step, BuildContext context) {
    switch (step) {
      case 0:
        return Case1();

      case 1:
        return Case2(context);

      default:
        return SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    // If editing, populate fields and set edit mode
    if (staff != null && !getController.isEditMode.value) {
      getController.resetForm(); // Reset form first
      // Add a small delay to ensure form reset is complete
      Future.delayed(Duration(milliseconds: 200), () {
        getController.isEditMode.value = true;
        getController.editingStaffId = staff!.sId;
        getController.populateFromStaff(staff!);
      });
    }
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(75),
        child: Obx(() => CustomAppBar(
              title: getController.isEditMode.value
                  ? "Update Staff"
                  : "Add New Staff",
            )),
      ),
      body: Form(
        key: _formKey, 
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  spacing: 30.h,
                  children: [
                    // Obx(() => StepProgress(
                    //       totalSteps: 2,
                    //       currentStep: getController.currentStep.value,
                    //       stepSize: 24,
                    //       nodeTitles: const [
                    //         "Owner's Info",
                    //         "Salon's Info",
                    //       ],
                    //       padding: const EdgeInsets.all(18),
                    //       theme: const StepProgressThemeData(
                    //         shape: StepNodeShape.diamond,
                    //         activeForegroundColor: primaryColor,
                    //         defaultForegroundColor: secondaryColor,
                    //         stepLineSpacing: 18,
                    //         stepLineStyle: StepLineStyle(
                    //           borderRadius: Radius.circular(4),
                    //         ),
                    //         nodeLabelStyle: StepLabelStyle(
                    //           margin: EdgeInsets.only(bottom: 6),
                    //         ),
                    //         stepNodeStyle: StepNodeStyle(
                    //           activeIcon: null,
                    //           decoration: BoxDecoration(
                    //             borderRadius: BorderRadius.all(
                    //               Radius.circular(6),
                    //             ),
                    //           ),
                    //         ),
                    //       ),
                    //     )),
                    Obx(() =>
                        _stepForm(getController.currentStep.value, context)),
                    Obx(() => Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(width: 5.w),
                            if (getController.currentStep.value > 0)
                              Expanded(
                                child: ElevatedButtonExample(
                                  text: "Back",
                                  onPressed: getController.previousStep,
                                  height: 35.h,
                                ),
                              ),
                            if (getController.currentStep.value > 0)
                              SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButtonExample(
                                height: 35.h,
                                text: getController.isEditMode.value
                                    ? 'Update Staff'
                                    : getController.currentStep.value == 1
                                        ? 'Add Staff'
                                        : 'Next',
                                onPressed: () {
                                  if (getController.currentStep.value < 1) {
                                    getController.nextStep();
                                  } else {
                                    if (getController.isEditMode.value) {
                                      getController.onUpdateStaffPress();
                                    } else {
                                      getController.onAddStaffPress();
                                    }
                                  }
                                },
                              ),
                            ),
                          ],
                        )),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget Case1() {
    return Column(
      spacing: 10.h,
      children: [
        Imagepicker(),
        InputTxtfield_fullName(),
        InputTxtfield_Email(),
        // InputTxtfield_Pass(),
        // InputTxtfield_confirmPass(),
        CommitionDropdown(),
        Gender(),
        InputTxtfield_Specialization(),
      ],
    );
  }

  Widget Case2(BuildContext context) {
    return Column(
      spacing: 10.h,
      children: [
        serviceDropdown(),
        branchDropdown(),
        InputTxtfield_Phone(),
        Row(
          children: [
            Expanded(child: shiftStart_time(context)),
            SizedBox(width: 10.w),
            Expanded(child: shiftEnd_time(context)),
          ],
        ),

        // InputTxtfield_Salary(),
        Row(
          children: [
            Expanded(child: InputTxtfield_Duration()),
            SizedBox(width: 10.w),
            Expanded(child: LunchTime(context)),
          ],
        ),
      ],
    );
  }

  Widget Imagepicker() {
    return Obx(() {
      return GestureDetector(
        onTap: () async {
          Get.bottomSheet(
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
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
            border: Border.all(
              color: primaryColor,
              width: 1,
            ),
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(10.r),
            color: secondaryColor.withOpacity(0.2),
          ),
          child: getController.singleImage.value != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(10.r),
                  child: getController.singleImage.value is File
                      ? Image.file(
                          getController.singleImage.value!,
                          fit: BoxFit.cover,
                        )
                      : getController.singleImage.value is String &&
                              getController.singleImage.value!.isNotEmpty
                          ? Image.network(
                              '${Apis.pdfUrl}${getController.singleImage.value}?v=${DateTime.now().millisecondsSinceEpoch}',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  Icons.image_not_supported,
                                  color: primaryColor,
                                  size: 30.sp,
                                );
                              },
                            )
                          : Icon(
                              Icons.image_rounded,
                              color: primaryColor,
                              size: 30.sp,
                            ),
                )
              : Icon(
                  Icons.image_rounded,
                  color: primaryColor,
                  size: 30.sp,
                ),
        ),
      );
    });
  }

  Widget InputTxtfield_fullName() {
    return CustomTextFormField(
      controller: getController.fullnameController,
      labelText: "Name",
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
      controller: getController.phoneController,
      labelText: "Contect Number",
      keyboardType: TextInputType.phone,
      validator: (value) => Validation.validatePhone(value),
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(10),
      ],
    );
  }

  Widget InputTxtfield_Specialization() {
    return CustomTextFormField(
      controller: getController.specializationController,
      labelText: "Specialization",
      keyboardType: TextInputType.text,
      validator: (value) => Validation.validateisBlanck(value),
    );
  }

  // Widget InputTxtfield_Salary() {
  //   return CustomTextFormField(
  //     controller: getController.salaryController,
  //     labelText: "Salary",
  //     keyboardType: TextInputType.number,
  //     validator: (value) => Validation.validateSalary(value),
  //   );
  // }

  Widget InputTxtfield_Duration() {
    return CustomTextFormField(
      controller: getController.durationController,
      labelText: "Duration",
      keyboardType: TextInputType.number,
      validator: (value) => Validation.validateDuration(value),
    );
  }

  Widget shiftStart_time(BuildContext context) {
    return CustomTextFormField(
      controller: getController.shiftStarttimeController,
      labelText: 'Shift Start Time',
      keyboardType: TextInputType.none,
      validator: (value) => Validation.validateTime(value),
      suffixIcon: IconButton(
        onPressed: () async {
          TimeOfDay initialTime = TimeOfDay.now();
          TimeOfDay? pickedTime = await showTimePicker(
            context: context,
            initialTime: initialTime,
          );
          if (pickedTime != null) {
            String formattedTime = formatTimeToString(pickedTime);
            getController.shiftStarttimeController.text = formattedTime;
          }
        },
        icon: Icon(Icons.access_time),
      ),
    );
  }

  Widget LunchTime(BuildContext context) {
    return CustomTextFormField(
      controller: getController.LunchStarttimeController,
      labelText: 'Lunch Start At',
      keyboardType: TextInputType.none,
      validator: (value) => Validation.validateTime(value),
      suffixIcon: IconButton(
        onPressed: () async {
          TimeOfDay initialTime = TimeOfDay.now();
          TimeOfDay? pickedTime = await showTimePicker(
            context: context,
            initialTime: initialTime,
          );
          if (pickedTime != null) {
            String formattedTime = formatTimeToString(pickedTime);
            getController.LunchStarttimeController.text = formattedTime;
          }
        },
        icon: Icon(Icons.access_time),
      ),
    );
  }

  Widget shiftEnd_time(BuildContext context) {
    return CustomTextFormField(
      controller: getController.shiftEndtimeController,
      labelText: 'Shift End Time',
      keyboardType: TextInputType.none,
      validator: (value) => Validation.validateTime(value),
      suffixIcon: IconButton(
        onPressed: () async {
          TimeOfDay initialTime = TimeOfDay.now();
          TimeOfDay? pickedTime = await showTimePicker(
            context: context,
            initialTime: initialTime,
          );
          if (pickedTime != null) {
            String formattedTime = formatTimeToString(pickedTime);
            getController.shiftEndtimeController.text = formattedTime;
          }
        },
        icon: Icon(Icons.access_time),
      ),
    );
  }

  Widget Gender() {
    return Obx(() => CustomDropdown<String>(
          value: getController.selectedGender.value.isEmpty
              ? null
              : getController.selectedGender.value,
          items: getController.dropdownItems,
          // hintText: 'Gender',
          labelText: 'Gender',
          onChanged: (newValue) {
            if (newValue != null) {
              getController.selectedGender(newValue);
            }
          },
        ));
  }

  // Widget InputTxtfield_Pass() {
  //   return Obx(() => CustomTextFormField(
  //         controller: getController.passwordController,
  //         labelText: 'Password',
  //         obscureText: !getController.showPass.value,
  //         suffixIcon: IconButton(
  //           onPressed: () {
  //             getController.toggleShowPass();
  //           },
  //           icon: Icon(
  //             getController.showPass.value
  //                 ? Icons.visibility
  //                 : Icons.visibility_off,
  //             color: grey,
  //           ),
  //         ),
  //         validator: (value) => Validation.validatePassword(value),
  //       ));
  // }

  // Widget InputTxtfield_confirmPass() {
  //   return Obx(() => CustomTextFormField(
  //         controller: getController.confirmpasswordController,
  //         labelText: 'Confirm Password',
  //         obscureText: !getController.showPass2.value,
  //         suffixIcon: IconButton(
  //           onPressed: () {
  //             getController.toggleShowPass2();
  //           },
  //           icon: Icon(
  //             getController.showPass.value
  //                 ? Icons.visibility
  //                 : Icons.visibility_off,
  //             color: grey,
  //           ),
  //         ),
  //         validator: (value) => Validation.validatePassword(value),
  //       ));
  // }

  Widget serviceDropdown() {
    return Obx(() {
      // Trigger service initialization when dropdown is built in edit mode
      if (getController.isEditMode.value &&
          getController.serviceList.isNotEmpty &&
          getController.selectedServices.isNotEmpty &&
          getController.serviceController.selectedItems.isEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          getController.initializeServiceController();
        });
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
          selectedIcon: const Icon(Icons.check_box, color: primaryColor),
          disabledIcon: Icon(Icons.lock, color: Colors.grey.shade300),
        ),
        onSelectionChange: (selectedItems) {
          getController.selectedServices.value = selectedItems;
        },
      );
    });
  }

  // Widget branchDropdown() {
  //   return Obx(() {
  //     return DropdownButton<Branch>(
  //       value: getController.selectedBranch.value,
  //       hint: Text("Select Branch"),
  //       items: getController.branchList.map((Branch branch) {
  //         return DropdownMenuItem<Branch>(
  //           value: branch,
  //           child: Text(branch.name ?? ''),
  //         );
  //       }).toList(),
  //       onChanged: (Branch? newValue) {
  //         if (newValue != null) {
  //           getController.selectedBranch.value = newValue;

  //           CustomSnackbar.showSuccess(
  //             'Branch Selected',
  //             'ID: ${newValue.id}',
  //           );
  //         }
  //       },
  //     );
  //   });
  // }
  Widget branchDropdown() {
    return Obx(() {
      return DropdownButtonFormField<Branch>(
        value: getController.selectedBranch.value,
        decoration: InputDecoration(
          labelText: "Select Branch",
           labelStyle: CustomTextStyles.textFontMedium(size: 14.sp, color: grey),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(
              color: primaryColor,
            ),
          ),
        ),
        items: getController.branchList.map((Branch branch) {
          return DropdownMenuItem<Branch>(
            value: branch,
            child: Text(branch.name ?? ''),
          );
        }).toList(),
        onChanged: (Branch? newValue) {
          if (newValue != null) {
            getController.selectedBranch.value = newValue;

            // CustomSnackbar.showSuccess(
            //   'Branch Selected',
            //   'ID: ${newValue.id}',
            // );
          }
        },
      );
    });
  }

  Widget CommitionDropdown() {
    return Obx(() {
      return DropdownButtonFormField<Commition>(
        value: getController.selectedCommitionId.value,
        decoration: InputDecoration(
          labelText: "Select Commision",
           labelStyle: CustomTextStyles.textFontMedium(size: 14.sp, color: grey),
          border: OutlineInputBorder(),
        ),
        items: getController.commitionList.map((Commition commition) {
          return DropdownMenuItem<Commition>(
            value: commition,
            child: Text(commition.name ?? ''),
          );
        }).toList(),
        onChanged: (Commition? newValue) {
          if (newValue != null) {
            getController.selectedCommitionId.value = newValue;
            CustomSnackbar.showSuccess(
              'Commition Selected',
              'ID: $newValue',
            );
          }
        },
      );
    });
  }
}
