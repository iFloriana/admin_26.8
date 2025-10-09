import 'package:flutter/material.dart';
import 'package:flutter_template/route/app_route.dart';
import 'package:flutter_template/ui/auth/renewPackage/renewPackageController.dart';
import 'package:flutter_template/wiget/appbar/commen_appbar.dart';
import 'package:flutter_template/wiget/loading.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../utils/colors.dart';
import '../../../utils/custom_text_styles.dart';
import '../../../wiget/Custome_button.dart';
import '../../../wiget/custome_text.dart';
import '../../../network/model/packages_model.dart';

class Renewpackagescreen extends StatelessWidget {
  Renewpackagescreen({super.key});

  final getController = Get.put(RenewPackagesController());

  @override
  Widget build(BuildContext context) {
    // Show dialog after the frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Reset controller states before opening dialog
      getController.clearData();

      Get.dialog(
        Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Verify Email",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: 20),

                // Email field
                TextField(
                  controller: getController.emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: "Enter Email",
                    labelStyle: const TextStyle(color: grey),
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: primaryColor,
                        width: 2,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Loading or Result
                Obx(() {
                  if (getController.isLoading.value) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: CustomLoadingAvatar(),
                    );
                  }

                  if (getController.adminName.isNotEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.deepPurple.shade100,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "✅ Admin: ${getController.adminName.value}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: primaryColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text("📧 ${getController.adminEmail.value}",
                              style: const TextStyle(fontSize: 14)),
                          const SizedBox(height: 8),
                          Text(
                            "🏢 Salon: ${getController.salonName.value}",
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return const SizedBox.shrink();
                }),

                const SizedBox(height: 24),

                // Dynamic buttons
                Obx(() {
                  final hasData = getController.adminName.isNotEmpty &&
                      getController.adminEmail.isNotEmpty &&
                      getController.salonName.isNotEmpty;

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: primaryColor,
                          side: const BorderSide(color: primaryColor),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                        ),
                        onPressed: () {
                          Get.offAllNamed(Routes.Adminprofilescreen);
                        },
                        child: const Text("Cancel"),
                      ),

                      // Change button dynamically
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                        ),
                        onPressed: () {
                          if (hasData) {
                            getController.fetchPackages();
                            Get.back();
                          } else {
                            getController.verifyEmail(
                              getController.emailController.text.trim(),
                            );
                          }
                        },
                        child: Text(
                          hasData ? "Proceed" : "Check Email",
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
        ),
        barrierDismissible: false,
      );
    });

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Renew Package',
      ),
      body: RefreshIndicator(
        color: primaryColor,
        onRefresh: () async {
          getController.fetchPackages();
        },
        child: Column(
          children: [
            SizedBox(height: 5.h),
            Expanded(
              child: Obx(() {
                if (getController.isLoading.value ||
                    getController.packages.isEmpty) {
                  return const Center(
                    child: CustomLoadingAvatar(),
                  );
                }
                return ListView.builder(
                  itemCount: getController.packages.length,
                  itemBuilder: (context, index) {
                    return _buildRadioCard(getController.packages[index]);
                  },
                );
              }),
            ),
            Obx(() => getController.selectedPackageId.value != null
                ? Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                      ),
                      onPressed: () => getController.renewPackage(),
                      child: const Text(
                        "Proceed to Payment",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  )
                : const SizedBox()),
          ],
        ),
      ),
    );
  }

  Widget _buildRadioCard(Package_model pkg) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      child: Obx(() {
        bool isSelected = getController.selectedPackageId.value == pkg.sId;
        return GestureDetector(
          onTap: () => getController.updateSelected(pkg.sId ?? ''),
          child: Container(
            decoration: BoxDecoration(
              color: secondaryColor,
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: isSelected ? primaryColor : Colors.transparent,
                width: 2,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    spacing: 4.w,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(
                          pkg.packageName ?? '',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: white,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      if (pkg.subscriptionPlan != null &&
                          pkg.subscriptionPlan!.isNotEmpty)
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: primaryColor,
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            child: Text(
                              pkg.subscriptionPlan!,
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 10.h),

                  // Price container
                  Container(
                    width: 170.w,
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '₹${pkg.price.toString()}',
                          style: TextStyle(
                            fontSize: 26.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (pkg.subscriptionPlan != null &&
                            pkg.subscriptionPlan!.isNotEmpty)
                          Text(
                            pkg.subscriptionPlan!,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.right,
                          ),
                      ],
                    ),
                  ),

                  SizedBox(height: 10.h),

                  // Services list with icons
                  ListView.separated(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: pkg.servicesIncluded?.length ?? 0,
                    separatorBuilder: (_, __) => SizedBox(height: 5.h),
                    itemBuilder: (context, index) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.check_circle,
                              color: primaryColor, size: 20.sp),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: Text(
                              pkg.servicesIncluded![index],
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
