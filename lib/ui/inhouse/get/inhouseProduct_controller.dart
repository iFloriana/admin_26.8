import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:excel/excel.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../../../main.dart';
import '../../../network/dio.dart';
import '../../../network/network_const.dart';
import '../../../wiget/custome_snackbar.dart';
import '../../../network/model/inhouseProduct_model.dart';

class InhouseproductController extends GetxController {
  RxList<InhouseProductData> inhouseProducts = <InhouseProductData>[].obs;
  RxList<Map<String, dynamic>> filteredProducts = <Map<String, dynamic>>[].obs;
  RxBool isLoading = true.obs;
  RxString searchQuery = ''.obs;
  RxString sortOrder = 'desc'.obs; // 'asc' or 'desc'
  DateTime? selectedDate;
  DateTimeRange? selectedDateRange;

  @override
  void onInit() {
    super.onInit();
    getInhouseProductUseageData();
  }

  void getInhouseProductUseageData() async {
    try {
      isLoading.value = true;
      final loginUser = await prefs.getUser();

      if (loginUser == null) {
        CustomSnackbar.showError('Error', 'User not logged in');
        return;
      }

      final response = await dioClient.getData<Map<String, dynamic>>(
        '${Apis.baseUrl}${Endpoints.inHouseProduct}?salon_id=${loginUser.salonId}',
        (json) => json,
      );
      print(
          "==============> ${Apis.baseUrl}${Endpoints.inHouseProduct}?salon_id=${loginUser.salonId}");
      if (response != null && response['data'] != null) {
        final List<dynamic> dataList = response['data'];
        inhouseProducts.value =
            dataList.map((json) => InhouseProductData.fromJson(json)).toList();
        print("Inhouse products loaded: ${inhouseProducts.length}");
        applyFilters();
      } else {
        inhouseProducts.value = [];
        print("No inhouse products found");
        applyFilters();
      }
    } catch (e) {
      print("Error fetching inhouse products: $e");
      CustomSnackbar.showError('Error', 'Failed to fetch data: $e');
      inhouseProducts.value = [];
      applyFilters();
    } finally {
      isLoading.value = false;
    }
  }

  // Search functionality
  void updateSearchQuery(String query) {
    searchQuery.value = query;
    applyFilters();
  }

  // Date filtering
  void selectDate(DateTime date) {
    selectedDate = date;
    applyFilters();
  }

  void selectDateRange(DateTimeRange range) {
    selectedDateRange = range;
    applyFilters();
  }

  // Sorting
  void setSortOrder(String order) {
    print('Setting sort order to: $order');
    sortOrder.value = order;

    // Force refresh the data and apply filters
    if (inhouseProducts.isNotEmpty) {
      applyFilters();

      // Show user feedback
      final sortText = order == 'asc' ? 'Oldest Updated' : 'Newest Updated';
      CustomSnackbar.showSuccess(
          'Sort Updated', 'Products sorted by $sortText');
    } else {
      // If no data, refresh from server
      getInhouseProductUseageData();
    }
  }

  // Clear all filters
  void clearFilters() {
    searchQuery.value = '';
    selectedDate = null;
    selectedDateRange = null;
    sortOrder.value = 'desc';
    applyFilters();

    // Show user feedback
    CustomSnackbar.showSuccess(
        'Filters Cleared', 'All filters have been reset');
  }

