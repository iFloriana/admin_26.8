import 'dart:io';

import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../main.dart';
import 'package:dio/dio.dart' as dio;
import '../../../../network/network_const.dart';
import '../../../../wiget/custome_snackbar.dart';
import '../../../../network/model/category_model.dart' as model;
import 'package:flutter/material.dart';
import 'package:multi_dropdown/multi_dropdown.dart';
import 'package:http_parser/http_parser.dart';

typedef Brand = model.Brand;
typedef Branch1 = model.Branch;

class ManagerCategorycontroller extends GetxController {
  RxList<model.Category> categories = <model.Category>[].obs;
  RxBool isLoading = false.obs;
  var nameController = TextEditingController();
  var isActive = true.obs;
  var selectedBrand = <Brand>[].obs;
  final brandController = MultiSelectController<Brand>();
  var brandList = <Brand>[].obs;
  var selectedBranches = <Branch1>[].obs;
  var branchList = <Branch1>[].obs;
  final branchController = MultiSelectController<Branch1>();
  final Rx<File?> singleImage = Rx<File?>(null);
  final RxString editImageUrl = ''.obs;
  @override
  void onInit() {
    super.onInit();

    getCategories();
    getBrand();
    getBranches();
  }

  Future<void> getCategories() async {
    isLoading.value = true;
    final loginUser = await prefs.getManagerUser();
    try {
      await dioClient.getData(
        '${Apis.baseUrl}${Endpoints.getAllCategory}${loginUser!.manager?.salonId}',
        (json) {
          final response = model.CategoryResponse.fromJson(json);
          categories.value = response.data;
          return json;
        },
      );
    } catch (e) {
      CustomSnackbar.showError('Error', 'Failed to get categories: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getBrand() async {
    final loginUser = await prefs.getManagerUser();
    try {
      final response = await dioClient.getData(
        '${Apis.baseUrl}${Endpoints.getBrandName}${loginUser!.manager?.salonId}',
        (json) => json,
      );

      final data = response['data'] as List;
      brandList.value = data.map((e) => model.Brand.fromJson(e)).toList();
    } catch (e) {
      CustomSnackbar.showError('Error', 'Failed to get data: $e');
    }
  }

  Future<void> getBranches() async {
    final loginUser = await prefs.getManagerUser();
    try {
      final response = await dioClient.getData(
        '${Apis.baseUrl}${Endpoints.getBranchName}${loginUser!.manager?.salonId}',
        (json) => json,
      );

      final data = response['data'] as List;
      branchList.value = data.map((e) => model.Branch.fromJson(e)).toList();
    } catch (e) {
      CustomSnackbar.showError('Error', 'Failed to get data: $e');
    }
  }

  Future onAddSubCategory() async {
    if (nameController.text.isEmpty) {
      CustomSnackbar.showError('Error', 'Please enter subcategory name');
      return;
    }

    if (selectedBranches.isEmpty) {
      CustomSnackbar.showError('Error', 'Please select at least one branch');
      return;
    }

    if (selectedBrand.isEmpty) {
      CustomSnackbar.showError('Error', 'Please select at least one brand');
      return;
    }

    final loginUser = await prefs.getManagerUser();
    Map<String, dynamic> subCategoryData = {
      "name": nameController.text,
      'branch_id': selectedBranches.map((branch) => branch.id).toList(),
      'status': isActive.value ? 1 : 0,
      'salon_id': loginUser!.manager?.salonId,
      'brand_id': selectedBrand.map((brand) => brand.id).toList(),
    };
    if (singleImage.value != null) {
      final mimeType = _getMimeType(singleImage.value!.path);
      if (mimeType == null) {
        CustomSnackbar.showError(
            'Invalid Image', 'Only JPG, JPEG, PNG images are allowed!');
        isLoading.value = false;
        return;
      }
      final mimeParts = mimeType.split('/');
      subCategoryData['image'] = await dio.MultipartFile.fromFile(
        singleImage.value!.path,
        filename: singleImage.value!.path.split(Platform.pathSeparator).last,
        contentType: MediaType(mimeParts[0], mimeParts[1]),
      );
    }
    final formData = dio.FormData.fromMap(subCategoryData);
    try {
      await dioClient.dio.post(
        '${Apis.baseUrl}${Endpoints.postSubCategory}',
        data: formData,
        options: dio.Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );
      resetForm();
      getCategories();
      Get.back(); // Close the bottom sheet

      CustomSnackbar.showSuccess(
          'Success', 'SubCategory Added Successfully'); // Reset the form
    } catch (e) {
      print('==> here Error: $e');
      CustomSnackbar.showError('Error', e.toString());
    }
  }

  void resetForm() {
    nameController.clear();
    isActive.value = true;
    selectedBranches.clear();
    selectedBrand.clear();
    singleImage.value = null;
    editImageUrl.value = ''; // Clear the network image URL
  }

  Future<void> deleteCategory(String categoryId) async {
    try {
      isLoading.value = true;
      final loginUser = await prefs.getManagerUser();
      await dioClient.deleteData(
        '${Apis.baseUrl}${Endpoints.postSubCategory}/$categoryId?salon_id=${loginUser!.manager?.salonId}',
        (json) => json,
      );

      // Refresh the categories list
      await getCategories();
      CustomSnackbar.showSuccess('Success', 'Category deleted successfully');
    } catch (e) {
      CustomSnackbar.showError('Error', 'Failed to delete category: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> showDeleteConfirmation(
      String categoryId, String categoryName) async {
    deleteCategory(categoryId);
  }

  Future<void> pickImageFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    editImageUrl.value = ''; // Clear network image when picking new
    await _handlePickedFile(pickedFile);
  }

  Future<void> pickImageFromCamera() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    editImageUrl.value = ''; // Clear network image when picking new
    await _handlePickedFile(pickedFile);
  }

  String? _getMimeType(String path) {
    final ext = path.toLowerCase();
    if (ext.endsWith('.jpg') || ext.endsWith('.jpeg')) {
      return 'image/jpeg';
    } else if (ext.endsWith('.png')) {
      return 'image/png';
    }
    return null;
  }

  Future<void> _handlePickedFile(XFile? pickedFile) async {
    const maxSizeInBytes = 150 * 1024; // 150 KB
    if (pickedFile != null) {
      final file = File(pickedFile.path);
      final mimeType = _getMimeType(pickedFile.path);
      if (mimeType == null) {
        CustomSnackbar.showError(
            'Invalid Image', 'Only JPG, JPEG, PNG images are allowed!');
        return;
      }
      if (await file.length() < maxSizeInBytes) {
        singleImage.value = file;
      } else {
        CustomSnackbar.showError('Error', 'Image size must be less than 150KB');
      }
    }
  }

  Future<void> updateCategory(String categoryId) async {
    final loginUser = await prefs.getManagerUser();
    Map<String, dynamic> categoryData = {
      "image": null,
      "name": nameController.text,
      'branch_id': selectedBranches.map((branch) => branch.id).toList(),
      'status': isActive.value ? 1 : 0,
      'salon_id': loginUser!.manager?.salonId,
      'brand_id': selectedBrand.map((brand) => brand.id).toList(),
    };
    if (singleImage.value != null) {
      final mimeType = _getMimeType(singleImage.value!.path);
      if (mimeType == null) {
        CustomSnackbar.showError(
            'Invalid Image', 'Only JPG, JPEG, PNG images are allowed!');
        isLoading.value = false;
        return;
      }
      final mimeParts = mimeType.split('/');
      categoryData['image'] = await dio.MultipartFile.fromFile(
        singleImage.value!.path,
        filename: singleImage.value!.path.split(Platform.pathSeparator).last,
        contentType: MediaType(mimeParts[0], mimeParts[1]),
      );
    }
    final formData = dio.FormData.fromMap(categoryData);
    try {
      await dioClient.dio.put(
        '${Apis.baseUrl}${Endpoints.postSubCategory}/$categoryId',
        data: formData,
        options: dio.Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );
      resetForm();
      await getCategories();

      CustomSnackbar.showSuccess('Success', 'Category updated successfully');
    } catch (e) {
      print('==> here Error: $e');
      CustomSnackbar.showError('Error', e.toString());
    }
  }
}
