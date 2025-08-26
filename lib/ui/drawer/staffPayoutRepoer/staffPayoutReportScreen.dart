import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../wiget/appbar/commen_appbar.dart';
import '../../../wiget/loading.dart';
import 'package:flutter_template/utils/colors.dart';
import '../drawer_screen.dart';
import 'staffPayoutReoirtController.dart';

class Staffpayoutreportscreen extends StatelessWidget {
  const Staffpayoutreportscreen({super.key});

  @override
  Widget build(BuildContext context) {
    final StatffearningReportcontroller getController =
        Get.put(StatffearningReportcontroller());

    // Add search functionality
    final RxBool isSearching = false.obs;
    final TextEditingController searchController = TextEditingController();

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70.h),
        child: Obx(() {
          return CustomAppBar(
            title: isSearching.value ? '' : 'Staff Payout Report',
            backgroundColor: primaryColor,
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
                        hintText: 'Search by Staff Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        hintStyle: TextStyle(color: grey),
                      ),
                      style: TextStyle(color: Colors.black, fontSize: 18),
                      onSubmitted: (value) {
                        getController.updateSearchQuery(value);
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
                    getController.clearSearchQuery();
                  } else {
                    isSearching.value = true;
                  }
                },
              ),
              PopupMenuButton<String>(
                onSelected: (value) async {
                  try {
                    if (value == 'date') {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (picked != null) {
                        getController.selectDate(picked);
                      }
                    } else if (value == 'range') {
                      final DateTimeRange? picked = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (picked != null) {
                        getController.selectDateRange(picked);
                      }
                    } else if (value == 'sort_asc') {
                      getController.setSortOrder('asc');
                    } else if (value == 'sort_desc') {
                      getController.setSortOrder('desc');
                    } else if (value == 'clear') {
                      getController.clearFilters();
                    } else if (value == 'export') {
                      _showExportDialog(context, getController);
                    }
                  } catch (e) {
                    print('Error in PopupMenuButton: $e');
                    // Show error to user
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  PopupMenuItem<String>(
                    value: 'date',
                    child: Text('Filter by Date'),
                  ),
                  PopupMenuItem<String>(
                    value: 'range',
                    child: Text('Filter by Date Range'),
                  ),
                  const PopupMenuDivider(),
                  PopupMenuItem<String>(
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
                  PopupMenuItem<String>(
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
                  PopupMenuItem<String>(
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
                  PopupMenuItem<String>(
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
          // Remove the old search TextField since we now have it in AppBar
          Expanded(
            child: Obx(() {
              if (getController.isLoading.value) {
                return Center(child: CustomLoadingAvatar());
              }
              if (getController.payouts.isEmpty) {
                return Center(
                    child: Text('No payout data available',
                        style: TextStyle(color: Colors.red)));
              }
              if (getController.filteredPayouts.isEmpty) {
                return const Center(
                    child: Text('No payouts found with the current filters.'));
              }
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Payment Date')),
                      DataColumn(label: Text('Staff')),
                      DataColumn(label: Text('Commission Amount')),
                      DataColumn(label: Text('Tips Amount')),
                      DataColumn(label: Text('Payment Type')),
                      DataColumn(label: Text('Total Pay')),
                    ],
                    rows: (() {
                      try {
                        return getController.filteredPayouts.map((payout) {
                          return DataRow(cells: [
                            DataCell(Text(payout.formattedDate)),
                            DataCell(Text(payout.staffName)),
                            DataCell(Text(payout.commissionAmount.toString())),
                            DataCell(Text(payout.tips.toString())),
                            DataCell(Text(payout.paymentType)),
                            DataCell(Text(payout.totalPay.toString())),
                          ]);
                        }).toList();
                      } catch (e) {
                        print('Error building DataTable rows: $e');
                        return <DataRow>[];
                      }
                    })(),
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
                          '\u20b9${(() {
                            try {
                              return getController.grandTotal.value
                                  .toStringAsFixed(2);
                            } catch (e) {
                              print('Error getting grand total: $e');
                              return '0.00';
                            }
                          })()}',
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
    );
  }

  void _showExportDialog(
      BuildContext context, StatffearningReportcontroller controller) {
    try {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0)),
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
                        try {
                          controller.exportToExcel();
                        } catch (e) {
                          print('Error exporting to Excel: $e');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('Error exporting to Excel: $e')),
                          );
                        }
                      },
                    ),
                    _buildExportOption(
                      context,
                      icon: Icons.picture_as_pdf,
                      label: 'PDF',
                      color: Colors.red,
                      onTap: () {
                        Navigator.of(context).pop();
                        try {
                          controller.exportToPdf();
                        } catch (e) {
                          print('Error exporting to PDF: $e');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('Error exporting to PDF: $e')),
                          );
                        }
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
    } catch (e) {
      print('Error showing export dialog: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error showing export dialog: $e')),
      );
    }
  }

  Widget _buildExportOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    try {
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
    } catch (e) {
      print('Error building export option: $e');
      return Container(); // Return empty container on error
    }
  }
}
