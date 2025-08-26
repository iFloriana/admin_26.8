import 'package:flutter/material.dart';
import 'package:flutter_template/route/app_route.dart';
import 'package:flutter_template/ui/drawer/coupons/couponsController.dart';
import 'package:flutter_template/utils/colors.dart';
import 'package:get/get.dart';

import '../../../network/network_const.dart';
import '../../../wiget/appbar/commen_appbar.dart';
import '../drawer_screen.dart';

class CouponsScreen extends StatelessWidget {
  CouponsScreen({super.key});
  final CouponsController getController = Get.put(CouponsController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomAppBar(
          title: 'Coupons',
        ),
        drawer: DrawerScreen(),
        body: RefreshIndicator(
            color: primaryColor,
            child: Obx(() {
              if (getController.couponList.isEmpty) {
                return const Center(child: Text("No coupons available"));
              }
              return ListView.builder(
                itemCount: getController.couponList.length,
                itemBuilder: (context, index) {
                  final coupon = getController.couponList[index];
                  return Card(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: ListTile(
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
                                    child:
                                        const Icon(Icons.image_not_supported),
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
                      title: Text(coupon.name ?? '-',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Type: ${coupon.couponType ?? '-'}"),
                          Text("Discount Type: ${coupon.discountType ?? '-'}"),
                          Text("Use Limit: ${coupon.useLimit ?? 0}"),
                          Text(
                            "Status: ${coupon.status == 1 ? 'Active' : 'Deactive'}",
                            style: TextStyle(
                              color: coupon.status == 1
                                  ? Colors.green
                                  : Colors.red,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined,
                                color: primaryColor),
                            onPressed: () {
                              Get.toNamed(Routes.addCoupon, arguments: coupon);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline,
                                color: primaryColor),
                            onPressed: () async {
                              await getController.deleteCoupon(coupon.sId);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
            onRefresh: () async {
              await getController.getCoupons();
            }),
        floatingActionButton: FloatingActionButton(
          backgroundColor: primaryColor,
          onPressed: () {
            Get.toNamed(Routes.addCoupon);
          },
          child: Icon(
            Icons.add,
            color: white,
          ),
        ));
  }
}
