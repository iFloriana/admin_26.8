import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_template/network/network_const.dart';
import 'package:flutter_template/ui/drawer/appointment/addNewAppointment/newAppointmentController.dart';
import 'package:flutter_template/utils/app_images.dart';
import 'package:flutter_template/utils/colors.dart';
import 'package:get/get.dart';
import 'package:step_progress/step_progress.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../utils/validation.dart';
import '../../../../wiget/Custome_textfield.dart';
import '../../../../wiget/custome_dropdown.dart';
import '../../../../wiget/loading.dart';

class Newappointmentscreen extends StatelessWidget {
  final Newappointmentcontroller getController =
      Get.put(Newappointmentcontroller());

  final _formKey = GlobalKey<FormState>();

  final List<String> nodeTitles = const [
    "Select Branch",
    "Select Service",
    "Select Staff",
    "Select Date & Time",
    "Customer Details",
    "Confirmation Detail",
  ];

  Widget _stepForm(int step) {
    switch (step) {
      case 0:
        return Case1();
      case 1:
        return Case2();
      case 2:
        return Case3();
      case 3:
        return Case4();
      case 4:
        return Case5();
      case 5:
        return Case6();
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(
              nodeTitles[getController.currentStep.value],
              style: TextStyle(
                color: Colors.white,
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
            )),
        backgroundColor: primaryColor,
        iconTheme: IconThemeData(color: white),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            loginScreenHeader(),
            Expanded(
              child: Obx(() {
                return SingleChildScrollView(
                  padding: EdgeInsets.all(10.w),
                  child: _stepForm(getController.currentStep.value),
                );
              }),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        child: navigationButtons(),
      ),
    );
  }

