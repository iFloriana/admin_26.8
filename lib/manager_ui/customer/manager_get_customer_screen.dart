import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_template/manager_ui/customer/ManagerCustomerProfileScreen.dart';
import 'package:flutter_template/manager_ui/customer/add/manager_post_customer_screen.dart';
import 'package:flutter_template/manager_ui/customer/edit/manager_edit_customer.dart';
import 'package:flutter_template/manager_ui/customer/manager_get_customer_controller.dart';
import 'package:flutter_template/manager_ui/drawer/drawerscreen.dart';
import 'package:flutter_template/route/app_route.dart';
import 'package:flutter_template/ui/drawer/customers/customerProfile.dart';
import 'package:flutter_template/ui/drawer/drawer_screen.dart';
import 'package:flutter_template/utils/colors.dart';
import 'package:flutter_template/wiget/appbar/commen_appbar.dart';
import 'package:flutter_template/wiget/loading.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../../network/network_const.dart';

class ManagerGetStaffScreen extends StatelessWidget {
  ManagerGetStaffScreen({super.key});
  final customerController = Get.put(ManagerGetStaffController());
  final TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: customerController.isSearching.value ? '' : 'Customers',
        actions: [
          Obx(() {
            if (customerController.isSearching.value) {
              return SizedBox(
                width: 220.w,
                child: Padding(
                  padding: EdgeInsets.only(right: 8.w),
                  child: TextField(
                    controller: searchController,
                    autofocus: true,
                    decoration: InputDecoration(
                      fillColor: Colors.white,
                      filled: true,
                      hintText: 'Search by name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.r),
                        borderSide: BorderSide.none,
                      ),
                      hintStyle: TextStyle(color: Colors.grey, fontSize: 16.sp),
                      suffixIcon: IconButton(
                        icon:
                            Icon(Icons.clear, color: Colors.grey, size: 20.sp),
                        onPressed: () {
                          searchController.clear();
                          customerController.clearSearch();
                        },
                      ),
                    ),
                    style: TextStyle(color: Colors.black, fontSize: 16.sp),
                    onChanged: customerController.searchCustomers,
                    onSubmitted: (value) {
                      customerController.searchCustomers(value);
                      customerController.isSearching.value = false;
                      searchController.clear();
                    },
                  ),
                ),
              );
            }
            return IconButton(
              icon: Icon(
                customerController.isSearching.value
                    ? Icons.close
                    : Icons.search,
                color: Colors.white,
                size: 24.sp,
              ),
              onPressed: () {
                if (customerController.isSearching.value) {
                  searchController.clear();
                  customerController.clearSearch();
                } else {
                  customerController.isSearching.value = true;
                }
              },
            );
          }),
        ],
      ),
      drawer: ManagerDrawerScreen(),
      body: Obx(() => customerController.isLoading.value
          ? const Center(child: CustomLoadingAvatar())
          : customerController.filteredCustomerList.isEmpty
              ? Center(
                  child: Text(
                    customerController.isSearching.value
                        ? "No customers found."
                        : "No customers available.",
                    style: TextStyle(fontSize: 16.sp),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: customerController.filteredCustomerList.length,
                  itemBuilder: (context, index) {
                    final customer =
                        customerController.filteredCustomerList[index];
                    return Slidable(
                      key: ValueKey(customer.id),
                      startActionPane: ActionPane(
                        motion: const DrawerMotion(),
                        extentRatio: 0.25,
                        children: [
                          SlidableAction(
                            onPressed: (context) {
                              Get.to(
                                () => ManagerEditCustomer(),
                                arguments: customer,
                              );
                            },
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(20),
                              bottomLeft: Radius.circular(20),
                            ),
                            icon: Icons.edit,
                            label: 'Edit',
                          ),
                        ],
                      ),
                      endActionPane: ActionPane(
                        motion: const DrawerMotion(),
                        extentRatio: 0.25,
                        children: [
                          SlidableAction(
                            onPressed: (context) {
                              _confirmDelete(
                                  context, customer.id, customerController);
                            },
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(20),
                              bottomRight: Radius.circular(20),
                            ),
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            icon: Icons.delete,
                            label: 'Delete',
                          ),
                        ],
                      ),
                      child: Card(
                        margin: EdgeInsets.symmetric(
                            vertical: 4.h, horizontal: 8.w),
                        child: ListTile(
                          onTap: () {
                            Get.to(ManagerCustomerProfileScreen(
                                customer: customer));
                          },
                          leading: customer.image != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8.r),
                                  child: CachedNetworkImage(
                                    imageUrl:
                                        '${Apis.pdfUrl}${customer.image}?v=${DateTime.now().millisecondsSinceEpoch}',
                                    width: 50.w,
                                    height: 50.h,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) =>
                                        const CustomLoadingAvatar(),
                                    errorWidget: (context, url, error) =>
                                        Container(
                                      width: 50.w,
                                      height: 50.h,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        borderRadius:
                                            BorderRadius.circular(8.r),
                                      ),
                                      child:
                                          const Icon(Icons.image_not_supported),
                                    ),
                                  ),
                                )
                              : Container(
                                  width: 50.w,
                                  height: 50.h,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  child: const Icon(Icons.image_not_supported),
                                ),
                          title: Text(
                            customer.fullName,
                            style: TextStyle(fontSize: 16.sp),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                customer.phoneNumber,
                                style: TextStyle(fontSize: 14.sp),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                )),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(ManagerPostCustomerScreen());
        },
        child: Icon(
          Icons.add,
          color: Colors.white,
          size: 24.sp,
        ),
        backgroundColor: primaryColor,
      ),
    );
  }

  void _confirmDelete(BuildContext context, String customerId,
      ManagerGetStaffController controller) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.warning_amber_rounded,
                  size: 48, color: primaryColor),
              const SizedBox(height: 12),
              const Text(
                "Delete Customer?",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                "Are you sure you want to delete this customer? This action cannot be undone.",
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: const Text(
                        "Cancel",
                        style: TextStyle(color: grey),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        controller.deleteCustomer(customerId);
                      },
                      child: const Text(
                        "Delete",
                        style: TextStyle(color: white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
