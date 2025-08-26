import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:flutter_template/network/model/AddManager.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart' as dio;
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';
import '../../../../main.dart';
import '../../../../network/network_const.dart';
import '../../../../wiget/custome_snackbar.dart';
import '../getManager/getmanagerController.dart';

class Branch {
  final String? id;
  final String? name;

  Branch({this.id, this.name});

  factory Branch.fromJson(Map<String, dynamic> json) {
    return Branch(
      id: json['_id'],
      name: json['name'],
    );
  }
}

class Managercontroller extends GetxController {
  var fullNameController = TextEditingController();
  var lastNameController = TextEditingController();
  var emailController = TextEditingController();
  var contactNumberController = TextEditingController();
  var passwordController = TextEditingController();
  var confirmPasswordController = TextEditingController();
  var selectedGender = "".obs;
  var selectedBranch = Rx<Branch?>(null);
  var branchList = <Branch>[].obs;
  var showPassword = false.obs;
  var showConfirmPassword = false.obs;
  var isLoading = false.obs;

  // Image handling variables
  final Rx<File?> singleImage = Rx<File?>(null);
  final RxString editImageUrl = ''.obs; // For network image in edit mode

  @override
  void onInit() {
    super.onInit();
    getBranches();
  }

  @override
  void onClose() {
    fullNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    contactNumberController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  final List<String> dropdownItems = [
    'Male',
    'Female',
    'Other',
  ];

  void toggleShowPassword() {
    showPassword.value = !showPassword.value;
  }

  void toggleShowConfirmPass() {
    showConfirmPassword.value = !showConfirmPassword.value;
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

  void resetForm() {
    fullNameController.clear();
    lastNameController.clear();
    emailController.clear();
    contactNumberController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    selectedGender.value = "";
    selectedBranch.value = null;
    showPassword.value = false;
    showConfirmPassword.value = false;
    singleImage.value = null;
    editImageUrl.value = '';
  }

  Future onManagerAdd() async {
    if (fullNameController.text.isEmpty) {
      CustomSnackbar.showError('Error', 'Please enter full name');
      return;
    }

    if (emailController.text.isEmpty) {
      CustomSnackbar.showError('Error', 'Please enter email');
      return;
    }

    if (contactNumberController.text.isEmpty) {
      CustomSnackbar.showError('Error', 'Please enter contact number');
      return;
    }

    if (passwordController.text.isEmpty) {
      CustomSnackbar.showError('Error', 'Please enter password');
      return;
    }

    if (selectedBranch.value == null) {
      CustomSnackbar.showError('Error', 'Please select a branch');
      return;
    }

    try {
      final loginUser = await prefs.getUser();
      isLoading.value = true;

      // Prepare form data for multipart request
      Map<String, dynamic> managerData = {
        "full_name": fullNameController.text,
        "email": emailController.text,
        "contact_number": contactNumberController.text,
        "password": passwordController.text,
        "confirm_password": confirmPasswordController.text,
        'gender': selectedGender.value.toLowerCase(),
        "salon_id": loginUser!.salonId,
        'branch_id': selectedBranch.value?.id,
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
        managerData['image'] = await dio.MultipartFile.fromFile(
          singleImage.value!.path,
          filename: singleImage.value!.path.split(Platform.pathSeparator).last,
          contentType: MediaType(mimeParts[0], mimeParts[1]),
        );
      }

      // Create FormData for multipart request
      final formData = dio.FormData.fromMap(managerData);

      await dioClient.dio.post(
        '${Apis.baseUrl}${Endpoints.addManager}',
        data: formData,
        options: dio.Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      final getManagerController = Get.find<Getmanagercontroller>();
      await getManagerController.getManagers();
      resetForm();
      CustomSnackbar.showSuccess('Success', 'Manager Added Successfully');
    } catch (e) {
      print('==> here Error: $e');
      CustomSnackbar.showError('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getBranches() async {
    final loginUser = await prefs.getUser();
    try {
      final response = await dioClient.getData(
        '${Apis.baseUrl}${Endpoints.getBranchName}${loginUser!.salonId}',
        (json) => json,
      );

      final data = response['data'] as List;
      branchList.value = data.map((e) => Branch.fromJson(e)).toList();
    } catch (e) {
      CustomSnackbar.showError('Error', 'Failed to get data: $e');
    }
  }

  Future<void> updateManager(String id) async {
    if (fullNameController.text.isEmpty) {
      CustomSnackbar.showError('Error', 'Please enter full name');
      return;
    }

    if (emailController.text.isEmpty) {
      CustomSnackbar.showError('Error', 'Please enter email');
      return;
    }

    if (contactNumberController.text.isEmpty) {
      CustomSnackbar.showError('Error', 'Please enter contact number');
      return;
    }

    if (selectedBranch.value == null) {
      CustomSnackbar.showError('Error', 'Please select a branch');
      return;
    }

    try {
      final loginUser = await prefs.getUser();
      isLoading.value = true;

      // Prepare form data for multipart request
      Map<String, dynamic> managerData = {
        "full_name": fullNameController.text,
        "email": emailController.text,
        "contact_number": contactNumberController.text,
        'gender': selectedGender.value.toLowerCase(),
        "salon_id": loginUser!.salonId,
        'branch_id': selectedBranch.value?.id,
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
        managerData['image'] = await dio.MultipartFile.fromFile(
          singleImage.value!.path,
          filename: singleImage.value!.path.split(Platform.pathSeparator).last,
          contentType: MediaType(mimeParts[0], mimeParts[1]),
        );
      }

      // Create FormData for multipart request
      final formData = dio.FormData.fromMap(managerData);

      await dioClient.dio.put(
        '${Apis.baseUrl}${Endpoints.addManager}/$id?salon_id=${loginUser!.salonId}',
        data: formData,
        options: dio.Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      final getManagerController = Get.find<Getmanagercontroller>();
      await getManagerController.getManagers();
      resetForm();
      CustomSnackbar.showSuccess('Success', 'Manager updated successfully');
    } catch (e) {
      print('==> here Error: $e');
      CustomSnackbar.showError('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
