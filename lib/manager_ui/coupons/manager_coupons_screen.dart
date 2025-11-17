import 'package:flutter/material.dart';
import 'package:flutter_template/manager_ui/drawer/drawerscreen.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_template/manager_ui/coupons/manager_coupons_controller.dart';
import 'package:flutter_template/utils/colors.dart';
import 'package:flutter_template/wiget/appbar/commen_appbar.dart';
import 'package:flutter_template/wiget/loading.dart';
import 'package:flutter_template/network/network_const.dart';

class ManagerCouponsScreen extends StatelessWidget {
  ManagerCouponsScreen({super.key});

  final ManagerCouponsController controller =
      Get.put(ManagerCouponsController());
  final TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70.h),
        child: Obx(() {
          return CustomAppBar(
            title: 'Coupons',
            backgroundColor: primaryColor,

            actions: [
              if (controller.isSearching.value)
                Container(
                  width: 250.w,
                  margin: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4.r,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: searchController,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'Search coupons...',
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      border: InputBorder.none,
                      hintStyle:
                          TextStyle(color: Colors.grey[600], fontSize: 16.sp),
                      contentPadding: EdgeInsets.symmetric(vertical: 10.h),
                    ),
                    style: TextStyle(color: Colors.black, fontSize: 16.sp),
                    onChanged: controller.setSearchQuery,
                    onSubmitted: (value) {
                      controller.setSearchQuery(value);
                      controller.isSearching.value = false;
                    },
                  ),
                )
              else
                IconButton(
                  icon: const Icon(Icons.search, color: Colors.white),
                  onPressed: () => controller.isSearching.value = true,
                ),
              if (controller.isSearching.value)
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () {
                    controller.isSearching.value = false;
                    searchController.clear();
                    controller.clearSearch();
                  },
                ),
            ],
          );
        }),
      ),
      drawer: ManagerDrawerScreen(),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CustomLoadingAvatar());
        }
        if (controller.filteredCoupons.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.discount_outlined,
                    size: 60.sp, color: Colors.grey[400]),
                SizedBox(height: 16.h),
                Text(
                  'No coupons found',
                  style: TextStyle(
                    fontSize: 18.sp,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }
        return RefreshIndicator(
          color: primaryColor,
          backgroundColor: Colors.white,
          onRefresh: () async => controller.getCoupons(),
          child: ListView.builder(
            padding: EdgeInsets.symmetric(vertical: 8.h),
            itemCount: controller.filteredCoupons.length,
            itemBuilder: (context, index) {
              final coupon = controller.filteredCoupons[index];
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                child: Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.r),
                      gradient: LinearGradient(
                        colors: [Colors.white, Colors.grey[50]!],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        dividerColor: Colors.transparent,
                      ),
                      child: ExpansionTile(
                        tilePadding: EdgeInsets.symmetric(
                            horizontal: 16.w, vertical: 8.h),
                        iconColor: Colors.grey[800],
                        collapsedIconColor: Colors.grey[600],
                        shape: const Border(), // No border when expanded
                        collapsedShape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                          side: BorderSide(color: Colors.grey[300]!, width: 1),
                        ),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8.r),
                          child: (coupon.imageUrl != null &&
                                  coupon.imageUrl!.isNotEmpty)
                              ? Image.network(
                                  '${Apis.pdfUrl}${coupon.imageUrl}?v=${DateTime.now().millisecondsSinceEpoch}',
                                  width: 50.w,
                                  height: 50.h,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return _buildPlaceholderImage();
                                  },
                                )
                              : _buildPlaceholderImage(),
                        ),
                        title: Text(
                          coupon.name ?? '-',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16.sp,
                            color: Colors.black87,
                          ),
                        ),
                        subtitle: Padding(
                          padding: EdgeInsets.only(top: 4.h),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                coupon.discountType ?? '',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.grey[700],
                                ),
                              ),
                              Text(
                                'Discount: ${coupon.discountAmount ?? 0}',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: primaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        children: [
                          Padding(
                            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildDetailRow(
                                    'Code', coupon.couponCode ?? '-'),
                                _buildDetailRow(
                                    'Use Limit', '${coupon.useLimit ?? 0}'),
                                _buildDetailRow(
                                  'Status',
                                  coupon.status == 1 ? 'Active' : 'Deactive',
                                  valueColor: coupon.status == 1
                                      ? Colors.green
                                      : Colors.red,
                                ),
                                SizedBox(height: 8.h),
                                Text(
                                  'Branches:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14.sp,
                                    color: Colors.black87,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                ...coupon.branches.map((b) => Padding(
                                      padding:
                                          EdgeInsets.only(left: 8.w, top: 2.h),
                                      child: Text(
                                        '- ${b.name ?? '-'}',
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          color: Colors.grey[800],
                                        ),
                                      ),
                                    )),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: 50.w,
      height: 50.h,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Icon(
        Icons.image_not_supported,
        color: Colors.grey[500],
        size: 24.sp,
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4.h),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              color: valueColor ?? Colors.grey[800],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
