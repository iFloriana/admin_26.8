import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../../../main.dart';
import '../../../network/model/forgot_model.dart';
import '../../../network/network_const.dart';
import '../../../wiget/custome_snackbar.dart';

class ForgotController extends GetxController {
  var emailController = TextEditingController();

  Future onForgotPress() async {
    Map<String, dynamic> forgotData = {
      'email': emailController.text,
    };

    try {
      await dioClient.postData<forgot_model>(
        '${Apis.baseUrl}${Endpoints.admin_forgot}',
        forgotData,
        (json) => forgot_model.fromJson(json),
      );
      CustomSnackbar.showSuccess(
          'Succcess', 'Password reset link sent to your email');
      await prefs.onLogout();
    } catch (e) {
      print('==> here Error: $e');
      CustomSnackbar.showError('Error', e.toString());
    }
  }
}
