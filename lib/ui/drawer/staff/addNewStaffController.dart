import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_template/main.dart';
import 'package:flutter_template/network/network_const.dart';
import 'package:flutter_template/wiget/custome_snackbar.dart';
import 'package:get/get.dart';
import 'package:multi_dropdown/multi_dropdown.dart';
import 'package:flutter_template/ui/drawer/staff/staffDetailsController.dart';
import 'package:dio/dio.dart' as dio;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';

class Service {
  String? id;
  String? name;

  Service({this.id, this.name});

  Service.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    name = json['name'];
  }
}

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

class Commition {
  final String? id;
  final String? name;

  Commition({this.id, this.name});

  factory Commition.fromJson(Map<String, dynamic> json) {
    return Commition(
      id: json['_id'],
      name: json['commission_name'],
    );
  }
}

class Addnewstaffcontroller extends GetxController {
  var fullnameController = TextEditingController();
  var emailController = TextEditingController();
  var phoneController = TextEditingController();
  var shiftStarttimeController = TextEditingController();
  var shiftEndtimeController = TextEditingController();
  var selectedGender = "".obs;
  var specializationController = TextEditingController();
  var durationController = TextEditingController();
  var LunchStarttimeController = TextEditingController();

  var showPass = false.obs;
  var showPass2 = false.obs;

  RxList<Service> serviceList = <Service>[].obs;
  Rx<Service?> selectedService = Rx<Service?>(null);
  RxList<Service> selectedServices = <Service>[].obs;
  final serviceController = MultiSelectController<Service>();
  var branchList = <Branch>[].obs;
  var commitionList = <Commition>[].obs;
  var selectedBranch = Rx<Branch?>(null);
  var selectedCommitionId = Rx<Commition?>(null);

  var isEditMode = false.obs;
  String? editingStaffId;
  Data? _pendingStaffToPopulate;

  void toggleShowPass() {
    showPass.value = !showPass.value;
  }

  void toggleShowPass2() {
    showPass2.value = !showPass2.value;
  }

