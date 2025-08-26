import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_template/network/network_const.dart';
import 'package:flutter_template/utils/colors.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../route/app_route.dart';
import '../../../wiget/loading.dart';
import 'getOrderListController.dart';
import '../../../wiget/appbar/drawer_appbar.dart';

class Getorderlistscreen extends StatelessWidget {
  Getorderlistscreen({super.key});
  final Getorderlistcontroller controller = Get.put(Getorderlistcontroller());

  final RxBool isSearching = false.obs;
  final TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(70.h),
          child: Obx(() {
            return CustomAppBarWithDrawer(
              title: isSearching.value ? '' : 'Order List',
              actions: [
                if (isSearching.value)
                  SizedBox(
                    width: 220.w,
                    child: Padding(
                      padding: EdgeInsets.only(right: 8.0),
                      child: TextField(
                        controller: searchController,
                        autofocus: true,
                        decoration: InputDecoration(
                          fillColor: Colors.white,
                          filled: true,
                          hintText: 'Search by Client Name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          hintStyle: TextStyle(color: grey),
                        ),
                        style: TextStyle(color: Colors.black, fontSize: 18),
                        onSubmitted: (value) {
                          controller.updateSearchQuery(value);
                          isSearching.value = false;
                        },
                      ),
                    ),
                  ),
                IconButton(
                  icon: Icon(isSearching.value ? Icons.close : Icons.search,
                      color: Colors.white),
                  onPressed: () {
                    if (isSearching.value) {
                      isSearching.value = false;
                      searchController.clear();
                      controller.updateSearchQuery('');
                    } else {
                      isSearching.value = true;
                    }
                  },
                ),
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert,
                    color: Colors.white,
                  ),
                  onSelected: (selected) {
                    controller.updatePaymentMethodFilter(selected);
                  },
                  itemBuilder: (context) => [
                    ...controller.paymentMethods
                        .map((method) => PopupMenuItem<String>(
                              value: method,
                              child: Text(method),
                            )),
                  ],
                ),
              ],
              backgroundColor: primaryColor,
            );
          }),
        ),
        body: RefreshIndicator(
            onRefresh: controller.getOrderReports,
            child: Column(
              children: [
                // Removed search TextField from here
                Expanded(
                  child: Obx(() {
                    if (controller.isLoading.value) {
                      return const Center(child: CustomLoadingAvatar());
                    }
                    if (controller.orderReports.isEmpty) {
                      return const Center(child: Text('No Order Found'));
                    }
                    if (controller.filteredOrderReports.isEmpty) {
                      return const Center(
                          child:
                              Text('No orders found matching the criteria.'));
                    }
                    return RefreshIndicator(
                      onRefresh: controller.getOrderReports,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              DataTable(
                                columns: const [
                                  DataColumn(label: Text('Client')),
                                  DataColumn(label: Text('Phone')),
                                  DataColumn(label: Text('Places On')),
                                  DataColumn(label: Text('Item')),
                                  DataColumn(label: Text('Payment Method')),
                                  DataColumn(label: Text('Total Price')),
                                  DataColumn(label: Text('Action')),
                                ],
                                rows: controller.filteredOrderReports
                                    .map((report) {
                                  return DataRow(cells: [
                                    DataCell(Text(
                                        report.customerId?.fullName ?? '')),
                                    DataCell(Text(
                                        report.customerId?.phoneNumber ?? '')),
                                    DataCell(Text(report.createdAt != null
                                        ? DateFormat('yyyy-MM-dd').format(
                                            DateTime.parse(report.createdAt!))
                                        : '')),
                                    DataCell(Text(
                                        report.productCount?.toString() ??
                                            '0')),
                                    DataCell(Text(report.paymentMethod ?? '')),
                                    DataCell(Text(
                                        report.totalPrice?.toString() ?? '0')),
                                    DataCell(Row(
                                      children: [
                                        IconButton(
                                          icon: Icon(
                                            Icons.insert_drive_file_outlined,
                                            color: primaryColor,
                                          ),
                                          onPressed: () {
                                            String pdfUrl =
                                                '${Apis.pdfUrl}${report.invoice_pdf_url}';
                                            controller.openPdf(pdfUrl);
                                          },
                                        ),
                                        IconButton(
                                          icon: Icon(
                                              Icons.delete_outline_outlined,
                                              color: primaryColor),
                                          onPressed: () {
                                            if (report.order_code != null) {
                                              controller
                                                  .deleteOrder(report.id!);
                                            } else {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                    content: Text(
                                                        'Order code not found.')),
                                              );
                                            }
                                          },
                                        ),
                                      ],
                                    ))
                                  ]);
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            )),
        floatingActionButton: FloatingActionButton(
          backgroundColor: primaryColor,
          onPressed: () async {
            final result = await Get.toNamed(Routes.placeOrder);
            if (result == true) {
              controller.getOrderReports();
            }
          },
          child: Icon(
            Icons.add,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
