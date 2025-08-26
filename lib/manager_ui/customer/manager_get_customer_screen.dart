import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_template/manager_ui/customer/edit/manager_edit_customer.dart';
import 'package:flutter_template/manager_ui/customer/manager_get_customer_controller.dart';
import 'package:flutter_template/manager_ui/drawer/drawerscreen.dart';
import 'package:flutter_template/route/app_route.dart';
import 'package:flutter_template/ui/drawer/drawer_screen.dart';
import 'package:flutter_template/utils/colors.dart';
import 'package:flutter_template/wiget/appbar/commen_appbar.dart';
import 'package:get/get.dart';
import '../../../network/network_const.dart';
import 'edit/manager_edit_customer.dart';

class ManagerGetStaffScreen extends StatelessWidget {
  ManagerGetStaffScreen({super.key});
  final customerController = Get.put(ManagerGetStaffController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Customers"),
      drawer: ManagerDrawerScreen(),
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
                              Routes.ManagerEditCustomer,
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
          Get.toNamed(Routes.ManagerPostCustomerScreen);
        },
        child: Icon(
          Icons.add,
          color: white,
        ),
        backgroundColor: primaryColor,
      ),
    );
  }
}
