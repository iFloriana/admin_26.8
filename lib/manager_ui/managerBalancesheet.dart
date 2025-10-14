import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_template/main.dart';
import 'dart:convert';
import 'dart:io';
import 'package:excel/excel.dart';
import 'package:flutter_template/manager_ui/drawer/drawerscreen.dart';
import 'package:flutter_template/wiget/appbar/commen_appbar.dart';
import 'package:flutter_template/wiget/loading.dart';
import 'package:pdf/pdf.dart' as pw;
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:flutter/services.dart';
import 'package:flutter_template/network/network_const.dart';
import '../../../wiget/custome_snackbar.dart';
import 'package:flutter_template/utils/colors.dart';

class managerBalancesheet extends StatefulWidget {
  const managerBalancesheet({super.key});

  @override
  State<managerBalancesheet> createState() => _managerBalancesheetState();
}

class _managerBalancesheetState extends State<managerBalancesheet> {
  List<Map<String, dynamic>> entries = [];
  bool isLoading = true;
  String errorMessage = '';
  DateTime startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime endDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    var getdata = await prefs.getManagerUser();
    final formattedStart = startDate.toIso8601String().split('T')[0];
    final formattedEnd = endDate.toIso8601String().split('T')[0];
    String url =
        '${Apis.baseUrl}/expenses/daily-summary?start_date=$formattedStart&end_date=$formattedEnd&salon_id=${getdata?.manager?.salonId}&branch_id=${getdata?.manager?.branchId?.sId}';
    try {
      final response = await dioClient.dio.get(url);
      if (response.statusCode == 200) {
        final json = response.data;
        if (json['success'] == true) {
          final data = json['data'] as Map<String, dynamic>;
          List<Map<String, dynamic>> allEntries = [];
          data.forEach((dateKey, list) {
            for (var item in list as List<dynamic>) {
              final entry = Map<String, dynamic>.from(item as Map);
              entry['display_date'] = dateKey;
              allEntries.add(entry);
            }
          });
          allEntries
              .sort((a, b) => a['display_date'].compareTo(b['display_date']));
          setState(() {
            entries = allEntries;
            isLoading = false;
          });
          return;
        }
      }
      throw Exception('Failed to load data');
    } catch (e) {
      setState(() {
        errorMessage = 'Error: $e';
        isLoading = false;
      });
    }
  }

  Future<void> _pickDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDateRange: DateTimeRange(start: startDate, end: endDate),
    );
    if (picked != null) {
      setState(() {
        startDate = picked.start;
        endDate = picked.end;
        isLoading = true;
        entries = [];
        errorMessage = '';
      });
      await fetchData();
    }
  }

  void _showExportDialog(BuildContext context) {
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
                      exportToExcel();
                    },
                  ),
                  _buildExportOption(
                    context,
                    icon: Icons.picture_as_pdf,
                    label: 'PDF',
                    color: Colors.red,
                    onTap: () {
                      Navigator.of(context).pop();
                      exportToPdf();
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
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(height: 10),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
        sheet = excel['Daily Summary Reports'];
      }

      final headers = [
        'Date',
        'Type',
        'Amount',
        'Count',
        'Category',
        'Vendor Name',
        'Notes',
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

      int rowIndex = 1;
      for (var entry in entries) {
        sheet.cell(
            CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex))
          ..value = entry['display_date'] ?? '-';
        sheet.cell(
            CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex))
          ..value = entry['type'] ?? '-';
        sheet.cell(
            CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex))
          ..value = entry['amount']?.toString() ?? '-';
        sheet.cell(
            CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIndex))
          ..value = entry['count']?.toString() ?? '-';
        sheet.cell(
            CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: rowIndex))
          ..value = entry['category'] ?? '-';
        sheet.cell(
            CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: rowIndex))
          ..value = entry['vendor_name'] ?? '-';
        sheet.cell(
            CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: rowIndex))
          ..value = entry['notes'] ?? '-';
        rowIndex++;
      }

      try {
        final newSheet = excel['Daily Summary Reports'];
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
          'daily_summary_reports_${DateTime.now().millisecondsSinceEpoch}.xlsx';
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
          pageFormat: pw.PdfPageFormat.a4.portrait,
          theme: pw.ThemeData.withFont(
            base: ttf,
            bold: ttf,
          ),
          build: (pw.Context context) {
            return [
              pw.Header(
                level: 0,
                child: pw.Text(
                  'Daily Summary Reports',
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
                    'Type',
                    'Amount',
                    'Count',
                    'Category',
                    'Vendor Name',
                    'Notes',
                  ],
                  ...entries.map<List<String>>((entry) {
                    return <String>[
                      entry['display_date'] ?? '-',
                      entry['type'] ?? '-',
                      entry['amount']?.toString() ?? '-',
                      entry['count']?.toString() ?? '-',
                      entry['category'] ?? '-',
                      entry['vendor_name'] ?? '-',
                      entry['notes'] ?? '-',
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
          'daily_summary_reports_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(await pdf.save());

      await OpenFile.open(file.path);
      CustomSnackbar.showSuccess('Success', 'PDF file exported successfully!');
    } catch (e) {
      CustomSnackbar.showError('Error', 'Failed to export PDF: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Balance Sheet',
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: _pickDateRange,
          ),
        ],
      ),
      drawer: ManagerDrawerScreen(),
      body: Builder(
        builder: (context) {
          if (isLoading) {
            return const Center(child: CustomLoadingAvatar());
          }
          if (errorMessage.isNotEmpty) {
            return Center(child: Text(errorMessage));
          }
          if (entries.isEmpty) {
            return const Center(child: Text('No data available'));
          }

          return SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Date')),
                  DataColumn(label: Text('Type')),
                  DataColumn(label: Text('Amount')),
                  DataColumn(label: Text('Count')),
                  DataColumn(label: Text('Category')),
                  DataColumn(label: Text('Vendor Name')),
                  DataColumn(label: Text('Notes')),
                ],
                rows: entries.map((entry) {
                  return DataRow(cells: [
                    DataCell(Text(entry['display_date'] ?? '-')),
                    DataCell(Text(entry['type'] ?? '-')),
                    DataCell(Text(entry['amount']?.toString() ?? '-')),
                    DataCell(Text(entry['count']?.toString() ?? '-')),
                    DataCell(Text(entry['category'] ?? '-')),
                    DataCell(Text(entry['vendor_name'] ?? '-')),
                    DataCell(Text(entry['notes'] ?? '-')),
                  ]);
                }).toList(),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        onPressed: () => _showExportDialog(context),
        child: const Icon(
          Icons.download,
          color: white,
        ),
      ),
    );
  }
}
