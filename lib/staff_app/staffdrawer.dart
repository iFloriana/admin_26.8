import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_template/main.dart'; // Assuming prefs is defined here
import 'package:flutter_template/staff_app/punchin-out.dart'; // Import AttendanceScreen
import 'package:flutter_template/staff_app/timecard.dart'; // Import AttendanceCalendarScreen
import 'package:flutter_template/staff_app/reports.dart'; // Import StaffReportScreen
import 'package:flutter_template/staff_app/staffprofile.dart'; // Import StaffProfileScreen
import 'package:flutter_template/utils/colors.dart';
import 'package:flutter_template/wiget/loading.dart';
import 'package:get/get.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

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
          body: Center(child: CustomLoadingAvatar()),
        );
      }

      if (controller.staffId == null || controller.salonId == null) {
        return const Scaffold(
          body: Center(child: Text('Error: Staff or Salon ID not found')),
        );
      }

      // List of screens for the tabs
      final List<Widget> screens = [
        AttendanceScreen(), // From punchin-out.dart (default tab)
        AttendanceCalendarScreen(staffId: controller.staffId!),
        StaffReportScreen(),
        StaffProfileScreen(
            staffId: controller.staffId!, salonId: controller.salonId!),
      ];

      // List of navigation bar items for Style13
      final List<PersistentBottomNavBarItem> items = [
        PersistentBottomNavBarItem(
          icon: const Icon(Icons.timer),
          title: 'Punch',
          activeColorPrimary: primaryColor,
          inactiveColorPrimary: Colors.grey,
        ),
        PersistentBottomNavBarItem(
          icon: const Icon(Icons.calendar_today),
          title: 'Timecard',
          activeColorPrimary: primaryColor,
          inactiveColorPrimary: Colors.grey,
        ),
        PersistentBottomNavBarItem(
          icon: const Icon(Icons.report),
          title: 'Reports',
          activeColorPrimary: primaryColor,
          inactiveColorPrimary: Colors.grey,
        ),
        PersistentBottomNavBarItem(
          icon: const Icon(Icons.person),
          title: 'Profile',
          activeColorPrimary: primaryColor,
          inactiveColorPrimary: Colors.grey,
        ),
      ];

      return PersistentTabView(
        context,
        controller: PersistentTabController(
            initialIndex: controller.currentIndex.value),
        screens: screens,
        items: items,
        navBarStyle: NavBarStyle.style9, // Use Style13 as specified
        backgroundColor: Colors.white, // Background color of the nav bar
        handleAndroidBackButtonPress: true,
        resizeToAvoidBottomInset: true,
        stateManagement: true, // Enable state management with GetX
        hideNavigationBarWhenKeyboardAppears: true,
        decoration: NavBarDecoration(
          borderRadius: BorderRadius.circular(10.0),
          colorBehindNavBar: Colors.white,
        ),
        navBarHeight: 60.0, // Adjust height if needed
        onItemSelected: (index) {
          controller.currentIndex.value =
              index; // Update current index in GetX controller
        },
      );
    });
  }
}
