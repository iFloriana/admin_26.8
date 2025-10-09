import 'package:flutter/material.dart';
import 'package:flutter_template/main.dart';
import 'package:flutter_template/utils/colors.dart';
import 'package:flutter_template/network/network_const.dart';
import 'package:flutter_template/ui/drawer/staff/staffDetailsController.dart';
import 'package:flutter_template/wiget/appbar/commen_appbar.dart';
import 'package:flutter_template/wiget/custome_snackbar.dart';
import 'package:flutter_template/wiget/loading.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:excel/excel.dart' hide Data;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;

class StaffProfileScreen extends StatelessWidget {
  final Data staff;
  StaffProfileScreen({super.key, required this.staff});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: CustomAppBar(
          title: staff.fullName ?? 'Staff Profile',
          bottom: const TabBar(
            indicatorColor: secondaryColor,
            labelColor: Colors.white,
            splashBorderRadius: BorderRadius.vertical(
              bottom: Radius.circular(20.0),
            ),
            unselectedLabelColor: secondaryColor,
            dividerColor: Colors.transparent,
            tabs: [
              Tab(text: 'Details'),
              Tab(text: 'Attendance'),
              Tab(text: 'Performance'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            StaffDetailsTab(staff: staff),
            AttendanceTab(staff: staff),
            PerformanceTab(staff: staff),
          ],
        ),
      ),
    );
  }
}

class StaffDetailsTab extends StatelessWidget {
  final Data staff;
  const StaffDetailsTab({super.key, required this.staff});

  @override
  Widget build(BuildContext context) {
    final DateFormat dateFormatter = DateFormat('yyyy-MM-dd');
    String formattedJoiningDate = 'N/A';
    if (staff.createdAt != null) {
      try {
        final DateTime parsedDate = DateTime.parse(staff.createdAt!);
        formattedJoiningDate = dateFormatter.format(parsedDate);
      } catch (e) {
        formattedJoiningDate = 'Invalid Date';
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.deepPurple.shade100,
              backgroundImage: staff.image != null
                  ? NetworkImage(
                      '${Apis.pdfUrl}${staff.image}?v=${DateTime.now().millisecondsSinceEpoch}',
                    )
                  : null,
              child: staff.image == null
                  ? const Icon(Icons.person, size: 50, color: Colors.white)
                  : null,
            ),
          ),
          const SizedBox(height: 20),
          _buildDetailRow('Name', staff.fullName ?? 'N/A'),
          _buildDetailRow('Email', staff.email ?? 'N/A'),
          _buildDetailRow('Phone', staff.phoneNumber ?? 'N/A'),
          _buildDetailRow('Gender', staff.gender ?? 'N/A'),
          _buildDetailRow('Specialization', staff.specialization ?? 'N/A'),
          _buildDetailRow('Branch', staff.branchId?.name ?? 'N/A'),
          _buildDetailRow('Commission', staff.commissionId?.name ?? 'N/A'),
          _buildDetailRow(
            'Services',
            staff.serviceId?.map((s) => s.name).join(', ') ?? 'N/A',
          ),
          _buildDetailRow(
            'Shift',
            '${staff.assignTime?.startShift ?? 'N/A'} - ${staff.assignTime?.endShift ?? 'N/A'}',
          ),
          _buildDetailRow(
            'Lunch',
            '${staff.lunchTime?.timing ?? 'N/A'} (${staff.lunchTime?.duration ?? 0} min)',
          ),
          _buildDetailRow('Status', staff.status == 1 ? 'Active' : 'Inactive'),
          _buildDetailRow('Joining At', formattedJoiningDate),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}

class AttendanceController extends GetxController {
  var attendanceData = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;
  final Data staff;

  AttendanceController(this.staff);

  @override
  void onInit() {
    super.onInit();
    fetchAttendanceData();
  }

  Future<void> fetchAttendanceData() async {
    final loginUser = await prefs.getUser();
    try {
      isLoading.value = true;
      final queryParameters = {
        "salon_id": loginUser!.salonId,
        "staff_id": staff.sId,
        "year": DateTime.now().year,
        "month": DateTime.now().month.toString().padLeft(2, '0'),
      };

      final response = await dioClient.dio.get(
        "${Apis.baseUrl}/attendance/report/staff",
        queryParameters: queryParameters,
      );

      if (response.statusCode == 200 && response.data['report'] != null) {
        final data = response.data['report'] as List;
        attendanceData.value = List<Map<String, dynamic>>.from(data);
      } else {
        attendanceData.clear();
      }
    } catch (e) {
      print("⚠️ Attendance fetch error: $e");
      attendanceData.clear();
    } finally {
      isLoading.value = false;
    }
  }

