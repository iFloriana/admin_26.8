import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_template/main.dart';
import 'package:flutter_template/network/network_const.dart';
import 'package:flutter_template/utils/colors.dart';
import 'package:flutter_template/wiget/loading.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart' show rootBundle;
import '../../../../wiget/appbar/commen_appbar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_template/wiget/custome_snackbar.dart';
import 'package:flutter_template/manager_ui/manager_products/product_list/product_list_model.dart';

class ManagerProductDetailScreen extends StatelessWidget {
  final Product product = Get.arguments;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: CustomAppBar(
          title: product.productName,
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
              Tab(text: 'Stock History'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildProductDetailsTab(context),
            ProductStockHistoryTab(product: product),
          ],
        ),
      ),
    );
  }

  Widget _buildProductDetailsTab(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 10),
          _buildProductImage(context),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.productName,
                  style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  '₹${product.price ?? 0}',
                  style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                        color: primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 16),
                _buildProductInfoRow(
                  context,
                  'Brand',
                  product.brandId?.name ?? 'N/A',
                  Icons.sell,
                ),
                _buildProductInfoRow(
                  context,
                  'Category',
                  product.categoryId?.name ?? 'N/A',
                  Icons.category,
                ),
                _buildProductInfoRow(
                  context,
                  'Stock',
                  '${product.stock ?? 0}',
                  Icons.inventory,
                ),
                _buildProductInfoRow(
                  context,
                  'Status',
                  product.status == 1 ? 'Active' : 'Inactive',
                  product.status == 1
                      ? Icons.check_circle_outline
                      : Icons.cancel_outlined,
                  isStatus: true,
                ),
                const SizedBox(height: 24),
                Text(
                  'Description',
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  product.description,
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: Colors.grey.shade700,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductImage(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.4,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: const BorderRadius.all(
          Radius.circular(30),
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(
          Radius.circular(30),
        ),
        child: product.imageUrl != null && product.imageUrl!.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: "${Apis.pdfUrl}${product.imageUrl!}",
                fit: BoxFit.cover,
                placeholder: (context, url) =>
                    const Center(child: CustomLoadingAvatar()),
                errorWidget: (context, url, error) => const Center(
                  child: Icon(Icons.image_not_supported,
                      size: 80, color: Colors.grey),
                ),
              )
            : const Center(
                child: Icon(Icons.inventory_2, size: 80, color: Colors.grey),
              ),
      ),
    );
  }

  Widget _buildProductInfoRow(
    BuildContext context,
    String title,
    String value,
    IconData icon, {
    bool isStatus = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey, size: 24),
          const SizedBox(width: 16),
          Text(
            '$title:',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 18,
                color: isStatus
                    ? (value == 'Active' ? Colors.green : Colors.red)
                    : Colors.grey.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ProductStockHistoryController extends GetxController {
  var stockHistory = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;
  final Product product;

  ProductStockHistoryController(this.product);

  @override
  void onInit() {
    super.onInit();
    fetchStockHistory();
  }

  Future<void> fetchStockHistory() async {
    try {
      isLoading.value = true;
      final response = await dioClient.dio
          .get('${Apis.baseUrl}/products/stock-history/${product.id}');

      if (response.statusCode == 200 && response.data['history'] != null) {
        stockHistory.value = List<Map<String, dynamic>>.from(response.data['history']);
      } else {
        stockHistory.clear();
      }
    } catch (e) {
      CustomSnackbar.showError('Error', 'Failed to load stock history: $e');
      stockHistory.clear();
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
        sheet = excel['Stock History Report'];
      }

      final headers = ['Date', 'Quantity Received'];
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
      for (var record in stockHistory) {
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex))
          ..value = getFormattedDate(record['date']);
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex))
          ..value = record['quantity_received']?.toString() ?? 'N/A';
        rowIndex++;
      }

      try {
        final newSheet = excel['Stock History Report'];
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
          'stock_history_report_${DateTime.now().millisecondsSinceEpoch}.xlsx';
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(excel.encode()!);

      await OpenFile.open(file.path);
      CustomSnackbar.showSuccess('Success', 'Excel file exported successfully!');
    } catch (e) {
      CustomSnackbar.showError('Error', 'Failed to export Excel: $e');
    }
  }

  Future<void> exportToPdf() async {
    try {
      final pdf = pw.Document();
      final fontData = await rootBundle.load('assets/fonts/NotoSans-Regular.ttf');
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
                  'Stock History Report',
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
                  ['Date', 'Quantity Received'],
                  ...stockHistory.map<List<String>>((record) {
                    return <String>[
                      getFormattedDate(record['date']),
                      record['quantity_received']?.toString() ?? 'N/A',
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
          'stock_history_report_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(await pdf.save());

      await OpenFile.open(file.path);
      CustomSnackbar.showSuccess('Success', 'PDF file exported successfully!');
    } catch (e) {
      CustomSnackbar.showError('Error', 'Failed to export PDF: $e');
    }
  }
}

class ProductStockHistoryTab extends StatelessWidget {
  final Product product;

  const ProductStockHistoryTab({Key? key, required this.product})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.put(ProductStockHistoryController(product));
    return Obx(() {
      final controller = Get.find<ProductStockHistoryController>();
      return Stack(
        children: [
          controller.isLoading.value
              ? const Center(child: CustomLoadingAvatar())
              : controller.stockHistory.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.history,
                              size: 80, color: Colors.grey.shade400),
                          const SizedBox(height: 20),
                          Text(
                            'Stock history for ${product.productName}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'No stock history available',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: controller.stockHistory.length,
                      itemBuilder: (context, index) {
                        final historyItem = controller.stockHistory[index];
                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          child: ListTile(
                            title: Text(
                              'Quantity: ${historyItem['quantity_received']}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              'Date: ${controller.getFormattedDate(historyItem['date'])}',
                            ),
                          ),
                        );
                      },
                    ),
          if (!controller.isLoading.value && controller.stockHistory.isNotEmpty)
            Positioned(
              bottom: 16,
              right: 16,
              child: FloatingActionButton(
                onPressed: () {
                  _showExportDialog(context, controller);
                },
                backgroundColor: primaryColor,
                child: const Icon(Icons.download,color: white,),
              ),
            ),
        ],
      );
    });
  }

  void _showExportDialog(
      BuildContext context, ProductStockHistoryController controller) {
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