// customer_membership_report_controller.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:excel/excel.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import '../../../../main.dart';
import '../../../../network/network_const.dart';
import '../../../../wiget/custome_snackbar.dart';

class ManagerCustomerMembershipReportController extends GetxController {
  final customerMemberships = <Map<String, dynamic>>[].obs;
  final filteredCustomerMemberships = <Map<String, dynamic>>[].obs;
  final isLoading = true.obs;
  final searchQuery = ''.obs;
  final Rx<DateTime?> selectedDate = Rx<DateTime?>(null);
  final Rx<DateTimeRange?> selectedDateRange = Rx<DateTimeRange?>(null);
  final sortOrder = 'desc'.obs;

  @override
  void onInit() {
    super.onInit();
    getCustomerMemberships();
  }

  Future<void> getCustomerMemberships() async {
    isLoading.value = true;
    try {
      final loginUser = await prefs.getManagerUser();
      final response = await dioClient.getData(
        '${Apis.baseUrl}${Endpoints.customers}?salon_id=${loginUser!.manager!.salonId}',
        (json) => json,
      );
      if (response != null && response['data'] != null) {
        // Only keep customers with non-empty package_and_membership
        customerMemberships.value = (response['data'] as List)
            .cast<Map<String, dynamic>>()
            .where((c) =>
                (c['package_and_membership'] as List?)?.isNotEmpty ?? false)
            .toList();

        applyFilters();
      }
      print(
          "===========> {${Apis.baseUrl}${Endpoints.customers}?salon_id=${loginUser!.manager!.salonId}}");
    } catch (e) {
      CustomSnackbar.showError(
          'Error', 'Failed to fetch customer memberships: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void applyFilters() {
    List<Map<String, dynamic>> temp = [];

    for (var customer in customerMemberships) {
      var items = (customer['package_and_membership'] as List?)
              ?.cast<Map<String, dynamic>>() ??
          [];

      items =
          items.where((item) => item.containsKey('branch_membership')).toList();

      if (searchQuery.isNotEmpty) {
        final name = (customer['full_name'] as String?)?.toLowerCase() ?? '';
        if (!name.contains(searchQuery.value.toLowerCase())) continue;
      }

      // Apply single date filter
      if (selectedDate.value != null) {
        final filterDate = selectedDate.value!;
        items = items.where((item) {
          final dateStr = item['date'] as String?;
          if (dateStr == null || dateStr.isEmpty) return false;
          final boughtDate = DateTime.tryParse(dateStr);
          if (boughtDate == null) return false;
          final localDate = boughtDate.toLocal();
          return localDate.year == filterDate.year &&
              localDate.month == filterDate.month &&
              localDate.day == filterDate.day;
        }).toList();
      }

      // Apply date range filter
      if (selectedDateRange.value != null) {
        final range = selectedDateRange.value!;
        items = items.where((item) {
          final dateStr = item['date'] as String?;
          if (dateStr == null || dateStr.isEmpty) return false;
          final boughtDate = DateTime.tryParse(dateStr);
          if (boughtDate == null) return false;
          final localDate = boughtDate.toLocal();
          return localDate
                  .isAfter(range.start.subtract(const Duration(days: 1))) &&
              localDate.isBefore(range.end.add(const Duration(days: 1)));
        }).toList();
      }

      if (items.isNotEmpty) {
        var filteredCustomer = Map<String, dynamic>.from(customer);
        filteredCustomer['package_and_membership'] = items;
        temp.add(filteredCustomer);
      }
    }

    // Sort and update
    sortMembershipsList(temp, sortOrder.value);
    filteredCustomerMemberships.value = temp;
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
    sortOrder.value = 'desc'; // Reset sort order
    applyFilters();
  }

  void sortMembershipsList(
      List<Map<String, dynamic>> memberships, String order) {
    print('Sorting ${memberships.length} memberships by order: $order');

    memberships.sort((a, b) {
      final aDates = (a['package_and_membership'] as List)
          .map((item) => DateTime.tryParse((item['date'] as String?) ?? ''))
          .where((date) => date != null)
          .cast<DateTime>()
          .toList();

      final bDates = (b['package_and_membership'] as List)
          .map((item) => DateTime.tryParse((item['date'] as String?) ?? ''))
          .where((date) => date != null)
          .cast<DateTime>()
          .toList();

      if (aDates.isEmpty && bDates.isEmpty) return 0;
      if (aDates.isEmpty) return 1;
      if (bDates.isEmpty) return -1;

      DateTime aCompare = order == 'asc'
          ? aDates.reduce((a, b) => a.isBefore(b) ? a : b)
          : aDates.reduce((a, b) => a.isAfter(b) ? a : b);
      DateTime bCompare = order == 'asc'
          ? bDates.reduce((a, b) => a.isBefore(b) ? a : b)
          : bDates.reduce((a, b) => a.isAfter(b) ? a : b);

      return order == 'asc'
          ? aCompare.compareTo(bCompare)
          : bCompare.compareTo(aCompare);
    });

    // Print first few items to verify sorting
    if (memberships.isNotEmpty) {
      print('First 3 items after sorting:');
      for (int i = 0; i < memberships.length && i < 3; i++) {
        final customer = memberships[i];
        print(
            '  ${i + 1}. ${customer['full_name']} - Example Date: ${(customer['package_and_membership'] as List).first['date']}');
      }
    }
  }

  void setSortOrder(String order) {
    sortOrder.value = order;
    print('Setting sort order to: $order');
    applyFilters();
  }

  String getFormattedDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'N/A';
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('M/d/yyyy').format(date);
    } catch (e) {
      return 'N/A';
    }
  }

