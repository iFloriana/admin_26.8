import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_template/main.dart';
import 'package:flutter_template/network/network_const.dart';
import 'package:flutter_template/staff_app/reports.dart';
import 'package:flutter_template/staff_app/staffprofile.dart';
import 'package:flutter_template/staff_app/timecard.dart';
import 'package:flutter_template/utils/colors.dart';
import 'package:flutter_template/wiget/appbar/commen_appbar.dart';
import 'package:flutter_template/wiget/custome_snackbar.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

class AttendanceController extends GetxController {
  var punchInTime = Rx<String?>(null);
  var punchOutTime = Rx<String?>(null);
  var isPunching = false.obs;
  var staffData = {}.obs;
  var loading = false.obs;
  String? staffId;
  String? salonId;

  String? staffname;

  // New computed property to easily access the staff name
  // String get staffName => staffData['full_name'] ?? 'Staff';

  @override
  void onInit() {
    super.onInit();
    _initializeController();
  }

  // Helper function to sequence asynchronous calls
  Future<void> _initializeController() async {
    await _loadStaffDetails();
    // After staffId/salonId are set, safely fetch the attendance status
    await fetchCurrentAttendanceStatus();
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

  Future<void> fetchCurrentAttendanceStatus() async {
    if (staffId == null || salonId == null) {
      if (staffData['full_name'] == null) {
        CustomSnackbar.showError('Error', 'Staff ID or Salon ID not found');
      }
      return;
    }
    try {
      final url = '${Apis.baseUrl}/attendance/$staffId/status';
      final response = await dioClient.dio.get(url);
      if (response.statusCode == 200) {
        final data = response.data;
        punchInTime.value = data['punch_in'] as String?;
        punchOutTime.value = data['punch_out'] as String? ?? null;

        // Check if punch_in is from a previous day when punch_out is null
        if (punchInTime.value != null && punchOutTime.value == null) {
          final punchInDate = DateTime.parse(punchInTime.value!).toLocal();
          final today = DateTime.now();
          if (punchInDate.year != today.year ||
              punchInDate.month != today.month ||
              punchInDate.day != today.day) {
            punchInTime.value = null;
            CustomSnackbar.showError('Warning',
                'You forgot to punch out on the previous day. Starting fresh for today.');
          }
        }

        print(
          'Fetched Status: punchInTime = ${punchInTime.value}, punchOutTime = ${punchOutTime.value}',
        );
      }
    } catch (e) {
      CustomSnackbar.showError('Error', 'Failed to fetch status: $e');
    }
  }

  // --- Geolocation Logic ---
  Future<Position?> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      CustomSnackbar.showError('Error', 'Location services are disabled.');
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        CustomSnackbar.showError('Error', 'Location permissions are denied');
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      CustomSnackbar.showError(
        'Error',
        'Location permissions are permanently denied.',
      );
      return null;
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  // --- API Call Handler ---
  Future<void> punchIn({String? reason}) async {
    punchOutTime.value = null;
    await _handlePunchAction('punch-in', reason: reason);
  }

  Future<void> punchOut({String? reason}) async {
    await _handlePunchAction('punch-out', reason: reason);
  }

  Future<void> _handlePunchAction(String action, {String? reason}) async {
    if (isPunching.value) return;

    isPunching.value = true;
    Position? position;

    try {
      position = await _getCurrentLocation();
      if (position == null) {
        return;
      }

      // Check for IDs again before making the API call
      if (staffId == null || salonId == null) {
        CustomSnackbar.showError(
            'Error', 'Staff ID or Salon ID not available for API call');
        isPunching.value = false;
        return;
      }

      final payload = {
        "salon_id": salonId,
        "latitude": position.latitude.toString(),
        "longitude": position.longitude.toString(),
        if (reason != null) "reason": reason,
      };

      final url = '${Apis.baseUrl}/attendance/$staffId/$action';

      final response = await dioClient.dio.post(url, data: payload);
      print('API Response: ${response.data}');

      final Map<String, dynamic>? record = response.data['record'];
      final String message = response.data['message'] ?? '$action successful';

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          record != null) {
        punchInTime.value = record['punch_in'] as String?;
        punchOutTime.value = record['punch_out'] as String?;
        await fetchCurrentAttendanceStatus();
        CustomSnackbar.showSuccess('Success', message);
      } else {
        CustomSnackbar.showError('Error', message);
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        final errorMessage = e.response?.data['error'] as String?;
        if (errorMessage == 'Early or off-site punch-out requires a reason' ||
            errorMessage == 'Reason required for early/off-site punch-out' ||
            errorMessage == 'Late punch-in or off-site requires a reason' ||
            errorMessage == 'Reason required for late/off-site punch-in') {
          Get.bottomSheet(
            _buildReasonBottomSheet(action),
            isScrollControlled: true,
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
          );
        } else {
          CustomSnackbar.showError(
            'API Error',
            e.response?.data?['message'] ?? 'Failed to $action: ${e.message}',
          );
        }
      } else {
        CustomSnackbar.showError(
          'API Error',
          e.response?.data?['message'] ?? 'Failed to $action: ${e.message}',
        );
      }
    } catch (e) {
      CustomSnackbar.showError('Error', 'An unexpected error occurred: $e');
    } finally {
      isPunching.value = false;
    }
  }

