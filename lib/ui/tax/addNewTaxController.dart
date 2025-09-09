import 'package:flutter/cupertino.dart';
import 'package:flutter_template/network/model/taxmodel.dart';
import 'package:get/get.dart';
import 'package:multi_dropdown/multi_dropdown.dart';
import '../../../main.dart';
import '../../../network/network_const.dart';
import '../../../wiget/custome_snackbar.dart';

class TaxModel {
  final String? id;
  final String? title;
  final int? value;
  final String? type;
  final String? taxType;
  final int? status;
  final List<Branch>? branches;

  TaxModel({
    this.id,
    this.title,
    this.value,
    this.type,
    this.taxType,
    this.status,
    this.branches,
  });

  factory TaxModel.fromJson(Map<String, dynamic> json) {
    return TaxModel(
      id: json['_id'],
      title: json['title'],
      value: json['value'],
      type: json['type'],
      taxType: json['tax_type'],
      status: json['status'],
      branches:
          (json['branch_id'] as List).map((b) => Branch.fromJson(b)).toList(),
    );
  }
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

class Addnewtaxcontroller extends GetxController {
  var titleController = TextEditingController();
  var valueController = TextEditingController();
  var selectedDropdownType = "".obs;
  var selectedDropdownModule = "".obs;
  var isActive = true.obs;
   var selectedBranches = <Branch>[].obs;
  final branchController = MultiSelectController<Branch>();
  var branchList = <Branch>[].obs;
  // var branchList = <Branch>[].obs;
  // var selectedBranches = <Branch>[].obs;
  // bool get allSelected => selectedBranches.length == branchList.length;
  var taxList = <TaxModel>[].obs;
var isEditMode = false.obs;
  String? editingTaxId; 

  
  final List<String> dropdownType = [
    'Percent',
    'Fixed',
  ];
  final List<String> dropdownModule = [
    'Product',
    'Services',
  ];

  @override
  void onInit() {
    super.onInit();
    getBranches();
    getTaxes();
  }

  void editTax(TaxModel tax) {
    isEditMode.value = true;
    editingTaxId = tax.id;

    titleController.text = tax.title ?? '';
    valueController.text = tax.value?.toString() ?? '';
    selectedDropdownType.value = tax.type?.capitalizeFirst ?? '';
    selectedDropdownModule.value = tax.taxType?.capitalizeFirst ?? '';
    isActive.value = tax.status == 1;
    final selected = branchList
        .where((b) => tax.branches!.any((ub) => ub.id == b.id))
        .toList();
    selectedBranches.value = selected;
    branchController.clearAll();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      branchController
          .selectWhere((item) => selected.contains(item.value));
    });
    // selectedBranches.value = tax.branches ?? [];
  }


  Future<void> deleteTax(String? taxId) async {
    final loginUser = await prefs.getUser();
    if (taxId == null) return;
    try {
      await dioClient.deleteData(
        '${Apis.baseUrl}${Endpoints.postTex}/$taxId?salon_id=${loginUser!.salonId}',
        (json) => json,
      );
      taxList.removeWhere((tax) => tax.id == taxId);
      getTaxes();
      CustomSnackbar.showSuccess('Success', 'Tax deleted');
    } catch (e) {
      CustomSnackbar.showError('Error', 'Delete failed: $e');
    }
  }

  Future onTaxadded() async {
    final loginUser = await prefs.getUser();

    Map<String, dynamic> taxData = {
      "salon_id": loginUser!.salonId,
      // "branch_id": selectedBranches.map((e) => e.id).toList(),
        'branch_id': selectedBranches.map((branch) => branch.id).toList(),
      "title": titleController.text.trim(),
      "value": int.tryParse(valueController.text.trim()) ?? 0,
      "type": selectedDropdownType.value.toLowerCase(),
      "tax_type": selectedDropdownModule.value.toLowerCase(),
      "status": isActive.value ? 1 : 0,
    };
    print("==> $taxData");
    try {
      await dioClient.postData<AddTex>(
        '${Apis.baseUrl}${Endpoints.postTex}',
        taxData,
        (json) => AddTex.fromJson(json),
      );
      getTaxes();
      CustomSnackbar.showSuccess('Succcess', 'tax added');
    } catch (e) {
      print('==> here Error: $e');
      CustomSnackbar.showError('Error', e.toString());
    }
  }
void resetForm() {
    isEditMode.value = false;
    editingTaxId = null;

    titleController.clear();
    valueController.clear();

    selectedDropdownType.value = "";
    selectedDropdownModule.value = "";
    isActive.value = true;

    selectedBranches.clear();
    branchController.clearAll();
  }

    Future<void> getBranches() async {
    final loginUser = await prefs.getUser();
    try {
      final response = await dioClient.getData(
        '${Apis.baseUrl}${Endpoints.getBranchName}${loginUser!.salonId}',
        (json) => json,
      );

      final data = response['data'] as List;
      branchList.value = data.map((e) => Branch.fromJson(e)).toList();
    } catch (e) {
      CustomSnackbar.showError('Error', 'Failed to get data: $e');
    }
  }

  Future<void> getTaxes() async {
    final loginUser = await prefs.getUser();
    try {
      final response = await dioClient.getData(
        '${Apis.baseUrl}${Endpoints.getTex}${loginUser!.salonId}',
        (json) => json,
      );
      final data = response['data'] as List;
      taxList.value = data.map((e) => TaxModel.fromJson(e)).toList();
    } catch (e) {
      CustomSnackbar.showError('Error', 'Failed to get data: $e');
    }
  }

  Future<void> updateTax() async {
    final loginUser = await prefs.getUser();
    if (editingTaxId == null) return;

    Map<String, dynamic> taxData = {
      "salon_id": loginUser!.salonId,
      // "branch_id": selectedBranches.map((e) => e.id).toList(),
        'branch_id': selectedBranches.map((branch) => branch.id).toList(),
      "title": titleController.text.trim(),
      "value": int.tryParse(valueController.text.trim()) ?? 0,
      "type": selectedDropdownType.value.toLowerCase(),
      "tax_type": selectedDropdownModule.value.toLowerCase(),
      "status": isActive.value ? 1 : 0,
    };

    try {
       await dioClient.putData(
        '${Apis.baseUrl}${Endpoints.postTex}/$editingTaxId',
        taxData,
        (json) => json,
      );
      isEditMode.value = false;
      editingTaxId = null;
      getTaxes();
      CustomSnackbar.showSuccess('Success', 'Tax updated');
    } catch (e) {
      CustomSnackbar.showError('Error', 'Update failed: $e');
    }
  }

}
