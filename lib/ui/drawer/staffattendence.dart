import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_template/main.dart';
import 'package:flutter_template/network/network_const.dart';
import 'package:flutter_template/ui/drawer/drawer_screen.dart';
import 'package:flutter_template/wiget/appbar/commen_appbar.dart';
import 'package:flutter_template/wiget/custome_snackbar.dart';
import 'package:flutter_template/wiget/loading.dart';
import 'package:get/get.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:open_file/open_file.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart' show rootBundle;

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
      print("⚠️ Branch fetch error: $e");
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
      print("⚠️ Attendance fetch error: $e");
      CustomSnackbar.showError('Exception', e.toString());
      attendanceData.clear();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> exportToExcel() async {
    try {
      final excel = Excel.createExcel();
      if (excel.sheets.containsKey('Sheet1')) {
        excel.delete('Sheet1');
      }

      final sheet = excel['Attendance Report'];

      // Add header row
      sheet.appendRow([
        'Staff Name',
        'Branch',
        'Present Days',
        'Absent Days',
        'Late Entries',
        'Early Exits'
      ]);

      // Add data rows
      for (var staff in attendanceData) {
        sheet.appendRow([
          staff['full_name']?.toString() ?? 'Unknown',
          staff['branch_name']?.toString() ?? 'Unknown',
          staff['present_days']?.toString() ?? '0',
          staff['absent_days']?.toString() ?? '0',
          staff['late_entries']?.toString() ?? '0',
          staff['early_exits']?.toString() ?? '0',
        ]);
      }

      // Save file
      final directory = await getApplicationDocumentsDirectory();
      final fileName =
          'attendance_report_${DateTime.now().millisecondsSinceEpoch}.xlsx';
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(excel.encode()!);
      await OpenFile.open(file.path);

      CustomSnackbar.showSuccess(
          'Success', 'Excel file exported successfully!');
    } catch (e) {
      CustomSnackbar.showError('Error', 'Failed to export Excel: $e');
    }
  }

  Future<void> exportToPdf() async {
    try {
      final pdf = pw.Document();
      final fontData =
          await rootBundle.load("assets/fonts/NotoSans-Regular.ttf");
      final ttf = pw.Font.ttf(fontData);

      pdf.addPage(
        pw.MultiPage(
           pageFormat: PdfPageFormat.a4,
          theme: pw.ThemeData.withFont(base: ttf, bold: ttf),
          build: (pw.Context context) {
            return [
              pw.Header(
                level: 0,
                child: pw.Text('Staff Attendance Report',
                    style: pw.TextStyle(
                        fontSize: 20, fontWeight: pw.FontWeight.bold)),
              ),
              pw.Table.fromTextArray(
                headers: [
                  'Staff Name',
                  'Branch',
                  'Present Days',
                  'Absent Days',
                  'Late Entries',
                  'Early Exits'
                ],
                data: attendanceData
                    .map((staff) => [
                          staff['full_name']?.toString() ?? 'Unknown',
                          staff['branch_name']?.toString() ?? 'Unknown',
                          staff['present_days']?.toString() ?? '0',
                          staff['absent_days']?.toString() ?? '0',
                          staff['late_entries']?.toString() ?? '0',
                          staff['early_exits']?.toString() ?? '0',
                        ])
                    .toList(),
              ),
            ];
          },
        ),
      );

      final directory = await getApplicationDocumentsDirectory();
      final fileName =
          'attendance_report_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(await pdf.save());
      await OpenFile.open(file.path);

      CustomSnackbar.showSuccess('Success', 'PDF file exported successfully!');
    } catch (e) {
      CustomSnackbar.showError('Error', 'Failed to export PDF: $e');
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
              child: Text('Clear'),
            ),
            TextButton(
              onPressed: () {
                controller.fetchAttendanceData();
                Navigator.of(context).pop();
              },
              child: Text('Apply'),
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
        title:'Staff Attendance',
        actions: [
          Obx(() => controller.isSearching.value
              ? SizedBox(
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
                      style: const TextStyle(color: Colors.black, fontSize: 18),
                      onChanged: (value) {
                        controller.setSearchQuery(value);
                      },
                    ),
                  ),
                )
              : SizedBox()),
          IconButton(
            icon: Obx(() => Icon(
                  controller.isSearching.value ? Icons.close : Icons.search,
                  color: Colors.white,
                )),
            onPressed: () {
              if (controller.isSearching.value) {
                controller.isSearching.value = false;
                searchController.clear();
                controller.clearSearch();
              } else {
                controller.isSearching.value = true;
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.filter_list, color: Colors.white),
            onPressed: () => _showFilterDialog(context),
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.download, color: Colors.white),
            onSelected: (value) async {
              if (value == 'excel') {
                await controller.exportToExcel();
              } else if (value == 'pdf') {
                await controller.exportToPdf();
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                value: 'excel',
                child: Text('Export to Excel'),
              ),
              PopupMenuItem<String>(
                value: 'pdf',
                child: Text('Export to PDF'),
              ),
            ],
          ),
        ],
      ),
      drawer: DrawerScreen(),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CustomLoadingAvatar());
        }

        final filteredData = controller.attendanceData
            .where((staff) =>
                (staff['full_name']?.toString().toLowerCase() ?? '')
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
                  DataCell(Text(staff['full_name']?.toString() ?? 'Unknown')),
                  DataCell(Text(staff['branch_name']?.toString() ?? 'Unknown')),
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
