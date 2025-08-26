import 'package:flutter_template/main.dart';
import 'package:flutter_template/manager_ui/customer/add/manager_post_customer_controller.dart';
import 'package:flutter_template/network/network_const.dart';
import 'package:flutter_template/wiget/custome_snackbar.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:multi_dropdown/multi_dropdown.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart' as dio;
import 'dart:io';
import '../../../commen_items/commen_class.dart';

class Customer {
  final String id;
  final String fullName;
  final String phoneNumber;
  final String email;
  final String gender;
  final List<String> branchPackage;
  final String branchMembership;
  final int status;
  final String branchMembershipId;
  final Map<String, dynamic>? branchMembershipObj;
  final String? image; // Add image field

  Customer({
    required this.id,
    required this.fullName,
    required this.phoneNumber,
    required this.email,
    required this.gender,
    this.branchPackage = const [],
    this.branchMembership = '',
    this.status = 1,
    this.branchMembershipId = '',
    this.branchMembershipObj,
    this.image, // Add image parameter
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['_id'] ?? '',
      fullName: json['full_name'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      email: json['email'] ?? '',
      gender: json['gender'] ?? '',
      branchPackage: (json['branch_package'] as List?)
              ?.map((e) => e is Map ? e['_id']?.toString() ?? '' : e.toString())
              .toList() ??
          [],
      branchMembership: json['branch_membership'] is Map
          ? json['branch_membership']['_id']?.toString() ?? ''
          : json['branch_membership']?.toString() ?? '',
      status: json['status'] is int
          ? json['status']
          : int.tryParse(json['status']?.toString() ?? '1') ?? 1,
      branchMembershipId: json['branchMembership_id']?.toString() ?? '',
      branchMembershipObj: json['branch_membership'] is Map<String, dynamic>
          ? json['branch_membership'] as Map<String, dynamic>
          : null,
      image: json['image_url'], // Parse image field
    );
  }
}

class ManagerGetStaffController extends GetxController {
  var isLoading = false.obs;

  // Add these for add/edit flows
  var fullNameController = TextEditingController();
  var emailController = TextEditingController();
  var phoneController = TextEditingController();
  var selectedGender = 'Male'.obs;
  var isActive = true.obs;
  final List<String> genderOptions = ['Male', 'Female', 'Other'];

  // Package/Membership support
  var showPackageFields = false.obs;
  final packageController = MultiSelectController<BranchPackage>();
  var selectedPackages = <BranchPackage>[].obs;
  var selectedBranchMembership = ''.obs;
  var branchPackageList = <BranchPackage>[].obs;
  var branchMembershipList = <dynamic>[].obs;

  // Image picker
  static const int maxImageSizeInBytes = 150 * 1024; // 150 KB
  static const List<String> allowedExtensions = ['.jpg', '.jpeg', '.png'];

  bool _isAllowedImageExtension(String path) {
    final ext = path.toLowerCase();
    return allowedExtensions.any((e) => ext.endsWith(e));
  }

  Future<void> _handlePickedFile(XFile? pickedFile) async {
    if (pickedFile != null) {
      final file = File(pickedFile.path);
      if (!_isAllowedImageExtension(pickedFile.path)) {
        CustomSnackbar.showError(
            'Invalid Image', 'Only JPG, JPEG, PNG images are allowed!');
        return;
      }
      if (await file.length() > maxImageSizeInBytes) {
        CustomSnackbar.showError('Error', 'Image size must be less than 150KB');
        return;
      }
      selectedImage.value = file;
    }
  }

  final ImagePicker _picker = ImagePicker();
  var selectedImage = Rx<File?>(null);
  var existingImageUrl = Rx<String?>(null);

  final Rx<File?> singleImage = Rx<File?>(null);
  final RxString editImageUrl = ''.obs;

  RxList<Customer> customerList = <Customer>[].obs;

  // Flags to track loading
  var packagesLoaded = false.obs;
  var membershipsLoaded = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCustomers();
    getBranchPackages();
    getBranchMemberships();
  }

