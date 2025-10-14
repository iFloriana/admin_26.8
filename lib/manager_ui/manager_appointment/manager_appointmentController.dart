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
  final num amount;
  final num totalPayment;
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
    required this.totalPayment,
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
    final firstService = services.isNotEmpty ? services[0] : {};
    final service = firstService['service'] ?? {};
    final staff = firstService['staff'] ?? {};

    final packageAndMembership =
        customer['package_and_membership'] as List? ?? [];

    String toString(dynamic value) {
      if (value == null) return '';
      if (value is String) return value;
      if (value is Map) {
        if (value.containsKey('data') && value.containsKey('contentType')) {
          return '';
        }
        return value.toString();
      }
      return value.toString();
    }

    int toInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    String _normalizeStatus(String status) {
      final normalized = status.toLowerCase().trim();
      if (normalized == 'check-in' || normalized == 'check in') {
        return 'check in';
      } else if (normalized == 'check-out' || normalized == 'check out') {
        return 'check out';
      }
      return normalized;
    }

    double? extractMembershipDiscount() {
      if (packageAndMembership.isEmpty) return null;

      final now = DateTime.now();
      for (final item in packageAndMembership) {
        if (item is Map && item['branch_membership'] != null) {
          final endDate = item['end_date'];
          if (endDate != null) {
            final end = DateTime.tryParse(endDate);
            if (end != null && end.isAfter(now)) {
              final discount = item['discount'];
              return (discount is num)
                  ? discount.toDouble()
                  : double.tryParse('$discount') ?? 0.0;
            }
          }
        }
      }
      return null;
    }

    String? extractMembershipDiscountType() {
      if (packageAndMembership.isEmpty) return null;

      final now = DateTime.now();
      for (final item in packageAndMembership) {
        if (item is Map && item['branch_membership'] != null) {
          final endDate = item['end_date'];
          if (endDate != null) {
            final end = DateTime.tryParse(endDate);
            if (end != null && end.isAfter(now)) {
              return toString(item['discount_type']);
            }
          }
        }
      }
      return null;
    }

    bool hasActivePackage() {
      if (packageAndMembership.isEmpty) return false;

      final now = DateTime.now();
      for (final item in packageAndMembership) {
        if (item is Map) {
          final branchPackage = item['branch_package'];
          if (branchPackage is List && branchPackage.isNotEmpty) {
            final endDate = item['end_date'];
            if (endDate != null) {
              final end = DateTime.tryParse(endDate);
              if (end != null && end.isAfter(now)) {
                return true;
              }
            }
          }
        }
      }
      return false;
    }

    bool hasActiveMembership() {
      if (packageAndMembership.isEmpty) return false;

      final now = DateTime.now();
      for (final item in packageAndMembership) {
        if (item is Map && item['branch_membership'] != null) {
          final endDate = item['end_date'];
          if (endDate != null) {
            final end = DateTime.tryParse(endDate);
            if (end != null && end.isAfter(now)) {
              return true;
            }
          }
        }
      }
      return false;
    }

    return Appointment(
      appointmentId: toString(json['appointment_id']),
      date: toString(json['appointment_date']).split('T')[0],
      time: toString(json['appointment_time']),
      clientName: toString(customer['full_name']),
      clientImage:
          customer['image'] is Map ? null : toString(customer['image']),
      clientPhone: toString(customer['phone_number']),
      amount: toInt(json['service_total_amount']),
      totalPayment: toInt(json['total_payment']),
      staffName: toString(staff['full_name']),
      staffImage: staff['image'] is Map ? null : toString(staff['image']),
      serviceName: toString(service['name']),
      membership: hasActiveMembership() ? 'Yes' : '-',
      package: hasActivePackage() ? 'Yes' : '-',
      status: _normalizeStatus(toString(json['status'])),
      paymentStatus: toString(json['payment_status']),
      branchMembershipDiscount: extractMembershipDiscount(),
      branchMembershipDiscountType: extractMembershipDiscountType(),
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
  RxString discountType = ''.obs;
  RxString discountValue = '0'.obs;
  RxDouble grandTotal = 0.0.obs;
}

class ManagerAppointmentcontroller extends GetxController {
  var appointments = <Appointment>[].obs;
  var currentPage = 1;
  var hasMore = true;
  var filteredAppointments = <Appointment>[].obs;
  var isLoading = false.obs;
  var taxes = <TaxModel>[].obs;
  var coupons = <CouponModel>[].obs;
  var paymentSummaryState = PaymentSummaryState();

  var appliedCoupon = Rxn<Map<String, dynamic>>();
  var couponApplied = false.obs;
  var couponId = ''.obs;

  DateTime? selectedDate;
  DateTimeRange? selectedDateRange;
  String sortOrder = 'desc';

  @override
  void onInit() {
    super.onInit();
    getTax();
    getCoupons();
    getAppointment();
  }

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

    filtered.sort((a, b) {
      final dateA = DateTime.parse(a.date);
      final dateB = DateTime.parse(b.date);
      return sortOrder == 'asc'
          ? dateA.compareTo(dateB)
          : dateB.compareTo(dateA);
    });

