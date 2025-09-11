import 'package:flutter/material.dart';
import 'package:flutter_template/manager_ui/manager_appointment/manager_appointmentController.dart';
import 'package:get/get.dart';
import '../../../../main.dart';
import '../../../../network/network_const.dart';
import '../../../../wiget/custome_snackbar.dart';
class BranchModel {
  final String id;
  final String name;
  final String category;
  final int status;
  final String contactEmail;
  final String contactNumber;
  final List<String> paymentMethod;
  final List<ServiceModel> services;
  final String address;
  final String landmark;
  final String country;
  final String state;
  final String city;
  final String postalCode;
  final String description;
  final String? image;
  final double ratingStar;
  final int totalReview;

  BranchModel({
    required this.id,
    required this.name,
    required this.category,
    required this.status,
    required this.contactEmail,
    required this.contactNumber,
    required this.paymentMethod,
    required this.services,
    required this.address,
    required this.landmark,
    required this.country,
    required this.state,
    required this.city,
    required this.postalCode,
    required this.description,
    required this.image,
    required this.ratingStar,
    required this.totalReview,
  });

  factory BranchModel.fromJson(Map<String, dynamic> json) {
    String _toString(dynamic v) => v == null
        ? ''
        : (v is String)
            ? v
            : v.toString();
    int _toInt(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      if (v is double) return v.toInt();
      if (v is String) return int.tryParse(v) ?? 0;
      return 0;
    }

    double _toDouble(dynamic v) {
      if (v == null) return 0;
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v) ?? 0;
      return 0;
    }

    // Image may arrive as String or Map; extract a URL-like string if present
    String? _parseImage(dynamic v) {
      if (v == null) return null;
      if (v is String && v.isNotEmpty) return v;
      if (v is Map) {
        final keys = ['url', 'path', 'file'];
        for (final k in keys) {
          final val = v[k];
          if (val is String && val.isNotEmpty) return val;
        }
      }
      return null;
    }

    // Services may be a list of service objects or a list of wrapper objects
    final dynamicServices = (json['service_id'] as List?) ?? [];
    final parsedServices = dynamicServices
        .map((e) {
          if (e is Map) {
            final inner = e['service'] is Map ? e['service'] : e;
            if (inner is Map<String, dynamic>) {
              return ServiceModel.fromJson(inner);
            }
          }
          return null;
        })
        .whereType<ServiceModel>()
        .toList();

    // Payment methods as strings regardless of underlying type
    final methods = ((json['payment_method'] as List?) ?? [])
        .map((m) => _toString(m))
        .where((s) => s.isNotEmpty)
        .toList();

    return BranchModel(
      id: _toString(json['_id']),
      name: _toString(json['name']),
      category: json['category'] is Map
          ? _toString(json['category']['name'] ?? json['category']['_id'])
          : _toString(json['category']),
      status: _toInt(json['status']),
      contactEmail: _toString(json['contact_email']),
      contactNumber: _toString(json['contact_number']),
      paymentMethod: methods,
      services: parsedServices,
      address: _toString(json['address']),
      landmark: _toString(json['landmark']),
      country: _toString(json['country']),
      state: _toString(json['state']),
      city: _toString(json['city']),
      postalCode: _toString(json['postal_code']),
      description: _toString(json['description']),
      image: _parseImage(json['image_url']),
      ratingStar: _toDouble(json['rating_star']),
      totalReview: _toInt(json['total_review']),
    );
  }
}

class ServiceModel {
  final String id;
  final String name;
  final int serviceDuration;
  final double regularPrice;
  final String? image;

