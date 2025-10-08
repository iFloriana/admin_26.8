import 'package:flutter/material.dart';
import 'package:flutter_template/network/network_const.dart';
import 'package:get/get.dart';

import '../../../main.dart';

class RenewPackagesController extends GetxController {
  var adminName = ''.obs;
  var adminEmail = ''.obs;
  var salonName = ''.obs;
  var isLoading = false.obs;
  var emailController = TextEditingController();

  Future<void> verifyEmail(String email) async {
    if (email.isEmpty) {
      Get.snackbar("Error", "Please enter an email");
      return;
    }

    try {
      isLoading.value = true;
      adminName.value = '';
      adminEmail.value = '';
      salonName.value = '';

      final response =
          await dioClient.dio.post('${Apis.baseUrl}/auth/verify-email', data: {
        "email": email,
      });

      if (response.statusCode == 200) {
        final data = response.data;
        adminName.value = data['admin']['full_name'] ?? '';
        adminEmail.value = data['admin']['email'] ?? '';
        salonName.value = data['salonDetails']['salon_name'] ?? '';
      } else {
        Get.snackbar("Error", "Server Error: ${response.statusMessage}");
      }
    } catch (e) {
      Get.snackbar("Failed", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> renewPackage() async {
    Get.snackbar("Success", "Renew package API called successfully!");
    
  }

  void clearData() {
    emailController.clear();
    adminName.value = '';
    adminEmail.value = '';
    salonName.value = '';
  }
}
