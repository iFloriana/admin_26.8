import 'package:flutter/material.dart';
import 'package:flutter_template/wiget/loading.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../network/model/packages_model.dart';
import '../../../utils/colors.dart';
import '../../../utils/custom_text_styles.dart';
import '../../../wiget/Custome_button.dart';
import '../../../wiget/appbar/commen_appbar.dart';
import '../../../wiget/custome_text.dart';
import 'register_packages_controller.dart';

class PackagesScreen extends StatelessWidget {
  PackagesScreen({super.key});

  final PackagesController getController = Get.put(PackagesController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Preferable Package",
        // actions: [
        //   PopupMenuButton<String>(
        //     onSelected: (String value) {
        //       getController.selectedFilter.value = value;
        //       getController.filterPackages();
        //     },
        //     itemBuilder: (BuildContext context) {
        //       return {'All', 'Monthly', 'Quarterly', 'Half-Yearly', 'Yearly'}
        //           .map((String choice) {
        //         return PopupMenuItem<String>(
        //           value: choice,
        //           child: Text(choice),
        //         );
        //       }).toList();
        //     },
        //   ),
        // ],
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
                if (getController.filteredPackages.isEmpty) {
                  return Center(
                    child: CustomLoadingAvatar(),
                  );
                }
                return ListView.builder(
                  itemCount: getController.filteredPackages.length,
                  itemBuilder: (context, index) {
                    return _buildRadioCard(
                        getController.filteredPackages[index]);
                  },
                );
              }),
            ),
            Obx(() => getController.selectedPackageId.value != null
                ? Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ElevatedButtonExample(
                      onPressed: () => getController.checkGmailId(
                          getController.registerData['owner_email']),
                      text: "Process to Payment",
                    ),
                  )
                : SizedBox()),
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
                        child: CustomTextWidget(
                          text: pkg.packageName ?? '',
                          textStyle: CustomTextStyles.textFontBold(
                            size: 16.sp,
                            textOverflow: TextOverflow.ellipsis,
                            color: white,
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
                          child: CustomTextWidget(
                            text: pkg.subscriptionPlan!,
                            textStyle: CustomTextStyles.textFontRegular(
                              size: 12.sp,
                              color: white,
                            ),
                          ),
                        )),
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
                        CustomTextWidget(
                          text: '₹${pkg.price.toString()}',
                          textStyle: CustomTextStyles.textFontBold(
                              size: 26.sp,
                              color: white,
                              textOverflow: TextOverflow.ellipsis),
                        ),
                        if (pkg.subscriptionPlan != null &&
                            pkg.subscriptionPlan!.isNotEmpty)
                          CustomTextWidget(
                            text: pkg.subscriptionPlan!,
                            textStyle: CustomTextStyles.textFontRegular(
                              size: 12.sp,
                              color: white,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        // SizedBox(width: 1),
                      ],
                    ),
                  ),

                  SizedBox(height: 10.h),

                  // Services list with icons
                  ListView.separated(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
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
                            child: CustomTextWidget(
                              text: pkg.servicesIncluded![index],
                              textStyle: CustomTextStyles.textFontRegular(
                                size: 14.sp,
                                color: white,
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
