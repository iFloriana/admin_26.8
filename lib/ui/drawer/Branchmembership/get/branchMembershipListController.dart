import 'package:flutter_template/commen_items/commen_class.dart';
import 'package:get/get.dart';
import '../../../../main.dart';
import '../../../../network/model/BranchMembership.dart';
import '../../../../network/network_const.dart';
import '../../../../wiget/custome_snackbar.dart';
import '../add/branchMembershipAddController.dart';

class BranchMembershipListController extends GetxController {
  var memberships = <BranchMemberShip>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchMemberships();
  }

  void clearAllFields() {
    if (!Get.isRegistered<Branchmembershipaddcontroller>()) {
      Get.put(Branchmembershipaddcontroller());
    }
    final addController = Get.find<Branchmembershipaddcontroller>();

    addController.memberShipNameController.clear();
    addController.descriptionController.clear();
    addController.discountAmountController.clear();
    addController.membershipAmountController.clear();

    addController.selected_Subscription_plan.value = '6-Months';
    addController.selected_discountType.value = 'Fixed';
    addController.isActive.value = true;
  }

  Future<void> fetchMemberships() async {
    final loginUser = await prefs.getUser();
    try {
      isLoading.value = true;
      final response = await dioClient.getData<Map<String, dynamic>>(
        '${Apis.baseUrl}/branch-memberships?salon_id=${loginUser!.salonId}',
        (json) => json,
      );

      if (response != null && response['data'] != null) {
        final List<dynamic> data = response['data'];
        memberships.value =
            data.map((json) => BranchMemberShip.fromJson(json)).toList();
      }
    } catch (e) {
      print('==> Error fetching memberships: $e');
      CustomSnackbar.showError('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteMembership(String membershipId) async {
    try {
      final loginUser = await prefs.getUser();
      isLoading.value = true;
      final response = await dioClient.deleteData(
        '${Apis.baseUrl}${Endpoints.postBranchMembership}/$membershipId?salon_id=${loginUser!.salonId}',
        (json) => json,
      );
      if (response != null) {
        memberships.removeWhere((m) => m.id == membershipId);
        CustomSnackbar.showSuccess(
            'Success', 'Membership deleted successfully');
      }
    } catch (e) {
      CustomSnackbar.showError('Error', 'Failed to delete membership: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateMembership(String membershipId) async {
    final addController = Get.find<Branchmembershipaddcontroller>();
    final loginUser = await prefs.getUser();
    Map<String, dynamic> membershipData = {
      'membership_name': addController.memberShipNameController.text,
      'description': addController.descriptionController.text,
      'subscription_plan':
          addController.selected_Subscription_plan.value.toLowerCase(),
      'status': addController.isActive.value ? 1 : 0,
      'discount': addController.discountAmountController.text,
      'discount_type': addController.selected_discountType.value.toLowerCase(),
      'membership_amount': addController.membershipAmountController.text,
      'salon_id': loginUser!.salonId
    };
    try {
      await dioClient.putData(
        '${Apis.baseUrl}${Endpoints.postBranchMembership}/$membershipId',
        membershipData,
        (json) => BranchMemberShip.fromJson(json),
      );
      await fetchMemberships();
      CustomSnackbar.showSuccess('Success', 'Membership updated successfully');
    } catch (e) {
      print('==> here Error: $e');
      CustomSnackbar.showError('Error', e.toString());
    }
    clearAllFields();
  }
}
