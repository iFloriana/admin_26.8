import 'package:get/get.dart';
import 'package:flutter_template/main.dart';
import 'package:flutter_template/network/network_const.dart';
import 'package:flutter_template/wiget/custome_snackbar.dart';

class ManagerCouponBranchInfo {
  final String? id;
  final String? name;
  ManagerCouponBranchInfo({this.id, this.name});
  factory ManagerCouponBranchInfo.fromJson(Map<String, dynamic> json) {
    return ManagerCouponBranchInfo(id: json['_id'], name: json['name']);
  }
}

class ManagerCoupon {
  final String? id;
  final String? name;
  final String? description;
  final String? couponType;
  final String? couponCode;
  final String? discountType;
  final num? discountAmount;
  final int? useLimit;
  final int? status;
  final String? startDate;
  final String? endDate;
  final String? imageUrl;
  final List<ManagerCouponBranchInfo> branches;

  ManagerCoupon({
    this.id,
    this.name,
    this.description,
    this.couponType,
    this.couponCode,
    this.discountType,
    this.discountAmount,
    this.useLimit,
    this.status,
    this.startDate,
    this.endDate,
    this.imageUrl,
    this.branches = const [],
  });

  factory ManagerCoupon.fromJson(Map<String, dynamic> json) {
    final List<ManagerCouponBranchInfo> parsedBranches =
        (json['branch_id'] is List)
            ? (json['branch_id'] as List)
                .map((b) => ManagerCouponBranchInfo.fromJson(b))
                .toList()
            : <ManagerCouponBranchInfo>[];
    return ManagerCoupon(
      id: json['_id'],
      name: json['name'],
      description: json['description'],
      couponType: json['coupon_type'],
      couponCode: json['coupon_code'],
      discountType: json['discount_type'],
      discountAmount: json['discount_amount'],
      useLimit: json['use_limit'],
      status: json['status'],
      startDate: json['start_date'],
      endDate: json['end_date'],
      imageUrl: json['image_url'],
      branches: parsedBranches,
    );
  }
}

class ManagerCouponsController extends GetxController {
  var coupons = <ManagerCoupon>[].obs;
  var filteredCoupons = <ManagerCoupon>[].obs;
  var isLoading = false.obs;
  var isSearching = false.obs;

  @override
  void onInit() {
    super.onInit();
    getCoupons();
  }

  Future<void> getCoupons() async {
    final manager = await prefs.getManagerUser();
    if (manager == null) return;
    isLoading.value = true;
    try {
      final response = await dioClient.getData(
        '${Apis.baseUrl}/coupons/by-branch?salon_id=${manager.manager?.salonId}&branch_id=${manager.manager?.branchId?.sId}',
        (json) => json,
      );
      if (response != null && response['data'] is List) {
        final List data = response['data'];
        coupons.value = data.map((e) => ManagerCoupon.fromJson(e)).toList();
        filteredCoupons.value = List<ManagerCoupon>.from(coupons);
      } else {
        coupons.clear();
        filteredCoupons.clear();
      }
    } catch (e) {
      CustomSnackbar.showError('Error', 'Failed to load coupons: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void setSearchQuery(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) {
      filteredCoupons.value = List<ManagerCoupon>.from(coupons);
      return;
    }
    filteredCoupons.value =
        coupons.where((c) => (c.name ?? '').toLowerCase().contains(q)).toList();
  }

  void clearSearch() {
    filteredCoupons.value = List<ManagerCoupon>.from(coupons);
  }
}
