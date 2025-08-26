class getStaffDetails {
  String? message;
  List<Data>? data;

  getStaffDetails({this.message, this.data});

  getStaffDetails.fromJson(Map<String, dynamic> json) {
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
  AssignTime? assignTime;
  LunchTime? lunchTime;
  String? sId;
  String? fullName;
  String? email;
  String? phoneNumber;
  String? password;
  String? gender;
  BranchId? branchId;
  List<String>? commissionId;
  List<ServiceId>? serviceId;
  int? status;
  String? image;
  int? salary;
  bool? showInCalendar;
  String? createdAt;
  String? updatedAt;
  int? iV;

  Data(
      {this.assignTime,
      this.lunchTime,
      this.sId,
      this.fullName,
      this.email,
      this.phoneNumber,
      this.password,
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
      this.iV});

  Data.fromJson(Map<String, dynamic> json) {
    assignTime = json['assign_time'] != null
        ? new AssignTime.fromJson(json['assign_time'])
        : null;
    lunchTime = json['lunch_time'] != null
        ? new LunchTime.fromJson(json['lunch_time'])
        : null;
    sId = json['_id'];
    fullName = json['full_name'];
    email = json['email'];
    phoneNumber = json['phone_number'];
    password = json['password'];
    gender = json['gender'];
    branchId = json['branch_id'] != null
        ? new BranchId.fromJson(json['branch_id'])
        : null;
    commissionId = json['commission_id'].cast<String>();
    if (json['service_id'] != null) {
      serviceId = <ServiceId>[];
      json['service_id'].forEach((v) {
        serviceId!.add(new ServiceId.fromJson(v));
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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.assignTime != null) {
      data['assign_time'] = this.assignTime!.toJson();
    }
    if (this.lunchTime != null) {
      data['lunch_time'] = this.lunchTime!.toJson();
    }
    data['_id'] = this.sId;
    data['full_name'] = this.fullName;
    data['email'] = this.email;
    data['phone_number'] = this.phoneNumber;
    data['password'] = this.password;
    data['gender'] = this.gender;
    if (this.branchId != null) {
      data['branch_id'] = this.branchId!.toJson();
    }
    data['commission_id'] = this.commissionId;
    if (this.serviceId != null) {
      data['service_id'] = this.serviceId!.map((v) => v.toJson()).toList();
    }
    data['status'] = this.status;
    data['image'] = this.image;
    data['salary'] = this.salary;
    data['show_in_calendar'] = this.showInCalendar;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['start_shift'] = this.startShift;
    data['end_shift'] = this.endShift;
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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['duration'] = this.duration;
    data['timing'] = this.timing;
    return data;
  }
}

class BranchId {
  String? sId;
  String? name;
  String? salonId;
  String? category;
  int? status;
  String? contactEmail;
  String? contactNumber;
  List<String>? paymentMethod;
  List<String>? serviceId;
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
  String? assignManager;

  BranchId(
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
      this.assignManager});

  BranchId.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    salonId = json['salon_id'];
    category = json['category'];
    status = json['status'];
    contactEmail = json['contact_email'];
    contactNumber = json['contact_number'];
    paymentMethod = json['payment_method'].cast<String>();
    serviceId = json['service_id'].cast<String>();
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
    assignManager = json['assign_manager'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['name'] = this.name;
    data['salon_id'] = this.salonId;
    data['category'] = this.category;
    data['status'] = this.status;
    data['contact_email'] = this.contactEmail;
    data['contact_number'] = this.contactNumber;
    data['payment_method'] = this.paymentMethod;
    data['service_id'] = this.serviceId;
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
    data['assign_manager'] = this.assignManager;
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
