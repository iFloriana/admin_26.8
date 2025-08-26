class ManagerBranchPackageModel {
  final String id;
  final List<ManagerBranchInfo> branchId;
  final String packageName;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final num status;
  final List<ManagerPackageDetail> packageDetails;
  final num packagePrice;
  final String salonId;
  final List<dynamic> usedServices;
  final DateTime createdAt;
  final DateTime updatedAt;

  ManagerBranchPackageModel({
    required this.id,
    required this.branchId,
    required this.packageName,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.packageDetails,
    required this.packagePrice,
    required this.salonId,
    required this.usedServices,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ManagerBranchPackageModel.fromJson(Map<String, dynamic> json) {
    return ManagerBranchPackageModel(
      id: (json['_id'] ?? '').toString(),
      branchId: ((json['branch_id'] as List?) ?? [])
          .map((b) =>
              ManagerBranchInfo.fromJson((b as Map).cast<String, dynamic>()))
          .toList(),
      packageName: (json['package_name'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      startDate: DateTime.tryParse((json['start_date'] ?? '').toString()) ??
          DateTime.now(),
      endDate: DateTime.tryParse((json['end_date'] ?? '').toString()) ??
          DateTime.now(),
      status: json['status'] is num
          ? json['status'] as num
          : num.tryParse('${json['status'] ?? 0}') ?? 0,
      packageDetails: ((json['package_details'] as List?) ?? [])
          .map((d) =>
              ManagerPackageDetail.fromJson((d as Map).cast<String, dynamic>()))
          .toList(),
      packagePrice: json['package_price'] is num
          ? json['package_price'] as num
          : num.tryParse('${json['package_price'] ?? 0}') ?? 0,
      salonId: (json['salon_id'] ?? '').toString(),
      usedServices: (json['used_services'] as List?) ?? const [],
      createdAt: DateTime.tryParse((json['createdAt'] ?? '').toString()) ??
          DateTime.now(),
      updatedAt: DateTime.tryParse((json['updatedAt'] ?? '').toString()) ??
          DateTime.now(),
    );
  }
}

class ManagerBranchInfo {
  final String id;
  final String name;

  ManagerBranchInfo({
    required this.id,
    required this.name,
  });

  factory ManagerBranchInfo.fromJson(Map<String, dynamic> json) {
    return ManagerBranchInfo(
      id: (json['_id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
    );
  }
}

class ManagerPackageDetail {
  final ManagerServiceMini serviceId;
  final num discountedPrice;
  final num quantity;
  final String id;

  ManagerPackageDetail({
    required this.serviceId,
    required this.discountedPrice,
    required this.quantity,
    required this.id,
  });

  factory ManagerPackageDetail.fromJson(Map<String, dynamic> json) {
    return ManagerPackageDetail(
      serviceId: ManagerServiceMini.fromJson(
          (json['service_id'] ?? const {}) as Map<String, dynamic>),
      discountedPrice: json['discounted_price'] is num
          ? json['discounted_price'] as num
          : num.tryParse('${json['discounted_price'] ?? 0}') ?? 0,
      quantity: json['quantity'] is num
          ? json['quantity'] as num
          : num.tryParse('${json['quantity'] ?? 0}') ?? 0,
      id: (json['_id'] ?? '').toString(),
    );
  }
}

class ManagerServiceMini {
  final String id;
  final String name;
  final num regularPrice;

  ManagerServiceMini({
    required this.id,
    required this.name,
    required this.regularPrice,
  });

  factory ManagerServiceMini.fromJson(Map<String, dynamic> json) {
    return ManagerServiceMini(
      id: (json['_id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      regularPrice: json['regular_price'] is num
          ? json['regular_price'] as num
          : num.tryParse('${json['regular_price'] ?? 0}') ?? 0,
    );
  }
}
