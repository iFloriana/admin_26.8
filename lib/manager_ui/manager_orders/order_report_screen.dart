import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_template/manager_ui/manager_orders/order_report_controller.dart';
import 'package:flutter_template/ui/drawer/reports/orderReport/order_report_controller.dart';
import 'package:flutter_template/utils/app_images.dart';
import 'package:flutter_template/utils/colors.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../network/network_const.dart';
import '../../../../wiget/appbar/commen_appbar.dart';
import '../../../../wiget/loading.dart';
import '../drawer/drawerscreen.dart';

class ManagerOrderReportScreen extends StatelessWidget {
  const ManagerOrderReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ManagerOrderReportController());
    final RxBool isSearching = false.obs;
    final TextEditingController searchController = TextEditingController();

    return SafeArea(
      child: Scaffold(
        // floatingActionButton: FloatingActionButton.extended(
        //   onPressed: () {
        //     _showExportDialog(context, controller);
        //   },
        //   icon: const Icon(
        //     Icons.file_download,
        //     color: Colors.white,
        //   ),
        //   label: const Text('Export', style: TextStyle(color: Colors.white)),
        //   backgroundColor: primaryColor,
        // ),
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(70.h),
          child: Obx(() {
            return CustomAppBar(
              title: isSearching.value ? '' : 'Order Report',
              backgroundColor: primaryColor,
              actions: [
                if (isSearching.value)
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
                          hintText: 'Search by Client or Staff Name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          hintStyle: const TextStyle(color: Colors.grey),
                        ),
                        style:
                            const TextStyle(color: Colors.black, fontSize: 18),
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
                  onSelected: (value) async {
                    if (value == 'date') {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (picked != null) {
                        controller.selectDate(picked);
                      }
                    } else if (value == 'range') {
                      final DateTimeRange? picked = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (picked != null) {
                        controller.selectDateRange(picked);
                      }
                    } else if (value == 'payment_method') {
                      _showPaymentMethodDialog(context, controller);
                    } else if (value == 'sort_asc') {
                      controller.setSortOrder('asc');
                    } else if (value == 'sort_desc') {
                      controller.setSortOrder('desc');
                    } else if (value == 'clear') {
                      controller.clearFilters();
                    }
                    else if (value == 'export') {
                      _showExportDialog(context, controller);
                    }
                  },
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<String>>[
                    const PopupMenuItem<String>(
                      value: 'date',
                      child: Text('Filter by Date'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'range',
                      child: Text('Filter by Date Range'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'payment_method',
                      child: Text('Filter by Payment Method'),
                    ),
                    const PopupMenuDivider(),
                    const PopupMenuItem<String>(
                      value: 'sort_asc',
                      child: Row(
                        children: [
                          Icon(
                            Icons.arrow_upward,
                            size: 16,
                            color: grey,
                          ),
                          SizedBox(width: 8),
                          Text('Sort Oldest First'),
                        ],
                      ),
                    ),
                    const PopupMenuItem<String>(
                      value: 'sort_desc',
                      child: Row(
                        children: [
                          Icon(
                            Icons.arrow_downward,
                            size: 16,
                            color: grey,
                          ),
                          SizedBox(width: 8),
                          Text('Sort Newest First'),
                        ],
                      ),
                    ),
                    const PopupMenuDivider(),
                    const PopupMenuItem<String>(
                      value: 'export',
                      child: Row(
                        children: [
                          Icon(
                            Icons.file_download,
                            size: 16,
                            color: grey,
                          ),
                          SizedBox(width: 8),
                          Text('Export Data'),
                        ],
                      ),
                    ),
                    const PopupMenuDivider(),
                    const PopupMenuItem<String>(
                      value: 'clear',
                      child: Text('Clear Filters'),
                    ),
                  ],
                ),
              ],
            );
          }),
        ),
          drawer: ManagerDrawerScreen(),
        body: Column(
          children: [
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CustomLoadingAvatar());
                }
                if (controller.orderReports.isEmpty) {
                  return const Center(child: Text('No data available'));
                }
                if (controller.filteredOrderReports.isEmpty) {
                  return const Center(
                      child: Text('No orders found with the current filters.'));
                }
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Order Code')),
                        DataColumn(label: Text('Client')),
                        DataColumn(label: Text('Phone')),
                        DataColumn(label: Text('Staff')),
                        DataColumn(label: Text('Order Date')),
                        DataColumn(label: Text('Items')),
                        DataColumn(label: Text('Payment Method')),
                        DataColumn(label: Text('Total Payment')),
                        DataColumn(label: Text('Actions')),
                      ],
                      rows: controller.filteredOrderReports.map((order) {
                        return DataRow(cells: [
                          DataCell(Text(order.order_code ?? '')),
                          DataCell(Text(order.customerId?.fullName ?? 'N/A')),
                          DataCell(Text(order.customerId?.phoneNumber ?? 'N/A')),
                          DataCell(Text(order.staffId?.fullName ?? 'N/A')),
                          DataCell(Text(order.createdAt != null
                              ? DateFormat('yyyy-MM-dd')
                                  .format(DateTime.parse(order.createdAt!))
                              : '')),
                          DataCell(Text(order.productCount?.toString() ?? '0')),
                          DataCell(Text(order.paymentMethod ?? '')),
                          DataCell(
                              Text('₹${order.totalPrice?.toString() ?? '0'}')),
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (order.invoice_pdf_url != null)
                                  GestureDetector(
                                    child: Icon(
                                      Icons.insert_drive_file_outlined,
                                      color: primaryColor,
                                    ),
                                    onTap: () {
                                      String pdfUrl =
                                          '${Apis.pdfUrl}${order.invoice_pdf_url}';
                                      controller.openPdf(pdfUrl);
                                    },
                                  ),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  child: Icon(
                                    Icons.delete_outline,
                                    color: primaryColor,
                                  ),
                                  onTap: () {
                                    controller.deleteOrder(order.id!);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ]);
                      }).toList(),
                    ),
                  ),
                );
              }),
            ),
            Obx(
              () => Container(
                margin: EdgeInsets.only(left: 15.h, right: 15.h, bottom: 15.h),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: secondaryColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(
                      color: primaryColor,
                      width: 1.0,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Grand Total: ',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16.sp)),
                        Text(
                            '₹${controller.grandTotal.value.toStringAsFixed(2)}',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16.sp)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPaymentMethodDialog(
      BuildContext context, ManagerOrderReportController controller) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Payment Method'),
          content: SizedBox(
            width: double.maxFinite,
            child: Obx(() => ListView(
                  shrinkWrap: true,
                  children: [
                    ListTile(
                      title: const Text('All Payment Methods'),
                      leading: Radio<String>(
                        value: '',
                        groupValue: controller.selectedPaymentMethod.value,
                        onChanged: (value) {
                          controller.selectedPaymentMethod.value = value!;
                          controller.applyFilters();
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                    ...controller.uniquePaymentMethods.map((method) => ListTile(
                          title: Text(method),
                          leading: Radio<String>(
                            value: method,
                            fillColor: MaterialStateProperty.all(primaryColor),
                            groupValue: controller.selectedPaymentMethod.value,
                            onChanged: (value) {
                              controller.selectedPaymentMethod.value = value!;
                              controller.applyFilters();
                              Navigator.of(context).pop();
                            },
                          ),
                        )),
                  ],
                )),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _showExportDialog(
      BuildContext context, ManagerOrderReportController controller) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0)), // Rounded corners
          title: const Text(
            'Export Data',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: primaryColor, // Using primaryColor for consistency
            ),
          ),
          contentPadding: const EdgeInsets.fromLTRB(
              24.0, 20.0, 24.0, 0.0), // Adjust padding
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Choose your preferred export format:',
                style: TextStyle(fontSize: 16, color: Colors.black87),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildExportOption(
                    context,
                    icon: Icons.table_chart,
                    label: 'Excel',
                    color: Colors.green,
                    onTap: () {
                      Navigator.of(context).pop();
                      controller.exportToExcel();
                    },
                  ),
                  _buildExportOption(
                    context,
                    icon: Icons.picture_as_pdf,
                    label: 'PDF',
                    color: Colors.red,
                    onTap: () {
                      Navigator.of(context).pop();
                      controller.exportToPdf();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
          actionsPadding: const EdgeInsets.all(16.0),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildExportOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(height: 10),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