  ServiceModel({
    required this.id,
    required this.name,
    required this.serviceDuration,
    required this.regularPrice,
    this.image,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    int _toInt(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      if (v is double) return v.toInt();
      if (v is String) return int.tryParse(v) ?? 0;
      return 0;
    }

    double _toDouble(dynamic v) {
      if (v == null) return 0;
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v) ?? 0;
      return 0;
    }

    String? _parseImage(dynamic v) {
      if (v == null) return null;
      if (v is String && v.isNotEmpty) return v;
      if (v is Map) {
        final keys = ['url', 'path', 'file'];
        for (final k in keys) {
          final val = v[k];
          if (val is String && val.isNotEmpty) return val;
        }
      }
      return null;
    }

    return ServiceModel(
      id: (json['_id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      serviceDuration: _toInt(json['service_duration']),
      regularPrice: _toDouble(json['regular_price']),
      image: _parseImage(json['image']),
    );
  }
}

class StaffModel {
  final String id;
  final String fullName;
  final String? imageUrl;
  final String branchId;
  final List<String> serviceIds;

  StaffModel({
    required this.id,
    required this.fullName,
    this.imageUrl,
    required this.branchId,
    required this.serviceIds,
  });

  factory StaffModel.fromJson(Map<String, dynamic> json) {
    return StaffModel(
      id: json['_id'] ?? '',
      fullName: json['full_name'] ?? '',
      imageUrl: json['image_url'],
      branchId: json['branch_id'] is String
          ? json['branch_id']
          : (json['branch_id']?['_id'] ?? ''),
      serviceIds: (json['service_id'] as List?)
              ?.map((e) {
                if (e is String) return e;
                if (e is Map && e['_id'] != null) return e['_id'] as String;
                return '';
              })
              .where((id) => id.isNotEmpty)
              .toList() ??
          [],
    );
  }
}

class ManagerNewappointmentcontroller extends GetxController {
  var currentStep = 0.obs;
  
  var branches = <BranchModel>[].obs;
  var selectedBranch = Rxn<BranchModel>();
  var fullNameController = TextEditingController();
  var emailController = TextEditingController();
  var phoneController = TextEditingController();
  var services = <ServiceModel>[].obs;
  var selectedService = Rxn<ServiceModel>();
  final List<String> genderOptions = ['Male', 'Female', 'Other'];
  var selectedGender = ''.obs;
  var staff = <StaffModel>[].obs;
  var selectedStaff = Rxn<StaffModel>();

  var availableSlots = <String>[].obs;
  var selectedDate = Rxn<DateTime>();
  var isBookingLoading = false.obs;

  Future<void> fetchServicesForBranch() async {
    try {
      final loginUser = await prefs.getManagerUser();
      var response = await dioClient.getData(
        '${Apis.baseUrl}/services?salon_id=${loginUser!.manager!.salonId}',
        (json) => json,
      );
      final serviceData = response['data'] as List;
      services.value =
          serviceData.map((e) => ServiceModel.fromJson(e)).toList();
    } catch (e) {
      CustomSnackbar.showError('Error', 'Failed to get services: $e');
    }
  }

  Future<void> fetchStaffsForBranch() async {
    try {
      final loginUser = await prefs.getManagerUser();
      var response = await dioClient.getData(
        '${Apis.baseUrl}/staffs/by-branch?salon_id=${loginUser?.manager?.salonId}&branch_id=${loginUser?.manager?.branchId?.sId}',
        (json) => json,
      );
      final staffData = response['data'] as List;
      staff.value = staffData.map((e) => StaffModel.fromJson(e)).toList();
    } catch (e) {
      CustomSnackbar.showError('Error', 'Failed to get staff: $e');
    }
  }

  void selectBranch(BranchModel branch) async {
        final loginUser = await prefs.getManagerUser();
     selectedBranch.value = branches.firstWhereOrNull((b) => b.id == loginUser?.manager?.branchId?.sId) ;
    await fetchServicesForBranch(); // Changed to branch.id
    nextStep(); // Move to next step after selection
  }

  void goToStep(int step) {
    currentStep.value = step;
  }

  void nextStep() {
    if (currentStep.value < 4) {
      currentStep.value++;

      if (currentStep.value == 2) {
        selectedDate.value = DateTime.now();
        fetchAvailableSlots();
      }
    }
  }

  void previousStep() {
    if (currentStep.value > 0) {
      currentStep.value--;
    }
  }

  @override
  void onInit() {
    super.onInit();
    getBranches();
  }

  Future<void> getBranches() async {
    try {
      final loginUser = await prefs.getManagerUser();
      var response = await dioClient.getData(
        '${Apis.baseUrl}/branches?salon_id=${loginUser!.manager!.salonId}',
        (json) => json,
      );
      final branchData = response['data'] as List;
      List<BranchModel> branchList =
          branchData.map((e) => BranchModel.fromJson(e)).toList();
      branches.value = branchList;
    } catch (e) {
      CustomSnackbar.showError('Error', 'Failed to get branches: $e');
    }
  }

  Future<void> fetchAvailableSlots() async {
     final loginUser = await prefs.getManagerUser();
    final branch = loginUser?.manager?.branchId;
    final staff = selectedStaff.value;
    final date = selectedDate.value;
    if (branch == null || staff == null || date == null) return;
    try {
     
      final dateStr =
          "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
      var response = await dioClient.getData(
        '${Apis.baseUrl}/quick-booking/available-slots?salon_id=${loginUser!.manager!.salonId}&date=$dateStr&staff_id=${staff.id}',
        (json) => json,
      );
      availableSlots.value =
          List<String>.from(response['availableSlots'] ?? []);
    } catch (e) {
      CustomSnackbar.showError('Error', 'Failed to get available slots: $e');
    }
  }

  Future<List<StaffModel>> get filteredStaff async {
    final manager = await prefs.getManagerUser();
    final branch = manager!.manager!.branchId!.sId;
    final service = selectedService.value;
    if (branch == null || service == null) return [];
    return staff
        .where((s) => s.branchId == branch && s.serviceIds.contains(service.id))
        .toList();
  }

  Future<void> addBooking() async {
    final loginUser = await prefs.getManagerUser();
    final branch = loginUser?.manager?.branchId;
    final service = selectedService.value;
    final staff = selectedStaff.value;
    final date = selectedDate.value;
    final time = selectedSlot.value;
    if (loginUser == null ||
        branch == null ||
        service == null ||
        staff == null ||
        date == null ||
        time == null) {
      CustomSnackbar.showError('Error', 'Please fill all booking details.');
      return;
    }
    isBookingLoading.value = true;
    try {
      final body = {
        "salon_id": loginUser.manager!.salonId,
        "branch_id": branch.sId,
        "service_id": [service.id],
        "staff_id": [staff.id],
        "date":
            "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}",
        "time": time,
        "customer_details": {
          "full_name": fullNameController.text,
          "email": emailController.text,
          "phone_number": phoneController.text,
          "gender": selectedGender.value.toLowerCase(),
        },
        "payment_status": "Pending"
      };
      await dioClient.postData(
        '${Apis.baseUrl}/quick-booking',
        body,
        (json) => json,
      );
      isBookingLoading.value = false;
      // Go to confirmation step
     currentStep.value = 4;
      Get.back();
      Get.put(ManagerAppointmentcontroller()).getAppointment();
    } catch (e) {
      isBookingLoading.value = false;
      CustomSnackbar.showError('Error', 'Failed to add booking: $e');
    }
  }

  var selectedSlot = RxnString();

  bool canProceedToNextStep() {
    switch (currentStep.value) {
      case 0:
        return selectedService.value != null;
      case 1:
        return selectedStaff.value != null;
      case 2:
        return selectedDate.value != null && selectedSlot.value != null;
      case 3:
        return fullNameController.text.isNotEmpty &&
            emailController.text.isNotEmpty &&
            phoneController.text.isNotEmpty &&
            selectedGender.value.isNotEmpty;
      default:
        return true;
    }
  }

  String getValidationMessage() {
    switch (currentStep.value) {
      // case 0:
      //   return "Please select a branch to continue";
      case 0:
        return "Please select a service to continue";
      case 1:
        return "Please select a staff member to continue";
      case 2:
        if (selectedDate.value == null) {
          return "Please select a date to continue";
        } else if (selectedSlot.value == null) {
          return "Please select a time slot to continue";
        }
        return "Please select date and time to continue";
      case 3:
        if (fullNameController.text.isEmpty) {
          return "Please enter full name";
        } else if (emailController.text.isEmpty) {
          return "Please enter email address";
        } else if (phoneController.text.isEmpty) {
          return "Please enter phone number";
        }
        return "Please fill all customer details";
      default:
        return "Please complete the current step";
    }
  }
}
