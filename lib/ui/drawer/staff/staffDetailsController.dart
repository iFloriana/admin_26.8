import 'package:flutter_template/main.dart';
import 'package:flutter_template/network/network_const.dart';
import 'package:flutter_template/wiget/custome_snackbar.dart';
import 'package:get/get.dart';

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
    image = json['image_url'];
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

class Staffdetailscontroller extends GetxController {
  var staffList = <Data>[].obs;
  var filteredStaffList = <Data>[].obs;
  var isLoading = false.obs;
  var selectedBranchId = ''.obs;
  var availableBranches = <BranchId>[].obs;

  @override
  void onInit() {
    super.onInit();
    getCustomerDetails();
  }

  Future<void> getCustomerDetails() async {
    final loginUser = await prefs.getUser();
    isLoading.value = true;
    try {
      final response = await dioClient.getData(
        '${Apis.baseUrl}${Endpoints.getStaffDetails}${loginUser!.salonId}',
        (json) => GetStaffDetails.fromJson(json),
      );
      staffList.value = response.data ?? [];

      // Extract unique branches from staff list
      _extractBranches();

      // Apply initial filter
      applyBranchFilter();
    } catch (e) {
      CustomSnackbar.showError('Error', 'Failed to check email: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void _extractBranches() {
    final branches = <BranchId>[];
    final branchIds = <String>{};

    for (final staff in staffList) {
      if (staff.branchId != null &&
          staff.branchId!.sId != null &&
          !branchIds.contains(staff.branchId!.sId)) {
        branches.add(staff.branchId!);
        branchIds.add(staff.branchId!.sId!);
      }
    }

    availableBranches.value = branches;
  }

  void applyBranchFilter() {
    if (selectedBranchId.value.isEmpty) {
      // Show all staff if no branch is selected
      filteredStaffList.value = staffList;
    } else {
      // Filter staff by selected branch
      filteredStaffList.value = staffList
          .where((staff) => staff.branchId?.sId == selectedBranchId.value)
          .toList();
    }
  }

  void onBranchChanged(String? branchId) {
    selectedBranchId.value = branchId ?? '';
    applyBranchFilter();
  }

  Future<void> deleteStaff(String staffId) async {
    final loginUser = await prefs.getUser();
    try {
      await dioClient.deleteData(
        '${Apis.baseUrl}${Endpoints.postStaffDetails}/$staffId/?salon_id=${loginUser!.salonId}',
        (json) => json,
      );
      CustomSnackbar.showSuccess('Success', 'Staff deleted successfully');
      getCustomerDetails();
    } catch (e) {
      CustomSnackbar.showError('Error', 'Failed to delete staff: $e');
    }
  }
}
