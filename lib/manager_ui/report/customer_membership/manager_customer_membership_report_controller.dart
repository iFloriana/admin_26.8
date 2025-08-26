import 'package:get/get.dart';

import '../../../main.dart';
import '../../../network/network_const.dart';
import '../../../wiget/custome_snackbar.dart';

class Customer {
  final String id;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String gender;
  final String? imageUrl;
  final String? membershipName;
  final int? membershipDiscount;
  final String? membershipValidTill;

  Customer({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.gender,
    this.imageUrl,
    this.membershipName,
    this.membershipDiscount,
    this.membershipValidTill,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    final membership = json['branch_membership'];
    return Customer(
      id: json['_id'] ?? '',
      fullName: json['full_name'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      gender: json['gender'] ?? '',
      imageUrl: json['image_url'],
      membershipName: membership?['membership_name'],
      membershipDiscount: membership?['discount'],
      membershipValidTill: json['branch_membership_valid_till'],
    );
  }
}
class ManagerCustomerMembershipReportController extends GetxController {
  var customers = <Customer>[].obs;
  var isLoading = false.obs;
  var page = 1;
  final int limit = 10; // fetch 10 at a time
  var hasMore = true.obs;

  Future<void> getCustomers({bool loadMore = false}) async {
    if (isLoading.value) return;
    if (!loadMore) {
      page = 1;
      customers.clear();
      hasMore.value = true;
    }

    isLoading.value = true;
    try {
      final loginUser = await prefs.getManagerUser();
      if (loginUser == null) return;

      final response = await dioClient.getData(
        '${Apis.baseUrl}/customers?salon_id=${loginUser?.manager?.salonId}&page=$page&limit=$limit',
        (json) => json,
      );

      if (response != null && response['data'] != null) {
        final fetched = (response['data'] as List)
            .map((e) => Customer.fromJson(e))
            .where(
                (c) => c.membershipName != null && c.membershipName!.isNotEmpty)
            .toList();

        if (fetched.length < limit) {
          hasMore.value = false; // no more records
        }

        customers.addAll(fetched);
        page++;
      }
    } catch (e) {
      CustomSnackbar.showError("Error", "Failed to fetch customers: $e");
    } finally {
      isLoading.value = false;
    }
  }
}

