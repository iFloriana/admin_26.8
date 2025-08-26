class UpdateProfileModel {
  String? message;
  Admin? admin;
  SalonDetails? salonDetails;

  UpdateProfileModel({this.message, this.admin, this.salonDetails});

  UpdateProfileModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    admin = json['admin'] != null ? new Admin.fromJson(json['admin']) : null;
    salonDetails = json['salonDetails'] != null
        ? new SalonDetails.fromJson(json['salonDetails'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    if (this.admin != null) {
      data['admin'] = this.admin!.toJson();
    }
    if (this.salonDetails != null) {
      data['salonDetails'] = this.salonDetails!.toJson();
    }
    return data;
  }
}

class Admin {
  String? sId;
  String? fullName;
  String? phoneNumber;
  String? email;
  String? address;
  String? packageId;
  String? packageStartDate;
  String? packageExpirationDate;
  String? password;
  int? iV;
  String? updatedAt;

  Admin(
      {this.sId,
      this.fullName,
      this.phoneNumber,
      this.email,
      this.address,
      this.packageId,
      this.packageStartDate,
      this.packageExpirationDate,
      this.password,
      this.iV,
      this.updatedAt});

  Admin.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    fullName = json['full_name'];
    phoneNumber = json['phone_number'];
    email = json['email'];
    address = json['address'];
    packageId = json['package_id'];
    packageStartDate = json['package_start_date'];
    packageExpirationDate = json['package_expiration_date'];
    password = json['password'];
    iV = json['__v'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['full_name'] = this.fullName;
    data['phone_number'] = this.phoneNumber;
    data['email'] = this.email;
    data['address'] = this.address;
    data['package_id'] = this.packageId;
    data['package_start_date'] = this.packageStartDate;
    data['package_expiration_date'] = this.packageExpirationDate;
    data['password'] = this.password;
    data['__v'] = this.iV;
    data['updatedAt'] = this.updatedAt;
    return data;
  }
}

class SalonDetails {
  String? sId;
  String? salonName;
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

  SalonDetails(
      {this.sId,
      this.salonName,
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
      this.iV});

  SalonDetails.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    salonName = json['salon_name'];
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
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['salon_name'] = this.salonName;
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
    return data;
  }
}
