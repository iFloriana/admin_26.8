import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_template/ui/splash/splash_controller.dart';
import 'package:flutter_template/utils/colors.dart';
import 'package:flutter_template/network/network_const.dart';
import 'package:get/get.dart';
import 'edit_branch_screen.dart';
import 'getBranchesController.dart';
import 'package:flutter_template/wiget/loading.dart';
import 'package:flutter_template/route/app_route.dart';
import 'package:flutter_template/wiget/appbar/commen_appbar.dart';

class GetBranchesScreen extends StatelessWidget {
 GetBranchesScreen({super.key});
  final Getbranchescontroller getController = Get.put(Getbranchescontroller());
  void _showDeleteConfirmation(BuildContext context, Getbranchescontroller controller, String branchId, String branchName) {
    controller.deleteBranch(branchId);
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: CustomAppBar(title: 'Branches'),
      body: Obx(() {
          if (getController.isLoading.value) {
            return const Center(child: CustomLoadingAvatar());
          }
          if (getController.branches.isEmpty) {
            return Center(
              child: Text(
                "No branches found",
                style: TextStyle(fontSize: 16.sp),
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(16.r),
            itemCount: getController.branches.length,
            itemBuilder: (context, index) {
              final branch = getController.branches[index];
              return Card(
                 color: white,
                margin: EdgeInsets.only(bottom: 16.r),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Branch Image
                    if (branch.imageUrl.isNotEmpty)
                      Container(
                        height: 200.h,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(12.r),
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(12.r),
                          ),
                          child: Image.network(
                            '${Apis.pdfUrl}${branch.imageUrl}?v=${DateTime.now().millisecondsSinceEpoch}',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[300],
                                child: Icon(
                                  Icons.image_not_supported,
                                  size: 50.sp,
                                  color: Colors.grey[600],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    Padding(
                      padding: EdgeInsets.all(16.r),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  branch.name,
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      Icons.edit_outlined,
                                      color: primaryColor,
                                      size: 24.sp,
                                    ),
                                    onPressed: () {
                                      Get.to(() => EditBranchScreen(branch: branch));
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.delete_outline,
                                      color: primaryColor,
                                      size: 24.sp,
                                    ),
                                    onPressed: () => _showDeleteConfirmation(
                                      context,
                                      getController,
                                      branch.id,
                                      branch.name,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Icon(Icons.phone, size: 16.sp, color: Colors.grey),
                              SizedBox(width: 4.w),
                              Text(
                                branch.contactNumber,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Icon(Icons.star, size: 16.sp, color: Colors.amber),
                              SizedBox(width: 4.w),
                              Text(
                                "${branch.ratingStar} (${branch.totalReview} reviews)",
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                            Row(
                            children: [
                              Icon(Icons.location_on, size: 16.sp, color: Colors.grey),
                              SizedBox(width: 4.w),
                              Expanded(
                                child: Text(
                                  "${branch.address}, ${branch.city}",
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: Colors.grey[600],
                                     overflow: TextOverflow.ellipsis, 
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        }),
          floatingActionButton: FloatingActionButton(
        onPressed: () {
            Get.toNamed(Routes.postBranchs);
        },
        child: Icon(Icons.add ,color: white),
        backgroundColor: primaryColor,
      ),
      );
  }
}
