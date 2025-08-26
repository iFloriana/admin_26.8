import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_template/main.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:excel/excel.dart';
import 'package:pdf/pdf.dart' as pw;
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

import '../../../network/network_const.dart';
import '../../../wiget/custome_snackbar.dart';

class Appointment {
  final String appointmentId;
  final String date;
  final String time;
  final String clientName;
  final String? clientImage;
  final String? clientPhone;
  final int amount;
  final String staffName;
  final String? staffImage;
  final String serviceName;
  final String? membership;
  final String? package;
  final String status;
  final String paymentStatus;
  final double? branchMembershipDiscount;
  final String? branchMembershipDiscountType;

  Appointment({
    required this.appointmentId,
    required this.date,
    required this.time,
    required this.clientName,
    this.clientImage,
    this.clientPhone,
    required this.amount,
    required this.staffName,
    this.staffImage,
    required this.serviceName,
    this.membership,
    this.package,
    required this.status,
    required this.paymentStatus,
    this.branchMembershipDiscount,
    this.branchMembershipDiscountType,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    final customer = json['customer'] ?? {};
    final services = (json['services'] as List?) ?? [];
    final branchMembership = customer['branch_membership'];

    // Helper function to safely convert dynamic to string
    String toString(dynamic value) {
      if (value == null) return '';
      if (value is String) return value;
      if (value is Map) {
        // Handle image object - construct URL or return empty string
        if (value.containsKey('data') && value.containsKey('contentType')) {
          // This is an image object, you might want to construct a URL here
          // For now, return empty string to avoid errors
          return '';
        }
        return value.toString();
      }
      return value.toString();
    }

    // Helper function to safely convert dynamic to int
    int toInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    // Helper function to normalize status values
    String _normalizeStatus(String status) {
      final normalized = status.toLowerCase().trim();
      if (normalized == 'check-in' || normalized == 'check in') {
        return 'check in';
      } else if (normalized == 'check-out' || normalized == 'check out') {
        return 'check out';
      }
      return normalized;
    }

    // Get staff name from first service (assuming all services have same staff)
    String staffName = '';
    String staffImage = '';
    if (services.isNotEmpty) {
      final firstService = services[0];
      final staff = firstService['staff'] ?? {};
      staffName = toString(staff['full_name']);
      staffImage = staff['image'] is Map ? '' : toString(staff['image']);
    }

    // Combine service names from all services
    List<String> serviceNames = [];
    for (var service in services) {
      final serviceData = service['service'];
      if (serviceData != null) {
        final serviceName = toString(serviceData['name']);
        if (serviceName.isNotEmpty) {
          serviceNames.add(serviceName);
        }
      }
    }

    // If no service names found, add a placeholder
    if (serviceNames.isEmpty) {
      serviceNames.add('Custom Service');
    }

    final combinedServiceName = serviceNames.join(', ');

    return Appointment(
      appointmentId: toString(json['appointment_id']),
      date: toString(json['appointment_date']).split('T')[0],
      time: toString(json['appointment_time']),
      clientName: toString(customer['full_name']),
      clientImage:
          customer['image'] is Map ? null : toString(customer['image']),
      clientPhone: toString(customer['phone_number']),
      amount: toInt(json['total_payment']),
      staffName: staffName,
      staffImage: staffImage,
      serviceName: combinedServiceName,
      membership: customer['branch_membership'] != null ? 'Yes' : '-',
      package: (customer['branch_package'] != null &&
              (customer['branch_package'] is List
                  ? customer['branch_package'].isNotEmpty
                  : true))
          ? 'Yes'
          : '-',
      status: _normalizeStatus(toString(json['status'])),
      paymentStatus: toString(json['payment_status']),
      branchMembershipDiscount: branchMembership != null
          ? (branchMembership['discount'] is int
              ? (branchMembership['discount'] as int).toDouble()
              : (branchMembership['discount'] ?? 0).toDouble())
          : null,
      branchMembershipDiscountType: branchMembership != null
          ? toString(branchMembership['discount_type'])
          : null,
    );
  }
}

class TaxModel {
  final String id;
  final String title;
  final double value;

  TaxModel({required this.id, required this.title, required this.value});

  factory TaxModel.fromJson(Map<String, dynamic> json) {
    return TaxModel(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      value: (json['value'] is int)
          ? (json['value'] as int).toDouble()
          : (json['value'] ?? 0).toDouble(),
    );
  }
}

class CouponModel {
  final String id;
  final String code;
  final String name;
  final String description;
  final String startDate;
  final String endDate;
  final String discountType;
  final double discountAmount;
  final int status;

  CouponModel({
    required this.id,
    required this.code,
    required this.name,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.discountType,
    required this.discountAmount,
    required this.status,
  });

