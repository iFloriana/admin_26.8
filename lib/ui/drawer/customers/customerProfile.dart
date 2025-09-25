import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_template/main.dart';
import 'package:flutter_template/network/network_const.dart';
import 'package:flutter_template/ui/drawer/customers/customerController.dart';
import 'package:flutter_template/utils/colors.dart';
import 'package:flutter_template/wiget/appbar/commen_appbar.dart';
import 'package:flutter_template/wiget/custome_snackbar.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart'; // For date formatting

class CustomerProfileScreen extends StatelessWidget {
  CustomerProfileScreen({super.key, required this.customer});
  final Customer customer;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: CustomAppBar(
          title: customer.fullName ?? 'Customer Profile',
          bottom: TabBar(
            indicatorColor: secondaryColor,
            labelColor: Colors.white,
            splashBorderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(20.0),
            ),
            unselectedLabelColor: secondaryColor,
            dividerColor: Colors.transparent,
            labelStyle: TextStyle(fontSize: 14.sp),
            unselectedLabelStyle: TextStyle(fontSize: 14.sp),
            tabs: const [
              Tab(text: 'Profile'),
              Tab(text: 'Membership & Package'),
              Tab(text: 'History'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            ProfileTab(customer: customer),
            MembershipPackageTab(customer: customer),
            HistoryTab(customer: customer),
          ],
        ),
      ),
    );
  }
}

class ProfileTab extends StatelessWidget {
  final Customer customer;
  const ProfileTab({super.key, required this.customer});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: CircleAvatar(
              radius: 50.r,
              backgroundColor: Colors.deepPurple.shade100,
              child: customer.image != null && customer.image!.isNotEmpty
                  ? ClipOval(
                      child: CachedNetworkImage(
                        imageUrl:
                            '${Apis.pdfUrl}${customer.image}?v=${DateTime.now().millisecondsSinceEpoch}',
                        fit: BoxFit.cover,
                        width: 100.w,
                        height: 100.h,
                        placeholder: (context, url) =>
                            const CircularProgressIndicator(),
                        errorWidget: (context, url, error) => const Icon(
                          Icons.person,
                          size: 50,
                          color: Colors.white,
                        ),
                      ),
                    )
                  : const Icon(
                      Icons.person,
                      size: 50,
                      color: Colors.white,
                    ),
            ),
          ),
          SizedBox(height: 20.h),
          _buildDetailRow('Name', customer.fullName ?? 'N/A'),
          _buildDetailRow('Email', customer.email ?? 'N/A'),
          _buildDetailRow('Phone', customer.phoneNumber ?? 'N/A'),
          _buildDetailRow('Gender', customer.gender ?? 'N/A'),
          _buildDetailRow(
              'Status', customer.status == 1 ? 'Active' : 'Inactive'),
          _buildDetailRow(
              'Packages', customer.branchPackage.join(', ') ?? 'N/A'),
          _buildDetailRow(
            'Membership',
            customer.branchMembershipObj?['name']?.toString() ?? 'N/A',
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120.w,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16.sp,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 16.sp, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}

class MembershipPackageTab extends StatelessWidget {
  final Customer customer;
  const MembershipPackageTab({super.key, required this.customer});

