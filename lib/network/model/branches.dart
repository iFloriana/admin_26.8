class branches {
  String? message;
  List<Data>? data;

  branches({this.message, this.data});

  branches.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(new Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  String? sId;
  String? name;
  SalonId? salonId;
  String? category;
  int? status;
  String? contactEmail;
  String? contactNumber;
  List<String>? paymentMethod;
  List<ServiceId>? serviceId;
  String? shopNo;
  String? buildingName;
  String? landmark;
  String? countryId;
  String? stateId;
  String? cityId;
  String? postalCode;
  double? latitude;
  double? longitude;
  String? description;
  String? image;
  int? ratingStar;
  int? totalReview;
  List<WorkingDays>? workingDays;
  String? createdAt;
  String? updatedAt;
  int? iV;
  String? address;
  String? city;
  String? country;
  String? state;
  int? staffCount;
  String? assignManager;

  Data(
      {this.sId,
      this.name,
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
      this.countryId,
      this.stateId,
      this.cityId,
      this.postalCode,
      this.latitude,
      this.longitude,
      this.description,
      this.image,
      this.ratingStar,
      this.totalReview,
      this.workingDays,
      this.createdAt,
      this.updatedAt,
      this.iV,
      this.address,
      this.city,
      this.country,
      this.state,
      this.staffCount,
      this.assignManager});

  Data.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    salonId = json['salon_id'] != null
        ? new SalonId.fromJson(json['salon_id'])
        : null;
    category = json['category'];
    status = json['status'];
    contactEmail = json['contact_email'];
    contactNumber = json['contact_number'];
    paymentMethod = json['payment_method'].cast<String>();
    if (json['service_id'] != null) {
      serviceId = <ServiceId>[];
      json['service_id'].forEach((v) {
        serviceId!.add(new ServiceId.fromJson(v));
      });
    }
    shopNo = json['shop_no'];
    buildingName = json['building_name'];
    landmark = json['landmark'];
    countryId = json['country_id'];
    stateId = json['state_id'];
    cityId = json['city_id'];
    postalCode = json['postal_code'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    description = json['description'];
    image = json['image'];
    ratingStar = json['rating_star'];
    totalReview = json['total_review'];
    if (json['working_days'] != null) {
      workingDays = <WorkingDays>[];
      json['working_days'].forEach((v) {
        workingDays!.add(new WorkingDays.fromJson(v));
      });
    }
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
    address = json['address'];
    city = json['city'];
    country = json['country'];
    state = json['state'];
    staffCount = json['staff_count'];
    assignManager = json['assign_manager'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['name'] = this.name;
    if (this.salonId != null) {
      data['salon_id'] = this.salonId!.toJson();
    }
    data['category'] = this.category;
    data['status'] = this.status;
    data['contact_email'] = this.contactEmail;
    data['contact_number'] = this.contactNumber;
    data['payment_method'] = this.paymentMethod;
    if (this.serviceId != null) {
      data['service_id'] = this.serviceId!.map((v) => v.toJson()).toList();
    }
    data['shop_no'] = this.shopNo;
    data['building_name'] = this.buildingName;
    data['landmark'] = this.landmark;
    data['country_id'] = this.countryId;
    data['state_id'] = this.stateId;
    data['city_id'] = this.cityId;
    data['postal_code'] = this.postalCode;
    data['latitude'] = this.latitude;
    data['longitude'] = this.longitude;
    data['description'] = this.description;
    data['image'] = this.image;
    data['rating_star'] = this.ratingStar;
    data['total_review'] = this.totalReview;
    if (this.workingDays != null) {
      data['working_days'] = this.workingDays!.map((v) => v.toJson()).toList();
    }
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
    data['address'] = this.address;
    data['city'] = this.city;
    data['country'] = this.country;
    data['state'] = this.state;
    data['staff_count'] = this.staffCount;
    data['assign_manager'] = this.assignManager;
    return data;
  }
}

class SalonId {
  String? sId;
  String? name;
  String? description;
  String? address;
  String? contactNumber;
  String? contactEmail;
  String? openingTime;
  String? closingTime;
  String? category;
  int? status;
  String? packageId;
  String? signupId;
  String? createdAt;
  String? updatedAt;
  int? iV;
  String? image;

  SalonId(
      {this.sId,
      this.name,
      this.description,
      this.address,
      this.contactNumber,
      this.contactEmail,
      this.openingTime,
      this.closingTime,
      this.category,
      this.status,
      this.packageId,
      this.signupId,
      this.createdAt,
      this.updatedAt,
      this.iV,
      this.image});

  SalonId.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    description = json['description'];
    address = json['address'];
    contactNumber = json['contact_number'];
    contactEmail = json['contact_email'];
    openingTime = json['opening_time'];
    closingTime = json['closing_time'];
    category = json['category'];
    status = json['status'];
    packageId = json['package_id'];
    signupId = json['signup_id'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
    image = json['image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['name'] = this.name;
    data['description'] = this.description;
    data['address'] = this.address;
    data['contact_number'] = this.contactNumber;
    data['contact_email'] = this.contactEmail;
    data['opening_time'] = this.openingTime;
    data['closing_time'] = this.closingTime;
    data['category'] = this.category;
    data['status'] = this.status;
    data['package_id'] = this.packageId;
    data['signup_id'] = this.signupId;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
    data['image'] = this.image;
    return data;
  }
}

class ServiceId {
  String? sId;
  String? image;
  String? name;
  int? serviceDuration;
  String? categoryId;
  String? description;
  int? status;
  String? salonId;
  String? createdAt;
  String? updatedAt;
  int? iV;
  int? membersPrice;
  int? regularPrice;

  ServiceId(
      {this.sId,
      this.image,
      this.name,
      this.serviceDuration,
      this.categoryId,
      this.description,
      this.status,
      this.salonId,
      this.createdAt,
      this.updatedAt,
      this.iV,
      this.membersPrice,
      this.regularPrice});

  ServiceId.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    image = json['image'];
    name = json['name'];
    serviceDuration = json['service_duration'];
    categoryId = json['category_id'];
    description = json['description'];
    status = json['status'];
    salonId = json['salon_id'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
    membersPrice = json['members_price'];
    regularPrice = json['regular_price'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['image'] = this.image;
    data['name'] = this.name;
    data['service_duration'] = this.serviceDuration;
    data['category_id'] = this.categoryId;
    data['description'] = this.description;
    data['status'] = this.status;
    data['salon_id'] = this.salonId;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
    data['members_price'] = this.membersPrice;
    data['regular_price'] = this.regularPrice;
    return data;
  }
}

class WorkingDays {
  String? day;
  String? startTime;
  String? endTime;
  int? isHoliday;
  List<String>? breaks;
  String? sId;

  WorkingDays(
      {this.day,
      this.startTime,
      this.endTime,
      this.isHoliday,
      this.breaks,
      this.sId});

  WorkingDays.fromJson(Map<String, dynamic> json) {
    day = json['day'];
    startTime = json['start_time'];
    endTime = json['end_time'];
    isHoliday = json['is_holiday'];
    breaks = json['breaks'].cast<String>();
    sId = json['_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['day'] = this.day;
    data['start_time'] = this.startTime;
    data['end_time'] = this.endTime;
    data['is_holiday'] = this.isHoliday;
    data['breaks'] = this.breaks;
    data['_id'] = this.sId;
    return data;
  }
}
