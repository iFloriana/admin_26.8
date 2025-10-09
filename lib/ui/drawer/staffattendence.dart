import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_template/main.dart';
import 'package:flutter_template/network/network_const.dart';
import 'package:flutter_template/ui/drawer/drawer_screen.dart';
import 'package:flutter_template/utils/colors.dart';
import 'package:flutter_template/wiget/appbar/commen_appbar.dart';
import 'package:flutter_template/wiget/custome_snackbar.dart';
import 'package:flutter_template/wiget/loading.dart';
import 'package:get/get.dart';

class AttendanceController extends GetxController {
  var attendanceData = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;
  var selectedYear = DateTime.now().year.obs;
  var selectedMonth = DateTime.now().month.obs;
  var selectedBranch = ''.obs;
  var isSearching = false.obs;
  var searchQuery = ''.obs;
  var branches = <Map<String, dynamic>>[].obs;

  final years = List.generate(10, (index) => DateTime.now().year - 5 + index);
  final months = [
    {'name': 'January', 'value': 1},
    {'name': 'February', 'value': 2},
    {'name': 'March', 'value': 3},
    {'name': 'April', 'value': 4},
    {'name': 'May', 'value': 5},
    {'name': 'June', 'value': 6},
    {'name': 'July', 'value': 7},
    {'name': 'August', 'value': 8},
    {'name': 'September', 'value': 9},
    {'name': 'October', 'value': 10},
    {'name': 'November', 'value': 11},
    {'name': 'December', 'value': 12},
  ];

  @override
  void onInit() {
    super.onInit();
    fetchBranches();
    fetchAttendanceData();
  }

  void setSearchQuery(String query) {
    searchQuery.value = query.toLowerCase();
  }

  void clearSearch() {
    searchQuery.value = '';
  }

  Future<void> fetchBranches() async {
    final loginUser = await prefs.getUser();
    try {
      final response = await dioClient.dio.get(
        "${Apis.baseUrl}/branches/names",
        queryParameters: {
          "salon_id": loginUser!.salonId,
        },
      );

      if (response.statusCode == 200 && response.data['data'] != null) {
        branches.value = List<Map<String, dynamic>>.from(response.data['data']);
      } else {
        CustomSnackbar.showError('Error', 'Failed to fetch branch data');
      }
    } catch (e) {
      print("Branch fetch error: $e");
      CustomSnackbar.showError('Exception', e.toString());
    }
  }

  Future<void> fetchAttendanceData() async {
    final loginUser = await prefs.getUser();

    try {
      isLoading.value = true;
      final queryParameters = {
        "salon_id": loginUser!.salonId,
        "year": selectedYear.value,
        "month": selectedMonth.value.toString().padLeft(2, '0'),
      };
      if (selectedBranch.value.isNotEmpty) {
        queryParameters["branch_id"] = selectedBranch.value;
      }

      final response = await dioClient.dio.get(
        "${Apis.baseUrl}/attendance/report/all-staff",
        queryParameters: queryParameters,
      );

      if (response.statusCode == 200 && response.data['report'] != null) {
        final data = response.data['report'] as List;
        attendanceData.value = List<Map<String, dynamic>>.from(data);
      } else {
        CustomSnackbar.showError('Error', 'Failed to fetch attendance data');
        attendanceData.clear();
      }
    } catch (e) {
      print("Attendance fetch error: $e");
      CustomSnackbar.showError('Exception', e.toString());
      attendanceData.clear();
    } finally {
      isLoading.value = false;
    }
  }
}

