class Sigm_up_model {
  String? fullName;
  String? phoneNumber;
  String? email;
  String? address;
  String? packageId;
  SalonDetails? salonDetails;
  String? adminId;
  String? salonId;

  Sigm_up_model(
      {this.fullName,
      this.phoneNumber,
      this.email,
      this.address,
      this.packageId,
      this.salonDetails,
      this.adminId,
      this.salonId});

  Sigm_up_model.fromJson(Map<String, dynamic> json) {
    fullName = json['full_name'];
    phoneNumber = json['phone_number'];
    email = json['email'];
    address = json['address'];
    packageId = json['package_id'];
    salonDetails = json['salonDetails'] != null
        ? new SalonDetails.fromJson(json['salonDetails'])
        : null;
    adminId = json['admin_id'];
    salonId = json['salon_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['full_name'] = this.fullName;
    data['phone_number'] = this.phoneNumber;
    data['email'] = this.email;
    data['address'] = this.address;
    data['package_id'] = this.packageId;
    if (this.salonDetails != null) {
      data['salonDetails'] = this.salonDetails!.toJson();
    }
    data['admin_id'] = this.adminId;
    data['salon_id'] = this.salonId;
    return data;
  }
}

class SalonDetails {
  String? salonName;

  SalonDetails({this.salonName});

  SalonDetails.fromJson(Map<String, dynamic> json) {
    salonName = json['salon_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['salon_name'] = this.salonName;
    return data;
  }
}
