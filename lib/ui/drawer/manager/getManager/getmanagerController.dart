import 'package:flutter_template/network/network_const.dart';
import 'package:get/get.dart';
import '../../../../main.dart';
import '../../../../wiget/custome_snackbar.dart';

class Manager {
  final String id;
  final String full_name;
  final String image_url;
  final String email;
  final String contactNumber;
  final String password;
  final String branchName;
  final String? branchId;
  final String? gender;

  Manager({
    required this.id,
    required this.full_name,
    required this.image_url,
    required this.email,
    required this.contactNumber,
    required this.password,
    required this.branchName,
    this.branchId,
    this.gender,
  });

  factory Manager.fromJson(Map<String, dynamic> json) {
    return Manager(
      id: json['_id'],
      full_name: json['full_name'],
      image_url: json['image_url'],
      email: json['email'],
      contactNumber: json['contact_number'],
      branchName: json['branch_id']?['name'] ?? '',
      password: json['password'],
      branchId: json['branch_id']?['_id'],
      gender: json['gender'],
    );
  }
}

class BranchFilter {
  final String? id;
  final String? name;

  BranchFilter({this.id, this.name});

  factory BranchFilter.fromJson(Map<String, dynamic> json) {
    return BranchFilter(
      id: json['_id'],
      name: json['name'],
    );
  }
}

class Getmanagercontroller extends GetxController {
  RxList<Manager> managers = <Manager>[].obs;
  RxList<Manager> filteredManagers = <Manager>[].obs;
  RxList<BranchFilter> branchList = <BranchFilter>[].obs;
  var isLoading = false.obs;
  var selectedBranchFilter = Rx<BranchFilter?>(null);

  @override
  void onInit() {
    super.onInit();
    getManagers();
    getBranches();
  }

  Future<void> getManagers() async {
    final loginUser = await prefs.getUser();
    try {
      isLoading.value = true;
      final response = await dioClient.getData(
        '${Apis.baseUrl}${Endpoints.getManager}${loginUser!.salonId}',
        (json) => json,
      );
      final data = response['data'] as List;
      managers.value = data.map((e) => Manager.fromJson(e)).toList();
      applyFilter(); // Apply current filter after loading managers
    } catch (e) {
      CustomSnackbar.showError('Error', 'Failed to get data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getBranches() async {
    final loginUser = await prefs.getUser();
    try {
      final response = await dioClient.getData(
        '${Apis.baseUrl}${Endpoints.getBranchName}${loginUser!.salonId}',
        (json) => json,
      );

      final data = response['data'] as List;
      branchList.value = data.map((e) => BranchFilter.fromJson(e)).toList();
    } catch (e) {
      CustomSnackbar.showError('Error', 'Failed to get branches: $e');
    }
  }

  void applyFilter() {
    if (selectedBranchFilter.value == null) {
      // Show all managers if no filter is selected
      filteredManagers.value = managers;
    } else {
      // Filter managers by selected branch
      filteredManagers.value = managers
          .where(
              (manager) => manager.branchId == selectedBranchFilter.value!.id)
          .toList();
    }
  }

  void setBranchFilter(BranchFilter? branch) {
    selectedBranchFilter.value = branch;
    applyFilter();
  }

  void clearFilter() {
    selectedBranchFilter.value = null;
    applyFilter();
  }

  Future<void> deleteManager(String? managerId) async {
    final loginUser = await prefs.getUser();
    if (managerId == null) return;
    try {
      isLoading.value = true;
      await dioClient.deleteData(
        '${Apis.baseUrl}${Endpoints.addManager}/$managerId?salon_id=${loginUser!.salonId}',
        (json) => json,
      );
      managers.removeWhere((m) => m.id == managerId);
      applyFilter(); // Reapply filter after deletion
      CustomSnackbar.showSuccess('Deleted', 'Manager deleted successfully');
    } catch (e) {
      CustomSnackbar.showError('Error', 'Failed to delete manager: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
