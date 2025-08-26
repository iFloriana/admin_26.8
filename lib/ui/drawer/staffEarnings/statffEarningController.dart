import 'dart:async';
import 'package:flutter_template/main.dart';
import 'package:flutter_template/network/network_const.dart';
import 'package:get/get.dart';
import '../../../wiget/custome_snackbar.dart';

class Statffearningcontroller extends GetxController {
  RxList staffEarnings = [].obs;
  RxBool isLoading = false.obs;
  RxString searchQuery = ''.obs;

  List get filteredStaffEarnings => staffEarnings.where((staff) {
        final name = (staff['staff_name'] ?? '').toString().toLowerCase();
        return name.contains(searchQuery.value.toLowerCase());
      }).toList();

  @override
  void onInit() {
    super.onInit();
    getStaffEarningData();
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  Future<void> getStaffEarningData() async {
    isLoading.value = true;
    try {
      final loginUser = await prefs.getUser();
      final response = await dioClient.getData(
        '${Apis.baseUrl}/staffEarnings?salon_id=${loginUser!.salonId}',
        (json) => json,
      );
      staffEarnings.value = response ?? [];
    } catch (e) {
      CustomSnackbar.showError('Error', ': $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> payoutStaff({
    required String staffId,
    required String paymentMethod,
    required String description,
  }) async {
    try {
      final loginUser = await prefs.getUser();
      final response = await dioClient.postData(
        '${Apis.baseUrl}/staffEarnings/pay/$staffId',
        {
          "payment_method": paymentMethod.toLowerCase(),
          "discription": description,
          "salon_id": loginUser!.salonId,
        },
        (json) => json,
      );
      await getStaffEarningData();
      Get.back(); // Close bottom sheet
      CustomSnackbar.showSuccess('Success', response['message'] ?? 'Paid out!');
    } catch (e) {
      CustomSnackbar.showError('Error', 'Failed to payout: $e');
    }
  }
}