  factory CouponModel.fromJson(Map<String, dynamic> json) {
    return CouponModel(
      id: json['_id'] ?? '',
      code: json['coupon_code'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'] ?? '',
      discountType: json['discount_type'] ?? '',
      discountAmount: (json['discount_amount'] is int)
          ? (json['discount_amount'] as int).toDouble()
          : (json['discount_amount'] ?? 0).toDouble(),
      status: json['status'] ?? 0,
    );
  }
}

class PaymentSummaryState {
  Rx<TaxModel?> selectedTax = Rx<TaxModel?>(null);
  RxString tips = '0'.obs;
  RxString paymentMethod = ''.obs;
  RxString couponCode = ''.obs;
  Rx<CouponModel?> appliedCoupon = Rx<CouponModel?>(null);
  RxBool addAdditionalDiscount = false.obs;
  RxString discountType = 'percentage'.obs;
  RxString discountValue = '0'.obs;
  RxDouble grandTotal = 0.0.obs;
}

class Getappointmentmanagercontroller extends GetxController {
  var appointments = <Appointment>[].obs;
  var currentPage = 1;
  var hasMore = true;
  var filteredAppointments = <Appointment>[].obs;
  var isLoading = false.obs;
  var taxes = <TaxModel>[].obs;
  var coupons = <CouponModel>[].obs;
  var paymentSummaryState = PaymentSummaryState();

  // Filter and sort variables
  DateTime? selectedDate;
  DateTimeRange? selectedDateRange;
  String sortOrder = 'desc'; // Default to newest first

  @override
  void onInit() {
    super.onInit();
    getTax();
    getCoupons();
    getAppointment();
  }

  // Filter and sort methods
  void selectDate(DateTime date) {
    selectedDate = date;
    selectedDateRange = null;
    _applyFilters();
  }

  void selectDateRange(DateTimeRange range) {
    selectedDateRange = range;
    selectedDate = null;
    _applyFilters();
  }

  void setSortOrder(String order) {
    sortOrder = order;
    _applyFilters();
  }

  void clearFilters() {
    selectedDate = null;
    selectedDateRange = null;
    sortOrder = 'desc';
    _applyFilters();
  }

  void _applyFilters() {
    var filtered = List<Appointment>.from(appointments);

    // Apply date filters
    if (selectedDate != null) {
      filtered = filtered.where((appointment) {
        final appointmentDate = DateTime.parse(appointment.date);
        return appointmentDate.year == selectedDate!.year &&
            appointmentDate.month == selectedDate!.month &&
            appointmentDate.day == selectedDate!.day;
      }).toList();
    } else if (selectedDateRange != null) {
      filtered = filtered.where((appointment) {
        final appointmentDate = DateTime.parse(appointment.date);
        return appointmentDate.isAfter(
                selectedDateRange!.start.subtract(const Duration(days: 1))) &&
            appointmentDate
                .isBefore(selectedDateRange!.end.add(const Duration(days: 1)));
      }).toList();
    }

    // Apply sorting
    filtered.sort((a, b) {
      final dateA = DateTime.parse(a.date);
      final dateB = DateTime.parse(b.date);
      if (sortOrder == 'asc') {
        return dateA.compareTo(dateB);
      } else {
        return dateB.compareTo(dateA);
      }
    });

    filteredAppointments.value = filtered;
  }

