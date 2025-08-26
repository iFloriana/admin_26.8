import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_template/network/model/daily_booking_model.dart';
import 'package:get/get.dart';
import '../../../../main.dart';
import '../../../../network/network_const.dart';
import '../../../../wiget/custome_snackbar.dart';
import 'package:intl/intl.dart';
import 'package:excel/excel.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:flutter/services.dart' show rootBundle;

class Dailybookingcontroller extends GetxController {
  final dailyReports = <DailyBookingData>[].obs;
  final filteredDailyReports = <DailyBookingData>[].obs; // Added for filtering
  final grandTotal = 0.0.obs;
  final isLoading = true.obs;
  final searchQuery = ''.obs; // Added for search
  final Rx<DateTime?> selectedDate =
      Rx<DateTime?>(null); // Added for date filter
  final Rx<DateTimeRange?> selectedDateRange =
      Rx<DateTimeRange?>(null); // Added for date range filter
  final sortOrder = 'desc'.obs; // 'asc' or 'desc'

  @override
  void onInit() {
    super.onInit();
    getDailyReport();
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
    applyFilters();
  }

  void selectDate(DateTime date) {
    selectedDate.value = date;
    selectedDateRange.value = null;
    applyFilters();
  }

  void selectDateRange(DateTimeRange range) {
    selectedDateRange.value = range;
    selectedDate.value = null;
    applyFilters();
  }

  void clearFilters() {
    searchQuery.value = '';
    selectedDate.value = null;
    selectedDateRange.value = null;
    sortOrder.value = 'desc';
    applyFilters();
  }

  void applyFilters() {
    List<DailyBookingData> filtered = List.from(dailyReports);

    if (searchQuery.value.isNotEmpty) {
      filtered = filtered.where((report) {
        final date = report.date?.toLowerCase() ?? '';
        final searchTerm = searchQuery.value.toLowerCase();
        return date.contains(searchTerm); // Assuming search by date string
      }).toList();
    }

    if (selectedDate.value != null) {
      filtered = filtered.where((report) {
        if (report.date == null) return false;
        final reportDate = DateTime.tryParse(report.date!);
        final filterDate = selectedDate.value!;
        return reportDate != null &&
            reportDate.year == filterDate.year &&
            reportDate.month == filterDate.month &&
            reportDate.day == filterDate.day;
      }).toList();
    }

    if (selectedDateRange.value != null) {
      filtered = filtered.where((report) {
        if (report.date == null) return false;
        final reportDate = DateTime.tryParse(report.date!);
        final filterRange = selectedDateRange.value!;
        return reportDate != null &&
            !reportDate.isBefore(filterRange.start) &&
            !reportDate.isAfter(filterRange.end);
      }).toList();
    }

    // Sort by date
    filtered.sort((a, b) {
      final dateA = DateTime.tryParse(a.date ?? '');
      final dateB = DateTime.tryParse(b.date ?? '');

      if (dateA == null && dateB == null) return 0;
      if (dateA == null) return 1;
      if (dateB == null) return -1;

      if (sortOrder.value == 'asc') {
        return dateA.compareTo(dateB);
      } else {
        return dateB.compareTo(dateA);
      }
    });

    filteredDailyReports.value = filtered;
    calculateGrandTotal();
  }

