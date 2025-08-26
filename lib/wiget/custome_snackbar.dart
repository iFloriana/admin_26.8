import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomSnackbar {
  static void showError(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      leftBarIndicatorColor: Colors.red,
      backgroundColor: Colors.red.withOpacity(0.1),
      borderRadius: 10,
      margin: const EdgeInsets.all(15),
      colorText: Colors.black,
      duration: const Duration(seconds: 3),
    );
  }

  static void showSuccess(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      leftBarIndicatorColor: Colors.green,
      backgroundColor: Colors.green.withOpacity(0.1),
      borderRadius: 10,
      margin: const EdgeInsets.all(15),
      colorText: Colors.black,
      duration: const Duration(seconds: 3),
    );
  }
}
