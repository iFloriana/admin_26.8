import 'package:flutter/material.dart';
import 'package:flutter_template/network/model/branch_package_model.dart';
import 'package:get/get.dart';

import '../../../main.dart';
import '../../../network/model/manager_branch_package_model.dart';
import '../../../network/network_const.dart';
import '../../../wiget/custome_snackbar.dart';
import '../manager_packageController.dart';

class Service {
  String? id;
  String? name;
  num? regularPrice;

  Service({this.id, this.name, this.regularPrice});

  Service.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    name = json['name'];
    regularPrice = json['regular_price'];
  }
}

class ContainerData {
  Rxn<Service> selectedService = Rxn<Service>();
  TextEditingController discountedPriceController = TextEditingController();
  TextEditingController quantityController = TextEditingController();
  RxInt total = 0.obs;
}

class AddManagerPackagecontroller extends GetxController {
  var containerList = <ContainerData>[].obs;
  RxList<Service> serviceList = <Service>[].obs;
  RxInt grandTotal = 0.obs;
  var StarttimeController = TextEditingController();
  var EndtimeController = TextEditingController();
  var isActive = true.obs;
  var discriptionController = TextEditingController();
  var nameController = TextEditingController();

  final ManagerBranchPackageModel? packageToEdit = Get.arguments;

  @override
  void onInit() {
    super.onInit();
    addContainer();
    _initData();
  }

  Future<void> _initData() async {
    await getServices();
    if (packageToEdit != null) {
      loadPackageForEdit(packageToEdit!);
    }
  }

  void loadPackageForEdit(ManagerBranchPackageModel package) {
    nameController.text = package.packageName;
    discriptionController.text = package.description;
    StarttimeController.text =
        package.startDate.toIso8601String().split('T').first;
    EndtimeController.text = package.endDate.toIso8601String().split('T').first;
    isActive.value = package.status == 1;

    containerList.clear();
    for (var detail in package.packageDetails) {
      final container = ContainerData();
      final service = serviceList.firstWhere(
        (s) => s.id == detail.serviceId.id,
        orElse: () => Service(
            id: detail.serviceId.id,
            name: detail.serviceId.name,
            regularPrice: detail.discountedPrice),
      );

      container.selectedService.value = service;
      container.discountedPriceController.text =
          detail.discountedPrice.toString();
      container.quantityController.text = detail.quantity.toString();

      container.discountedPriceController
          .addListener(() => updateTotal(container));
      container.quantityController.addListener(() => updateTotal(container));

      updateTotal(container);

      containerList.add(container);
    }
    calculateGrandTotal();
  }

  void addContainer() {
    final container = ContainerData();
    container.discountedPriceController
        .addListener(() => updateTotal(container));
    container.quantityController.addListener(() => updateTotal(container));
    containerList.add(container);
  }

  void removeContainer(int index) {
    containerList.removeAt(index);
    calculateGrandTotal();
  }

  void onServiceSelected(ContainerData container, Service? service) {
    if (service != null) {
      container.selectedService.value = service;
      container.discountedPriceController.text =
          service.regularPrice?.toString() ?? '0';
      container.quantityController.text = '1';
      updateTotal(container);
    }
  }

  void updateTotal(ContainerData container) {
    final priceText = container.discountedPriceController.text;
    final quantityText = container.quantityController.text;

    final price = int.tryParse(priceText) ?? 0;
    final quantity = int.tryParse(quantityText) ?? 0;

    container.total.value = price * quantity;
    calculateGrandTotal();
  }

  void calculateGrandTotal() {
    grandTotal.value =
        containerList.fold(0, (sum, container) => sum + container.total.value);
  }

  Future<void> getServices() async {
    final loginUser = await prefs.getManagerUser();
    try {
      final response = await dioClient.getData(
        '${Apis.baseUrl}${Endpoints.getServiceNames}${loginUser?.manager?.salonId}',
        (json) => json,
      );
      final data = response['data'] as List;
      serviceList.value = data.map((e) => Service.fromJson(e)).toList();
    } catch (e) {
      CustomSnackbar.showError('Error', 'Failed to get services: $e');
    }
  }

  Future<void> submitPackage() async {
    try {
      final packageDetails = containerList.map((container) {
        if (container.selectedService.value == null) {
          throw Exception('Please select a service for all containers');
        }
        return {
          'service_id': container.selectedService.value!.id,
          'discounted_price':
              int.parse(container.discountedPriceController.text),
          'quantity': int.parse(container.quantityController.text),
        };
      }).toList();
      final loginUser = await prefs.getManagerUser();
      final requestBody = {
        'branch_id': [loginUser?.manager?.branchId?.sId],
        'package_name': nameController.text,
        'description': discriptionController.text,
        'start_date': StarttimeController.text,
        'end_date': EndtimeController.text,
        'status': isActive.value ? 1 : 0,
        'package_details': packageDetails,
        'salon_id': loginUser!.manager?.salonId,
      };

      if (packageToEdit != null) {
        final response = await dioClient.putData(
          '${Apis.baseUrl}${Endpoints.branchPackages}/${packageToEdit!.id}',
          requestBody,
          (json) => json,
        );

        Get.back();
        // Refresh package list on previous screen
        final getBranchPackagesController =
            Get.find<ManagerPackagecontroller>();
        await getBranchPackagesController.getBranchPackages();
        CustomSnackbar.showSuccess('Success', 'Package updated successfully');
      } else {
        final response = await dioClient.postData(
          '${Apis.baseUrl}${Endpoints.branchPackages}',
          requestBody,
          (json) => json,
        );
        // Refresh package list on previous screen

        Get.back();
        final getBranchPackagesController =
            Get.find<ManagerPackagecontroller>();
        await getBranchPackagesController.getBranchPackages();

        CustomSnackbar.showSuccess('Success', 'Package created successfully');
      }

      // Clear all controllers and reset state after success
      clearForm();
    } catch (e) {
      CustomSnackbar.showError('Error', 'Failed to submit package: $e');
    }
  }

  void clearForm() {
    containerList.clear();
    addContainer();
    nameController.clear();
    discriptionController.clear();
    StarttimeController.clear();
    EndtimeController.clear();
    isActive.value = true;
    grandTotal.value = 0;
  }
}
