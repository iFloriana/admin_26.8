import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:multi_dropdown/multi_dropdown.dart';

import '../../../../main.dart';
import '../../../../network/model/variation_product.dart';
import '../../../../network/network_const.dart';
import '../../../../wiget/custome_snackbar.dart';

class Branch1 {
  final String? id;
  final String? name;

  Branch1({this.id, this.name});

  factory Branch1.fromJson(Map<String, dynamic> json) {
    return Branch1(
      id: json['_id'] ?? json['id'],
      name: json['name'],
    );
  }

  @override
  String toString() => 'Branch1(id: $id, name: $name)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Branch1 && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class Variationcontroller extends GetxController {
  final isLoading = false.obs;
  var branchList = <Branch1>[].obs;
  var selectedBranches = <Branch1>[].obs;
  var nameController = TextEditingController();
  var valueController = TextEditingController();
  final branchController = MultiSelectController<Branch1>();
  var isActive = true.obs;
  var selectedType = "".obs;
  final List<String> dropdownItemsType = [
    'Text',
    'Color',
  ];

  // For dynamic value fields
  var valueControllers = <TextEditingController>[].obs;

  @override
  void onInit() {
    super.onInit();
    clearFormFields();
    getBranches();
    // valueControllers.add(TextEditingController());
  }

  @override
  void onClose() {
    nameController.dispose();
    valueController.dispose();
    branchController.dispose();
    for (var c in valueControllers) {
      c.dispose();
    }
    super.onClose();
  }

  void addValueField() {
    valueControllers.add(TextEditingController());
  }

  void removeValueField(int index) {
    if (valueControllers.length > 1) {
      valueControllers[index].dispose();
      valueControllers.removeAt(index);
    }
  }

  Future<void> getBranches() async {
    final loginUser = await prefs.getUser();
    try {
      isLoading.value = true;
      final response = await dioClient.getData(
        '${Apis.baseUrl}${Endpoints.getBranchName}${loginUser!.salonId}',
        (json) => json,
      );
      final List<dynamic> data = response['data'];
      branchList.value = data.map((e) => Branch1.fromJson(e)).toList();
    } catch (e) {
      CustomSnackbar.showError('Error', 'Failed to get data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void clearFormFields() {
    nameController.clear();
    selectedType.value = '';
    isActive.value = true;

    // Clear branch selection
    selectedBranches.clear();
    branchController.clearAll();
    valueControllers.clear();
    valueControllers.add(TextEditingController());
  }

  Future onBranchAdd() async {
    final loginUser = await prefs.getUser();
    // Collect branch IDs
    final branchIds =
        selectedBranches.map((b) => b.id).whereType<String>().toList();
    // Collect values from all valueControllers
    final values =
        valueControllers.map((c) => c.text).where((v) => v.isNotEmpty).toList();
    // Prepare data
    Map<String, dynamic> branchData = {
      "branch_id": branchIds,
      "name": nameController.text,
      "value": values,
      "type": selectedType.value,
      "salon_id": loginUser!.salonId,
      'status': isActive.value ? 1 : 0,
    };
    print("===> $branchData");
    try {
      await dioClient.postData<ProductVariation>(
        '${Apis.baseUrl}${Endpoints.postVariation}',
        branchData,
        (json) => ProductVariation.fromJson(json['data']),
      );
      Get.back();
      CustomSnackbar.showSuccess('Success', 'Variation added successfully');
      clearFormFields();
    } catch (e) {
      print('==> here Error: $e');
      CustomSnackbar.showError('Error', e.toString());
    }
  }
}
