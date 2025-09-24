import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_template/ui/drawer/customers/customerController.dart';
import 'package:flutter_template/utils/colors.dart';
import 'package:flutter_template/network/network_const.dart';
import 'package:flutter_template/wiget/appbar/commen_appbar.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';

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

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.card_membership, size: 80.sp, color: Colors.grey.shade400),
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
}

class HistoryTab extends StatelessWidget {
  final Customer customer;
  const HistoryTab({super.key, required this.customer});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 80.sp, color: Colors.grey.shade400),
          SizedBox(height: 20.h),
          Text(
            'History for ${customer.fullName ?? "Customer"}',
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 10.h),
          Text(
            'No history data available',
            style: TextStyle(fontSize: 16.sp, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
