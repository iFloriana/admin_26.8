class UnitsModel {
  final String? message;
  final List<UnitData>? data;

  UnitsModel({
    this.message,
    this.data,
  });

  factory UnitsModel.fromJson(Map<String, dynamic> json) {
    return UnitsModel(
      message: json['message'],
      data: json['data'] != null
          ? List<UnitData>.from(json['data'].map((x) => UnitData.fromJson(x)))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'data': data?.map((x) => x.toJson()).toList(),
    };
  }
}

// Alternative constructor for when the response is directly a list
class UnitsListModel {
  final List<UnitData>? data;

  UnitsListModel({
    this.data,
  });

  factory UnitsListModel.fromJson(List<dynamic> json) {
    return UnitsListModel(
      data: json.map((x) => UnitData.fromJson(x)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data?.map((x) => x.toJson()).toList(),
    };
  }
}

class UnitData {
  final String? id;
  final BranchInfo? branchId;
  final String? name;
  final int? status;
  final String? createdAt;
  final String? updatedAt;
  final int? version;

  UnitData({
    this.id,
    this.branchId,
    this.name,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.version,
  });

  factory UnitData.fromJson(Map<String, dynamic> json) {
    return UnitData(
      id: json['_id'],
      branchId: json['branch_id'] != null
          ? BranchInfo.fromJson(json['branch_id'])
          : null,
      name: json['name'],
      status: json['status'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      version: json['__v'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'branch_id': branchId?.toJson(),
      'name': name,
      'status': status,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      '__v': version,
    };
  }
}

class BranchInfo {
  final double? ratingStar;
  final int? totalReview;
  final String? id;
  final String? name;
  final String? assignManager;
  final String? salonId;
  final String? category;
  final int? status;
  final String? contactEmail;
  final String? contactNumber;
  final List<String>? paymentMethod;
  final String? serviceId;
  final String? shopNo;
  final String? buildingName;
  final String? landmark;
  final String? country;
  final String? state;
  final String? city;
  final String? postalCode;
  final double? latitude;
  final double? longitude;
  final String? description;
  final String? image;
  final String? createdAt;
  final String? updatedAt;
  final int? version;
  final List<WorkingDay>? workingDays;

  BranchInfo({
    this.ratingStar,
    this.totalReview,
    this.id,
    this.name,
    this.assignManager,
    this.salonId,
    this.category,
    this.status,
    this.contactEmail,
    this.contactNumber,
    this.paymentMethod,
    this.serviceId,
    this.shopNo,
    this.buildingName,
    this.landmark,
    this.country,
    this.state,
    this.city,
    this.postalCode,
    this.latitude,
    this.longitude,
    this.description,
    this.image,
    this.createdAt,
    this.updatedAt,
    this.version,
    this.workingDays,
  });

  factory BranchInfo.fromJson(Map<String, dynamic> json) {
    return BranchInfo(
      ratingStar: json['rating_star']?.toDouble(),
      totalReview: json['total_review'],
      id: json['_id'],
      name: json['name'],
      assignManager: json['assign_manager'],
      salonId: json['salon_id'],
      category: json['category'],
      status: json['status'],
      contactEmail: json['contact_email'],
      contactNumber: json['contact_number'],
      paymentMethod: json['payment_method'] != null
          ? List<String>.from(json['payment_method'])
          : null,
      serviceId: json['service_id'],
      shopNo: json['shop_no'],
      buildingName: json['building_name'],
      landmark: json['landmark'],
      country: json['country'],
      state: json['state'],
      city: json['city'],
      postalCode: json['postal_code'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      description: json['description'],
      image: json['image'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      version: json['__v'],
      workingDays: json['working_days'] != null
          ? List<WorkingDay>.from(
              json['working_days'].map((x) => WorkingDay.fromJson(x)))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rating_star': ratingStar,
      'total_review': totalReview,
      '_id': id,
      'name': name,
      'assign_manager': assignManager,
      'salon_id': salonId,
      'category': category,
      'status': status,
      'contact_email': contactEmail,
      'contact_number': contactNumber,
      'payment_method': paymentMethod,
      'service_id': serviceId,
      'shop_no': shopNo,
      'building_name': buildingName,
      'landmark': landmark,
      'country': country,
      'state': state,
      'city': city,
      'postal_code': postalCode,
      'latitude': latitude,
      'longitude': longitude,
      'description': description,
      'image': image,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      '__v': version,
      'working_days': workingDays?.map((x) => x.toJson()).toList(),
    };
  }
}

class WorkingDay {
  final String? day;
  final String? startTime;
  final String? endTime;
  final int? isHoliday;
  final List<dynamic>? breaks;
  final String? id;

  WorkingDay({
    this.day,
    this.startTime,
    this.endTime,
    this.isHoliday,
    this.breaks,
    this.id,
  });

  factory WorkingDay.fromJson(Map<String, dynamic> json) {
    return WorkingDay(
      day: json['day'],
      startTime: json['start_time'],
      endTime: json['end_time'],
      isHoliday: json['is_holiday'],
      breaks: json['breaks'],
      id: json['_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'start_time': startTime,
      'end_time': endTime,
      'is_holiday': isHoliday,
      'breaks': breaks,
      '_id': id,
    };
  }
}