  // Apply all filters and sorting
  void applyFilters() {
    List<Map<String, dynamic>> grouped = getGroupedProducts();

    // Apply search filter
    if (searchQuery.value.isNotEmpty) {
      grouped = grouped.where((product) {
        final productNames = product['product_names'] as List<String>;
        final staff = product['staff'] as String;
        final branch = product['branch'] as String;

        return productNames.any((name) =>
                name.toLowerCase().contains(searchQuery.value.toLowerCase())) ||
            staff.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
            branch.toLowerCase().contains(searchQuery.value.toLowerCase());
      }).toList();
    }

    // Apply date filter
    if (selectedDate != null) {
      final selectedDateStr = formatDate(selectedDate);
      grouped = grouped.where((product) {
        return product['used_on'] == selectedDateStr;
      }).toList();
    }

    if (selectedDateRange != null) {
      grouped = grouped.where((product) {
        final usedOn = product['used_on'] as String;
        if (usedOn == 'N/A') return false;

        try {
          final parts = usedOn.split('-');
          if (parts.length == 3) {
            final productDate = DateTime(
              int.parse(parts[2]), // year
              int.parse(parts[1]), // month
              int.parse(parts[0]), // day
            );
            return productDate.isAfter(selectedDateRange!.start
                    .subtract(const Duration(days: 1))) &&
                productDate.isBefore(
                    selectedDateRange!.end.add(const Duration(days: 1)));
          }
        } catch (e) {
          print('Error parsing date: $e');
        }
        return false;
      }).toList();
    }

    // Apply sorting
    print('Applying sort order: ${sortOrder.value}');
    print('Total items to sort: ${grouped.length}');

    if (grouped.isNotEmpty) {
      grouped.sort((a, b) {
        final dateA = a['updated_on'] as String;
        final dateB = b['updated_on'] as String;

        print('Comparing updated_on dates: $dateA vs $dateB');

        // Handle N/A values
        if (dateA == 'N/A' && dateB == 'N/A') return 0;
        if (dateA == 'N/A') return 1;
        if (dateB == 'N/A') return -1;

        try {
          // Parse relative time strings like "2 days ago", "1 hour ago", etc.
          final timeA = parseRelativeTime(dateA);
          final timeB = parseRelativeTime(dateB);

          if (timeA != null && timeB != null) {
            final comparison = timeA.compareTo(timeB);
            final result = sortOrder.value == 'asc' ? comparison : -comparison;
            print(
                'Updated time comparison result: $result (${sortOrder.value})');
            return result;
          } else {
            // Fall back to string comparison if parsing fails
            print('Failed to parse relative time, using string comparison');
            final comparison = dateA.compareTo(dateB);
            return sortOrder.value == 'asc' ? comparison : -comparison;
          }
        } catch (e) {
          print('Error sorting updated_on dates: $e');
          // Fall back to string comparison on error
          final comparison = dateA.compareTo(dateB);
          return sortOrder.value == 'asc' ? comparison : -comparison;
        }
      });

      print('Sorting completed. First few items:');
      for (int i = 0; i < (grouped.length < 3 ? grouped.length : 3); i++) {
        print('Item $i: ${grouped[i]['updated_on']}');
      }
    } else {
      print('No items to sort');
    }

    filteredProducts.value = grouped;
  }

