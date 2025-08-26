import 'package:flutter/material.dart';
import 'package:flutter_template/main.dart';
import 'package:flutter_template/network/model/BranchMembership.dart';
import 'package:get/get.dart';
import '../../../../network/network_const.dart';
import '../../../../wiget/custome_snackbar.dart';

class Branchmembershipaddcontroller extends GetxController {
  var selected_Subscription_plan = ''.obs;
  final List<String> Subscription_plan_option = [
    '1-Month',
    '3-Months',
    '6-Months',
    '12-Months',
    'Lifetime'
  ];
  var descriptionController = TextEditingController();
  var memberShipNameController = TextEditingController();
  var discountAmountController = TextEditingController();
  var membershipAmountController = TextEditingController();
  var selected_discountType = ''.obs;
  var isActive = true.obs;
  final List<String> discountType_option = ['Fixed', 'Percentage'];

  @override
  void onInit() {
    super.onInit();
  }

  Future onBranchAdd() async {
    final loginUser = await prefs.getUser();
    Map<String, dynamic> membershipData = {
      'membership_name': memberShipNameController.text,
      'description': descriptionController.text,
      'subscription_plan': selected_Subscription_plan.value.toLowerCase(),
      'status': isActive.value ? 1 : 0,
      'discount': discountAmountController.text,
      'discount_type': selected_discountType.value.toLowerCase(),
      'membership_amount': membershipAmountController.text,
      'salon_id': loginUser!.salonId
    };

    try {
      await dioClient.postData<BranchMemberShip>(
        '${Apis.baseUrl}${Endpoints.postBranchMembership}',
        membershipData,
        (json) => BranchMemberShip.fromJson(json),
      );
      CustomSnackbar.showSuccess(
          'Success', 'Branch Membership Added successfully');
    } catch (e) {
      print('==> here Error: $e');
      CustomSnackbar.showError('Error', e.toString());
    }
  }
}
