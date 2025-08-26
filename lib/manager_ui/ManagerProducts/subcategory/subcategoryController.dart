import 'package:flutter/widgets.dart';
import 'package:flutter_template/network/model/productSubCategory.dart';
import 'package:get/get.dart';
import 'package:multi_dropdown/multi_dropdown.dart';
import '../../../../main.dart';
import '../../../../network/network_const.dart';
import '../../../../wiget/custome_snackbar.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart' as dio;
import 'package:http_parser/http_parser.dart';

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

class Subcategorys {
  final String? id;
  final String? name;

  Subcategorys({this.id, this.name});

  factory Subcategorys.fromJson(Map<String, dynamic> json) {
    return Subcategorys(
      id: json['_id'],
      name: json['name'],
    );
  }
}

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

class ManagerSubcategorycontroller extends GetxController {
  final subCategories = <ProductSubCategory>[].obs;
  final isLoading = false.obs;
  var isActive = true.obs;
  var branchList = <Branch1>[].obs;
  var categoryList = <Category>[].obs;

  var brandList = <Subcategorys>[].obs;
  var selectedCategory = Rx<Category?>(null);
  var selectedBranches = <Branch1>[].obs;
  var selectedBrand = <Subcategorys>[].obs;
  var nameController = TextEditingController();
  final branchController = MultiSelectController<Branch1>();
  final brandController = MultiSelectController<Subcategorys>();
  final Rx<File?> singleImage = Rx<File?>(null);
  final RxString editImageUrl = ''.obs;

  @override
  void onInit() {
    super.onInit();
    getSubCategories();
    getBranches();
    getBrand();
    getCatedory();
    singleImage.value = null;
    editImageUrl.value = '';
  }

  @override
  void onClose() {
    nameController.dispose();
    branchController.dispose();
    singleImage.value = null;
    editImageUrl.value = '';
    super.onClose();
  }