class StaffAttendanceReportPage extends StatelessWidget {
  final controller = Get.put(AttendanceController());
  final TextEditingController searchController = TextEditingController();

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Filter Attendance'),
          content: SingleChildScrollView(
            child: Obx(() => Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Year'),
                    DropdownButton<int>(
                      isExpanded: true,
                      value: controller.selectedYear.value,
                      items: controller.years.map((year) {
                        return DropdownMenuItem<int>(
                          value: year,
                          child: Text(year.toString()),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          controller.selectedYear.value = value;
                        }
                      },
                    ),
                    SizedBox(height: 16.h),
                    Text('Month'),
                    DropdownButton<int>(
                      isExpanded: true,
                      value: controller.selectedMonth.value,
                      items: controller.months.map((month) {
                        return DropdownMenuItem<int>(
                          value: month['value'] as int,
                          child: Text(month['name'] as String),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          controller.selectedMonth.value = value;
                        }
                      },
                    ),
                    SizedBox(height: 16.h),
                    Text('Branch'),
                    DropdownButton<String>(
                      isExpanded: true,
                      value: controller.selectedBranch.value.isEmpty
                          ? null
                          : controller.selectedBranch.value,
                      hint: Text('Select Branch'),
                      items: [
                        DropdownMenuItem<String>(
                          value: '',
                          child: Text('All Branches'),
                        ),
                        ...controller.branches.map((branch) {
                          return DropdownMenuItem<String>(
                            value: branch['_id'],
                            child: Text(branch['name']),
                          );
                        }).toList(),
                      ],
                      onChanged: (value) {
                        controller.selectedBranch.value = value ?? '';
                      },
                    ),
                  ],
                )),
          ),
          actions: [
            TextButton(
                onPressed: () {
                  controller.selectedYear.value = DateTime.now().year;
                  controller.selectedMonth.value = DateTime.now().month;
                  controller.selectedBranch.value = '';
                  controller.fetchAttendanceData();
                  Navigator.of(context).pop();
                },
                child: Text(
                  'Clear',
                  style: TextStyle(color: grey),
                )),
            TextButton(
              onPressed: () {
                controller.fetchAttendanceData();
                Navigator.of(context).pop();
              },
              child: Text(
                'Apply',
                style: TextStyle(color: primaryColor),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Staff Attendance Report',
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context),
          ),
        ],
      ),
      drawer: DrawerScreen(),
      body: Column(
        children: [
          // Optional: Show selected filters as chips
          // Obx(() => Padding(
          //       padding: EdgeInsets.all(8.w),
          //       child: Wrap(
          //         spacing: 8.w,
          //         children: [
          //           if (controller.selectedBranch.value.isNotEmpty)
          //             Chip(
          //               label: Text(controller.branches.firstWhere(
          //                   (b) => b['_id'] == controller.selectedBranch.value,
          //                   orElse: () => {'name': 'Unknown'})['name']),
          //               onDeleted: () {
          //                 controller.selectedBranch.value = '';
          //                 controller.fetchAttendanceData();
          //               },
          //             ),
          //           if (controller.selectedYear.value != DateTime.now().year ||
          //               controller.selectedMonth.value != DateTime.now().month)
          //             Chip(
          //               label: Text(
          //                   '${controller.months.firstWhere((m) => m['value'] == controller.selectedMonth.value)['name']} ${controller.selectedYear.value}'),
          //               onDeleted: () {
          //                 controller.selectedYear.value = DateTime.now().year;
          //                 controller.selectedMonth.value = DateTime.now().month;
          //                 controller.fetchAttendanceData();
          //               },
          //             ),
          //         ],
          //       ),
          //     )),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CustomLoadingAvatar());
              }

              // Client-side fallback filter if server doesn't filter (based on demo data observation)
              var displayData = controller.attendanceData.toList();
              if (controller.selectedBranch.value.isNotEmpty) {
                final selectedBranchId = controller.selectedBranch.value;
                displayData = displayData
                    .where((staff) => staff['branch_id'] == selectedBranchId)
                    .toList();
              }

              final filteredData = displayData
                  .where((staff) => (staff['full_name'] as String? ?? 'Unknown')
                      .toLowerCase()
                      .contains(controller.searchQuery.value))
                  .toList();

              if (filteredData.isEmpty) {
                return const Center(child: Text("No attendance data found"));
              }

              return SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Staff')),
                      DataColumn(label: Text('Branch')),
                      DataColumn(label: Text('Present Days')),
                      DataColumn(label: Text('Absent Days')),
                      DataColumn(label: Text('Late Entries')),
                      DataColumn(label: Text('Early Exits')),
                    ],
                    rows: filteredData.asMap().entries.map((entry) {
                      final index = entry.key + 1;
                      final staff = entry.value;
                      return DataRow(cells: [
                        DataCell(
                            Text(staff['full_name'] as String? ?? 'Unknown')),
                        DataCell(
                            Text(staff['branch_name'] as String? ?? 'Unknown')),
                        DataCell(Text((staff['present_days'] ?? 0).toString())),
                        DataCell(Text((staff['absent_days'] ?? 0).toString())),
                        DataCell(Text((staff['late_entries'] ?? 0).toString())),
                        DataCell(Text((staff['early_exits'] ?? 0).toString())),
                      ]);
                    }).toList(),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
