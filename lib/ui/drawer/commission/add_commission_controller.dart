import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_template/network/network_const.dart';
import 'package:flutter_template/wiget/custome_snackbar.dart';
import 'package:flutter_template/main.dart';
import 'package:flutter_template/network/model/branch_model.dart';
import 'commission_list_controller.dart';

class CommissionSlot {
  String slot;
  String amount;
  CommissionSlot({required this.slot, required this.amount});
  Map<String, dynamic> toJson() => {'slot': slot, 'amount': amount};
}

class Branch {
  final String? id;
  final String? name;

  Branch({this.id, this.name});

  factory Branch.fromJson(Map<String, dynamic> json) {
    return Branch(
      id: json['_id'],
      name: json['name'],
    );
  }
}

class AddCommissionController extends GetxController {
  var isLoading = false.obs;
  var branchList = <BranchModel>[].obs;
  var selectedBranch = Rxn<BranchModel>();
  var commissionNameController = TextEditingController();
  var commissionType = ''.obs;
  var slots = <CommissionSlot>[].obs;
  String? editingId;

  final List<String> commissionTypeOptions = ['Percentage', 'Fixed'];

  @override
  void onInit() {
    super.onInit();
    fetchBranches();
    final arg = Get.arguments;
    if (arg != null && arg is CommissionItem) {
      editingId = arg.id;
      commissionNameController.text = arg.commissionName;
      commissionType.value = arg.commissionType;
      ever(branchList, (_) {
        selectedBranch.value =
            branchList.firstWhereOrNull((b) => b.id == arg.branch.id);
      });
      slots.value = arg.commission
          .map<CommissionSlot>((e) =>
              CommissionSlot(slot: e['slot'], amount: e['amount'].toString()))
          .toList();
    }
  }

  Future<void> fetchBranches() async {
    isLoading.value = true;
    final loginUser = await prefs.getUser();
    try {
      final response = await dioClient.getData(
        '${Apis.baseUrl}${Endpoints.getBranches}${loginUser!.salonId}',
        (json) => json,
      );
      if (response != null && response['data'] != null) {
        final List<dynamic> branchesData = response['data'];
        branchList.value =
            branchesData.map((branch) => BranchModel.fromJson(branch)).toList();
      }
    } catch (e) {
      CustomSnackbar.showError('Error', 'Failed to fetch branches: $e');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    commissionNameController.dispose();
    super.onClose();
  }

  void addSlot() {
    slots.add(CommissionSlot(slot: '', amount: ''));
  }

  void removeSlot(int index) {
    slots.removeAt(index);
  }

  Future<void> postCommission() async {
    isLoading.value = true;
    final loginUser = await prefs.getUser();
    try {
      Map<String, dynamic> data = {
        'branch_id': selectedBranch.value?.id ?? '',
        'commission_name': commissionNameController.text,
        'commission_type': commissionType.value,
        'commission': slots.map((e) => e.toJson()).toList(),
        'salon_id': loginUser!.salonId
      };
      if (editingId != null) {
        await dioClient.putData(
          '${Apis.baseUrl}${Endpoints.commition}/$editingId',
          data,
          (json) => json,
        );
        Get.back(result: true);
        CustomSnackbar.showSuccess(
            'Success', 'Commission updated successfully');
      } else {
        await dioClient.postData(
          '${Apis.baseUrl}${Endpoints.commition}',
          data,
          (json) => json,
        );
        Get.back(result: true);
        CustomSnackbar.showSuccess('Success', 'Commission added successfully');
      }
      commissionNameController.clear();
      commissionType.value = '';
      slots.clear();
      selectedBranch.value = null;
      editingId = null;
    } catch (e) {
      CustomSnackbar.showError('Error', 'Failed to save commission: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
