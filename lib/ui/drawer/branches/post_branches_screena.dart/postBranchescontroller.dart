import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_template/network/network_const.dart';
import 'package:flutter_template/wiget/custome_snackbar.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart' as dio;
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';
import 'package:multi_dropdown/multi_dropdown.dart';
import '../../../../main.dart';
import '../getBranches/getBranchesController.dart';

// Simple Service class for add branch functionality
class Service {
  String? id;
  String? name;

  Service({this.id, this.name});

  Service.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    name = json['name'];
  }
}

class Postbranchescontroller extends GetxController {
  bool _isInitialized = false;

  @override
  void onInit() async {
    super.onInit();

    if (!_isInitialized) {
      _isInitialized = true;
      await getServices();
    }
  }

  var nameController = TextEditingController();
  var contactEmailController = TextEditingController();
  var contactNumberController = TextEditingController();
  var landmarkController = TextEditingController();
  var cityController = TextEditingController();
  var stateController = TextEditingController();
  var countryController = TextEditingController();
  var postalCodeController = TextEditingController();
  var discriptionController = TextEditingController();
  var addressController = TextEditingController();
  var selectedCategory = "".obs;
  var isActive = true.obs;
  RxList<Service> selectedServices = <Service>[].obs;
  RxList<Service> serviceList = <Service>[].obs;
  RxString locationText = "Press the button to get location".obs;
  final RxList<String> selectedPaymentMethod = <String>[].obs;
  var pincodeController = TextEditingController();

  // var latController = TextEditingController();
  // var lngController = TextEditingController();

  // Image state for branch add
  final Rx<File?> singleImage = Rx<File?>(null);

  // MultiSelect controllers
  final serviceController = MultiSelectController<Service>();
  final paymentMethodController = MultiSelectController<String>();

  @override
  void onClose() {
    nameController.dispose();
    contactEmailController.dispose();
    contactNumberController.dispose();
    landmarkController.dispose();
    cityController.dispose();
    stateController.dispose();
    countryController.dispose();
    postalCodeController.dispose();
    discriptionController.dispose();
    addressController.dispose();
    pincodeController.dispose();
    serviceController.dispose();
    paymentMethodController.dispose();
    super.onClose();
  }

  final List<String> dropdownItemSelectedCategory = [
    'Male',
    'Female',
    'Unisex',
  ];

  var isLoading = false.obs;
  var latitude = ''.obs;
  var longitude = ''.obs;

  var country = ''.obs;
  var state = ''.obs;
  var district = ''.obs;
  var block = ''.obs;
  var error = ''.obs;

  var landmark = ''.obs;
  var city = ''.obs;
  var postalCode = ''.obs;

  Future<void> getServices() async {
    if (isLoading.value) return; // Prevent multiple calls

    isLoading.value = true;
    final loginUser = await prefs.getUser();
    try {
      final response = await dioClient.getData(
        '${Apis.baseUrl}${Endpoints.getServiceNames}${loginUser!.salonId}',
        (json) => json,
      );

      final data = response['data'] as List;
      serviceList.value = data.map((e) => Service.fromJson(e)).toList();
    } catch (e) {
      CustomSnackbar.showError('Error', 'Failed to get data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future onBranchAdd() async {
    final loginUser = await prefs.getUser();
    try {
      isLoading.value = true;

      // Build map with all non-file fields
      Map<String, dynamic> branchData = {
        "name": nameController.text,
        "salon_id": loginUser!.salonId,
        'category': selectedCategory.value.toLowerCase(),
        'status': isActive.value ? 1 : 0,
        "contact_email": contactEmailController.text,
        "contact_number": contactNumberController.text,
        "payment_method":
            selectedPaymentMethod.map((e) => e.toLowerCase()).toList(),
        'service_id': selectedServices.map((s) => s.id).toList(),
        "landmark": landmarkController.text,
        "country": countryController.text,
        "state": stateController.text,
        "city": cityController.text,
        "postal_code": postalCodeController.text,
        // "latitude": latitude.value,
        // "longitude": longitude.value,
        "description": discriptionController.text,
        "address": addressController.text,
      };

      // Attach image if selected
      if (singleImage.value != null) {
        final mimeType = _getMimeType(singleImage.value!.path);
        if (mimeType == null) {
          CustomSnackbar.showError(
              'Invalid Image', 'Only JPG, JPEG, PNG images are allowed!');
          isLoading.value = false;
          return;
        }
        final mimeParts = mimeType.split('/');
        branchData['image'] = await dio.MultipartFile.fromFile(
          singleImage.value!.path,
          filename: singleImage.value!.path.split(Platform.pathSeparator).last,
          contentType: MediaType(mimeParts[0], mimeParts[1]),
        );
      }

      final formData = dio.FormData.fromMap(branchData);

      await dioClient.dio.post(
        '${Apis.baseUrl}${Endpoints.postBranchs}',
        data: formData,
        options: dio.Options(headers: {
          'Content-Type': 'multipart/form-data',
        }),
      );
      Get.find<Getbranchescontroller>().getBranches();
      Get.back();
      CustomSnackbar.showSuccess('Success', 'Branch added successfully');
    } catch (e) {
      print('==> here Error: $e');
      CustomSnackbar.showError('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // Image helpers
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
    await _handlePickedFile(pickedFile);
  }

  Future<void> pickImageFromCamera() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
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
}