  Future<void> getAppointment() async {
    final manager = await prefs.getManagerUser();
    isLoading.value = true;
    try {

      final response = await dioClient.getData(
        '${Apis.baseUrl}/appointments/by-branch?salon_id=${manager?.manager?.salonId}&branch_id=${manager?.manager?.branchId?.sId}',
        (json) => json,
      );

      if (response != null && response['success'] == true) {
        final List data = response['data'] ?? [];
        appointments.value = data.map((e) => Appointment.fromJson(e)).toList();
        filteredAppointments.value = List.from(appointments);
        _applyFilters();
      }
      print(
          "${Apis.baseUrl}/appointments/by-branch?salon_id=${manager?.manager?.salonId}&branch_id=${manager?.manager?.branchId?.sId}");
    } catch (e) {
      CustomSnackbar.showError('Error', 'Failed to get data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getTax() async {
    //  final manager = await prefs.getManagerUser();
      final manager = await prefs.getManagerUser();
    isLoading.value = true;
    try {
      final response = await dioClient.getData(
        '${Apis.baseUrl}${Endpoints.getTex}${manager?.manager?.salonId}',
        (json) => json,
      );
      if (response != null && response['data'] != null) {
        final List data = response['data'] ?? [];
        taxes.value = data.map((e) => TaxModel.fromJson(e)).toList();
      }
    } catch (e) {
      CustomSnackbar.showError('Error', 'Failed to get data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getCoupons() async {
     final manager = await prefs.getManagerUser();
    isLoading.value = true;
    try {
      final response = await dioClient.getData(
        '${Apis.baseUrl}${Endpoints.getCoupons}${manager?.manager?.salonId}',
        (json) => json,
      );
      if (response != null && response['data'] != null) {
        final List data = response['data'] ?? [];
        coupons.value = data.map((e) => CouponModel.fromJson(e)).toList();
      }
    } catch (e) {
      CustomSnackbar.showError('Error', 'Failed to get data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void applyCoupon(String code) {
    final now = DateTime.now();
    final coupon = coupons.firstWhereOrNull((c) {
      final start = DateTime.tryParse(c.startDate);
      final end = DateTime.tryParse(c.endDate);
      return c.code.toLowerCase() == code.toLowerCase() &&
          c.status == 1 &&
          start != null &&
          end != null &&
          now.isAfter(start) &&
          now.isBefore(end.add(const Duration(days: 1)));
    });
    if (coupon != null) {
      paymentSummaryState.appliedCoupon.value = coupon;
      CustomSnackbar.showSuccess('Coupon Applied', coupon.code);
    } else {
      paymentSummaryState.appliedCoupon.value = null;
      CustomSnackbar.showError(
          'Invalid Coupon', 'Coupon is not active or does not exist');
    }
  }

  // Add this function to calculate the grand total
  void calculateGrandTotal({
    required double servicePrice,
    double memberDiscount = 0.0,
    double taxValue = 0.0,
    double tip = 0.0,
    double couponDiscount = 0.0,
    double additionalDiscount = 0.0,
    String discountType = 'percentage',
  }) {
    double total = servicePrice - memberDiscount;
    total -= couponDiscount;
    // Apply additional discount if any
    if (additionalDiscount > 0) {
      if (discountType == 'percentage') {
        total -= (total * additionalDiscount / 100);
      } else {
        total -= additionalDiscount;
      }
    }
    double totalWithTax = total + taxValue;
    double grandTotal = totalWithTax + tip;
    paymentSummaryState.grandTotal.value = grandTotal < 0 ? 0 : grandTotal;
  }

  // Cancel appointment method
  Future<void> cancelAppointment(String appointmentId) async {
    try {
      final response = await dioClient.dio.put(
        '${Apis.baseUrl}/appointments/$appointmentId',
        data: {
          'status': 'cancelled',
        },
      );
      CustomSnackbar.showSuccess(
          'Success', 'Appointment cancelled successfully');
      await getAppointment();
    } catch (e) {
      CustomSnackbar.showError('Error', 'Failed to cancel appointment: $e');
    }
  }

  // Get payment data by appointment ID and open PDF
  Future<void> openAppointmentPdf(String appointmentId) async {
    try {
       final manager = await prefs.getManagerUser();
      final response = await dioClient.getData(
        '${Apis.baseUrl}/payments?salon_id=${manager?.manager?.salonId}',
        (json) => json,
      );

      // if (response != null && response['success'] == true) {
      final List payments = response['data'] ?? [];
      final payment = payments.firstWhereOrNull(
        (payment) => payment['appointment_id'] == appointmentId,
      );

      if (payment != null && payment['invoice_pdf_url'] != null) {
        final pdfUrl = '${Apis.pdfUrl}${payment['invoice_pdf_url']}';
        await openPdf(pdfUrl);
      } else {
        CustomSnackbar.showError(
            'Error', 'No invoice found for this appointment');
      }
      // } else {
      //   CustomSnackbar.showError('Error', 'Failed to fetch payment data');
      // }
    } catch (e) {
      CustomSnackbar.showError('Error', 'Failed to open PDF: $e');
    }
  }

  // Open PDF method
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

  // Delete appointment method
  Future<void> deleteAppointment(String appointmentId) async {
    try {
      final response = await dioClient.deleteData(
        '${Apis.baseUrl}/appointments/$appointmentId',
        (json) => json,
      );

      CustomSnackbar.showSuccess('Success', 'Appointment deleted successfully');
      // Refresh the appointments list
      await getAppointment();
    } catch (e) {
      CustomSnackbar.showError('Error', 'Failed to delete appointment: $e');
    }
  }

  // Export methods
  Future<void> exportToExcel() async {
    try {
      final excel = Excel.createExcel();
      // Safely ensure only one sheet named 'Appointments'
      Sheet sheet;
      try {
        if (excel.sheets.keys.contains('Sheet1')) {
          try {
            excel.rename('Sheet1', 'Appointments');
          } catch (_) {
            // Fallback: just use default sheet if rename unsupported
          }
        }
        // Try to get the 'Appointments' sheet; fallback to first available
        if (excel.sheets.keys.contains('Appointments')) {
          sheet = excel['Appointments'];
        } else {
          final first = excel.sheets.keys.first;
          sheet = excel[first]!;
        }
      } catch (_) {
        final first = excel.sheets.keys.first;
        sheet = excel[first]!;
      }

      // Add headers with styling
      final headers = [
        'Date & Time',
        'Client',
        'Amount',
        'Staff Name',
        'Services',
        'Membership',
        'Package',
        'Status',
        'Payment Status'
      ];

      for (int i = 0; i < headers.length; i++) {
        final cell =
            sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
        cell.value = headers[i];
        // Make headers bold
        cell.cellStyle = CellStyle(bold: true);
      }

      // Add data from filtered appointments
      for (int i = 0; i < filteredAppointments.length; i++) {
        final appointment = filteredAppointments[i];
        final rowIndex = i + 1;

        sheet
            .cell(
                CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex))
            .value = '${appointment.date} - ${appointment.time}';
        sheet
            .cell(
                CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex))
            .value = appointment.clientName;
        sheet
            .cell(
                CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex))
            .value = appointment.amount;
        sheet
            .cell(
                CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIndex))
            .value = appointment.staffName;
        sheet
            .cell(
                CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: rowIndex))
            .value = appointment.serviceName;
        sheet
            .cell(
                CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: rowIndex))
            .value = appointment.membership ?? '-';
        sheet
            .cell(
                CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: rowIndex))
            .value = appointment.package ?? '-';
        sheet
            .cell(
                CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: rowIndex))
            .value = appointment.status;
        sheet
            .cell(
                CellIndex.indexByColumnRow(columnIndex: 8, rowIndex: rowIndex))
            .value = appointment.paymentStatus;
      }

