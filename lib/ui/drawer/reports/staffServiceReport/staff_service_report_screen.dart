import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_template/network/network_const.dart';
import 'package:flutter_template/ui/drawer/reports/staffServiceReport/staff_service_report_controller.dart';
import 'package:flutter_template/wiget/appbar/commen_appbar.dart';
import 'package:flutter_template/utils/colors.dart';
import 'package:flutter_template/wiget/loading.dart';
import 'package:get/get.dart';

import '../../drawer_screen.dart';

class StaffServiceReportScreen extends StatelessWidget {
  const StaffServiceReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final StaffServiceReportController controller =
        Get.put(StaffServiceReportController());
    final RxBool isSearching = false.obs;
    final TextEditingController searchController = TextEditingController();

    return SafeArea(
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(70.h),
          child: Obx(() {
            return CustomAppBar(
              title: isSearching.value ? '' : 'Staff Service Report',
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
                          hintText: 'Search by Staff Name',
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
                    if (value == 'sort_newest') {
                      controller.sortReports('desc');
                    } else if (value == 'sort_oldest') {
                      controller.sortReports('asc');
                    } else if (value == 'export') {
                      _showExportDialog(context, controller);
                    } else if (value == 'clear') {
                      controller.clearFilters();
                    }
                  },
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<String>>[
                    const PopupMenuItem<String>(
                      value: 'sort_newest',
                      child: Row(
                        children: [
                          Icon(Icons.arrow_upward,
                              color: Colors.grey, size: 16),
                          SizedBox(width: 8),
                          Text('Sort Newest First'),
                        ],
                      ),
                    ),
                    const PopupMenuItem<String>(
                      value: 'sort_oldest',
                      child: Row(children: [
                        Icon(Icons.arrow_downward,
                            size: 16, color: Colors.grey),
                        SizedBox(width: 8),
                        Text('Sort Oldest First'),
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
          if (controller.staffServiceReports.isEmpty) {
            return const Center(child: Text('No data available'));
          }
          if (controller.filteredStaffServiceReports.isEmpty) {
            return const Center(
                child: Text('No reports found with the current filters.'));
          }
          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Staff Name')),
                        DataColumn(label: Text('Service Count')),
                        DataColumn(label: Text('Commission')),
                        DataColumn(label: Text('Tips')),
                        DataColumn(label: Text('Total Earning')),
                      ],
                      rows:
                          controller.filteredStaffServiceReports.map((report) {
                        return DataRow(cells: [
                          DataCell(
                            Text(report.staffName ?? 'N/A'),
                            // Row(
                            //   children: [
                            //     // Conditional display of staff image or fallback icon
                            //     report.staffImage != null &&
                            //             report.staffImage!.isNotEmpty
                            //         ? CircleAvatar(
                            //             backgroundImage: NetworkImage(
                            //                 '${Apis.pdfUrl}${report.staffImage!}'),
                            //           )
                            //         : const CircleAvatar(
                            //             backgroundColor: secondaryColor,
                            //             child: Icon(
                            //               Icons.person,
                            //               color: black,
                            //             ), // Fallback icon
                            //           ),
                            //     const SizedBox(width: 8),
                            //     Text(report.staffName ?? 'N/A'),
                            //   ],
                            // ),
                          ),
                          DataCell(Text(report.services?.toString() ?? '0')),
                          DataCell(Text(
                              '₹${report.commissionEarn?.toString() ?? '0.0'}')),
                          DataCell(
                              Text('₹${report.tipsEarn?.toString() ?? '0.0'}')),
                          DataCell(Text(
                              '₹${report.totalEarning?.toString() ?? '0.0'}')),
                        ]);
                      }).toList(),
                    ),
                  ),
                ),
              ),
              // Grand Total section moved to the bottom
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: double.infinity, // Take full width
                  decoration: BoxDecoration(
                    color: secondaryColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(
                      color: primaryColor,
                      width: 1.0,
                    ),
                  ),
                  margin: const EdgeInsets.all(16.0), // Add some margin
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
            ],
          );
        }),
      ),
    );
  }

  void _showExportDialog(
      BuildContext context, StaffServiceReportController controller) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Export Data',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: primaryColor, // Using primaryColor for consistency
            ),
          ),
          contentPadding: const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 0.0),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Choose export format:',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
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
