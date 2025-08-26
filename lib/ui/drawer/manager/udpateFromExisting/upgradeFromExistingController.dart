import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../main.dart';
import '../../../../network/network_const.dart';
import '../../../../route/app_route.dart';
import '../../../../wiget/custome_snackbar.dart';

class GetStaffDetails {
  String? message;
  List<Data>? data;

  GetStaffDetails({this.message, this.data});

  GetStaffDetails.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
      });
    }
  }
}

class Data {
  AssignTime? assignTime;
  LunchTime? lunchTime;
  String? sId;
  String? fullName;
  String? email;
  String? specialization;
  String? phoneNumber;
  String? password;
  String? gender;
  BranchId? branchId;
  CommitionId? commissionId;
  List<ServiceId>? serviceId;
  int? status;
  String? image;
  int? salary;
  bool? showInCalendar;
  String? createdAt;
  String? updatedAt;
  int? iV;

  Data({
    this.assignTime,
    this.lunchTime,
    this.sId,
    this.fullName,
    this.email,
    this.phoneNumber,
    this.password,
    this.specialization,
    this.gender,
    this.branchId,
    this.commissionId,
    this.serviceId,
    this.status,
    this.image,
    this.salary,
    this.showInCalendar,
    this.createdAt,
    this.updatedAt,
    this.iV,
  });

  Data.fromJson(Map<String, dynamic> json) {
    assignTime = json['assign_time'] != null
        ? AssignTime.fromJson(json['assign_time'])
        : null;
    lunchTime = json['lunch_time'] != null
        ? LunchTime.fromJson(json['lunch_time'])
        : null;
    sId = json['_id'];
    fullName = json['full_name'];
    email = json['email'];
    phoneNumber = json['phone_number'];
    password = json['password'];
    gender = json['gender'];
    specialization = json['specialization'];
    branchId =
        json['branch_id'] != null ? BranchId.fromJson(json['branch_id']) : null;
    commissionId = json['commission_id']?.cast<String>();
    if (json['service_id'] != null) {
      serviceId = <ServiceId>[];
      json['service_id'].forEach((v) {
        serviceId!.add(ServiceId.fromJson(v));
      });
    }
    status = json['status'];
    image = json['image'];
    salary = json['salary'];
    showInCalendar = json['show_in_calendar'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (assignTime != null) {
      data['assign_time'] = assignTime!.toJson();
    }
    if (lunchTime != null) {
      data['lunch_time'] = lunchTime!.toJson();
    }
    data['_id'] = sId;
    data['full_name'] = fullName;
    data['email'] = email;
    data['phone_number'] = phoneNumber;
    data['password'] = password;
    data['gender'] = gender;
    data['specialization'] = specialization;
    if (branchId != null) {
      data['branch_id'] = branchId!.toJson();
    }
    data['commission_id'] = commissionId;
    if (serviceId != null) {
      data['service_id'] = serviceId!.map((v) => v.toJson()).toList();
    }
    data['status'] = status;
    data['image'] = image;
    data['salary'] = salary;
    data['show_in_calendar'] = showInCalendar;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    return data;
  }
}

class AssignTime {
  String? startShift;
  String? endShift;

  AssignTime({this.startShift, this.endShift});

  AssignTime.fromJson(Map<String, dynamic> json) {
    startShift = json['start_shift'];
    endShift = json['end_shift'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['start_shift'] = startShift;
    data['end_shift'] = endShift;
    return data;
  }
}

class LunchTime {
  int? duration;
  String? timing;

  LunchTime({this.duration, this.timing});

  LunchTime.fromJson(Map<String, dynamic> json) {
    duration = json['duration'];
    timing = json['timing'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['duration'] = duration;
    data['timing'] = timing;
    return data;
  }
}

class BranchId {
  String? sId;
  String? name;
  // ... other fields as needed ...

  BranchId({this.sId, this.name});

  BranchId.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['name'] = name;
    return data;
  }
}

class CommitionId {
  String? sId;
  String? name;
  // ... other fields as needed ...

  CommitionId({this.sId, this.name});

  CommitionId.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['name'] = name;
    return data;
  }
}

class ServiceId {
  String? sId;
  String? name;
  // ... other fields as needed ...

  ServiceId({this.sId, this.name});

  ServiceId.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['name'] = name;
    return data;
  }
}

class Upgradefromexistingcontroller extends GetxController {
  @override
  void onInit() {
    super.onInit();
    getStaffDetails();
  }

  var selectedStaffId = ''.obs;
  var staffList = <Data>[].obs;
  var isLoading = false.obs;
  var passwordController = TextEditingController();

  var confirmPasswordController = TextEditingController();

  var showPassword = false.obs;

  var showConfirmPassword = false.obs;

  void toggleShowPassword() {
    showPassword.value = !showPassword.value;
  }

  void toggleShowConfirmPass() {
    showConfirmPassword.value = !showConfirmPassword.value;
  }

  Future<void> getStaffDetails() async {
    final loginUser = await prefs.getUser();
    isLoading.value = true;
    try {
      final response = await dioClient.getData(
        '${Apis.baseUrl}${Endpoints.getStaffDetails}${loginUser!.salonId}',
        (json) => GetStaffDetails.fromJson(json),
      );
      print("${Apis.baseUrl}${Endpoints.getStaffDetails}${loginUser!.salonId}");

      staffList.value = response.data ?? [];
    } catch (e) {
      CustomSnackbar.showError('Error', 'Failed to check email: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> upgradeStaff2Manager() async {
    isLoading.value = true;
    try {
      final response = await dioClient.postData(
        '${Apis.baseUrl}/managers/upgrade/${selectedStaffId.value}',
        {
          'password': passwordController.text,
          'confirm_password': confirmPasswordController.text,
        },
        (json) => json,
      );
      CustomSnackbar.showSuccess('Success', response['message']);
      Get.back();
    } catch (e) {
      CustomSnackbar.showError('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
