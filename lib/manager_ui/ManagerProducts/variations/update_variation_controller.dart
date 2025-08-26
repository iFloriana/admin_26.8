import 'package:flutter/widgets.dart';
import 'package:flutter_template/main.dart';
import 'package:get/get.dart';
import 'package:multi_dropdown/multi_dropdown.dart';
import '../../../../network/model/variation_product.dart';
import '../../../../network/network_const.dart';
import '../../../../wiget/custome_snackbar.dart';
import 'get/variationGetController.dart';

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
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Branch1 && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class ManagerUpdateVariationcontroller extends GetxController {
  final isLoading = false.obs;
  var branchList = <Branch1>[].obs;
  var selectedBranches = <Branch1>[].obs;
  var nameController = TextEditingController();
  final branchController = MultiSelectController<Branch1>();
  var isActive = true.obs;
  var selectedType = "".obs;
  final List<String> dropdownItemsType = ['Text', 'Color'];
  var valueControllers = <TextEditingController>[].obs;

  final Data variationToEdit;

  ManagerUpdateVariationcontroller({required this.variationToEdit});

  @override
  void onInit() {
    super.onInit();
    getBranches();
    setDataForEdit();
  }

  void setDataForEdit() {
    nameController.text = variationToEdit.name ?? '';
    selectedType.value = variationToEdit.type ?? '';
    isActive.value = (variationToEdit.status == 1);

    valueControllers.clear();
    if (variationToEdit.value != null && variationToEdit.value!.isNotEmpty) {
      for (var val in variationToEdit.value!) {
        valueControllers.add(TextEditingController(text: val));
      }
    } else {
      valueControllers.add(TextEditingController());
    }
  }

  @override
  void onClose() {
    nameController.dispose();
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
    final loginUser = await prefs.getManagerUser();
    try {
      isLoading.value = true;
      final response = await dioClient.getData(
        '${Apis.baseUrl}${Endpoints.getBranchName}${loginUser!.manager?.salonId}',
        (json) => json,
      );
      final List<dynamic> data = response['data'];
      final allBranches = data.map((e) => Branch1.fromJson(e)).toList();
      branchList.value = allBranches;

      branchController.setItems(allBranches
          .map((branch) =>
              DropdownItem<Branch1>(label: branch.name ?? '', value: branch))
          .toList());

      if (variationToEdit.branchId != null) {
        final List<Branch1> branchesToSelect = [];
        for (var branchToSelect in variationToEdit.branchId!) {
          final foundBranch =
              allBranches.firstWhereOrNull((b) => b.id == branchToSelect.id);
          if (foundBranch != null) {
            branchesToSelect.add(foundBranch);
          }
        }
        selectedBranches.value = branchesToSelect;
        branchController
            .selectWhere((element) => branchesToSelect.contains(element.value));
      }
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

  Future<void> onBranchUpdate() async {
    final loginUser = await prefs.getManagerUser();
    final branchIds =
        selectedBranches.map((b) => b.id).whereType<String>().toList();
    final values =
        valueControllers.map((c) => c.text).where((v) => v.isNotEmpty).toList();

    Map<String, dynamic> branchData = {
      "branch_id": branchIds,
      "name": nameController.text,
      "value": values,
      "type": selectedType.value,
      "salon_id": loginUser!.manager?.salonId,
      'status': isActive.value ? 1 : 0,
    };
    print("===> $branchData");
    try {
      await dioClient.putData(
        '${Apis.baseUrl}${Endpoints.postVariation}/${variationToEdit.sId}',
        branchData,
        (json) => json,
      );
      clearFormFields();
      final getController =
          Get.find<ManagerVariationGetcontroller>();
      getController.getVariation();
      Get.back();
    } catch (e) {
      print('==> here Error: $e');
      CustomSnackbar.showError('Error', e.toString());
    }
  }
}