  String getFormattedDate(String? date) {
    if (date == null) return 'N/A';
    try {
      final parsedDate = DateTime.parse(date);
      return DateFormat('yyyy-MM-dd').format(parsedDate);
    } catch (e) {
      return 'Invalid Date';
    }
  }

  Future<void> exportToExcel() async {
    try {
      final excel = Excel.createExcel();
      final sheetNames = excel.tables.keys.toList();
      Sheet sheet;

      if (sheetNames.isNotEmpty) {
        final defaultSheetName = sheetNames.first;
        sheet = excel.tables[defaultSheetName]!;
        for (int row = 0; row < sheet.maxRows; row++) {
          for (int col = 0; col < sheet.maxCols; col++) {
            final cell = sheet.cell(CellIndex.indexByColumnRow(
              columnIndex: col,
              rowIndex: row,
            ));
            if (cell.value != null) {
              cell.value = null;
            }
          }
        }
      } else {
        sheet = excel['Attendance Report'];
      }

      final headers = [
        'Date',
        'Status',
        'Check In',
        'Check Out',
        'Total Hours'
      ];
      for (int i = 0; i < headers.length; i++) {
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0))
          ..value = headers[i]
          ..cellStyle = CellStyle(
            bold: true,
            horizontalAlign: HorizontalAlign.Center,
            backgroundColorHex: '#E0E0E0',
          );
      }