  // Image picker methods
  Future<void> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 50,
      );
      await _handlePickedFile(image);
    } catch (e) {
      CustomSnackbar.showError(
          'Error', 'Failed to pick image from gallery: $e');
    }
  }

  Future<void> pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 50,
      );
      await _handlePickedFile(image);
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

  Future<void> fetchCustomers() async {
    try {
      final loginUser = await prefs.getManagerUser();

      final Map<String, dynamic> response = await dioClient.getData(
        '${Apis.baseUrl}${Endpoints.getCustomersDetails}?salon_id=${loginUser?.manager?.salonId}',
        (json) => json as Map<String, dynamic>,
      );

      final List<dynamic> data = response['data'];
      customerList.value = data.map((e) => Customer.fromJson(e)).toList();
    } catch (e) {
      CustomSnackbar.showError('Error', 'Failed to fetch customers: $e');
    }
  }

  Future<void> deleteCustomer(String customerId) async {
    try {
      final loginUser = await prefs.getManagerUser();
      isLoading.value = true;
      final response = await dioClient.deleteData(
        '${Apis.baseUrl}${Endpoints.customers}/$customerId?salon_id=${loginUser?.manager?.salonId}',
        (json) => json,
      );

      if (response != null) {
        customerList.removeWhere((customer) => customer.id == customerId);
        CustomSnackbar.showSuccess('Success', 'Customer deleted successfully');
        await fetchCustomers();
      }
    } catch (e) {
      CustomSnackbar.showError('Error', 'Failed to delete customer: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateCustomer(String customerId) async {
    try {
      final loginUser = await prefs.getManagerUser();
      isLoading.value = true;

      // Prepare form data for multipart request
      Map<String, dynamic> customerData = {
        'full_name': fullNameController.text,
        'email': emailController.text,
        'phone_number': phoneController.text,
        'gender': selectedGender.value.toLowerCase(),
        'status': isActive.value ? 1 : 0,
        'salon_id': loginUser != null ? loginUser?.manager?.salonId : null
      };

      if (showPackageFields.value) {
        customerData['branch_package'] =
            selectedPackages.map((p) => p.id).toList();
        if (selectedBranchMembership.value.isNotEmpty) {
          customerData['branch_membership'] = selectedBranchMembership.value;
        }
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

      await dioClient.dio.put(
        '${Apis.baseUrl}${Endpoints.customers}/$customerId?salon_id=${loginUser?.manager?.salonId}',
        data: formData,
        options: dio.Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      // Update in list
      int index = customerList.indexWhere((c) => c.id == customerId);
      if (index != -1) {
        customerList[index] = Customer(
          id: customerId,
          fullName: fullNameController.text,
          phoneNumber: phoneController.text,
          email: emailController.text,
          gender: selectedGender.value,
          image: selectedImage.value != null
              ? selectedImage.value!.path
              : existingImageUrl.value,
        );
        customerList.refresh();
      }

      // Clear image selection
      selectedImage.value = null;
      existingImageUrl.value = null;

      Get.back();
      CustomSnackbar.showSuccess('Success', 'Customer updated successfully');
      await fetchCustomers();
    } catch (e) {
      CustomSnackbar.showError('Error', 'Failed to update customer: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getBranchPackages() async {
    try {
      final loginUser = await prefs.getManagerUser();
      final response = await dioClient.getData(
        '${Apis.baseUrl}${Endpoints.getBranchpackagesNames}${loginUser?.manager?.salonId}',
        (json) => json,
      );
      final data = response['data'] as List;
      branchPackageList.value =
          data.map((e) => BranchPackage.fromJson(e)).toList();
      packagesLoaded.value = true;
    } catch (e) {
      CustomSnackbar.showError('Error', 'Failed to get branch packages: $e');
      packagesLoaded.value = true;
    }
  }

  Future<void> getBranchMemberships() async {
    try {
      final loginUser = await prefs.getManagerUser();
      final response = await dioClient.getData(
        '${Apis.baseUrl}${Endpoints.getBranchMembershipNames}?salon_id=${loginUser?.manager?.salonId}',
        (json) => json,
      );
      final data = response['data'] as List;
      branchMembershipList.value =
          data.map((e) => BranchMembership.fromJson(e)).toList();
      membershipsLoaded.value = true;
    } catch (e) {
      CustomSnackbar.showError('Error', 'Failed to get branch memberships: $e');
      membershipsLoaded.value = true;
    }
  }
}
