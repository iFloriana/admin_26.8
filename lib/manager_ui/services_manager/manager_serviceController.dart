import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:flutter_template/main.dart';
import 'package:flutter_template/network/network_const.dart';
import 'package:flutter_template/wiget/custome_snackbar.dart';
import 'package:get/get.dart';
import 'package:excel/excel.dart';
import 'package:pdf/pdf.dart' as pw;
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:flutter/services.dart' show rootBundle;

class Service {
  String? id;
  String? name;
  int? duration;
  int? price;
  int? status;
  String? description;
  String? categoryId;
  String? categoryName;
  String? image_url;

  Service({
    this.id,
    this.name,
    this.duration,
    this.price,
    this.status,
    this.description,
    this.categoryId,
    this.categoryName,
    this.image_url,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['_id']?.toString(),
      name: json['name']?.toString(),
      duration: json['service_duration'] is int
          ? json['service_duration']
          : int.tryParse(json['service_duration']?.toString() ?? '0'),
      price: json['regular_price'] is int
          ? json['regular_price']
          : int.tryParse(json['regular_price']?.toString() ?? '0'),
      status: json['status'] is int
          ? json['status']
          : int.tryParse(json['status']?.toString() ?? '0'),
      description: json['description']?.toString(),
      categoryId: json['category_id'] is Map
          ? (json['category_id']['_id']?.toString())
          : json['category_id']?.toString(),
      categoryName: json['category_id'] is Map
          ? (json['category_id']['name']?.toString())
          : null,
      image_url: (json['image_url'] ?? json['image'])?.toString(),
    );
  }
}

class ManagerServicecontroller extends GetxController {
  var isActive = true.obs;
  var serviceList = <Service>[].obs;
  var filteredServiceList = <Service>[].obs;
  var isSearching = false.obs;
  var searchQuery = ''.obs;
  var selectedCategoryId = RxnString();
  var categoryOptions = <Map<String, String>>[].obs; // {'id': ..., 'name': ...}
  var editingService = Rxn<Service>();
  var isLoading = false.obs;
  var sortOrder = 'asc'.obs; // 'asc' or 'desc'

  @override
  void onInit() {
    super.onInit();
    getAllServices();
  }

  Future<void> getAllServices() async {
    final manager = await prefs.getManagerUser();
    try {
      final response = await dioClient.getData<Map<String, dynamic>>(
        '${Apis.baseUrl}${Endpoints.getBranches}${manager?.manager?.salonId}',
        (json) => json as Map<String, dynamic>,
      );

      if (response['data'] != null && response['data'] is List) {
        final List<dynamic> branches = response['data'];

        Map<String, dynamic>? selectedBranch;
        final String? branchId = manager?.manager?.branchId?.sId;
        for (final b in branches) {
          if (b is Map<String, dynamic>) {
            final id = (b['_id'] ?? b['id'])?.toString();
            if (id != null && id == branchId) {
              selectedBranch = b;
              break;
            }
          }
        }

        if (selectedBranch != null) {
          final List<dynamic> servicesJson =
              (selectedBranch['service_id'] as List?) ?? <dynamic>[];

          final services =
              servicesJson.map((e) => Service.fromJson(e)).toList();

          serviceList.value = services;
          _rebuildCategoryOptions();
          _applyFilters();
        } else {
          serviceList.clear();
          filteredServiceList.clear();
          CustomSnackbar.showError(
              'Error', 'Selected branch not found while fetching services');
        }
      } else {
        serviceList.clear();
        filteredServiceList.clear();
        CustomSnackbar.showError(
            'Error', response['message'] ?? 'Failed to fetch branches');
      }
    } catch (e) {
      serviceList.clear();
      filteredServiceList.clear();
      CustomSnackbar.showError('Error', 'Failed to fetch services: $e');
    }
  }

  void toggleSearch() {
    isSearching.value = !isSearching.value;
    if (!isSearching.value) {
      setSearchQuery('');
    }
  }

  void setSearchQuery(String query) {
    searchQuery.value = query;
    _applyFilters();
  }

  void setCategoryFilter(String? categoryId) {
    selectedCategoryId.value = categoryId;
    _applyFilters();
  }

  void clearFilters() {
    selectedCategoryId.value = null;
    setSearchQuery('');
  }

