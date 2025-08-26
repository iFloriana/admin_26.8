import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_template/main.dart';
import 'package:flutter_template/network/network_const.dart';
import 'package:flutter_template/wiget/custome_snackbar.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart' as dio;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;

class CreateServiceCategory {
  String? id;
  String? name;
  String? image;
  int? status;

  CreateServiceCategory({this.id, this.name, this.image, this.status});

  factory CreateServiceCategory.fromJson(Map<String, dynamic> json) {
    return CreateServiceCategory(
      id: json['_id'],
      name: json['name'],
      image: json['image_url'],
      status: json['status'],
    );
  }
}

class AddNewCategotyController extends GetxController {
  var nameController = TextEditingController();
  var isActive = true.obs;

  RxList<CreateServiceCategory> serviceList = <CreateServiceCategory>[].obs;
  RxBool isEditing = false.obs;
  Rxn<CreateServiceCategory> editingItem = Rxn<CreateServiceCategory>();

  // Add state variables for image handling
  final Rx<File?> singleImage = Rx<File?>(null);
  final RxString editImageUrl =
      ''.obs; // To store the URL of the existing image

  @override
  void onInit() {
    super.onInit();
    callCategories();
  }

  void startEditing(CreateServiceCategory item) {
    isEditing.value = true;
    editingItem.value = item;
    nameController.text = item.name ?? '';
    isActive.value = (item.status ?? 0) == 1;
    // Set the network image URL when editing
    singleImage.value = null; // Clear local image
    editImageUrl.value = item.image ?? '';
  }

  void resetForm() {
    nameController.clear();
    isActive.value = true;
    isEditing.value = false;
    editingItem.value = null;
    // Reset image state
    singleImage.value = null;
    editImageUrl.value = '';
  }

  Future<void> onAddOrUpdateCategoryPress() async {
    if (isEditing.value && editingItem.value != null) {
      await onEditPress(editingItem.value!.id ?? '');
    } else {
      await onAddCategoryPress();
    }
  }

  Future<void> onAddCategoryPress() async {
    if (nameController.text.isEmpty) {
      CustomSnackbar.showError('Error', 'Please enter a name');
      return;
    }
    final loginUser = await prefs.getUser();
    try {
      Map<String, dynamic> serviceData = {
        'name': nameController.text,
        'status': isActive.value ? 1 : 0,
        'salon_id': loginUser!.salonId,
      };
      if (singleImage.value != null) {
        final mimeType = _getMimeType(singleImage.value!.path);
        if (mimeType == null) {
          CustomSnackbar.showError(
              'Invalid Image', 'Only JPG, JPEG, PNG images are allowed!');
          return;
        }
        final mimeParts = mimeType.split('/');
        serviceData['image'] = await dio.MultipartFile.fromFile(
          singleImage.value!.path,
          filename: singleImage.value!.path.split(Platform.pathSeparator).last,
          contentType: MediaType(mimeParts[0], mimeParts[1]),
        );
      }
      final formData = dio.FormData.fromMap(serviceData);
      await dioClient.dio.post(
        '${Apis.baseUrl}${Endpoints.postServiceCategory}',
        data: formData,
        options: dio.Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );
      callCategories();
      resetForm();
      CustomSnackbar.showSuccess('Success', 'Added Successfully');
    } catch (e) {
      CustomSnackbar.showError('Error', e.toString());
    }
  }

  Future<void> onEditPress(String id) async {
    final loginUser = await prefs.getUser();
    try {
      Map<String, dynamic> staffData = {
        'name': nameController.text,
        'status': isActive.value ? 1 : 0,
        'salon_id': loginUser!.salonId,
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
      await dioClient.dio.put(
        '${Apis.baseUrl}${Endpoints.postServiceCategory}/$id',
        data: formData,
        options: dio.Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );
      callCategories();
      resetForm();
      CustomSnackbar.showSuccess('Success', 'Updated Successfully');
    } catch (e) {
      CustomSnackbar.showError('Error', 'Failed: $e');
    }
  }

  Future<void> callCategories() async {
    final loginUser = await prefs.getUser();
    try {
      final response = await dioClient.getData(
        '${Apis.baseUrl}${Endpoints.postServiceCategoryGet}${loginUser!.salonId}',
        (json) => json,
      );

      if (response['data'] != null) {
        serviceList.value = (response['data'] as List)
            .map((e) => CreateServiceCategory.fromJson(e))
            .toList();
      }
    } catch (e) {
      CustomSnackbar.showError('Error', 'Failed to fetch categories: $e');
    }
  }

  Future<void> deleteCategory(String id) async {
    final loginUser = await prefs.getUser();
    try {
      await dioClient.deleteData(
        '${Apis.baseUrl}${Endpoints.postServiceCategory}/$id/?salon_id=${loginUser!.salonId}',
        (json) => json,
      );
      callCategories();
      CustomSnackbar.showSuccess('Success', 'Deleted Successfully');
    } catch (e) {
      CustomSnackbar.showError('Error', 'Failed to delete: $e');
    }
  }

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
}
