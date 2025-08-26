import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_template/route/app_route.dart';
import 'package:flutter_template/ui/drawer/drawer_screen.dart';
import 'package:flutter_template/utils/colors.dart';
import 'package:flutter_template/wiget/appbar/commen_appbar.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io';
import '../../../network/network_const.dart';
import 'customerController.dart';

class CustomersScreen extends StatelessWidget {
  CustomersScreen({super.key});
  final CustomerController customerController = Get.put(CustomerController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Customers"),
      drawer: DrawerScreen(),
      body: Obx(() => customerController.customerList.isEmpty
          ? Center(
              child: Text(
                "No customers available.",
                style: TextStyle(fontSize: 16.sp),
              ),
            )
          : ListView.builder(
              shrinkWrap: true,
              itemCount: customerController.customerList.length,
              itemBuilder: (context, index) {
                final customer = customerController.customerList[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 4.h, horizontal: 8.w),
                  child: ListTile(
                    leading: customer.image != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              '${Apis.pdfUrl}${customer.image}?v=${DateTime.now().millisecondsSinceEpoch}',
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
                    title: Text(customer.fullName),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Text(customer.email),
                        Text(customer.phoneNumber),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit_outlined, color: primaryColor),
                          onPressed: () {
                            Get.toNamed(
                              Routes.editCustomer,
                              arguments: customer,
                            );
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete_outline, color: primaryColor),
                          onPressed: () {
                            customerController.deleteCustomer(customer.id);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            )),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.toNamed(Routes.addCustomer);
        },
        child: Icon(
          Icons.add,
          color: white,
        ),
        backgroundColor: primaryColor,
      ),
    );
  }

  // Widget _buildCustomerAvatar(Customer customer) {
  //   final imageUrl = customer.fullImageUrl;

  //   if (imageUrl != null && imageUrl.isNotEmpty) {
  //     // Network image
  //     return CircleAvatar(
  //       radius: 25.r,
  //       backgroundImage: CachedNetworkImageProvider(imageUrl),
  //       onBackgroundImageError: (exception, stackTrace) {
  //         // Handle error - fallback to default avatar
  //       },
  //       child: null,
  //     );
  //   } else {
  //     // Default avatar
  //     return CircleAvatar(
  //       radius: 25.r,
  //       backgroundColor: primaryColor,
  //       child: Icon(Icons.person, color: Colors.white),
  //     );
  //   }
  // }
}
