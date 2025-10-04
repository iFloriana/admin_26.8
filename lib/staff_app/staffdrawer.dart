import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_template/main.dart'; // Assuming prefs is defined here
import 'package:flutter_template/staff_app/punchin-out.dart'; // Import AttendanceScreen
import 'package:flutter_template/staff_app/timecard.dart'; // Import AttendanceCalendarScreen
import 'package:flutter_template/staff_app/reports.dart'; // Import StaffReportScreen
import 'package:flutter_template/staff_app/staffprofile.dart'; // Import StaffProfileScreen
import 'package:get/get.dart';

class DashboardController extends GetxController {
  RxInt currentIndex = 0.obs;
  RxBool isLoading = true.obs;
  String? staffId;
  String? salonId;

  @override
  void onInit() {
    super.onInit();
    loadStaffData();
  }

  Future<void> loadStaffData() async {
    final data = await prefs.getStaffData();
    if (data != null) {
      try {
        final Map<String, dynamic> decodedData = jsonDecode(data);
        final Map<String, dynamic>? staffJson = decodedData['staff'];

        if (staffJson != null) {
          staffId = staffJson['_id'] as String?;
          salonId = staffJson['salon_id'] as String?;
        }
      } catch (e) {
        Get.snackbar('Error', 'Failed to load staff data: $e');
      }
    } else {
      Get.snackbar('Error', 'Staff data not found in storage');
    }
    isLoading.value = false;
  }
}

class StaffDashboard extends StatelessWidget {
  final DashboardController controller = Get.put(DashboardController());

  StaffDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      }

      if (controller.staffId == null || controller.salonId == null) {
        return const Scaffold(
          body: Center(child: Text('Error: Staff or Salon ID not found')),
        );
      }

      final List<Widget> screens = [
        AttendanceScreen(), // From punchin-out.dart (default tab)
        AttendanceCalendarScreen(staffId: controller.staffId!),
        StaffReportScreen(),
        StaffProfileScreen(
            staffId: controller.staffId!, salonId: controller.salonId!),
      ];

      return Scaffold(
        body: screens[controller.currentIndex.value],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: controller.currentIndex.value,
          onTap: (index) => controller.currentIndex.value = index,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.deepPurple, // Customize as per your theme
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.timer), label: 'Punch'),
            BottomNavigationBarItem(
                icon: Icon(Icons.calendar_today), label: 'Timecard'),
            BottomNavigationBarItem(icon: Icon(Icons.report), label: 'Reports'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      );
    });
  }
}
