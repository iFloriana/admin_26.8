import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_template/main.dart';
import 'package:flutter_template/network/model/getAdminDetails.dart';
import 'package:flutter_template/network/network_const.dart';
import 'package:http_parser/http_parser.dart';
import 'package:flutter_template/wiget/custome_snackbar.dart';
import 'package:get/get.dart' hide MultipartFile, FormData;
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';

class Adminprofilecontroller extends GetxController {
  var fullnameController = TextEditingController();
  var salonNameController = TextEditingController();
  var addressController = TextEditingController();
  var emailController = TextEditingController();
  var phoneController = TextEditingController();
  var gst = TextEditingController();
  var passwordController = TextEditingController();
  var oldPasswordController = TextEditingController();
  var confirmPasswordController = TextEditingController();
  final Rx<File?> singleImage = Rx<File?>(null);
  final RxString editImageUrl = ''.obs;
  var showPassword = false.obs;
  var showOldPassword = false.obs;
  var showConfirmPassword = false.obs;
  var pincodeController = TextEditingController();
  var country = ''.obs;
  var state = ''.obs;
  var district = ''.obs;
  var block = ''.obs;
  var isLoading = false.obs;
  var error = ''.obs;
  var salonImageUrl = ''.obs;
  var isExpanded_Details = false.obs;
  var isExpanded_pass = false.obs;
  var isExpanded_packages = false.obs; // New variable for package section
  final Rx<GetAdminDetails?> profileDetails =
      Rx<GetAdminDetails?>(null); // Store profile details


  void toggleShowPassword() {
    showPassword.value = !showPassword.value;
  }

  void toggleShowConfirmPass() {
    showConfirmPassword.value = !showConfirmPassword.value;
  }

  void toggleShowOldPass() {
    showOldPassword.value = !showOldPassword.value;
  }

  void expand_details() {
    isExpanded_Details.value = !isExpanded_Details.value;
  }

  void expand_pass() {
    isExpanded_pass.value = !isExpanded_pass.value;
  }

  void expand_packages() {
    isExpanded_packages.value = !isExpanded_packages.value;
  }

  @override
  void onInit() {
    super.onInit();
    getProfileData();
  }

  void clearImage() {
    singleImage.value = null;
    editImageUrl.value = '';
    salonImageUrl.value = '';
  }

  String? _getMimeType(String path) {
    final ext = path.toLowerCase();
    if (ext.endsWith('.jpg') || ext.endsWith('.jpeg')) {
      return 'image/jpeg';
    } else if (ext.endsWith('.png')) {
      return 'image/png';
    } else if (ext.endsWith('.heic') || ext.endsWith('.heif')) {
      return 'image/heic';
    }
    return null;
  }

  Future<void> pickImageFromGallery() async {
    final picker = ImagePicker();
    final pickedFile =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    editImageUrl.value = '';
    await _handlePickedFile(pickedFile, isFromCamera: false);
  }

  Future<void> pickImageFromCamera() async {
    final picker = ImagePicker();
    final pickedFile =
        await picker.pickImage(source: ImageSource.camera, imageQuality: 85);
    editImageUrl.value = '';
    await _handlePickedFile(pickedFile, isFromCamera: true);
  }

  Future<void> _handlePickedFile(XFile? pickedFile,
      {required bool isFromCamera}) async {
    const maxSizeInBytes = 150 * 1024; // 150 KB
    if (pickedFile == null) {
      CustomSnackbar.showError('Error', 'No image selected');
      return;
    }

    final file = File(pickedFile.path);
    final mimeType = _getMimeType(pickedFile.path) ?? pickedFile.mimeType;

    File? processedFile;
    try {
      if (isFromCamera ||
          mimeType == 'image/heic' ||
          mimeType == 'image/heif') {
        // Convert camera images (or HEIC/HEIF) to JPEG
        final bytes = await file.readAsBytes();
        final image = img.decodeImage(bytes);
        if (image == null) {
          CustomSnackbar.showError('Error', 'Failed to process image');
          return;
        }

        // Encode to JPEG with quality control
        final jpegBytes = img.encodeJpg(image, quality: 85);

        // Save to a temporary file with .jpg extension
        final tempDir = await getTemporaryDirectory();
        final tempPath =
            '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
        processedFile = File(tempPath)..writeAsBytesSync(jpegBytes);
      } else if (mimeType == 'image/jpeg' ||
          mimeType == 'image/jpg' ||
          mimeType == 'image/png') {
        processedFile = file; // Use original file for valid formats
      } else {
        CustomSnackbar.showError(
            'Invalid Image', 'Only JPG, JPEG, PNG images are allowed!');
        return;
      }

      if (processedFile != null &&
          await processedFile.length() <= maxSizeInBytes) {
        singleImage.value = processedFile;
      } else {
        CustomSnackbar.showError('Error', 'Image size must be less than 150KB');
      }
    } catch (e) {
      CustomSnackbar.showError('Error', 'Failed to process image: $e');
    }
  }

