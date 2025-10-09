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
  var isSearching = false.obs;
  var searchQuery = ''.obs;

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
    fetchAttendanceData();
  }

  void setSearchQuery(String query) {
    searchQuery.value = query.toLowerCase();
  }

  void clearSearch() {
    searchQuery.value = '';
  }

  Future<void> fetchAttendanceData() async {
    final loginUser = await prefs.getUser();

    try {
      isLoading.value = true;
      final response = await dioClient.dio.get(
        "${Apis.baseUrl}/attendance/report/all-staff",
        queryParameters: {
          "salon_id": loginUser!.salonId,
          "year": selectedYear.value,
          "month": selectedMonth.value.toString().padLeft(2, '0'),
        },
      );

      if (response.statusCode == 200 && response.data['report'] != null) {
        final data = response.data['report'] as List;
        attendanceData.value = List<Map<String, dynamic>>.from(data);
      } else {
        CustomSnackbar.showError('Error', 'Failed to fetch attendance data');
        attendanceData.clear();
      }
    } catch (e) {
      print("⚠️ Attendance fetch error: $e");
      CustomSnackbar.showError('Exception', e.toString());
      attendanceData.clear();
    } finally {
      isLoading.value = false;
    }
  }
}

class StaffAttendanceReportPage extends StatelessWidget {
  final AttendanceController controller = Get.put(AttendanceController());
  final TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70.h),
        child: Obx(() => CustomAppBar(
              title: "Staff Attendance",
              actions: [
                Obx(() {
                  if (controller.isSearching.value) {
                    return SizedBox(
                      width: 220,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: TextField(
                          controller: searchController,
                          autofocus: true,
                          decoration: InputDecoration(
                            fillColor: Colors.white,
                            filled: true,
                            hintText: 'Search by staff name',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                            hintStyle: const TextStyle(color: Colors.grey),
                          ),
                          style: const TextStyle(
                              color: Colors.black, fontSize: 18),
                          onChanged: controller.setSearchQuery,
                          onSubmitted: (value) {
                            controller.setSearchQuery(value);
                            controller.isSearching.value = false;
                          },
                        ),
                      ),
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                }),
                Obx(() => IconButton(
                      icon: Icon(
                        controller.isSearching.value
                            ? Icons.close
                            : Icons.search,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        if (controller.isSearching.value) {
                          controller.isSearching.value = false;
                          searchController.clear();
                          controller.clearSearch();
                        } else {
                          controller.isSearching.value = true;
                        }
                      },
                    )),
                IconButton(
                  icon: const Icon(
                    Icons.more_vert,
                  ),
                  onPressed: () {
                    int tempMonth = controller.selectedMonth.value;
                    int tempYear = controller.selectedYear.value;
                    showDialog(
                      context: context,
                      builder: (BuildContext dialogContext) {
                        return StatefulBuilder(
                          builder:
                              (BuildContext context, StateSetter setState) {
                            return AlertDialog(
                              title: const Text('Select Month and Year'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Month'),
                                  DropdownButton<int>(
                                    value: tempMonth,
                                    isExpanded: true,
                                    items: controller.months.map((month) {
                                      return DropdownMenuItem<int>(
                                        value: month['value'] as int,
                                        child: Text(month['name'] as String),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      if (value != null) {
                                        setState(() {
                                          tempMonth = value;
                                        });
                                      }
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  const Text('Year'),
                                  DropdownButton<int>(
                                    value: tempYear,
                                    isExpanded: true,
                                    items: controller.years.map((year) {
                                      return DropdownMenuItem<int>(
                                        value: year,
                                        child: Text(year.toString()),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      if (value != null) {
                                        setState(() {
                                          tempYear = value;
                                        });
                                      }
                                    },
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(dialogContext).pop();
                                  },
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    controller.selectedMonth.value = tempMonth;
                                    controller.selectedYear.value = tempYear;
                                    controller.fetchAttendanceData();
                                    Navigator.of(dialogContext).pop();
                                  },
                                  child: const Text('Apply'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ],
            )),
      ),
      drawer: DrawerScreen(),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CustomLoadingAvatar());
        }

        final filteredData = controller.attendanceData
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
                // DataColumn(label: Text('Sr. No.')),
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
                  // DataCell(Text(index.toString())),
                  DataCell(Text(staff['full_name'] as String? ?? 'Unknown')),
                  DataCell(Text(staff['branch_name'] as String? ?? 'Unknown')),
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
    );
  }
}
