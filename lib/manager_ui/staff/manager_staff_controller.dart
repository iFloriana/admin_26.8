import 'package:get/get.dart';
import 'package:flutter_template/main.dart';
import 'package:flutter_template/network/network_const.dart';
import 'package:flutter_template/wiget/custome_snackbar.dart';

class ManagerStaffBranchInfo {
  final String? id;
  final String? name;
  ManagerStaffBranchInfo({this.id, this.name});
  factory ManagerStaffBranchInfo.fromJson(Map<String, dynamic> json) {
    return ManagerStaffBranchInfo(
      id: json['_id']?.toString(),
      name: json['name']?.toString(),
    );
  }
}

class ManagerStaffServiceInfo {
  final String? id;
  final String? name;
  final int? duration;
  final int? price;
  ManagerStaffServiceInfo({this.id, this.name, this.duration, this.price});
  factory ManagerStaffServiceInfo.fromJson(Map<String, dynamic> json) {
    return ManagerStaffServiceInfo(
      id: json['_id']?.toString(),
      name: json['name']?.toString(),
      duration:
          json['service_duration'] is int ? json['service_duration'] : null,
      price: json['regular_price'] is int ? json['regular_price'] : null,
    );
  }
}

class ManagerStaffItem {
  final String? id;
  final String? fullName;
  final String? email;
  final String? phoneNumber;
  final String? gender;
  final ManagerStaffBranchInfo? branch;
  final String? salonId;
  final List<ManagerStaffServiceInfo> services;
  final int? status;
  final bool? showInCalendar;
  final String? specialization;
  final String? imageUrl;

  ManagerStaffItem({
    this.id,
    this.fullName,
    this.email,
    this.phoneNumber,
    this.gender,
    this.branch,
    this.salonId,
    this.services = const [],
    this.status,
    this.showInCalendar,
    this.specialization,
    this.imageUrl,
  });

  factory ManagerStaffItem.fromJson(Map<String, dynamic> json) {
    ManagerStaffBranchInfo? branch;
    if (json['branch_id'] is Map<String, dynamic>) {
      branch = ManagerStaffBranchInfo.fromJson(json['branch_id']);
    }
    final List<ManagerStaffServiceInfo> services = <ManagerStaffServiceInfo>[];
    if (json['service_id'] is List) {
      for (final s in (json['service_id'] as List)) {
        if (s is Map<String, dynamic>) {
          services.add(ManagerStaffServiceInfo.fromJson(s));
        }
      }
    }
    return ManagerStaffItem(
      id: json['_id']?.toString(),
      fullName: json['full_name']?.toString(),
      email: json['email']?.toString(),
      phoneNumber: json['phone_number']?.toString(),
      gender: json['gender']?.toString(),
      branch: branch,
      salonId: json['salon_id']?.toString(),
      services: services,
      status: json['status'] is int ? json['status'] : null,
      showInCalendar:
          json['show_in_calendar'] is bool ? json['show_in_calendar'] : null,
      specialization: json['specialization']?.toString(),
      imageUrl: json['image_url'] is String ? json['image_url'] : null,
    );
  }
}

class ManagerStaffController extends GetxController {
  var staff = <ManagerStaffItem>[].obs;
  var filteredStaff = <ManagerStaffItem>[].obs;
  var branches = <ManagerStaffBranchInfo>[].obs;
  var selectedBranchId = ''.obs;
  var specializations = <String>[].obs;
  var selectedSpecialization = ''.obs;
  var searchQuery = ''.obs;
  var isLoading = false.obs;
  var isSearching = false.obs;

  @override
  void onInit() {
    super.onInit();
    getStaff();
  }

  Future<void> getStaff() async {
    final manager = await prefs.getManagerUser();
    if (manager == null) return;
    isLoading.value = true;
    try {
      final response = await dioClient.getData(
        '${Apis.baseUrl}/staffs/by-branch?salon_id=${manager.manager?.salonId}&branch_id=${manager.manager?.branchId?.sId}',
        (json) => json,
      );
      if (response != null && response['data'] is List) {
        final List data = response['data'];
        staff.value = data.map((e) => ManagerStaffItem.fromJson(e)).toList();
        filteredStaff.assignAll(staff);
        final Map<String, ManagerStaffBranchInfo> unique = {};
        for (final s in staff) {
          final b = s.branch;
          if (b != null && (b.id ?? '').isNotEmpty) unique[b.id!] = b;
        }
        branches.assignAll(unique.values.toList());

        // Build unique specialization list
        final Set<String> specs = {};
        for (final s in staff) {
          final spec = (s.specialization ?? '').trim();
          if (spec.isNotEmpty) specs.add(spec);
        }
        specializations.assignAll(specs.toList()..sort());
      } else {
        staff.clear();
        filteredStaff.clear();
        branches.clear();
        specializations.clear();
      }
    } catch (e) {
      CustomSnackbar.showError('Error', 'Failed to load staff: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void setSearchQuery(String query) {
    searchQuery.value = query;
    _applyFilters();
  }

  void clearSearch() {
    searchQuery.value = '';
    _applyFilters();
  }

  void applyBranchFilter(String branchId) {
    selectedBranchId.value = branchId;
    _applyFilters();
  }

  void applySpecializationFilter(String specialization) {
    selectedSpecialization.value = specialization;
    _applyFilters();
  }

  void _applyFilters() {
    Iterable<ManagerStaffItem> base = staff;
    if (selectedBranchId.value.isNotEmpty) {
      base = base.where((s) => s.branch?.id == selectedBranchId.value);
    }
    if (selectedSpecialization.value.isNotEmpty) {
      base = base.where(
          (s) => (s.specialization ?? '') == selectedSpecialization.value);
    }
    final q = searchQuery.value.trim().toLowerCase();
    if (q.isNotEmpty) {
      base = base.where((s) => (s.fullName ?? '').toLowerCase().contains(q));
    }
    filteredStaff.assignAll(base);
  }
}
