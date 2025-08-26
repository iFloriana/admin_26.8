import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:excel/excel.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import '../../../../main.dart';
import '../../../../network/model/order_report_model.dart';
import '../../../../network/network_const.dart';
import '../../../../wiget/custome_snackbar.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';

class OrderReportController extends GetxController {
  final orderReports = <OrderReportData>[].obs;
  final filteredOrderReports = <OrderReportData>[].obs;
  final grandTotal = 0.0.obs;
  final isLoading = true.obs;
  final searchQuery = ''.obs;
  final Rx<DateTime?> selectedDate = Rx<DateTime?>(null);
  final Rx<DateTimeRange?> selectedDateRange = Rx<DateTimeRange?>(null);
  final selectedPaymentMethod = ''.obs;
  final sortOrder = 'desc'.obs; // 'asc' or 'desc'

  @override
  void onInit() {
    super.onInit();
    getOrderReports();
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
    selectedPaymentMethod.value = '';
    sortOrder.value = 'desc';
    applyFilters();
  }

  Future<void> openPdf(String url) async {
    final uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } else {
      CustomSnackbar.showError('Error', 'Could not open PDF.');
    }
  }

  Future<void> deleteOrder(String orderId) async {
    try {
      final response = await dioClient.deleteData(
        '${Apis.baseUrl}/orders/$orderId',
        (json) => json,
      );

      if (response != null) {
        CustomSnackbar.showSuccess('Success', 'Order deleted successfully');
        // Refresh the orders list
        await getOrderReports();
      }
    } catch (e) {
      CustomSnackbar.showError('Error', 'Failed to delete order: $e');
    }
  }

  void applyFilters() {
    List<OrderReportData> filtered = List.from(orderReports);

    if (searchQuery.value.isNotEmpty) {
      filtered = filtered.where((order) {
        final customerName = order.customerId?.fullName?.toLowerCase() ?? '';
        final staffName = order.staffId?.fullName?.toLowerCase() ?? '';
        final searchTerm = searchQuery.value.toLowerCase();
        return customerName.contains(searchTerm) ||
            staffName.contains(searchTerm);
      }).toList();
    }

    if (selectedDate.value != null) {
      filtered = filtered.where((order) {
        if (order.createdAt == null) return false;
        final orderDate = DateTime.tryParse(order.createdAt!);
        final filterDate = selectedDate.value!;
        
        if (orderDate == null) return false;
        
        // Normalize dates to start of day for comparison
        final orderDateNormalized = DateTime(orderDate.year, orderDate.month, orderDate.day);
        final filterDateNormalized = DateTime(filterDate.year, filterDate.month, filterDate.day);
        
        return orderDateNormalized.isAtSameMomentAs(filterDateNormalized);
      }).toList();
    }

    if (selectedDateRange.value != null) {
      filtered = filtered.where((order) {
        if (order.createdAt == null) return false;
        final orderDate = DateTime.tryParse(order.createdAt!);
        final filterRange = selectedDateRange.value!;
        
        if (orderDate == null) return false;
        
        // Normalize dates to start of day for comparison
        final orderDateNormalized = DateTime(orderDate.year, orderDate.month, orderDate.day);
        final startDateNormalized = DateTime(filterRange.start.year, filterRange.start.month, filterRange.start.day);
        final endDateNormalized = DateTime(filterRange.end.year, filterRange.end.month, filterRange.end.day);
        
        return (orderDateNormalized.isAtSameMomentAs(startDateNormalized) || orderDateNormalized.isAfter(startDateNormalized)) &&
               (orderDateNormalized.isAtSameMomentAs(endDateNormalized) || orderDateNormalized.isBefore(endDateNormalized));
      }).toList();
    }

    if (selectedPaymentMethod.value.isNotEmpty) {
      filtered = filtered
          .where((order) =>
              order.paymentMethod?.toLowerCase() ==
              selectedPaymentMethod.value.toLowerCase())
          .toList();
    }

    // Sort by date
    filtered.sort((a, b) {
      final dateA = DateTime.tryParse(a.createdAt ?? '');
      final dateB = DateTime.tryParse(b.createdAt ?? '');

      if (dateA == null && dateB == null) return 0;
      if (dateA == null) return 1;
      if (dateB == null) return -1;

      if (sortOrder.value == 'asc') {
        return dateA.compareTo(dateB);
      } else {
        return dateB.compareTo(dateA);
      }
    });

    filteredOrderReports.value = filtered;
    calculateGrandTotal();
  }

  Future<void> getOrderReports() async {
    final loginUser = await prefs.getUser();
    isLoading.value = true;
    try {
      final response = await dioClient.getData(
        '${Apis.baseUrl}${Endpoints.orderReport}?salon_id=${loginUser!.salonId}',
        (json) {
          final model = OrderReportModel.fromJson(json);
          return model;
        },
      );
      print(
          '${Apis.baseUrl}${Endpoints.orderReport}?salon_id=${loginUser!.salonId}');
      if (response != null && response.data != null) {
        orderReports.value = response.data!;
        filteredOrderReports.value = response.data!;
        calculateGrandTotal();
      }
    } catch (e) {
      CustomSnackbar.showError('Error', 'Failed to fetch order reports: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void calculateGrandTotal() {
    double total = 0;
    for (var report in filteredOrderReports) {
      total += report.totalPrice ?? 0;
    }
    grandTotal.value = total;
  }

  List<String> get uniquePaymentMethods {
    final methods = <String>{};
    for (var order in orderReports) {
      if (order.paymentMethod != null && order.paymentMethod!.isNotEmpty) {
        methods.add(order.paymentMethod!);
      }
    }
    return methods.toList()..sort();
  }

  void setSortOrder(String order) {
    sortOrder.value = order;
    applyFilters();
  }

  String getFormattedDate(OrderReportData order) {
    if (order.createdAt == null) return 'N/A';
    try {
      final date = DateTime.parse(order.createdAt!);
      return DateFormat('yyyy-MM-dd').format(date);
    } catch (e) {
      return 'N/A';
    }
  }

  // Export to Excel
  Future<void> exportToExcel() async {
    try {
      final excel = Excel.createExcel();

      // Remove the default sheet if it exists
      if (excel.sheets.containsKey('Sheet1')) {
        excel.delete('Sheet1');
      }

      final sheet = excel['Order Reports'];

      // Add headers
      final headers = [
        'Order Code',
        'Client Name',
        'Phone',
        'Staff Name',
        'Order Date',
        'Items',
        'Payment Method',
        'Total Payment',
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

      // Add data
      final dataToExport =
          filteredOrderReports.isNotEmpty ? filteredOrderReports : orderReports;

      for (int i = 0; i < dataToExport.length; i++) {
        final order = dataToExport[i];
        final row = i + 1;

        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
          ..value = order.order_code ?? '';
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row))
          ..value = order.customerId?.fullName ?? '';
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row))
          ..value = order.customerId?.phoneNumber ?? '';
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: row))
          ..value = order.staffId?.fullName ?? 'N/A';
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: row))
          ..value = getFormattedDate(order);
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: row))
          ..value = order.productCount?.toString() ?? '0';
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: row))
          ..value = order.paymentMethod ?? '';
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: row))
          ..value = '₹${order.totalPrice?.toString() ?? '0'}';
      }

      // Add grand total row
      final totalRow = dataToExport.length + 1;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: totalRow))
        ..value = 'Grand Total'
        ..cellStyle = CellStyle(bold: true);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: totalRow))
        ..value = '₹${calculateTotalForExport(dataToExport).toStringAsFixed(2)}'
        ..cellStyle = CellStyle(bold: true);

      // Set Order Reports as the default sheet
      excel.setDefaultSheet('Order Reports');

      // Save file
      final directory = await getApplicationDocumentsDirectory();
      final fileName =
          'order_reports_${DateTime.now().millisecondsSinceEpoch}.xlsx';
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(excel.encode()!);

      // Open file
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

      // Load custom font
      final fontData =
          await rootBundle.load("assets/fonts/NotoSans-Regular.ttf");
      final ttf = pw.Font.ttf(fontData);

      final dataToExport =
          filteredOrderReports.isNotEmpty ? filteredOrderReports : orderReports;

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
                  'Order Reports',
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
                    'Order Code',
                    'Client Name',
                    'Phone',
                    'Staff Name',
                    'Order Date',
                    'Items',
                    'Payment Method',
                    'Total Payment',
                  ],
                  ...dataToExport.map((order) => [
                        order.order_code ?? '',
                        order.customerId?.fullName ?? '',
                        order.customerId?.phoneNumber ?? '',
                        order.staffId?.fullName ?? 'N/A',
                        getFormattedDate(order),
                        order.productCount?.toString() ?? '0',
                        order.paymentMethod ?? '',
                        '₹${order.totalPrice?.toString() ?? '0'}',
                      ]),
                  [
                    'Grand Total',
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
          'order_reports_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(await pdf.save());

      await OpenFile.open(file.path);
      CustomSnackbar.showSuccess('Success', 'PDF file exported successfully!');
    } catch (e) {
      CustomSnackbar.showError('Error', 'Failed to export PDF: $e');
    }
  }

  double calculateTotalForExport(List<OrderReportData> data) {
    double total = 0;
    for (var order in data) {
      total += order.totalPrice ?? 0;
    }
    return total;
  }
}
