import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_template/main.dart';
import 'package:flutter_template/network/network_const.dart';
import 'package:flutter_template/ui/drawer/customers/customerController.dart';
import 'package:flutter_template/utils/colors.dart';
import 'package:flutter_template/wiget/appbar/commen_appbar.dart';
import 'package:flutter_template/wiget/custome_snackbar.dart';
import 'package:flutter_template/wiget/loading.dart';
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
          bottom: TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            dividerColor: Colors.transparent,
            labelStyle: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
            unselectedLabelStyle: TextStyle(fontSize: 14.sp),
            tabs: const [
              Tab(text: 'Profile'),
              Tab(text: 'Membership & Package'),
              Tab(text: 'History'),
            ],
          ),
          title: customer.fullName ?? 'Customer Profile',
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.grey.shade100, Colors.white],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: TabBarView(
            children: [
              ProfileTab(customer: customer),
              MembershipPackageTab(customer: customer),
              HistoryTab(customer: customer),
            ],
          ),
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
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.deepPurple.shade100,
                      Colors.deepPurple.shade50
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: CircleAvatar(
                  radius: 60.r,
                  backgroundColor: Colors.white,
                  child: customer.image != null && customer.image!.isNotEmpty
                      ? ClipOval(
                          child: CachedNetworkImage(
                            imageUrl:
                                '${Apis.pdfUrl}${customer.image}?v=${DateTime.now().millisecondsSinceEpoch}',
                            fit: BoxFit.cover,
                            width: 120.w,
                            height: 120.h,
                            placeholder: (context, url) =>
                                const CustomLoadingAvatar(),
                            errorWidget: (context, url, error) => const Icon(
                              Icons.person,
                              size: 60,
                              color: Colors.grey,
                            ),
                          ),
                        )
                      : const Icon(
                          Icons.person,
                          size: 60,
                          color: Colors.grey,
                        ),
                ),
              ),
            ),
          ),
          SizedBox(height: 24.h),
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Personal Details',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  _buildDetailRow('Name', customer.fullName ?? 'N/A'),
                  _buildDetailRow('Email', customer.email ?? 'N/A'),
                  _buildDetailRow('Phone', customer.phoneNumber ?? 'N/A'),
                  _buildDetailRow('Gender', customer.gender ?? 'N/A'),
                  _buildDetailRow(
                      'Status', customer.status == 1 ? 'Active' : 'Inactive'),
                  _buildDetailRow(
                      'Packages',
                      customer.packageAndMembership
                              ?.where((item) => item['branch_package'] != null)
                              .map((item) =>
                                  item['branch_package']['package_name']
                                      ?.toString() ??
                                  'N/A')
                              .join(', ') ??
                          'N/A'),
                  _buildDetailRow(
                      'Membership',
                      customer.packageAndMembership
                              ?.firstWhereOrNull((item) =>
                                  item['branch_membership'] !=
                                  null)?['branch_membership']['membership_name']
                              ?.toString() ??
                          'N/A'),
                ],
              ),
            ),
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
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.black54,
              ),
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
    final packageAndMembership = customer.packageAndMembership ?? [];
    final packages = packageAndMembership
        .where((item) => item['branch_package'] != null)
        .toList();
    final memberships = packageAndMembership
        .where((item) => item['branch_membership'] != null)
        .toList();

    if (packageAndMembership.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.card_membership,
                size: 80.sp, color: Colors.grey.shade400),
            SizedBox(height: 20.h),
            Text(
              'Membership & Package for ${customer.fullName ?? "Customer"}',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              'No package or membership found',
              style: TextStyle(fontSize: 16.sp, color: Colors.grey.shade600),
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
          if (packages.isNotEmpty) ...[
            Text(
              'Packages',
              style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                  color: primaryColor),
            ),
            SizedBox(height: 12.h),
            ...packages.map((package) => Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.r),
                      gradient: LinearGradient(
                        colors: [
                          Colors.white,
                          Colors.grey.shade50,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(16.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.card_giftcard,
                                  color: secondaryColor, size: 24.sp),
                              SizedBox(width: 8.w),
                              Text(
                                package['branch_package']['package_name'] ??
                                    'N/A',
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8.h),
                          _buildDetailRow(
                              'Description',
                              package['branch_package']['description'] ??
                                  'N/A'),
                          _buildDetailRow(
                              'Price',
                              package['branch_package']['package_price']
                                      ?.toString() ??
                                  'N/A'),
                          _buildDetailRow(
                              'Bought At', _formatDate(package['date'])),
                          _buildDetailRow('Valid Till',
                              _formatDate(package['expiry_date'])),
                          _buildDetailRow('Status',
                              package['status']?.toUpperCase() ?? 'N/A'),
                          if (package['branch_package']['package_details'] !=
                                  null &&
                              package['branch_package']['package_details']
                                  .isNotEmpty) ...[
                            SizedBox(height: 12.h),
                            Text(
                              'Services Included:',
                              style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87),
                            ),
                            ...package['branch_package']['package_details']
                                .map<Widget>((service) => Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 4.h),
                                      child: Row(
                                        children: [
                                          Icon(Icons.circle,
                                              size: 8.sp,
                                              color: secondaryColor),
                                          SizedBox(width: 8.w),
                                          Expanded(
                                            child: Text(
                                              'Service: ${service['service_id']['name'] ?? 'N/A'}, Price: ${service['discounted_price'] ?? 'N/A'}, Quantity: ${service['quantity'] ?? 'N/A'}',
                                              style: TextStyle(fontSize: 14.sp),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ))
                                .toList(),
                          ],
                        ],
                      ),
                    ),
                  ),
                )),
          ],
          if (memberships.isNotEmpty) ...[
            SizedBox(height: 20.h),
            Text(
              'Memberships',
              style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                  color: primaryColor),
            ),
            SizedBox(height: 12.h),
            ...memberships.map((membership) => Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.r),
                      gradient: LinearGradient(
                        colors: [
                          Colors.white,
                          Colors.grey.shade50,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(16.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.star,
                                  color: secondaryColor, size: 24.sp),
                              SizedBox(width: 8.w),
                              Text(
                                membership['branch_membership']
                                        ['membership_name'] ??
                                    'N/A',
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8.h),
                          _buildDetailRow(
                              'Description',
                              membership['branch_membership']['description'] ??
                                  'N/A'),
                          _buildDetailRow(
                              'Amount',
                              membership['branch_membership']
                                          ['membership_amount']
                                      ?.toString() ??
                                  'N/A'),
                          _buildDetailRow(
                              'Discount',
                              membership['branch_membership']['discount'] !=
                                      null
                                  ? '${membership['branch_membership']['discount']}${membership['branch_membership']['discount_type'] == 'percentage' ? '%' : ''}'
                                  : 'N/A'),
                          _buildDetailRow(
                              'Subscription Plan',
                              membership['branch_membership']
                                      ['subscription_plan'] ??
                                  'N/A'),
                          _buildDetailRow(
                              'Bought At', _formatDate(membership['date'])),
                          _buildDetailRow('Valid Till',
                              _formatDate(membership['expiry_date'])),
                          _buildDetailRow('Status',
                              membership['status']?.toUpperCase() ?? 'N/A'),
                        ],
                      ),
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
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120.w,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15.sp,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 15.sp,
                color: Colors.black54,
              ),
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
          return const Center(
            child: CustomLoadingAvatar(),
          );
        } else if (snapshot.hasError || snapshot.data == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline,
                    size: 80.sp, color: Colors.red.shade300),
                SizedBox(height: 20.h),
                Text(
                  'History for ${customer.fullName ?? "Customer"}',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  'Error fetching history',
                  style: TextStyle(fontSize: 16.sp, color: Colors.red.shade400),
                ),
              ],
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
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  'No history data available',
                  style:
                      TextStyle(fontSize: 16.sp, color: Colors.grey.shade600),
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
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.r),
                    gradient: LinearGradient(
                      colors: [
                        Colors.white,
                        Colors.grey.shade50,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.history_toggle_off,
                                color: secondaryColor, size: 24.sp),
                            SizedBox(width: 8.w),
                            Text(
                              _formatDate(visit['visit_date']),
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8.h),
                        _buildDetailRow(
                            'Branch', visit['branch_name'] ?? 'N/A'),
                        _buildDetailRow(
                            'Status', visit['status']?.toUpperCase() ?? 'N/A'),
                        _buildDetailRow('Services',
                            (visit['services'] as List?)?.join(', ') ?? 'N/A'),
                      ],
                    ),
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
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120.w,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15.sp,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 15.sp,
                color: Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
