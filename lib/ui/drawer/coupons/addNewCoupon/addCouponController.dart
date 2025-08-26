import 'package:flutter/material.dart';
import 'package:flutter_template/main.dart';

import 'package:flutter_template/network/model/coupon_model.dart';
import 'package:flutter_template/network/network_const.dart';
import 'package:flutter_template/ui/drawer/coupons/couponsController.dart';
import 'package:flutter_template/wiget/custome_snackbar.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';
import 'package:dio/dio.dart' as dio;
import 'package:multi_dropdown/multi_dropdown.dart';

class Addcouponcontroller extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _initialize();
  }

  void _initialize() async {
    // Check if we're in edit mode
    final coupon = Get.arguments as Data?;
    if (coupon != null) {
      isEditMode.value = true;
      editingCouponId.value = coupon.sId;
    } else {
      singleImage.value = null;
      editImageUrl.value = '';
    }

    await getBranches();
  }

  void populateFormForUpdate(Data coupon) {
    // Pre-fill the form
    nameController.text = coupon.name ?? '';
    descriptionController.text = coupon.description ?? '';
    coponCodeController.text = coupon.couponCode ?? '';
    discountAmtController.text = coupon.discountAmount?.toString() ?? '';
    userLimitController.text = coupon.useLimit?.toString() ?? '';
    selectedCouponType.value = coupon.couponType?.capitalize ?? 'Custom';
    selectedDiscountType.value = coupon.discountType?.capitalize ?? 'Percent';
    isActive.value = coupon.status == 1;

    if (coupon.branchId!.isNotEmpty) {
      final branches = branchList
          .where((b) => coupon.branchId!.any((branch) => branch.sId == b.id))
          .toList();
      selectedBranches.value = branches;
      // Initialize branch controller with selected branches
      WidgetsBinding.instance.addPostFrameCallback((_) {
        branchController.selectWhere((item) =>  
            selectedBranches.any((branch) => branch.id == item.value.id));
      });
    }
    // Pre-fill image
    singleImage.value = null;
    editImageUrl.value = coupon.imageUrl ?? '';

    // Format dates to YYYY-MM-DD
    if (coupon.startDate != null) {
      final startDate = DateTime.parse(coupon.startDate!);
      StarttimeController.text =
          "${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}";
    }
    if (coupon.endDate != null) {
      final endDate = DateTime.parse(coupon.endDate!);
      EndtimeController.text =
          "${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}";
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    descriptionController.dispose();
    coponCodeController.dispose();
    discountAmtController.dispose();
    userLimitController.dispose();
    StarttimeController.dispose();
    EndtimeController.dispose();
    branchController.dispose();
    super.onClose();
  }

  var isEditMode = false.obs;
  var editingCouponId = RxnString();

  var nameController = TextEditingController();
  var descriptionController = TextEditingController();
  var coponCodeController = TextEditingController();
  var discountAmtController = TextEditingController();
  var userLimitController = TextEditingController();
  var isActive = true.obs;
  var selectedCouponType = "".obs;
  var couponList = <CouponModel>[].obs;
  var StarttimeController = TextEditingController();
  var EndtimeController = TextEditingController();
  var branchList = <Branch>[].obs;
  var selectedBranches = <Branch>[].obs;
  final branchController = MultiSelectController<Branch>();

  var selectedDiscountType = "".obs;
  final List<String> dropdownCouponTypeItem = [
    'Custom',
    'Bulk',
    'Seasonal',
    'Event'
  ];

  final List<String> dropdownDiscountTypeItem = ['Percent', 'Fixed'];

  final Rx<File?> singleImage = Rx<File?>(null);
  final RxString editImageUrl = ''.obs;

  // String? _originalImageUrl;

  Future<void> getBranches() async {
    final loginUser = await prefs.getUser();
    try {
      print('Fetching branches for salon: ${loginUser!.salonId}');
      final response = await dioClient.getData(
        '${Apis.baseUrl}${Endpoints.getBranchName}${loginUser.salonId}',
        (json) => json,
      );

      print('Coupon getBranches response: $response');
      final data = response['data'] as List;
      branchList.value = data.map((e) => Branch.fromJson(e)).toList();
      print('Coupon branchList length: ${branchList.length}');
      print(
          'Coupon branchList: ${branchList.map((b) => '${b.name} (${b.id})').toList()}');

      // Populate the branch controller with available branches
      branchController.setItems(branchList.value
          .map((branch) => DropdownItem(
                label: branch.name ?? 'Unknown',
                value: branch,
              ))
          .toList());
      print('Branch controller items set: ${branchController.items.length}');

      // Check if we need to populate form for edit mode
      final coupon = Get.arguments as Data?;
      if (coupon != null && coupon.branchId != null) {
        print('Branches loaded, now populating form for edit mode');
        populateFormForUpdate(coupon);
      }
    } catch (e) {
      print('Coupon getBranches error: $e');
      CustomSnackbar.showError('Error', 'Failed to get data: $e');
    }
  }

  Future<void> pickImageFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      // Clear the existing image URL only when a new image is actually selected
      editImageUrl.value = '';
      print('New image selected from gallery, clearing editImageUrl');
    }
    await _handlePickedFile(pickedFile);
  }

  Future<void> pickImageFromCamera() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      // Clear the existing image URL only when a new image is actually selected
      editImageUrl.value = '';
    }
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
        print('Image file accepted: ${file.path}');
      } else {
        CustomSnackbar.showError('Error', 'Image size must be less than 150KB');
      }
    }
  }

  void resetForm() {
    nameController.clear();
    descriptionController.clear();
    coponCodeController.clear();
    discountAmtController.clear();
    userLimitController.clear();
    StarttimeController.clear();
    EndtimeController.clear();
    isActive.value = true;
    selectedCouponType.value = '';
    selectedDiscountType.value = '';
    selectedBranches.clear();
    singleImage.value = null;
    editImageUrl.value = '';

    print('Form reset - Image state cleared');
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

  Future onCoupons() async {
    final loginUser = await prefs.getUser();

    Map<String, dynamic> couponData = {
      "name": nameController.text,
      "description": descriptionController.text,
      "start_date": StarttimeController.text,
      "end_date": EndtimeController.text,
      "coupon_type": selectedCouponType.value.toLowerCase(),
      "coupon_code": coponCodeController.text,
      "discount_type": selectedDiscountType.value.toLowerCase(),
      "discount_amount": discountAmtController.text,
      "use_limit": userLimitController.text,
      'status': isActive.value ? 1 : 0,
      'salon_id': loginUser!.salonId,
      "branch_id": selectedBranches.map((e) => e.id).toList(),
    };

    try {
      dio.FormData? formData;

      // IMAGE HANDLING
      if (singleImage.value != null) {
        // New image selected
        final mimeType = _getMimeType(singleImage.value!.path);
        if (mimeType == null) {
          CustomSnackbar.showError(
              'Invalid Image', 'Only JPG, JPEG, PNG images are allowed!');
          return;
        }
        final mimeParts = mimeType.split('/');
        couponData['image'] = await dio.MultipartFile.fromFile(
          singleImage.value!.path,
          filename: singleImage.value!.path.split(Platform.pathSeparator).last,
          contentType: MediaType(mimeParts[0], mimeParts[1]),
        );
      } else {
        if (!isEditMode.value) {
          // ADD MODE → image is required
          CustomSnackbar.showError('Error', 'Image is required for new coupon');
          return;
        }
        // EDIT MODE → if no new image, don't send image field at all
      }

      formData = dio.FormData.fromMap(couponData);

      if (isEditMode.value && editingCouponId.value != null) {
        // UPDATE COUPON
        await dioClient.dio.put(
          '${Apis.baseUrl}${Endpoints.coupons}/${editingCouponId.value}?salon_id=${loginUser!.salonId}',
          data: formData,
          options:
              dio.Options(headers: {'Content-Type': 'multipart/form-data'}),
        );
        Get.back();
      } else {
        // ADD COUPON
        await dioClient.dio.post(
          '${Apis.baseUrl}${Endpoints.coupons}',
          data: formData,
          options:
              dio.Options(headers: {'Content-Type': 'multipart/form-data'}),
        );
        Get.back();
      }

      var updateList = Get.put(CouponsController());
      await updateList.getCoupons();
    } catch (e) {
      CustomSnackbar.showError('Error', e.toString());
    }
  }
}
