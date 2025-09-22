class GetAdminDetails {
  Admin? admin;
  SalonDetails? salonDetails;

  GetAdminDetails({this.admin, this.salonDetails});

  GetAdminDetails.fromJson(Map<String, dynamic> json) {
    admin = json['admin'] != null ? new Admin.fromJson(json['admin']) : null;
    salonDetails = json['salonDetails'] != null
        ? new SalonDetails.fromJson(json['salonDetails'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
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
  PackageId? packageId;
  String? packageStartDate;
  String? packageExpirationDate;
  String? password;
  String? createdAt;
  String? updatedAt;
  int? iV;

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
      this.createdAt,
      this.updatedAt,
      this.iV});

  Admin.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    fullName = json['full_name'];
    phoneNumber = json['phone_number'];
    email = json['email'];
    address = json['address'];
    packageId = json['package_id'] != null
        ? new PackageId.fromJson(json['package_id'])
        : null;
    packageStartDate = json['package_start_date'];
    packageExpirationDate = json['package_expiration_date'];
    password = json['password'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['full_name'] = this.fullName;
    data['phone_number'] = this.phoneNumber;
    data['email'] = this.email;
    data['address'] = this.address;
    if (this.packageId != null) {
      data['package_id'] = this.packageId!.toJson();
    }
    data['package_start_date'] = this.packageStartDate;
    data['package_expiration_date'] = this.packageExpirationDate;
    data['password'] = this.password;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
    return data;
  }
}

class PackageId {
  String? status;
  String? sId;
  String? packageName;
  String? description;
  int? price;
  List<String>? servicesIncluded;
  String? subscriptionPlan;
  int? iV;

  PackageId(
      {this.status,
      this.sId,
      this.packageName,
      this.description,
      this.price,
      this.servicesIncluded,
      this.subscriptionPlan,
      this.iV});

  PackageId.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    sId = json['_id'];
    packageName = json['package_name'];
    description = json['description'];
    price = json['price'];
    servicesIncluded = json['services_included'].cast<String>();
    subscriptionPlan = json['subscription_plan'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['_id'] = this.sId;
    data['package_name'] = this.packageName;
    data['description'] = this.description;
    data['price'] = this.price;
    data['services_included'] = this.servicesIncluded;
    data['subscription_plan'] = this.subscriptionPlan;
    data['__v'] = this.iV;
    return data;
  }
}

class SalonDetails {
  String? sId;
  String? salonName;
  String? description;
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
  String? gstNumber;
  String? imageUrl;

  SalonDetails(
      {this.sId,
      this.salonName,
      this.description,
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
      this.gstNumber,
      this.imageUrl});

  SalonDetails.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    salonName = json['salon_name'];
    description = json['description'];
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
    gstNumber = json['gst_number'];
    imageUrl = json['image_url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['salon_name'] = this.salonName;
    data['description'] = this.description;
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
    data['gst_number'] = this.gstNumber;
    data['image_url'] = this.imageUrl;
    return data;
  }
}
