import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:multi_dropdown/multi_dropdown.dart';

import '../../../../main.dart';
import '../../../../network/model/postUnits.dart';
import '../../../../network/network_const.dart';
import '../../../../wiget/custome_snackbar.dart';

class UnitModel {
  final String? id;
  final List<Branch1> branches;
  final String? name;
  final int? status;
  final String? salonId;

  UnitModel({
    this.id,
    required this.branches,
    this.name,
    this.status,
    this.salonId,
  });

  factory UnitModel.fromJson(Map<String, dynamic> json) {
    return UnitModel(
      id: json['_id'],
      branches:
          (json['branch_id'] as List).map((e) => Branch1.fromJson(e)).toList(),
      name: json['name'],
      status: json['status'],
      salonId: json['salon_id'],
    );
  }
}

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

class Unitscontroller extends GetxController {
  @override
  void onInit() {
    super.onInit();
    getBranches();
    getUnits();
  }

  var nameController = TextEditingController();
  var isActive = true.obs;
  var selectedBranches = <Branch1>[].obs;
  final branchController = MultiSelectController<Branch1>();
  var branchList = <Branch1>[].obs;
  var unitsList = <UnitModel>[].obs;

  Future onUniteAdd() async {
    final loginUser = await prefs.getUser();
    Map<String, dynamic> unitsData = {
      'name': nameController.text,
      'status': isActive.value ? 1 : 0,
      'branch_id': selectedBranches.map((branch) => branch.id).toList(),
      'salon_id': loginUser!.salonId,
    };

    try {
      await dioClient.postData(
        '${Apis.baseUrl}${Endpoints.postUnits}',
        unitsData,
        (json) => PostUnits.fromJson(json),
      );
      Get.back();
      await getUnits();
      CustomSnackbar.showSuccess('Succcess', 'Units Added');
    } catch (e) {
      print('==> here Error: $e');
      CustomSnackbar.showError('Error', e.toString());
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
      branchList.value = data.map((e) => Branch1.fromJson(e)).toList();
    } catch (e) {
      CustomSnackbar.showError('Error', 'Failed to get data: $e');
    }
  }

  Future<void> getUnits() async {
    final loginUser = await prefs.getUser();
    try {
      final response = await dioClient.getData(
        '${Apis.baseUrl}${Endpoints.getUnits}${loginUser!.salonId}',
        (json) => json,
      );
      final data = response['data'] as List;
      unitsList.value = data.map((e) => UnitModel.fromJson(e)).toList();
    } catch (e) {
      CustomSnackbar.showError('Error', 'Failed to get data: $e');
    }
  }

  Future<void> deleteUnit(String unitId) async {
    final loginUser = await prefs.getUser();
    try {
      await dioClient.deleteData(
        '${Apis.baseUrl}${Endpoints.postUnits}/$unitId?salon_id=${loginUser!.salonId}',
        (json) => json,
      );
      await getUnits();
      CustomSnackbar.showSuccess('Success', 'Unit deleted successfully');
    } catch (e) {
      CustomSnackbar.showError('Error', 'Failed to delete unit: $e');
    }
  }

  Future<void> updateUnit(String unitId) async {
    final loginUser = await prefs.getUser();
    Map<String, dynamic> unitsData = {
      'name': nameController.text,
      'status': isActive.value ? 1 : 0,
      'branch_id': selectedBranches.map((branch) => branch.id).toList(),
      'salon_id': loginUser!.salonId,
    };

    try {
      await dioClient.putData(
        '${Apis.baseUrl}${Endpoints.postUnits}/$unitId',
        unitsData,
        (json) => PostUnits.fromJson(json),
      );

      await getUnits();
      CustomSnackbar.showSuccess('Success', 'Unit updated');
    } catch (e) {
      print('==> here Error: $e');
      CustomSnackbar.showError('Error', e.toString());
    }
  }
}
