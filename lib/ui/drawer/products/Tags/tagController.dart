import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:multi_dropdown/multi_dropdown.dart';
import '../../../../main.dart';
import '../../../../network/network_const.dart';
import '../../../../wiget/custome_snackbar.dart';

class Branch1 {
  final String? id;
  final String? name;

  Branch1({this.id, this.name});

  factory Branch1.fromJson(Map<String, dynamic> json) {
    return Branch1(
      id: json['_id'],
      name: json['name'],
    );
  }
}

class TagModel {
  final String? id;
  final List<Branch1> branches;
  final String? name;
  final int? status;
  final String? salonId;

  TagModel({
    this.id,
    required this.branches,
    this.name,
    this.status,
    this.salonId,
  });

  factory TagModel.fromJson(Map<String, dynamic> json) {
    return TagModel(
      id: json['_id'],
      branches:
          (json['branch_id'] as List).map((e) => Branch1.fromJson(e)).toList(),
      name: json['name'],
      status: json['status'],
      salonId: json['salon_id'],
    );
  }
}

class Tagcontroller extends GetxController {
  var isActive = true.obs;
  var branchList = <Branch1>[].obs;
  var selectedBranches = <Branch1>[].obs;
  var nameController = TextEditingController();
  final branchController = MultiSelectController<Branch1>();
  var tagsList = <TagModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    getTags();
    getBranches();
  }

  @override
  void onClose() {
    nameController.dispose();
    branchController.dispose();
    super.onClose();
  }

  Future<void> getBranches() async {
    final loginUser = await prefs.getUser();
    try {
      final response = await dioClient.getData(
        '${Apis.baseUrl}${Endpoints.getBranchName}${loginUser!.salonId}',
        (json) => json,
      );

      final data = response['data'] as List;
      branchList.value = data.map((e) => Branch1.fromJson(e)).toList();
    } catch (e) {
      CustomSnackbar.showError('Error', 'Failed to get data: $e');
    }
  }

  Future onAddSubCategory() async {
    final loginUser = await prefs.getUser();
    Map<String, dynamic> subCategoryData = {
      "name": nameController.text,
      'branch_id': selectedBranches.map((branch) => branch.id).toList(),
      'status': isActive.value ? 1 : 0,
      'salon_id': loginUser!.salonId,
    };

    try {
      await dioClient.postData(
        '${Apis.baseUrl}${Endpoints.postTags}',
        subCategoryData,
        (json) => json,
      );

      Get.back();
      resetForm();
      getTags();
      CustomSnackbar.showSuccess(
          'Success', 'SubCategory Added Successfully'); // Reset the form
    } catch (e) {
      print('==> here Error: $e');
      CustomSnackbar.showError('Error', e.toString());
    }
  }

  Future<void> getTags() async {
    final loginUser = await prefs.getUser();
    try {
      final response = await dioClient.getData(
        '${Apis.baseUrl}${Endpoints.getTags}${loginUser!.salonId}',
        (json) => json,
      );
      final data = response['data'] as List;
      tagsList.value = data.map((e) => TagModel.fromJson(e)).toList();
    } catch (e) {
      CustomSnackbar.showError('Error', 'Failed to get data: $e');
    }
  }

  void resetForm() {
    nameController.clear();
    isActive.value = true;
    selectedBranches.clear();
    branchController.clearAll();
  }

  Future<void> deleteTag(String tagId) async {
    final loginUser = await prefs.getUser();
    try {
      await dioClient.deleteData(
        '${Apis.baseUrl}${Endpoints.postTags}/$tagId?salon_id=${loginUser!.salonId}',
        (json) => json,
      );
      CustomSnackbar.showSuccess('Success', 'Tag deleted successfully');
      await getTags();
    } catch (e) {
      CustomSnackbar.showError('Error', 'Failed to delete tag: $e');
    }
  }

  Future<void> onEditTag(String tagId) async {
    final loginUser = await prefs.getUser();
    Map<String, dynamic> tagData = {
      "name": nameController.text,
      'branch_id': selectedBranches.map((branch) => branch.id).toList(),
      'status': isActive.value ? 1 : 0,
      'salon_id': loginUser!.salonId,
    };
    try {
      await dioClient.putData(
        '${Apis.baseUrl}${Endpoints.postTags}/$tagId',
        tagData,
        (json) => json,
      );
      CustomSnackbar.showSuccess('Success', 'Tag updated successfully');
      await getTags();
      resetForm();
    } catch (e) {
      CustomSnackbar.showError('Error', 'Failed to update tag: $e');
    }
  }
}