      // Set column widths (Excel package doesn't have setColumnWidth method)
      // Columns will auto-fit based on content

      // Save file
      final directory = await getApplicationDocumentsDirectory();
      final fileName =
          'appointments_${DateTime.now().millisecondsSinceEpoch}.xlsx';
      final file = File('${directory.path}/$fileName');
      final bytes = excel.encode();
      if (bytes == null) {
        throw Exception('Excel encode failed');
      }
      await file.writeAsBytes(bytes, flush: true);

      // Open file
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
      // Use MultiPage so long tables paginate correctly

      pdf.addPage(
        pw.MultiPage(
          pageFormat: pw.PdfPageFormat.a4.portrait,
          margin: pw.EdgeInsets.all(20),
          theme: pw.ThemeData.withFont(
            base: ttf,
            bold: ttf,
          ),
          build: (pw.Context context) {
            return [
              // Header
              pw.Center(
                child: pw.Text(
                  'Appointments Report',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 10),

              // Export info
              // pw.Text(
              //   'Generated on: ${DateTime.now().toString().split('.')[0]}',
              //   style: pw.TextStyle(fontSize: 12, color: pw.PdfColors.grey),
              // ),
              // pw.SizedBox(height: 5),
              // pw.Text(
              //   'Total Records: ${filteredAppointments.length}',
              //   style: pw.TextStyle(fontSize: 12, color: pw.PdfColors.grey),
              // ),
              // pw.SizedBox(height: 20),

              // Table
              pw.Table.fromTextArray(
                context: context,
                border: pw.TableBorder.all(),
                headers: [
                  'Date & Time',
                  'Client',
                  'Amount',
                  'Staff',
                  'Service',
                  'Status',
                  'Payment'
                ],
                data: filteredAppointments
                    .map((appointment) => [
                          '${appointment.date}\n${appointment.time}',
                          appointment.clientName,
                          '₹${appointment.amount}',
                          appointment.staffName,
                          appointment.serviceName,
                          appointment.status,
                          appointment.paymentStatus,
                        ])
                    .toList(),
                // headerStyle: pw.TextStyle(
                //   fontWeight: pw.FontWeight.bold,
                //   color: pw.PdfColors.white,
                // ),
                // headerDecoration: pw.BoxDecoration(
                //   color: pw.PdfColors.blue,
                // ),
                cellHeight: 30,
                cellPadding: pw.EdgeInsets.all(5),
              ),
            ];
          },
        ),
      );

      // Save file
      final directory = await getApplicationDocumentsDirectory();
      final fileName =
          'appointments_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(await pdf.save());

      // Open file
      await OpenFile.open(file.path);
      CustomSnackbar.showSuccess('Success', 'PDF file exported successfully');
    } catch (e) {
      CustomSnackbar.showError('Error', 'Failed to export PDF: $e');
    }
  }
}
