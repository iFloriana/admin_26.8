import 'package:flutter/material.dart';
import 'package:flutter_template/main.dart';

import 'package:flutter_template/network/network_const.dart';

import 'package:flutter_template/wiget/custome_snackbar.dart';
import 'package:get/get.dart';

class Adminprofilecontroller extends GetxController {
  var fullnameController = TextEditingController();
  var salonNameController = TextEditingController();
  var addressController = TextEditingController();
  var emailController = TextEditingController();
  var phoneController = TextEditingController();

  var passwordController = TextEditingController();
  var oldPasswordController = TextEditingController();
  var confirmPasswordController = TextEditingController();

  var showPassword = false.obs;
  var showOldPassword = false.obs;
  var showConfirmPassword = false.obs;

  void toggleShowPassword() {
    showPassword.value = !showPassword.value;
  }

  void toggleShowConfirmPass() {
    showConfirmPassword.value = !showConfirmPassword.value;
  }

  void toggleShowOldPass() {
    showOldPassword.value = !showOldPassword.value;
  }

  var pincodeController = TextEditingController();

  var country = ''.obs;
  var state = ''.obs;
  var district = ''.obs;
  var block = ''.obs;
  var isLoading = false.obs;
  var error = ''.obs;

  var isExpanded_Details = false.obs;
  var isExpanded_pass = false.obs;

  void expand_details() {
    isExpanded_Details.value = !isExpanded_Details.value;
  }

  void expand_pass() {
    isExpanded_pass.value = !isExpanded_pass.value;
  }

  @override
  void onInit() {
    super.onInit();
    getProfileData();
  }

  void getProfileData() async {
    final profileDetails = await prefs.getRegisterdetails();
    fullnameController.text = profileDetails?.admin?.fullName ?? '';
    salonNameController.text = profileDetails?.salonDetails?.salonName ?? '';
    addressController.text = profileDetails?.admin?.address ?? '';
    emailController.text = profileDetails?.admin?.email ?? '';
    phoneController.text = profileDetails?.admin?.phoneNumber ?? '';
  }

  Future onProdileUpdate() async {
    Map<String, dynamic> data = {
      'full_name': fullnameController.text,
      'phone_number': phoneController.text,
      'email': emailController.text,
      'address': addressController.text,
      'salonDetails[salon_name]': salonNameController.text,
    };

    try {
      final loginUser = await prefs.getUser();
      await dioClient.putData(
        '${Apis.baseUrl}${Endpoints.get_register_details}${loginUser?.adminId}',
        data,
        (json) => (json),
      );
      await prefs.onLogout();
    } catch (e) {
      CustomSnackbar.showError('Error', e.toString());
    }
  }

  Future onChangePAssword() async {
    final loginUser = await prefs.getUser();
    Map<String, dynamic> changeData = {
      'email': loginUser!.email,
      'old_password': oldPasswordController.text,
      'new_password': passwordController.text,
      'confirm_password': confirmPasswordController.text,
    };

    try {
      await dioClient.postData(
        '${Apis.baseUrl}${Endpoints.resetPass}',
        changeData,
        (json) => json,
      );

      CustomSnackbar.showSuccess('Success', 'password update  successfully');
      await prefs.onLogout();
    } catch (e) {
      CustomSnackbar.showError('Error', e.toString());
    }
  }

  jsonDecode(Map<String, dynamic> response) {}
}