      int rowIndex = 1;
      for (var record in attendanceData) {
        sheet.cell(
            CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex))
          ..value = getFormattedDate(record['date']);
        sheet.cell(
            CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex))
          ..value = record['status']?.toString() ?? 'N/A';
        sheet.cell(
            CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex))
          ..value = record['check_in']?.toString() ?? 'N/A';
        sheet.cell(
            CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIndex))
          ..value = record['check_out']?.toString() ?? 'N/A';
        sheet.cell(
            CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: rowIndex))
          ..value = record['total_hours']?.toString() ?? 'N/A';
        rowIndex++;
      }

      try {
        final newSheet = excel['Attendance Report'];
        for (int row = 0; row < sheet.maxRows; row++) {
          for (int col = 0; col < sheet.maxCols; col++) {
            final sourceCell = sheet.cell(CellIndex.indexByColumnRow(
              columnIndex: col,
              rowIndex: row,
            ));
            if (sourceCell.value != null) {
              final targetCell = newSheet.cell(CellIndex.indexByColumnRow(
                columnIndex: col,
                rowIndex: row,
              ));
              targetCell.value = sourceCell.value;
            }
          }
        }
        if (sheetNames.isNotEmpty) {
          excel.delete(sheetNames.first);
        }
      } catch (e) {
        print('Could not rename sheet: $e');
      }

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
          await rootBundle.load('assets/fonts/NotoSans-Regular.ttf');
      final ttf = pw.Font.ttf(fontData);

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4.portrait,
          theme: pw.ThemeData.withFont(
            base: ttf,
            bold: ttf,
          ),
          build: (pw.Context context) {
            return [
              pw.Header(
                level: 0,
                child: pw.Text(
                  'Attendance Report',
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Table.fromTextArray(
                context: context,
                data: <List<String>>[
                  ['Date', 'Status', 'Check In', 'Check Out', 'Total Hours'],
                  ...attendanceData.map<List<String>>((record) {
                    return <String>[
                      getFormattedDate(record['date']),
                      record['status']?.toString() ?? 'N/A',
                      record['check_in']?.toString() ?? 'N/A',
                      record['check_out']?.toString() ?? 'N/A',
                      record['total_hours']?.toString() ?? 'N/A',
                    ];
                  }).toList(),
                ],
                cellHeight: 30,
                cellAlignment: pw.Alignment.center,
                border: pw.TableBorder.all(),
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

class AttendanceTab extends StatelessWidget {
  final Data staff;
  const AttendanceTab({super.key, required this.staff});

  @override
  Widget build(BuildContext context) {
    Get.put(AttendanceController(staff));
    return Obx(() {
      final controller = Get.find<AttendanceController>();
      return Stack(
        children: [
          controller.isLoading.value
              ? const Center(child: CustomLoadingAvatar())
              : controller.attendanceData.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.event_note,
                              size: 80, color: Colors.grey.shade400),
                          const SizedBox(height: 20),
                          Text(
                            'Attendance records for ${staff.fullName ?? "Staff"}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'No attendance data available',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('Date')),
                          DataColumn(label: Text('Status')),
                          DataColumn(label: Text('Check In')),
                          DataColumn(label: Text('Check Out')),
                          DataColumn(label: Text('Total Hours')),
                        ],
                        rows: controller.attendanceData.map((record) {
                          return DataRow(cells: [
                            DataCell(Text(record['date'] != null
                                ? DateFormat('yyyy-MM-dd')
                                    .format(DateTime.parse(record['date']))
                                : 'N/A')),
                            DataCell(
                                Text(record['status']?.toString() ?? 'N/A')),
                            DataCell(
                                Text(record['check_in']?.toString() ?? 'N/A')),
                            DataCell(
                                Text(record['check_out']?.toString() ?? 'N/A')),
                            DataCell(Text(
                                record['total_hours']?.toString() ?? 'N/A')),
                          ]);
                        }).toList(),
                      ),
                    ),
          if (!controller.isLoading.value &&
              controller.attendanceData.isNotEmpty)
            Positioned(
              bottom: 16,
              right: 16,
              child: FloatingActionButton(
                onPressed: () {
                  _showExportDialog(context, controller);
                },
                backgroundColor: primaryColor,
                child: const Icon(Icons.download, color: Colors.white),
              ),
            ),
        ],
      );
    });
  }

  void _showExportDialog(
      BuildContext context, AttendanceController controller) {
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
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: color.withOpacity(0.1),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class PerformanceController extends GetxController {
  final Rx<Map<String, dynamic>?> performanceData =
      Rx<Map<String, dynamic>?>(null);
  final RxBool isLoading = true.obs;
  final Data staff;

  PerformanceController(this.staff);

  @override
  void onInit() {
    super.onInit();
    fetchPerformanceData();
  }

  Future<void> fetchPerformanceData() async {
    var getUser = await prefs.getUser();
    try {
      final response = await dioClient.dio.get(
        '${Apis.baseUrl}/staffs/performance/${staff.sId}',
        queryParameters: {'salon_id': getUser?.salonId},
      );

      if (response.statusCode == 200) {
        performanceData.value = response.data;
      }
    } catch (e) {
      performanceData.value = null;
    } finally {
      isLoading.value = false;
    }
  }
}

class PerformanceTab extends StatelessWidget {
  final Data staff;
  const PerformanceTab({super.key, required this.staff});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PerformanceController(staff));

    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CustomLoadingAvatar());
      }

      final data = controller.performanceData.value;
      return Scaffold(
        backgroundColor: Colors.grey[100],
        body: data == null
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.bar_chart,
                        size: 90, color: Colors.grey.shade400),
                    const SizedBox(height: 20),
                    Text(
                      'No performance data available',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              )
            : Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    Expanded(
                      child: GridView.count(
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 1.1,
                        children: [
                          _buildStatCard(
                            icon: Icons.calendar_today,
                            title: "Appointments",
                            value: data['appointment_count']?.toString() ?? "0",
                            color: Colors.indigo,
                          ),
                          _buildStatCard(
                            icon: Icons.content_cut,
                            title: "Service Amount",
                            value: "₹${data['total_service_amount'] ?? '0'}",
                            color: Colors.purple,
                          ),
                          _buildStatCard(
                            icon: Icons.shopping_bag,
                            title: "Product Amount",
                            value: "₹${data['total_product_amount'] ?? '0'}",
                            color: Colors.teal,
                          ),
                          _buildStatCard(
                            icon: Icons.monetization_on,
                            title: "Commission Earned",
                            value: "₹${data['commission_earned'] ?? '0'}",
                            color: Colors.orange,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      );
    });
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: color.withOpacity(0.1),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
