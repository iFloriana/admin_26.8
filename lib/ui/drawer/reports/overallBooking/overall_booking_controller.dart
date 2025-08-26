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
import '../../../../network/model/payment_model.dart';
import '../../../../network/network_const.dart';
import '../../../../wiget/custome_snackbar.dart';
import 'package:flutter/services.dart' show rootBundle;

class OverallBookingController extends GetxController {
  final payments = <PaymentData>[].obs;
  final filteredPayments = <PaymentData>[].obs;
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
    getPayments();
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

  Future<void> deletePayment(String paymentId) async {
    try {
      await dioClient.deleteData(
        '${Apis.baseUrl}/payments/$paymentId',
        (json) => json,
      );

      {
        CustomSnackbar.showSuccess('Success', 'Payment deleted successfully');
        // Refresh the payments list
        await getPayments();
      }
    } catch (e) {
      CustomSnackbar.showError('Error', 'Failed to delete payment: $e');
    }
  }

  void applyFilters() {
    List<PaymentData> filtered = List.from(payments);

    if (searchQuery.value.isNotEmpty) {
      filtered = filtered
          .where((payment) =>
              payment.staffTips?.any((staff) =>
                  staff.name
                      ?.toLowerCase()
                      .contains(searchQuery.value.toLowerCase()) ??
                  false) ??
              false)
          .toList();
    }

    if (selectedDate.value != null) {
      filtered = filtered.where((payment) {
        if (payment.createdAt == null) return false;
        final paymentDate = DateTime.tryParse(payment.createdAt!);
        final filterDate = selectedDate.value!;

        if (paymentDate == null) return false;

        // Normalize dates to start of day for comparison
        final paymentDateNormalized =
            DateTime(paymentDate.year, paymentDate.month, paymentDate.day);
        final filterDateNormalized =
            DateTime(filterDate.year, filterDate.month, filterDate.day);

        return paymentDateNormalized.isAtSameMomentAs(filterDateNormalized);
      }).toList();
    }

    if (selectedDateRange.value != null) {
      filtered = filtered.where((payment) {
        if (payment.createdAt == null) return false;
        final paymentDate = DateTime.tryParse(payment.createdAt!);
        final filterRange = selectedDateRange.value!;

        if (paymentDate == null) return false;

        // Normalize dates to start of day for comparison
        final paymentDateNormalized =
            DateTime(paymentDate.year, paymentDate.month, paymentDate.day);
        final startDateNormalized = DateTime(filterRange.start.year,
            filterRange.start.month, filterRange.start.day);
        final endDateNormalized = DateTime(
            filterRange.end.year, filterRange.end.month, filterRange.end.day);

        return (paymentDateNormalized.isAtSameMomentAs(startDateNormalized) ||
                paymentDateNormalized.isAfter(startDateNormalized)) &&
            (paymentDateNormalized.isAtSameMomentAs(endDateNormalized) ||
                paymentDateNormalized.isBefore(endDateNormalized));
      }).toList();
    }

    if (selectedPaymentMethod.value.isNotEmpty) {
      filtered = filtered
          .where((payment) =>
              payment.paymentMethod?.toLowerCase() ==
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

    filteredPayments.value = filtered;
    calculateGrandTotal();
  }

  Future<void> getPayments() async {
    final loginUser = await prefs.getUser();
    isLoading.value = true;
    try {
      final response = await dioClient.getData(
        '${Apis.baseUrl}/payments?salon_id=${loginUser!.salonId}',
        (json) {
          final model = PaymentModel.fromJson(json);
          return model;
        },
      );
      print("${Apis.baseUrl}/payments?salon_id=${loginUser.salonId}");
      if (response.data != null) {
        payments.value = response.data!;
        filteredPayments.value = response.data!;
        calculateGrandTotal();
      }
    } catch (e) {
      CustomSnackbar.showError('Error', 'Failed to fetch payments: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void calculateGrandTotal() {
    double total = 0;
    for (var payment in filteredPayments) {
      total += payment.finalTotal ?? 0;
    }
    grandTotal.value = total;
  }

  List<String> get uniquePaymentMethods {
    final methods = <String>{};
    for (var payment in payments) {
      if (payment.paymentMethod != null && payment.paymentMethod!.isNotEmpty) {
        methods.add(payment.paymentMethod!);
      }
    }
    return methods.toList()..sort();
  }

  void setSortOrder(String order) {
    sortOrder.value = order;
    applyFilters();
  }

  // Export to Excel
  Future<void> exportToExcel() async {
    try {
      final excel = Excel.createExcel();

      // Remove the default sheet if it exists
      if (excel.sheets.containsKey('Sheet1')) {
        excel.delete('Sheet1');
      }

      final sheet = excel['Payment Reports'];

      // Add headers
      final headers = [
        'Booking Date',
        'Inv ID',
        'Staff Name',
        'Total Service',
        'Total Service Amount',
        'Membership Discount',
        'Additional Charges',
        'Taxes',
        'Tip',
        'Additional Discount',
        'Payment Method',
        'Total Amount',
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
          filteredPayments.isNotEmpty ? filteredPayments : payments;

      for (int i = 0; i < dataToExport.length; i++) {
        final payment = dataToExport[i];
        final row = i + 1;

        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
          ..value = payment.formattedDate;
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row))
          ..value = payment.invoiceId;
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row))
          ..value = payment.staffTips?.isNotEmpty == true
              ? payment.staffTips!.first.name ?? 'N/A'
              : 'N/A';
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: row))
          ..value = payment.serviceCount?.toString() ?? '0';
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: row))
          ..value = '₹${payment.serviceAmount?.toString() ?? '0'}';
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: row))
          ..value = '₹${payment.membershipDiscount?.toString() ?? '0'}';
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: row))
          ..value = '₹${payment.additionalCharges?.toString() ?? '0'}';
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: row))
          ..value = '₹${payment.taxAmount?.toString() ?? '0'}';
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 8, rowIndex: row))
          ..value = '₹${payment.tips?.toString() ?? '0'}';
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 9, rowIndex: row))
          ..value = '₹${payment.additionalDiscount?.toString() ?? '0'}';
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 10, rowIndex: row))
          ..value = payment.paymentMethod ?? '';
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 11, rowIndex: row))
          ..value = '₹${payment.finalTotal?.toString() ?? '0'}';
      }

      // Add grand total row
      final totalRow = dataToExport.length + 1;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: totalRow))
        ..value = 'Grand Total'
        ..cellStyle = CellStyle(bold: true);
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 11, rowIndex: totalRow))
        ..value = '₹${calculateTotalForExport(dataToExport).toStringAsFixed(2)}'
        ..cellStyle = CellStyle(bold: true);

      // Set Payment Reports as the default sheet
      excel.setDefaultSheet('Payment Reports');

      // Save file
      final directory = await getApplicationDocumentsDirectory();
      final fileName =
          'payment_reports_${DateTime.now().millisecondsSinceEpoch}.xlsx';
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
          filteredPayments.isNotEmpty ? filteredPayments : payments;

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
                  'Payment Reports',
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
                    'Booking Date',
                    'Inv ID',
                    'Staff Name',
                    'Total Service',
                    'Total Service Amount',
                    'Membership Discount',
                    'Additional Charges',
                    'Taxes',
                    'Tip',
                    'Additional Discount',
                    'Payment Method',
                    'Total Amount',
                  ],
                  ...dataToExport.map((payment) => [
                        payment.formattedDate,
                        payment.invoiceId,
                        payment.staffTips?.isNotEmpty == true
                            ? payment.staffTips!.first.name ?? 'N/A'
                            : 'N/A',
                        payment.serviceCount?.toString() ?? '0',
                        '₹${payment.serviceAmount?.toString() ?? '0'}',
                        '₹${payment.membershipDiscount?.toString() ?? '0'}',
                        '₹${payment.additionalCharges?.toString() ?? '0'}',
                        '₹${payment.taxAmount?.toString() ?? '0'}',
                        '₹${payment.tips?.toString() ?? '0'}',
                        '₹${payment.additionalDiscount?.toString() ?? '0'}',
                        payment.paymentMethod ?? '',
                        '₹${payment.finalTotal?.toString() ?? '0'}',
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
          'payment_reports_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(await pdf.save());

      await OpenFile.open(file.path);
      CustomSnackbar.showSuccess('Success', 'PDF file exported successfully!');
    } catch (e) {
      CustomSnackbar.showError('Error', 'Failed to export PDF: $e');
    }
  }

  // // Export to PDF
  // Future<void> exportToPdf() async {
  //   try {
  //     final pdf = pw.Document();

  //     final dataToExport =
  //         filteredPayments.isNotEmpty ? filteredPayments : payments;

  //     pdf.addPage(
  //       pw.MultiPage(
  //         pageFormat: PdfPageFormat.a4.landscape,
  //         build: (pw.Context context) {
  //           return [
  //             pw.Header(
  //               level: 0,
  //               child: pw.Text(
  //                 'Payment Reports',
  //                 style: pw.TextStyle(
  //                   fontSize: 20,
  //                   fontWeight: pw.FontWeight.bold,
  //                 ),
  //               ),
  //             ),
  //             pw.SizedBox(height: 20),
  //             pw.Table.fromTextArray(
  //               context: context,
  //               data: <List<String>>[
  //                 // Headers
  //                 [
  //                   'Booking Date',
  //                   'Inv ID',
  //                   'Staff Name',
  //                   'Total Service',
  //                   'Total Service Amount',
  //                   'Additional Charges',
  //                   'Taxes',
  //                   'Tip',
  //                   'Additional Discount',
  //                   'Payment Method',
  //                   'Total Amount',
  //                 ],
  //                 // Data rows
  //                 ...dataToExport.map((payment) => [
  //                       payment.formattedDate,
  //                       payment.invoiceId,
  //                       payment.staffTips?.isNotEmpty == true
  //                           ? payment.staffTips!.first.name ?? 'N/A'
  //                           : 'N/A',
  //                       payment.serviceCount?.toString() ?? '0',
  //                       '₹${payment.serviceAmount?.toString() ?? '0'}',
  //                       '₹${payment.additionalCharges?.toString() ?? '0'}',
  //                       '₹${payment.taxAmount?.toString() ?? '0'}',
  //                       '₹${payment.tips?.toString() ?? '0'}',
  //                       '₹${payment.additionalDiscount?.toString() ?? '0'}',
  //                       payment.paymentMethod ?? '',
  //                       '₹${payment.finalTotal?.toString() ?? '0'}',
  //                     ]),
  //                 // Grand total row
  //                 [
  //                   'Grand Total',
  //                   '',
  //                   '',
  //                   '',
  //                   '',
  //                   '',
  //                   '',
  //                   '',
  //                   '',
  //                   '',
  //                   '₹${calculateTotalForExport(dataToExport).toStringAsFixed(2)}',
  //                 ],
  //               ],
  //               cellHeight: 30,
  //               cellAlignment: pw.Alignment.center,
  //               border: pw.TableBorder.all(),
  //             ),
  //           ];
  //         },
  //       ),
  //     );

  //     // Save file
  //     final directory = await getApplicationDocumentsDirectory();
  //     final fileName =
  //         'payment_reports_${DateTime.now().millisecondsSinceEpoch}.pdf';
  //     final file = File('${directory.path}/$fileName');
  //     await file.writeAsBytes(await pdf.save());

  //     // Open file
  //     await OpenFile.open(file.path);
  //     CustomSnackbar.showSuccess('Success', 'PDF file exported successfully!');
  //   } catch (e) {
  //     CustomSnackbar.showError('Error', 'Failed to export PDF: $e');
  //   }
  // }

  double calculateTotalForExport(List<PaymentData> data) {
    double total = 0;
    for (var payment in data) {
      total += payment.finalTotal ?? 0;
    }
    return total;
  }
}
