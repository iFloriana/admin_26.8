import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:flutter_template/main.dart';
import 'package:flutter_template/network/network_const.dart';
import 'package:flutter_template/wiget/custome_snackbar.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart' as dio;
import 'package:http_parser/http_parser.dart';

class Category {
  final String id;
  final String name;

  Category({required this.id, required this.name});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
    );
  }
}

class Service {
  String? id;
  String? name;
  int? duration;
  int? price;
  int? status;
  String? description;
  String? categoryId;
  String? image_url;

  Service({
    this.id,
    this.name,
    this.duration,
    this.price,
    this.status,
    this.description,
    this.categoryId,
    this.image_url,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['_id']?.toString(),
      name: json['name']?.toString(),
      duration: json['service_duration'] is int
          ? json['service_duration']
          : int.tryParse(json['service_duration']?.toString() ?? '0'),
      price: json['regular_price'] is int
          ? json['regular_price']
          : int.tryParse(json['regular_price']?.toString() ?? '0'),
      status: json['status'] is int
          ? json['status']
          : int.tryParse(json['status']?.toString() ?? '0'),
      description: json['description']?.toString(),
      categoryId: json['category_id'] is Map
          ? (json['category_id']['_id']?.toString())
          : json['category_id']?.toString(),
      image_url: json['image_url']?.toString(),
    );
  }
}

class Addservicescontroller extends GetxController {
  var nameController = TextEditingController();
  var serviceDuration = TextEditingController();
  var regularPrice = TextEditingController();
  var descriptionController = TextEditingController();
  var isActive = true.obs;
  var categories = <Category>[].obs;
  var selectedCategory = Rxn<Category>();
  var serviceList = <Service>[].obs;
  var isEditing = false.obs;
  var editingService = Rxn<Service>();