  void setSortOrder(String order) {
    sortOrder.value = order;
    _applyFilters();
  }

  void _applyFilters() {
    var list = List<Service>.from(serviceList);

    final categoryId = selectedCategoryId.value;
    if (categoryId != null && categoryId.isNotEmpty) {
      list = list.where((s) => (s.categoryId ?? '') == categoryId).toList();
    }

    final query = searchQuery.value.trim().toLowerCase();
    if (query.isNotEmpty) {
      list = list
          .where((s) => (s.name ?? '').toLowerCase().contains(query))
          .toList();
    }

    // Apply sorting by service name
    list.sort((a, b) {
      final nameA = (a.name ?? '').toLowerCase();
      final nameB = (b.name ?? '').toLowerCase();
      if (sortOrder.value == 'asc') {
        return nameA.compareTo(nameB);
      } else {
        return nameB.compareTo(nameA);
      }
    });

    filteredServiceList.value = list;
  }

  void _rebuildCategoryOptions() {
    final Map<String, String> idToName = {};
    for (final s in serviceList) {
      if ((s.categoryId ?? '').isNotEmpty) {
        idToName[s.categoryId!] = s.categoryName ?? 'Unknown';
      }
    }
    final options = idToName.entries
        .map((e) => {'id': e.key, 'name': e.value})
        .toList()
      ..sort((a, b) => (a['name'] ?? '').compareTo(b['name'] ?? ''));
    categoryOptions.value = options;
  }

  Future<void> exportToExcel() async {
    try {
      final excel = Excel.createExcel();

      if (excel.sheets.containsKey('Sheet1')) {
        excel.delete('Sheet1');
      }

      final sheet = excel['Services'];

      final headers = [
        'Name',
        'Duration (min)',
        'Price',
        'Status',
        'Category',
      ];

      for (int i = 0; i < headers.length; i++) {
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0))
          ..value = headers[i]
          ..cellStyle = CellStyle(bold: true);
      }

      final List<Service> dataToExport = filteredServiceList.isNotEmpty ||
              searchQuery.isNotEmpty ||
              (selectedCategoryId.value ?? '').isNotEmpty
          ? filteredServiceList
          : serviceList;

      for (int i = 0; i < dataToExport.length; i++) {
        final s = dataToExport[i];
        final row = i + 1;
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
          ..value = s.name ?? '';
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row))
          ..value = s.duration ?? 0;
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row))
          ..value = "₹ ${s.price}" ?? 0;
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: row))
          ..value = (s.status == 1) ? 'Active' : 'Deactive';
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: row))
          ..value = s.categoryName ?? '';
      }

      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'services_${DateTime.now().millisecondsSinceEpoch}.xlsx';
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(excel.encode()!);

      await OpenFile.open(file.path);
      CustomSnackbar.showSuccess('Success', 'Excel file exported successfully');
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

      final List<Service> dataToExport = filteredServiceList.isNotEmpty ||
              searchQuery.isNotEmpty ||
              (selectedCategoryId.value ?? '').isNotEmpty
          ? filteredServiceList
          : serviceList;

      pdf.addPage(
        pw.MultiPage(
          pageFormat: pw.PdfPageFormat.a4.portrait,
          margin: pw.EdgeInsets.all(20),
          theme: pw.ThemeData.withFont(
            base: ttf,
            bold: ttf,
          ),
          build: (context) => [
            pw.Center(
              child: pw.Text(
                'Services',
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 12),
            pw.Table.fromTextArray(
              headers: const [
                'Name',
                'Duration (min)',
                'Price',
                'Status',
                'Category',
              ],
              data: dataToExport
                  .map((s) => [
                        s.name ?? '',
                        (s.duration ?? 0).toString(),
                        ("₹${s.price}" ?? 0).toString(),
                        (s.status == 1) ? 'Active' : 'Deactive',
                        s.categoryName ?? '',
                      ])
                  .toList(),
              border: pw.TableBorder.all(),
              cellPadding: pw.EdgeInsets.all(6),
            ),
          ],
        ),
      );

      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'services_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(await pdf.save());

      await OpenFile.open(file.path);
      CustomSnackbar.showSuccess('Success', 'PDF file exported successfully');
    } catch (e) {
      CustomSnackbar.showError('Error', 'Failed to export PDF: $e');
    }
  }
}
