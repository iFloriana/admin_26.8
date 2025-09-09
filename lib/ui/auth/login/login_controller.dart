import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_template/network/model/getAdminDetails.dart';
import 'package:get/get.dart';
import '../../../commen_items/requestData.dart';
import '../../../main.dart';
import '../../../network/model/login_model.dart';
import '../../../network/model/managerLogin.dart';
import '../../../network/network_const.dart';
import '../../../route/app_route.dart';
import '../../../wiget/custome_snackbar.dart';
import '../../../wiget/loading.dart';

class LoginController extends GetxController {
  var emailController = TextEditingController();
  var passController = TextEditingController();
  var showPass = false.obs;
  var selectedRole = "".obs;
  final List<String> dropdownItems = [
    'Admin',
    'Manager',
  ];

  void toggleShowPass() {
    showPass.value = !showPass.value;
  }

  Future onLoginPress() async {
    Map<String, dynamic> loginData = {
      'email': emailController.text,
      'password': passController.text,
    };

    try {
      Login_model loginResponse = await dioClient.postData<Login_model>(
        '${Apis.baseUrl}${Endpoints.login}',
        loginData,
        (json) => Login_model.fromJson(json),
      );

      await prefs.setUser(loginResponse);
      callgetSignupApi();
      await Get.showOverlay(
        asyncFunction: () async {
          await Future.delayed(const Duration(seconds: 2));
        },
        loadingWidget: const Center(child: CustomLoadingAvatar()),
      );
      Get.offNamed(Routes.dashboardScreen);
    } catch (e) {
      CustomSnackbar.showError('Error', e.toString());
    }
  }

  Future onLoginPressManager() async {
    ApiService api = ApiService();

    try {
      var response = await api.postRequest(
        "${Apis.baseUrl}/managers/login",
        {
          'email': emailController.text,
          'password': passController.text,
        },
      );

      if (response != null && response['manager'] != null) {
        final managerUser = ManagerLogin.fromJson(response);

        
        await prefs.setManagerUser(managerUser);

        CustomSnackbar.showSuccess("Success", "Manager Login Successfully");
        Get.offAllNamed(Routes.managerDashboard);
      } else {
        CustomSnackbar.showError("Error", "Invalid response from server");
      }
    } catch (e) {
      CustomSnackbar.showError("Error", e.toString());
    }
  }

  Future<void> callgetSignupApi() async {
    final loginUser = await prefs.getUser();
    try {
      final response = await dioClient.getData(
        '${Apis.baseUrl}${Endpoints.get_register_details}${loginUser!.adminId}',
        (json) => json,
      );
      await prefs.setRegisterdetails(GetAdminDetails.fromJson(response));
    } catch (e) {
      CustomSnackbar.showError('Error', 'Failed to check email: $e');
    }
  }
}
// 