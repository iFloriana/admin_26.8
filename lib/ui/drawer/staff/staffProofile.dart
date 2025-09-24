import 'package:flutter/material.dart';
import 'package:flutter_template/utils/colors.dart';
import 'package:flutter_template/network/network_const.dart';
import 'package:flutter_template/ui/drawer/staff/staffDetailsController.dart';
import 'package:flutter_template/wiget/appbar/commen_appbar.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class StaffProfileScreen extends StatelessWidget {
  final Data staff;
  StaffProfileScreen({super.key, required this.staff});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // Updated to 3 tabs
      child: Scaffold(
        appBar: CustomAppBar(
          title: staff.fullName ?? 'Staff Profile',
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
              Tab(text: 'Attendance'),
              Tab(text: 'Performance'), // New Performance tab
            ],
          ),
        ),
        body: TabBarView(
          children: [
            StaffDetailsTab(staff: staff),
            AttendanceTab(staff: staff),
            PerformanceTab(staff: staff), // New Performance tab widget
          ],
        ),
      ),
    );
  }
}

class StaffDetailsTab extends StatelessWidget {
  final Data staff;
  const StaffDetailsTab({super.key, required this.staff});

  @override
  Widget build(BuildContext context) {
    // Date formatter for YYYY-MM-DD
    final DateFormat dateFormatter = DateFormat('yyyy-MM-dd');

    // Format createdAt date
    String formattedJoiningDate = 'N/A';
    if (staff.createdAt != null) {
      try {
        final DateTime parsedDate = DateTime.parse(staff.createdAt!);
        formattedJoiningDate = dateFormatter.format(parsedDate);
      } catch (e) {
        formattedJoiningDate = 'Invalid Date';
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.deepPurple.shade100,
              backgroundImage: staff.image != null
                  ? NetworkImage(
                      '${Apis.pdfUrl}${staff.image}?v=${DateTime.now().millisecondsSinceEpoch}',
                    )
                  : null,
              child: staff.image == null
                  ? const Icon(Icons.person, size: 50, color: Colors.white)
                  : null,
            ),
          ),
          const SizedBox(height: 20),
          _buildDetailRow('Name', staff.fullName ?? 'N/A'),
          _buildDetailRow('Email', staff.email ?? 'N/A'),
          _buildDetailRow('Phone', staff.phoneNumber ?? 'N/A'),
          _buildDetailRow('Gender', staff.gender ?? 'N/A'),
          _buildDetailRow('Specialization', staff.specialization ?? 'N/A'),
          _buildDetailRow('Branch', staff.branchId?.name ?? 'N/A'),
          _buildDetailRow('Commission', staff.commissionId?.name ?? 'N/A'),
          _buildDetailRow(
            'Services',
            staff.serviceId?.map((s) => s.name).join(', ') ?? 'N/A',
          ),
          _buildDetailRow(
            'Shift',
            '${staff.assignTime?.startShift ?? 'N/A'} - ${staff.assignTime?.endShift ?? 'N/A'}',
          ),
          _buildDetailRow(
            'Lunch',
            '${staff.lunchTime?.timing ?? 'N/A'} (${staff.lunchTime?.duration ?? 0} min)',
          ),
          _buildDetailRow('Status', staff.status == 1 ? 'Active' : 'Inactive'),
          _buildDetailRow('Joining At', formattedJoiningDate),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}

class AttendanceTab extends StatelessWidget {
  final Data staff;
  const AttendanceTab({super.key, required this.staff});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_note, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 20),
          Text(
            'Attendance records for ${staff.fullName ?? "Staff"}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          const Text(
            'No attendance data available',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class PerformanceTab extends StatelessWidget {
  final Data staff;
  const PerformanceTab({super.key, required this.staff});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bar_chart, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 20),
          Text(
            'Performance records for ${staff.fullName ?? "Staff"}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          const Text(
            'No performance data available',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