  void getProfileData() async {
    final profileDetails = await prefs.getRegisterdetails();
    this.profileDetails.value =
        profileDetails; // Store the full profile details
    fullnameController.text = profileDetails?.admin?.fullName ?? '';
    salonNameController.text = profileDetails?.salonDetails?.salonName ?? '';
    addressController.text = profileDetails?.admin?.address ?? '';
    emailController.text = profileDetails?.admin?.email ?? '';
    phoneController.text = profileDetails?.admin?.phoneNumber ?? '';
    gst.text = profileDetails?.salonDetails?.gstNumber ?? '';
    if (profileDetails?.salonDetails?.imageUrl != null) {
      salonImageUrl.value = profileDetails!.salonDetails!.imageUrl!;
    }
  }

  Future onProdileUpdate() async {
    final loginUser = await prefs.getUser();
    final url = '${Apis.baseUrl}/auth/update-admin/${loginUser?.adminId}';

    try {
      isLoading.value = true;
      if (singleImage.value != null) {
        // Ensure the file has a .jpg or .png extension
        String fileName = singleImage.value!.path.split('/').last;
        if (!fileName.endsWith('.jpg') && !fileName.endsWith('.png')) {
          final tempDir = await getTemporaryDirectory();
          fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
          final newPath = '${tempDir.path}/$fileName';
          await singleImage.value!.copy(newPath);
          singleImage.value = File(newPath);
        }

        final fileExtension = fileName.split('.').last.toLowerCase();
        final imageMultipart = await MultipartFile.fromFile(
          singleImage.value!.path,
          filename: fileName,
          contentType:
              MediaType('image', fileExtension == 'png' ? 'png' : 'jpeg'),
        );

        final formData = FormData.fromMap({
          'full_name': fullnameController.text,
          'phone_number': phoneController.text,
          'email': emailController.text,
          'address': addressController.text,
          'salonDetails[salon_name]': salonNameController.text,
          'salonDetails[gst_number]': gst.text,
          'image': imageMultipart,
        });

        await dioClient.dio.put(
          url,
          data: formData,
          options: Options(
            contentType: "multipart/form-data",
          ),
        );
      } else {
        final data = {
          'full_name': fullnameController.text,
          'phone_number': phoneController.text,
          'email': emailController.text,
          'address': addressController.text,
          'salonDetails': {
            'salon_name': salonNameController.text,
            'gst_number': gst.text,
          },
        };

        await dioClient.putData(
          url,
          data,
          (json) => json,
        );
      }

      await prefs.onLogout();
      CustomSnackbar.showSuccess('Success', 'Profile updated successfully');
    } catch (e) {
      CustomSnackbar.showError('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future onChangePAssword() async {
    final loginUser = await prefs.getUser();
    Map<String, dynamic> changeData = {
      'email': loginUser!.email,
      'old_password': oldPasswordController.text,
      'new_password': passwordController.text,
      'confirm_password': confirmPasswordController.text,
    };

    try {
      isLoading.value = true;
      await dioClient.postData(
        '${Apis.baseUrl}${Endpoints.resetPass}',
        changeData,
        (json) => json,
      );

      CustomSnackbar.showSuccess('Success', 'Password updated successfully');
      await prefs.onLogout();
    } catch (e) {
      CustomSnackbar.showError('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  jsonDecode(Map<String, dynamic> response) {}
}
