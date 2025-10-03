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
  // late final String staffReportUrl =
  //     '${Apis.baseUrl}/appointments/staff-report?salon_id=$salonId&staff_id=$staffId';
  // late final String staffEarningsUrl =
  //     '${Apis.baseUrl}/staffEarnings/by-staff/$staffId?salon_id=$salonId';

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 2, vsync: this);
    fetchData();
  }

  // Helper function to sequence asynchronous calls
  Future<void> _initializeController() async {
    await _loadStaffDetails();
  }

  Future<void> _loadStaffDetails() async {
    // FIX: Instantiate SharedPreferenceManager to fix the 'prefs' error
    final data = await prefs.getStaffData();

    if (data != null) {
      try {
        final Map<String, dynamic> decodedData = jsonDecode(data);
        final Map<String, dynamic>? staffJson = decodedData['staff'];

        if (staffJson != null) {
          // Assign IDs from the staff data
          staffId = staffJson['_id'] as String?;
          salonId = staffJson['salon_id'] as String?;
          staffname = staffJson['full_name'] as String?;

          // Populate the observable map for the UI (StaffProfileScreen)
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

  void fetchData() async {
    try {
      isLoading(true);
      final staffReportResponse = await dioClient.dio.get(
          '${Apis.baseUrl}/appointments/staff-report?salon_id=684011271ee646f27873fddc&staff_id=6881fe017e277962d2370dd4');
      final staffEarningsResponse = await dioClient.dio.get(
          '${Apis.baseUrl}/staffEarnings/by-staff/6854e87f552c461e11b487dd?salon_id=684011271ee646f27873fddc');

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
            ? Center(child: CircularProgressIndicator())
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
          Text('Completed Appointments',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ...controller.staffReportData['completed']
                  ?.map<Widget>((appointment) {
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    title: Text(
                      appointment['customer_id'] != null
                          ? appointment['customer_id']['full_name'] ?? 'Unknown'
                          : 'No Customer',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            'Date: ${appointment['appointment_date'].split('T')[0]}'),
                        Text('Time: ${appointment['appointment_time']}'),
                        Text(
                            'Services: ${appointment['services'].map((s) => s['service_id']['name']).join(', ')}'),
                        Text('Total: ${appointment['grand_total']}'),
                        Text('Status: ${appointment['status']}'),
                        Text('Order: ${appointment['order_code']}'),
                      ],
                    ),
                  ),
                );
              })?.toList() ??
              [Text('No completed appointments')],
          SizedBox(height: 16),
          Text('Upcoming Appointments',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ...controller.staffReportData['upcoming']?.map<Widget>((appointment) {
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    title: Text(
                      appointment['customer_id'] != null
                          ? appointment['customer_id']['full_name'] ?? 'Unknown'
                          : 'No Customer',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            'Date: ${appointment['appointment_date'].split('T')[0]}'),
                        Text('Time: ${appointment['appointment_time']}'),
                        Text(
                            'Services: ${appointment['services'].map((s) => s['service_id']['name']).join(', ')}'),
                        Text('Total: ${appointment['grand_total']}'),
                        Text('Status: ${appointment['status']}'),
                        Text('Order: ${appointment['order_code']}'),
                      ],
                    ),
                  ),
                );
              })?.toList() ??
              [Text('No upcoming appointments')],
        ],
      ),
    );
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
            Text('Staff Earnings',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            Card(
              child: ListTile(
                title: Text(
                  controller.staffEarningsData['staff_name'] ?? 'Unknown',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        'Total Bookings: ${controller.staffEarningsData['total_booking'] ?? 0}'),
                    Text(
                        'Service Amount: ${controller.staffEarningsData['service_amount'] ?? 0}'),
                    Text(
                        'Commission Earning: ${controller.staffEarningsData['commission_earning'] ?? 0}'),
                    Text(
                        'Tip Earning: ${controller.staffEarningsData['tip_earning'] ?? 0}'),
                    Text(
                        'Total Earning: ${controller.staffEarningsData['staff_earning'] ?? 0}'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