  Future<void> getSubCategories() async {
    final loginUser = await prefs.getManagerUser();
    try {
      isLoading.value = true;
      final response = await dioClient.getData(
        '${Apis.baseUrl}${Endpoints.getProductSubCategories}${loginUser!.manager?.salonId}',
        (json) => json,
      );

      if (response != null && response['data'] != null) {
        final List<dynamic> data = response['data'];
        subCategories.value =
            data.map((json) => ProductSubCategory.fromJson(json)).toList();
      }
    } catch (e) {
      CustomSnackbar.showError('Error', 'Failed to get data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteSubCategory(String subCategoryId) async {
    try {
      isLoading.value = true;
      final loginUser = await prefs.getManagerUser();

      final response = await dioClient.deleteData(
        '${Apis.baseUrl}${Endpoints.productSubcategory}/$subCategoryId?salon_id=${loginUser!.manager?.salonId}',
        (json) => json,
      );

      if (response != null) {
        subCategories
            .removeWhere((subCategory) => subCategory.id == subCategoryId);
        getSubCategories();
        CustomSnackbar.showSuccess(
            'Success', 'SubCategory deleted successfully');
      }
    } catch (e) {
      CustomSnackbar.showError('Error', 'Failed to delete subcategory: $e');
    } finally {
      isLoading.value = false;
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
      branchList.value = data.map((e) => Branch1.fromJson(e)).toList();
    } catch (e) {
      CustomSnackbar.showError('Error', 'Failed to get data: $e');
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
      brandList.value = data.map((e) => Subcategorys.fromJson(e)).toList();
    } catch (e) {
      CustomSnackbar.showError('Error', 'Failed to get data: $e');
    }
  }

  Future<void> getCatedory() async {
    final loginUser = await prefs.getManagerUser();
    try {
      final response = await dioClient.getData(
        '${Apis.baseUrl}${Endpoints.getproductName}${loginUser!.manager?.salonId}',
        (json) => json,
      );

      final data = response['data'] as List;
      categoryList.value = data.map((e) => Category.fromJson(e)).toList();
    } catch (e) {
      CustomSnackbar.showError('Error', 'Failed to get data: $e');
    }
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

  Future<void> pickImageFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    editImageUrl.value = '';
    await _handlePickedFile(pickedFile);
  }

  Future<void> pickImageFromCamera() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    editImageUrl.value = '';
    await _handlePickedFile(pickedFile);
  }

  Future<void> _handlePickedFile(XFile? pickedFile) async {
    const maxSizeInBytes = 150 * 1024; // 150 KB
    if (pickedFile != null) {
      final file = File(pickedFile.path);
      final mimeType = _getMimeType(pickedFile.path);
      if (mimeType == null) {
        CustomSnackbar.showError('Invalid Image', 'Only JPG, JPEG, PNG images are allowed!');
        return;
      }
      if (await file.length() < maxSizeInBytes) {
        singleImage.value = file;
      } else {
        CustomSnackbar.showError('Error', 'Image size must be less than 150KB');
      }
    }
  }

  Future onAddSubCategory() async {
  
    final loginUser = await prefs.getManagerUser();
    Map<String, dynamic> subCategoryData = {
      "name": nameController.text,
      'branch_id': selectedBranches.map((branch) => branch.id).toList(),
      'status': isActive.value ? 1 : 0,
      'salon_id': loginUser!.manager?.salonId,
      'product_category_id': selectedCategory.value!.id,
      'brand_id': selectedBrand.map((brand) => brand.id).toList(),
    };

    try {
      dio.FormData? formData;
      if (singleImage.value != null) {
        final mimeType = _getMimeType(singleImage.value!.path);
        if (mimeType == null) {
          CustomSnackbar.showError('Invalid Image', 'Only JPG, JPEG, PNG images are allowed!');
          return;
        }
        final mimeParts = mimeType.split('/');
        subCategoryData['image'] = await dio.MultipartFile.fromFile(
          singleImage.value!.path,
          filename: singleImage.value!.path.split(Platform.pathSeparator).last,
          contentType: MediaType(mimeParts[0], mimeParts[1]),
        );
        formData = dio.FormData.fromMap(subCategoryData);
      }
      if (formData != null) {
        await dioClient.dio.post(
          '${Apis.baseUrl}${Endpoints.productSubcategory}',
          data: formData,
          options: dio.Options(headers: {'Content-Type': 'multipart/form-data'}),
        );
      } else {
        await dioClient.postData(
          '${Apis.baseUrl}${Endpoints.productSubcategory}',
          subCategoryData,
          (json) => json,
        );
      }
      // Get.back(); 
      getSubCategories();
      resetForm(); 
       CustomSnackbar.showSuccess(
          'Success', 'SubCategory Added Successfully'); 
    } catch (e) {
      print('==> here Error: $e');
      CustomSnackbar.showError('Error', e.toString());
    }
  }

  Future<void> updateSubCategory(String subCategoryId) async {
    final loginUser = await prefs.getManagerUser();
    Map<String, dynamic> subCategoryData = {
      "name": nameController.text,
      'branch_id': selectedBranches.map((branch) => branch.id).toList(),
      'status': isActive.value ? 1 : 0,
      'salon_id': loginUser!.manager?.salonId,
      'product_category_id': selectedCategory.value!.id,
      'brand_id': selectedBrand.map((brand) => brand.id).toList(),
    };
    try {
      dio.FormData? formData;
      if (singleImage.value != null) {
        final mimeType = _getMimeType(singleImage.value!.path);
        if (mimeType == null) {
          CustomSnackbar.showError('Invalid Image', 'Only JPG, JPEG, PNG images are allowed!');
          return;
        }
        final mimeParts = mimeType.split('/');
        subCategoryData['image'] = await dio.MultipartFile.fromFile(
          singleImage.value!.path,
          filename: singleImage.value!.path.split(Platform.pathSeparator).last,
          contentType: MediaType(mimeParts[0], mimeParts[1]),
        );
        formData = dio.FormData.fromMap(subCategoryData);
      }
      if (formData != null) {
        await dioClient.dio.put(
          '${Apis.baseUrl}${Endpoints.productSubcategory}/$subCategoryId?salon_id=${loginUser!.manager?.salonId}',
          data: formData,
          options: dio.Options(headers: {'Content-Type': 'multipart/form-data'}),
        );
      } else {
        await dioClient.putData(
          '${Apis.baseUrl}${Endpoints.productSubcategory}/$subCategoryId',
          subCategoryData,
          (json) => json,
        );
      }
      await getSubCategories();
      // Get.back();
      resetForm();
      CustomSnackbar.showSuccess('Success', 'SubCategory updated successfully');
    } catch (e) {
      print('==> here Error: $e');
      CustomSnackbar.showError('Error', e.toString());
    }
  }

  void resetForm() {
    nameController.clear();
    isActive.value = true;
    selectedBranches.clear();
    singleImage.value = null;
    editImageUrl.value = '';
  }
}
