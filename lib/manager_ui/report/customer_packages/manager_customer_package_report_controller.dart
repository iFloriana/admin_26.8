// customer_package_report_controller.dart
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
import '../../../../network/model/customer_package_report_model.dart';
import '../../../../network/network_const.dart';
import '../../../../wiget/custome_snackbar.dart';

class ManagerCustomerPackageReportController extends GetxController {
  final customerPackages = <CustomerPackageReportData>[].obs;
  final filteredCustomerPackages = <CustomerPackageReportData>[].obs;
  final isLoading = true.obs;
  final searchQuery = ''.obs;
  final Rx<DateTime?> selectedDate = Rx<DateTime?>(null);
  final Rx<DateTimeRange?> selectedDateRange = Rx<DateTimeRange?>(null);
  final sortOrder = 'desc'.obs; // 'asc' or 'desc'

  @override
  void onInit() {
    super.onInit();
    getCustomerPackages();
  }

  Future<void> getCustomerPackages() async {
    isLoading.value = true;
    try {
      final loginUser = await prefs.getManagerUser();
      final response = await dioClient.getData(
        '${Apis.baseUrl}${Endpoints.customers}?salon_id=${loginUser?.manager?.salonId}',
        (json) {
          final model = CustomerPackageReportModel.fromJson(json);
          return model;
        },
      );
      if (response != null && response.data != null) {
        // Only keep customers with non-empty branch_package
        customerPackages.value = response.data!
            .where(
                (c) => c.branchPackage != null && c.branchPackage!.isNotEmpty)
            .toList();

        applyFilters();
      }
      print(
          "===========> {${Apis.baseUrl}${Endpoints.customers}?salon_id=${loginUser?.manager?.salonId}}");
    } catch (e) {
      CustomSnackbar.showError(
          'Error', 'Failed to fetch customer packages: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void applyFilters() {
    List<CustomerPackageReportData> tempPackages = customerPackages.toList();

    if (searchQuery.isNotEmpty) {
      tempPackages = tempPackages
          .where((customer) =>
              customer.fullName
                  ?.toLowerCase()
                  .contains(searchQuery.value.toLowerCase()) ??
              false)
          .toList();
    }

    // Apply single date filter (corrected local date comparison)
    if (selectedDate.value != null) {
      final filterDate = selectedDate.value!;
      tempPackages = tempPackages.where((customer) {
        if (customer.branchPackageBoughtAt == null ||
            customer.branchPackageBoughtAt!.isEmpty) return false;
        final boughtDate = DateTime.tryParse(customer.branchPackageBoughtAt!);
        if (boughtDate == null) return false;

        // Compare the year, month, and day components directly in local time
        return boughtDate.toLocal().year == filterDate.year &&
            boughtDate.toLocal().month == filterDate.month &&
            boughtDate.toLocal().day == filterDate.day;
      }).toList();
    }

    // Apply date range filter (with local date comparison)
    if (selectedDateRange.value != null) {
      final range = selectedDateRange.value!;
      tempPackages = tempPackages.where((customer) {
        if (customer.branchPackageBoughtAt == null ||
            customer.branchPackageBoughtAt!.isEmpty) return false;
        final boughtDate = DateTime.tryParse(customer.branchPackageBoughtAt!);
        if (boughtDate == null) return false;

        final localDate = boughtDate.toLocal();
        // Ensure the comparison is inclusive of the start and end dates
        return (localDate
                .isAfter(range.start.subtract(const Duration(days: 1))) &&
            localDate.isBefore(range.end.add(const Duration(days: 1))));
      }).toList();
    }

    // Sort and update
    sortPackagesList(tempPackages, sortOrder.value);
    filteredCustomerPackages.value = tempPackages;
  }

  bool isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
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

  void sortPackagesList(
      List<CustomerPackageReportData> packages, String order) {
    print('Sorting ${packages.length} packages by order: $order');

    if (order == 'asc') {
      // Sort by bought at date - oldest first
      packages.sort((a, b) {
        final aDate = a.branchPackageBoughtAt != null &&
                a.branchPackageBoughtAt!.isNotEmpty
            ? DateTime.tryParse(a.branchPackageBoughtAt!)
            : null;
        final bDate = b.branchPackageBoughtAt != null &&
                b.branchPackageBoughtAt!.isNotEmpty
            ? DateTime.tryParse(b.branchPackageBoughtAt!)
            : null;

        if (aDate == null && bDate == null) return 0;
        if (aDate == null) return 1; // null dates go to the end
        if (bDate == null) return -1;

        return aDate.compareTo(bDate);
      });
      print('Sorted in ascending order (oldest first)');
    } else {
      // Sort by bought at date - newest first
      packages.sort((a, b) {
        final aDate = a.branchPackageBoughtAt != null &&
                a.branchPackageBoughtAt!.isNotEmpty
            ? DateTime.tryParse(a.branchPackageBoughtAt!)
            : null;
        final bDate = b.branchPackageBoughtAt != null &&
                b.branchPackageBoughtAt!.isNotEmpty
            ? DateTime.tryParse(b.branchPackageBoughtAt!)
            : null;

        if (aDate == null && bDate == null) return 0;
        if (aDate == null) return 1; 
        if (bDate == null) return -1;

        return bDate.compareTo(aDate);
      });
      print('Sorted in descending order (newest first)');
    }

    // Print first few items to verify sorting
    if (packages.isNotEmpty) {
      print('First 3 items after sorting:');
      for (int i = 0; i < packages.length && i < 3; i++) {
        final customer = packages[i];
        print(
            '  ${i + 1}. ${customer.fullName} - Bought: ${customer.branchPackageBoughtAt}');
      }
    }
  }

  void sortPackages(String order) {
    sortOrder.value = order;
    sortPackagesList(filteredCustomerPackages, order);
  }

  void setSortOrder(String order) {
    sortOrder.value = order;
    print('Setting sort order to: $order');
    applyFilters();
  }

  String getStatusText(int? status) {
    switch (status) {
      case 1:
        return 'Active';
      case 0:
        return 'Inactive';
      default:
        return 'Unknown';
    }
  }

  String getFormattedDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'N/A';
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('yyyy-MM-dd').format(date);
    } catch (e) {
      return 'N/A';
    }
  }