  Future<void> getDailyReport() async {
    final loginUser = await prefs.getUser();
    isLoading.value = true;
    try {
      final response = await dioClient.getData(
        '${Apis.baseUrl}${Endpoints.dailyBookings}/?salon_id=${loginUser!.salonId}',
        (json) {
          final model = DailyBookingModel.fromJson(json);
          return model;
        },
      );
      print(
          '${Apis.baseUrl}${Endpoints.dailyBookings}/?salon_id=${loginUser.salonId}');
      if (response.data != null) {
        dailyReports.value = response.data!;
        filteredDailyReports.value =
            response.data!; // Initialize filtered reports
        calculateGrandTotal();
      }
    } catch (e) {
      CustomSnackbar.showError('Error', 'Failed to fetch daily reports: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void calculateGrandTotal() {
    double total = 0;
    for (var report in filteredDailyReports) {
      // Calculate total for filtered reports
      total += report.finalAmount ?? 0;
    }
    grandTotal.value = total;
  }

  void setSortOrder(String order) {
    sortOrder.value = order;
    applyFilters();
  }

  String getFormattedDate(DailyBookingData report) {
    if (report.date == null) return 'N/A';
    try {
      final date = DateTime.parse(report.date!);
      return DateFormat('yyyy-MM-dd').format(date);
    } catch (e) {
      return 'N/A';
    }
  }

  Future<void> exportToExcel() async {
    try {
      final excel = Excel.createExcel();

      if (excel.sheets.containsKey('Sheet1')) {
        excel.delete('Sheet1');
      }

      final sheet = excel['Daily Booking Reports'];

      final headers = [
        'Date',
        'Appointments',
        'Services',
        'Used Packages',
        'Service Amount',
        'Product Amount',
        'Tax',
        'Tips',
        'Discount',
        'Membership Discount',
        'Additional Charges',
        'Cash',
        'Card',
        'UPI',
        'Final Amount',
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

      final dataToExport =
          filteredDailyReports.isNotEmpty ? filteredDailyReports : dailyReports;

      for (int i = 0; i < dataToExport.length; i++) {
        final report = dataToExport[i];
        final row = i + 1;

        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
          ..value = report.date ?? '';
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row))
          ..value = report.appointmentsCount?.toString() ?? '0';
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row))
          ..value = report.servicesCount?.toString() ?? '0';
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: row))
          ..value = report.usedPackageCount?.toString() ?? '0';
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: row))
          ..value = '₹${report.serviceAmount?.toString() ?? '0'}';
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: row))
          ..value = '₹${report.productAmount?.toString() ?? '0'}';
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: row))
          ..value = '₹${report.taxAmount?.toString() ?? '0'}';
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: row))
          ..value = '₹${report.tipsEarning?.toString() ?? '0'}';
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 8, rowIndex: row))
          ..value = '₹${report.additionalDiscount?.toString() ?? '0'}';
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 9, rowIndex: row))
          ..value = '₹${report.membershipDiscount?.toString() ?? '0'}';
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 10, rowIndex: row))
          ..value = '₹${report.additionalCharges?.toString() ?? '0'}';
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 11, rowIndex: row))
          ..value = '₹${report.paymentBreakdown?.cash?.toString() ?? '0'}';
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 12, rowIndex: row))
          ..value = '₹${report.paymentBreakdown?.card?.toString() ?? '0'}';
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 13, rowIndex: row))
          ..value = '₹${report.paymentBreakdown?.upi?.toString() ?? '0'}';
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 14, rowIndex: row))
          ..value = '₹${report.finalAmount?.toString() ?? '0'}';
      }

      final totalRow = dataToExport.length + 1;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: totalRow))
        ..value = 'Grand Total'
        ..cellStyle = CellStyle(bold: true);
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 14, rowIndex: totalRow))
        ..value = '₹${calculateTotalForExport(dataToExport).toStringAsFixed(2)}'
        ..cellStyle = CellStyle(bold: true);

      excel.setDefaultSheet('Daily Booking Reports');

      final directory = await getApplicationDocumentsDirectory();
      final fileName =
          'daily_booking_reports_${DateTime.now().millisecondsSinceEpoch}.xlsx';
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

      final dataToExport =
          filteredDailyReports.isNotEmpty ? filteredDailyReports : dailyReports;

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
                  'Daily Booking Reports',
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
                  [
                    'Date',
                    'Appointments',
                    'Services',
                    'Used Packages',
                    'Service Amount',
                    'Product Amount',
                    'Tax',
                    'Tips',
                    'Discount',
                    'Membership Discount',
                    'Additional Charges',
                    'Cash',
                    'Card',
                    'UPI',
                    'Final Amount',
                  ],
                  ...dataToExport.map((report) => [
                        report.date ?? '',
                        report.appointmentsCount?.toString() ?? '0',
                        report.servicesCount?.toString() ?? '0',
                        report.usedPackageCount?.toString() ?? '0',
                        '₹${report.serviceAmount?.toString() ?? '0'}',
                        '₹${report.productAmount?.toString() ?? '0'}',
                        '₹${report.taxAmount?.toString() ?? '0'}',
                        '₹${report.tipsEarning?.toString() ?? '0'}',
                        '₹${report.additionalDiscount?.toString() ?? '0'}',
                        '₹${report.membershipDiscount?.toString() ?? '0'}',
                        '₹${report.additionalCharges?.toString() ?? '0'}',
                        '₹${report.paymentBreakdown?.cash?.toString() ?? '0'}',
                        '₹${report.paymentBreakdown?.card?.toString() ?? '0'}',
                        '₹${report.paymentBreakdown?.upi?.toString() ?? '0'}',
                        '₹${report.finalAmount?.toString() ?? '0'}',
                      ]),
                  [
                    'Grand Total',
                    '',
                    '',
                    '',
                    '',
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
          'daily_booking_reports_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(await pdf.save());

      await OpenFile.open(file.path);
      CustomSnackbar.showSuccess('Success', 'PDF file exported successfully!');
    } catch (e) {
      CustomSnackbar.showError('Error', 'Failed to export PDF: $e');
    }
  }

  double calculateTotalForExport(List<DailyBookingData> data) {
    double total = 0;
    for (var report in data) {
      total += report.finalAmount ?? 0;
    }
    return total;
  }
}
