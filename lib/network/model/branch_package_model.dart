class BranchPackageModel {
  final String id;
  final List<BranchInfo> branchId;
  final String packageName;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final int status;
  final List<PackageDetail> packageDetails;
  final int packagePrice;
  final DateTime createdAt;
  final DateTime updatedAt;

  BranchPackageModel({
    required this.id,
    required this.branchId,
    required this.packageName,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.packageDetails,
    required this.packagePrice,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BranchPackageModel.fromJson(Map<String, dynamic> json) {
    return BranchPackageModel(
      id: json['_id'] ?? '',
      branchId: (json['branch_id'] as List?)
              ?.map((branch) => BranchInfo.fromJson(branch))
              .toList() ??
          [],
      packageName: json['package_name'] ?? '',
      description: json['description'] ?? '',
      startDate: DateTime.parse(
          json['start_date'] ?? DateTime.now().toIso8601String()),
      endDate:
          DateTime.parse(json['end_date'] ?? DateTime.now().toIso8601String()),
      status: json['status'] ?? 0,
      packageDetails: (json['package_details'] as List?)
              ?.map((detail) => PackageDetail.fromJson(detail))
              .toList() ??
          [],
      packagePrice: json['package_price'] ?? 0,
      createdAt:
          DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt:
          DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}

class BranchInfo {
  final String id;
  final String name;
  final String salonId;
  final String category;
  final int status;
  final String contactEmail;
  final String contactNumber;
  final List<String> paymentMethod;
  final List<String> serviceId;
  final String shopNo;
  final String buildingName;
  final String landmark;
  final String countryId;
  final String stateId;
  final String cityId;
  final String postalCode;
  final double latitude;
  final double longitude;
  final String description;
  final String image;
  final int ratingStar;
  final int totalReview;
  final List<WorkingDay> workingDays;

  BranchInfo({
    required this.id,
    required this.name,
    required this.salonId,
    required this.category,
    required this.status,
    required this.contactEmail,
    required this.contactNumber,
    required this.paymentMethod,
    required this.serviceId,
    required this.shopNo,
    required this.buildingName,
    required this.landmark,
    required this.countryId,
    required this.stateId,
    required this.cityId,
    required this.postalCode,
    required this.latitude,
    required this.longitude,
    required this.description,
    required this.image,
    required this.ratingStar,
    required this.totalReview,
    required this.workingDays,
  });

  factory BranchInfo.fromJson(Map<String, dynamic> json) {
    return BranchInfo(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      salonId: json['salon_id'] ?? '',
      category: json['category'] ?? '',
      status: json['status'] ?? 0,
      contactEmail: json['contact_email'] ?? '',
      contactNumber: json['contact_number'] ?? '',
      paymentMethod: List<String>.from(json['payment_method'] ?? []),
      serviceId: List<String>.from(json['service_id'] ?? []),
      shopNo: json['shop_no'] ?? '',
      buildingName: json['building_name'] ?? '',
      landmark: json['landmark'] ?? '',
      countryId: json['country_id'] ?? '',
      stateId: json['state_id'] ?? '',
      cityId: json['city_id'] ?? '',
      postalCode: json['postal_code'] ?? '',
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      description: json['description'] ?? '',
      image: json['image'] ?? '',
      ratingStar: json['rating_star'] ?? 0,
      totalReview: json['total_review'] ?? 0,
      workingDays: (json['working_days'] as List?)
              ?.map((day) => WorkingDay.fromJson(day))
              .toList() ??
          [],
    );
  }
}

class WorkingDay {
  final String day;
  final String startTime;
  final String endTime;
  final int isHoliday;
  final List<String> breaks;
  final String id;

  WorkingDay({
    required this.day,
    required this.startTime,
    required this.endTime,
    required this.isHoliday,
    required this.breaks,
    required this.id,
  });

  factory WorkingDay.fromJson(Map<String, dynamic> json) {
    return WorkingDay(
      day: json['day'] ?? '',
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
      isHoliday: json['is_holiday'] ?? 0,
      breaks: List<String>.from(json['breaks'] ?? []),
      id: json['_id'] ?? '',
    );
  }
}

class PackageDetail {
  final ServiceInfo serviceId;
  final int discountedPrice;
  final int quantity;
  final String id;

  PackageDetail({
    required this.serviceId,
    required this.discountedPrice,
    required this.quantity,
    required this.id,
  });

  factory PackageDetail.fromJson(Map<String, dynamic> json) {
    return PackageDetail(
      serviceId: ServiceInfo.fromJson(json['service_id'] ?? {}),
      discountedPrice: json['discounted_price'] ?? 0,
      quantity: json['quantity'] ?? 0,
      id: json['_id'] ?? '',
    );
  }
}

class ServiceInfo {
  final String id;
  final String image;
  final String name;
  final int serviceDuration;
  final String categoryId;
  final String description;
  final int status;
  final String salonId;
  final int membersPrice;
  final int regularPrice;

  ServiceInfo({
    required this.id,
    required this.image,
    required this.name,
    required this.serviceDuration,
    required this.categoryId,
    required this.description,
    required this.status,
    required this.salonId,
    required this.membersPrice,
    required this.regularPrice,
  });

  factory ServiceInfo.fromJson(Map<String, dynamic> json) {
    return ServiceInfo(
      id: json['_id'] ?? '',
      image: json['image'] ?? '',
      name: json['name'] ?? '',
      serviceDuration: json['service_duration'] ?? 0,
      categoryId: json['category_id'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? 0,
      salonId: json['salon_id'] ?? '',
      membersPrice: json['members_price'] ?? 0,
      regularPrice: json['regular_price'] ?? 0,
    );
  }
}
