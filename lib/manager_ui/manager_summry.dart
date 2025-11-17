import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_template/main.dart';
import 'package:flutter_template/manager_ui/drawer/drawerscreen.dart';
import 'package:flutter_template/network/network_const.dart';
import 'package:flutter_template/utils/colors.dart';
import 'package:flutter_template/wiget/appbar/commen_appbar.dart';
import 'package:flutter_template/wiget/custome_snackbar.dart';
import 'package:flutter_template/wiget/loading.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';

class ManagerSummaryController extends GetxController {
  var isLoading = false.obs;
  var summary = {}.obs;
  var staffList = [].obs;

  var selectedDateRange = Rxn<DateTimeRange>();

  @override
  void onInit() {
    super.onInit();
    fetchSummary();
  }

  Future<void> fetchSummary() async {
    try {
      isLoading.value = true;
      var details = await prefs.getManagerUser();
      String baseUrl = "${Apis.baseUrl}/overall-summary";
      String url = "$baseUrl?salon_id=${details?.manager?.salonId}";

      if (selectedDateRange.value != null) {
        final start =
            DateFormat("yyyy-MM-dd").format(selectedDateRange.value!.start);
        final end =
            DateFormat("yyyy-MM-dd").format(selectedDateRange.value!.end);
        url = "$url&start_date=$start&end_date=$end";
      }

      final response = await dioClient.dio.get(url);

      if (response.statusCode == 200) {
        final data = response.data;
        if (data["success"] == true) {
          summary.value = data["summary"] ?? {};
          staffList.value = data["staff"] ?? [];
        } else {
          CustomSnackbar.showError("Error", "API returned success=false");
        }
      } else {
        CustomSnackbar.showError("Error", "Failed to load summary");
      }
    } catch (e) {
      CustomSnackbar.showError("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// ----------------- EXPORT FUNCTIONS ----------------- ///
  Future<void> exportToExcel() async {
    try {
      final excel = Excel.createExcel();
      if (excel.sheets.containsKey('Sheet1')) {
        excel.delete('Sheet1');
      }

      final sheet = excel['Finance Summary'];

      int rowIndex = 0;

      // ---------- 1) Actual Sales ----------
      sheet.appendRow(["Actual Sales to Salon", "₹"]);
      sheet.appendRow(["Services", summary["total_service_sales"] ?? 0]);
      sheet.appendRow(["Products", summary["total_product_sales"] ?? 0]);
      sheet.appendRow(["Memberships", summary["total_membership_sales"] ?? 0]);
      sheet.appendRow(["Packages", summary["total_package_sales"] ?? 0]);
      sheet.appendRow(["Total", summary["grand_total"] ?? 0]);
      rowIndex = sheet.maxRows; // move pointer

      sheet.appendRow([]); // empty row

      // ---------- 2) Collections ----------
      sheet.appendRow(["Collections", "₹"]);
      sheet.appendRow(["Cash", summary["payment_breakdown"]["cash"] ?? 0]);
      sheet.appendRow(["Card", summary["payment_breakdown"]["card"] ?? 0]);
      sheet.appendRow(["UPI", summary["payment_breakdown"]["upi"] ?? 0]);
      sheet.appendRow(["Outstanding", -(summary["difference"] ?? 0)]);
      sheet.appendRow(["Total", summary["collected_total"] ?? 0]);
      rowIndex = sheet.maxRows;

      sheet.appendRow([]);

      // ---------- 3) Appointment Count ----------
      sheet.appendRow(["Appointment Count", ""]);
      sheet.appendRow(["Open", summary["appointment_counts"]["open"] ?? 0]);
      sheet.appendRow(
          ["Completed", summary["appointment_counts"]["completed"] ?? 0]);
      sheet.appendRow(
          ["Cancelled", summary["appointment_counts"]["cancelled"] ?? 0]);
      sheet.appendRow(["Total", summary["appointment_counts"]["total"] ?? 0]);
      rowIndex = sheet.maxRows;

      sheet.appendRow([]);

      // ---------- 4) Sales by Staff ----------
      sheet.appendRow(["Sales by Staff"]);
      sheet.appendRow([
        "Staff Name",
        "Service Count",
        "Service Amount ₹",
        "Product Amount ₹",
        "Total ₹"
      ]);
      for (var staff in staffList) {
        sheet.appendRow([
          staff["staff_name"] ?? "-",
          staff["service_count"] ?? 0,
          staff["total_service_amount"] ?? 0,
          staff["total_product_amount"] ?? 0,
          staff["total"] ?? 0,
        ]);
      }

      // Save file
      final directory = await getApplicationDocumentsDirectory();
      final fileName =
          'finance_summary_${DateTime.now().millisecondsSinceEpoch}.xlsx';
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
                child: pw.Text('Finance Summary Report',
                    style: pw.TextStyle(
                        fontSize: 20, fontWeight: pw.FontWeight.bold)),
              ),

              // ---------- 1) Actual Sales ----------
              pw.Text("Actual Sales to Salon",
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Table.fromTextArray(
                data: [
                  ['Label', 'Value'],
                  ['Services', summary["total_service_sales"] ?? 0],
                  ['Products', summary["total_product_sales"] ?? 0],
                  ['Memberships', summary["total_membership_sales"] ?? 0],
                  ['Packages', summary["total_package_sales"] ?? 0],
                  ['Total', summary["grand_total"] ?? 0],
                ],
              ),
              pw.SizedBox(height: 20),

              // ---------- 2) Collections ----------
              pw.Text("Collections",
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Table.fromTextArray(
                data: [
                  ['Label', 'Value'],
                  ['Cash', summary["payment_breakdown"]["cash"] ?? 0],
                  ['Card', summary["payment_breakdown"]["card"] ?? 0],
                  ['UPI', summary["payment_breakdown"]["upi"] ?? 0],
                  ['Outstanding', -(summary["difference"] ?? 0)],
                  ['Total', summary["collected_total"] ?? 0],
                ],
              ),
              pw.SizedBox(height: 20),

              // ---------- 3) Appointment Count ----------
              pw.Text("Appointment Count",
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Table.fromTextArray(
                data: [
                  ['Label', 'Value'],
                  ['Open', summary["appointment_counts"]["open"] ?? 0],
                  [
                    'Completed',
                    summary["appointment_counts"]["completed"] ?? 0
                  ],
                  [
                    'Cancelled',
                    summary["appointment_counts"]["cancelled"] ?? 0
                  ],
                  ['Total', summary["appointment_counts"]["total"] ?? 0],
                ],
              ),
              pw.SizedBox(height: 20),

              // ---------- 4) Sales by Staff ----------
              pw.Text("Sales by Staff",
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Table.fromTextArray(
                headers: [
                  'Staff Name',
                  'Service Count',
                  'Service Amount ₹',
                  'Product Amount ₹',
                  'Total ₹'
                ],
                data: staffList
                    .map((staff) => [
                          staff["staff_name"] ?? "-",
                          staff["service_count"] ?? 0,
                          staff["total_service_amount"] ?? 0,
                          staff["total_product_amount"] ?? 0,
                          staff["total"] ?? 0,
                        ])
                    .toList(),
              ),
            ];
          },
        ),
      );

      final directory = await getApplicationDocumentsDirectory();
      final fileName =
          'finance_summary_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(await pdf.save());
      await OpenFile.open(file.path);

      CustomSnackbar.showSuccess('Success', 'PDF file exported successfully!');
    } catch (e) {
      CustomSnackbar.showError('Error', 'Failed to export PDF: $e');
    }
  }
}

class ManagerSummaryPage extends StatelessWidget {
  final ManagerSummaryController controller =
      Get.put(ManagerSummaryController());

  ManagerSummaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Finance Summary",
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: () async {
              final DateTimeRange? picked = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2022),
                lastDate: DateTime.now(),
                initialDateRange: controller.selectedDateRange.value,
              );
              if (picked != null) {
                controller.selectedDateRange.value = picked;
                controller.fetchSummary();
              }
            },
          ),
        ],
      ),
      drawer: ManagerDrawerScreen(),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CustomLoadingAvatar());
        }

        final summary = controller.summary;
        final staffList = controller.staffList;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  controller.selectedDateRange.value != null
                      ? "Summary of ${DateFormat('dd/M/yyyy').format(controller.selectedDateRange.value!.start)}"
                          " - ${DateFormat('dd/M/yyyy').format(controller.selectedDateRange.value!.end)}"
                      : "Summary of ${DateFormat('dd/M/yyyy').format(DateTime.now())}",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _buildCard("Actual sales to salon", [
                _buildRow("Services", summary["total_service_sales"]),
                _buildRow("Products", summary["total_product_sales"]),
                _buildRow("Memberships", summary["total_membership_sales"]),
                _buildRow("Packages", summary["total_package_sales"]),
                const Divider(),
                _buildRow("Total", summary["grand_total"], isBold: true),
              ]),
              _buildCard("Collections", [
                _buildRow("Cash", summary["payment_breakdown"]["cash"]),
                _buildRow("Card", summary["payment_breakdown"]["card"]),
                _buildRow("UPI", summary["payment_breakdown"]["upi"]),
                _buildRow("Outstanding", -summary["difference"]),
                const Divider(),
                _buildRow("Total", summary["collected_total"], isBold: true),
              ]),
              _buildCard("Appointment Count", [
                _buildRow("Open", summary["appointment_counts"]["open"]),
                _buildRow(
                    "Completed", summary["appointment_counts"]["completed"]),
                _buildRow(
                    "Cancelled", summary["appointment_counts"]["cancelled"]),
                const Divider(),
                _buildRow("Total", summary["appointment_counts"]["total"],
                    isBold: true),
              ]),
              _buildCard("Sales by Staff", [
                Table(
                  border: TableBorder.all(color: Colors.grey.shade300),
                  columnWidths: const {
                    0: FlexColumnWidth(3),
                    1: FlexColumnWidth(2),
                    2: FlexColumnWidth(3),
                    3: FlexColumnWidth(3),
                    4: FlexColumnWidth(3),
                  },
                  children: [
                    const TableRow(
                      decoration: BoxDecoration(color: Color(0xFFE0E0E0)),
                      children: [
                        Padding(
                            padding: EdgeInsets.all(8),
                            child: Text("Staff Name",
                                style: TextStyle(fontWeight: FontWeight.bold))),
                        Padding(
                            padding: EdgeInsets.all(8),
                            child: Text("Service Count",
                                style: TextStyle(fontWeight: FontWeight.bold))),
                        Padding(
                            padding: EdgeInsets.all(8),
                            child: Text("Service Amount ₹",
                                style: TextStyle(fontWeight: FontWeight.bold))),
                        Padding(
                            padding: EdgeInsets.all(8),
                            child: Text("Product Amount ₹",
                                style: TextStyle(fontWeight: FontWeight.bold))),
                        Padding(
                            padding: EdgeInsets.all(8),
                            child: Text("Total ₹",
                                style: TextStyle(fontWeight: FontWeight.bold))),
                      ],
                    ),
                    ...staffList.map((staff) {
                      return TableRow(
                        children: [
                          Padding(
                              padding: const EdgeInsets.all(8),
                              child: Text(staff["staff_name"] ?? "-")),
                          Padding(
                              padding: const EdgeInsets.all(8),
                              child: Text("${staff["service_count"] ?? 0}")),
                          Padding(
                              padding: const EdgeInsets.all(8),
                              child: Text(
                                  "₹ ${staff["total_service_amount"] ?? 0}")),
                          Padding(
                              padding: const EdgeInsets.all(8),
                              child: Text(
                                  "₹ ${staff["total_product_amount"] ?? 0}")),
                          Padding(
                              padding: const EdgeInsets.all(8),
                              child: Text("₹ ${staff["total"] ?? 0}")),
                        ],
                      );
                    }).toList(),
                  ],
                ),
              ]),
            ],
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        child: const Icon(
          Icons.file_download,
          color: white,
        ),
        backgroundColor: primaryColor,
        onPressed: () => _showExportDialog(context),
      ),
    );
  }

  void _showExportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Text(
            'Export Data',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.blue,
            ),
          ),
          contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
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
            ],
          ),
          actionsPadding: const EdgeInsets.all(16),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildExportOption(BuildContext context,
      {required IconData icon,
      required String label,
      required Color color,
      required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 36),
            const SizedBox(height: 8),
            Text(label,
                style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(String title, List<Widget> children) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, dynamic value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value is num ? "₹ ${value.toStringAsFixed(2)}" : value.toString(),
            style: TextStyle(
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal),
          ),
        ],
      ),
    );
  }
}
