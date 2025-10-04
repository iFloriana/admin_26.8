import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_template/main.dart';
import 'package:flutter_template/network/network_const.dart';
import 'package:flutter_template/utils/colors.dart';
import 'package:flutter_template/wiget/appbar/commen_appbar.dart';
import 'package:flutter_template/wiget/custome_snackbar.dart';
import 'package:get/get.dart';

class StaffReportController extends GetxController
    with SingleGetTickerProviderMixin {
  var isLoading = true.obs;
  var staffReportData = {}.obs;
  var staffEarningsData = {}.obs;
  late TabController tabController;
  String? staffId;
  String? salonId;
  var staffData = {}.obs;
  String? staffname;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 2, vsync: this);
    _initializeController();
  }

  // Helper function to sequence asynchronous calls
  Future<void> _initializeController() async {
    await _loadStaffDetails();
    await fetchData();
  }

  Future<void> _loadStaffDetails() async {
    final data = await prefs.getStaffData();

    if (data != null) {
      try {
        final Map<String, dynamic> decodedData = jsonDecode(data);
        final Map<String, dynamic>? staffJson = decodedData['staff'];

        if (staffJson != null) {
          staffId = staffJson['_id'] as String?;
          salonId = staffJson['salon_id'] as String?;
          staffname = staffJson['full_name'] as String?;

          staffData.value = {
            'full_name': staffJson['full_name'],
            'image_url': staffJson['image_url'],
            '_id': staffJson['_id'],
            'salon_id': staffJson['salon_id'],
          };
        } else {
          CustomSnackbar.showError(
              'Error', 'Staff details not found in stored data');
        }
      } on FormatException catch (e) {
        CustomSnackbar.showError(
            'Error', 'Failed to parse staff data JSON: $e');
      } catch (e) {
        CustomSnackbar.showError(
            'Error', 'An unexpected error occurred loading staff data: $e');
      }
    } else {
      CustomSnackbar.showError('Error', 'Staff data not found in storage');
    }
  }

  Future<void> fetchData() async {
    if (staffId == null || salonId == null) {
      CustomSnackbar.showError('Error', 'Staff ID or Salon ID not found');
      isLoading(false);
      return;
    }

    try {
      isLoading(true);
      final staffReportResponse = await dioClient.dio.get(
          '${Apis.baseUrl}/appointments/staff-report?salon_id=$salonId&staff_id=$staffId');
      final staffEarningsResponse = await dioClient.dio.get(
          '${Apis.baseUrl}/staffEarnings/by-staff/$staffId?salon_id=$salonId');

      if (staffReportResponse.data['success']) {
        staffReportData.value = staffReportResponse.data['data'];
      }
      staffEarningsData.value = staffEarningsResponse.data;
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch data: $e');
    } finally {
      isLoading(false);
    }
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }
}

class StaffReportScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.put(StaffReportController());

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Staff Report',
        bottom: TabBar(
          controller: controller.tabController,
          indicatorColor: secondaryColor,
          labelColor: Colors.white,
          splashBorderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20.0),
          ),
          unselectedLabelColor: secondaryColor,
          dividerColor: Colors.transparent,
          tabs: [
            Tab(text: 'Appointments'),
            Tab(text: 'Earnings'),
          ],
        ),
      ),
      body: Obx(
        () => controller.isLoading.value
            ? Center(
                child: CircularProgressIndicator(
                  color: primaryColor,
                ),
              )
            : TabBarView(
                controller: controller.tabController,
                children: [
                  AppointmentsTab(),
                  EarningsTab(),
                ],
              ),
      ),
    );
  }
}

class AppointmentsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<StaffReportController>();

    return Obx(
      () => ListView(
        padding: EdgeInsets.all(16),
        children: [
          _buildSectionTitle('Completed Appointments'),
          if (controller.staffReportData['completed']?.isEmpty ?? true)
            _buildEmptyState('No completed appointments')
          else
            ...controller.staffReportData['completed']
                .map<Widget>((appointment) => _buildCompactAppointmentCard(
                      context,
                      appointment,
                    ))
                .toList(),
          SizedBox(height: 24),
          _buildSectionTitle('Upcoming Appointments'),
          if (controller.staffReportData['upcoming']?.isEmpty ?? true)
            _buildEmptyState('No upcoming appointments')
          else
            ...controller.staffReportData['upcoming']
                .map<Widget>((appointment) => _buildCompactAppointmentCard(
                      context,
                      appointment,
                    ))
                .toList(),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: primaryColor,
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        message,
        style: TextStyle(
          fontSize: 16,
          color: Colors.grey[600],
          fontStyle: FontStyle.italic,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  // Compact card: Shows 2-3 key items only (customer, date/time, total + status chip)
  Widget _buildCompactAppointmentCard(
      BuildContext context, Map<String, dynamic> appointment) {
    final customerName = appointment['customer_id'] != null
        ? appointment['customer_id']['full_name'] ?? 'Unknown Customer'
        : 'No Customer';
    final dateTime =
        '${appointment['appointment_date'].split('T')[0]} | ${appointment['appointment_time']}';
    final total = appointment['grand_total']?.toString() ?? '0';
    final status = appointment['status'] ?? 'Unknown';
    final statusColor = _getStatusColor(status);

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.symmetric(vertical: 6),
      child: InkWell(
        // Adds ripple effect on tap
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showAppointmentDetailsDialog(context, appointment),
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [Colors.white, Colors.grey[50]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Row(
            children: [
              // Leading Avatar
              CircleAvatar(
                backgroundColor: secondaryColor,
                radius: 20,
                child: Text(
                  customerName.isNotEmpty ? customerName[0].toUpperCase() : 'U',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
              SizedBox(width: 12),
              // Main Content (Expanded)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title: Customer Name
                    Text(
                      customerName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    // Subtitle: Date & Time (single line)
                    Text(
                      dateTime,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 2),
                    // Total Amount
                    Text(
                      'Total: \₹${total}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              // Trailing: Status Chip
              Chip(
                label: Text(
                  status,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                backgroundColor: statusColor,
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Show attractive dialog with full details
  void _showAppointmentDetailsDialog(
      BuildContext context, Map<String, dynamic> appointment) {
    showDialog(
      context: context,
      barrierDismissible: true, // Allow tap outside to dismiss
      builder: (BuildContext context) {
        return AppointmentDetailsDialog(appointment: appointment);
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'upcoming':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

// New Widget: Attractive Dialog for Full Appointment Details
class AppointmentDetailsDialog extends StatelessWidget {
  final Map<String, dynamic> appointment;

  const AppointmentDetailsDialog({Key? key, required this.appointment})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final customerName = appointment['customer_id'] != null
        ? appointment['customer_id']['full_name'] ?? 'Unknown Customer'
        : 'No Customer';
    final customerId = appointment['customer_id']?['_id'] ?? 'N/A';
    final date = appointment['appointment_date'].split('T')[0];
    final time = appointment['appointment_time'] ?? 'N/A';
    final status = appointment['status'] ?? 'Unknown';
    final total = appointment['grand_total']?.toString() ?? '0';
    final orderCode = appointment['order_code'] ?? 'N/A';
    final statusColor = _getStatusColor(
        status); // Reuse helper (you can move it to a utils file if needed)

    // Services as list of chips
    final services = (appointment['services'] as List<dynamic>?)
            ?.map((s) => s['service_id']['name'] as String?)
            ?.where((s) => s != null)
            .toList() ??
        [];

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 16,
      backgroundColor: Colors.transparent, // Transparent for custom styling
      child: Container(
        height: MediaQuery.of(context).size.height * 0.65,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [Colors.white, Colors.grey[50]!],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header: Gradient with Avatar, Name, Status, and Close Button
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                gradient: LinearGradient(
                  colors: [primaryColor, secondaryColor],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
              child: Row(
                children: [
                  // Avatar
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 25,
                    child: Text(
                      customerName.isNotEmpty
                          ? customerName[0].toUpperCase()
                          : 'U',
                      style: TextStyle(
                        color: primaryColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  // Name and Customer ID
                  Text(
                    customerName,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            // Scrollable Body
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Order Code
                    _buildInfoRow(Icons.code, 'Order Code', orderCode),
                    SizedBox(height: 16),
                    // Date & Time Section
                    _buildSectionTitle('Date & Time'),
                    _buildInfoRow(Icons.calendar_today, 'Date', date),
                    _buildInfoRow(Icons.access_time, 'Time', time),
                    SizedBox(height: 16),
                    // Services Section
                    _buildSectionTitle('Services'),
                    if (services.isEmpty)
                      _buildInfoRow(
                          Icons.room_service, 'Services', 'No services booked')
                    else
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: services
                            .map((service) => Chip(
                                  label: Text(
                                    service!,
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 12),
                                  ),
                                  backgroundColor: secondaryColor,
                                ))
                            .toList(),
                      ),
                    SizedBox(height: 16),
                    // Pricing Section
                    _buildSectionTitle('Pricing'),
                    _buildInfoRow(
                        Icons.monetization_on, 'Total Amount', '\$$total'),
                    SizedBox(height: 16),
                    // Additional Info Section
                    _buildSectionTitle('Additional Info'),
                    _buildInfoRow(Icons.info, 'Status', status,
                        color: statusColor),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: primaryColor,
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value,
      {Color? color}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: color ?? primaryColor),
          SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                children: [
                  TextSpan(
                      text: '$label: ',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  TextSpan(
                    text: value,
                    style: TextStyle(
                      color: color ?? Colors.black87,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'upcoming':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

class EarningsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<StaffReportController>();

    return Obx(
      () => Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Staff Earnings',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            SizedBox(height: 16),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    colors: [Colors.white, Colors.grey[50]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: secondaryColor,
                            radius: 24,
                            child: Text(
                              controller.staffEarningsData['staff_name']?[0] ??
                                  'U',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 20),
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              controller.staffEarningsData['staff_name'] ??
                                  'Unknown',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      _buildEarningRow(
                        Icons.book_online,
                        'Total Bookings',
                        '${controller.staffEarningsData['total_booking'] ?? 0}',
                      ),
                      _buildEarningRow(
                        Icons.monetization_on,
                        'Service Amount',
                        '${controller.staffEarningsData['service_amount'] ?? 0}',
                      ),
                      _buildEarningRow(
                        Icons.account_balance_wallet,
                        'Commission Earning',
                        '${controller.staffEarningsData['commission_earning'] ?? 0}',
                      ),
                      _buildEarningRow(
                        Icons.card_giftcard,
                        'Tip Earning',
                        '${controller.staffEarningsData['tip_earning'] ?? 0}',
                      ),
                      Divider(height: 24),
                      _buildEarningRow(
                        Icons.summarize,
                        'Total Earning',
                        '${controller.staffEarningsData['staff_earning'] ?? 0}',
                        isTotal: true,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEarningRow(IconData icon, String label, String value,
      {bool isTotal = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: isTotal ? primaryColor : Colors.grey[600],
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
                fontSize: isTotal ? 16 : 14,
                color: isTotal ? primaryColor : Colors.grey[700],
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
              color: isTotal ? primaryColor : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
