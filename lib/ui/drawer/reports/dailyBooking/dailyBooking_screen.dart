import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_template/ui/drawer/drawer_screen.dart';
import 'package:get/get.dart';
import '../../../../utils/colors.dart';
import '../../../../wiget/appbar/commen_appbar.dart'; // Import CustomAppBar
import '../../../../wiget/loading.dart'; // Import CustomLoadingAvatar
import '../../../../ui/drawer/reports/dailyBooking/dailyBookingController.dart'; //

class DailybookingScreen extends StatelessWidget {
  const DailybookingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Dailybookingcontroller controller =
        Get.put(Dailybookingcontroller()); //
    final RxBool isSearching = false.obs;
    // final TextEditingController searchController = TextEditingController();

    return SafeArea(
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(70.h),
          child: Obx(() {
            return CustomAppBar(
              title: isSearching.value ? '' : 'Daily Booking Report',
              backgroundColor: primaryColor,
              actions: [
                // if (isSearching.value)
                //   SizedBox(
                //     width: 220.w,
                //     child: Padding(
                //       padding: const EdgeInsets.only(right: 8.0),
                //       child: TextField(
                //         controller: searchController,
                //         autofocus: true,
                //         decoration: InputDecoration(
                //           fillColor: Colors.white,
                //           filled: true,
                //           hintText: 'Search by Date',
                //           border: OutlineInputBorder(
                //             borderRadius: BorderRadius.circular(10),
                //             borderSide: BorderSide.none,
                //           ),
                //           hintStyle: const TextStyle(color: Colors.grey),
                //         ),
                //         style:
                //             const TextStyle(color: Colors.black, fontSize: 18),
                //         onSubmitted: (value) {
                //           controller.updateSearchQuery(value);
                //           isSearching.value = false;
                //         },
                //       ),
                //     ),
                //   ),
                // IconButton(
                //   icon: Icon(isSearching.value ? Icons.close : Icons.search,
                //       color: Colors.white),
                //   onPressed: () {
                //     if (isSearching.value) {
                //       isSearching.value = false;
                //       searchController.clear();
                //       controller.updateSearchQuery('');
                //     } else {
                //       isSearching.value = true;
                //     }
                //   },
                // ),
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
                    } else if (value == 'clear') {
                      controller.clearFilters();
                    } else if (value == 'export') {
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
        drawer: DrawerScreen(),
        body: Column(
          children: [
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  //
                  return const Center(child: CustomLoadingAvatar());
                }
                if (controller.dailyReports.isEmpty) {
                  //
                  return const Center(child: Text('No data available')); //
                }
                if (controller.filteredDailyReports.isEmpty) {
                  return const Center(
                      child: Text(
                          'No daily bookings found with the current filters.'));
                }
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Date')),
                        DataColumn(label: Text('Appointments')),
                        DataColumn(label: Text('Services')),
                        DataColumn(label: Text('Used Packages')),
                        DataColumn(label: Text('Service Amount')),
                        DataColumn(label: Text('Product Amount')),
                        DataColumn(label: Text('Tax')),
                        DataColumn(label: Text('Tips')),
                        DataColumn(label: Text('Discount')),
                        DataColumn(label: Text('Membership Discount')),
                        DataColumn(label: Text('Additional Charges')),
                        DataColumn(label: Text('Cash')),
                        DataColumn(label: Text('Card')),
                        DataColumn(label: Text('UPI')),
                        DataColumn(label: Text('Final Amount')),
                      ],
                      rows: controller.filteredDailyReports.map((report) {
                        return DataRow(cells: [
                          DataCell(Text(report.date ?? '')),
                          DataCell(Text(
                              report.appointmentsCount?.toString() ?? '0')),
                          DataCell(
                              Text(report.servicesCount?.toString() ?? '0')),
                          DataCell(
                              Text(report.usedPackageCount?.toString() ?? '0')),
                          DataCell(
                              Text(report.serviceAmount?.toString() ?? '0')),
                          DataCell(
                              Text(report.productAmount?.toString() ?? '0')),
                          DataCell(Text(report.taxAmount?.toString() ?? '0')),
                          DataCell(Text(report.tipsEarning?.toString() ?? '0')),
                          DataCell(Text(
                              report.additionalDiscount?.toString() ?? '0')),
                          DataCell(Text(
                              report.membershipDiscount?.toString() ?? '0')),
                          DataCell(Text(
                              report.additionalCharges?.toString() ?? '0')),
                          DataCell(Text(
                              report.paymentBreakdown?.cash?.toString() ??
                                  '0')),
                          DataCell(Text(
                              report.paymentBreakdown?.card?.toString() ??
                                  '0')),
                          DataCell(Text(
                              report.paymentBreakdown?.upi?.toString() ?? '0')),
                          DataCell(Text(report.finalAmount?.toString() ?? '0')),
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

  void _showExportDialog(
      BuildContext context, Dailybookingcontroller controller) {
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
}
