import 'dart:io';

import 'package:get/get.dart';
import 'package:dio/dio.dart' as dio;
import 'package:http_parser/http_parser.dart';
import 'package:multi_dropdown/multi_dropdown.dart';

import '../../../../main.dart';
import '../../../../network/network_const.dart';
import '../../../../wiget/custome_snackbar.dart';
import '../../../../network/model/branch_model.dart';

class Getbranchescontroller extends GetxController {
  final RxList<BranchModel> branches = <BranchModel>[].obs;
  final RxBool isLoading = false.obs;

  // Service-related variables
  RxList<Service> serviceList = <Service>[].obs;
  RxList<Service> selectedServices = <Service>[].obs;

  // MultiSelect controllers
  final paymentMethodController = MultiSelectController<String>();
  final serviceController = MultiSelectController<Service>();

  @override
  void onClose() {
    paymentMethodController.dispose();
    serviceController.dispose();
    super.onClose();
  }

  @override
  void onInit() {
    super.onInit();
    getBranches();
    getServices();
  }

  Future<void> getBranches() async {
    isLoading.value = true;
    final loginUser = await prefs.getUser();
    try {
      final response = await dioClient.getData(
        '${Apis.baseUrl}${Endpoints.getBranches}${loginUser!.salonId}',
        (json) => json,
      );

      if (response != null && response['data'] != null) {
        final List<dynamic> branchesData = response['data'];
        branches.value =
            branchesData.map((branch) => BranchModel.fromJson(branch)).toList();
      }
    } catch (e) {
      CustomSnackbar.showError('Error', 'Failed to fetch branches: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteBranch(String branchId) async {
    try {
      final loginUser = await prefs.getUser();
      isLoading.value = true;
      final response = await dioClient.deleteData(
        '${Apis.baseUrl}${Endpoints.postBranchs}/$branchId?salon_id=${loginUser!.salonId}',
        (json) => json,
      );

      if (response != null) {
        // Remove the branch from the local list
        branches.removeWhere((branch) => branch.id == branchId);
        CustomSnackbar.showSuccess('Success', 'Branch deleted successfully');
      }
    } catch (e) {
      CustomSnackbar.showError('Error', 'Failed to delete branch: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateBranch({
    required String branchId,
    required String name,
    required String address,
    required String city,
    required String state,
    required String country,
    required String postalCode,
    required String contactNumber,
    required String contactEmail,
    required String description,
    required String landmark,
    // required double latitude,
    // required double longitude,
    required List<String> paymentMethod,
    required List<Service> services,
    File? imageFile,
  }) async {
    try {
      final loginUser = await prefs.getUser();
      isLoading.value = true;

      final Map<String, dynamic> data = {
        'name': name,
        'address': address,
        'city': city,
        'state': state,
        'country': country,
        'postal_code': postalCode,
        'contact_number': contactNumber,
        'contact_email': contactEmail,
        'description': description,
        'landmark': landmark,
        'payment_method': paymentMethod,
        'service_id': services.map((s) => s.id).toList(),
        'salon_id': loginUser!.salonId,
      };

      if (imageFile != null) {
        final String path = imageFile.path.toLowerCase();
        String? mimeType;
        if (path.endsWith('.jpg') || path.endsWith('.jpeg')) {
          mimeType = 'image/jpeg';
        } else if (path.endsWith('.png')) {
          mimeType = 'image/png';
        }
        if (mimeType == null) {
          CustomSnackbar.showError(
              'Invalid Image', 'Only JPG, JPEG, PNG images are allowed!');
          isLoading.value = false;
          return;
        }
        final parts = mimeType.split('/');
        data['image'] = await dio.MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split(Platform.pathSeparator).last,
          contentType: MediaType(parts[0], parts[1]),
        );
      }

      final formData = dio.FormData.fromMap(data);

      final response = await dioClient.dio.put(
        '${Apis.baseUrl}${Endpoints.postBranchs}/$branchId?salon_id=${loginUser!.salonId}',
        data: formData,
        options: dio.Options(headers: {
          'Content-Type': 'multipart/form-data',
        }),
      );

      if (response != null) {
        // Refresh the branches list after successful update
        await getBranches();
        // Get.back();
        CustomSnackbar.showSuccess('Success', 'Branch updated successfully');
      }
    } catch (e) {
      CustomSnackbar.showError('Error', 'Failed to update branch: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getServices() async {
    final loginUser = await prefs.getUser();
    try {
      final response = await dioClient.getData(
        '${Apis.baseUrl}${Endpoints.getServiceNames}${loginUser!.salonId}',
        (json) => json,
      );

      final data = response['data'] as List;
      serviceList.value = data.map((e) => Service.fromJson(e)).toList();
    } catch (e) {
      CustomSnackbar.showError('Error', 'Failed to get services: $e');
    }
  }
}
