class Login_model {
  String? message;
  String? token;
  String? fullName;
  String? email;
  String? salonName;
  String? phoneNumber;
  String? address;
  String? packageId;
  String? adminId;
  String? salonId;

  Login_model(
      {this.message,
      this.token,
      this.fullName,
      this.email,
      this.salonName,
      this.phoneNumber,
      this.address,
      this.packageId,
      this.adminId,
      this.salonId});

  Login_model.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    token = json['token'];
    fullName = json['full_name'];
    email = json['email'];
    salonName = json['salon_name'];
    phoneNumber = json['phone_number'];
    address = json['address'];
    packageId = json['package_id'];
    adminId = json['admin_id'];
    salonId = json['salon_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    data['token'] = this.token;
    data['full_name'] = this.fullName;
    data['email'] = this.email;
    data['salon_name'] = this.salonName;
    data['phone_number'] = this.phoneNumber;
    data['address'] = this.address;
    data['package_id'] = this.packageId;
    data['admin_id'] = this.adminId;
    data['salon_id'] = this.salonId;
    return data;
  }
}