  void resetForm() {
    fullnameController.clear();
    emailController.clear();
    phoneController.clear();
    shiftStarttimeController.clear();
    shiftEndtimeController.clear();
    specializationController.clear();
    durationController.clear();
    LunchStarttimeController.clear();
    selectedGender.value = "";
    selectedServices.clear();
    selectedBranch.value = null;
    selectedCommitionId.value = null;
    singleImage.value = null;
    isEditMode.value = false;
    editingStaffId = null;
    currentStep.value = 0;

    // Reset service controller when form is reset
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (serviceController.selectedItems.isNotEmpty) {
        serviceController.selectedItems.clear();
      }
    });
  }

  var singleImage = Rxn<dynamic>();

  @override
  void onInit() {
    super.onInit();
    getBranches();
    getCommition();
    getServices();
  }

  @override
  void onClose() {
    fullnameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    shiftStarttimeController.dispose();
    shiftEndtimeController.dispose();
    specializationController.dispose();
    durationController.dispose();
    LunchStarttimeController.dispose();
    serviceController.dispose();
    super.onClose();
  }

  final List<String> dropdownItems = [
    'Male',
    'Female',
    'Other',
  ];

  var currentStep = 0.obs;

  void goToStep(int step) {
    currentStep.value = step;
  }

  void nextStep() {
    if (currentStep.value < 1) {
      currentStep.value++;
    }
  }

  void previousStep() {
    if (currentStep.value > 0) {
      currentStep.value--;
    }
  }

  Future<void> getServices() async {
    final loginUser = await prefs.getUser();
    try {
      final response = await dioClient.getData(
        '${Apis.baseUrl}${Endpoints.getServiceNames}${loginUser!.salonId}',
        (json) => json,
      );

      final data = response['data'] as List;
      serviceList.value = data.map((e) => Service.fromJson(e)).toList();
      _tryPopulatePendingStaff();
    } catch (e) {
      CustomSnackbar.showError('Error', 'Failed to get data: $e');
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
      _tryPopulatePendingStaff();
    } catch (e) {
      CustomSnackbar.showError('Error', 'Failed to get data: $e');
    }
  }

  Future<void> getCommition() async {
    final loginUser = await prefs.getUser();
    try {
      final response = await dioClient.getData(
        '${Apis.baseUrl}${Endpoints.getcommisionForStaff}${loginUser!.salonId}',
        (json) => json,
      );

      final data = response['data'] as List;
      commitionList.value = data.map((e) => Commition.fromJson(e)).toList();
      _tryPopulatePendingStaff();
    } catch (e) {
      CustomSnackbar.showError('Error', 'Failed to get data: $e');
    }
  }

  void _tryPopulatePendingStaff() {
    if (_pendingStaffToPopulate != null &&
        branchList.isNotEmpty &&
        commitionList.isNotEmpty &&
        serviceList.isNotEmpty) {
      // Use a small delay to ensure the UI is ready
      Future.delayed(Duration(milliseconds: 100), () {
        populateFromStaff(_pendingStaffToPopulate!);
        _pendingStaffToPopulate = null;
      });
    }
  }

  void populateFromStaff(Data staff) {
    if (branchList.isEmpty || commitionList.isEmpty || serviceList.isEmpty) {
      _pendingStaffToPopulate = staff;
      return;
    }
    _pendingStaffToPopulate = null;
    fullnameController.text = staff.fullName ?? '';
    specializationController.text = staff.specialization ?? '';
    emailController.text = staff.email ?? '';
    phoneController.text = staff.phoneNumber ?? '';
    selectedGender.value = staff.gender?.capitalizeFirst ?? '';
    shiftStarttimeController.text = staff.assignTime?.startShift ?? '';
    shiftEndtimeController.text = staff.assignTime?.endShift ?? '';
    durationController.text = staff.lunchTime?.duration?.toString() ?? '';
    LunchStarttimeController.text = staff.lunchTime?.timing ?? '';

    // Set selectedBranch (preselect like example)
    if (branchList.isNotEmpty) {
      final branch = branchList.firstWhere(
        (b) => b.id == staff.branchId?.sId,
        orElse: () => branchList.first,
      );
      selectedBranch.value = branch;
    } else {
      selectedBranch.value = null;
    }

    // Set selectedServices
    selectedServices.assignAll(
      serviceList
          .where((s) => staff.serviceId?.any((sid) => sid.sId == s.id) ?? false)
          .toList(),
    );

    // Initialize service controller with selected services
    initializeServiceController();

    if (commitionList.isNotEmpty) {
      final commiison = commitionList.firstWhere(
        (b) => b.id == staff.commissionId?.sId,
        orElse: () => commitionList.first,
      );
      selectedCommitionId.value = commiison;
    } else {
      selectedCommitionId.value = null;
    }
    // Set image
    singleImage.value = staff.image;
  }

  void initializeServiceController() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (serviceList.isNotEmpty && selectedServices.isNotEmpty) {
        print(
            'Initializing services with ${selectedServices.length} selected services');
        print(
            'Selected service IDs: ${selectedServices.map((s) => s.id).toList()}');
        print(
            'Available service IDs: ${serviceList.map((s) => s.id).toList()}');

        // Force refresh the service list to trigger UI update
        serviceList.refresh();

        // Select the services using selectWhere
        serviceController.selectWhere((item) =>
            selectedServices.any((service) => service.id == item.value.id));
      } else if (serviceList.isEmpty) {
        // Listen for serviceList changes
        ever(serviceList, (services) {
          if (services.isNotEmpty && selectedServices.isNotEmpty) {
            print(
                'Service list loaded, initializing with ${selectedServices.length} selected services');
            initializeServiceController();
          }
        });
      }
    });
  }

  Future onUpdateStaffPress() async {
    final loginUser = await prefs.getUser();
    try {
      // Build map with all non-file fields
      Map<String, dynamic> staffData = {
        'full_name': fullnameController.text,
        'email': emailController.text,
        'phone_number': phoneController.text,
        'gender': selectedGender.value.toLowerCase(),
        'branch_id': selectedBranch.value?.id,
        'service_id': selectedServices.map((s) => s.id).toList(),
        'status': 1,
        'specialization': specializationController.text,
        'assigned_commission_id': selectedCommitionId.value?.id,
        'salon_id': loginUser!.salonId,
        'assign_time': {
          'start_shift': shiftStarttimeController.text,
          'end_shift': shiftEndtimeController.text,
        },
        'lunch_time': {
          'duration': int.tryParse(durationController.text) ?? 0,
          'timing': LunchStarttimeController.text,
        },
      };

      // Attach image if selected and it's a File
      if (singleImage.value != null && singleImage.value is File) {
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
        '${Apis.baseUrl}${Endpoints.postStaffDetails}/$editingStaffId',
        data: formData,
        options: dio.Options(headers: {
          'Content-Type': 'multipart/form-data',
        }),
      );
      Get.find<Staffdetailscontroller>().getCustomerDetails();
      Get.back();
      CustomSnackbar.showSuccess('Success', 'Staff updated successfully');
    } catch (e) {
      CustomSnackbar.showError('Error', e.toString());
    }
  }

  Future onAddStaffPress() async {
    final loginUser = await prefs.getUser();
    try {
      // Build map with all non-file fields
      Map<String, dynamic> staffData = {
        'full_name': fullnameController.text,
        'email': emailController.text,
        'phone_number': phoneController.text,
        'gender': selectedGender.value.toLowerCase(),
        'branch_id': selectedBranch.value?.id,
        'service_id': selectedServices.map((s) => s.id).toList(),
        'status': 1,
        'assigned_commission_id': selectedCommitionId.value!.id,
        'salon_id': loginUser!.salonId,
        'specialization': specializationController.text,
        'assign_time': {
          'start_shift': shiftStarttimeController.text,
          'end_shift': shiftEndtimeController.text,
        },
        'lunch_time': {
          'duration': int.tryParse(durationController.text) ?? 0,
          'timing': LunchStarttimeController.text,
        },
      };

      // Attach image if selected
      if (singleImage.value != null && singleImage.value is File) {
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
        '${Apis.baseUrl}${Endpoints.postStaffDetails}',
        data: formData,
        options: dio.Options(headers: {
          'Content-Type': 'multipart/form-data',
        }),
      );
       Get.find<Staffdetailscontroller>().getCustomerDetails();
      Get.back();
      CustomSnackbar.showSuccess('Success', 'Staff added successfully');
    } catch (e) {
      print('==> Add Staff Error: $e');
      CustomSnackbar.showError('Error', e.toString());
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
