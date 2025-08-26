import 'package:get/get.dart';
import 'package:flutter_template/network/network_const.dart';
import 'package:flutter_template/wiget/custome_snackbar.dart';
import 'package:flutter_template/main.dart';

class CommissionBranch {
  final String id;
  final String name;
  CommissionBranch({required this.id, required this.name});
  factory CommissionBranch.fromJson(Map<String, dynamic> json) {
    return CommissionBranch(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
    );
  }
}

class CommissionItem {
  final String id;
  final CommissionBranch branch;
  final String commissionName;
  final String commissionType;
  final List<dynamic> commission;

  CommissionItem({
    required this.id,
    required this.branch,
    required this.commissionName,
    required this.commissionType,
    required this.commission,
  });

  factory CommissionItem.fromJson(Map<String, dynamic> json) {
    return CommissionItem(
      id: json['_id'],
      branch: CommissionBranch.fromJson(json['branch_id'] ?? {}),
      commissionName: json['commission_name'],
      commissionType: json['commission_type'],
      commission: json['commission'] ?? [],
    );
  }
}

class CommissionListController extends GetxController {
  var isLoading = false.obs;
  var commissionList = <CommissionItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchCommissions();
  }

  Future<void> fetchCommissions() async {
    isLoading.value = true;
    final loginUser = await prefs.getUser();
    try {
      final response = await dioClient.getData(
        '${Apis.baseUrl}${Endpoints.getcommition}${loginUser!.salonId}',
        (json) => json,
      );
      if (response != null && response['data'] != null) {
        commissionList.value = (response['data'] as List)
            .map((e) => CommissionItem.fromJson(e))
            .toList();
      }
    } catch (e) {
      CustomSnackbar.showError('Error', 'Failed to fetch commissions: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteCommission(String id) async {
    isLoading.value = true;
    final loginUser = await prefs.getUser();
    try {
      await dioClient.deleteData(
        '${Apis.baseUrl}${Endpoints.commition}/$id?salon_id=${loginUser!.salonId}',
        (json) => json,
      );
      commissionList.removeWhere((item) => item.id == id);
      CustomSnackbar.showSuccess('Success', 'Commission deleted');
    } catch (e) {
      CustomSnackbar.showError('Error', 'Failed to delete commission: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
