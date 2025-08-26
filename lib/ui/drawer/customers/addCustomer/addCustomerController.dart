import 'package:flutter/material.dart';
import 'package:flutter_template/main.dart';
import 'package:flutter_template/network/network_const.dart';
import 'package:flutter_template/wiget/custome_snackbar.dart';
import 'package:get/get.dart';
import 'package:multi_dropdown/multi_dropdown.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart' as dio;
import 'dart:io';
import 'dart:convert';
import '../customerController.dart';

class Salon {
  final String? id;
  final String? salonName;
  final String? description;
  final String? address;
  final String? contactNumber;
  final String? contactEmail;
  final String? openingTime;
  final String? closingTime;
  final String? category;
  final int? status;
  final String? packageId;
  final String? signupId;
  final String? createdAt;
  final String? updatedAt;
  final String? image;

  Salon({
    this.id,
    this.salonName,
    this.description,
    this.address,
    this.contactNumber,
    this.contactEmail,
    this.openingTime,
    this.closingTime,
    this.category,
    this.status,
    this.packageId,
    this.signupId,
    this.createdAt,
    this.updatedAt,
    this.image,
  });

  factory Salon.fromJson(Map<String, dynamic> json) {
    return Salon(
      id: json['_id'],
      salonName: json['salon_name'],
      description: json['description'],
      address: json['address'],
      contactNumber: json['contact_number'],
      contactEmail: json['contact_email'],
      openingTime: json['opening_time'],
      closingTime: json['closing_time'],
      category: json['category'],
      status: json['status'],
      packageId: json['package_id'],
      signupId: json['signup_id'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      image: json['image'],
    );
  }
}

class BranchPackage {
  final String? id;
  final String? packageName;

  BranchPackage({this.id, this.packageName});

  factory BranchPackage.fromJson(Map<String, dynamic> json) {
    return BranchPackage(
      id: json['_id'],
      packageName: json['package_name'],
    );
  }
}

class BranchMembership {
  final String? id;
  final String? membershipName;

  BranchMembership({this.id, this.membershipName});

  factory BranchMembership.fromJson(Map<String, dynamic> json) {
    return BranchMembership(
      id: json['_id'],
      membershipName: json['membership_name'],
    );
  }
}

class Addcustomercontroller extends GetxController {
  var isLoading = false.obs;
  var isActive = true.obs;
  var showPackageFields = false.obs;

  // Controllers
  var fullNameController = TextEditingController();
  var emailController = TextEditingController();
  var phoneController = TextEditingController();
  // var passwordController = TextEditingController();
  final packageController = MultiSelectController<BranchPackage>();

  // Image picker
  final ImagePicker _picker = ImagePicker();
  var selectedImage = Rx<File?>(null);

  // Dropdown values
  var selectedGender = ''.obs;
  var selectedBranchMembership = ''.obs;
  var selectedPackages = <BranchPackage>[].obs;

  // Lists for dropdowns
  var branchPackageList = <BranchPackage>[].obs;
  var branchMembershipList = <BranchMembership>[].obs;

  final List<String> genderOptions = ['Male', 'Female', 'Other'];

  @override
  void onInit() {
    super.onInit();
    getBranchPackages();
    getBranchMemberships();
  }

  @override
  void onClose() {
    fullNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    // passwordController.dispose();
    packageController.dispose();
    super.onClose();
  }

  // Image picker methods
  Future<void> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (image != null) {
        selectedImage.value = File(image.path);
      }
    } catch (e) {
      CustomSnackbar.showError(
          'Error', 'Failed to pick image from gallery: $e');
    }
  }

  Future<void> pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );
      if (image != null) {
        selectedImage.value = File(image.path);
      }
    } catch (e) {
      CustomSnackbar.showError(
          'Error', 'Failed to capture image from camera: $e');
    }
  }

  void removeSelectedImage() {
    selectedImage.value = null;
  }

  void showImageSourceDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  pickImageFromGallery();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take Photo'),
                onTap: () {
                  Navigator.pop(context);
                  pickImageFromCamera();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> getBranchPackages() async {
    try {
      final loginUser = await prefs.getUser();
      final response = await dioClient.getData(
        '${Apis.baseUrl}${Endpoints.getBranchpackagesNames}${loginUser!.salonId}',
        (json) => json,
      );

      final data = response['data'] as List;
      branchPackageList.value =
          data.map((e) => BranchPackage.fromJson(e)).toList();
    } catch (e) {
      CustomSnackbar.showError('Error', 'Failed to get branch packages: $e');
    }
  }

  Future<void> getBranchMemberships() async {
    try {
      final loginUser = await prefs.getUser();
      final response = await dioClient.getData(
        '${Apis.baseUrl}${Endpoints.getBranchMembershipNames}?salon_id=${loginUser!.salonId}',
        (json) => json,
      );

      final data = response['data'] as List;
      branchMembershipList.value =
          data.map((e) => BranchMembership.fromJson(e)).toList();
    } catch (e) {
      CustomSnackbar.showError('Error', 'Failed to get branch memberships: $e');
    }
  }

  Future<void> addCustomer() async {
    try {
      isLoading.value = true;
      final loginUser = await prefs.getUser();

      // Prepare form data for multipart request
      Map<String, dynamic> customerData = {
        'salon_id': loginUser!.salonId,
        'full_name': fullNameController.text,
        'email': emailController.text,
        'gender': selectedGender.value.toLowerCase(),
        // 'password': passwordController.text,
        'phone_number': phoneController.text,
        'status': isActive.value ? 1 : 0,
      };

      if (showPackageFields.value) {
        customerData['branch_package'] =
            selectedPackages.map((p) => p.id).toList();
        customerData['branch_membership'] = selectedBranchMembership.value;
      } 

      // Add image if selected
      if (selectedImage.value != null) {
        customerData['image'] = await dio.MultipartFile.fromFile(
          selectedImage.value!.path,
          filename:
              selectedImage.value!.path.split(Platform.pathSeparator).last,
        );
      }

      // Create FormData for multipart request
      final formData = dio.FormData.fromMap(customerData);

      await dioClient.dio.post(
        '${Apis.baseUrl}${Endpoints.customers}',
        data: formData,
        options: dio.Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      // Refresh customer list after adding
      try {
        Get.find<CustomerController>().fetchCustomers();
      } catch (e) {}

      // Clear form
      fullNameController.clear();
      emailController.clear();
      phoneController.clear();
      // passwordController.clear();
      selectedGender.value = '';
      selectedBranchMembership.value = '';
      selectedPackages.clear();
      packageController.clearAll();
      isActive.value = true;
      showPackageFields.value = false;
      selectedImage.value = null;

      Get.back();
      CustomSnackbar.showSuccess('Success', 'Customer added successfully');
    } catch (e) {
      CustomSnackbar.showError('Error', 'Failed to add customer: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