  String getFormattedBoughtDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'N/A';
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('yyyy-MM-dd HH:mm').format(date);
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
        sheet = excel['Customer Package Reports'];
      }

      // Add headers
      final headers = [
        'Customer Name',
        'Email',
        'Package Name',
        'Package Price',
        'Bought At',
        'Valid Till',
        'Status',
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
      final dataToExport = filteredCustomerPackages.isNotEmpty
          ? filteredCustomerPackages
          : customerPackages;

      int rowIndex = 1;
      for (var customer in dataToExport) {
        for (var pkg in customer.branchPackage!) {
          sheet.cell(
              CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex))
            ..value = customer.fullName ?? '';
          sheet.cell(
              CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex))
            ..value = customer.email ?? '';
          sheet.cell(
              CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex))
            ..value = pkg.packageName ?? '';
          sheet.cell(
              CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIndex))
            ..value = pkg.packagePrice?.toString() ?? '';
          sheet.cell(
              CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: rowIndex))
            ..value = getFormattedBoughtDate(customer.branchPackageBoughtAt);
          sheet.cell(
              CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: rowIndex))
            ..value = getFormattedDate(customer.branchPackageValidTill);
          sheet.cell(
              CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: rowIndex))
            ..value = getStatusText(pkg.status);
          rowIndex++;
        }
      }

      // Try to rename the sheet by creating a new one with desired name
      try {
        // Create a new sheet with our desired name
        final newSheet = excel['Customer Package Reports'];

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
          'customer_package_reports_${DateTime.now().millisecondsSinceEpoch}.xlsx';
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

      final dataToExport = filteredCustomerPackages.isNotEmpty
          ? filteredCustomerPackages
          : customerPackages;

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
                  'Customer Package Reports',
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
                    'Email',
                    'Package Name',
                    'Package Price',
                    'Bought At',
                    'Valid Till',
                    'Status',
                  ],
                  ...dataToExport.expand((customer) {
                    return customer.branchPackage!.map((pkg) => [
                          customer.fullName ?? '',
                          customer.email ?? '',
                          pkg.packageName ?? '',
                          pkg.packagePrice?.toString() ?? '',
                          getFormattedBoughtDate(
                              customer.branchPackageBoughtAt),
                          getFormattedDate(customer.branchPackageValidTill),
                          getStatusText(pkg.status),
                        ]);
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
          'customer_package_reports_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(await pdf.save());

      await OpenFile.open(file.path);
      CustomSnackbar.showSuccess('Success', 'PDF file exported successfully!');
    } catch (e) {
      CustomSnackbar.showError('Error', 'Failed to export PDF: $e');
    }
  }
}
