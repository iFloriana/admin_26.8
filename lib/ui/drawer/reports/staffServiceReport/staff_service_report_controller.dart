import 'dart:io';
import 'package:get/get.dart';
import 'package:excel/excel.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../../../../main.dart';
import '../../../../network/model/staff_service_report_model.dart';
import '../../../../network/network_const.dart';
import '../../../../wiget/custome_snackbar.dart';

class StaffServiceReportController extends GetxController {
  final staffServiceReports = <StaffServiceReportData>[].obs;
  final filteredStaffServiceReports = <StaffServiceReportData>[].obs;
  final grandTotal = 0.0.obs;
  final isLoading = true.obs;
  final searchQuery = ''.obs;
  final sortOrder = 'desc'.obs; // 'asc' or 'desc'

  @override
  void onInit() {
    super.onInit();
    getStaffServiceReports();
  }

  void getStaffServiceReports() async {
    final loginUser = await prefs.getUser();
    isLoading.value = true;
    try {
      final response = await dioClient.getData(
        '${Apis.baseUrl}${Endpoints.staffServiceReport}?salon_id=${loginUser!.salonId}',
        (json) {
          final model = StaffServiceReportModel.fromJson(json);
          return model;
        },
      );
      if (response != null && response.data != null) {
        staffServiceReports.value = response.data!;
        applyFilters();
      }
    } catch (e) {
      CustomSnackbar.showError(
          'Error', 'Failed to fetch staff service reports: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void applyFilters() {
    List<StaffServiceReportData> tempReports = staffServiceReports.toList();

    if (searchQuery.isNotEmpty) {
      tempReports = tempReports
          .where((report) =>
              report.staffName
                  ?.toLowerCase()
                  .contains(searchQuery.value.toLowerCase()) ??
              false)
          .toList();
    }

    // Apply sorting
    sortReports(sortOrder.value);

    filteredStaffServiceReports.value = tempReports;
    calculateGrandTotal();
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
    applyFilters();
  }

  void clearFilters() {
    searchQuery.value = '';
    sortOrder.value = 'desc'; // Reset sort order
    applyFilters();
  }

  void sortReports(String order) {
    sortOrder.value = order;
    if (order == 'asc') {
      filteredStaffServiceReports.sort((a, b) => (a.sId ?? '')
          .compareTo(b.sId ?? '')); // Assuming _id is a sortable string
    } else {
      filteredStaffServiceReports
          .sort((a, b) => (b.sId ?? '').compareTo(a.sId ?? ''));
    }
    calculateGrandTotal();
  }

  void calculateGrandTotal() {
    double total = 0;
    for (var report in filteredStaffServiceReports) {
      total += report.totalEarning ?? 0;
    }
    grandTotal.value = total;
  }

  Future<void> exportToExcel() async {
    try {
      // Create Excel file
      final excel = Excel.createExcel();

      // Get the default sheet and work with it
      final sheetNames = excel.tables.keys.toList();
      Sheet sheet;

      if (sheetNames.isNotEmpty) {
        // Use the first available sheet (default sheet)
        final defaultSheetName = sheetNames.first;
        sheet = excel.tables[defaultSheetName]!;

        // Clear the default sheet content by overwriting cells
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
        // Create new sheet if none exists
        sheet = excel['Staff Service Reports'];
      }

      // Add our data to the sheet
      sheet.appendRow([
        'Staff Name',
        'Service Count',
        'Commission',
        'Tips',
        'Total Earning',
      ]);

      for (var report in filteredStaffServiceReports) {
        sheet.appendRow([
          report.staffName,
          report.services?.toString() ?? '0',
          report.commissionEarn?.toString() ?? '0.0',
          report.tipsEarn?.toString() ?? '0.0',
          report.totalEarning,
        ]);
      }

      sheet.appendRow([
        'Grand Total',
        '',
        '',
        '',
        grandTotal.value.toStringAsFixed(2),
      ]);

      // Try to rename the sheet by creating a new one with desired name
      try {
        // Create a new sheet with our desired name
        final newSheet = excel['Staff Service Reports'];

        // Copy all data from the default sheet to the new sheet
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

        // Delete the original default sheet
        if (sheetNames.isNotEmpty) {
          excel.delete(sheetNames.first);
        }
      } catch (e) {
        // If renaming fails, continue with the default sheet
        print('Could not rename sheet: $e');
      }

      final directory = await getApplicationDocumentsDirectory();
      final fileName =
          'staff_service_reports_${DateTime.now().millisecondsSinceEpoch}.xlsx';
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
            final dataToExport = filteredStaffServiceReports;
            return [
              pw.Center(
                child: pw.Text('Staff Service Report',
                    style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                        font: ttf)),
              ),
              pw.SizedBox(height: 20),
              pw.Table.fromTextArray(
                headerStyle:
                    pw.TextStyle(fontWeight: pw.FontWeight.bold, font: ttf),
                cellStyle: pw.TextStyle(font: ttf),
                headers: <String>[
                  'Staff Name',
                  'Service Count',
                  'Commission',
                  'Tips',
                  'Total Earning',
                ],
                data: <List<String>>[
                  ...dataToExport.map((report) => [
                        report.staffName ?? 'N/A',
                        report.services?.toString() ?? '0',
                        '₹${report.commissionEarn?.toString() ?? '0.0'}',
                        '₹${report.tipsEarn?.toString() ?? '0.0'}',
                        '₹${report.totalEarning?.toString() ?? '0.0'}',
                      ]),
                  [
                    'Grand Total',
                    '',
                    '',
                    '',
                    '₹${calculateTotalForExport(dataToExport).toStringAsFixed(2)}',
                  ],
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
          'staff_service_reports_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(await pdf.save());

      await OpenFile.open(file.path);
      CustomSnackbar.showSuccess('Success', 'PDF file exported successfully!');
    } catch (e) {
      CustomSnackbar.showError('Error', 'Failed to export PDF: $e');
    }
  }

  double calculateTotalForExport(List<StaffServiceReportData> data) {
    double total = 0;
    for (var report in data) {
      total += report.totalEarning ?? 0;
    }
    return total;
  }
}