  // Export functionality
  Future<void> exportToExcel() async {
    try {
      final excel = Excel.createExcel();

      if (excel.sheets.containsKey('Sheet1')) {
        excel.delete('Sheet1');
      }

      final sheet = excel['In-House Product Usage'];

      final headers = [
        'Sr. No.',
        'Product Names',
        'Quantities',
        'Staff',
        'Branch',
        'Used On',
        'Updated On',
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
          filteredProducts.isNotEmpty ? filteredProducts : getGroupedProducts();

      for (int i = 0; i < dataToExport.length; i++) {
        final product = dataToExport[i];
        final row = i + 1;

        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
          ..value = product['sr_no']?.toString() ?? '';
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row))
          ..value =
              (product['product_names'] as List<String>?)?.join(', ') ?? '';
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row))
          ..value = (product['quantities'] as List<String>?)?.join(', ') ?? '';
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: row))
          ..value = product['staff']?.toString() ?? '';
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: row))
          ..value = product['branch']?.toString() ?? '';
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: row))
          ..value = product['used_on']?.toString() ?? '';
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: row))
          ..value = product['updated_on']?.toString() ?? '';
      }

      excel.setDefaultSheet('In-House Product Usage');

      final directory = await getApplicationDocumentsDirectory();
      final fileName =
          'inhouse_product_usage_${DateTime.now().millisecondsSinceEpoch}.xlsx';
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
          filteredProducts.isNotEmpty ? filteredProducts : getGroupedProducts();

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
                  'In-House Product Usage Report',
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
                    'Sr. No.',
                    'Product Names',
                    'Quantities',
                    'Staff',
                    'Branch',
                    'Used On',
                    'Updated On',
                  ],
                  ...dataToExport.map((product) => [
                        product['sr_no']?.toString() ?? '',
                        (product['product_names'] as List<String>?)
                                ?.join(', ') ??
                            '',
                        (product['quantities'] as List<String>?)?.join(', ') ??
                            '',
                        product['staff']?.toString() ?? '',
                        product['branch']?.toString() ?? '',
                        product['used_on']?.toString() ?? '',
                        product['updated_on']?.toString() ?? '',
                      ]),
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
          'inhouse_product_usage_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(await pdf.save());

      await OpenFile.open(file.path);
      CustomSnackbar.showSuccess('Success', 'PDF file exported successfully!');
    } catch (e) {
      CustomSnackbar.showError('Error', 'Failed to export PDF: $e');
    }
  }

  // Delete inhouse product
  Future<void> deleteInhouseProduct(String productId) async {
    try {
      final response = await dioClient.deleteData<Map<String, dynamic>>(
        '${Apis.baseUrl}${Endpoints.inHouseProduct}/$productId',
        (json) => json,
      );

      if (response != null) {
        CustomSnackbar.showSuccess('Success', 'Product deleted successfully');
        getInhouseProductUseageData(); // Refresh the list
      }
    } catch (e) {
      CustomSnackbar.showError('Error', 'Failed to delete product: $e');
    }
  }

  // Format date to DD-MM-YYYY
  String formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    try {
      return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
    } catch (e) {
      return 'N/A';
    }
  }

  // Get relative time (e.g., "21 hours ago", "a day ago")
  String getRelativeTime(DateTime? date) {
    if (date == null) return 'N/A';
    try {
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays > 0) {
        return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return 'N/A';
    }
  }

  // Parse relative time string back to DateTime for sorting
  DateTime? parseRelativeTime(String relativeTime) {
    if (relativeTime == 'N/A' || relativeTime.isEmpty) return null;

    try {
      final now = DateTime.now();

      if (relativeTime == 'Just now') {
        return now;
      }

      // Parse patterns like "2 days ago", "1 hour ago", "30 minutes ago"
      final parts = relativeTime.toLowerCase().split(' ');
      if (parts.length >= 3 && parts.last == 'ago') {
        final amount = int.tryParse(parts[0]);
        final unit = parts[1];

        if (amount != null) {
          switch (unit) {
            case 'day':
            case 'days':
              return now.subtract(Duration(days: amount));
            case 'hour':
            case 'hours':
              return now.subtract(Duration(hours: amount));
            case 'minute':
            case 'minutes':
              return now.subtract(Duration(minutes: amount));
            default:
              return null;
          }
        }
      }

      return null;
    } catch (e) {
      print('Error parsing relative time: $e');
      return null;
    }
  }

  // Debug method to test sorting
  void debugSorting() {
    print('=== DEBUG SORTING ===');
    print('Current sort order: ${sortOrder.value}');
    print('Total products: ${inhouseProducts.length}');
    print('Filtered products: ${filteredProducts.length}');

    if (filteredProducts.isNotEmpty) {
      print('First 3 items:');
      for (int i = 0;
          i < (filteredProducts.length < 3 ? filteredProducts.length : 3);
          i++) {
        print(
            '  Item $i: used_on=${filteredProducts[i]['used_on']}, updated_on=${filteredProducts[i]['updated_on']}');
      }
    }
    print('=== END DEBUG ===');
  }

  // Get full product name with variant info
  String getFullProductName(ProductItem productItem) {
    String name = productItem.product?.productName ?? 'Unknown Product';
    if (productItem.variant != null &&
        productItem.variant!.combination != null &&
        productItem.variant!.combination!.isNotEmpty) {
      final variantInfo = productItem.variant!.combination!
          .map((c) => c.variationValue ?? '')
          .where((value) => value.isNotEmpty)
          .join(' - ');
      if (variantInfo.isNotEmpty) {
        name += ' ($variantInfo)';
      }
    }
    return name;
  }

  // Group products by staff, branch, and dates
  List<Map<String, dynamic>> getGroupedProducts() {
    if (inhouseProducts.isEmpty) return [];

    // Group products by staff_id, branch_id, createdAt, and updatedAt
    Map<String, List<InhouseProductData>> groupedMap = {};

    for (var productData in inhouseProducts) {
      final staffId = productData.staff?.id ?? 'N/A';
      final branchId = productData.branch?.id ?? 'N/A';
      final createdAt = productData.createdAt?.toString() ?? '';
      final updatedAt = productData.updatedAt?.toString() ?? '';

      final key = '$staffId|$branchId|$createdAt|$updatedAt';

      if (!groupedMap.containsKey(key)) {
        groupedMap[key] = [];
      }
      groupedMap[key]!.add(productData);
    }

    // Convert grouped map to list with grouped data
    List<Map<String, dynamic>> groupedList = [];
    int srNo = 1;

    groupedMap.forEach((key, products) {
      if (products.isNotEmpty) {
        final firstProduct = products.first;

        // Get product names and quantities
        List<String> productNames = [];
        List<String> quantities = [];
        List<InhouseProductData> allProducts = [];

        for (var productData in products) {
          for (var productItem in productData.product) {
            if (productItem.product != null) {
              productNames.add(getFullProductName(productItem));
              quantities.add(productItem.quantity?.toString() ?? 'N/A');
            }
          }
          allProducts.add(productData);
        }

        groupedList.add({
          'sr_no': srNo++,
          'product_names': productNames,
          'quantities': quantities,
          'staff': firstProduct.staff?.fullName ?? 'N/A',
          'branch': firstProduct.branch?.name ?? 'N/A',
          'used_on': formatDate(firstProduct.createdAt),
          'updated_on': getRelativeTime(firstProduct.updatedAt),
          'products': allProducts,
        });
      }
    });

    return groupedList;
  }
}