  // Helper to determine the current state
  bool get isPunchedIn {
    return punchInTime.value != null && punchOutTime.value == null;
  }

  Widget _buildReasonBottomSheet(String action) {
    final TextEditingController reasonController = TextEditingController();
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [secondaryColor, primaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Icon and Title
          Row(
            children: [
              Icon(
                action == 'punch-in' ? Icons.location_off : Icons.logout,
                color: Colors.white,
                size: 30,
              ),
              // SizedBox(width: 10),
              Text(
                action == 'punch-in'
                    ? 'Reason for Off-Site Punch-In'
                    : 'Reason for Early Punch-Out',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          // SizedBox(height: 20),
          // Text Input
          Card(
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: TextField(
                controller: reasonController,
                decoration: InputDecoration(
                  hintText: 'Enter your reason here...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.grey.shade500),
                ),
                maxLines: 4,
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
            ),
          ),
          // SizedBox(height: 20),
          // Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            spacing: 10,
            children: [
              ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade200,
                  foregroundColor: Colors.black87,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                child: Text('Cancel'),
              ),
              // SizedBox(width: 10),
              ElevatedButton(
                onPressed: () async {
                  if (reasonController.text.isNotEmpty) {
                    Get.back();
                    if (action == 'punch-in') {
                      await punchIn(reason: reasonController.text);
                    } else {
                      await punchOut(reason: reasonController.text);
                    }
                  } else {
                    CustomSnackbar.showError('Error', 'Reason is required');
                  }
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.resolveWith<Color>(
                    (states) {
                      if (states.contains(MaterialState.pressed)) {
                        return secondaryColor;
                      }
                      return primaryColor;
                    },
                  ),
                  foregroundColor: MaterialStateProperty.all(Colors.white),
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  padding: MaterialStateProperty.all(
                    EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  elevation: MaterialStateProperty.all(5),
                ),
                child: Text('Submit'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// --- Modern Attendance UI Screen ---

class AttendanceScreen extends StatelessWidget {
  AttendanceScreen({super.key});

  final AttendanceController controller = Get.put(AttendanceController());

  // Helper to format the time from ISO 8601 string to local time
  String _formatTime(String? isoTime) {
    if (isoTime == null) return '---';
    try {
      final dateTime = DateTime.parse(isoTime).toLocal();
      return DateFormat('hh:mm:ss a').format(dateTime);
    } catch (e) {
      return 'N/A';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70.h),
        child: Obx(() => CustomAppBar(
              title: controller.staffData['full_name']?.toString() ?? 'Buddy',
              actions: [
                Container(
                  margin: EdgeInsets.only(right: 10.w),
                  child: GestureDetector(
                    onTap: () {
                      if (controller.staffId != null &&
                          controller.salonId != null) {
                        Get.to(() => StaffProfileScreen(
                              staffId: controller.staffId!,
                              salonId: controller.salonId!,
                            ));
                      } else {
                        CustomSnackbar.showError(
                            'Error', 'Staff or Salon ID missing');
                      }
                    },
                    child: Obx(() => CircleAvatar(
                          radius: 20.r,
                          backgroundColor: Colors.white,
                          backgroundImage:
                              controller.staffData['image_url'] != null &&
                                      controller.staffData['image_url']
                                          .toString()
                                          .isNotEmpty
                                  ? NetworkImage(
                                      "${Apis.pdfUrl}${controller.staffData['image_url']}",
                                    )
                                  : null,
                          child: controller.staffData['image_url'] == null ||
                                  controller.staffData['image_url']
                                      .toString()
                                      .isEmpty
                              ? Text(
                                  controller.staffData['full_name']?[0] ?? "?",
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.deepPurple,
                                  ),
                                )
                              : null,
                        )),
                  ),
                ),
                // SizedBox(width: 10),
              ],
            )),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Obx(() {
            final isPunchedIn = controller.isPunchedIn;
            final activeColor =
                isPunchedIn ? Colors.green.shade600 : Colors.red.shade600;

            return Column(
              spacing: 20,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _buildStatusCard(isPunchedIn, activeColor),
                // const SizedBox(height: 30),
                Row(
                  spacing: 5,
                  children: [
                    Expanded(
                      child: _buildTimeLogCard(
                        title: 'Punch In',
                        time: _formatTime(controller.punchInTime.value),
                        icon: Icons.login,
                        iconColor: primaryColor,
                        isActive: controller.punchInTime.value != null,
                      ),
                    ),
                    // const SizedBox(width: 15),
                    Expanded(
                      child: _buildTimeLogCard(
                        title: 'Punch Out',
                        time: _formatTime(controller.punchOutTime.value),
                        icon: Icons.logout,
                        iconColor: Colors.deepPurple,
                        isActive: controller.punchOutTime.value != null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildActionButton(isPunchedIn, primaryColor, activeColor),
                // const SizedBox(height: 20),
                _buildLocationInfo(Colors.grey.shade400),
                const SizedBox(height: 20),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildStatusCard(bool isPunchedIn, Color activeColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isPunchedIn
              ? [Colors.green.shade400, Colors.green.shade700]
              : [Colors.red.shade400, Colors.red.shade700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: activeColor.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isPunchedIn ? Icons.waving_hand : Icons.timer_off_outlined,
            size: 35,
            color: Colors.white,
          ),
          // const SizedBox(width: 15),
          Text(
            isPunchedIn ? 'STATUS: ACTIVE' : 'STATUS: AWAY',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeLogCard({
    required String title,
    required String time,
    required IconData icon,
    required Color iconColor,
    required bool isActive,
  }) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: iconColor, size: 30),
            // const SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
            // const SizedBox(height: 5),
            Text(
              time,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: isActive ? iconColor : Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    bool isPunchedIn,
    Color primaryColor,
    Color activeColor,
  ) {
    return SizedBox(
      height: 65,
      child: ElevatedButton.icon(
        onPressed: controller.isPunching.value
            ? null
            : () async {
                if (isPunchedIn) {
                  await controller.punchOut();
                } else {
                  await controller.punchIn();
                }
              },
        icon: controller.isPunching.value
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Icon(
                isPunchedIn ? Icons.waving_hand : Icons.thumb_up_alt_outlined,
                size: 28,
              ),
        label: Text(
          controller.isPunching.value
              ? 'Processing...'
              : isPunchedIn
                  ? 'CLOCK OUT'
                  : 'CLOCK IN',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: isPunchedIn ? Colors.red.shade700 : primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 8,
          shadowColor:
              isPunchedIn ? Colors.red.shade300 : primaryColor.withOpacity(0.5),
        ),
      ),
    );
  }

  Widget _buildLocationInfo(Color inactiveColor) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.location_on_outlined, color: inactiveColor, size: 28),
          // const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Your location is required for clocking. Please ensure GPS is enabled.',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
            ),
          ),
        ],
      ),
    );
  }
}