  Widget loginScreenHeader() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20.r),
          bottomRight: Radius.circular(20.r),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Obx(() => StepProgress(
                  totalSteps: nodeTitles.length,
                  currentStep: getController.currentStep.value,
                  stepSize: 20,
                  padding: const EdgeInsets.all(10),
                  theme: StepProgressThemeData(
                    shape: StepNodeShape.heptagon,
                    activeForegroundColor: secondaryColor,
                    defaultForegroundColor: Colors.white70,
                    stepLineSpacing: 18,
                    stepLineStyle: StepLineStyle(
                      borderRadius: Radius.circular(4),
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget navigationButtons() {
    return Obx(() {
      final step = getController.currentStep.value;
      final isLoading = getController.isBookingLoading.value;
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          (step > 0 && step < 5)
              ? ElevatedButton(
                  onPressed: () => getController.previousStep(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: secondaryColor,
                  ),
                  child: const Text(
                    "Back",
                    style: TextStyle(color: white),
                  ),
                )
              : const SizedBox(width: 100),
          ElevatedButton(
            onPressed: isLoading
                ? null
                : () {
                    if (_formKey.currentState!.validate()) {
                      if (step == 4) {
                        getController.addBooking();
                      } else if (step >= nodeTitles.length - 1) {
                        Get.back();
                      } else {
                        // Validate current step before proceeding
                        if (getController.canProceedToNextStep()) {
                          getController.nextStep();
                        } else {
                          _showValidationMessage(step);
                        }
                      }
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
            ),
            child: isLoading
                ? SizedBox(width: 24, height: 24, child: CustomLoadingAvatar())
                : Text(
                    step == 4
                        ? "Add Booking"
                        : (step >= nodeTitles.length - 1 ? "Finish" : "Next"),
                    style: TextStyle(color: white),
                  ),
          ),
        ],
      );
    });
  }

  Widget Case1() {
    return Obx(() {
      final branchList = getController.branches;
      return GridView.builder(
        shrinkWrap: true,
        // physics: NeverScrollableScrollPhysics(),
        itemCount: branchList.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 3 / 3.8,
          crossAxisSpacing: 10.w,
          mainAxisSpacing: 10.h,
        ),
        itemBuilder: (context, index) {
          final branch = branchList[index];
          return GestureDetector(
            onTap: () => getController.selectBranch(branch),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: getController.selectedBranch.value == branch
                      ? primaryColor
                      : Colors.grey.shade200,
                  width: getController.selectedBranch.value == branch ? 2 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: Offset(0, 3), // changes position of shadow
                  ),
                ],
              ),
              // elevation: 4,
              // shape: RoundedRectangleBorder(
              //     borderRadius: BorderRadius.circular(12.r)),
              child: Padding(
                padding: EdgeInsets.all(10.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 30.r,
                      backgroundImage: branch.image != null
                          ? NetworkImage("${Apis.pdfUrl}${branch.image}"!)
                          : AssetImage(AppImages.placeholder) as ImageProvider,
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      branch.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: getController.selectedBranch.value == branch
                            ? primaryColor
                            : Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 5.h),
                    Text(
                      "${branch.country} / ${branch.postalCode}",
                      style: TextStyle(color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                    Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.phone, size: 16, color: grey),
                        SizedBox(width: 5),
                        Text(branch.contactNumber,
                            style: TextStyle(fontSize: 12, color: grey)),
                      ],
                    ),
                    SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.email, size: 16, color: grey),
                        SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            branch.contactEmail,
                            style: TextStyle(fontSize: 12, color: grey),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    });
  }

  Widget Case2() {
    return Obx(() {
      final branch = getController.selectedBranch.value;
      final serviceList = branch?.services ?? [];
      if (serviceList.isEmpty) {
        return Center(
            child: Text(
          "No services available for this branch.",
          style: TextStyle(color: secondaryColor),
        ));
      }
      return GridView.builder(
        shrinkWrap: true,
        // physics: NeverScrollableScrollPhysics(),
        itemCount: serviceList.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 3 / 2.2,
          crossAxisSpacing: 10.w,
          mainAxisSpacing: 10.h,
        ),
        itemBuilder: (context, index) {
          final service = serviceList[index];
          return GestureDetector(
            onTap: () {
              getController.selectedService.value = service;
              getController.nextStep();
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: getController.selectedService.value == service
                      ? primaryColor
                      : Colors.grey.shade200,
                  width: getController.selectedService.value == service ? 2 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.all(10.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      service.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: getController.selectedService.value == service
                            ? primaryColor
                            : Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      "${service.serviceDuration} min",
                      style: TextStyle(color: Colors.grey),
                    ),
                    SizedBox(height: 8.h),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: secondaryColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "\₹ ${service.regularPrice.toStringAsFixed(2)}",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    });
  }

  Widget Case3() {
    return Obx(() {
      final branch = getController.selectedBranch.value;
      if (branch == null) {
        return Center(
            child: Text(
          "Please select a branch first.",
          style: TextStyle(color: secondaryColor),
        ));
      }
      // Fetch staff if not already fetched
      if (getController.staff.isEmpty) {
        getController.fetchStaffsForBranch();
        return Center(child: CustomLoadingAvatar());
      }
      final staffList = getController.filteredStaff;
      if (staffList.isEmpty) {
        return Center(
            child: Text(
          "No staff available for this branch and service.",
          style: TextStyle(color: secondaryColor),
        ));
      }
      return GridView.builder(
        shrinkWrap: true,
        // physics: NeverScrollableScrollPhysics(),
        itemCount: staffList.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 3 / 2.2,
          crossAxisSpacing: 10.w,
          mainAxisSpacing: 10.h,
        ),
        itemBuilder: (context, index) {
          final staff = staffList[index];
          return GestureDetector(
            onTap: () {
              getController.selectedStaff.value = staff;
              getController.nextStep();
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: getController.selectedStaff.value == staff
                      ? primaryColor
                      : Colors.grey.shade200,
                  width: getController.selectedStaff.value == staff ? 2 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 30.r,
                    backgroundImage: staff.imageUrl != null &&
                            staff.imageUrl!.isNotEmpty
                        ? NetworkImage("${Apis.pdfUrl}${staff.imageUrl!}")
                        : AssetImage(AppImages.placeholder) as ImageProvider,
                    backgroundColor: Colors.grey[200],
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    staff.fullName,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16.sp,
                      color: getController.selectedStaff.value == staff
                          ? primaryColor
                          : Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }

  Widget Case4() {
    return Obx(() {
      final selectedDate = getController.selectedDate.value;
      final availableSlots = getController.availableSlots;
      final selectedSlot = getController.selectedSlot.value;
      final currentStep = getController.currentStep.value;

      // Auto-open date picker when Case4 is first displayed
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (currentStep == 3 && selectedDate == null) {
          _showDatePicker();
        }
      });

      return Column(
        spacing: 10.h,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => _showDatePicker(),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: primaryColor),
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.calendar_today, size: 20, color: primaryColor),
                  SizedBox(width: 8),
                  Text(
                    selectedDate != null
                        ? "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}"
                        : "Pick a date",
                    style: TextStyle(
                      color: selectedDate != null ? black : Colors.grey[600],
                      fontWeight: selectedDate != null
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 10.h),
          if (selectedDate != null)
            Text("Available Slots",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.sp,
                  color: primaryColor,
                )),
          SizedBox(height: 10.h),
          Align(
              alignment: Alignment.center,
              child: availableSlots.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Text(
                        "No slots available for this date.",
                        style: TextStyle(color: secondaryColor),
                      ),
                    )
                  : Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: availableSlots.map((slot) {
                        final isSelected = selectedSlot == slot;
                        return ChoiceChip(
                          label: Text(
                            slot,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : Colors.black, // 👈 Change text color here
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: primaryColor,
                          disabledColor: secondaryColor,
                          checkmarkColor: Colors.white,
                          onSelected: (selected) {
                            if (selected) {
                              getController.selectedSlot.value = slot;
                              if (getController.selectedDate.value != null) {
                                Future.delayed(Duration(milliseconds: 500), () {
                                  getController.nextStep();
                                });
                              }
                            }
                          },
                        );
                      }).toList(),
                    ))
        ],
      );
    });
  }

  Future<void> _showDatePicker() async {
    final picked = await showDatePicker(
      context: Get.context!,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (picked != null) {
      getController.selectedDate.value = picked;
      await getController.fetchAvailableSlots();
      getController.selectedSlot.value = null;

      // Auto navigate to next step if slot is already selected
      if (getController.selectedSlot.value != null) {
        Future.delayed(Duration(milliseconds: 500), () {
          getController.nextStep();
        });
      }
    }
  }

  void _showValidationMessage(int step) {
    final message = getController.getValidationMessage();
    ScaffoldMessenger.of(Get.context!).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget Case5() {
    return Column(
      spacing: 10,
      children: [
        CustomTextFormField(
          controller: getController.fullNameController,
          labelText: 'Full Name',
          keyboardType: TextInputType.text,
          validator: (value) => Validation.validatename(value),
        ),
        CustomTextFormField(
          controller: getController.emailController,
          labelText: 'Email',
          keyboardType: TextInputType.emailAddress,
          validator: (value) => Validation.validateEmail(value),
        ),
        CustomTextFormField(
          controller: getController.phoneController,
          labelText: 'Phone Number',
          keyboardType: TextInputType.phone,
          validator: (value) => Validation.validatePhone(value),
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
          ],
        ),
        Obx(() => CustomDropdown<String>(
              value: getController.selectedGender.value.isEmpty
                  ? null
                  : getController.selectedGender.value,
              items: getController.genderOptions,
              hintText: 'Gender',
              labelText: 'Gender',
              onChanged: (newValue) {
                if (newValue != null) {
                  getController.selectedGender.value = newValue;
                }
              },
            ))
      ],
    );
  }

  Widget Case6() {
    final branch = getController.selectedBranch.value;
    final staff = getController.selectedStaff.value;
    final service = getController.selectedService.value;
    final date = getController.selectedDate.value;
    final slot = getController.selectedSlot.value;
    final name = getController.fullNameController.text;
    final phone = getController.phoneController.text;
    final email = getController.emailController.text;

    // Service price
    final double price = service?.regularPrice ?? 0;

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Text("Confirmation Detail",
            //     style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            // Divider(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Salon Info
                Text("SALON INFO",
                    style: TextStyle(
                        color: primaryColor, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: secondaryColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    spacing: 5.h,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(branch?.name ?? '',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Row(
                        children: [
                          Icon(Icons.phone, size: 16, color: secondaryColor),
                          SizedBox(width: 8),
                          GestureDetector(
                            onTap: () async {
                              final phoneNumber = branch?.contactNumber ?? '';
                              if (phoneNumber.isNotEmpty) {
                                final Uri phoneUri =
                                    Uri(scheme: 'tel', path: phoneNumber);
                                if (await canLaunchUrl(phoneUri)) {
                                  await launchUrl(phoneUri);
                                } else {
                                  ScaffoldMessenger.of(Get.context!)
                                      .showSnackBar(
                                    SnackBar(
                                      content:
                                          Text('Could not launch phone dialer'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            },
                            child: Text(
                              "${branch?.contactNumber ?? ''}",
                              style: TextStyle(
                                color: primaryColor,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                // Customer Info
                Text("CUSTOMER INFO",
                    style: TextStyle(
                        color: primaryColor, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: secondaryColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    spacing: 5.h,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Name: $name"),
                      Row(
                        children: [
                          Icon(Icons.phone, size: 16, color: secondaryColor),
                          SizedBox(width: 8),
                          GestureDetector(
                            onTap: () async {
                              if (phone.isNotEmpty) {
                                final Uri phoneUri =
                                    Uri(scheme: 'tel', path: phone);
                                if (await canLaunchUrl(phoneUri)) {
                                  await launchUrl(phoneUri);
                                } else {
                                  ScaffoldMessenger.of(Get.context!)
                                      .showSnackBar(
                                    SnackBar(
                                      content:
                                          Text('Could not launch phone dialer'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            },
                            child: Text(
                              "Number: $phone",
                              style: TextStyle(
                                color: primaryColor,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(Icons.email, size: 16, color: secondaryColor),
                          SizedBox(width: 8),
                          GestureDetector(
                            onTap: () async {
                              if (email.isNotEmpty) {
                                final Uri emailUri =
                                    Uri(scheme: 'mailto', path: email);
                                if (await canLaunchUrl(emailUri)) {
                                  await launchUrl(emailUri);
                                } else {
                                  ScaffoldMessenger.of(Get.context!)
                                      .showSnackBar(
                                    SnackBar(
                                      content:
                                          Text('Could not launch email app'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            },
                            child: Text(
                              "Email: $email",
                              style: TextStyle(
                                color: primaryColor,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                // Appointment Summary
                Text("APPOINTMENT SUMMARY",
                    style: TextStyle(
                        color: primaryColor, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: secondaryColor.withOpacity(0.3)),
                  ),
                  child: Column(
                    spacing: 5.h,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text("Staff: ",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(staff?.fullName ?? ''),
                        ],
                      ),
                      Row(
                        children: [
                          Text("Date: ",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(date != null
                              ? "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}"
                              : ''),
                        ],
                      ),
                      Row(
                        children: [
                          Text("Time: ",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(slot ?? ''),
                        ],
                      ),
                      SizedBox(height: 12),
                      Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: secondaryColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          spacing: 5.h,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Services",
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            Row(
                              spacing: 5.h,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(service?.name ?? ''),
                                Text("₹ ${price.toStringAsFixed(2)}"),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