  String _formatDate(String? date) {
    if (date == null) return 'N/A';
    try {
      final parsedDate = DateTime.parse(date);
      return DateFormat('MMM dd, yyyy').format(parsedDate);
    } catch (e) {
      return date;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (customer.branchPackages.isEmpty && customer.branchMemberships.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.card_membership,
                size: 80.sp, color: Colors.grey.shade400),
            SizedBox(height: 20.h),
            Text(
              'Membership & Package for ${customer.fullName ?? "Customer"}',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 10.h),
            Text(
              'No membership or package data available',
              style: TextStyle(fontSize: 16.sp, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (customer.branchPackages.isNotEmpty) ...[
            Text(
              'Packages',
              style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10.h),
            ...customer.branchPackages.map((package) => Card(
                  margin: EdgeInsets.symmetric(vertical: 8.h),
                  child: Padding(
                    padding: EdgeInsets.all(12.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetailRow(
                            'Name',
                            package['branch_package_id']['package_name'] ??
                                'N/A'),
                        _buildDetailRow(
                            'Description',
                            package['branch_package_id']['description'] ??
                                'N/A'),
                        _buildDetailRow(
                            'Price',
                            package['branch_package_id']['package_price']
                                    ?.toString() ??
                                'N/A'),
                        _buildDetailRow(
                            'Bought At', _formatDate(package['bought_at'])),
                        _buildDetailRow(
                            'Valid Till', _formatDate(package['valid_till'])),
                        _buildDetailRow('Status',
                            package['status']?.toUpperCase() ?? 'N/A'),
                        if (package['branch_package_id']['package_details'] !=
                                null &&
                            package['branch_package_id']['package_details']
                                .isNotEmpty) ...[
                          SizedBox(height: 8.h),
                          Text(
                            'Services Included:',
                            style: TextStyle(
                                fontSize: 16.sp, fontWeight: FontWeight.w600),
                          ),
                          ...package['branch_package_id']['package_details']
                              .map<Widget>((service) => Padding(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 4.h),
                                    child: Text(
                                      '• Service ID: ${service['service_id']}, Price: ${service['discounted_price']}, Quantity: ${service['quantity']}',
                                      style: TextStyle(fontSize: 14.sp),
                                    ),
                                  ))
                              .toList(),
                        ],
                      ],
                    ),
                  ),
                )),
          ],
          if (customer.branchMemberships.isNotEmpty) ...[
            SizedBox(height: 20.h),
            Text(
              'Memberships',
              style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10.h),
            ...customer.branchMemberships.map((membership) => Card(
                  margin: EdgeInsets.symmetric(vertical: 8.h),
                  child: Padding(
                    padding: EdgeInsets.all(12.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetailRow(
                            'Name',
                            membership['branch_membership_id']
                                    ['membership_name'] ??
                                'N/A'),
                        _buildDetailRow(
                            'Description',
                            membership['branch_membership_id']['description'] ??
                                'N/A'),
                        _buildDetailRow(
                            'Amount',
                            membership['branch_membership_id']
                                        ['membership_amount']
                                    ?.toString() ??
                                'N/A'),
                        _buildDetailRow(
                            'Discount',
                            membership['branch_membership_id']['discount'] !=
                                    null
                                ? '${membership['branch_membership_id']['discount']}${membership['branch_membership_id']['discount_type'] == 'percentage' ? '%' : ''}'
                                : 'N/A'),
                        _buildDetailRow(
                            'Subscription Plan',
                            membership['branch_membership_id']
                                    ['subscription_plan'] ??
                                'N/A'),
                        _buildDetailRow(
                            'Bought At', _formatDate(membership['bought_at'])),
                        _buildDetailRow('Valid Till',
                            _formatDate(membership['valid_till'])),
                        _buildDetailRow('Status',
                            membership['status']?.toUpperCase() ?? 'N/A'),
                      ],
                    ),
                  ),
                )),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120.w,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14.sp,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 14.sp, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}

class HistoryTab extends StatelessWidget {
  final Customer customer;
  const HistoryTab({super.key, required this.customer});

  Future<List<dynamic>> fetchVisitHistory() async {
    final loginUser = await prefs.getUser();
    try {
      final response = await dioClient.getData(
        '${Apis.baseUrl}/customers/visit-history/${customer.id}?salon_id=${loginUser!.salonId}',
        (json) => json as Map<String, dynamic>,
      );
      if (response['success'] == true) {
        return response['data'] as List<dynamic>;
      } else {
        throw Exception('Failed to fetch visit history');
      }
    } catch (e) {
      CustomSnackbar.showError('Error', 'Failed to fetch visit history: $e');
      return [];
    }
  }

  String _formatDate(String? date) {
    if (date == null) return 'N/A';
    try {
      final parsedDate = DateTime.parse(date);
      return DateFormat('MMM dd, yyyy').format(parsedDate);
    } catch (e) {
      return date;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: fetchVisitHistory(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError || snapshot.data == null) {
          return Center(
            child: Text(
              'Error fetching history',
              style: TextStyle(fontSize: 16.sp, color: Colors.red),
            ),
          );
        } else if (snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history, size: 80.sp, color: Colors.grey.shade400),
                SizedBox(height: 20.h),
                Text(
                  'History for ${customer.fullName ?? "Customer"}',
                  style:
                      TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 10.h),
                Text(
                  'No history data available',
                  style: TextStyle(fontSize: 16.sp, color: Colors.grey),
                ),
              ],
            ),
          );
        } else {
          final history = snapshot.data!;
          return ListView.builder(
            padding: EdgeInsets.all(16.w),
            itemCount: history.length,
            itemBuilder: (context, index) {
              final visit = history[index];
              return Card(
                margin: EdgeInsets.symmetric(vertical: 8.h),
                child: Padding(
                  padding: EdgeInsets.all(12.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow(
                          'Visit Date', _formatDate(visit['visit_date'])),
                      _buildDetailRow('Branch', visit['branch_name'] ?? 'N/A'),
                      _buildDetailRow(
                          'Status', visit['status']?.toUpperCase() ?? 'N/A'),
                      _buildDetailRow('Services',
                          (visit['services'] as List?)?.join(', ') ?? 'N/A'),
                    ],
                  ),
                ),
              );
            },
          );
        }
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120.w,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14.sp,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 14.sp, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
