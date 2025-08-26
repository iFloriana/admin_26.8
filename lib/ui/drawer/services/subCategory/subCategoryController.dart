import 'package:flutter/widgets.dart';
import 'package:flutter_template/main.dart';
import 'package:flutter_template/network/network_const.dart';
import 'package:flutter_template/wiget/custome_snackbar.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart' as dio;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;

class Category {
  final String? id;
  final String? name;

  Category({this.id, this.name});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['_id'],
      name: json['name'],
    );
  }
}

class SubCategory {
  final String id;
  final String name;
  final String? categoryId;
  final int? status;

  SubCategory(
      {required this.id, required this.name, this.categoryId, this.status});

  factory SubCategory.fromJson(Map<String, dynamic> json) {
    String? categoryId;
    if (json['category_id'] is String) {
      categoryId = json['category_id'];
    } else if (json['category_id'] is Map<String, dynamic>) {
      categoryId = json['category_id']['_id'];
    }

    return SubCategory(
      id: json['_id'],
      name: json['name'],
      categoryId: categoryId,
      status: json['status'],
    );
  }
}

class Subcategorycontroller extends GetxController {
  @override
  void onInit() {
    super.onInit();
    getCategorys();
    getSubCategory();
  }

  var branchList = <Category>[].obs;
  var selectedBranch = Rx<Category?>(null);
  var nameController = TextEditingController();
  var isActive = true.obs;
  var subCategoryList = <SubCategory>[].obs;

  // Image state
  final Rx<File?> singleImage = Rx<File?>(null);
  final RxString editImageUrl = ''.obs;

  // Helper to get MIME type from file extension
  String? _getMimeType(String filePath) {
    final ext = path.extension(filePath).toLowerCase();
    if (ext == '.jpg' || ext == '.jpeg') {
      return 'image/jpeg';
    } else if (ext == '.png') {
      return 'image/png';
    }
    return null;
  }

  // Handle picked file, including size and type validation
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
        editImageUrl.value = ''; // Clear network image if a new one is picked
      } else {
        CustomSnackbar.showError('Error', 'Image size must be less than 150KB');
      }
    }
  }

  // Method to pick image from the gallery
  Future<void> pickImageFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    await _handlePickedFile(pickedFile);
  }

  // Method to pick image from the camera
  Future<void> pickImageFromCamera() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    await _handlePickedFile(pickedFile);
  }

  void resetForm() {
    nameController.clear();
    isActive.value = true;
    selectedBranch.value = null;
    singleImage.value = null;
    editImageUrl.value = '';
  }

  Future<void> getCategorys() async {
    final loginUser = await prefs.getUser();
    try {
      var response = await dioClient.getData(
        '${Apis.baseUrl}${Endpoints.getServiceCategotyName}${loginUser!.salonId}',
        (json) => json,
      );
      final data = response['data'] as List;
      branchList.value = data.map((e) => Category.fromJson(e)).toList();
    } catch (e) {
      print("==> ${e.toString()}");
      CustomSnackbar.showError('Error', 'Failed to get data: $e');
    }
  }

  Future<void> getSubCategory() async {
    final loginUser = await prefs.getUser();
    try {
      var response = await dioClient.getData(
        '${Apis.baseUrl}${Endpoints.getSubCategory}${loginUser!.salonId}',
        (json) => json,
      );
      final data = response['data'] as List;
      subCategoryList.value = data.map((e) => SubCategory.fromJson(e)).toList();
    } catch (e) {
      print("==> ${e.toString()}");
      CustomSnackbar.showError('Error', 'Failed to get data: $e');
    }
  }

  Future<void> deleteSubCategory(String? subCategoryId) async {
    final loginUser = await prefs.getUser();
    if (subCategoryId == null) return;
    try {
      await dioClient.deleteData(
        '${Apis.baseUrl}${Endpoints.addSubCategory}/$subCategoryId?salon_id=${loginUser!.salonId}',
        (json) => json,
      );

      subCategoryList.removeWhere((s) => s.id == subCategoryId);
      getSubCategory();
      CustomSnackbar.showSuccess('Deleted', 'Subcategory removed successfully');
    } catch (e) {
      CustomSnackbar.showError('Error', 'Failed to delete subcategory: $e');
    }
  }

  Future onaddNewSubcategory() async {
    final loginUser = await prefs.getUser();
    try {
      Map<String, dynamic> staffData = {
        "name": nameController.text,
        "salon_id": loginUser!.salonId,
        "category_id": selectedBranch.value?.id,
        'status': isActive.value ? 1 : 0,
      };
      if (singleImage.value != null) {
        final mimeType = _getMimeType(singleImage.value!.path);
        if (mimeType == null) {
          CustomSnackbar.showError(
              'Invalid Image', 'Only JPG, JPEG, PNG images are allowed!');
          return;
        }
        final mimeParts = mimeType.split('/');
        staffData['image'] = await dio.MultipartFile.fromFile(
          singleImage.value!.path,
          filename: singleImage.value!.path.split(Platform.pathSeparator).last,
          contentType: MediaType(mimeParts[0], mimeParts[1]),
        );
      }
      final formData = dio.FormData.fromMap(staffData);
      await dioClient.dio.post(
        '${Apis.baseUrl}${Endpoints.addSubCategory}',
        data: formData,
        options: dio.Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );
      getSubCategory();
      resetForm();
      CustomSnackbar.showSuccess('Success', 'Subcategory added successfully');
    } catch (e) {
      CustomSnackbar.showError('Error', e.toString());
    }
  }

  Future<void> onEditSubcategory(SubCategory subCategory) async {
    final loginUser = await prefs.getUser();
    try {
      Map<String, dynamic> data = {
        "name": nameController.text,
        "category_id": selectedBranch.value?.id,
        'status': isActive.value ? 1 : 0,
      };
      if (singleImage.value != null) {
        final mimeType = _getMimeType(singleImage.value!.path);
        if (mimeType == null) {
          CustomSnackbar.showError(
              'Invalid Image', 'Only JPG, JPEG, PNG images are allowed!');
          return;
        }
        final mimeParts = mimeType.split('/');
        data['image'] = await dio.MultipartFile.fromFile(
          singleImage.value!.path,
          filename: singleImage.value!.path.split(Platform.pathSeparator).last,
          contentType: MediaType(mimeParts[0], mimeParts[1]),
        );
      }
      final formData = dio.FormData.fromMap(data);
      await dioClient.dio.put(
        '${Apis.baseUrl}${Endpoints.addSubCategory}/${subCategory.id}/?salon_id=${loginUser!.salonId}',
        data: formData,
        options: dio.Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );
      getSubCategory();
      resetForm();
      CustomSnackbar.showSuccess('Success', 'Subcategory updated successfully');
    } catch (e) {
      CustomSnackbar.showError('Error', e.toString());
    }
  }

  // When editing, set image url and clear local image
  void startEditing(SubCategory subCategory) {
    nameController.text = subCategory.name;
    selectedBranch.value =
        branchList.firstWhereOrNull((c) => c.id == subCategory.categoryId);
    isActive.value = subCategory.status == 1;
    singleImage.value = null;
    editImageUrl.value = subCategory.id.isNotEmpty ? subCategory.id : '';
  }
}