  // Export to Excel
  Future<void> exportToExcel() async {
    try {
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
        sheet = excel['Customer Membership Reports'];
      }

      // Add headers
      final headers = [
        'Customer Name',
        'Membership Name',
        'Subscription Plan',
        'Discount',
        'Discount Type',
        'Membership Amount',
        'Start Date',
        'Expiry Date',
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
      final dataToExport = filteredCustomerMemberships.isNotEmpty
          ? filteredCustomerMemberships
          : customerMemberships;

      int rowIndex = 1;
      for (var customer in dataToExport) {
        for (var item in (customer['package_and_membership'] as List)
            .cast<Map<String, dynamic>>()) {
          final details = item['branch_membership'];
          sheet.cell(
              CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex))
            ..value = customer['full_name'] ?? '';
          sheet.cell(
              CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex))
            ..value = details['membership_name'] ?? '';
          sheet.cell(
              CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex))
            ..value = details['subscription_plan'] ?? '';
          sheet.cell(
              CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIndex))
            ..value = details['discount'].toString();
          sheet.cell(
              CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: rowIndex))
            ..value = details['discount_type'] ?? '';
          sheet.cell(
              CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: rowIndex))
            ..value = details['membership_amount'].toString();
          sheet.cell(
              CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: rowIndex))
            ..value = getFormattedDate(item['date']);
          sheet.cell(
              CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: rowIndex))
            ..value = getFormattedDate(item['expiry_date']);
          rowIndex++;
        }
      }

      // Try to rename the sheet by creating a new one with desired name
      try {
        // Create a new sheet with our desired name
        final newSheet = excel['Customer Membership Reports'];

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
          'customer_membership_reports_${DateTime.now().millisecondsSinceEpoch}.xlsx';
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

      final dataToExport = filteredCustomerMemberships.isNotEmpty
          ? filteredCustomerMemberships
          : customerMemberships;

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
                  'Customer Membership Reports',
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
                    'Customer Name',
                    'Membership Name',
                    'Subscription Plan',
                    'Discount',
                    'Discount Type',
                    'Membership Amount',
                    'Start Date',
                    'Expiry Date',
                  ],
                  ...dataToExport.expand((customer) {
                    return (customer['package_and_membership'] as List)
                        .cast<Map<String, dynamic>>()
                        .map<List<String>>((item) {
                      final details = item['branch_membership'];
                      return <String>[
                        customer['full_name'] ?? '',
                        details['membership_name'] ?? '',
                        details['subscription_plan'] ?? '',
                        details['discount'].toString(),
                        details['discount_type'] ?? '',
                        details['membership_amount'].toString(),
                        getFormattedDate(item['date']),
                        getFormattedDate(item['expiry_date']),
                      ];
                    });
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
          'customer_membership_reports_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(await pdf.save());

      await OpenFile.open(file.path);
      CustomSnackbar.showSuccess('Success', 'PDF file exported successfully!');
    } catch (e) {
      CustomSnackbar.showError('Error', 'Failed to export PDF: $e');
    }
  }

}
