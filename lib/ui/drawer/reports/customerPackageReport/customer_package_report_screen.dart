import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_template/ui/drawer/drawer_screen.dart';
import 'package:flutter_template/ui/drawer/reports/customerPackageReport/customer_package_report_controller.dart';
import 'package:flutter_template/utils/colors.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../wiget/appbar/commen_appbar.dart';
import '../../../../wiget/loading.dart';
import '../../../../network/network_const.dart';

class CustomerPackageReportScreen extends StatelessWidget {
 CustomerPackageReportScreen({super.key});
  final CustomerPackageReportController controller =
      Get.put(CustomerPackageReportController());
  @override
  Widget build(BuildContext context) {
   
    final RxBool isSearching = false.obs;
    final TextEditingController searchController = TextEditingController();

    return SafeArea(
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(70.h),
          child: Obx(() {
            return CustomAppBar(
              title: isSearching.value ? '' : _getAppBarTitle(controller),
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
                          hintText: 'Search by Customer Name',
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
                    } else if (value == 'sort_asc') {
                      controller.setSortOrder('asc');
                    } else if (value == 'sort_desc') {
                      controller.setSortOrder('desc');
                    } else if (value == 'export') {
                      _showExportDialog(context, controller);
                    } else if (value == 'clear') {
                      controller.clearFilters();
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
                    const PopupMenuDivider(),
                    const PopupMenuItem<String>(
                      value: 'sort_asc',
                      child: Row(
                        children: [
                          Icon(Icons.arrow_upward,
                              color: Colors.grey, size: 16),
                          SizedBox(width: 8),
                          Text('Sort by Oldest Date'),
                        ],
                      ),
                    ),
                    const PopupMenuItem<String>(
                      value: 'sort_desc',
                      child: Row(children: [
                        Icon(Icons.arrow_downward,
                            size: 16, color: Colors.grey),
                        SizedBox(width: 8),
                        Text('Sort by Newest Date'),
                      ]),
                    ),
                    const PopupMenuDivider(),
                    const PopupMenuItem<String>(
                      value: 'export',
                      child: Row(
                        children: [
                          Icon(Icons.file_download,
                              color: Colors.grey, size: 16),
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
        drawer: DrawerScreen(),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CustomLoadingAvatar());
          }
          if (controller.customerPackages.isEmpty) {
            return const Center(child: Text('No customers with packages.'));
          }
          if (controller.filteredCustomerPackages.isEmpty) {
            return const Center(
                child: Text('No customers found with the current filters.'));
          }
          return SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Customer')),
                  DataColumn(label: Text('Email')),
                  DataColumn(label: Text('Package Name')),
                  DataColumn(label: Text('Package Price')),
                  DataColumn(label: Text('Bought At')),
                  DataColumn(label: Text('Valid Till')),
                  DataColumn(label: Text('Status')),
                ],
                rows: controller.filteredCustomerPackages.expand((customer) {
                  return customer.branchPackage!.map((pkg) {
                    return DataRow(cells: [
                      DataCell(
                        Row(
                          children: [
                            // Customer image or fallback icon
                            customer.image != null && customer.image!.isNotEmpty
                                ? CircleAvatar(
                                    backgroundImage: NetworkImage(
                                        '${Apis.pdfUrl}/${customer.image!}'),
                                    radius: 20,
                                  )
                                : const CircleAvatar(
                                    backgroundColor: secondaryColor,
                                    child: Icon(
                                      Icons.person,
                                      color: black,
                                    ),
                                    radius: 20,
                                  ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                customer.fullName ?? '',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      DataCell(Text(customer.email ?? '')),
                      DataCell(Text(pkg.packageName ?? '')),
                      DataCell(Text(pkg.packagePrice?.toString() ?? '')),
                      DataCell(Text(controller.getFormattedBoughtDate(
                          customer.branchPackageBoughtAt))),
                      DataCell(Text(controller
                          .getFormattedDate(customer.branchPackageValidTill))),
                      DataCell(Text(controller.getStatusText(pkg.status))),
                    ]);
                  });
                }).toList(),
              ),
            ),
          );
        }),
      ),
    );
  }

  void _showExportDialog(
      BuildContext context, CustomerPackageReportController controller) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
          title: const Text(
            'Export Data',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: primaryColor,
            ),
          ),
          contentPadding: const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 0.0),
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

  String _getAppBarTitle(CustomerPackageReportController controller) {
    String title = 'Customer Package Report';

    if (controller.selectedDate.value != null) {
      title += ' (Filtered by Date)';
    } else if (controller.selectedDateRange.value != null) {
      title += ' (Filtered by Date Range)';
    } else if (controller.searchQuery.value.isNotEmpty) {
      title += ' (Search Results)';
    }

    // Add sort indicator
    if (controller.sortOrder.value == 'asc') {
      title += ' [Oldest First]';
    } else if (controller.sortOrder.value == 'desc') {
      title += ' [Newest First]';
    }

    return title;
  }
}