  // Image handling variables
  final Rx<File?> singleImage = Rx<File?>(null);
  final RxString editImageUrl = ''.obs; // For network image in edit mode
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    getCategorys();
    getAllServices();
  }

  @override
  void onClose() {
    nameController.dispose();
    serviceDuration.dispose();
    regularPrice.dispose();
    descriptionController.dispose();
    super.onClose();
  }

  Future<void> startEditing(Service service) async {
    isEditing.value = true;
    editingService.value = service;
    nameController.text = service.name ?? '';
    serviceDuration.text = service.duration?.toString() ?? '';
    regularPrice.text = service.price?.toString() ?? '';
    descriptionController.text = service.description ?? '';
    isActive.value = service.status == 1;

    // Reset image selection for editing
    singleImage.value = null;
    editImageUrl.value = service.image_url ?? '';

    // Ensure categories are loaded first
    if (categories.isEmpty) {
      await getCategorys();
    }
    final categoryToSelect = categories.firstWhereOrNull(
      (category) => category.id == service.categoryId,
    );
    selectedCategory.value = categoryToSelect;
  }

  void resetForm() {
    nameController.clear();
    serviceDuration.clear();
    regularPrice.clear();
    descriptionController.clear();
    isActive.value = true;
    selectedCategory.value = null;
    isEditing.value = false;
    editingService.value = null;
    singleImage.value = null;
    editImageUrl.value = '';
  }

  // Helper to get MIME type from file extension
  String? _getMimeType(String path) {
    final ext = path.toLowerCase();
    if (ext.endsWith('.jpg') || ext.endsWith('.jpeg')) {
      return 'image/jpeg';
    } else if (ext.endsWith('.png')) {
      return 'image/png';
    }
    return null;
  }

  // Image picker methods
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

  Future<void> getCategorys() async {
    final loginUser = await prefs.getUser();
    try {
      final response = await dioClient.dio.get(
          '${Apis.baseUrl}${Endpoints.getServiceCategotyName}${loginUser!.salonId}');
      final data = response.data["data"] as List;

      categories.value = data.map((item) => Category.fromJson(item)).toList();
      print('Categories loaded: ${categories.length}');

      // Trigger UI update
      categories.refresh();
    } catch (e) {
      CustomSnackbar.showError('Error', 'Failed to get data: $e');
    }
  }

  Future<void> onServicePress() async {
    if (isEditing.value && editingService.value != null) {
      await updateService(editingService.value!.id!);
    } else {
      await addService();
    }
  }

  Future<void> addService() async {
    final loginUser = await prefs.getUser();

    try {
      isLoading.value = true;

      // Prepare form data for multipart request
      Map<String, dynamic> serviceData = {
        "name": nameController.text,
        "service_duration": int.parse(serviceDuration.text),
        "regular_price": int.parse(regularPrice.text),
        "category_id": selectedCategory.value?.id,
        "description": descriptionController.text,
        "status": isActive.value ? 1 : 0,
        "salon_id": loginUser!.salonId
      };

      // Add image if selected
      if (singleImage.value != null) {
        final mimeType = _getMimeType(singleImage.value!.path);
        if (mimeType == null) {
          CustomSnackbar.showError(
              'Invalid Image', 'Only JPG, JPEG, PNG images are allowed!');
          isLoading.value = false;
          return;
        }
        final mimeParts = mimeType.split('/');
        serviceData['image'] = await dio.MultipartFile.fromFile(
          singleImage.value!.path,
          filename: singleImage.value!.path.split(Platform.pathSeparator).last,
          contentType: MediaType(mimeParts[0], mimeParts[1]),
        );
      }

      // Create FormData for multipart request
      final formData = dio.FormData.fromMap(serviceData);

      await dioClient.dio.post(
        '${Apis.baseUrl}${Endpoints.getServices}',
        data: formData,
        options: dio.Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      getAllServices();
      Get.back();
      resetForm();
      CustomSnackbar.showSuccess('Success', 'Service Added Successfully');
    } catch (e) {
      CustomSnackbar.showError('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateService(String id) async {
    final loginUser = await prefs.getUser();

    try {
      isLoading.value = true;

      // Prepare form data for multipart request
      Map<String, dynamic> serviceData = {
        "name": nameController.text,
        "service_duration": int.parse(serviceDuration.text),
        "regular_price": int.parse(regularPrice.text),
        "category_id": selectedCategory.value?.id,
        "description": descriptionController.text,
        "status": isActive.value ? 1 : 0,
        "salon_id": loginUser!.salonId
      };

      // Add image if selected
      if (singleImage.value != null) {
        final mimeType = _getMimeType(singleImage.value!.path);
        if (mimeType == null) {
          CustomSnackbar.showError(
              'Invalid Image', 'Only JPG, JPEG, PNG images are allowed!');
          isLoading.value = false;
          return;
        }
        final mimeParts = mimeType.split('/');
        serviceData['image'] = await dio.MultipartFile.fromFile(
          singleImage.value!.path,
          filename: singleImage.value!.path.split(Platform.pathSeparator).last,
          contentType: MediaType(mimeParts[0], mimeParts[1]),
        );
      }

      // Create FormData for multipart request
      final formData = dio.FormData.fromMap(serviceData);

      await dioClient.dio.put(
        '${Apis.baseUrl}${Endpoints.getServices}/$id?salon_id=${loginUser.salonId}',
        data: formData,
        options: dio.Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      await getAllServices();
      Get.back();
      resetForm();
      CustomSnackbar.showSuccess('Success', 'Service Updated Successfully');
    } catch (e) {
      CustomSnackbar.showError('Error', 'Failed to update service: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getAllServices() async {
    final loginUser = await prefs.getUser();
    try {
      final response = await dioClient.getData<Map<String, dynamic>>(
        '${Apis.baseUrl}${Endpoints.getAllServices}${loginUser!.salonId}',
        (json) => json as Map<String, dynamic>,
      );

      if (response['data'] != null) {
        List<dynamic> servicesJson = response['data'];

        final services = servicesJson.map((e) {
          return Service.fromJson(e);
        }).toList();

        serviceList.value = services;
      } else {
        serviceList.clear();
        CustomSnackbar.showError(
            'Error', response['message'] ?? 'Failed to fetch services');
      }
    } catch (e) {
      serviceList.clear();
      CustomSnackbar.showError('Error', 'Failed to fetch services: $e');
    }
  }

  Future<void> deleteService(String id) async {
    final loginUser = await prefs.getUser();
    try {
      await dioClient.deleteData(
        '${Apis.baseUrl}${Endpoints.getServices}/$id?salon_id=${loginUser!.salonId}',
        (json) => json,
      );
      await getAllServices();

      CustomSnackbar.showSuccess('Success', 'Service deleted successfully');
    } catch (e) {
      CustomSnackbar.showError('Error', 'Failed to delete service: $e');
    }
  }
}
