import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_template/manager_ui/manager_appointment_screen/managerAppointmentController.dart';
import 'package:flutter_template/network/network_const.dart';
import 'package:flutter_template/utils/app_images.dart';
import 'package:flutter_template/utils/colors.dart';
import 'package:get/get.dart';
import 'package:step_progress/step_progress.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../utils/validation.dart';
import '../../../../wiget/Custome_textfield.dart';
import '../../../../wiget/custome_dropdown.dart';
import '../../../../wiget/loading.dart';

class Managerappointmentsscreen extends StatelessWidget {
  final getController = Get.put(Managerappointmentcontroller());

  final _formKey = GlobalKey<FormState>();

  final List<String> nodeTitles = const [
    "Select Service",
    "Select Staff",
    "Select Date & Time",
    "Customer Details",
    "Confirmation Detail",
  ];

  Widget _stepForm(int step) {
    switch (step) {
      case 0:
        return Case2();
      case 1:
        return Case3();
      case 2:
        return Case4();
      case 3:
        return Case5();
      case 4:
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
      final lastIndex = nodeTitles.length - 1;
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button: show when not on first step and not on final confirmation
          (step > 0 && step <= lastIndex)
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
                : () async {
                    if (!_formKey.currentState!.validate()) return;

                    // If we are on Customer Details step (index 3) -> add booking
                    // Note: Customer Details moved from 4 -> 3 (after removing branch step)
                    if (step == 3) {
                      await getController.addBooking();
                      return;
                    }

                    // If already on final confirmation step, just close
                    if (step >= lastIndex) {
                      Get.back();
                      return;
                    }

                    // Validate current step before proceeding
                    if (getController.canProceedToNextStep()) {
                      // Move to next step safely (limit by nodeTitles length)
                      if (getController.currentStep.value < lastIndex) {
                        getController.currentStep.value++;

                        // If we just landed on the Date & Time step (now index 2),
                        // set today's date and fetch slots
                        if (getController.currentStep.value == 2) {
                          getController.selectedDate.value = DateTime.now();
                          await getController.fetchAvailableSlots();
                        }
                      }
                    } else {
                      _showValidationMessage(step);
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
            ),
            child: isLoading
                ? SizedBox(width: 24, height: 24, child: CustomLoadingAvatar())
                : Text(
                    // Show "Add Booking" on Customer Details step (index 3)
                    step == 3
                        ? "Add Booking"
                        : (step >= nodeTitles.length - 1 ? "Finish" : "Next"),
                    style: TextStyle(color: white),
                  ),
          ),
        ],
      );
    });
  }

  // Removed obsolete Case1 (branch selection)
  Widget Case2() {
    return Obx(() {
      final serviceList = getController.services;
      if (serviceList.isEmpty) {
        // Trigger fetch once if not loaded
        getController.fetchServicesForBranch();
        return Center(child: CustomLoadingAvatar());
      }
      return GridView.builder(
        shrinkWrap: true,
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
                        "₹ ${service.regularPrice.toStringAsFixed(2)}",
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
      // Fetch staff if not already fetched
      if (getController.staff.isEmpty) {
        getController.fetchStaffsForBranch();
        return Center(child: CustomLoadingAvatar());
      }

      return FutureBuilder<List<StaffModel>>(
        future: getController.filteredStaff,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return Center(child: CustomLoadingAvatar());
          }
          final staffList = snapshot.data ?? [];
          if (staffList.isEmpty) {
            return Center(
                child: Text(
              "No staff available for this service.",
              style: TextStyle(color: secondaryColor),
            ));
          }
          return GridView.builder(
            shrinkWrap: true,
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
                            : AssetImage(AppImages.placeholder)
                                as ImageProvider,
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
        if (currentStep == 2 && selectedDate == null) {
          _showDatePicker();
        }
      });

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 10.h),
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
      children: [
        CustomTextFormField(
          controller: getController.fullNameController,
          labelText: 'Full Name',
          keyboardType: TextInputType.text,
          validator: (value) => Validation.validatename(value),
        ),
        SizedBox(height: 10),
        CustomTextFormField(
          controller: getController.emailController,
          labelText: 'Email',
          keyboardType: TextInputType.emailAddress,
          validator: (value) => Validation.validateEmail(value),
        ),
        SizedBox(height: 10),
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
        SizedBox(height: 10),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 5),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 5),
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 5),
                            Text("Services",
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            Row(
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
