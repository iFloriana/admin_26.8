import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StaffReportController extends GetxController
    with SingleGetTickerProviderMixin {
  final Dio _dio = Dio();
  var isLoading = true.obs;
  var staffReportData = {}.obs;
  var staffEarningsData = {}.obs;
  late TabController tabController;

  final String staffReportUrl =
      'http://192.168.29.132:5000/api/appointments/staff-report?salon_id=684011271ee646f27873fddc&staff_id=6881fe017e277962d2370dd4';
  final String staffEarningsUrl =
      'http://192.168.29.132:5000/api/staffEarnings/by-staff/6854e87f552c461e11b487dd?salon_id=684011271ee646f27873fddc';

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 2, vsync: this);
    fetchData();
  }

  void fetchData() async {
    try {
      isLoading(true);
      final staffReportResponse = await _dio.get(staffReportUrl);
      final staffEarningsResponse = await _dio.get(staffEarningsUrl);

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
      appBar: AppBar(
        title: Text('Staff Report'),
        bottom: TabBar(
          controller: controller.tabController,
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