    filteredAppointments.value = filtered;
  }

  Future<void> getAppointment() async {
    try {
      isLoading.value = true;
      final loginUser = await prefs.getManagerUser();
      final response = await dioClient.getData(
        '${Apis.baseUrl}/appointments?salon_id=${loginUser!.manager!.salonId}&branch_id=${loginUser.manager!.branchId}&page=$currentPage&limit=10',
        (json) => json,
      );

      final List data = response['data'] ?? [];
      final List<Appointment> newAppointments =
          data.map((json) => Appointment.fromJson(json)).toList();

      if (currentPage == 1) {
        appointments.clear();
      }

      appointments.addAll(newAppointments);
      hasMore = data.length == 10;
      _applyFilters();
    } catch (e) {
      CustomSnackbar.showError('Error', 'Failed to fetch appointments: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getTax() async {
    try {
      final loginUser = await prefs.getManagerUser();
      final response = await dioClient.getData(
        '${Apis.baseUrl}/taxes?salon_id=${loginUser!.manager!.salonId}&branch_id=${loginUser.manager!.branchId}',
        (json) => json,
      );

      final List data = response['data'] ?? [];
      taxes.value = data.map((json) => TaxModel.fromJson(json)).toList();
    } catch (e) {
      CustomSnackbar.showError('Error', 'Failed to fetch taxes: $e');
    }
  }

  Future<void> getCoupons() async {
    try {
      final loginUser = await prefs.getManagerUser();
      final response = await dioClient.getData(
        '${Apis.baseUrl}/coupons?salon_id=${loginUser!.manager!.salonId}&branch_id=${loginUser.manager!.branchId}',
        (json) => json,
      );

      final List data = response['data'] ?? [];
      coupons.value = data.map((json) => CouponModel.fromJson(json)).toList();
    } catch (e) {
      CustomSnackbar.showError('Error', 'Failed to fetch coupons: $e');
    }
  }

  Future<void> applyCoupon(String code) async {
    try {
      final loginUser = await prefs.getManagerUser();
      final response = await dioClient.getData(
        '${Apis.baseUrl}/coupons/verify?salon_id=${loginUser!.manager!.salonId}&branch_id=${loginUser.manager!.branchId}&code=$code',
        (json) => json,
      );

      if (response['success'] == true) {
        appliedCoupon.value = response['data'];
        couponApplied.value = true;
        couponId.value = response['data']['_id'];
        paymentSummaryState.appliedCoupon.value =
            CouponModel.fromJson(response['data']);
        CustomSnackbar.showSuccess('Success', 'Coupon applied successfully');
      } else {
        CustomSnackbar.showError('Error', 'Invalid coupon code');
      }
    } catch (e) {
      CustomSnackbar.showError('Error', 'Failed to apply coupon: $e');
    }
  }

  Future<void> cancelAppointment(String appointmentId) async {
    try {
      await dioClient.putData(
        '${Apis.baseUrl}/appointments/$appointmentId',
        {'status': 'cancelled'},
        (json) => json,
      );

      CustomSnackbar.showSuccess(
          'Success', 'Appointment cancelled successfully');
      await getAppointment();
    } catch (e) {
      CustomSnackbar.showError('Error', 'Failed to cancel appointment: $e');
    }
  }

  Future<void> openAppointmentPdf(String appointmentId) async {
    try {
      final loginUser = await prefs.getManagerUser();
      final response = await dioClient.getData(
        '${Apis.baseUrl}/payments?salon_id=${loginUser!.manager!.salonId}&branch_id=${loginUser.manager!.branchId}',
        (json) => json,
      );

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
    } catch (e) {
      CustomSnackbar.showError('Error', 'Failed to open PDF: $e');
    }
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

  Future<void> deleteAppointment(String appointmentId) async {
    try {
      final loginUser = await prefs.getManagerUser();
      await dioClient.deleteData(
        '${Apis.baseUrl}/appointments/$appointmentId?salon_id=${loginUser!.manager!.salonId}&branch_id=${loginUser.manager!.branchId}',
        (json) => json,
      );

      CustomSnackbar.showSuccess('Success', 'Appointment deleted successfully');
      await getAppointment();
    } catch (e) {
      CustomSnackbar.showError('Error', 'Failed to delete appointment: $e');
    }
  }

  Future<void> exportToExcel() async {
    try {
      final excel = Excel.createExcel();
      Sheet sheet;
      try {
        if (excel.sheets.keys.contains('Sheet1')) {
          try {
            excel.rename('Sheet1', 'Appointments');
          } catch (_) {}
        }
        if (excel.sheets.keys.contains('Appointments')) {
          sheet = excel['Appointments'];
        } else {
          final first = excel.sheets.keys.first;
          sheet = excel[first];
        }
      } catch (_) {
        final first = excel.sheets.keys.first;
        sheet = excel[first];
      }

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
        cell.cellStyle = CellStyle(bold: true);
      }

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
            .value = appointment.totalPayment;
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
            .value = appointment.membership;
        sheet
            .cell(
                CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: rowIndex))
            .value = appointment.package;
        sheet
            .cell(
                CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: rowIndex))
            .value = appointment.status;
        sheet
            .cell(
                CellIndex.indexByColumnRow(columnIndex: 8, rowIndex: rowIndex))
            .value = appointment.paymentStatus;
      }

      final directory = await getApplicationDocumentsDirectory();
      final fileName =
          'appointments_${DateTime.now().millisecondsSinceEpoch}.xlsx';
      final file = File('${directory.path}/$fileName');
      final bytes = excel.encode();
      if (bytes == null) {
        throw Exception('Excel encode failed');
      }
      await file.writeAsBytes(bytes, flush: true);

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
                          '₹${appointment.totalPayment}',
                          appointment.staffName,
                          appointment.serviceName,
                          appointment.status,
                          appointment.paymentStatus,
                        ])
                    .toList(),
                cellHeight: 30,
                cellPadding: pw.EdgeInsets.all(5),
              ),
            ];
          },
        ),
      );

      final directory = await getApplicationDocumentsDirectory();
      final fileName =
          'appointments_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(await pdf.save());

      await OpenFile.open(file.path);
      CustomSnackbar.showSuccess('Success', 'PDF file exported successfully');
    } catch (e) {
      CustomSnackbar.showError('Error', 'Failed to export PDF: $e');
    }
  }
}
