class RegisterDetailsModel {
  String? sId;
  String? fullName;
  String? salonName;
  String? phoneNumber;
  String? email;
  String? address;
  PackageId? packageId;
  String? password;
  int? iV;

  RegisterDetailsModel(
      {this.sId,
      this.fullName,
      this.salonName,
      this.phoneNumber,
      this.email,
      this.address,
      this.packageId,
      this.password,
      this.iV});

  RegisterDetailsModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    fullName = json['full_name'];
    salonName = json['salon_name'];
    phoneNumber = json['phone_number'];
    email = json['email'];
    address = json['address'];
    packageId = json['package_id'] != null
        ? new PackageId.fromJson(json['package_id'])
        : null;
    password = json['password'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['full_name'] = this.fullName;
    data['salon_name'] = this.salonName;
    data['phone_number'] = this.phoneNumber;
    data['email'] = this.email;
    data['address'] = this.address;
    if (this.packageId != null) {
      data['package_id'] = this.packageId!.toJson();
    }
    data['password'] = this.password;
    data['__v'] = this.iV;
    return data;
  }
}

class PackageId {
  String? sId;
  String? packageName;
  String? description;
  int? price;
  List<String>? servicesIncluded;
  String? expirationDate;
  String? subscriptionPlan;
  int? iV;

  PackageId(
      {this.sId,
      this.packageName,
      this.description,
      this.price,
      this.servicesIncluded,
      this.expirationDate,
      this.subscriptionPlan,
      this.iV});

  PackageId.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    packageName = json['package_name'];
    description = json['description'];
    price = json['price'];
    servicesIncluded = json['services_included'].cast<String>();
    expirationDate = json['expiration_date'];
    subscriptionPlan = json['subscription_plan'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['package_name'] = this.packageName;
    data['description'] = this.description;
    data['price'] = this.price;
    data['services_included'] = this.servicesIncluded;
    data['expiration_date'] = this.expirationDate;
    data['subscription_plan'] = this.subscriptionPlan;
    data['__v'] = this.iV;
    return data;
  }
}
