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
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70.h),
        child: Obx(() {
          return CustomAppBar(
            title: controller.isSearching.value ? '' : 'Coupons',
            actions: [
              if (controller.isSearching.value)
                SizedBox(
                  width: 220.w,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: TextField(
                      controller: searchController,
                      autofocus: true,
                      decoration: InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
                        hintText: 'Search by coupon name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        hintStyle: const TextStyle(color: Colors.grey),
                      ),
                      style: const TextStyle(color: Colors.black, fontSize: 18),
                      onChanged: controller.setSearchQuery,
                      onSubmitted: (value) {
                        controller.setSearchQuery(value);
                        controller.isSearching.value = false;
                      },
                    ),
                  ),
                ),
              IconButton(
                icon: Icon(
                  controller.isSearching.value ? Icons.close : Icons.search,
                  color: Colors.white,
                ),
                onPressed: () {
                  if (controller.isSearching.value) {
                    controller.isSearching.value = false;
                    searchController.clear();
                    controller.clearSearch();
                  } else {
                    controller.isSearching.value = true;
                  }
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
          return const Center(child: Text('No coupons found'));
        }
        return RefreshIndicator(
          color: primaryColor,
          onRefresh: () async => controller.getCoupons(),
          child: ListView.builder(
            itemCount: controller.filteredCoupons.length,
            itemBuilder: (context, index) {
              final coupon = controller.filteredCoupons[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                elevation: 2,
                child: ExpansionTile(
                  leading: (coupon.imageUrl != null &&
                          coupon.imageUrl!.isNotEmpty)
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            '${Apis.pdfUrl}${coupon.imageUrl}?v=${DateTime.now().millisecondsSinceEpoch}',
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.image_not_supported),
                              );
                            },
                          ),
                        )
                      : Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.image_not_supported),
                        ),
                  title: Text(
                    coupon.name ?? '-',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    'Type: ${coupon.couponType ?? '-'} | Discount: ${coupon.discountType ?? '-'} ${coupon.discountAmount ?? 0}',
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Code: ${coupon.couponCode ?? '-'}'),
                          Text('Use Limit: ${coupon.useLimit ?? 0}'),
                          Text(
                              'Status: ${coupon.status == 1 ? 'Active' : 'Deactive'}'),
                          const SizedBox(height: 8),
                          const Text('Branches:',
                              style: TextStyle(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: coupon.branches
                                .map((b) => Chip(label: Text(b.name ?? '-')))
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      }),
    );
  }
}
