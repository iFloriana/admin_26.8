import 'package:get/get.dart';
import 'package:flutter_template/main.dart';
import 'package:flutter_template/network/network_const.dart';
import 'package:flutter_template/wiget/custome_snackbar.dart';

class ManagerTaxBranchInfo {
  final String? id;
  final String? name;

  ManagerTaxBranchInfo({this.id, this.name});

  factory ManagerTaxBranchInfo.fromJson(Map<String, dynamic> json) {
    return ManagerTaxBranchInfo(
      id: json['_id'],
      name: json['name'],
    );
  }
}

class ManagerTax {
  final String? id;
  final String? title;
  final num? value;
  final String? type; // percent | fixed
  final String? taxType; // services | product | etc
  final int? status; // 1 | 0
  final List<ManagerTaxBranchInfo> branches;

  ManagerTax({
    this.id,
    this.title,
    this.value,
    this.type,
    this.taxType,
    this.status,
    this.branches = const [],
  });

  factory ManagerTax.fromJson(Map<String, dynamic> json) {
    final List<ManagerTaxBranchInfo> parsedBranches =
        (json['branch_id'] is List)
            ? (json['branch_id'] as List)
                .map((b) => ManagerTaxBranchInfo.fromJson(b))
                .toList()
            : <ManagerTaxBranchInfo>[];
    return ManagerTax(
      id: json['_id'],
      title: json['title'],
      value: json['value'],
      type: json['type'],
      taxType: json['tax_type'],
      status: json['status'],
      branches: parsedBranches,
    );
  }
}

class ManagerTaxesController extends GetxController {
  var taxes = <ManagerTax>[].obs;
  var filteredTaxes = <ManagerTax>[].obs;
  var isLoading = false.obs;
  var isSearching = false.obs;

  @override
  void onInit() {
    super.onInit();
    getTaxes();
  }

  Future<void> getTaxes() async {
    final manager = await prefs.getManagerUser();
    if (manager == null) return;
    isLoading.value = true;
    try {
      final response = await dioClient.getData(
        '${Apis.baseUrl}/taxes/by-branch?salon_id=${manager.manager?.salonId}&branch_id=${manager.manager?.branchId?.sId}',
        (json) => json,
      );
      if (response != null && response['data'] is List) {
        final List data = response['data'];
        taxes.value = data.map((e) => ManagerTax.fromJson(e)).toList();
        filteredTaxes.value = List<ManagerTax>.from(taxes);
      } else {
        taxes.clear();
        filteredTaxes.clear();
      }
    } catch (e) {
      CustomSnackbar.showError('Error', 'Failed to load taxes: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void setSearchQuery(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) {
      filteredTaxes.value = List<ManagerTax>.from(taxes);
      return;
    }
    filteredTaxes.value =
        taxes.where((t) => (t.title ?? '').toLowerCase().contains(q)).toList();
  }

  void clearSearch() {
    filteredTaxes.value = List<ManagerTax>.from(taxes);
  }
}
